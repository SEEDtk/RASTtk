=head1 Return Data From Features in PATRIC

    p3-get-feature-data [options]

This script returns data about the features identified in the standard input. It supports standard filtering
parameters and the specification of additional columns if desired.

=head2 Parameters

There are no positional parameters.

The standard input can be overwritten using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/data_options> and L<P3Utils/col_options>.

=cut

use strict;
use P3DataAPI;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::data_options(), P3Utils::col_options(), P3Utils::ih_options(),
    ['fields|f', 'Show available fields']);

my $fields = ($opt->fields ? 1 : 0);
if ($fields) {
    print_usage();
    exit();
}
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Compute the output columns.
my ($selectList, $newHeaders) = P3Utils::select_clause(feature => $opt);
# Compute the filter.
my $filterList = P3Utils::form_filter($opt);
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Form the full header set and write it out.
push @$outHeaders, @$newHeaders;
P3Utils::print_cols($outHeaders);
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    # Get the output rows for these input couplets.
    my $resultList = P3Utils::get_data_batch($p3, feature => $filterList, $selectList, $couplets);
    # Print them.
    for my $result (@$resultList) {
        P3Utils::print_cols($result);
    }
}

sub print_usage {
my $usage = <<"End_of_Usage";
genome_id
genome_name
taxon_id
sequence_id
accession
annotation
annotation_sort
feature_type
feature_id
p2_feature_id
alt_locus_tag
patric_id
gene_id
gi
start
end
strand
location
segments
pos_group
na_length
aa_length
na_sequence
aa_sequence
aa_sequence_md5
gene
product
figfam_id
plfam_id
pgfam_id
ec
pathway
go
End_of_Usage
print $usage;
}
