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
use TetraMap;
use TetraProfile;

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

=item safeLen

If specified, then a contig length. Contigs of this length or greater will not be removed from the bin. A value of C<0> causes the
length check to be ignored.

=item minLen

If specified, then a contig length. Contigs shorter than this length will be removed from the bin in the C<relaxed> algorithm if they
have no good roles.

=item tetra

A tetramer profile distance. Contigs which do not have bad roles but are within this distance of the contigs being kept will be
added back in. A value of C<0> will skip the add-back-in step (this is the default).

=back

In addition, at most one of the following options may be specified, indicating the algorithm for keeping contigs.

=over 4

=item relaxed

If specified, then a contig is kept if it has at least one good role or no bad roles.

=item fine

If specified, then a contig is kept only if it has at least one good role.

=item defrag

If specified, then a contig is kept if it has at least one good role or has more than one feature.

=back

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('packageDir pkg1 pkg2 ... pkgN',
        ['all', 'process all packages'],
        ['roles=s', 'role definition file', { default => "$FIG_Config::global/roles.in.subsystems" }],
        ['missing', 'skip packages already processed'],
        ['suffix=s', 'output file suffix', { default => '1' }],
        ['minLen=i', 'minimum contig length for a contig to be kept in relaxed mode', { default => 500 }],
        ['safeLen=i', 'minimum contig length for contig to be safe from discarding', { default => 0 }],
        ['method' => hidden => { one_of => [
            ['fine', 'keep only contigs with good roles'],
            ['relaxed', 'keep contigs with good roles or with no bad roles (minLen applies to the latter)'],
            ['defrag', 'keep contigs with good roles or multiple features'],
            ], default => 'fine'}],
        ['tetra=f', 'maximum tetramer distance (0 to disable)', { default => 0 }],
        );
