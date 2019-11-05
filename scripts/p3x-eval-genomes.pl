=head1 Evaluate PATRIC Genomes

    p3x-eval-genomes.pl [options] workDir outDir

This script evaluates one or more PATRIC genomes. Normally, it takes an input file containing genome IDs and produces
an output directory containing evaluation information for each genome. Optionally, web page output can be specified.
The standard error output will contain progress messages. This is an artifact of the many subordinate helper scripts required.
The standard output will contain the consistency and completeness numbers appended to the input rows.

Each output file will have two sections-- a completeness section followed by a consistency section. Each section begins
with a set of labeled values. The label begins in the first column and is separated from the number by
a colon and whitespace. The labels for completeness are C<Good Seed>, C<Completeness>, C<Contamination>, and C<Group>. The labels for
consistency are C<Coarse Consistency> and C<Fine Consistency>. Beneath the labels are
zero or more role descriptors, all tab-delimited. Each role descriptor consists of (0) a role ID, (1) a predicted count,
and (2) an expected count.

=head2 Parameters

The positional parameters are the name of a working directory and the name of an output directory. The working directory
contents are destroyed, but the output directory contents are not, unless C<--clear> is specified.

The standard input can be overridden using the options in L<P3Utils/ih_options>. The standard input should contain
PATRIC genome IDs in the key column (as specified by L<P3Utils/col_options>).

The options in L<EvalCon/role_options> may be used to specify the predictors for doing the consistency checks.

The options in L<BinningReports/template_options> may be used to specify the templates and web helper files.

The following additional command-line options are supported.

=over 4

=item checkDir

The directory containing the completeness-checker input files (see L<EvalCom::Tax> for details). The default is
C<CheckG> in the SEEDtk globals directory.  If the directory contains a C<REP> file, L<EvalCom::Rep> will be used
instead, and the REP file must contain the kmer size.

=item clear

If specified, the output directory is erased before any output is produced.

=item web

If specified, web pages for all of the genome evaluations will be produced in the output directory.

=item deep

If specified, the web pages will include detailed protein analysis. Implies C<--web>.

=item gtoCol

If specified, the index (1-based) or name of an input column containing the names for pre-fetched L<GenomeTypeObject> files for the
specified genomes. This option allows greatly improved performance.

=item terse

If specified, the reports on the individual genomes will not be produced, only the basic numbers. If this is specified, the
output directory is ignored, and the C<--clear> and C<--web> options are prohibited.

=item refCol

If specified, the index (1-based) or name of an input column that contains the PATRIC ID of a reference genome. The reference
genome will be used on the web page produced.

=item resume

Specifies a genome ID. All rows of the input will be skipped until the genome ID is found, and then processing will continue
with the next row after that. The standard output will not contain a header. Use this option to resume after a failure.
If this option is specified, C<web> is prohibited.

=item refTable

Specifies a file containing the reference genome mapping. This is a tab-delimited file with two columns (0) a taxonomic grouping
ID and (1) the corresponding reference genome. The groupings are usually genus or species. If no reference genome is specified
and one can be computed from this file, it will be used. The default is C<ref.genomes.tbl> in the C<--checkDir> directory.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use BinningReports;
use EvalCon;
use EvalCom::Tax;
use EvalCom::Rep;
use GEO;
use File::Copy::Recursive;
use GPUtils;
use Math::Round;
use Time::HiRes;

$| = 1;
my $exitCode = 0;
my $start = time;
# Get the command-line options.
my $opt = P3Utils::script_opts('workDir outDir', P3Utils::col_options(), P3Utils::ih_options(),
        EvalCon::role_options(), BinningReports::template_options(),
        ['checkDir=s', 'completeness checker configuration files', { default => "$FIG_Config::p3data/CheckG" }],
        ['clear', 'clear output directory before starting'],
        ['web', 'create web pages as well as output files for evaluations'],
        ['deep', 'perform detailed analysis of missing and redundant proteins (implies web)'],
        ['terse', 'suppress individual genome role reports (incompatible with web)'],
        ['gtoCol=s', 'index (1-based) or name of column containing GTO file names'],
        ['refCol=s', 'index (1-based) or name of column containing reference genome IDs'],
        ['resume=s', 'resume after error with specified genome'],
        ['refTable=s', 'reference genome file']
        );
