=head1  Retrieve the proteins in PATRIC similar to the one provided, based on  a BLAST search to the target protein.

    p3-similar-proteins-by-blast [options] < fasta-file

    Retrieve the proteins in PATRIC similar to the one provided, based on  a BLAST search to the target protein.

=cut

use Data::Dumper;
use strict;
use P3DataAPI;
use Getopt::Long::Descriptive;
use LWP::UserAgent;
use JSON::XS;
use URI;
use Digest::MD5;
use gjoseqlib;

my $blast_service_url = "http://p3.theseed.org/services/homology_service";

my($opt, $usage) = describe_options("%c %o [input-file]",
                                    ["taxon=s", "BLAST only genomes under this taxonomy ID"],
                                    ["evalue-cutoff|e=s", "BLAST e-value cutoff", { default => 1e-5 }],
                                    ["min-coverage|m=s", "Minimal coverage", { default => 0 }],
                                    ["max-hits|m=s", "Maximum number of matching sequences to return", { default => 0 }],
                                    ["input|i=s", "FASTA input file of target protein sequence"],
                                    ["output|o=s", "Output file"],
                                    ["client-timeout=s", "Timeout to BLAST service", { default => 3600 }],
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
# Read sequence
#

my($id, $def, $seq) = read_next_fasta_seq($in_fh);

#
# Invoke BLAST service. (Hand-craft a JSONRPC call)
#
my $call;

if ($opt->taxon)
{
    $call = {
        id => 1,
        params => [">$id\n$seq\n", "blastp", $opt->taxon, "features",
                   $opt->evalue_cutoff + 0.0, $opt->max_hits + 0, $opt->min_coverage + 0.0],
        method => "HomologyService.blast_fasta_to_taxon",
    };
}
else
{
    $call = {
        id => 1,
        params => [">$id\n$seq\n", "blastp", "ref.faa",
                   $opt->evalue_cutoff + 0.0, $opt->max_hits + 0, $opt->min_coverage + 0.0],
        method => "HomologyService.blast_fasta_to_database",
    };
}


my $enc = encode_json($call);
print STDERR "$enc\n";
my $ua = LWP::UserAgent->new;
$ua->timeout($opt->client_timeout);

my $res = $ua->post($blast_service_url, Content => $enc);

if (!$res->is_success)
{
    die "Error invoking BLAST: " . $res->status_line . "\n";
}

my $txt = $res->content;

my $json_resp = decode_json($txt);
if ($json_resp->{error})
{
    die "Error invoking BLAST: $json_resp->{error}\n$txt\n";
}
my($reports, $metadata) = @{$json_resp->{result}};

for my $report (@$reports)
{
    my $search = $report->{report}->{results}->{search};
    my $qid = $search->{query_id};

    for my $hit (@{$search->{hits}})
    {
        my $id = $hit->{description}->[0]->{id};
        my $meta = $metadata->{$id};
        next unless $id =~ /^fig\|/;
        print $out_fh join("\t", $id, $meta->{genome_id}), "\n";
    }
}
