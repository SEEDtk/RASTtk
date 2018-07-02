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

The directory containing the completeness-checker input files (see L<GtoChecker> for details). The default is
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

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use BinningReports;
use EvalCon;
use GtoChecker;
use File::Copy::Recursive;
use GPUtils;
use Math::Round;


# Get the command-line options.
my $opt = P3Utils::script_opts('workDir outDir', P3Utils::col_options(), P3Utils::ih_options(), EvalCon::role_options(),
        ['checkDir=s', 'completeness checker configuration files', { default => "$FIG_Config::global/CheckG" }],
        ['clear', 'clear output directory before starting'],
        ['web', 'create web pages as well as output files for evaluations'],
        ['gtoCol=s', 'index (1-based) or name of column containing GTO file names'],
        ['templates=s', 'name of the directory containing the binning templates',
                { default => "$FIG_Config::mod_base/RASTtk/lib/BinningReports" }],
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
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Form the full header set and write it out.
if (! $opt->nohead) {
    push @$outHeaders, 'Coarse Consistency', 'Fine Consistency', 'Completeness', 'Contamination', 'Good Seed';
    P3Utils::print_cols($outHeaders);
}
# Compute the GTO file column.
my $gtoCol = $opt->gtocol;
if (defined $gtoCol) {
    print STDERR "GTO file names will be taken from column $gtoCol.\n";
    $gtoCol = P3Utils::find_column($gtoCol, $outHeaders);
}
# Get the web options.
my $web = $opt->web;
my $templateDir = $opt->templates;
my $detailTT = "$templateDir/details.tt";
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
        print STDERR "Installing web page styles in $outDir.\n";
        File::Copy::Recursive::fcopy("$templateDir/packages.css", $outDir) || die "Could not copy style file: $!";
    }
}
# Create the consistency helper.
my $evalCon = EvalCon->new_from_script($opt);
# Get access to the statistics object.
my $stats = $evalCon->stats;
# Create the completeness helper.
my ($nMap, $cMap) = $evalCon->roleHashes;
my $evalG = GtoChecker->new($opt->checkdir, roleHashes=> [$nMap, $cMap], logH => \*STDERR, stats => $stats);
# Loop through the input.
while (! eof $ih) {
    # Get this batch of input.
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    # Start the predictor matrix for the consistency checker.
    $evalCon->OpenMatrix($workDir);
    # This will hold the GTOs built.
    my %gtos;
    # This will hold results for the output. It will map genome IDs to [coarse, fine, complete, contam, goodSeed];
    my %results;
    for my $couplet (@$couplets) {
        my ($genome, $row) = @$couplet;
        $stats->Add(genomeIn => 1);
        print STDERR "Processing $genome.\n";
        my $gto;
        if (defined $gtoCol && $row->[$gtoCol]) {
            $gto = GenomeTypeObject->create_from_file($row->[$gtoCol]);
            if (! $gto) {
                print STDERR "Genome $genome not found in file $row->[$gtoCol].\n";
                $stats->Add(genomeBadFile => 1);
            }
        } else {
            $gto = $p3->gto_of($genome, eval => 1);
            if (! $gto) {
                print STDERR "Genome $genome not found in PATRIC.\n";
                $stats->Add(genomeNotFound => 1);
            }
        }
        if ($gto) {
            # We have the genome. Start the output file.
            my $outFile = "$outDir/$genome.out";
            open(my $oh, ">$outFile") || die "Could not open $outFile: $!";
            # Find out if we have a good seed.
            my $seedFlag = GPUtils::good_seed($gto);
            print $oh "Good Seed: $seedFlag\n";
            if ($seedFlag) {
                $stats->Add(genomeGoodSeed => 1);
            } else {
                $stats->Add(genomeBadSeed => 1);
            }
            # Compute the consistency and completeness.
            my $evalH = $evalG->Check($gto);
            my $complete = Math::Round::nearest(0.1, $evalH->{complete} // 0);
            my $contam = Math::Round::nearest(0.1, $evalH->{contam} // 100);
            my $taxon = $evalH->{taxon} // 'N/F';
            print $oh "Completeness: $complete\n";
            print $oh "Contamination: $contam\n";
            print $oh "Group: $taxon\n";
            $stats->Add(genomeComplete => 1) if GtoChecker::completeX($complete);
            $stats->Add(genomeClean => 1) if GtoChecker::contamX($contam);
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
            # Store the evaluation results.
            $results{$genome} = [0, 0, $complete, $contam, ($seedFlag ? 'Y' : '')];
            # Add this genome to the evalCon matrix.
            $evalCon->AddGtoToMatrix($gto);
            # If we are building a web page, we need to keep the GTO.
            if ($web) {
                $gtos{$genome} = $gto;
            }
        }
    }
    # Now evaluate the batch for consistency.
    $evalCon->CloseMatrix();
    if (! keys %results) {
        print STDERR "No genomes found in batch-- skipping.\n";
    } else {
        my $rc = system('eval_matrix', $evalCon->predictors, $workDir, $outDir);
        if ($rc) {
            die "EvalCon returned error code $rc.";
        }
        $stats->Add(evalConRun => 1);
        # Read back the results to get the consistencies.
        open(my $sh, "<$workDir/summary.out") || die "Could not open evalCon summary file: $!";
        while (! eof $sh) {
            my $line = <$sh>;
            my ($genome, $coarse, $fine) = P3Utils::get_fields($line);
            $results{$genome}[0] = $coarse;
            $results{$genome}[1] = $fine;
            if (GtoChecker::consistX($fine)) {
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
                    my $gto = $gtos{$genome};
                    # Store the quality metrics in the GTO.
                    BinningReports::UpdateGTO($gto, "$outDir/$genome.out", $cMap);
                    # Create the detail page.
                    my $html = BinningReports::Detail(undef, undef, $detailTT, $gto, $nMap);
                    open(my $wh, ">$outDir/$genome.html") || die "Could not open $genome HTML file: $!";
                    print $wh $html;
                    close $wh;
                }
            }
        }
    }
}
# All done. Dump the stats.
print STDERR "All done.\n" . $stats->Show();