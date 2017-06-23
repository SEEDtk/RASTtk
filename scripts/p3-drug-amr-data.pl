=head1 Return AMR Data From PATRIC

    p3-drug-amr-data [options]

This script returns general anti-microbial resistance data. It supports standard filtering parameters and
the specification of additional columns if desired.

=head2 Parameters

There are no positional parameters.

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
my ($selectList, $newHeaders) = P3Utils::select_clause(genome_drug => $opt);
# Compute the filter.
my $filterList = P3Utils::form_filter($opt);
P3Utils::print_cols($newHeaders);
# Process the query.
my $results = P3Utils::get_data($p3, genome_drug => $filterList, $selectList);
# Print the results.
for my $result (@$results) {
    P3Utils::print_cols($result);
}

sub print_usage {
    my $fieldList = P3Utils::list_object_fields('genome_drug');
    print join("\n", @$fieldList, "");
}
