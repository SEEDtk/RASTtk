use strict;

### OBSOLETE ### use p3-merge

=head1 Merge Two Files

p3-inAorB

=head1 SYNOPSIS

p3-inAorB File1 File2 > set of lines in either A or B

=head1 DESCRIPTION

Finds the lines that are in File1 or File2.

Example:

    p3-inAorB File1 File2 > set-in-A-or-B

where File1 and File2 are lists of assigned functions.

=head1 COMMAND-LINE OPTIONS

Usage: p3-inAorB File1 File2 > set-in-A-or-B

File1 --- Name of a text file

File2 --- Name of text-file to be compared.

=head1 AUTHORS

L<The SEED Project|http://www.theseed.org>

=cut

my($f1,$f2);
my $usage = "usage: p3-inAorB File1 File2 > in-A-or-B";

my $help;
use Getopt::Long;
my $rc = GetOptions('help' => \$help);

if (!$rc || $help || @ARGV < 2) {
    seek(DATA, 0, 0);
    while (<DATA>) {
        last if /^=head1 COMMAND-LINE /;
    }
    while (<DATA>) {
        last if (/^=/);
        print $_;
    }
    exit($help ? 0 : 1);
}

(
 ($f1 = shift @ARGV) && (-s $f1) &&
 ($f2 = shift @ARGV) && (-s $f2)
)
    || die $usage;

#save the p3 header from f1;
my $hdr = `head -n 1 $f1`;
my $hdr2 = `head -n 1 $f2`;
if ($hdr ne $hdr2) {
    die "different format files";
}


#we're gonna find out what is in a but not b and save the nots along with all of b

my %f1H = map { $_ ? ($_ => 1) : () } `tail -n+2  $f1`;
my %f2H = map { $_ ? ($_ => 1) : () } `tail -n+2  $f2`;
foreach my $x (grep { ! defined($f2H{$_}) } keys(%f1H))
{
    $f2H{$x} = 1;
}

print $hdr;
foreach $_ (sort keys(%f2H)) {
    print $_;
}

__DATA__
