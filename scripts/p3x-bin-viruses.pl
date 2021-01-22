#!/usr/bin/env perl
#
# Copyright (c) 2003-2015 University of Chicago and Fellowship
# for Interpretations of Genomes. All Rights Reserved.
#
# This file is part of the SEED Toolkit.
#
# The SEED Toolkit is free software. You can redistribute
# it and/or modify it under the terms of the SEED Toolkit
# Public License.
#
# You should have received a copy of the SEED Toolkit Public License
# along with this program; if not write to the University of Chicago
# at info@ci.uchicago.edu or the Fellowship for Interpretation of
# Genomes at veronika@thefig.info or download a copy from
# http://www.theseed.org/LICENSE.TXT.
#

=head1 Run Through a Sample Directory Binning Viruses

    p3x-bin-viruses.pl [options] binDir1 binDir2 ...

This program runs through a sample directory binning viruses.  It looks for the C<Eval/index.tbl> file to determine
whether a directory has been binned.  If this is found and there is no C<checkv/completeness.tsv> file, it runs
the B<checkv> command.  If there is no C<vbins.tsv> file it runs the CVUtils program to process the CheckV results
into bins.

=head2 Parameters

The positional parameters are the names of the binning directories.  If a directory contains a C<site.tbl> it is
processed as a single sample, otherwise the subdirectories are scanned for samples.

Additional command-line options are the following.

=over 4

=item db

The name of the CheckV database directory.  The default is C<checkv_db> in the SEEDtk data directory.

=item test

If specified, the program will stop on the first error.

=back

=cut

use strict;
use FIG_Config;
use P3Utils;
use CVUtils;
use Stats;

$| = 1;
my $stats = Stats->new();
# Get the command-line options.
my $opt = P3Utils::script_opts('binDir1 binDir2 ...',
    ['db=s', 'checkv database directory', { default => "$FIG_Config::data/checkv_db" }],
    ['test', 'if specified, the program will stop on the first error']
    );
# Get the checkv database directory.
my $checkVdb = $opt->db;
# Get the input directories.
my @binDirs;
for my $binDir (@ARGV) {
    if (-s "$binDir/site.tbl") {
        if (! -s "$binDir/Eval/index.tbl") {
            print "WARNING: $binDir is not completed.\n";
            $stats->Add(dirSkipped => 1);
        } else {
            push @binDirs, $binDir;
            $stats->Add(samples => 1);
        }
    } else {
        if (! opendir(my $dh, $binDir)) {
            print "WARNING: Could not open input directory $binDir: $!\n";
            $stats->Add(dirSkipped => 1);
        } else {
            my @dirs = grep { -s "$binDir/$_/Eval/index.tbl" } readdir $dh;
            closedir $dh;
            print scalar(@dirs) . " completed samples found in $binDir.\n";
            push @binDirs, map { "$binDir/$_" } @dirs;
            $stats->Add(samples => scalar @dirs);
        }
    }
}
# Loop through the directories, processing.
my $tot = scalar @binDirs;
my $count = 0;
for my $binDir (sort @binDirs) {
    $count++;
    print "Processing sample $count of $tot: $binDir.\n";
    my $rc = 0;
    if (! -s "$binDir/checkv/completeness.tsv") {
        # Here we need to run checkv.
        my @parms = ('checkv', 'completeness', "$binDir/unbinned.fasta", "$binDir/checkv");
        my $cmd = join(" ", @parms);
        print "Running: $cmd\n";
        $rc = system($cmd);
        $stats->Add(checkvRuns => 1);
        if ($rc && $opt->test) {
            die "Error in CheckV (rc = $rc).\n";
        }
    }
    if (! -s "$binDir/vbins.tsv" && $rc == 0) {
        # Now we must process the checkv output.
        print "Processing checkV output for $binDir.\n";
        $stats->Add(outputRuns => 1);
        my $checkv = CVUtils->new($checkVdb, $binDir, $binDir, logH => \*STDOUT, stats => $stats);
        $checkv->CreateBins();
    }
}
print "All done.\n" . $stats->Show();
