=head1 Statistically Analyze Numerical Values

    p3-stats.pl [options] statCol

This script divides the input into groups by the key column and analyzes the values found in a second column (specified by the
parameter). It outputs the mean, standard deviation, minimum, maximum, and count.

=head2 Parameters

The positional parameter is the name of the column to be analyzed. It must contain only numbers.

The standard input can be overriddn using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/col_options> (to specify the key column).

=cut

use strict;
use P3DataAPI;
use P3Utils;


# Get the command-line options.
my $opt = P3Utils::script_opts('statCol', P3Utils::col_options(), P3Utils::ih_options(),
        );
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($inHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Compute the location of the target column.
my ($statCol) = @ARGV;
if (! defined $statCol) {
    die "No target column specified."
}
my $targetCol = P3Utils::find_column($statCol, $inHeaders);
# Form the full header set and write it out.
my $colName = ($opt->nohead ? 'key' : $inHeaders->[$keyCol]);
my @outHeaders = ($colName, qw(count average min max stdev));
P3Utils::print_cols(\@outHeaders);
# This is our tally hash. For each key value, it will contain [count, sum, min, max, square-sum].
my %tally;
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    for my $couplet (@$couplets) {
        my ($key, $line) = @$couplet;
        my $value = $line->[$targetCol];
        if (! exists $tally{$key}) {
            $tally{$key} = [1, $value, $value, $value, $value*$value];
        } else {
            my $tallyL = $tally{$key};
            $tallyL->[0]++;
            $tallyL->[1] += $value;
            if ($value < $tallyL->[2]) {
                $tallyL->[2] = $value;
            }
            if ($value > $tallyL->[3]) {
                $tallyL->[3] = $value;
            }
            $tallyL->[4] += $value * $value;
        }
    }
}
# Now loop through the tally hash, producing output.
for my $key (sort keys %tally) {
    my ($count, $sum, $min, $max, $sqrs) = @{$tally{$key}};
    my $avg = $sum / $count;
    my $stdev = sqrt($sqrs/$count - $avg*$avg);
    P3Utils::print_cols([$key, $count, $avg, $min, $max, $stdev]);
}
