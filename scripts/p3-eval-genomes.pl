=head1 Evaluate PATRIC Genomes

    p3-eval-genomes.pl [options] workDir outDir

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

The following additional command-line options are supported.

=over 4

=item checkDir

The directory containing the completeness-checker input files (see L<GenomeChecker> for details). The default is
C<CheckG> in the SEEDtk globals directory.

=item clear

If specified, the output directory is erased before any output is produced.

=item web

If specified, web pages for all of the genome evaluations will be produced in the output directory. (This option is not
yet implemented.)

=item gtoCol

If specified, the index (1-based) or name of an input column containing the names for pre-fetched L<GenomeTypeObject> files for the
specified genomes. This option allows greatly improved performance.

=item templates

Name of the directory containing the web page templates and style file. The default is C<RASTtk/lib/BinningReports> in the
SEEDtk code directory.

=item terse

If specified, the reports on the individual genomes will not be produced, only the basic numbers. If this is specified, the
output directory is ignored, and the C<--clear> and C<--web> options are prohibited.

=item refCol

If specified, the index (1-based) or name of an input column that contains the PATRIC ID of a reference genome. The reference
genome will be used on the web page produced.

=item resume

Specifies a genome ID. All rows of the input will be skipped until the genome ID is found, and then processing will continue
with the next row after that. The standard output will not contain a header. Use this option to resume after a failure.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use BinningReports;
use EvalCon;
use GenomeChecker;
use GEO;
use File::Copy::Recursive;
use GPUtils;
use Math::Round;
use Time::HiRes;

