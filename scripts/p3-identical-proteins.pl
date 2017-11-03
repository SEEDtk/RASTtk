### OBSOLETE ### Use p3-get-features-by-sequence

=head1  Retrieve the proteins in PATRIC identical to the one provided.

    p3-identical-proteins [options] < target-protein-sequence

    Retrieve the proteins in PATRIC identical to the one provided.
=cut

#
# Retrieve the proteins in PATRIC identical to the one provided.
#

use Data::Dumper;
use strict;
use P3DataAPI;
use Getopt::Long::Descriptive;
use Digest::MD5;
use gjoseqlib;

my($opt, $usage) = describe_options("%c %o [input-file]",
                                    ["input|i=s", "FASTA input file of target protein sequence"],
                                    ["output|o=s", "Output file"],
                                    ["help|h", "Show this help message"]);
print($usage->text), exit 0 if $opt->help;
die($usage->text) if @ARGV > 1;

if (@ARGV && $opt->input)
{
    die "Only supply an input file using --input or as a positional parameter\n";
}

my $in_fh;
my $in_file;
if (@ARGV)
{
    $in_file = shift;
}
elsif ($opt->input)
{
    $in_file = $opt->input;
}

if ($in_file)
{
    open($in_fh, "<", $in_file) or die "Cannot open input file $in_file: $!";
}
else
{
    $in_fh = \*STDIN;
}

my $out_fh;
if ($opt->output)
{
    open($out_fh, ">", $opt->output) or die "Cannot open output file " . $opt->output . ": $!";
}
else
{
    $out_fh = \*STDOUT;
}

#
# Read sequences and compute md5.
#
# We are only using the first protein in the sequence data.
#

my($id, $def, $seq) = read_next_fasta_seq($in_fh);
my $md5 = Digest::MD5::md5_hex($seq);

my $api = P3DataAPI->new();

my @res = $api->query("genome_feature",
                      ["select", "patric_id,aa_sequence_md5,genome_id"],
                      ["eq", "annotation", "PATRIC"],
                      ["eq", "aa_sequence_md5", $md5]);

print $out_fh join("genome.patric_id", "genome.genome_id"), "\n";
for my $ent (@res)
{
    my($id, $md5,$genome) = @$ent{'patric_id', 'aa_sequence_md5', 'genome_id'};

    print $out_fh join("\t", $id, $genome), "\n";
}
