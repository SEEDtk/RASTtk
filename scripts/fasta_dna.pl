=head1 Extract DNA from a FASTA file

    fasta_dna.pl [options] fastaFile

This script reads one or more locations from the standard input and outputs the corresponding DNA from the input FASTA file.

=head2 Parameters

The positional parameter should be the name of the FASTA file containing the DNA.

The standard input can be overridden using the options in L<ScriptUtils/ih_options>. The standard input should contain location
strings in the column identified by the C<--col> parameter and the region name in the column identified by the
C<--label> parameter.

Location strings are of the form I<contigID>C<_>I<start>C<+>I<len> for the forward strand and I<contigID>C<_>I<start>C<->I<len> for
the backward strand.

Additional command-line options are as follows.

=over 4

=item col

Index (1-based) of the column containing the locations. The default is the last column (C<0>).

=item fasta

Output should be in FASTA format, with the region name as the ID.

=item label

Index (1-based) of the column containing the region names. The default is the first column (C<1>).

=back

=cut

use strict;
use ScriptUtils;
use Contigs;


# Get the command-line options.
my $opt = ScriptUtils::Opts('fastaFile', ScriptUtils::ih_options(),
        ['label=i', 'index (1-based) of the label column', { default => 1 }],
        ['col=i', 'index (1-based) of the location column', { default => 0 }],
        ['fasta', 'output should be in FASTA format'],
        );
# Get the FASTA file.
my ($fastaFile) = @ARGV;
if (! $fastaFile) {
    die "No FASTA file specified.";
} elsif (! -s $fastaFile) {
    die "Invalid, missing, or empty FASTA file $fastaFile.";
}
# Get the FASTA file's contigs.
my $contigs = Contigs->new($fastaFile);
# Open the input file.
my $ih = ScriptUtils::IH($opt->input);
# Check the options.
my $fasta = $opt->fasta;
# Determine the label and key columns.
my $labelCol = $opt->label - 1;
my $keyCol = $opt->col;
# Loop through the input.
while (! eof $ih) {
    my @couplets = ScriptUtils::get_couplets($ih, $keyCol, 100);
    for my $couplet (@couplets) {
        my ($loc, $data) = @$couplet;
        # Get the DNA.
        my $dna = $contigs->dna($loc);
        # Write it out according to the format.
        if (! $fasta) {
            push @$data, $dna;
            print join("\t", @$data) . "\n";
        } else {
            my $label = $data->[$labelCol];
            print ">$label\n$dna\n";
        }
    }
}