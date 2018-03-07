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
use GPUtils;
use SubsystemProjector;
use File::Copy::Recursive;
use ScriptUtils;

=head1 Project Subsystems onto Genome Packages

    package_subystems.pl [ options ] packageDir

This script will examine the genomes in the specified genome package directory and project subsystems onto them. This involves replacing the
C<bin.gto> files.

=head2 Parameters

The positional parameter is the name of the output directory.

The command-line options are the following:

=over 4

=item roleFile

Name of a tab-delimited file containing [role checksum, subsystem name] pairs.

=item variantFile

Name of a tab-delimited file containing in each record (0) a subsystem name, (1) a variant code, and
(2) a space-delimited list of role checksums.

=back

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('packageDir',
        ['roleFile|r=s', 'name of file containing subsystems for roles', { required => 1 }],
        ['variantFile|v=s', 'name of file containing variant maps', { required => 1}]
        );
# Get the positional parameters.
my ($packageDir) = @ARGV;
# Verify the parameters.
if (! $packageDir) {
    die "No package directory specified.";
} elsif (! -d $packageDir) {
    die "Package directory $packageDir missing or invalid.";
}
# Create the subsystem projector.
print "Initializing projector.\n";
my $projector = SubsystemProjector->new($opt->rolefile, $opt->variantfile);
# Get the statistics object.
my $stats = $projector->stats;
# Get all the packages.
print "Reading package directory.\n";
my $gHash = GPUtils::get_all($packageDir);
# Loop through the genomes.
for my $genome (sort keys %$gHash) {
    print "Reading $genome.\n";
    my $gto = GPUtils::gto_of($gHash, $genome);
    if (! $gto) {
        print "ERROR: genome not found.\n";
        $stats->Add(badGenome => 1);
    } else {
        print "Computing subsystems.\n";
        my $subsystemHash = $projector->ProjectForGto($gto, store => 1);
        my $count = scalar(keys %$subsystemHash);
        print "$count subsystems found.\n";
        # Now we must replace the old GTO file. We write to a new file name, delete the old file, and rename the new one.
        my $genomeDir = $gHash->{$genome};
        my $oldFile = "$genomeDir/bin.gto";
        my $outFile = "$genomeDir/bin.gto~";
        print "Writing output to $outFile.\n";
        $gto->destroy_to_file($outFile);
        print "Overwriting old file.\n";
        unlink $oldFile;
        rename($outFile, $oldFile) || die "Could not rename $outFile: $!";
        $stats->Add(packagesProcessed => 1);
    }
}
print "All done: " . $stats->Show();