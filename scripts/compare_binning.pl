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


use strict;
use warnings;
use FIG_Config;
use ScriptUtils;
use Stats;
##TODO more use clauses

=head1 Compare Binning Runs

    compare_binning.pl [ options ] binDir1 binDir2

This script will compare two different binning runs in two different binning directories.  Each binning job is in its own sub-directory with
the result analysis in a further subdirectory named C<Eval>.  Inside C<Eval>, the C<index.tbl> file records each bin and whether it is good or
bad.  If the binning job failed, the file will simply contain the string C<No bins found>.

The output will list the corresponding bin counts side by side with a column for differences.  Binning jobs that failed in one case and not the
other will be highlighted in messages on STDERR.

=head2 Parameters

The positional parameters are the names of the binning directories.

The command-line options are the following

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('binDir1 binDir2',
        );
# Create a statistics object.
my $stats = Stats->new();
# Get the binning directories.
my ($binDir1, $binDir2) = @ARGV;
if (! $binDir1) {
    die "No binning directories specified.";
} elsif (! $binDir2) {
    die "Only one binning directory specified.";
} elsif (! -d $binDir1) {
    die "$binDir1 is not a valid directory.";
} elsif (! -d $binDir2) {
    die "$binDir2 is not a valid directory.";
}
# Write the output headers.
print "Sample Name\t${binDir1}_good\t${binDir2}_good\tgood_diff\t${binDir1}_total\t${binDir2}_total\ttotal_diff\n";
# This will hold the messages for the failure mismatches.
my @failures;
# Loop through the bindir1 samples.
opendir(my $dh, $binDir1) || die "Could not open $binDir1: $!";
my @samples = grep { -s "$binDir1/$_/Eval/index.tbl" } readdir $dh;
closedir $dh;
# Loop through all the bins in the first directory.
for my $sample (sort @samples) {
    $stats->Add(sampleIn => 1);
    # Count the binDir1 bins.
    my ($good1, $total1) = countBins($binDir1, $sample);
    # Count the binDir2 bins.
    my ($good2, $total2) = countBins($binDir2, $sample);
    # Do the comparison.
    if ($total1 == 0 && $total2 > 0) {
        push @failures, "$binDir1 failed for $sample but $binDir2 did not.\n";
    } elsif ($total1 > 0 && $total2 == 0) {
        push @failures, "$binDir2 failed for $sample but $binDir1 did not.\n";
    }
    my $goodDiff = $good1 - $good2;
    my $totDiff = $total1 - $total2;
    if ($goodDiff > 0) {
        $stats->Add("better-$binDir1" => 1);
    } elsif ($goodDiff < 0) {
        $stats->Add("better-$binDir2" => 1);
    }
    if ($totDiff > 0) {
        $stats->Add("bigger-$binDir1" => 1);
    } elsif ($totDiff < 0) {
        $stats->Add("bigger-$binDir2" => 1);
    }
    print "$sample\t$good1\t$good2\t$goodDiff\t$total1\t$total2\t$totDiff\n";
}
# Spool out the failure messages.
print STDERR @failures;
print STDERR "All done.\n" . $stats->Show();

## Count the bins for a sample in a directory.
sub countBins {
    my ($binDir, $sample) = @_;
    open(my $ih, '<', "$binDir/$sample/Eval/index.tbl") || die "Could not open $sample/Eval/index.tbl in $binDir: $!";
    # Skip the header line.
    my $line = <$ih>;
    my ($good, $total) = (0, 0);
    # A good bin has a "1" in the last column.
    while (! eof $ih) {
        my $line = <$ih>;
        if ($line =~ /\t1$/) {
            $good++;
            $stats->Add("good-$binDir" => 1);
        }
        $total++;
        $stats->Add("total-$binDir" => 1);
    }
    $stats->Add("sample-$binDir" => 1);
    if ($total == 0) {
        $stats->Add("fail-$binDir" => 1);
    } elsif ($good == 0) {
        $stats->Add("bad-$binDir" => 1);
    }
    return ($good, $total);
}
