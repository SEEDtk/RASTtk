use strict;

### OBSOLETE ### use p3-merge

=head1 Find Lines in File1 NOT Present in File2

p3-inAnotB

=head1 SYNOPSIS

p3-inAnotB File1 File2 > set-theoretic-difference

=head1 DESCRIPTION

Finds the lines in File1 that are B<NOT> present in File2.

Example:

    p3-inAnotB File1 File2 > set-theoretic-difference

where File1 and File2 are lists of assigned functions.

=head1 COMMAND-LINE OPTIONS

Usage: p3-inAnotB File1 File2 > set-theoretic-difference

File1 --- Name of a text file

File2 --- Name of text-file to be compared.

=head1 AUTHORS

L<The SEED Project|http://www.theseed.org>

=cut

my($f1,$f2);
my $usage = "usage: a_and_b File1 File2 > intersection";

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


my %f2H = map { $_ ? ($_ => 1) : () } `tail -n+2  $f2`;
my %keep;
foreach my $x (grep { ! defined($f2H{$_}) } `tail -n+2  $f1`)
{
    $keep{$x} = 1;
}

print $hdr;
foreach $_ (sort keys(%keep))
{
    print $_;
}

__DATA__
