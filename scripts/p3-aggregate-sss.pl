use Data::Dumper;
use strict;
use warnings;
use P3Utils;
use SeedUtils;


### OBSOLETE ###

=head1 Aggregate Clusters Produced from Distinct Samples

     p3-aggregate-sss -d DataDirectory > aggregated.clusters

This tool takes as input an Output Directory created by p3-related-by-clusters.
That tool produces a group of sample sets of genomes, along with
the chromosomal clusters that can be computed from them.
This tool takes the output for all of the samples and aggregates it.
It aggregates tables from different samples

=head2 Parameters

There are no positional parameters.

Standard input is not used.

The additional command-line options are as follows.

=over 4

=item d DataDirectory

=back

=cut

my ($opt, $helper) = P3Utils::script_opts('',["d=s","a directory created by p3-related-by-clusters", { required => 1 }]);
my $outD = $opt->d;

my %pairs;

open(RF,"cat $outD/related.signature.families |") || die "could not open related.signature.families";
while (defined($_ = <RF>))
{
    if ($_ =~ /^(\S+\t\S+)\t(\d+)$/)
    {
        $pairs{$1} += $2;
    }
}
close(RF);
open(PAIRS,">$outD/aggregated.related.signature.families") || die "BAD";

foreach my $pair (sort { $pairs{$b} <=> $pairs{$a} } keys(%pairs))
{
    print PAIRS join("\t",($pair,$pairs{$pair})),"\n";
}
close(PAIRS);

my %sss;
open(SSS,">$outD/aggregated.sss") || die "BAD";

open(CLUST,"cat $outD/CS/* |") || die "could not open clusters in $outD/CS";
$/ = "\n//\n";
my $cluster;
while (defined($cluster = <CLUST>))
{
    my $best_pair = &best($cluster,\%pairs);
    if ($best_pair)
    {
        $sss{$best_pair}->{$cluster} = 1;
    }
}
close(CLUST);

foreach my $pair (sort { $pairs{$b} <=> $pairs{$a} } keys(%sss))
{
    print SSS join("\t",($pair,$pairs{$pair})),"\n";
    foreach my $cluster (sort { length($b) <=> length($a) } keys(%{$sss{$pair}}))
    {
        print SSS $cluster;
    }
    print SSS "////\n";
}
close(SSS);

sub best {
    my($cluster,$pairs) = @_;

    my %fams = map { ($_ =~ /fig\|\S+\t(\S+)/) ? ($1 => 1) : () } split(/\n/,$cluster);
    my @fams = sort keys(%fams);
    my $sofar = 0;
    my $best_pair;
    for (my $i=0; ($i < $#fams); $i++)
    {
        for (my $j = $i+1; ($j < @fams); $j++)
        {
            if ($fams[$i] ne $fams[$j])
            {
                my $p = join("\t",($fams[$i],$fams[$j]));
                if (($_ = $pairs->{$p}) && ($_ > $sofar)) { $sofar = $_; $best_pair = $p  }
                $p = join("\t",($fams[$i],$fams[$j]));
                if (($_ = $pairs->{$p}) && ($_ > $sofar)) { $sofar = $_; $best_pair = $p  }
            }
        }
    }
    return $best_pair;
}
