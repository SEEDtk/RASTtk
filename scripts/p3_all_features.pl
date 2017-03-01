use strict;
use P3DataAPI;
use Data::Dumper;

use Getopt::Long::Descriptive;

my($opt, $usage) = describe_options("%c %o [genome-id] feature-type [ < genome-id-file]",
				    ["help|h", "Show this help message"]);

print($usage->text), exit  if $opt->help;
print($usage->text), exit 1 if (@ARGV != 1 && @ARGV != 2);

my @ids;
my $type;

if (@ARGV == 1)
{
    $type = shift;
    while (<STDIN>)
    {
	chomp;
	my @cols = split(/\t/);
	my $id = $cols[-1];
	push(@ids, $id);
    }
}
else
{
    my $id = shift;
    push(@ids, $id);
    $type = shift;
}
				     
my $d = P3DataAPI->new();

$type = 'CDS' if $type eq 'peg';

my @type = ($type);
if ($type eq 'rna')
{
    push(@type, 'trna', 'rrna');
}

my $chunk_size = 10;
while (@ids)
{
    my @set = splice(@ids, 0, $chunk_size);
    my @res = $d->query("genome_feature",
			["in", "feature_type", "(" . join(",", @type) . ")"],
			["select", "patric_id"],
			["eq", "annotation", "PATRIC"],
			["sort", "+accession", "+start"],
			["in", "genome_id", "(" . join(",", @set) . ")"],
		    );

    for my $ent (@res)
    {
	print join("\t", @$ent{'patric_id'}), "\n";
    }
}
