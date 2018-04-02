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


package GPUtils;

    use strict;
    use warnings;
    use GenomeTypeObject;
    use RoleParse;
    use SeedUtils qw();

=head1 GenomePackage Utilities

This package provides utilities for managing a directory of genome packages.Each genome package is a directory with the
same name as the genome ID and contains the following files

=over 4

=item bin.gto

A L<GenomeTypeObject> for the genome.

=item bin.fa

A FASTA file containing the genome.

=item data.tbl

A tab-delimited file of key/value pairs, with the following keys.

=over 8

=item Genome Name

Name of the genome

=item Source Database

PATRIC or CORE

=item Contigs

The number of contigs in the genome.

=item Base pairs

The number of DNA base pairs in the genome's contigs.

=item Sample Name (sometimes)

Name of the source binning sample.

=item Bin Number (sometimes)

Index number of the source bin.

=back

=item EvalBySciKit

A directory containing the results of a SciKit quality evaluation.

=item EvalByCheckM

A directory containing the results of a CheckM quality evaluation.

=back

=head2 Feature Objects

Many of the methods in this library return a list of feature objects. A feature object is a reference to a hash with (among
other things) the following fields.

=over 4

=item id

The feature ID (in FIG format).

=item location

The feature location. This is represented as a reference to a list of 4-tuples. Each tuple consists of (0) the contig ID,
(1) the start location, (2) the strand (C<+> or C<->), and (3) the length. The location is always a tuple list. If there is
a single segment (the most common case), the contig will be at C<< $loc->[0][0] >>, not C<< $loc->[0] >>.

=item type

The feature type (e.g. C<rna>, C<peg>, C<pg>).

=item function

The feature's functional assignment.

=item protein_translation (optional)

The feature's amino acid sequence (if any).

=item family_assignments (optional)

The feature's protein families. This is represented as a reference to a list of sub-lists. Each sub-list consists of (0) the
family type (C<PGFAM>, C<PLFAM>, C<FIGFAM>), (1) the family ID, (2) the family function, and optionally (3) the family version.

=back

=head2 Public Methods

=head3 get_all

    my $genomeHash = GPUtils::get_all($dir);

Return a hash of genome IDs to directory locations. This hash serves as input to several other methods in this library.
The list of keys from the hash can be used to traverse all the genomes.

=over 4

=item dir

The name of the directory containing the genome packages, which may be split into subdirectories.

=item RETURN

Returns a reference to a hash, keyed on genome ID, that maps each ID to its package directory.

=back

=cut

sub get_all {
    my ($dir) = @_;
    # This will be the return hash.
    my %retVal;
    # We prime a stack of directories to process with the start directory.
    my @stack = ($dir);
    # Process the stack.
    while (my $current = pop @stack) {
        opendir(my $dh, $current) || die "Could not open package directory $current: $!";
        # Get all the sub-directories.
        my @subs = grep { substr($_,0,1) ne '.' && -d "$current/$_" } readdir $dh;
        # Loop through them. Genome packages are saved, and others are stacked.
        for my $sub (@subs) {
            my $fullDir = "$current/$sub";
            if (-s "$fullDir/bin.gto") {
                # This is a real genome package.
                $retVal{$sub} = $fullDir;
            } else {
                # This is another subdirectory we need to check.
                push @stack, $fullDir;
            }
        }
    }
    # Return the hash found.
    return \%retVal;
}

=head3 gto_of

    my $gto = GPUtils::gto_of($genomeHash, $genome);

Get the L<GenomeTypeObject> for the specified genome in the specified package complex.

=over 4

=item genomeHash

The hash of genome packages returned from L</get_all>.

=item genome

The ID of the genome whose GTO is desired.

=item RETURN

A L<GenomeTypeObject> for the identified genome.

=back

=cut

sub gto_of {
    my ($genomeHash, $genome) = @_;
    my $gtoDir = $genomeHash->{$genome};
    if (! $gtoDir) {
        die "$genome not found.";
    } elsif (! -f "$gtoDir/bin.gto") {
        die "$genome does not have a GTO file.";
    }
    my $retVal = GenomeTypeObject->create_from_file("$gtoDir/bin.gto");
    return $retVal;
}

