use strict;
use Data::Dumper;
use File::Copy::Recursive;
use P3Utils;

=head1 Compute related by signatures for all Genera/Species

    run_all_fam_rel [options] Output genus

Will build a large Output directory. It will contain subdirectories
for each genus/species computation based on p3-related-by-clusters
runs (each producing one of the subdirectories).


=head2 Parameters

There are two positional parameters-- an output directory (which will be erased if it exists) and
an optional genus. If the genus is specified, only that genus will be processed; otherwise,
they will all be processed.

Standard input is not used.

The following options are supported.

=over 4

=item sz1

Number of genomes to use for the in-species sets.

=item sz2

Number of genomes to use for the out-of-species sets.

=item iterations

Number of iterations to use for each species.

=item min

Minimum fraction of the in-species set required for a family to be considered a signature.

=item max

Maximum fraction of the out-of-species set allowed for a family to be considered a signature.

=back

=cut

my $opt = P3Utils::script_opts('outDir [genus]',
        ["sz1=i", "size of the in-species sets", { default => 30 }],
        ["sz2=i", "size of the out-of-species sets", { default => 50 }],
        ["min=f", "minimum fraction of in-species required for a signature", { default => 1 }],
        ["max=f", "maximum fraction of out-of-species allowed for a signature", { default => 0 }],
        ["iterations|n=i", "number of iterations per species", { default => 20 }]);
my ($outD, $genus1) = @ARGV;
my $sz1 = $opt->sz1;
my $sz2 = $opt->sz2;
my $min = $opt->min;
my $max = $opt->max;
my $iter = $opt->iterations;

$outD || die "specify an output directory";
if (-d $outD) {
    File::Copy::Recursive::pathempty($outD) || die "Cannot clear $outD";
} else {
    mkdir($outD,0777) || die "cannot make $outD";
}
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
        print "Processing $genus $s.\n";
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
	    &run("p3-related-by-clusters --gs1 $fI --gs2 $fO -n $iter --sz2=$sz1 --sz1=$sz2  -o $outD/$outN --min=$min --max=$max");
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
