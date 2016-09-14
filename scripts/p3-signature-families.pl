use Data::Dumper;
use strict;
use warnings;
use P3Signatures;
 
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

# Get the command-line options.
my $gs1 = $opt->gs1;
my $gs2 = $opt->gs2;
my $min_in = $opt->min;
my $max_out = $opt->max;

# Read in both sets of genomes.
open(GENOMES,"<$gs1") || die "could not open $gs1";
my @gs1 = map { ($_ =~ /(\d+\.\d+)/) ? ($1) : () } <GENOMES>;
close(GENOMES);

open(GENOMES,"<$gs2") || die "could not open $gs2";
my @gs2 = map { ($_ =~ /(\d+\.\d+)/) ? ($1) : () } <GENOMES>;
close(GENOMES);

# Compute the output hash.
my $dataH = P3Signatures::Process(\@gs1, \@gs2, $min_in, $max_out);
# Print the header.
P3Utils::print_cols([qw(counts_in_set1 counts_in_set2 family.family_id family.product)]);
# Output the data.
foreach my $fam (sort keys %$dataH) {
    my ($x1, $x2, $role) = @{$dataH->{$fam}};
    P3Utils::print_cols([$x1,$x2,$fam, $role]);
}
