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
use File::Basename;
use GenomeTypeObject;

=head1 Create Crippled GTOs

    cripple_gto.pl [ options ] outDir gto1 gto2 ... gtoN

This script removes a certain percentage of features from one or more L<GenomeTypeObject> files, producing new
files in a different directory.

We remove features randomly, so multiple runs of this script will generate different results.

=head2 Parameters

The positional parameters are the name of the output directory and the names of the GTO files to modify.

The command-line options are the following.

=over 4

=item removal

Percent of features to remove. The default is C<25>.

=back

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('outDir gto1 gto2 ... gtoN',
        ['removal|r=f', 'percent of features to remove', { default => 25 }]
        );
# Compute the removal percentage.
my $removal = $opt->removal;
# Get the parameters.
my ($outDir, @gtos) = @ARGV;
# Check the output directory.
if (! $outDir) {
    die "No output directory specified.";
} elsif (! -d $outDir) {
    die "Invalid output directory $outDir.";
}
# Loop through the GTOs.
for my $gtoFile (@gtos) {
    # Get the base file name.
    my $baseName =  fileparse($gtoFile);
    print "Processing $gtoFile.\n";
    # Read in this GTO.
    my $gto = GenomeTypeObject->create_from_file($gtoFile);
    # Get a list of feature IDs.
    my @fids = map { $_->{id} } @{$gto->features};
    # Compute the number of features to delete.
    my $undeleted = scalar(@fids);
    my $deleted = 0;
    my $deleteSize = int($removal * $undeleted / 100);
    # Loop until we've filled the delete list.
    while ($deleted < $deleteSize) {
        # Pick a random feature to delete.
        my $i = int(rand($undeleted));
        my ($removed) = splice @fids, $i, 1;
        $undeleted--;
        $deleted++;
        $gto->delete_feature($removed);
    }
    # Now actually delete the chosen features.
    print "$deleted features removed from genome.\n";
    # Write the result.
    my $outFile = "$outDir/$baseName";
    print "Writing new GTO to $outFile.\n";
    $gto->destroy_to_file($outFile);
}
print "All done.\n";
