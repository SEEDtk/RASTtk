=head1 Return All Drugs in PATRIC

    p3-all-drugs [options]

This script returns the IDs of all the antibiotic drugs in the PATRIC database. It supports standard filtering
parameters and the specification of additional columns if desired.

=head2 Parameters

There are no positional parameters.

The command-line options are those given in L<P3Utils/data_options>.
You can peruse

     https://github.com/PATRIC3/patric_solr/blob/master/antibiotics/conf/schema.xml

to gain access to all of the supported fields.  There are quite a
few, so do not panic.  You can use something like

    p3-all-drugs -a antibiotic_name -a description -a canonical_smiles

to get some commonly sought fields.

=cut

use strict;
use P3DataAPI;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::data_options());
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Compute the output columns. Note we configure this as an ID-centric method.
my ($selectList, $newHeaders) = P3Utils::select_clause(drug => $opt, 1);
# Compute the filter.
my $filterList = P3Utils::form_filter($opt);
# Add a safety check to eliminate null drugs.
push @$filterList, ['ne', 'pubchem_cid', 0];
# Write the headers.
P3Utils::print_cols($newHeaders);
# Process the query.
my $results = P3Utils::get_data($p3, drug => $filterList, $selectList);
# Print the results.
for my $result (@$results) {
    P3Utils::print_cols($result);
}
