=head1 Description

    p3x-test-evaluator.pl [options] binDir outDir

This is a script to test the evaluation pipeline. In order to mimic the environment in a binning situation, we
take as input a binning directory, then create an output directory for each bin with evaluation web pages.
The GTOs are then read back in and a summary page created.

=head2 Parameters

The positional parameters are the name of the directory containing the binning results and the name of a
directory to contain the output.

Additional command-line options are those in L<EvalCon/role_options> and L<BinningReports/template_options>
plus the following.

=item checkDir

The name of the directory containing the reference genome table and the completeness data files. The default
is C<CheckG> in the SEEDtk global data directory.

=item clear

If specified, the output directory will be erased before starting. Otherwise, existing subdirectories in the
output will be skipped.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use EvalCon;
use EvalCom::Tax;
use GEO;
use File::Copy::Recursive;
use Bin;
use Stats;
use GenomeTypeObject;
use BinningReports;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('binDir outDir', BinningReports::template_options(), EvalCon::role_options(),
        ['checkDir=s', 'completeness data directory', { default => "$FIG_Config::p3data/CheckG" }],
        ['clear', 'erase output directory']
        );
# Get the incoming directories.
my ($binDir, $outDir) = @ARGV;
if (! $binDir) {
    die "No input directory specified.";
} elsif (! -d $binDir) {
    die "Input directory $binDir missing or invalid.";
} elsif (! $outDir) {
    die "No output directory specified.";
} elsif (! -d $outDir) {
    print "Creating output directory $outDir.\n";
    File::Copy::Recursive::pathmk($outDir) || die "Could not create $outDir: $!";
} elsif ($opt->clear) {
    print "Erasing output directory $outDir.\n";
    File::Copy::Recursive::pathempty($outDir) || die "Could not erase $outDir: $!";
}
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Get the web page strings.
print "Loading web page templates.\n";
my ($prefix, $suffix, $detailTT) = BinningReports::build_strings($opt);
my $summaryTFile = $opt->templates . "/summary.tt";
# Create the consistency helper.
print "Loading EvalCon data.\n";
my $evalCon = EvalCon->new_for_script($opt);
# Get access to the statistics object.
my $stats = $evalCon->stats;
# Create the completeness helper.
my ($nMap, $cMap) = $evalCon->roleHashes;
my $evalG = EvalCom::Tax->new($opt->checkdir, roleHashes=> [$nMap, $cMap], logH => \*STDOUT, stats => $stats);
# Set up the options for creating the GEOs.
my %geoOptions = (roleHashes => [$nMap, $cMap], logH => \*STDOUT, detail => 2, binned => 1);
# Now we find all the GTOs of interest.
opendir(my $dh, $binDir) || die "Could not open directory $binDir: $!";
my @files = map { "$binDir/$_" } grep { $_ =~ /^bin\d+.gto|\d+\.\d+\.json$/ } readdir $dh;
closedir $dh;
print scalar(@files) . " genomes found in $binDir.\n";
# Load them into memory and create GEOs from them for evaluation.
my (%gtoHash, $geoHash);
for my $file (@files) {
    print "Loading genome from $file.\n";
    my $gto = GenomeTypeObject->create_from_file($file);
    my $genome = $gto->{id};
    $gtoHash{$genome} = $gto;
    my $geo = GEO->CreateFromGto($gto, %geoOptions);
    $geoHash->{$genome} = $geo;
}
# Map the GEOs by name.
my %nameMap = map { $geoHash->{$_}->name => $_ } keys %$geoHash;
# We will save the GEOs to evaluate in this list.
my @evalGeos;
# Now we must link the bins to the reference genomes. We use the bins.json file for this.
my $binHash = BinningReports::parse_bins_json(Bin::ReadBins("$binDir/bins.json"));
# Loop through the bins, linking the reference genomes.
for my $binName (keys %$binHash) {
    # Find this bin's genome.
    my $binID = $nameMap{$binName};
    if (! $binID) {
        print "WARNING: Could not find the genome in $binDir for $binName.\n";
        $stats->Add(binNotFound => 1);
    } else {
        my $binGeo = $geoHash->{$binID};
        print "Genome $binID found for $binName.\n";
        $stats->Add(binGenomeFound => 1);
        push @evalGeos, $binGeo;
        # Get the reference genome IDs.
        my $refGenomes = $binHash->{$binName}{refs};
        for my $refGenome (@$refGenomes) {
            # Extract the reference genome ID.
            my $refGenomeID = $refGenome->{genome};
            my $refGeo = $geoHash->{$refGenomeID};
            if (! $refGeo) {
                print "WARNING: reference genome $refGenomeID not found for bin $binID.\n";
                $stats->Add(refGenomeNotFound => 1);
            } else {
                $binGeo->AddRefGenome($refGeo);
                print "$refGenomeID is a reference for $binID.\n";
                $stats->Add(refGenomeFound => 1);
            }
        }
    }
}
# Only proceed if we have something to do.
if (! @evalGeos) {
    print "No bins found to evaluate in $binDir.\n";
    $stats->Add(sampleEmpty => 1);
} else {
    # Start the predictor matrix for the consistency checker. We use the target directory
    # as our work directory, because the files are small.
    $evalCon->OpenMatrix($outDir);
    # This will keep the GEOs to be copied into the output.
    my @evaledGeos;
    # Now we loop through the bin GEOs.
    for my $geo (@evalGeos) {
        my $genome = $geo->id;
        # Compute the target directory.
        my $targetDir = "$outDir/$genome";
        if (-s "$targetDir/$genome.gto") {
            # There is already a GTO in there. Replace the incoming GTO with it and regenerate the GEO.
            print "Reloading genome $genome.\n";
            $gtoHash{$genome} = GenomeTypeObject->create_from_file("$targetDir/$genome.gto");
            $geo = GEO->CreateFromGto($gtoHash{$genome}, %geoOptions);
            $geoHash->{$genome} = $geo;
            $stats->Add(genomeReloaded => 1);
        } else {
            my $outFile = "$outDir/$genome.out";
            open(my $oh, ">$outFile") || die "Could not open $outFile: $!";
            # Compute the consistency and completeness. This also writes the output.
            $evalG->Check2($geo, $oh);
            # Add this genome to the evalCon matrix.
            $evalCon->AddGeoToMatrix($geo);
            $stats->Add(genomeEvaluated => 1);
            push @evaledGeos, $geo;
        }
    }
    # Evaluate all the genomes for consistency.
    $evalCon->CloseMatrix();
    if (@evaledGeos) {
        my $rc = system('eval_matrix', $evalCon->predictors, $outDir, $outDir);
        $stats->Add(evalConRun => 1);
        # Loop through the genomes again, storing the quality metrics in the GEOs.
        for my $geo (@evaledGeos) {
            my $genome = $geo->id;
            print "Processing output for $genome.\n";
            $geo->AddQuality("$outDir/$genome.out");
            File::Copy::Recursive::fmove("$outDir/$genome.out", "$outDir/$genome/eval.out");
            # Create the detail page.
            my $html = BinningReports::Detail(undef, $binHash, \$detailTT, $geo, $nMap);
            open(my $wh, ">$outDir/$genome/GenomeReport.html") || die "Could not open $genome HTML file: $!";
            print $wh $prefix . "<title>$genome</title></head><body>\n" . $html . $suffix;
            close $wh;
            # Update the GTO and write it back out.
            $geo->UpdateGTO($gtoHash{$genome});
            $gtoHash{$genome}->destroy_to_file("$outDir/$genome/$genome.gto");
        }
    }
    @evaledGeos = ();
    # Now we need to create the summary page. First we need to create URLs for the bins.
    my %urlMap = map { $_->id => ($_->id . "/GenomeReport.html") } @evalGeos;
    # Now we reload the GEOs from the GTOs. This is for test purposes.
    @evalGeos = ();
    for my $genome (keys %urlMap) {
        print "Rebuilding $genome.\n";
        my $geo = GEO->CreateFromGto($gtoHash{$genome}, %geoOptions);
        push @evalGeos, $geo;
    }
    open(my $oh, ">$outDir/index.html") || die "Could not open summary page for $binDir: $!";
    my $html = BinningReports::Summary($binDir, { contigs => "$binDir/contigs.fasta" }, $binHash, $summaryTFile, '', \@evalGeos, \%urlMap);
    print $oh $prefix . "<title>$binDir</title></head><body>" . $html . $suffix;
    close $oh;
}
print "All done\n" . $stats->Show();