# Create the statistics object.
my $stats = Stats->new();
# Determine the algorithm.
my $method = $opt->method;
print ucfirst($method) . " mode selected.\n";
# Determine the tetramer distance.
my $tetraDist = $opt->tetra;
if ($tetraDist) {
    print "Tetramer distance is $tetraDist.\n";
}
# Check for a safe length.
my $safeLen = $opt->safelen;
if ($safeLen) {
    print "Safe length is $safeLen.\n";
}
# Get the minimum length.
my $minLen = $opt->minlen;
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
    closedir $dh;
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
        my %badRoles;
        my ($count, $bCount) = (0, 0);
        while (! eof $ih) {
            my $line = <$ih>;
            chomp $line;
            my ($role, $expect, $found) = split /\t/, $line;
            if ($expect == $found) {
                $goodRoles{$role} = 1;
                $stats->Add(goodRole => 1);
                $count++;
            } else {
                $badRoles{$role} = 1;
                $stats->Add(badRole => 1);
                $bCount++;
            }
        }
        close $ih;
        print "$count good and $bCount bad roles found.\n";
        # This will count the features in a contig.
        my %contigFeats;
        # Read the GTO and compute the good contigs.
        my %goodContigs;
        my %badContigs;
        my $gto = GenomeTypeObject->create_from_file("$packageDir/$pkg/bin.gto");
        my $featuresL = $gto->{features};
        for my $feature (@$featuresL) {
            $stats->Add(featureProcessed => 1);
            my $function = $feature->{function};
            my @roles = SeedUtils::roles_of_function($function);
            my ($good, $bad);
            for my $role (@roles) {
                my $checksum = RoleParse::Checksum($role);
                my $roleID = $roleMap{$checksum};
                if (! $roleID) {
                    $stats->Add(roleNotMapped => 1);
                } elsif ($badRoles{$roleID}) {
                    $stats->Add(roleBad => 1);
                    $bad = 1;
                } elsif (! $goodRoles{$roleID}) {
                    $stats->Add(roleNotGood => 1);
                } else {
                    $good = 1;
                    $stats->Add(roleGood => 1);
                }
            }
            if ($good) {
                $stats->Add(featureGood => 1);
                RecordContigs($feature, \%goodContigs);
                if ($bad) {
                    $stats->Add(featureGoodAndBad => 1);
                }
            }
            if ($bad) {
                $stats->Add(featureBad => 1);
                RecordContigs($feature, \%badContigs);
            }
            if (! $bad && ! $good) {
                $stats->Add(featureNotGood => 1);
            }
            # Record this feature in the contig feature counts.
            RecordContigs($feature, \%contigFeats);
        }
        # This will be our final list of good contigs.
        my %good;
        # This will be the tetramer profile for the good contigs.
        my $mapper = TetraMap->new();
        my $profile = TetraProfile->new($mapper, nolocals => 1, chunkSize => 0);
        # Get the contig list.
        my $contigsL = $gto->{contigs};
        for my $contig (@$contigsL) {
            my $contigID = $contig->{id};
            my $dna = $contig->{dna};
            my $len = length $dna;
            $stats->Add(contigsProcessed => 1);
            my $contigOK;
            if ($goodContigs{$contigID}) {
                $stats->Add(contigsGood => 1);
                $contigOK = 1;
            } elsif ($method eq 'defrag' && $contigFeats{$contigID} && $contigFeats{$contigID} > 1) {
                $stats->Add(contigsNotFrag => 1);
                $contigOK = 1;
            } elsif ($method eq 'relaxed' && ! $badContigs{$contigID}) {
                if ($len >= $minLen) {
                    $stats->Add(contigsNotBad => 1);
                    $contigOK = 1;
                } else {
                    $stats->Add(contigsShort => 1);
                }
            } elsif ($safeLen && $len >= $safeLen) {
                $stats->Add(contigsSafe => 1);
                $contigOK = 1;
            }
            if ($contigOK) {
                # Save the contig and submit it to the profiler.
                $good{$contigID} = 1;
                $profile->ProcessContig($dna);
            }
        }
        # Now we have a list of good and bad contigs. We need some counts.
        my ($contigKept, $contigSkipped, $dnaKept, $dnaSkipped) = (0, 0, 0, 0);
        print "Initial set of good contigs contains " . scalar(keys %good) . "\n";
        # Open the output FASTA file.
        print "Writing $outFile.\n";
        open(my $oh, ">$outFile") || die "Could not open $outFile: $!";
        # Get the tetramer profile.
        my $global = $profile->global;
        # Get the contig list. Here we make our final determination.
        for my $contig (@$contigsL) {
            my $contigID = $contig->{id};
            my $dna = $contig->{dna};
            my $len = length $dna;
            $stats->Add(contigsChecked => 1);
            my $contigOK;
            if ($good{$contigID}) {
                $stats->Add(contigGoodOut => 1);
                $contigOK = 1;
            } elsif ($tetraDist == 0) {
                $stats->Add(contigRejected => 1);
            } else {
                # Compute the contig's tetramer distance.
                my $vec = $mapper->ProcessString($dna);
                TetraMap::Norm($vec);
                my $dist = 1 - TetraMap::dot($global, $vec);
                if ($dist <= $tetraDist) {
                    $stats->Add(contigTetraOut => 1);
                    $contigOK = 1;
                } else {
                    $stats->Add(contigRejected => 1);
                }
            }
            if ($contigOK) {
                $contigKept++;
                $dnaKept += $len;
                print $oh ">$contigID\n$dna\n";
                $stats->Add(dnaKept => $len);
            } else {
                $contigSkipped++;
                $dnaSkipped += $len;
                $stats->Add(dnaRejected => $len);
            }
        }
        close $oh;
        print "$contigKept contigs kept with $dnaKept bases.\n";
        print "$contigSkipped contigs rejected with $dnaSkipped bases.\n";
    }
}
# Now we write out the good contigs. Open the output file.
print "All done.\n" . $stats->Show();

# Record the contigs of a feature into the specified hash.
sub RecordContigs {
    my ($feature, $hash) = @_;
    my $locs = $feature->{location};
    for my $loc (@$locs) {
        $hash->{$loc->[0]}++;
    }
}