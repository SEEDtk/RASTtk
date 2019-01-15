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


package P3Sequences;

    use strict;
    use warnings;
    use P3Utils;
    use SeedUtils;

=head1 Utilities for Managing PATRIC DNA Sequences

This object manages a list of PATRIC DNA sequences.  The main data structure is a hash mapping sequence IDs to DNA sequences.
The sequence will be the forward strand, and the regions containing features will be in upper case; the rest in lower case.

The fields in this object are as follows.

=over 4

=item p3

The <P3DataAPI> object for accessing the PATRIC database.

=item seqH

Reference to a hash mapping each sequence ID to its annotated DNA sequence.

=back

=head2 Special Methods

=head3 new

    my $p3seqs = P3Sequences->new($p3);

Create a new, blank P3 sequences object.

=over 4

=item p3

The L<P3DataAPI> object for accessing the PATRIC database.

=back

=cut

sub new {
    my ($class, $p3) = @_;
    # Create the object.
    my $retVal = { p3 => $p3, seqH => {} };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head2 Public Manipulation Methods

=head3 GetSequence

    my $dna = $p3seqs->GetSequence($seqID);

Return the DNA for a specified sequence.  The sequence itself will be stored in the internal hash.  Regions containing features will be
in upper case, the rest in lower case.

=over 4

=item seqID

The ID of the sequence to return.

=item RETURN

Returns the requested DNA sequence, for the requested strand, with the feature-containing regions in upper case.  If the sequence does
not exist, it will return C<undef>.

=back

=cut

sub GetSequence {
    my ($self, $seqID) = @_;
    # Get the sequence hash.
    my $seqH = $self->{seqH};
    # Do we need to load this sequence?
    if (! $seqH->{$seqID}) {
        # Yes, we do.  Read the DNA first.
        my $p3 = $self->{p3};
        my $seqList = P3Utils::get_data($p3, contig => [['eq', 'sequence_id', $seqID]], ['sequence_id', 'genome_id', 'sequence']);
        my $seqData = $seqList->[0];
        if ($seqData) {
            my ($id, $genome, $sequence) = @$seqData;
            # Here we have the sequence.  Get the locations of the features in this sequence.  In PATRIC, the start is always on
            # the left and the end on the right.  We don't need the strand for this.
            my $flocList = P3Utils::get_data($p3, feature => [['eq', 'sequence_id', $seqID], ['eq', 'feature_type', 'CDS']], ['patric_id', 'start', 'end']);
            # Start in lower case.
            $sequence = lc $sequence;
            # Loop through the features, converting them to upper case.  Note we need to adjust the start, since it is a position,
            # not an offset.
            for my $floc (@$flocList) {
                my ($fid, $start, $end) = @$floc;
                $start--;
                my $len = $end  - $start;
                my $newVal = uc substr($sequence, $start, $len);
                substr($sequence, $start, $len) = $newVal;
            }
            # Store the result back.
            $seqH->{$seqID} = $sequence;
        }
    }
    # Return the sequence.
    my $retVal = $seqH->{$seqID};
    return $retVal;
}


=head3 FeatureRegions

    my $fidHash = $p3seqs->FeatureRegions(\@fids, %options);

Return the regions containing the specified features.  For each feature, we will return the DNA for the feature plus the surrounding area, with
occupied portions in upper case and intergenic regions in lower case.

=over 4

=item fids

Reference to a list of a the IDs for the features whose regions are desired.

=item options

A hash containing zero or more of the following keys.

=over 8

=item distance

The distance to display to either side of each feature.  The default is C<100>.

=item consolidated

If requested features are adjacent, they will be included in the region.

=item metrics

If specified, a reference to a hash.  Upon return, the hash will map each feature ID to its starting offset and
length in the returned sequence string.

=back

=item RETURN

Returns a reference to a hash mapping each incoming feature ID to its region sequence.

=back

=cut

sub FeatureRegions {
    my ($self, $fids, %options) = @_;
    my $p3 = $self->{p3};
    # Get the options.
    my $distance = $options{distance} // 100;
    my $consolidate = $options{consolidated};
    my $metrics = $options{metrics} // {};
    # This will be the return hash.
    my %retVal;
    # Get the sequence ID, start, end, and strand for each incoming feature.
    my $fidList = P3Utils::get_data_keyed($p3, feature => [], ['patric_id', 'sequence_id', 'start', 'end', 'strand'], $fids);
    # Set up for consolidation.
    my %fidRegions;
    if ($consolidate) {
        for my $fidTuple (@$fidList) {
            my ($fid, $seqID, $start, $end) = @$fidTuple;
            $fidRegions{$fid} = [$seqID, $start, $end];
        }
    }
    # Loop through the features, extracting regions.
    for my $fidTuple (@$fidList) {
        my ($fid, $seqID, $start0, $end, $strand) = @$fidTuple;
        # Get the sequence from the internal hash.
        my $sequence = $self->GetSequence($seqID);
        # Adjust the start and compute the length.  The start and end are both positions, so there is a -1 adjustment as well.
        $start0--;
        my $len0 = $end - $start0;
        my $len = $len0 + $distance + $distance;
        my $start = $start0 - $distance;
        if ($start < 0) {
            # Note this shrinks the length, since the start location is negative.
            $len += $start;
            # Insure the start is not negative.
            $start = 0;
        }
        # Are we consolidating?
        if ($consolidate) {
            # We loop through the other features.  If they overlap our region, we make the region bigger.
            my $end = $start + $len;
            for my $fid (keys %fidRegions) {
                my ($seqID2, $start2, $end2) = @{$fidRegions{$fid}};
                if ($seqID2 eq $seqID) {
                    if ($start2 < $start && $end2 >= $start) {
                        $len += $start - $start2;
                        $start = $start2;
                    }
                    if ($end2 > $end && $start2 <= $end) {
                        $len += $end2 - $end;
                        $end = $end2;
                    }
                }
            }
        }
        # Get the substring.
        my $region = substr($sequence, $start, $len);
        # Store the metrics.
        $metrics->{$fid} = [$start0 - $start, $len0];
        # Adjust for strand.
        if ($strand eq '-') {
            SeedUtils::rev_comp(\$region);
        }
        # Store in the return hash.
        $retVal{$fid} = $region;
    }
    # Return the hash computed.
    return \%retVal;
}


1;