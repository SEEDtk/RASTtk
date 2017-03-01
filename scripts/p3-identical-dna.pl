#
# Retrieve the DNA features in PATRIC identical to the one provided.
#

use Data::Dumper;
use strict;
use SeedUtils;
use P3DataAPI;
use Getopt::Long::Descriptive;
use Digest::MD5;
use gjoseqlib;

my($opt, $usage) = describe_options("%c %o [input-file]",
				    ["input|i=s", "FASTA input file of target DNA sequence"],
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
# We are only using the first sequence in the sequence data.
#
# We translate to protein to find the set of features identical at the
# protein level and then filter those with the identical dna sequence.
#

my($id, $def, $seq) = read_next_fasta_seq($in_fh);

my $aa_4 = SeedUtils::translate($seq, SeedUtils::genetic_code(4), 1);
my $aa_11 = SeedUtils::translate($seq, SeedUtils::genetic_code(11), 1);

$aa_4 =~ s/\*$//;
$aa_11 =~ s/\*$//;

my $md5_4 = Digest::MD5::md5_hex($aa_4);
my $md5_11 = Digest::MD5::md5_hex($aa_11);

my $q;
if ($md5_4 eq $md5_11)
{
    $q = ["eq", "aa_sequence_md5", $md5_4];
}
else
{
    $q = ["in", "aa_sequence_md5", "($md5_4,$md5_11)"];
}

my $api = P3DataAPI->new();

my @res = $api->query("genome_feature",
		      ["select", "patric_id,genome_id,na_sequence"],
		      ["eq", "annotation", "PATRIC"],
		      $q);

print join("\t", "genome.patric_id", "genome.genome_id"), "\n";
for my $ent (@res)
{
    my($id, $dna, $genome) = @$ent{'patric_id', 'na_sequence', 'genome_id'};

    if ($dna eq $seq)
    {
	print $out_fh join("\t", $id, $genome), "\n";
    }
}
