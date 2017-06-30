=head1 Return All Genomes in PATRIC

    p3-all-genomes [options]

This script returns the IDs of all the genomes in the PATRIC database. It supports standard filtering
parameters and the specification of additional columns if desired.

=head2 Parameters

There are no positional parameters.

The command-line options are those given in L<P3Utils/data_options> plus the following.

=over 4

=item fields

List the names of the available fields.

=item public

Only include public genomes. If this option is NOT specified and you are logged in (via L<p3-login.pl>), your own private
genomes will also be included in the output.

=item private

Only include private genomes. If this option is specified and you are not logged in, there will be no output. It is mutually
exclusive with public.

=back
You can peruse

     https://github.com/PATRIC3/patric_solr/blob/master/genome/conf/schema.xml

to gain access to all of the supported fields.  There are quite a

few, so do not panic.  You can use something like

    p3-all-genomes -a genome_name -a genome_length -a contigs -a genome_status

to get some commonly sought fields.

=cut

use strict;
use P3DataAPI;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::data_options(),
        ['fields|f', 'show available fields'],
        ['public', 'only include public genomes'],
        ['private', 'only include private genomes']);
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
if ($opt->fields) {
    my $fieldList = P3Utils::list_object_fields('genome');
    print join("\n", @$fieldList, "");
} else {
    # Compute the output columns. Note we configure this as an ID-centric method.
    my ($selectList, $newHeaders) = P3Utils::select_clause(genome => $opt, 1);
    # Compute the filter.
    my $filterList = P3Utils::form_filter($opt);
    # Add a safety check to remove null genomes.
    push @$filterList, ['ne', 'genome_id', 0];
    # Check for public-only and private-only.
    if ($opt->public) {
        push @$filterList, ['eq', 'public', 1];
    } elsif ($opt->private) {
        push @$filterList, ['eq', 'public', 0];
    }
    # Write the headers.
    P3Utils::print_cols($newHeaders);
    # Process the query.
    my $results = P3Utils::get_data($p3, genome => $filterList, $selectList);
    # Print the results.
    for my $result (@$results) {
        P3Utils::print_cols($result);
    }
}
