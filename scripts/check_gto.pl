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
use GenomeTypeObject;
use File::Copy::Recursive;
use Stats;
use GtoChecker;
use Math::Round;

=head1 Check Completeness and Contamination for One or More GTOs

    check_gto.pl [ options ] outDir gto1 gto2 gto3 ... gtoN

This script takes as input a list of L<GenomeTypeObject> files. For each, it examines the features to determine
completeness and contamination.  In addition, a file of the marker roles will be written out so that the problematic
roles can be determined.

=head2 Parameters

The positional parameters are the name of the output directory followed by the names of all the GTO files to examine.
If a directory is specified for a GTO name, all I<*>C<.gto> files in the directory will be processed.

The command-line options are the following.

=over 4

=item roleFile

The name of the file containing the role ID mappings. This file is headerless and contains in each record (0) a role ID,
(1) a role checksum, and (2) the role name. The default is C<roles.in.subsystems> in the global data directory.

=item workDir

The name of the directory containing the C<roles.tbl> and C<taxon_map.tbl> files produced by the data generation scripts
(see L<GtoChecker>). The default is C<CheckG> in the global data directory.

=item missing

If specified, only GTOs without output files in the output directory will be processed.

=item packages

If specified, each directory name will be presumed to by a genome package directory, and all the genome packages in it
will be processed. If a value is specified, it will be treated as a file name, and an evaluation comparison report will
be written to it.

=item eval

If specified, the output files will be named C<evaluate.log> and C<evaluate.out> instead of being based on the genome ID.

=item quiet

Display fewer log messages.

=back

=head2 Output Files

For each GTO, two output files will be produced, both tab-delimited with headers and named after the GTO's genome ID.
I<genome>C<.out> will contain the completeness, contamination, and relevant taxonomic group for the genome. I<genome>C<.tbl>
will contain a table of marker roles and the number of times each role was found. Roles with a count of C<0> are missing.
Roles with a count greater than C<1> indicate contamination. Note the file name matches the genome ID, so a GTO with a genome
ID of C<100226.10> will produce files named C<100226.10.out> and C<100226.10.tbl>.

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('outDir gto1 gto2 gto3 ... gtoN', ScriptUtils::ih_options(),
        ['roleFile|roles|R=s', 'role-mapping file', { default => "$FIG_Config::global/roles.in.subsystems" }],
        ['workDir=s', 'directory containing data files', { default => "$FIG_Config::global/CheckG" }],
        ['missing|m', 'only process new GTOs'],
        ['packages:s', 'directory inputs contain genome packages'],
        ['eval', 'use evaluate output file naming (only valid for single input GTO)'],
        ['quiet', 'display fewer messages']
        );
# Get the statistics object.
my $stats = Stats->new();
# Verify the parameters.
my ($outDir, @gtos) = @ARGV;
if (! $outDir) {
    die "No output directory specified.";
} elsif (! -d $outDir) {
    print "Creating $outDir.\n";
    File::Copy::Recursive::pathmk($outDir) || die "Could not create output directory: $!";
}
if (! @gtos) {
    die "No input GTOs specified.";
}
# Get the options.
my $missing = $opt->missing;
my $packages = $opt->packages;
my $workDir = $opt->workdir;
my $roleFile = $opt->rolefile;
my $quiet = $opt->quiet;
my ($packageFlag, $ph);
if (defined $packages) {
    $packageFlag = 1;
    if ($packages) {
        open($ph, ">$packages") || die "Could not open package report: $!\n";
        print $ph "GenomeID\tconsist\tcomplete\tcm-complete\tmulti\tcm-multi\tcontam\tgood\n";
    }
}
# Now we create a list of all the GTOs.
print "Gathering input.\n" if ! $quiet;
my @inputs;
# Now we loop through the GTOs.
for my $gtoName (@gtos) {
    if (-d $gtoName) {
        opendir(my $dh, $gtoName) || die "Could not open $gtoName: $!";
        my @files;
        if ($packages) {
            print "Collecting genome packages in $gtoName.\n";
            my @dirs = grep { substr($_,0,1) ne '.' && -d "$gtoName/$_" } readdir $dh;
            for my $dir (@dirs) {
                my $fileName = "$gtoName/$dir/bin.gto";
                if (-s $fileName) {
                    push @files, $fileName;
                }
            }
            print scalar(@files) . " packages found.\n" if ! $quiet;
        } else {
            print "Collecting GTO files in $gtoName.\n";
            @files = map { "$gtoName/$_" } grep { $_ =~ /\.gto$/ } readdir $dh;
            print scalar(@files) . " GTO files found.\n" if ! $quiet;
        }
        push @inputs, @files;
        closedir $dh;
    } else {
        push @inputs, $gtoName;
    }
}
my $total = scalar @inputs;
# Check the output file naming convention/
my $evalFlag = $opt->eval;
if ($evalFlag && $total > 1) {
    die "Cannot use EVAL option for multiple input GTOs.";
}
print "$total GTO files found.\n" if ! $quiet;
print "Creating GTO Checker object.\n";
my $log = ($quiet ? undef : \*STDOUT);
my $checker = GtoChecker->new($workDir, stats => $stats, roleFile => $roleFile, logH => $log);
# Loop through the GTO files.
my $count = 0;
for my $gtoFile (@inputs) {
    $count++;
    print "Processing $gtoFile ($count of $total).\n" if ! $quiet;
    # Read this GTO.
    my $gto = GenomeTypeObject->create_from_file($gtoFile);
    $stats->Add(gtoRead => 1);
    # Get the genome ID.
    my $genomeID = $gto->{id};
    # Compute the output file names.
    my ($outFile, $tblFile);
    if ($evalFlag) {
        $outFile = "evaluate.log";
        $tblFile = "evaluate.out";
    } else {
        $outFile = "$genomeID.out";
        $tblFile = "$genomeID.tbl";
    }
    # If the output exists and MISSING is on, then skip.
    if (-s "$outDir/$outFile" && $missing) {
        print "Output already in $outDir-- skipping.\n";
        $stats->Add(gtoSkipped => 1);
    } else {
        # Check the genome.
        my $resultH = $checker->Check($gto);
        my $complete = $resultH->{complete};
        if (! defined $complete) {
            print "$gtoFile is from an unsupported taxonomic grouping.\n";
            $stats->Add(gtoFail => 1);
        } else {
            $complete = nearest(0.01, $complete);
            my $contam = nearest(0.01, $resultH->{contam});
            my $multi = nearest(0.01, $resultH->{multi});
            my $roleHash = $resultH->{roleData};
            my $group = $resultH->{taxon};
            print "Producing output for $genomeID in $outDir.\n" if ! $quiet;
            open(my $rh, ">$outDir/$tblFile") || die "Could not open $tblFile: $!";
            print $rh "Role\tCount\tName\n";
            for my $role (sort keys %$roleHash) {
                my $name = $checker->role_name($role);
                print $rh "$role\t$roleHash->{$role}\t$name\n";
            }
            close $rh;
            open(my $oh, ">$outDir/$outFile") || die "Could not open $outFile: $!";
            print $oh "Completeness\tContamination\tMultiplicity\tGroup\n";
            print $oh "$complete\t$contam\t$multi\t$group\n";
            my ($groupWord) = split /\s/, $group;
            $stats->Add("gto-$groupWord" => 1);
            print "Completeness $complete, contamination $contam, and multiplicity $multi using $group.\n";
        }
    }
}
print "All done.\n" . $stats->Show() if ! $quiet;
