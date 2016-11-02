use strict;
use Data::Dumper;

my %counts;
while (defined($_ = <STDIN>))
{
    if ($_ =~ /^(\S+)\t(\S+)/)
    {
	$counts{$2}++;
    }
}

foreach my $role (sort keys(%counts))
{
    print $role,"\t",$counts{$role},"\n";
}
