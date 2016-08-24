use Data::Dumper;
use strict;
use warnings;
use P3Utils;
 
=head1 Compute Related Protein Families Based on Clusters

     p3-related-by-clusters --gs1 Genome_set_1
                            --gs2 Genome_set_2
                            --sz1 Sample_size_for_gs1
                            --sz2 Sample_size_for_gs2
                            --iterations Number_random_sample_iterations
                            --Output_Directory

This tool takes as input two genome sets.  These will often be 

    gs1    genomes for a specifis species (e.g., Streptococcus pyogenes)
    gs2    genomes from the same genus, but different species

The tool picks random subsets of gs1 and gs2, computes signature families for
each pair of picks, then computes clusters of these families for each pick.

It does a set of iterations, saving the signature clusters for each iteration.

After running the set of iterations, it computes the number of times each pair
of signature families were in signature clusters.

It outputs the pairs of co-ocurring signature families, along with the 
signature clusters computed for each iteration.

The output goes to a created directory.  Within that directory, the subdirectory

    CS

will contain the cluster signatures for each iteraion, and

    related.signature.families 

is set to the predicted functionally-coupled pairs of families:

    [occurrence-count,family1,family2] sorted into descending order based on count.

Each CS/n file contains entries of the form

          famId1 peg1 func1
          famId2 peg2 func2
          .
          .
          .
          //

=head2 Parameters

There are no positional parameters.

Standard input is not used.

The additional command-line options are as follows.

=over 4

=item gs1

Genome set 1: a file containing genome ids in the first column
These genomes will be the onces containing signature families and clusters.

=item gs2

Genome set 2: a file containing genome ids in the first column

=item sz1  

For each iteration pick a sample of sz1 genomes from gs1

=item sz2

For each iteration pick a sample of sz2 genomes from gs2

=item Iterations

run this many iterations of random subsets of gs1 and gs2

=item Output_directory

a created directory that will contain the output

=back

=cut

my ($opt, $helper) = P3Utils::script_opts('', P3Utils::ih_options(), 
					  ["gs1=s","a file containing genome set 1", { required => 1 }],
					  ["gs2=s","a file containing genome set 2", { required => 1 }],
					  ["sz1=i","size of sample from gs1", { default => 20 }],
					  ["sz2=i","size of sample from gs2", { default => 20 }],
					  ["min=f","min fraction of gs1 to be signature family", { default => 1 }],
					  ["max=f","max fraction of gs2 to be signature family", { default => 0 }],
					  ["iterations|n=i",{ default => 20 }],
					  ["output|o=s","output directory", { required => 1 }]);
my $ih = P3Utils::ih($opt);
my $gs1 = $opt->gs1;
my $gs2 = $opt->gs2;
my $sz1 = $opt->sz1;
my $sz2 = $opt->sz2;
my $min = $opt->min;
my $max = $opt->max;
my $iterations = $opt->iterations;
my $outD = $opt->output;
mkdir($outD,0777) || die "could not make $outD";
mkdir("$outD/CS",0777) || die "could not make $outD/CS";

my $i;
for ($i=0; ($i < $iterations); $i++)
{
    &run("p3-pick $sz1 < $gs1 > $outD/sample1");
    &run("p3-pick $sz2 < $gs2 > $outD/sample2");
    &run("p3-signature-families --min $min --max $max --gs1 $outD/sample1 --gs2 $outD/sample2 > $outD/F");
    &run("p3-signature-peginfo --gs1=$outD/sample1 < $outD/F | p3-signature-clusters > $outD/CS/$i");
    &run("get_fam_rel < $outD/CS/$i >> $outD/fam.rel");
}
&run("get_fam_corr < $outD/fam.rel > $outD/related.signature.families");

sub run {
    shift if UNIVERSAL::isa($_[0],__PACKAGE__);
    my($cmd) = @_;

    if ($ENV{FIG_VERBOSE}) {
        my @tmp = `date`;
        chomp @tmp;
        print STDERR "$tmp[0]: running $cmd\n";
    }
    (system($cmd) == 0) || die("FAILED: $cmd");
}
