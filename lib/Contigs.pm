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


package Contigs;

    use strict;
    use warnings;
    use gjoseqlib;
    use SeedUtils;
    use BasicLocation;

=head1 Contig Management Object

This object contains the contigs for a specific genome. it provides methods for extracting
DNA and exporting the contigs in different forms.

The object is a subclass of L<Contigs> that gets the contig data from the L<Shrub> database.

=over 4

=item genome

ID of the relevant genome.

=item comments

Reference to a hash mapping each contig ID to its comment.

=item seqs

Reference to a hash mapping each contig ID to its sequence.

=back

=head2 Special Methods

=head3 new

    my $contigObj = Contigs->new($contigFile, %options);

Create a contig object from a FASTA file.

=over 4

=item contigFile

Name of a FASTA file containing the contig DNA.

=item options

A hash of options, containing zero or more of the following keys.

=over 8

=item genomeID

ID of the relevant genome. If omitted, the default is C<unknown>.

=item geneticCode

Genetic code of the contigs. If omitted, the default is C<11>.

=back

=back

=cut

sub new {
    # Get the parameters.
    my ($class, $contigFile, $genomeID) = @_;
    # Read the specified FASTA file.
    my $triplesList = gjoseqlib::read_fasta($contigFile);
    # Use the triplets we just read to build the object.
    my %comments = map { $_->[0] => $_->[1] } @$triplesList;
    my %seqs = map { $_->[0] => $_->[2] } @$triplesList;
    my $retVal = {
        genome => $genomeID,
        comments => \%comments,
        seqs => \%seqs
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}


=head2 Query Methods

=head3 dna

    my $seq = $contigs->dna(@locs);

Return the DNA at the specified locations. The locations must be in this object's
genome.

=over 4

=item locs

A list of locations. These can be in the form of location strings or L<BasicLocation>
objects.

=item RETURN

Returns a DNA sequence corresponding to the specified locations.

=back

=cut

sub dna {
    # Get the parameters.
    my ($self, @locs) = @_;
    # We'll stash the DNA in here.
    my @retVal;
    # Loop through the locations, creating DNA. Note we convert each
    # one to a basic location object.
    for my $loc (map { BasicLocation->new($_) } @locs) {
        # Get the contig ID.
        my $contigID = $loc->Contig;
        # Does the contig exist?
        my $seqH = $self->{seqs};
        if (! exists $seqH->{$contigID}) {
            # No. Return a bunch of hyphens.
            push @retVal, '-' x $loc->Length;
        } else {
            # Yes. Extract the dna.
            my $dna = substr($seqH->{$contigID}, $loc->Left, $loc->Length);
            # If the direction is negative, reverse complement it.
            SeedUtils::rev_comp(\$dna);
            # Keep the result.
            push @retVal, $dna;
        }
    }
    # Return the DNA.
    return join("", @retVal);
}




1;