=head1 Evaluate the Bins from a Binning Job

    p3-eval-bins.pl [options] binDir

This script will evaluate the bins resulting from a binning job run through L<bins_sample_pipeline.pl>. In each such directory, it expects
the following files.

=over 4

=item bins.rast.json

A set of bin descriptors in JSON format, suitable for loading using the L<Bin/ReadBins> method.

=item binX.gto

Where I<X> is the bin number, a L<GenomeTypeObject> file containing the genome built from the bin.

=item XXXXXX.X.json

Where I<XXXXXX.X> is the ID of a reference genome, a L<GenomeTypeObject> file containing the reference genome.

=back

A subdirectory C<Eval> will be created containing the evaluation output. This will include a C<.out> file and a C<.html> file for each bin, plus an C<index.html>
file and an C<index.tbl> file containing a summary of all the bins.

=head2 Parameters

The positional parameter is the name of the sample directory containing the binning job to process.

The command-line options include those in L<EvalCon/role_options> and L<BinningReports/template_options> as well as the following.

=over 4

=item deep

Compare bin protein sequences to the reference genome.

=item checkDir

The directory containing the completeness-checker input files (see L<GenomeChecker> for details). The default is
C<CheckG> in the SEEDtk globals directory.

=item recursive

If specified, the input directory is considered a directory of samples, rather than a sample directory. All subdirectories will be processed.

=item missing

If specified, the evaluation will not be performed if it has already been performed. The existence of an C<Eval/index.html> file will be considered evidence
of an evaluation already performed.

=back

=cut

use strict;
use P3Utils;
use Bin;
use EvalCon;
use GenomeChecker;
use BinningReports;
use File::Copy::Recursive;
use GEO;
use Data::Dumper;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('binDir', BinningReports::template_options(), EvalCon::role_options(),
        ['recursive', 'process all samples in subdirectories'],
        ['checkDir=s', 'completeness checker configuration files', { default => "$FIG_Config::global/CheckG" }],
        ['missing', 'skip processed samples'],
        ['deep', 'show full details']
        );
