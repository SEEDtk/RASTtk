#!/usr/bin/env perl
#
# Copyright (c) 2003-2015 University of Chicago and Fellowship
# for Interpretations of Genomes. All Rights Reserved.
#
# This file is part of the SEED Toolkit.
#
# The SEED Toolkit is free software. You can redistribute
# it and/or modify it under the terms of the SEED Toolkit
# Public License.
#
# You should have received a copy of the SEED Toolkit Public License
# along with this program; if not write to the University of Chicago
# at info@ci.uchicago.edu or the Fellowship for Interpretation of
# Genomes at veronika@thefig.info or download a copy from
# http://www.theseed.org/LICENSE.TXT.
#


use strict;
use warnings;
use FIG_Config;
use ScriptUtils;
use File::Copy::Recursive;
use RASTlib;
use GenomeTypeObject;
use gjoseqlib;
use GPUtils;

=head1 Create a New Genome Package From Cleaned FASTAs

    package_cleaned_bins.pl [ options ] packageDir outputDir

This script operates on genome packages for which an alternate FASTA file has been created by L<clean_bad_contigs.pl>.
The cleaned FASTA files have the name C<bin>I<X>C<.fa>, where I<X> is usually C<1>. The file is fed to RAST to create
a new GTO file and then the GTO and FA files will be combined to produce a new package in the specified output directory.
A marker will be put in C<clean.log> in the input package directory to denote that the new package has been created.
This marker is used to insure that we don't try converting the same package twice (a useful thing if we need to restart
this script after a server failure).

=head2 Parameters

There are two positional parameters, the name and path of the genome packages directory, and the name and path of the output
directory. The new genome packages will be created in the latter directory. If the latter directory is omitted, then the input
packages directory is used.

The command-line options are the following.

=over 4

=item user

User name for RAST access. The default is taken from the environment.

=item password

Password for RAST access.  The default is taken from the environment.

=item sleep

Sleep interval in seconds while waiting for the job to complete. The default is C<60>.

=item suffix

Suffix to use for files containing the clean contigs. The default is C<1>, which yields a file name of C<bin1.fa>.

=item force

If specified, all bins will be processed, regardless of whether or not they have been processed before.

=back

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('packageDir outputDir',
        ["user|u=s", "user name for RAST access"],
        ["password|p=s", "password for RAST access"],
        ["sleep=i", "sleep interval for status polling", { default => 60 }],
        ["suffix=s", "input file name suffix", { default => '1' }],
        ["force", "process all bins, even ones already processed or good"]
        );
