use strict;
use Data::Dumper;

=head1 Compute related by signatures for all Genera/Species

    run_all_sel_by_sig Output genus

Will build a large Output directory. It will contain subdirectories
for each genus/species computation based on p3-related-by-clusters
runs (each producing one of the subdirectories).


=head2 Parameters

There are two positional parameters-- an output directory (which must not exist) and
an optional genus. If the genus is specified, only that genus will be processed; otherwise,
they will all be processed.

Standard input is not used.

=cut

my ($outD, $genus1) = @ARGV; 
$outD || die "specify an output directory";

mkdir($outD,0777) || die "cannot make $outD";
my $cmd = "p3-all-genomes --attr genome_name";
open(ALL,"$cmd |") 
    || die "could not access genomes";

my @genomes = map { ($_ =~ /^(\d+\.\d+)\s+([A-Z]\S+)\s([a-z]+\S+)/) ? [$1,$2,$3] : () } <ALL>;
close(ALL);
# my @genomes = map { ($_ =~ /^(\d+\.\d+)\s+([A-Z]\S+)\s([a-z]+\S+)/) ? [$1,$2,$3] : () } `cat patric.genomes`;
my %gs;

foreach my $tuple (@genomes)
{
    my($id,$g,$s) = @$tuple;
    if ($s !~ /^sp\./)
    {
	$gs{$g}->{$s}->{$id} = 1;
    }
}
my @geni;
if ($genus1) {
    @geni = ($genus1);
} else {
    @geni = sort keys %gs;
}


foreach my $genus (@geni)
{
    my @species = sort keys(%{$gs{$genus}});
    foreach my $s (@species)
    {
	my @in;
	my @out;
	foreach my $s1 (@species)
	{
            my @genomes = keys(%{$gs{$genus}->{$s1}});
	    if ($s eq $s1)
	    {
		push(@in,@genomes);
	    }
	    else
	    {
		push(@out,@genomes);
	    }
	}

	if ((@in >= 5) && (@out >= 5))
	{
	    my $fI = "tmp1.$$";
	    my $fO = "tmp2.$$";
	    &dump_to_file(\@in,$fI);
	    &dump_to_file(\@out,$fO);
	    my $outN = "Output.$genus.$s";
	    &run("p3-related-by-clusters --gs1 $fI --gs2 $fO -n 1 --sz2=30 --sz1=30  -o $outD/$outN --min 1.0 --max 0.0");
#            die "perl p3-related-by-clusters.pl --gs1 $fI --gs2 $fO -n 1 --sz2=30 --sz1=30  -o $outD/$outN --min 1.0 --max 0.0";
	    unlink $fI;
	    unlink $fO;
	}
    }
}

sub dump_to_file {
    my($genomes,$file) = @_;

    open(TMP,">$file") || die "could not open $file";
    print TMP "genome.genome_id\n";
    foreach $_ (@$genomes)
    {
	print TMP "$_\n";
    }
    close(TMP);
}

sub run {
    shift if UNIVERSAL::isa($_[0],__PACKAGE__);
    my($cmd) = @_;

    if ($ENV{FIG_VERBOSE}) {
        my @tmp = `date`;
        chomp @tmp;
        print STDERR "$tmp[0]: running $cmd\n";
    }
    (system($cmd) == 0) || die("FAILED: $cmd");
}
