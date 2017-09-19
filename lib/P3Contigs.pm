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


package P3Contigs;

    use strict;
    use warnings;
    use P3DataAPI;
    use P3Utils;
    use base qw(Contigs);

=head1 Contig Management Object

This object contains the contigs for a specific genome. it provides methods for extracting
DNA and exporting the contigs in different forms.

The object is a subclass of L<Contigs> that gets the contig data from the PATRIC database.
In addition to the fields in the base-class object. It contains the following.

=over 4

=item p3

L<P3DataAPI> object for accessing the database.

=back

=head2 Special Methods

=head3 new

    my $contigObj = P3Contigs->new($genomeID);

Create a Contigs object for the specified genome ID. If the genome is not found, it will return an undefined value.

=over 4

=item genomeID

ID of the genome whose contigs are desired.

=back

=cut

sub new {
    # Get the parameters.
    my ($class, $genomeID) = @_;
    # This will be the return variable.
    my $retVal;
    # Get the P3 object.
    my $p3 = P3DataAPI->new();
    # Try to read the contigs.
    my $resultList = P3Utils::get_data($p3, contig => [['eq', 'genome_id', $genomeID]], ['sequence_id', 'taxon_id', 'sequence']);
    # Is there a genome?
    if (@$resultList) {
        # Yes. Compute the genetic code from the taxon ID.
        my $taxonID = $resultList->[0][1];
        my $codeList = P3Utils::get_data($p3, taxonomy => [['eq', 'taxon_id', $taxonID]], ['genetic_code']);
        my $geneticCode = (@$codeList ? $codeList->[0][0] : 11);
        # Create the Contigs object.
        my $resultList = [map { [$_->[0], '', $_->[2]] } @$resultList];
        $retVal = Contigs::new($class, $resultList, genomeID => $genomeID, genetic_code => $geneticCode);
        # Add the P3 object.
        $retVal->{p3} = $p3;
    }
    # Return it.
    return $retVal;
}


=head2 Query Methods

=head3 fdna

    my $seq = $contigs->fdna($fid);

Return the DNA for the specified feature.

=over 4

=item fid

The ID of a feature in this object's genome.

=item RETURN

Returns a DNA sequence corresponding to the specified feature.

=back

=cut

sub fdna {
    # Get the parameters.
    my ($self, $fid) = @_;
    # Get the locations for the feature.
    my $locData = P3Utils::get_data($self->{p3}, feature => [['eq', 'patric_id', $fid]], ['strand', 'sequence_id', 'segments']);
    # This will be the return value. If the feature is not found, we'll return an empty string.
    my $retVal = '';
    # Only proceed if we found the feature.
    if (@$locData) {
        my $location = $locData->[0];
        # Convert the segments to location tuples.
        my ($strand, $contigID, $segments) = @$location;
        my @locs;
        for my $segment (@$segments) {
            my ($start, $end) = split /\.\./, $segment;
            my $loc = $contigID . "_$start$strand" . ($end + 1 - $start);
            push @locs, $loc;
        }
        $retVal = $self->dna(@locs);
    }
    # Return the result.
    return $retVal;
}

1;