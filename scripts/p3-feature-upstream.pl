=head1 Find Upstream DNA Regions

    p3-feature-upstream.pl [options] parms

This script takes as input a file of feature IDs. For each feature, it appends the upstream region on the input record.
Use the C<--downstream>) option to get the downstream regions instead.

=head2 Parameters

There are no positional parameters.

The standard input can be overriddn using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/col_options> plus the following.

=over 4

=item downstream

Display downstream instead of upstream regions.

=item length

Specifies the length to display upstream. The default is C<100>.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use SeedUtils;

# These are the instructions for finding the desired DNA. + means go to the left, - means go to the right.
use constant RULES => { downstream => { '+' => '+', '-' => '-' },
                        upstream => { '+' => '-', '-' => '+'} };

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::data_options(), P3Utils::col_options(), P3Utils::ih_options(),
        ['downstream|down|d', 'display downstream rather than upstream'],
        ['length|l=i', 'length to display', { default => 100 }]
        );
# Get the options.
my $type = ($opt->downstream ? 'downstream' : 'upstream');
my $len = $opt->length;
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
if (! $opt->nohead) {
    # Form the full header set and write it out.
    push @$outHeaders, $type;
    P3Utils::print_cols($outHeaders);
}
# We will stash contigs in here for re-use.
my %contigs;
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    # Get the location information for each feature.
    my $fidClause = '(' . join(',', map { $_->[0] } @$couplets) . ')';
    my @locData =  $p3->query(genome_feature => [qw(select patric_id sequence_id start end strand)], ['in', 'patric_id', $fidClause]);
    # Compute the sequences that we don't know yet.
    my @newSeqs = grep { ! $contigs{$_} } map { $_->{sequence_id} } @locData;
    if (@newSeqs) {
        my $seqClause = '(' . join(',', @newSeqs) . ')';
        my @seqData = $p3->query(genome_sequence => [qw(select sequence_id sequence)], ['in', 'sequence_id', $seqClause]);
        for my $seqDatum (@seqData) {
            $contigs{$seqDatum->{sequence_id}} = $seqDatum->{sequence};
        }
    }
    # Convert the location data into a hash.
    my %locs = map { $_->{patric_id} => $_ } @locData;
    undef @locData;
    # Now we need to find the upstream DNA for each feature.
    for my $couplet (@$couplets) {
        my ($fid, $line) = @$couplet;
        my $locDatum = $locs{$fid};
        my $strand = $locDatum->{strand};
        my $rule = RULES->{$type}{$strand};
        # Get the length of the sequence.
        my $seqLen = length($contigs{$locDatum->{sequence_id}});
        # The rule now tells us where to find the DNA.
        my ($x0, $n);
        if ($rule eq '-') {
            my $end = $locDatum->{start} - 1;
            $x0 = ($end < $len ? 0 : $end - $len);
            $n = $end - $x0;
        } else {
            $x0 = $locDatum->{end};
            my $end = $x0 + $len;
            $n = ($end > $seqLen ? $seqLen - $x0 : $len);
        }
        my $dna = substr($contigs{$locDatum->{sequence_id}}, $x0, $n);
        if ($strand eq '-') {
            $dna = SeedUtils::rev_comp($dna);
        }
        push @$line, $dna;
        P3Utils::print_cols($line, opt => $opt);
    }
}