# Get the two directories.
my ($packageDir, $outputDir) = @ARGV;
if (! $packageDir) {
    die "You must specified a package directory.";
} elsif (! -d $packageDir) {
    die "Invalid or missing package directory $packageDir.";
}
print "Input packages will be taken from $packageDir.\n";
if (! $outputDir) {
    $outputDir = $packageDir;
    print "Output will be to input directory $packageDir.\n";
} elsif (! -d $outputDir) {
    die "Invalid or missing output directory $outputDir.";
} else {
    print "Output packages will be created in $outputDir.\n";
}
# Get the force flag.
my $force = $opt->force;
print "Force flag is " . ($force ? "ON" : "off") . ".\n";
# Compute the input FASTA file name.
my $suffix = $opt->suffix;
my $inFileName = "bin$suffix.fa";
# Find the cleaned packages.
opendir(my $dh, $packageDir) || die "Could not open $packageDir: $!";
my @pkgs = sort grep { -s "$packageDir/$_/bin.gto" } readdir $dh;
closedir $dh;
print scalar(@pkgs) . " packages found in $packageDir.\n";
for my $pkg (@pkgs) {
    my $pDir = "$packageDir/$pkg";
    # If we are NOT forcing, check to see if this is a redundant operation.
    my $found;
    if (! $force && -s "$pDir/clean.log") {
        open(my $ih, "<$pDir/clean.log") || die "Could not open clean.log: $!";
        while (! eof $ih && ! $found) {
            my $line = <$ih>;
            if ($line =~ /^(bin[^.]+\.fa)\s/ && $1 eq $inFileName) {
                $found = 1;
            }
        }
    }
    if ($found) {
        print "$pkg already processed-- skipping.\n";
    } elsif (! -s "$pDir/$inFileName") {
        print "$pkg does not have an $inFileName-- skipping.\n";
    } else {
        # Get the old quality information.
        my ($good, $cmplt, $contam, $coarse, $fine) = package_quality($pDir);
        # Get the taxonomy ID and name from the old GTO.
        my ($taxonID, $name) = get_taxon($pDir);
        print "Package is $taxonID: $name.\n";
        $name = "$name (cleaned)";
        # Read the contigs.
        my $newFa = "$pDir/$inFileName";
        my $triples = gjoseqlib::read_fasta($newFa);
        my ($contigs, $bases) = (0,0);
        for my $triple (@$triples) {
            $contigs++;
            $bases += length($triple->[2]);
        }
        # Create the GTO.
        print STDERR "Submitting cleaned $pkg contigs to RAST.\n";
        my %options = ('sleep' => $opt->sleep, user => $opt->user, password => $opt->password);
        my $gto = RASTlib::Annotate($triples, $taxonID, $name, %options);
        # Output the GTO.
        my $newID = $gto->{id};
        print STDERR "Creating new GenomePackage $newID.\n";
        my $newDir = "$outputDir/$newID";
        if (-d $newDir) {
            die "Redundant genome ID returned $newID.";
        } else {
            print "Creating $newID in $outputDir.\n";
            File::Copy::Recursive::pathmk($newDir) || die "Could not create $newDir: $!";
            File::Copy::Recursive::fmove($newFa, "$newDir/bin.fa") || die "Could not copy FASTA: $!";
            SeedUtils::write_encoded_object($gto, "$newDir/bin.gto");
            open(my $oh, '>', "$newDir/data.tbl") || die "Could not open new data.tbl: $!";
            print $oh "Genome Name\t$name\n";
            print $oh "Source Package\t$pkg\n";
            print $oh "Contigs\t$contigs\n";
            print $oh "Base pairs\t$bases\n";
            close $oh; undef $oh;
            # Record this in the cleaning log.
            open($oh, '>>', "$pDir/clean.log") || die "Could not open clean.log for $pkg: $!";
            print $oh "$inFileName produced $newID in $outputDir.\n";
            close $oh; undef $oh;
            # Evaluate the new package.
            print "Running CheckM.\n";
            my $outDir = "$newDir/EvalByCheckm";
            my $cmd = "checkm lineage_wf --tmpdir $FIG_Config::temp -x fa --file $newDir/evaluate.log $newDir $outDir";
            SeedUtils::run($cmd);
            File::Copy::Recursive::fmove("$newDir/evaluate.log", "$newDir/EvalByCheckm/evaluate.log");
            print "Running SciKit.\n";
            $outDir = "$newDir/EvalBySciKit";
            $cmd = "gto_consistency $newDir/bin.gto $outDir $FIG_Config::p3data/FunctionPredictors $FIG_Config::p3data/roles.in.subsystems $FIG_Config::p3data/roles.to.use";
            SeedUtils::run($cmd);
            print "Package $pkg transformed to $newID: $name\n";
            my $qual = int(($cmplt + 1.06 * $fine - 10 * $contam) * 100) / 100;
            print "Old stats are $cmplt complete, $contam contamination, $coarse coarse-consistent, $fine fine-consistent, $qual quality.\n";
            ($good, $cmplt, $contam, $coarse, $fine) = package_quality($newDir);
            $qual = int(($cmplt + 1.06 * $fine - 10 * $contam) * 100) / 100;
            print "New stats are $cmplt complete, $contam contamination, $coarse coarse-consistent, $fine fine-consistent, $qual quality.\n";
            if ($good) {
                print "PACKAGE IS NOW GOOD.\n";
            }
        }
    }
}

sub get_taxon {
    my ($pDir) = @_;
    my $gto = GenomeTypeObject->create_from_file("$pDir/bin.gto");
    my $taxon = $gto->{ncbi_taxonomy_id};
    my $name = $gto->{scientific_name};
    return ($taxon, $name);
}

sub package_quality {
    my ($pDir) = @_;
    # Get the checkm scores.
    my ($checkMscore, $checkMcontam) = (0, 100);
    if (-d "$pDir/EvalByCheckm") {
        if (open(my $fh, '<', "$pDir/EvalByCheckm/evaluate.log")) {
            while (! eof $fh) {
                my $line = <$fh>;
                if ($line =~ /^\s+bin\s+/) {
                    my @cols = split /\s+/, $line;
                    $checkMscore = $cols[13];
                    $checkMcontam = $cols[14];
                }
            }
            close $fh;
        }
    }
    # Get the scikit score.
    my ($scikitCScore, $scikitFScore) = (0, 0);
    if (-d "$pDir/EvalBySciKit") {
        if (open(my $fh, '<', "$pDir/EvalBySciKit/evaluate.log")) {
            while (! eof $fh) {
                my $line = <$fh>;
                if ($line =~ /^Coarse_Consistency=\s+(.+)\%/) {
                    $scikitCScore = $1;
                } elsif ($line =~ /^Fine_Consistency=\s+(.+)%/) {
                    $scikitFScore = $1;
                }
            }
            close $fh;
        }
    }
    # Are we probably good?
    my $good = ($checkMcontam <= 10 && $checkMscore >= 80 && $scikitFScore >= 85);
    if ($good) {
        # Yes, check the seed protein.
        my $gto = GenomeTypeObject->create_from_file("$pDir/bin.gto");
        $good = GPUtils::good_seed($gto);
    }
    return ($good, $checkMscore, $checkMcontam, $scikitCScore, $scikitFScore);
}

