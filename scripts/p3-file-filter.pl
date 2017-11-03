=head1 Filter a File Against Contents of a Second File

    p3-file-filter.pl [options] filterFile filterCol

Filter the standard input using the contents of a file. The output will contain only those rows in the input file whose key value
matches a value from the specified column of the specified filter file. To have the output contain only those rows in the input
file that do NOT match, use the C<--reverse> option. This is similar to L<p3-merge.pl>, except that script operates on whole
lines instead of a single key field.

=head2 Parameters

The positional parameters are the name of the filter file and the index (1-based) or name of the key column in the filter file.
If the latter parameter is absent, the value of the C<--col> parameter will be used (same name or index as the input file).

The standard input can be overriddn using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/col_options> plus the following.

=over 4

=item reverse

Instead of only keeping input records that match a filter record, only keep records that do NOT match.

=back

=head3 Example

This command is shown in the tutorial p3-common-tasks.html;

p3-file-filter --reverse --col=feature.role aRoles.tbl feature.role &lt;cRoles.tbl

feature.role    count
2,3-dihydroxybenzoate-AMP ligase (EC 2.7.7.58) of siderophore biosynthesis  33
2-octaprenyl-3-methyl-6-methoxy-1,4-benzoquinol hydroxylase (EC 1.14.13.-)  1
2-pyrone-4,6-dicarboxylic acid hydrolase (EC 3.1.1.57)  14
23S ribosomal RNA rRNA prediction is too short  1
...

=cut

use strict;
use P3Utils;


# Get the command-line options.
my $opt = P3Utils::script_opts('filterFile filterCol', P3Utils::col_options(), P3Utils::ih_options(),
        ['reverse|invert|v', 'only keep non-matching records']
        );
# Get the filter parameters.
my ($filterFile, $filterCol) = @ARGV;
if (! defined $filterCol) {
    $filterCol = $opt->col;
}
if (! $filterFile) {
    die "No filter file specified.";
} elsif (! -f $filterFile) {
    die "Filter file $filterFile invalid or not found.";
}
# Open the filter file.
open(my $fh, '<', $filterFile) || die "Could not open filter file: $!";
# Read its headers. Note we bypass key-column processing.
my ($filterHeaders) = P3Utils::process_headers($fh, $opt, 1);
# Find the key column.
my $fCol = P3Utils::find_column($filterCol, $filterHeaders);
# Create a hash of the acceptable field values.
my $filterList = P3Utils::get_col($fh, $fCol);
my %filter = map { $_ => 1 } @$filterList;
# Release the memory for the filter file stuff.
close $fh;
undef $filterList;
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Write the output headers.
if (! $opt->nohead) {
    P3Utils::print_cols($outHeaders);
}
# Determine the mode.
my $reverse = $opt->reverse;
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    for my $couplet (@$couplets) {
        my ($key, $line) = @$couplet;
        if ($filter{$key} xor $reverse) {
            P3Utils::print_cols($line);
        }
    }
}