# Get the parameters.
my ($binDir) = @ARGV;
if (! $binDir) {
    die "No input directory specified.";
} elsif (! -d $binDir) {
    die "Directory $binDir is missing or invalid.";
}
# Compute the list of directories to process.
my @samples;
if ($opt->recursive) {
    # Here we are processing all the subdirectories.
    opendir(my $dh, $binDir) || die "Could not open directory $binDir: $!";
    @samples = map { "$binDir/$_" } sort grep { -s "$binDir/$_/bins.rast.json" } readdir $dh;
    closedir $dh;
    print scalar(@samples) . " sample directories found in $binDir.\n";
} else {
    # Here we are processing a single directory
    if (! -s "$binDir/bins.rast.json") {
        die "$binDir does not appear to contain a completed sample.";
    } else {
        @samples = ($binDir);
    }
}
# Get the web page strings.
print "Loading web page templates.\n";
my ($prefix, $suffix, $detailTT) = BinningReports::build_strings($opt);
my $summaryTFile = $opt->templates . "/summary.tt";
# Create the consistency helper.
print "Loading EvalCon data.\n";
my $evalCon = EvalCon->new_from_script($opt);
# Get access to the statistics object.
my $stats = $evalCon->stats;
# Create the completeness helper.
my ($nMap, $cMap) = $evalCon->roleHashes;
my $evalG = GenomeChecker->new($opt->checkdir, roleHashes=> [$nMap, $cMap], logH => \*STDOUT, stats => $stats);
# Set up the options for creating the GEOs.
my $detail = ($opt->deep ? 2 : 1);
my %geoOptions = (roleHashes => [$nMap, $cMap], logH => \*STDOUT, detail => $detail, binned => 1);
# Loop through the samples.
my $sampTot = scalar @samples;
my $sampDone = 0;
for my $sample (@samples) {
    if ($opt->missing && -s "$sample/Eval/index.html") {
        print "$sample already processed-- skipping.\n";
        $stats->Add(sampleSkipped => 1);
    } else {
        # Here we have a sample that needs evaluation. We need to create GEOs for all the reference genomes and the bin genomes.
        print "Loading genomes for $sample.\n";
        # Compute the actual sample name.
        my $sName = $sample;
        if ($sName =~ /([^\/\\]+)$/) {
            $sName = $1;
        }
        # Now we find all the GTOs of interest.
        opendir(my $dh, $sample) || die "Could not open directory $sample: $!";
        my @files = map { "$sample/$_" } grep { $_ =~ /^bin\d+.gto|\d+\.\d+\.json$/ } readdir $dh;
        closedir $dh;
        print scalar(@files) . " genomes found in $sample.\n";
        # Create GEOs from them for evaluation.
        my $geoHash = GEO->CreateFromGtoFiles(\@files, %geoOptions);
        # Map them by name.
        my %nameMap = map { $geoHash->{$_}->name => $_ } keys %$geoHash;
        # We will save the GEOs to evaluate in this list.
        my @evalGeos;
        # Now we must link the bins to the reference genomes. We use the bins.rast.json file for this.
        # First we get a hash that maps each bin name to its coverage and reference genomes. This hash
        # is used by the web page builder as well as us. The nested call means we don't need to keep
        # whole bins in memory.
        my $binHash = BinningReports::parse_bins_json(Bin::ReadBins("$sample/bins.rast.json"));
        # Loop through the bins, linking the reference genomes.
        for my $binName (keys %$binHash) {
            # Find this bin's genome.
            my $binID = $nameMap{$binName};
            if (! $binID) {
                print "WARNING: Could not find the genome in $sample for $binName.\n";
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
            print "No bins found to evaluate in $sample.\n";
            $stats->Add(sampleEmpty => 1);
        } else {
            # Create the output directory.
            my $outDir = "$sample/Eval";
            if (! -d $outDir) {
                File::Copy::Recursive::pathmk($outDir) || die "Could not create $outDir: $!";
            } else {
                File::Copy::Recursive::pathempty($outDir) || die "Could not erase $outDir: $!";
            }
            # Start the predictor matrix for the consistency checker. We use the sample directory
            # as our work directory, because the files are small.
            $evalCon->OpenMatrix($sample);
            # Now we loop through the bin GEOs.
            for my $geo (@evalGeos) {
                my $genome = $geo->id;
                my $outFile = "$outDir/$genome.out";
                open(my $oh, ">$outFile") || die "Could not open $outFile: $!";
                # Compute the consistency and completeness. This also writes the output.
                $evalG->Check2($geo, $oh);
                # Add this genome to the evalCon matrix.
                $evalCon->AddGeoToMatrix($geo);
            }
            # Evaluate all the genomes for consistency.
            $evalCon->CloseMatrix();
            my $rc = system('eval_matrix', $evalCon->predictors, $sample, $outDir);
            $stats->Add(evalConRun => 1);
            # Loop through the genomes again, storing the quality metrics in the GEOs and creating the summary output file.
            open(my $oh, ">$outDir/index.tbl") || die "Could not create summary output file: $!";
            P3Utils::print_cols(['Sample', 'Bin ID', 'Bin Name', 'Ref ID', 'Ref Name', 'Contigs', 'Base Pairs', 'N50', 'Coarse Consistency', 'Fine Consistency',
                    'Completeness', 'Contamination', 'Taxonomic Grouping', 'Good PheS', 'Good'], oh => $oh);
            for my $geo (@evalGeos) {
                my $genome = $geo->id;
                print "Processing output for $genome.\n";
                $geo->AddQuality("$outDir/$genome.out");
                # Create the detail page.
                my $html = BinningReports::Detail(undef, $binHash, \$detailTT, $geo, $nMap);
                open(my $wh, ">$outDir/$genome.html") || die "Could not open $genome HTML file: $!";
                print $wh $prefix . "<title>$genome</title></head><body>\n" . $html . $suffix;
                close $wh;
                # Create the summary report line.
                my $metrics = $geo->metrics;
                my ($coarse, $fine, $complete, $contam, $group) = $geo->scores;
                my $ref = $geo->bestRef;
                my ($refID, $refName) = ('', '');
                if ($ref) {
                    ($refID, $refName) = ($ref->id, $ref->name);
                }
                my $seedFlag = ($geo->good_seed ? 1 : 0);
                my $goodFlag = ($geo->is_good ? 1 : 0);
                P3Utils::print_cols([$sName, $genome, $geo->name, $refID, $refName, $geo->contigCount, $metrics->{totlen}, $metrics->{N50}, $coarse,
                        $fine, $complete, $contam, $group, $seedFlag, $goodFlag], oh => $oh);
            }
            close $oh; undef $oh;
            # Now we need to create the summary page. First we need to create URLs for the bins.
            my %urlMap = map { $_->id => ($_->id . ".html") } @evalGeos;
            open($oh, ">$outDir/index.html") || die "Could not open summary page for $sample: $!";
            my $html = BinningReports::Summary($sName, { contigs => "$sName/contigs.fasta" }, $binHash, $summaryTFile, '', \@evalGeos, \%urlMap);
            print $oh $prefix . "<title>$sample</title></head><body>" . $html . $suffix;
            close $oh;
        }
    }
    $sampDone++;
    print "$sampDone of $sampTot samples processed.\n";
}
print "All done.\n" . $stats->Show();