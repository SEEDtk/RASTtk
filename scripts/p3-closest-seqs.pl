=head1 Find Closest Sequences Using Kmers

    p3-closest-seqs.pl [options] kmerDB

This script takes as input a file of DNA or protein sequences and compares them to a kmer database. The closest
groups within a certain threshold are listed. So, for example, given a kmer database of protein sequences for features
and an incoming file of new proteins, each new protein would be paired with the features in the kmer database with
which it is closest. Given a kmer database of DNA sequences for genomes and an incoming file of contigs, each incoming
contig would be paired with the genomes with which it is closest. Use L<p3-build-kmer-db.pl> to build the kmer database.

=head2 Parameters

##TODO positional parameters

The standard input can be overridden using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/data_options> and L<P3Utils/col_options> plus the following
options.

=over 4

##TODO

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;


# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::col_options(), P3Utils::ih_options(),
        ##TODO oprions
        );
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Compute the output columns.
my ($selectList, $newHeaders) = P3Utils::select_clause(dataType => $opt);
# Compute the filter.
my $filterList = P3Utils::form_filter($opt);
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
    die "Not implemented: coming soon."; ##TODO process
}