=head3 role_to_features

    my $featureList = GPUtils::role_to_features($gto, $role);

Search the specified L<GenomeTypeObject> for all features with the specified functional role. Note that this works
even if the role is part of a multi-role functional assignment.

=over 4

=item gto

A L<GenomeTypeObject> returned by L</gto_of>.

=item role

A functional role description.

=item RETURN

Returns a reference to a list of L</Feature Objects> for the features containing the specified functional role.

=back

=cut

sub role_to_features {
    my ($gto, $role) = @_;
    # Get the checksum of the role.
    my $target = RoleParse::Checksum($role);
    # The features found will be put in here.
    my @retVal;
    # Loop through the features of the GTO.
    my $allFeatures = $gto->{features};
    for my $feature (@$allFeatures) {
        my $function = $feature->{function};
        if ($function) {
            my @roles = SeedUtils::roles_of_function($function);
            my $found;
            for my $role (@roles) {
                my $possible = RoleParse::Checksum($role);
                if ($possible eq $target) {
                    $found = 1;
                }
            }
            if ($found) {
                push @retVal, $feature;
            }
        }
    }
    # Return the features found.
    return \@retVal;
}


=head3 all_pegs

    my $featureList = GPUtils::all_pegs($gto);

Return a list of all the protein-encoding features in the specified L<GenomeTypeObject>.

=over 4

=item gto

The L<GenomeTypeObject> whose proteins are desired.

=item RETURN

Returns a list of L</Feature Objects> for the protein features of the incoming genome.

=back

=cut

sub all_pegs {
    my ($gto) = @_;
    # The features found will be put in here.
    my @retVal;
    # Loop through the genome features.
    my $allFeatures = $gto->{features};
    for my $feature (@$allFeatures) {
        if ($feature->{id} =~ /\.peg\.\d+$/) {
            push @retVal, $feature;
        }
    }
    return \@retVal;
}

=head3 get_data

    my $dataHash = GPUtils::get_data($genomeHash, $genome);

Return a hash of the genome package's metadata entries.

=over 4

=item genomeHash

The hash of genome packages returned from L</get_all>.

=item genome

The ID of the genome whose metadatais desired.

=item RETURN

Returns a reference to a hash mapping each metadata key to its value.

=back

=cut

sub get_data {
    my ($genomeHash, $genome) = @_;
    # This will be the return hash.
    my %retVal;
    # Find the data file.
    my $genomeDir = $genomeHash->{$genome};
    my $dataFile = "$genomeDir/data.tbl";
    open(my $ih, "<$dataFile") || die "Could not open data.tbl for $genome: $!";
    while (! eof $ih) {
        my $line = <$ih>;
        if ($line =~ /^([^\t]+)\t(.*)/) {
            $retVal{$1} = $2;
        }
    }
    # Return the key/value map.
    return \%retVal;
}

=head3 good_seed

    my $isGood = GPUtils::good_seed($gto);

Return TRUE if the specified genome has exactly one occurrence of the SEED protein and its length is within
acceptable limits, else FALSE.

=over 4

=item gto

A L<GenomeTypeObject> for the specified genome.

=item RETURN

Returns TRUE if the genome is good, else FALSE.

=back

=cut

sub good_seed {
    my ($gto) = @_;
    my $retVal = 0;
    my $flist = role_to_features($gto, 'Phenylalanyl-tRNA synthetase alpha chain');
    if (scalar @$flist == 1) {
        my $domain = $gto->{domain};
        my ($min, $max) = (209, 405);
        if ($domain eq 'Archaea') {
            ($min, $max) = (293, 652);
        }
        my $aa = $flist->[0]{protein_translation};
        my $aaLen = length $aa;
        if ($aaLen >= $min && $aaLen <= $max) {
            $retVal = 1;
        }
    }
    return $retVal;
}


1;