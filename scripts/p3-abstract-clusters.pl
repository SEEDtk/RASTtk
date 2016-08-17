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

use Data::Dumper;
use strict;
use warnings;
use P3Utils;
 
=head1 Compute Abstract Clusters

     p3_abstract clusters <  cluster.signatures > abstract.clusters

     processes a file containing cluster.signatures of the form

     	  famId1 peg1 func1
          famId2 peg2 func2
	  .
	  .
	  .
	  //

=head2 Parameters

=over 4

=back

=cut

my $opt = P3Utils::script_opts('', P3Utils::ih_options());


my $ih = P3Utils::ih($opt);

my @clusters;
$/ = "\n//\n";
while (defined(my $line = <$ih>))
{
    my %fams;
    foreach my $tuple (split("\n",$line))
    {
	if ($tuple =~ /^(\S+)\t(\S+)\t(.*)$/)
	{
	    my($fam,$peg,$func) = ($1,$2,$3);
	    $fams{$fam} = 1;
	}
    }
    push(@clusters,[sort keys(%fams)]);
}
@clusters = sort { @$b <=> @$a } @clusters;

my @abstract_clusters;
my @counts;
while (@clusters > 0)
{
    my $seed = shift @clusters;
    my $count = 1;
    my @left;

    foreach my $x (@clusters)
    {
	if (! &instance($x,$seed))
	{
	    push @left, $x;
	}
	else
	{
	    $count++;
	}
    }
    push(@abstract_clusters,$seed);
    push(@counts,$count);
    @clusters = @left;
}

for (my $i = 0; $i < @abstract_clusters; $i++) {
    my $cluster = $abstract_clusters[$i];
    print $counts[$i] . "\t" . join(",", @$cluster),"\n";
}

sub instance {
    my($clust,$seed) = @_;

    my %seed = map { $_ => 1 } @$seed;
    my @same = grep { $seed{$_} } @$clust;
    my $n = @$clust;
    return (@same >= (0.6 * $n));
}
