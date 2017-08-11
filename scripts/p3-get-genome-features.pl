=head1 Return Features From Genomes in PATRIC

    p3-get-genome-features [options]

This script returns data for all the features in one or more genomes from the PATRIC database. It supports standard filtering
parameters and the specification of additional columns if desired.

=head2 Parameters

There are no positional parameters.

The standard input can be overriddn using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/data_options> and L<P3Utils/col_options> plus the following.

=over 4

=item fields

List the available fields.

=back

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
# Add a safety check to remove null features.
push @$filterList, ['eq', 'patric_id', '*'];
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Form the full header set and write it out.
if (! $opt->nohead) {
    push @$outHeaders, @$newHeaders;
    P3Utils::print_cols($outHeaders);
}
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    # Get the output rows for these input couplets.
    my $resultList = P3Utils::get_data($p3, feature => $filterList, $selectList, genome_id => $couplets);
    # Print them.
    for my $result (@$resultList) {
        P3Utils::print_cols($result, opt => $opt);
    }
}
sub print_usage {
    my $fieldList = P3Utils::list_object_fields('feature');
    print join("\n", @$fieldList, "");
}
