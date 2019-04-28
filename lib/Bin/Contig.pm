#
# Copyright (c) 2003-2019 University of Chicago and Fellowship
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


package Bin::Contig;

    use strict;
    use warnings;


=head1 Contig Descriptor for Binning

This object describes a single contig for binning.  It contains the contig ID, the length, and the mean coverage.

The fields in this object are as follows.

=over 4

=item id

The ID of this contig.

=item len

The length of this contig in base pairs.

=item covg

The mean coverage of this contig.

=back

=head2 Special Methods

=head3 new

    my $binContig = Bin::Contig->new($id, $len, $covg);

Create a new contig bin object.

=over 4

=item id

The ID of the contig.

=item len

The length of the contig.

=item covg

The mean coverage of the contig.

=back

=cut

sub new {
    my ($class, $id, $len, $covg) = @_;
    # Create the object.
    my $retVal = [$id, $len, $covg];
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head2 Query Methods

=head3 id

    my $id = $binContig->id

Return the ID of this contig.

=cut

sub id {
    my ($self) = @_;
    return $self->[0];
}

=head3 len

    my $len = $binContig->len

Return the length of this contig.

=cut

sub len {
    my ($self) = @_;
    return $self->[1];
}

=head3 covg

    my $covg = $binContig->covg

Return the mean coverage of this contig.

=cut

sub covg {
    my ($self) = @_;
    return $self->[2];
}

=head2 Public Manipulation Methods

=head3 set_coverage

    $binContig->set_coverage($newCovg);

Store a new mean coverage for this contig.

=over 4

=item newCovg

New coverage value to store.

=back

=cut

sub set_coverage {
    my ($self, $newCovg) = @_;
    $self->[2] = $newCovg;
}

1;