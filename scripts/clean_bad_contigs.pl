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
use Stats;
use GenomeTypeObject;
use RoleParse;

=head1 Clean Bad Contigs From a Genome Package

    clean_bad_contigs.pl [ options ] packageDir pkg1 pkg2 ... pkgN

This script processes a quality-checked genome package and produces a C<bin1.fa> file that contains only good contigs. To determine the
good contigs, we first examine the C<EvalBySciKit/evaluate.out> file and isolate the IDs of the roles that have the correct count (the
I<good roles>). We then read through the L<GenomeTypeObject> in C<bin.gto> and identify the contigs that contain a good role. Finally,
we produce the output FASTA file containing only the identified contigs.

=head2 Parameters

The positional parameters are the name of the directory containing the genome packages plus the IDs of one or more packages to process.

The command-line options are the following.

=over 4

=item all

If specified, all of the packages in the directory will be processed. In this case, no package IDs should be specified.

=item roles

The name of the role description file. This is a tab-delimited file containing in each record the role ID, the role checksum, and the role name.
The default is C<roles.in.subsystems> in the global data directory, which will work in a standard SEEDtk environment.

=item missing

Only process packages that don't already have an output file.

=item suffix

The suffix to place on the name portion of the output file. The default is C<1>, indicating C<bin1.fa>.

=item coarse

If specified, then a good role is one that is expected, rather than one with an exact match.

=back

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('packageDir pkg1 pkg2 ... pkgN',
        ['all', 'process all packages'],
        ['roles=s', 'role definition file', { default => "$FIG_Config::global/roles.in.subsystems" }],
        ['missing', 'skip packages already processed'],
        ['suffix=s', 'output file suffix', { default => '1' }],
        ['coarse', 'use coarse criterion for good roles'],
        );
# Create the statistics object.
my $stats = Stats->new();
# Get the good-role criterion.
my $fine;
if ($opt->coarse) {
    print "Coarse mode selected.\n";
    $fine = 0;
} else {
    print "Fine mode selected.\n";
    $fine = 1;
}
# Get the suffix.
my $suffix = $opt->suffix;
my $outFileName = "bin$suffix.fa";
print "Output files will be called $outFileName.\n";
# Get the packages to process.
my ($packageDir, @pkgs) = @ARGV;
if (! $packageDir) {
    die "No package directory specified.";
} elsif (! -d $packageDir) {
    die "$packageDir missing or invalid.";
} elsif ($opt->all) {
    print "Computing package list.\n";
    opendir(my $dh, $packageDir) || die "Could not open $packageDir: $!";
    @pkgs = grep { $_ =~ /\d+\.\d+/ } readdir $dh;
}
print scalar(@pkgs) . " packages to be processed.\n";
# Read the role map.
my %roleMap;
my $roleFile = $opt->roles;
open(my $rh, "<$roleFile") || die "Could not open role map $roleFile: $!";
while (! eof $rh) {
    my $line = <$rh>;
    chomp $line;
    my ($roleID, $checksum) = split /\t/, $line;
    $roleMap{$checksum} = $roleID;
}
close $rh;
# Loop through the packages.
for my $pkg (@pkgs) {
    my $gtoFile = "$packageDir/$pkg/bin.gto";
    my $evalFile = "$packageDir/$pkg/EvalBySciKit/evaluate.out";
    my $outFile = "$packageDir/$pkg/$outFileName";
    if (! -s $gtoFile) {
        print "$pkg is invalid-- skipping.\n";
        $stats->Add(badPackage => 1);
    } elsif (! -s $evalFile) {
        print "$pkg was not evaluated-- skipping.\n";
        $stats->Add(unreadyPackage => 1);
    } elsif ($opt->missing && -s $outFile) {
        print "$pkg already has a cleaned version-- skipping.\n";
        $stats->Add(skippedPackage => 1);
    } else {
        print "Processing $pkg.\n";
        $stats->Add(packages => 1);
        # Read the role expectation list to compute the good roles.
        open(my $ih, "$packageDir/$pkg/EvalBySciKit/evaluate.out") || die "Could not load role expectation file for $pkg: $!";
        my %goodRoles;
        my $count = 0;
        while (! eof $ih) {
            my $line = <$ih>;
            chomp $line;
            my ($role, $expect, $found) = split /\t/, $line;
            if ($fine ? ($expect == $found) : ($expect >= $found)) {
                $goodRoles{$role} = 1;
                $stats->Add(goodRole => 1);
                $count++;
            } else {
                $stats->Add(badRole => 1);
            }
        }
        close $ih;
        print "$count good roles found.\n";
        # Read the GTO and compute the good contigs.
        my %goodContigs;
        my $gto = GenomeTypeObject->create_from_file("$packageDir/$pkg/bin.gto");
        my $featuresL = $gto->{features};
        for my $feature (@$featuresL) {
            $stats->Add(featureProcessed => 1);
            my $function = $feature->{function};
            my @roles = SeedUtils::roles_of_function($function);
            my $good;
            for my $role (@roles) {
                my $checksum = RoleParse::Checksum($role);
                my $roleID = $roleMap{$checksum};
                if (! $roleID) {
                    $stats->Add(roleNotMapped => 1);
                } elsif (! $goodRoles{$roleID}) {
                    $stats->Add(roleNotGood => 1);
                } else {
                    $good = 1;
                    $stats->Add(roleGood => 1);
                }
                if ($good) {
                    $stats->Add(goodFeature => 1);
                    my $locs = $feature->{location};
                    for my $loc (@$locs) {
                        $goodContigs{$loc->[0]}++;
                    }
                }
            }
        }
        # Now we have a list of good contigs. We need some counts.
        my ($contigKept, $contigSkipped, $dnaKept, $dnaSkipped) = (0, 0, 0, 0);
        # Open the output file.
        print "Writing $outFile.\n";
        open(my $oh, ">$outFile") || die "Could not open $outFile: $!";
        # Get the contig list.
        my $contigsL = $gto->{contigs};
        for my $contig (@$contigsL) {
            my $contigID = $contig->{id};
            my $dna = $contig->{dna};
            my $len = length $dna;
            $stats->Add(contigsProcessed => 1);
            if ($goodContigs{$contigID}) {
                $contigKept++;
                $dnaKept += $len;
                print $oh ">$contigID\n$dna\n";
                $stats->Add(contigsKept => 1);
                $stats->Add(dnaKept => $len);
            } else {
                $contigSkipped++;
                $dnaSkipped += $len;
                $stats->Add(contigsRejected => 1);
                $stats->Add(dnaRejected => 1);
            }
        }
        close $oh;
        print "$contigKept contigs kept with $dnaKept bases.\n";
        print "$contigSkipped contigs rejected with $dnaSkipped bases.\n";
    }
}
print "All done.\n" . $stats->Show();
