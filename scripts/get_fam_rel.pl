use strict;
use Data::Dumper;
#
# Collapse a cluster to a single line of family IDs.
$/ = "\n//\n";
my $x;
while (defined($x = <STDIN>))
{
    chomp $x;
    my @fams = sort map { ($_ =~ /(\S+)\tfig\|/) ? $1 : () } split(/\n/,$x);
    if (@fams > 3)
    {
	print join(",",@fams),"\n";
    }
}
