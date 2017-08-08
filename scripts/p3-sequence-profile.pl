=head1 Profile Sequences by Letter Content

    p3-sequence-profile.pl [options]

This script analyzes DNA or protein sequences in the key column of the incoming file and outputs the number of times
each letter occurs. The output file will contain the letter in the first column and the count in the second, and
will be sorted from most frequent to least. This can lead to very small output files.

=head2 Parameters

There are no positional parameters.

The standard input can be overriddn using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/col_options> (to select the column containing the sequences).

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;


# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::col_options(), P3Utils::ih_options(),
        );
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Loop through the input.
my %counts;
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    for my $couplet (@$couplets) {
        for my $char (split '', uc $couplet->[0]) {
            if ($char =~ /[A-Z.\-\?]/) {
                $counts{$char}++;
            }
        }
    }
}
# Output the counts.
my @chars = sort { $counts{$b} <=> $counts{$a} } keys %counts;
P3Utils::print_cols(['letter', 'count']);
for my $char (@chars) {
    P3Utils::print_cols([$char, $counts{$char}]);
}