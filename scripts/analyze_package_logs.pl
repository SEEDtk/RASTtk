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

=head1 Produce Analysis of Package Log Files

    analyze_package_logs.pl [ options ] dir

This script creates a table of the score results found in log files from L<package_cleaned_bins.pl>. The log files must all be in a specified
directory and have a name of the form C<package>I<N>C<.log>, where I<N> is a number. The output report will list the scores for each bin in
tab-delimited format, with an extra column for the I<goodness> (completeness + fine-consistency) and I<quality> (completeness - 5 * contamination).

=head2 Parameters

The single positional parameter is the name of the directory containing the log files.

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('dir',
        );
# Get the input directory.
my ($dir) = @ARGV;
if (! $dir) {
    die "No directory specified.";
} elsif (! -d $dir) {
    die "Directory $dir invalid or missing.";
}
# Find all the package logs.
opendir(my $dh, $dir) || die "Could not open $dir: $!";
my @logs = grep { $_ =~ /^package\d*\.log$/ } readdir $dh;
closedir $dh;
# Loop through them, forming a hash keyed by bin. Each hash entry will contain a sub-hash mapping a package ID to a tuple 
# [completeness, contamination, coarse-consistency, fine-consistency, goodness, quality].
my %bins;
for my $log (@logs) {
    # Compute the file label.
    my $idx = 1;
    if ($log =~ /package(\d+)\.log/) {
        $idx = $1;
    }
    # Loop through the file.
    my $bin;
    open(my $ih, "<$dir/$log") || die "Could not open $log: $!";
    while (! eof $ih) {
        my $line = <$ih>;
        if ($line =~ /^Package is (\d+: [^.]+)/) {
            $bin = $1;
        } elsif ($line =~ /^Old stats are (.+)/) {
            process_stats(\%bins, $bin, 'old', $1);
        } elsif ($line =~ /^New stats are (.+)/) {
            process_stats(\%bins, $bin, $idx, $1);
        }
    }
}
# Now sort and print the hash.
print join("\t", qw(Bin Type Complete Contam Coarse Fine Good Quality)) . "\n";
for my $bin (sort keys %bins) {
    my $scoresH = $bins{$bin};
    for my $type (sort { weird_sort($a, $b) } keys %$scoresH) {
        print join("\t", $bin, $type, @{$scoresH->{$type}}) . "\n";
    }
}

# Process statistics.
sub process_stats {
    my ($binH, $bin, $idx, $line) = @_;
    # Parse out the stats.
    my ($complt, $contam, $coarse, $fine) = $line =~ /(\S+) complete, (\S+) contamination, (\S+) coarse-consistent, (\S+) fine-consistent./;
    # Only proceed if we got a full match.
    if (defined $fine) {
        my $goodness = $complt + $fine;
        my $quality = $complt - 5 * $contam;
        $binH->{$bin}{$idx} = [$complt, $contam, $coarse, $fine, $goodness, $quality];
    }
}

# Sort old values before new.
sub weird_sort {
    my ($a, $b) = @_;
    my $retVal;
    if ($a eq 'old') {
        if ($b eq 'old') {
            $retVal = 0;
        } else {
            $retVal = -1;
        }
    } elsif ($b eq 'old') {
        $retVal = 1;
    } else {
        $retVal = ($a <=> $b);
    }
    return $retVal;
}