=head1 Return Features From Genomes in PATRIC

    p3-get-genome-features [options]

This script returns data for all the features in one or more genomes from the PATRIC database. It supports standard filtering
parameters and the specification of additional columns if desired.

=head2 Parameters

There are no positional parameters.

The standard input can be overwritten using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/data_options> and L<P3Utils/col_options>.

The command-line options are those given in L<P3Utils/data_options>.
You can peruse

    https://github.com/PATRIC3/patric_solr/blob/master/genome_feature/conf/schema.xml
     to gain access to all of the supported fields.  There are quite a
     few, so do not panic.  You can use something like

         p3-echo -t genome.genome_id 282669.3 | p3-get-genome-features -e feature_type,CDS -a annotation -a start -a end -a product

         to get some commonly sought fields.



=cut

use strict;
use P3DataAPI;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::data_options(), P3Utils::col_options(), P3Utils::ih_options());
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
    my $resultList = P3Utils::get_data($p3, feature => $filterList, $selectList, genome_id => $couplets);
    # Print them.
    for my $result (@$resultList) {
        P3Utils::print_cols($result);
    }
}
