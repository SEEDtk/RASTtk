=head1 Return Features From Families in PATRIC

    p3-get-family-features [options]

This script returns data for all the features in one or more protein families from the PATRIC database. It supports standard filtering
parameters and the specification of additional columns if desired. In addition, the results can be filtered by genomes
from a secondary input file. As currently coded, the command may fail if the number of genomes in the secondary file is
large.

=head2 Parameters

There are no positional parameters.

The standard input can be overwritten using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/data_options> and L<P3Utils/col_options> plus the following
options.

=over 4

=item gFile

Name of a tab-delimited file containing genome IDs. If specified, only features in these genomes will be returned.

=item gCol

Index (1-based) or header name of the column containing the genome IDs in the genome file. The default is
C<genome.genome_id>.

=item ftype

The type of family being used. The default is C<local>, indicating PATRIC local protein families. Other options are
C<figfam> or C<global>.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;

# This maps family types to the appropriate ID field in the feature record.
use constant FAMTYPE => {'local' => 'plfam_id', global => 'pgfam_id', figfam => 'figfam_id',
                         plfam => 'plfam_id', pgfam => 'pgfam_id', fig => 'figfam_id' };

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::data_options(), P3Utils::col_options(), P3Utils::ih_options(),
        ['gFile|gfile|g=s', 'name of a file containing genome IDs'],
        ['gCol|gcol=s', 'index (1-based) or name of the genome file column with the IDs', { default => 'genome.genome_id'}],
        ['ftype|fType=s', 'type of protein family (local, global, figfam', { default => 'local'}]);
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
# Compute the family ID column.
my $ftype = $opt->ftype;
my $famField = FAMTYPE->{$opt->ftype};
die "Invalid protein family type \"$ftype\"." if (! $famField);
# Check for a genome file.
if ($opt->gfile) {
    my $genomeFile = $opt->gfile;
    # Get the headers from the genome file.
    open(my $gh, "<$genomeFile") || die "Could not open genome file: $!";
    my ($gHeaders) = P3Utils::process_headers($gh);
    # Find the key column.
    my $gCol = P3Utils::find_column($opt->gcol, $gHeaders);
    # Read it in.
    my $genomeIDs = P3Utils::get_col($gh, $gCol);
    # Create the genome ID filter and add it to the existing filter data.
    my $gFilter = ['in', 'genome_id', '(' . join(',', @$genomeIDs) . ')'];
    push @$filterList, $gFilter;
}
# Form the full header set and write it out.
push @$outHeaders, @$newHeaders;
P3Utils::print_cols($outHeaders);
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    # Get the output rows for these input couplets.
    my $resultList = P3Utils::get_data($p3, feature => $filterList, $selectList, $famField => $couplets);
    # Print them.
    for my $result (@$resultList) {
        P3Utils::print_cols($result);
    }
}
