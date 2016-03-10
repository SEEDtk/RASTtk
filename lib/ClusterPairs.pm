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


package ClusterPairs;

    use strict;
    use warnings;

=head1 Clustering Subroutines

This package contains methods for combining pairings into clusters. Any two objects in a pair are
considered to be part of the same cluster.

This object has the following fields.

=over 4

=item to_cluster

Reference to a hash that maps each object ID to a cluster ID.

=item in_cluster

Referehce to a hash that maps each cluster ID to a list of object IDs.

=item next_id

ID to give to the next cluster.

=back

=head2 Special Methods

=head3 new

    my $clusterObj = ClusterPairs->new();

Create a new, blank clustering object.

=cut

sub new {
    my ($class) = @_;
    my $retVal = {
        to_cluster => {},
        in_cluster => {},
        next_id => 1,
    };
    bless $retVal, $class;
    return $retVal;
}


=head2 Public Manipulation Methods

=head3 add_pair

    $clusterObj->add_pair($obj1, $obj2);

Indicate that two objects are paired. This updates the internal hashes. The paired objects are
put into the same cluster.

=over 4

=item obj1

ID of the first object.

=item obj2

ID of the second object.

=back

=cut

sub add_pair {
    my ($self, $obj1, $obj2) = @_;
    # Only proceed if we have two distinct objects.
    if (defined($obj1) && defined($obj2) && $obj1 ne $obj2) {
        my $to_cluster = $self->{to_cluster};
        # Get the IDs of the clusters (if any) containing the objects.
        my $in1 = $to_cluster->{$obj1};
        my $in2 = $to_cluster->{$obj2};
        # Insure each object is in a cluster.
        if (! $in1) {
            $in1 = $self->create_cluster($obj1)
        }
        if (! $in2) {
            $in2 = $self->create_cluster($obj2);
        }
        # Merge the two clusters.
        if ($in1 != $in2) {
            $self->merge_clusters($in1, $in2);
        }
    }
}

=head3 create_cluster

    my $clusterID = $clusterObj->create_cluster($obj);

Create a new cluster containing the specified single object and return its ID.

=over 4

=item obj

ID of the object to put in the cluster.

=item RETURN

Returns the ID of the new cluster.

=back

=cut

sub create_cluster {
    my ($self, $obj) = @_;
    # Compute the new cluster's ID.
    my $retVal = $self->{next_id};
    $self->{next_id}++;
    # Insert the object into the cluster.
    $self->{in_cluster}{$retVal} = [$obj];
    $self->{to_cluster}{$obj} = $retVal;
    # Return the cluster ID.
    return $retVal;
}

=head3 merge_clusters

    $clusterObj->merge_clusters($in1, $in2);

Merge a cluster into another existing cluster.

=over 4

=item in1

ID of the cluster to contain all the objects.

=item in2

ID of the cluster containing the objects to be merged.

=back

=cut

sub merge_clusters {
    my ($self, $in1, $in2) = @_;
    # Get the hashes.
    my $in_cluster = $self->{in_cluster};
    my $to_cluster = $self->{to_cluster};
    # Get the cluster lista.
    my $cluster1 = $in_cluster->{$in1};
    my $cluster2 = $in_cluster->{$in2};
    # Add the second cluster to the first cluster's list.
    push @$cluster1, @$cluster2;
    # Update the to-cluster index for the second cluster's items.
    for my $obj (@$cluster2) {
        $to_cluster->{$obj} = $in1;
    }
    # Delete the second cluster.
    delete $in_cluster->{$in2};
}

=head2 Query Methods

=head3 clusters

    my $clusterIDs = $clusterObj->clusters();

Return a list of the cluster IDs.

=cut

sub clusters {
    my ($self) = @_;
    return [sort { $self->cluster_len($b) <=> $self->cluster_len($a) } keys %{$self->{in_cluster}}];
}

=head3 cluster

    my $memberList = $clusterObj->cluster($in);

Return the object IDs for the objects in a specified cluster.

=over 4

=item in

ID of the relevant cluster.

=item RETURN

Returns a reference to a list of all the object IDs for the specified cluster. If the cluster does
not exist, an empty list will be returned.

=back

=cut

sub cluster {
    my ($self, $in) = @_;
    return ($self->{in_cluster}{$in} // []);
}

=head3 cluster_len

    my $len = $clusterObj->cluster_len($in);

Return the number of objects in the specified cluster.

=over 4

=item in

ID of the desired cluster.

=item RETURN

Number of objects in the cluster, or C<0> if the cluster does not exist.

=back

=cut

sub cluster_len {
    my ($self, $in) = @_;
    my $list = $self->cluster($in);
    return scalar @$list;
}

1;