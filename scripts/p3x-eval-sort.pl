=head1 Sort Evaluation Results by Quality

    p3x-eval-sort.pl [options] <inFile >sortedFile

This script sorts the output from L<p3x-eval-genomes.pl> to put the best genomes at the top. All good genomes sort before the bad ones, and
in each section they are sorted by the qscore.

=head2 Parameters

There are no positional parameters. The standard input is sorted into the standard output.

The standard input can be overridden using the options in L<P3Utils/ih_options>.

The following additional options are supported.

=over 4

=item stats

If specified, statistics about the genomes will be written to the standard error output.

=item score

Include a column for the score in the output.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use GEO;
use Stats;

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::ih_options(),
        ['stats', 'write statistics to the standard error output'],
        ['score', 'include score column in output']
        );
# Open the input file.
my $ih = P3Utils::ih($opt);
my $stats = Stats->new();
# Get the options.
my $scoreCol = $opt->score;
# Read the incoming headers.
my ($outHeaders, $cols) = P3Utils::find_headers($ih, evalOutput => 'Good Seed', 'Coarse Consistency', 'Fine Consistency', 'Completeness',
        'Contamination', 'Contigs', 'Pct Hypothetical');
push @$outHeaders, 'Score' if $scoreCol;
push @$outHeaders, 'Good Genome';
# The input rows will be kept in here. The hash is two-level, {goodness}{qscore};
my %rows = (0 => {}, 1 => {});
# Loop through the input.
while (! eof $ih) {
    my $line = <$ih>;
    $stats->Add(total => 1);
    my @fields = P3Utils::get_fields($line);
    # Pull out the key columns.
    my ($goodSeed, $coarse, $fine, $complete, $contam, $contigs, $hypoPct) = P3Utils::get_cols(\@fields, $cols);
    my $goodness = 1;
    my @qualities = ([$goodSeed, 'goodPheS', 'badPheS'], [GEO::consistX($fine), 'consistent', 'inconsistent'], [GEO::completeX($complete), 'complete', 'incomplete'],
            [GEO::contamX($contam), 'clean', 'contaminated'], [GEO::hypoX($hypoPct), 'understood', 'suspicious']);
    for my $quality (@qualities) {
        my ($flag, $good, $bad) = @$quality;
        if ($flag) {
            $stats->Add($good => 1);
        } else {
            $stats->Add($bad => 1);
            $goodness = 0;
        }
    }
    if ($goodness) {
        $stats->Add(good => 1);
    } else {
        $stats->Add(bad => 1);
    }
    my $qScore = GEO::qscoreX($coarse, $fine, $complete, $contam, $hypoPct, $contigs);
    push @fields, $qScore if $scoreCol;
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
if ($opt->stats) {
    print STDERR $stats->Show();
}