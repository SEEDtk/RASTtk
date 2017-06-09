=head1  Retrieve the proteins in PATRIC similar to the one provided, based on  PATRIC families

    p3-similar-proteins-by-family [options] < fasta-file

    Retrieve the proteins in PATRIC similar to the one provided, based on PATRIC families

=cut
#
# Retrieve the proteins in PATRIC similar to the one provided, based on
# PATRIC families.
#

use Data::Dumper;
use strict;
use P3DataAPI;
use Getopt::Long::Descriptive;
use LWP::UserAgent;
use URI;
use Digest::MD5;
use gjoseqlib;

my $family_service_url = "http://spruce.mcs.anl.gov:6100";

my($opt, $usage) = describe_options("%c %o [input-file]",
                                    ["plfam", "Use PATRIC local families (default)"],
                                    ["pgfam", "Use PATRIC global families"],
                                    ["genus=s", "Limit results to this genus. Required for use with local families."],
                                    ["input|i=s", "FASTA input file of target protein sequence"],
                                    ["output|o=s", "Output file"],
                                    ["help|h", "Show this help message"]);
print($usage->text), exit 0 if $opt->help;
die($usage->text) if @ARGV > 1;

if (@ARGV && $opt->input)
{
    die "Only supply an input file using --input or as a positional parameter\n";
}

if ($opt->pgfam && $opt->plfam)
{
    die "Only one of --pgfam and--plfam may be specified\n";
}
my $fam_type = "PLFAM";
if ($opt->pgfam)
{
    $fam_type = "PGFAM";
}
if ($fam_type eq "PLFAM" && !$opt->genus)
{
    die "A genus must be specified with --genus to use local families\n";
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
# Read sequence and determine family membership
#

my($id, $def, $seq) = read_next_fasta_seq($in_fh);

my $ua = LWP::UserAgent->new;
my $uri = URI->new("$family_service_url/lookup");
$uri->query_form(find_best_match => 1,
                 $opt->genus ? (target_genus => $opt->genus) : ());

my $res = $ua->post($uri, Content => ">$id\n$seq\n");

if (!$res->is_success)
{
    die "Error looking up family membership: " . $res->status_line . "\n";
}

my $txt = $res->content;
my ($pgf, $pgf_score, $plf, $plf_score, $function, $score);
($id, $pgf, $pgf_score, $plf, $plf_score, $function, $score) = split(/\t/, $txt);

my $matching_family;
my $db_query;

if ($fam_type eq 'PLFAM')
{
    if ($plf)
    {
        $matching_family = $plf;
        $db_query = ["eq", "plfam_id", $matching_family];
    }
    else
    {
        warn "No matching family found\n";
        exit;
    }
}
else
{
    if ($pgf)
    {
        $matching_family = $pgf;
        $db_query = ["eq", "pgfam_id", $matching_family];
    }
    else
    {
        warn "No matching family found\n";
        exit;
    }
}

my $api = P3DataAPI->new();

my @res = $api->query("genome_feature",
                      ["select", "patric_id,genome_id,genome_name"],
                      ["eq", "annotation", "PATRIC"],
                      $db_query);

print $out_fh join("genome.patric_id", "genome.genome_id"), "\n";
for my $ent (@res)
{
    my($id, $genome_name, $genome) = @$ent{'patric_id', 'genome_name', 'genome_id'};

    my $g = $opt->genus;
    if (!$g || $genome_name =~ /^$g\s/)
    {
        print $out_fh join("\t", $id, $genome), "\n";
    }
}