# Get the input directories.
my ($workDir, $outDir) = @ARGV;
if (! $workDir) {
    die "No working directory specified.";
} elsif (-f $workDir) {
    die "Invalid working directory $workDir.";
} elsif (! -d $workDir) {
    print STDERR "Creating $workDir.\n";
    File::Copy::Recursive::pathmk($workDir) || die "Could not create $workDir: $!";
} else {
    print STDERR "Erasing $workDir.\n";
    File::Copy::Recursive::pathempty($workDir) || die "Could not clear $workDir: $!";
}
# Check for terse mode.
my $terse = $opt->terse;
if ($terse) {
    if ($opt->web) {
        die "Cannot specify web output in terse mode.";
    }
    if ($opt->clear) {
        print STDERR "Output directory is not used and will not be cleared.\n";
    }
    $outDir = '0';
} else {
    if (! $outDir) {
        die "No output directory specified.";
    } elsif (-f $outDir) {
        die "Invalid output directory $outDir.";
    } elsif (! -d $outDir) {
        print STDERR "Creating $outDir.\n";
        File::Copy::Recursive::pathmk($outDir) || die "Could not create $outDir: $!";
    } elsif ($opt->clear) {
        print STDERR "Erasing $outDir.\n";
        File::Copy::Recursive::pathempty($outDir) || die "Could not clear $outDir: $!";
    }
}
# Get access to PATRIC.
print STDERR "Connecting to PATRIC.\n";
my $p3 = P3DataAPI->new();
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Compute the GTO file and reference genome columns.
my $gtoCol = $opt->gtocol;
if (defined $gtoCol) {
    print STDERR "GTO file names will be taken from column $gtoCol.\n";
    $gtoCol = P3Utils::find_column($gtoCol, $outHeaders);
}
my $refCol = $opt->refcol;
if (defined $refCol) {
    print STDERR "Reference genome IDs will be taken from column $refCol.\n";
    $refCol = P3Utils::find_column($refCol, $outHeaders);
}
my %refMap;
my $refCount = 0;
# Get the web options and compute the detail level.
my $web = $opt->web || $opt->deep;
my $detailLevel = ($opt->deep ? 2 : ($web ? 1 : 0));
my ($prefix, $suffix, $detailTT);
if ($web) {
    print STDERR "Building web page templates.\n";
    ($prefix, $suffix, $detailTT) = BinningReports::build_strings($opt);
    if ($opt->resume) {
        die "Cannot resume if web page output is desired.";
    }
    # Reference genomes are used by the web pages. Check for them.
    my $refTable = $opt->reftable // ($opt->checkdir . '/ref.genomes.tbl');
    print STDERR "Reference genome file is $refTable.\n";
    if (-s $refTable) {
        # Here we have a reference-genome table.
        open(my $rh, "<$refTable") || die "Could not open reference genome table $refTable: $!";
        while (! eof $rh) {
            my $line = <$rh>;
            if ($line =~ /^(\d+)\t(\d+\.\d+)/) {
                $refMap{$1} = $2;
            }
        }
        $refCount = scalar keys %refMap;
        print STDERR "$refCount reference genomes read from $refTable.\n";
    }
}
# Create the consistency helper.
my $evalCon = EvalCon->new_for_script($opt, \*STDERR);
# Get access to the statistics object.
my $stats = $evalCon->stats;
# Create the completeness helper.
my ($nMap, $cMap) = $evalCon->roleHashes;
my %evalOptions = (logH => \*STDERR, stats => $stats);
my $evalCom;
my $checkDir = $opt->checkdir;
print STDERR "Reading completeness data from $checkDir.\n";
if (-s "$checkDir/REP") {
    open(my $xh, '<', "$checkDir/REP") || die "Could not open REP file: $!";
    my $k = <$xh>;
    chomp $k;
    $evalCom = EvalCom::Rep->new($checkDir, %evalOptions, K => $k);
} else {
    $evalCom = EvalCom::Tax->new($checkDir, %evalOptions, roleHashes=> [$nMap, $cMap]);
}
print STDERR "Completeness data read.\n";
my $timer = Math::Round::round(time - $start);
$stats->Add(timeLoading => $timer);
# Set up the options for creating the GEOs.
my %geoOptions = (roleHashes => [$nMap, $cMap], p3 => $p3, stats => $stats, detail => $detailLevel,
        logH => \*STDERR);
