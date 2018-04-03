#!/usr/bin/env perl
#
# This is a SAS Component
#

#
# Copyright (c) 2003-2006 University of Chicago and Fellowship
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


use Carp;
use strict;

# usage: cluster_objects < related > sets

=head1 Cluster Objects

    cluster_objects.pl < relation > sets

This script takes as input a relation consisting of a set of pairs and outputs a list of partitions. The input
and output files are both tab-delimited. The input file should have one pair per line, with the pair object IDs
in the first two columns. The output file will have one set per line, each set containing tab-delimited IDs of
the set members. Every object will be in the same set as each object with which it was paired at least once.
The script therefore can be said to perform a transitive closure on the pairings.

=cut

$| = 1;

my %to_cluster;
my %in_cluster;

my $nxt = 1;
while (defined($_ = <STDIN>))
{
    if (($_ =~ /^(\S[^\t]*\S?)\t(\S?[^\t]*\S)/) && ($1 ne $2))
    {
        my $obj1 = $1;
        my $obj2 = $2;
        my $in1 = $to_cluster{$obj1};
        my $in2 = $to_cluster{$obj2};

        if (defined($in1) && defined($in2) && ($in1 != $in2))
        {
            push(@{$in_cluster{$in1}},@{$in_cluster{$in2}});
            foreach $_ (@{$in_cluster{$in2}})
            {
                $to_cluster{$_} = $in1;
            }
            delete $in_cluster{$in2};
        }
        elsif ((! defined($in1)) && defined($in2))
        {
            push(@{$in_cluster{$in2}},$obj1);
            $to_cluster{$obj1} = $in2;
        }
        elsif ((! defined($in2)) && defined($in1))
        {
            push(@{$in_cluster{$in1}},$obj2);
            $to_cluster{$obj2} = $in1;
        }
        elsif ((! defined($in1)) && (! defined($in2)))
        {
            $to_cluster{$obj1} = $to_cluster{$obj2} = $nxt;
            $in_cluster{$nxt} = [$obj1,$obj2];
            $nxt++;
        }
    }
}

foreach my $cluster (keys(%in_cluster))
{
    my $set = $in_cluster{$cluster};
    print join("\t",sort @$set),"\n";
}
