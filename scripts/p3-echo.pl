=head1 Write Data to Standard Output

    p3-echo [options] value1 value2 ... valueN

This script creates a tab-delimited output file containing the values on the command line. If a single header (C<--title> option)
is specified, then the output file is single-column. Otherwise, there is one column per header. So, for example


    p3-echo --title=genome_id 83333.1 100226.1

produces

    genome_id
    83333.1
    100226.1

However, the command

    p3-echo --title=genome_id --title=name 83333.1 "Escherichia coli" 100226.1 "Streptomyces coelicolor"

produces

    genome_id   name
    83333.1     Escherichia coli
    100226.1    Streptomyces coelicolor


=head2 Parameters

The positional parameters are the values to be output.

The command-line options are as follows.

=over 4

=item title

The value to use for the header line. If more than one value is specified, then the output file is multi-column. This
option is required.

=back

=cut

use strict;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('value1 value2 ... valueN', 
        ['title|header|hdr|t=s@', 'header value(s) to use in first output record', { required => 1 }]);
# Get the titles.
my $titles = $opt->title;
# Compute the column count.
my $cols = scalar @$titles;
my @values = @ARGV;
P3Utils::print_cols($titles);
# We will accumulate the current line in here.
my @line;
for my $value (@values) {
    push @line, $value;
    if (scalar(@line) >= $cols) {
        P3Utils::print_cols(\@line);
        @line = ();
    }
}
if (scalar @line) {
    # Here there is leftover data. Pad the line.
    while (scalar(@line) < $cols) {
        push @line, '';
    }
    P3Utils::print_cols(\@line);
}