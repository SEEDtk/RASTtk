use Data::Dumper;
use strict;
use warnings;
use P3Utils;
use P3DataAPI;
 
=head1 Compute Family Signatures

     p3-signature-families --gs1=FileOfGenomeIds 
                           --gs2=FileOfGenomeIds 
			   [--min=MinGs1Frac]
			   [--max=MaxGs2Frac]
	> family.signatures		   

     This script produces a file in which the last field in each line
     is a family signature. The first field will be the number of hits against Gs1,
     and the second will be the number of hits against Gs2.

=head2 Parameters

=over 4

=item gs1

A tab-delimited file of genomes.  These are thought of as the genomes that have a
given property (e.g. belong to a certain species, have resistance to a particular
antibiotic).

=item gs2

A tab-delimited file of genomes.  These are genomes that do not have the given property.

=item min

Minimum fraction of genomes in Gs1 that occur in a signature family

=item max

Maximum fraction of genomes in Gs2 that occur in a signature family

=back

=cut

my $opt = P3Utils::script_opts('',
        ["gs1=s", "genomes with property",{required => 1}],
        ["gs2=s", "genomes without property",{required => 1}],
        ["min|m=f","minimum fraction of Gs1",{default => 0.8}],
        ["max|M=f","maximum fraction of Gs2",{default => 0.2}]);

# Get access to PATRIC.
my $p3 = P3DataAPI->new();

# Get the command-line options.
my $gs1 = $opt->gs1;
my $gs2 = $opt->gs2;
my $min_in = $opt->min;
my $max_out = $opt->max;

# Read in both sets of genomes.
open(GENOMES,"<$gs1") || die "could not open $gs1";
my %gs1 = map { ($_ =~ /(\d+\.\d+)/) ? ($1 => 1) : () } <GENOMES>;
close(GENOMES);

open(GENOMES,"<$gs2") || die "could not open $gs2";
my %gs2 = map { ($_ =~ /(\d+\.\d+)/) ? ($1 => 1) : () } <GENOMES>;
close(GENOMES);

# This hash will count the number of times each family is found in the sets.
# It is keyed by family ID, and each value is a sub-hash with keys "in" and "out"
# pointing to counts.
my %counts;
# This hash maps families to their annotation product.
my %families;
# This hash maps "in" to a list of all the genomes in the set, and "out" to a list of all
# the genomes not in the set.
my %genomes = (in => [keys %gs1], out => [keys %gs2]);
for my $type (qw(in out)) {
    my $genomeL = $genomes{$type};
    for my $genome (@$genomeL) {
        # Get all of the protein families in this genome. A single family may appear multiple times.
        my $resultList = P3Utils::get_data($p3, feature => [['eq', 'genome_id', $genome], ['eq', 'plfam_id', '*']], ['plfam_id', 'product']);
        # Save the families and count the unique ones.
        my %uniques;
        for my $result (@$resultList) {
            my ($fam, $product) = @$result;
            $families{$fam} = $product;
            if (! $uniques{$fam}) {
                $counts{$fam}{$type}++;
                $uniques{$fam} = 1;
            } 
        }
    }
}
# Print the header.
P3Utils::print_cols([qw(counts_in_set1 counts_in_set2 family.family_id family.product)]);
my $szI = scalar keys %gs1;
my $szO = scalar keys %gs2;
foreach my $fam (keys(%counts)) {
    my $x1 = $counts{$fam}->{in}; if (! defined $x1) { $x1 = 0}
    my $x2 = $counts{$fam}->{out}; if (! defined $x2) { $x2 = 0}
    if ((($x2/$szO) <= $max_out) && (($x1/$szI) >= $min_in)) {
        P3Utils::print_cols([$x1,$x2,$fam, $families{$fam}]);
    }
}
