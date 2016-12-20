
use strict;
use P3Utils;
use Data::Dumper;
use P3DataAPI;
use gjoseqlib;

my $opt = P3Utils::script_opts('[fids]',
			       P3Utils::ih_options(),
			       ["output|o=s", "name of the output file (if not the standard output)"],
			       P3Utils::col_options(),
			       ["dna" => "Return DNA for protein features (default is to return amino acid data for protein features)"],
			      );

my $api = P3DataAPI->new;

my $ih;
my ($outHeaders, $keyCol);

if (@ARGV)
{
    my $inp = join("\n", @ARGV) . "\n";
    open($ih, "<", \$inp);
    $keyCol = -1;
}
else
{
    $ih = P3Utils::ih($opt);
    # Process the headers and compute the key column index.
    ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
}

my %is_protein = (peg => 1, cds => 1);

my @batch;
my $batch_size = 100;
my $last_stype;

my $oh;

if ($opt->output)
{
    open($oh, ">", $opt->output) or die "Cannot write " . $opt->output . ": $!\n";
}
else
{
    $oh = \*STDOUT;
}

while (<$ih>)
{
    chomp;
    my @cols = split(/\t/);
    my $fid = $cols[$keyCol];
    my($ftype) = $fid =~ /fig\|\d+\.\d+\.(\S+)\.\d+$/;
    my $stype = "na_sequence";
    $stype = "aa_sequence" if $is_protein{lc($ftype)} && !$opt->dna;
    if (@batch >= $batch_size || ($last_stype && $last_stype ne $stype))
    {
	process_batch($last_stype, \@batch);
	@batch = ();
    }
    push(@batch, $fid);
    $last_stype = $stype;
}
if (@batch)
{
    process_batch($last_stype, \@batch);
}

sub process_batch
{
    my($stype, $list) = @_;

    my $q = "(" . join(",", @$list) . ")";

    my $cb = sub {
	my($data) = @_;
	for my $ent (@$data)
	{
	    print_alignment_as_fasta($oh, [$ent->{patric_id}, $ent->{product}, $ent->{$stype}]);
	}
    };

    $api->query_cb("genome_feature", $cb,
		   ["in", "patric_id", $q],
		   ["select", "patric_id,$stype,product"]);
    
}
    
