use strict;
use Data::Dumper;

my %counts;

while (defined($_ = <STDIN>))
{
    if (substr($_,length($_)-1,1) eq "\n")
    {
	chomp;
	my @fams = split(/,/,$_);
	my($i,$j);
	for ($i=0; ($i < $#fams); $i++)
	{
	    my $f1 = $fams[$i];
            for ($j=$i+1; ($j < @fams); $j++)
	    {
		my $f2 = $fams[$j];
                my $k = join(",",(sort ($f1,$f2)));
		$counts{$k}++;
	    }
	}
    }
}

foreach my $k (sort { $counts{$b} <=> $counts{$a} } keys(%counts))
{
    print $counts{$k},"\t",$k,"\n";
}