$| = 1;
my $exitCode = 0;
my $start = time;
# Get the command-line options.
my $opt = P3Utils::script_opts('workDir outDir', P3Utils::col_options(), P3Utils::ih_options(), EvalCon::role_options(),
        ['checkDir=s', 'completeness checker configuration files', { default => "$FIG_Config::global/CheckG" }],
        ['clear', 'clear output directory before starting'],
        ['web', 'create web pages as well as output files for evaluations'],
        ['terse', 'suppress individual genome role reports (incompatible with web)'],
        ['gtoCol=s', 'index (1-based) or name of column containing GTO file names'],
        ['templates=s', 'name of the directory containing the binning templates',
                { default => "$FIG_Config::mod_base/RASTtk/lib/BinningReports" }],
        ['refCol=s', 'index (1-based) or name of column containing reference genome IDs'],
        ['resume=s', 'resume after error with specified genome'],
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
# Get the web options.
my $web = $opt->web;
my $templateDir = $opt->templates;
my $detailTT = "$templateDir/details.tt";
my ($prefix, $suffix);
if ($web) {
    # Prepare the output directory for the web pages.
    if (! -s $detailTT) {
        die "Could not find web template in $templateDir.";
    } else {
        # Read the template file.
        print STDERR "Reading web template file from $detailTT.\n";
        open(my $th, "<$detailTT") || die "Could not open template file: $!";
        $detailTT = join("", <$th>);
        # Copy the style file.
        $prefix = "<html><head>\n<style type=\"text/css\">\n";
        close $th; undef $th;
        open($th, "<$templateDir/packages.css") || die "Could not open style file: $!";
        while (! eof $th) {
            $prefix .= <$th>;
        }
        close $th; undef $th;
        $prefix .= "</style></head><body>\n";
        $suffix = "\n</body></html>\n";
    }
}
# Create the consistency helper.
my $evalCon = EvalCon->new_from_script($opt);
# Get access to the statistics object.
my $stats = $evalCon->stats;
# Create the completeness helper.
my ($nMap, $cMap) = $evalCon->roleHashes;
my $evalG = GenomeChecker->new($opt->checkdir, roleHashes=> [$nMap, $cMap], logH => \*STDERR, stats => $stats);
my $timer = Math::Round::round(time - $start);
$stats->Add(timeLoading => $timer);
# Set up the options for creating the GEOs.
my %geoOptions = (roleHashes => [$nMap, $cMap], p3 => $p3, stats => $stats, abridged => ! $web,
        logH => \*STDERR);
# Process the resume option.
if ($opt->resume) {
    my $found;
    my $count = 0;
    my $lastGenome = $opt->resume;
    print STDERR "Searching for $lastGenome.\n";
    while (! eof $ih && ! $found) {
        my $line = <$ih>;
        my @fields = P3Utils::get_fields($line);
        $count++;
        if ($fields[$keyCol] eq $lastGenome) {
            $found = 1;
        }
    }
    print STDERR "$count lines skipped.\n";
} elsif (! $opt->nohead) {
    # Not resuming. Form the full header set and write it out.
    push @$outHeaders, 'Coarse Consistency', 'Fine Consistency', 'Completeness', 'Contamination', 'Good Seed';
    P3Utils::print_cols($outHeaders);
}
# If an error occurs, we still display stats.
my $lastGenome = "";
eval {
    my $start0 = time;
    my $count0 = 0;
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
        # Loop through the couplets. We will accumulate GTO file names and PATRIC genome IDs in separate lists.
        my (@gtoFiles, %pGenomes);
        for my $couplet (@$couplets) {
            my ($genome, $row) = @$couplet;
            $stats->Add(genomeIn => 1);
            $mainGenomes{$genome} = 1;
            if (defined $gtoCol && $row->[$gtoCol]) {
                push @gtoFiles, $row->[$gtoCol];
            } else {
                $pGenomes{$genome} = 1;
            }
            if (defined $refCol && $row->[$refCol]) {
                my $rGenome = $row->[$refCol];
                $pGenomes{$rGenome} = 1;
                $refGenomes{$rGenome} = $genome;
            }
        }
        # Get the data for the genomes.
        $start = time;
        my $gHash;
        if (@gtoFiles) {
            $gHash = GEO->CreateFromGtoFile(\@gtoFiles, %geoOptions);
            for my $genome (keys %$gHash) {
                $geoMap{$genome} = $gHash->{$genome};
                print STDERR "Target genome $genome queued for evaluation.\n";
            }
        }
        my @pGenomes = sort keys %pGenomes;
        if (scalar @pGenomes) {
            $gHash = GEO->CreateFromPatric(\@pGenomes, %geoOptions);
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
                    my $target = $refGenomes{$genome};
                    my $geo = $geoMap{$target};
                    if ($geo) {
                        $geo->SetRefGenome($refGeo);
                        print STDERR "$genome stored as reference for $target.\n";
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
            # Find out if we have a good seed.
            my $seedFlag = $geo->good_seed;
            if ($seedFlag) {
                $stats->Add(genomeGoodSeed => 1);
            } else {
                $stats->Add(genomeBadSeed => 1);
            }
            # Compute the consistency and completeness.
            my $evalH = $evalG->Check($geo);
            my $complete = Math::Round::nearest(0.1, $evalH->{complete} // 0);
            my $contam = Math::Round::nearest(0.1, $evalH->{contam} // 100);
            my $taxon = $evalH->{taxon} // 'N/F';
            if (! $terse) {
                # Output the check results.
                print $oh "Good Seed: $seedFlag\n";
                print $oh "Completeness: $complete\n";
                print $oh "Contamination: $contam\n";
                print $oh "Group: $taxon\n";
                # Now output the role counts.
                my $roleH = $evalH->{roleData};
                if ($roleH) {
                    for my $role (sort keys %$roleH) {
                        my $count = $roleH->{$role};
                        print $oh "$role\t1\t$count\n";
                    }
                } else {
                    $stats->Add(evalGFailed => 1);
                }
                close $oh;
            }
            $stats->Add(genomeComplete => 1) if GEO::completeX($complete);
            $stats->Add(genomeClean => 1) if GEO::contamX($contam);
            # Store the evaluation results.
            $results{$genome} = [0, 0, $complete, $contam, ($seedFlag ? 'Y' : '')];
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
                        $geo->AddQuality("$outDir/$genome.out", $refGenomes{$genome});
                        # Create the detail page.
                        my $html = BinningReports::Detail(undef, undef, \$detailTT, $geo, $nMap);
                        open(my $wh, ">$outDir/$genome.html") || die "Could not open $genome HTML file: $!";
                        print $wh $prefix . $html . $suffix;
                        close $wh;
                    }
                }
                # Denote this is our last successfully-processed genome.
                $count0++;
                $lastGenome = $genome;
            }
            print STDERR "$count0 genomes processed at " . Math::Round::nearest(0.01, (time - $start0)/$count0) . "seconds/genome.\n";
        }
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
