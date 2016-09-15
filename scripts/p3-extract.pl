=head1 Select Columns from an Input File

    p3-extract [options] col1 col2 ... colN

This script extracts the specified columns from a tab-delimited file.

=head2 Parameters

The positional parameters are the numbers or names of the columns to include in the output. The column numbers
are 1-based, and the column names are taken from the header record of the input file.

The standard input may be overridden by the command-line options given in L<P3Utils/ih_options>.

=cut

use strict;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('col1 col2 ... colN', P3Utils::ih_options());
# Get the column identifiers.
my @cols = @ARGV;
die "No columns specified." if (! @cols);
# Open the input file.
my $ih = P3Utils::ih($opt);
# Process the headers.
my ($inHeaders) = P3Utils::process_headers($ih);
# Compute the column indices.
my @idxes = map { P3Utils::find_column($_, $inHeaders) } @cols;
# Compute the output headers.
my @outHeaders = map { $inHeaders->[$_] } @idxes;
# Write out the headers.
P3Utils::print_cols(\@outHeaders);
# Loop through the input.
while (! eof $ih) {
    my @row =  P3Utils::get_cols($ih, \@idxes);
    P3Utils::print_cols(\@row);
}