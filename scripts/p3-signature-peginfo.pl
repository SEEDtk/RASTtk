### OBSOLETE ###

=head1 Return Signature Feature Data From Families in PATRIC

    p3-signature-peginfo

This script is a shortcut to create the input file for L<p3-signature-clusters.pl> from the output of
L<p3-signature-families.pl>. It takes the signature-families output file and the list of relevant genomes (the
C<--gs1> option from signature-families) and produces a file of feature data restricted to features in the
families belonging to the specified genomes.

=head2 Parameters

There are no positional parameters.

The standard input can be overriddn using the options in L<P3Utils/ih_options>.

The additional command-line option is

=over 4

=item gs1

Name of a tab-delimited file containing genome IDs in a column labelled C<genome.genome_id>.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::ih_options(),
        ['gs1|g=s', 'name of a file containing genome IDs', { required => 1 }],
        ['batchSize=i', 'recommended input batch size', { default => 100 }]);
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Compute the output columns.
my @selectList = qw(patric_id accession start end strand product);
my @newHeaders = map { "feature.$_" } @selectList;
# Initialize the filter.
my $filterList = [];
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, 'family.family_id');
# Compute the family ID column.
my $famField = 'plfam_id';
my $genomeFile = $opt->gs1;
# Get the headers from the genome file.
open(my $gh, "<$genomeFile") || die "Could not open genome file: $!";
my ($gHeaders, $gCol) = P3Utils::process_headers($gh, 'genome.genome_id');
# Read it in.
my $genomeIDs = P3Utils::get_col($gh, $gCol);
# Create the genome ID filter and add it to the existing filter data.
my $gFilter = ['in', 'genome_id', '(' . join(',', @$genomeIDs) . ')'];
push @$filterList, $gFilter;
# Form the full header set and write it out.
push @$outHeaders, @newHeaders;
P3Utils::print_cols($outHeaders);
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    # Get the output rows for these input couplets.
    my $resultList = P3Utils::get_data_batch($p3, feature => $filterList, \@selectList, $couplets, $famField);
    # Print them.
    for my $result (@$resultList) {
        P3Utils::print_cols($result);
    }
}
