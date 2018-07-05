=head1 Description

    p3-eval-sort.pl [options] <inFile >sortedFile

This script sorts the output from L<p3-eval-genomes.pl> to put the best genomes at the top. All good genomes sort before the bad ones, and
in each section they are sorted by the qscore.

=head2 Parameters

There are no positional parameters. The standard input is sorted into the standard output.

The standard input can be overridden using the options in L<P3Utils/ih_options>.

=cut

use strict;
use P3DataAPI;
use P3Utils;
use GEO;


# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::ih_options(),
        );
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $cols) = P3Utils::find_headers($ih, evalOutput => 'Good Seed', 'Coarse Consistency', 'Fine Consistency', 'Completeness', 'Contamination');
push @$outHeaders, 'Good Genome';
# The input rows will be kept in here. The hash is two-level, {goodness}{qscore};
my %rows = (0 => {}, 1 => {});
# Loop through the input.
while (! eof $ih) {
    my $line = <$ih>;
    my @fields = P3Utils::get_fields($line);
    # Pull out the key columns.
    my ($goodSeed, $coarse, $fine, $complete, $contam) = P3Utils::get_cols(\@fields, $cols);
    my $goodness =  (($goodSeed && GEO::consistX($fine) && GEO::completeX($complete) && GEO::contamX($contam)) ? 1 : 0);
    my $qScore = GEO::qscoreX($coarse, $fine, $complete, $contam);
    push @{$rows{$goodness}{$qScore}}, join("\t", @fields, $goodness) . "\n";
}
# Write the output.
P3Utils::print_cols($outHeaders);
for my $goodness (1, 0) {
    my $rowsX = $rows{$goodness};
    my @scores = sort { $b <=> $a } keys %$rowsX;
    for my $score (@scores) {
        print join("", @{$rowsX->{$score}});
    }
}