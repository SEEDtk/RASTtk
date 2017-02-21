use strict;
use P3DataAPI;
use Data::Dumper;

use Getopt::Long::Descriptive;

my($opt, $usage) = describe_options("%c %o < genome_ids > genome_data",
				    ["help|h", "Show this help message"]);

print($usage->text), exit  if $opt->help;
print($usage->text), exit 1 if (@ARGV != 0);

     
my $d = P3DataAPI->new();

my @ids;
while (<STDIN>)
{
    chomp;
    my @cols = split(/\t/);
    my $id = $cols[-1];
    push(@ids, [$id, $_]);
}

my $chunk_size = 10;
while (@ids)
{
    my @set = splice(@ids, 0, $chunk_size);
    my %set;
    for my $i (@set)
    {
	push(@{$set{$i->[0]}}, $i->[1]);
    }

    my @res = $d->query("genome_feature",
			["eq", "feature_type", "source"],
			["select", "genome_id", "accession"],
			["eq", "annotation", "PATRIC"],
			["in", "genome_id", "(" . join(",", keys %set) . ")"],
		    );

    my %res;
    for my $ent (@res)
    {
	push(@{$res{$ent->{genome_id}}}, $ent->{accession});
    }
    for my $i (@set)
    {
	my($id, $line) = @$i;
	my $l = $res{$id};
	if (ref($l) && @$l > 0)
	{
	    for my $r (@$l)
	    {
		print "$line\t$r\n";
	    }
	}
	else
	{
	    print "$line\t\n";
	}
    }
}