# Process the resume option.
my $skipped = 0;
if ($opt->resume) {
    my $found;
    my $lastGenome = $opt->resume;
    print STDERR "Searching for $lastGenome.\n";
    while (! eof $ih && ! $found) {
        my $line = <$ih>;
        my @fields = P3Utils::get_fields($line);
        $skipped++;
        if ($fields[$keyCol] eq $lastGenome) {
            $found = 1;
        }
    }
    print STDERR "$skipped lines skipped.\n";
} elsif (! $opt->nohead) {
    # Not resuming. Form the full header set and write it out.
    push @$outHeaders, 'Coarse Consistency', 'Fine Consistency', 'Completeness', 'Contamination', 'Completeness Group', 'Good Seed';
    P3Utils::print_cols($outHeaders);
}
# If an error occurs, we still display stats.
my $lastGenome = "";
eval {
    my $start0 = time;
    my $count0 = 0;
    # The GEOs for the summary web page will be kept in here.
    my @summary;
    # Loop through the input.
    while (! eof $ih) {
        # Get this batch of input.
        my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
        # This hash will map reference genome IDs to the target genomes.
        my %refGenomes;
        # This hash will map target genome IDs to their GEOs.
        my %geoMap;
        # This hash remembers which genomes we need to evaluate.
        my %mainGenomes;
        # Start the predictor matrix for the consistency checker.
        $evalCon->OpenMatrix($workDir);
        # Loop through the couplets. We will accumulate reference genome requirements and PATRIC genome IDs in separate lists.
        # GTOs will be processed individually.
        my (@gtoFiles, %pGenomes, @refsNeeded, %gRefsNeeded);
        for my $couplet (@$couplets) {
            my ($genome, $row) = @$couplet;
            $stats->Add(genomeIn => 1);
            $mainGenomes{$genome} = 1;
            my $refNeeded;
            # Check for a reference genome.
            if (defined $refCol && $row->[$refCol]) {
                my $rGenome = $row->[$refCol];
                $pGenomes{$rGenome} = 1;
                $refGenomes{$rGenome} = $genome;
            } elsif ($refCount) {
                # Here we have to search the taxon list for the reference genomes. Queue a request.
                $refNeeded = 1;
            }
            # Read in the genome if this is a GTO; otherwise, queue it.
            if (defined $gtoCol && $row->[$gtoCol]) {
                # GTO is provided. Load it in.
                my $gtoName = $row->[$gtoCol];
                my $gHash = GEO->CreateFromGtoFiles([$gtoName], %geoOptions);
                if (! $gHash->{$genome}) {
                    die "$gtoName is missing or does not have genome ID $genome.\n";
                } else {
                    $geoMap{$genome} = $gHash->{$genome};
                    print STDERR "Target genome $genome queued for evaluation.\n";
                    # For a GTO, we need to get the reference genome from the taxonomic ID.
                    if ($refNeeded) {
                        $gRefsNeeded{$genome} = 1;
                    }
                }
            } else {
                $pGenomes{$genome} = 1;
                if ($refNeeded) {
                    push @refsNeeded, $genome;
                }
            }
        }
        # Look for reference genomes for the GTOs.
        if (keys %gRefsNeeded) {
            print STDERR "Searching for reference genomes for " . scalar(keys %gRefsNeeded) . " GTOs.\n";
            my @taxResults;
            for my $genome (keys %gRefsNeeded) {
                my $lineage = $geoMap{$genome}->lineage;
                push @taxResults, [$genome, $lineage];
            }
            ProcessTaxResults(\@taxResults, \%pGenomes, \%refGenomes);
        }
        # Look for reference genomes for the PATRIC genomes.
        if (@refsNeeded) {
            # Read the taxonomic lineage for each genome that needs a reference.
            print STDERR "Searching for reference genomes for " . scalar(@refsNeeded) . " genomes.\n";
            $start = time;
            # This is simpler. We get the taxonomy data for each genome ID and compute the reference.
            my $taxResults = P3Utils::get_data_keyed($p3, genome => [], ['genome_id', 'taxon_lineage_ids'], \@refsNeeded);
            ProcessTaxResults($taxResults, \%pGenomes, \%refGenomes);
            $stats->Add(refSearchTime => Math::Round::round(time - $start));
        }
        # Get the data for the PATRIC genomes (which includes any reference genomes).
        $start = time;
        my @pGenomes = sort keys %pGenomes;
        if (scalar @pGenomes) {
            my $gHash = GEO->CreateFromPatric(\@pGenomes, %geoOptions);
            for my $genome (keys %$gHash) {
                if ($mainGenomes{$genome}) {
                    my $geo = $gHash->{$genome};
                    if (! $geo) {
                        print STDERR "Target genome $genome was not found.\n";
                    } else {
                        $geoMap{$genome} = $geo;
                        print STDERR "Target genome $genome queued for evaluation.\n";
                    }
                }
            }
            for my $genome (keys %refGenomes) {
                my $refGeo = $gHash->{$genome};
                if ($refGeo) {
                    my $targetList = $refGenomes{$genome};
                    for my $target (@$targetList) {
                        my $geo = $geoMap{$target};
                        if ($geo) {
                            $geo->AddRefGenome($refGeo);
                            print STDERR "$genome stored as reference for $target.\n";
                        }
                    }
                }
            }
        }
        $stats->Add(timeFetching => Math::Round::round(time - $start));
        # This will hold results for the output. It will map genome IDs to [coarse, fine, complete, contam, goodSeed];
        my %results;
        for my $genome (keys %geoMap) {
            my $geo = $geoMap{$genome};
            # We have the genome. Start the output file.
            my $outFile = "$outDir/$genome.out";
            my $oh;
            if (! $terse) {
                open($oh, ">$outFile") || die "Could not open $outFile: $!";
            }
            # Compute the consistency and completeness. This also writes the output file.
            my ($complete, $contam, $taxon, $seedFlag) = $evalCom->Check2($geo, $oh);
            # Store the evaluation results.
            $results{$genome} = [0, 0, $complete, $contam, $taxon, ($seedFlag ? 'Y' : '')];
            # Add this genome to the evalCon matrix.
            $evalCon->AddGeoToMatrix($geo);
        }
        # Now evaluate the batch for consistency.
        $evalCon->CloseMatrix();
        if (! keys %results) {
            print STDERR "No genomes found in batch-- skipping.\n";
        } else {
            $start = time;
            my $rc = system('eval_matrix', $evalCon->predictors, $workDir, $outDir);
            if ($rc) {
                die "EvalCon returned error code $rc.";
            }
            $stats->Add(timeConsistency => Math::Round::round(time - $start));
            $stats->Add(evalConRun => 1);
            # Read back the results to get the consistencies.
            open(my $sh, "<$workDir/summary.out") || die "Could not open evalCon summary file: $!";
            while (! eof $sh) {
                my $line = <$sh>;
                my ($genome, $coarse, $fine) = P3Utils::get_fields($line);
                $results{$genome}[0] = $coarse;
                $results{$genome}[1] = $fine;
                if (GEO::consistX($fine)) {
                    $stats->Add(genomeConsistent => 1);
                }
            }
            close $sh;
            # Now, write the standard output and optionally produce the web pages.
            for my $couplet (@$couplets) {
                my ($genome, $row) = @$couplet;
                my $result = $results{$genome};
                if ($result) {
                    P3Utils::print_cols([@$row, @$result]);
                    $stats->Add(genomeOut => 1);
                    if ($web) {
                        my $geo = $geoMap{$genome};
                        # Store the quality metrics in the GTO.
                        $geo->AddQuality("$outDir/$genome.out");
                        # Create the detail page.
                        my $html = BinningReports::Detail(undef, undef, \$detailTT, $geo, $nMap);
                        open(my $wh, ">$outDir/$genome.html") || die "Could not open $genome HTML file: $!";
                        print $wh $prefix . "<title>$genome</title></head><body>\n" . $html . $suffix;
                        close $wh;
                        # Save this GEO for the summary page.
                        push @summary, $geo;
                    }
                }
                # Denote this is our last successfully-processed genome.
                $count0++;
                $lastGenome = $genome;
            }
            my $count1 = $count0 + $skipped;
            print STDERR "$count1 genomes processed at " . Math::Round::nearest(0.01, (time - $start0)/$count0) . " seconds/genome.\n";
        }
    }
    # Here we have processed all the genomes. If we are doing a summary page, we do it now.
    if ($web && scalar(@summary) > 1) {
        my $summaryTFile = $opt->templates . '/summary.tt';
        my %urlMap = map { $_->id => ($_->id . ".html") } @summary;
        open(my $oh, ">$outDir/index.html") || die "Could not open summary web page: $!";
        my $html = BinningReports::Summary('', {}, undef, $summaryTFile, '', \@summary, \%urlMap);
        print $oh "<html><head><title>Genome Evaluations</title></head><body>\n" . $html . $suffix;
        close $oh;
    }
};
if ($@) {
    # Here an error occurred.
    if ($lastGenome) {
        print STDERR "FATAL ERROR: last genome processed was $lastGenome.\n";
    } else {
        print STDERR "FATAL ERROR before any output.\n";
    }
    print STDERR "$@\n";
    $exitCode = 255;
}
# All done. Dump the stats.
print STDERR "All done.\n" . $stats->Show();
exit($exitCode);

# Find the reference genomes given the results of a taxonomic lineage ID query.
sub ProcessTaxResults {
    my ($taxResults, $pGenomes, $refGenomes) = @_;
    my $count = 0;
    for my $taxResult (@$taxResults) {
        # Get this genome's ID and lineage.
        my ($genome, $lineage) = @$taxResult;
        # Loop through the lineage until we find something. Note that sometimes the lineage ID list comes back
        # as an empty string instead of a list so we need an extra IF.
        my $refFound;
        if ($lineage) {
            while (! $refFound && (my $tax = pop @$lineage)) {
                $refFound = $refMap{$tax};
            }
        }
        if ($refFound && $genome ne $refFound) {
            push @{$refGenomes->{$refFound}}, $genome;
            $pGenomes->{$refFound} = 1;
            $count++;
        } elsif ($refFound) {
            $stats->Add(refSelfFound => 1);
        } else {
            $stats->Add(refNotFound => 1);
        }
    }
    print STDERR "$count reference genomes found.\n";
}
