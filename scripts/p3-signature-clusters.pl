use Data::Dumper;
use strict;
use warnings;
use P3Utils;
 
=head1 Compute Cluster Signatures

     p3-signature-clusters  
        < peg.data                   
        > cluster.signatures

The standard input file normally contains I<[n/a, n/a, family_id, feature_id, contig, start, end, strand, function]>
(the first two columns are ignored). Such a file is created from a family signatures file (output of
L<p3-signature-familes.pl>) using the following command

    p3-signature-peginfo --gs1=FileOfGenomeIds < family.data > peg.data

However, any file containing the appropriately named columns in the headers (see below) will work.

This script produces a file containing entries of the form

          famId1 peg1 func1
          famId2 peg2 func2
          .
          .
          .
          //

if the --verbose flag is used.  Else, you get 1 line per cluster of the form

          genome1 peg11,peg12,...,peg1n1
          genome1 peg13,peg14,...,peg1n2
          genome2 peg21,peg22,...,peg2n1
            .
            .
            .

that is, you get the genome containing the cluster followed by
a comma-separated list of peg ids.  There is often a number of
clusters for a single genome.

In the non-verbose mode you get a header line containing

             genome_id pegs_in_cluster

=head2 Parameters

There are no positional parameters.

The standard input is specified using the options in L<P3Utils::ih_options>. It should be a tab-delimited
file with headers, containing the following fields at minimum.

=over 4

=item family.family_id

The ID of a protein family.

=item feature.patric_id

The ID of a feature in the protein family.

=item feature.accession

The ID of the contig containing the feature.

=item feature.start

The index of the leftmost location for the feature on the contig.

=item feature.end

The index of the rightmost location for the feature on the contig.

=item feature.strand

The strand containing the feature (C<+> or C<->).

=item feature.product

The function assigned to the feature.

=back

The additional command-line options are as follows.

=over 4

=item terse

In normal mode, clusters are written in a readable format, and the
family id and the peg function are included for each member of a
cluster. In terse mode, each cluster is written on a single line.

=item distance

Maximum base-pair distance between the midpoints of two features in order for them to be
considered close. The default is 2000.

=back

=cut

my ($opt, $helper) = P3Utils::script_opts('', P3Utils::ih_options(), 
        ["terse|t","display in abbreviated format"],
        ["distance|d", "maximum distance between close features", { default => 2000 }]);

my $verbose  = ! $opt->terse;
my $distance = $opt->distance;

my %peg_func;
my %genomes;

my $ih = P3Utils::ih($opt);

# Parse the headers to get the input column indices.
my (undef, $cols) = P3Utils::find_headers($ih, input => qw(family.family_id feature.patric_id feature.accession
        feature.start feature.end feature.strand feature.product));
# Loop through the input.
while (! eof $ih)
{
    my($fam,$peg,$contig,$begin,$end,$strand,$func) = P3Utils::get_cols($ih, $cols);
    # Note we only process protein-encoding genes.
    if ($peg =~ /^fig\|(\d+\.\d+)\.peg\.\d+$/)
    {
        # Store this feature and its midpoint with the genome. We will eventually sort
        # by midpoint to assemble the clusters. 
        my $g = $1;
        my $mid = int(($begin+$end)/2);
        push(@{$genomes{$g}},[$contig,$mid,$fam,$peg,$func]);
    }
}

my %fam_score;
my %best_fam_cluster;

foreach my $g (sort { $a <=> $b } keys(%genomes))
{
    #  We compute all clusters for a genome, sort them by length,
    #  print them.
    my @output;

    # Get all the features for this genome and sort them by contig ID and location midpoint.
    my $features = $genomes{$g};
    my @sorted = sort { ($a->[0] cmp $b->[0]) or ($a->[1] <=> $b->[1]) } @$features;

    while (my $x = shift (@sorted))
    {
        #  $x is of the form [$contig,$mid,$fam,$peg,$func]
        my @close = ($x);
        while ((@sorted > 0) && ($sorted[0]->[0] eq $close[-1]->[0]) &&
                                (abs($sorted[0]->[1] - $close[-1]->[1]) < $distance))
        {
            $x = shift @sorted;
            push(@close,$x);
        }
        my $n = @close;
        if ($n > 2)
        {
            push(@output,[$n,[@close]]);
	}
    }
    my @sorted_clusters = sort { $b->[0] <=> $a->[0]} @output;
    foreach my $cluster (@sorted_clusters)
    {
	my $close = $cluster->[1];
	if ($verbose)
	{
	    foreach $_ (@$close)
	    {
		print join("\t",($_->[2],$_->[3],$_->[4])),"\n";
	    }
	    print "//\n";
	}
	else 
	{
	    my $pegs = join(",",map { $_->[3] } @$close);
	    print $g,"\t",$pegs,"\n";
	}
    }
}


