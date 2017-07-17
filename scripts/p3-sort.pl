=head1 Small File Multi-Column Sort

    p3-sort.pl [options] col1 col2 ... colN

This is a sort script variant that sorts a single small file in memory with the ability to specify multiple columns.
It assumes the file has a header, and the columns are tab-delimited. If no columns are specified, it sorts by the
first column only.

=head2 Parameters

The positional parameters are the indices (1-based) or names of the key columns.

The standard input can be overwritten using the options in L<P3Utils/ih_options>.

The following additional options are suppported.

=over 4

=item count

If specified, the output will consist only of the key fields with a count column added.

=back

=cut

use strict;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('col1 col2 ... colN', P3Utils::ih_options(),
        ['count|K', 'count instead of sorting']
        );
# Verify the parameters.
my @sortCols;
if (! @ARGV) {
    # No sort key. Sort by first column.
    @sortCols = 1;
} else {
    @sortCols = @ARGV;
}
# Get the options.
my $count = $opt->count;
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers and compute the key columns.
my ($headers, $cols) = P3Utils::find_headers($ih, 'sort input' => @sortCols);
# Write out the headers.
if ($count) {
    my @sortHeaders = P3Utils::get_cols($headers, $cols);
    P3Utils::print_cols([@sortHeaders, 'count']);
} else {
    P3Utils::print_cols($headers);
}
# We will use this hash to facilitate the sort. It is keyed on the first column.
my %sorter;
# Loop through the input.
while (! eof $ih) {
    my $line = <$ih>;
    my @fields = P3Utils::get_fields($line);
    # Form the key.
    my @key = map { $fields[$_] } @$cols;
    my $key1 = shift @key;
    push @{$sorter{$key1}}, [\@key, $line];
}
# Now process each group.
for my $key1 (sort keys %sorter) {
    # Sort the items.
    my $subList = $sorter{$key1};
    my @sorted = sort { list_cmp($a->[0], $b->[0]) } @$subList;
    if (! $count) {
        # Print the sorted items.
        print map { $_->[1] } @sorted;
    } else {
        # Count the items for each key combination and print them.
        my $first = shift @sorted;
        my ($key, $tally) = (join("\t", $key1, @{$first->[0]}), 1);
        for my $item (@sorted) {
            my $key0 = join("\t", $key1, @{$item->[0]});
            if ($key0 ne $key) {
                print "$key\t$tally\n";
                ($key, $tally) = ($key0, 1);
            } else {
                $tally++;
            }
        }
        print "$key\t$tally\n";
    }
}

# Compare two lists.
sub list_cmp {
    my ($a, $b) = @_;
    my $n = scalar @$a;
    my $retVal = 0;
    for (my $i = 0; $i < $n && ! $retVal; $i++) {
        $retVal = $a->[$i] cmp $b->[$i];
    }
    return $retVal;
}
