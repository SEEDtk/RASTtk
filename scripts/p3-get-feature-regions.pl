=head1 Display DNA Regions for Features

    p3-get-feature-regions.pl [options]

This script takes as input a list of feature IDs and displays the DNA region surrounding each feature.  The portion of each region
occupied by the feature itself and the feature's neighbors will be shown in upper case, the rest in lower case.  The output can be
displayed in FASTA format or the sequence can be appended to the input lines.

=head2 Parameters

There are no positional parameters

The standard input can be overridden using the options in L<P3Utils/ih_options>.

The input column can be specified using L<P3Utils/col_options>.  Additional command-line options are as follows.

=over 4

=item distance

The distance in base pairs to show around the specified feature.  The default is C<100>.

=item fasta

If specified, the regions will be output in FASTA format.

=item comment

If specified, a field to put in the FASTA comments.  If multiple fields are desired, the option should be specified multiple
times.  Specifying this option implies C<--fasta>.

=item mapped

If specified, then a second line below the sequence will be displayed in FASTA format, with asterisks under the positions occupied
by the target feature.  Specifying this option implies C<--fasta>.

=item consolidated

If a requested feature's region includes another requested feature, the region will be expanded to include it.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use P3Sequences;

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::col_options(), P3Utils::ih_options(),
        ['distance|dist|margin|d=i', 'distance to show around specified feature', { default => 100 }],
        ['fasta|F', 'output in FASTA format'],
        ['comment|c=s@', 'field to put in FASTA comment (implies FASTA)'],
        ['consolidated|K', 'extend regions to include features at the edges'],
        ['mapped', 'if specified, a second line will be printed below the main one showing where the original feature occurs (implies FASTA)']
        );
# Extract the key options.
my $distance = $opt->distance;
my $fasta = $opt->fasta;
my $mapped = $opt->mapped;
if ($mapped || $opt->comment) {
    $fasta = 1;
}
my $consolidated = $opt->consolidated;
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Form the full header set and write it out.
if (! $opt->nohead && ! $fasta) {
    push @$outHeaders, 'region';
    P3Utils::print_cols($outHeaders);
}
# In FASTA mode, check for comment requirements.
my $commentSpec = [];
if ($fasta) {
    my $commentFields = $opt->comment;
    $commentSpec = P3Utils::find_headers($outHeaders, inputFile => @$commentFields);
}
# Create the sequence manager.
my $p3seqs = P3Sequences->new($p3);
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    # For each feature, get its region.
    my @features = map { $_->[0] } @$couplets;
    my %map;
    my $regionHash = $p3seqs->FeatureRegions(\@features, distance => $distance, consolidated => $consolidated,
        metrics => \%map);
    # Loop through the regions, producing output.
    for my $couplet (@$couplets) {
        my ($fid, $tuple) = @$couplet;
        my $region = $regionHash->{$fid};
        if ($region) {
            if ($fasta) {
                my $comment = join(' ', P3Utils::get_cols($tuple, $commentSpec));
                print ">$fid $comment\n$region\n";
                if ($mapped) {
                    my ($offset, $len) = @{$map{$fid}};
                    my $mapString = (' ' x $offset) . ('*' x $len);
                    print "$mapString\n";
                }
            } else {
                P3Utils::print_cols([@$tuple, $region]);
            }
        }
    }
}