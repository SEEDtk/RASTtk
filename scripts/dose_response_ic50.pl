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
use IC50;

=head1 Compute IC50 From Dose-Response File

    dose_response_ic50.pl [ options ]

This script takes as input a dose-response file (such as produced by L<dose_response_extract.pl>) and outputs
estimated IC50 results for each drug / cell line combination.

The input file is tab-delimited with headers, each line containing (0) a drug name, (1) a cell line name, (2) a
concentration unit, (3) the log concentration, (4) the data source, and (5) the growth rate. The output
file is also tab-delimited with headers, and each lien will contain (0) a drug name, (1) a cell line name,
(2) an IC50 estimate, (3) the min dosage tested, (4) the max dosage tested, and (5) a C<*> if the estimate is
outside the bounds of the dosages tested.

Progress messages are written to the standard error output, which should be kept separate from the standard output.

=head2 Parameters

There are no positional parameters.

The command-line options are those found in L<ScriptUtils/ih_options> (to select the input) plus the following.

=over 4

=item negative

Use -50 as the target growth instead of 50.

=item stats

Produce a statistics file indicating how many drug, cell-line, and drug/cell-line pairs there are for each source
and each combination of sources.  The value of this option is the name to give the file.

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('', ScriptUtils::ih_options(),
        ['negative', 'use -50 as the target growth'],
        ['stats=s', 'name of a statistics output file']
        );
my $stats = Stats->new();
# Create the IC50 object.
my $negative = $opt->negative // 0;
my $ic50 = IC50->new(negative => $negative);
# Open the input file.
my $ih = ScriptUtils::IH($opt->input);
# This is a four-level hash. The primary key is data sources, then drug names, cell lines, and concentrations.
my %sources;
print STDERR "Gathering input.\n";
# Skip the header.
my $line = <$ih>;
# Loop through the data.
while (! eof $ih) {
    my ($drug, $cl, undef, $conc, $source, $growth) = ScriptUtils::get_line($ih);
    $stats->Add(lineIn => 1);
    $sources{$source}{$drug}{$cl}{$conc} = $growth;
}
# These hashes track the existence of combinations.  For each hash the main key is a source ID and the secondary key is
# a drug, cell-line, or pair name.
my (%drugH, %cellLineH, %pairH);
# Now we produce the output.
print STDERR "Producing output.\n";
print join("\t", qw(Source Drug Cell-Line IC50 Min Max Bad)) . "\n";
# Loop through the sources.
for my $source (sort keys %sources) {
    $stats->Add(source => 1);
    my $drugs = $sources{$source};
    # Loop through the drug / line pairs.
    for my $drug (sort keys %$drugs) {
        my $lineH = $drugs->{$drug};
        $drugH{$source}{$drug} = 1;
        for my $cl (sort keys %$lineH) {
            my $dataHash = $lineH->{$cl};
            $stats->Add(pairs => 1);
            $stats->Add("$source-pairs" => 1);
            $cellLineH{$source}{$cl} = 1;
            $pairH{$source}{"$drug\t$cl"} = 1;
            # Analyze the dosages.
            my @dosages = sort { $a <=> $b } keys %$dataHash;
            if (@dosages < 3) {
                print STDERR "Too few dosages to compute a value for $drug and $cl.\n";
                $stats->Add(badPairs => 1);
            } else {
                my $min = shift @dosages;
                my $max = pop @dosages;
                my $mid = $ic50->compute($dataHash);
                my $bad = '';
                if (! defined $mid) {
                    $stats->Add(badPairs => 1);
                } else {
                    $stats->Add(usefulPairs => 1);
                    if ($mid < $min || $mid > $max) {
                        $stats->Add(iffyPairs => 1);
                        $bad = '*';
                    } else {
                        $stats->Add(goodPairs => 1);
                    }
                    print join("\t", $source, $drug, $cl, $mid, $min, $max, $bad) . "\n";
                    $stats->Add(lineOut => 1);
                }
            }
        }
    }
}
if ($opt->stats) {
    print STDERR "Processing statistics.\n";
    open(my $oh, '>', $opt->stats) || die "Could not open stats file: $!";
    CountCombos($oh, 'Drugs', \%drugH);
    CountCombos($oh, 'Cell Lines', \%cellLineH);
    CountCombos($oh, 'Pairs', \%pairH);
    print $oh $stats->Show();
    close $oh;
}
print STDERR "All done.\n" . $stats->Show();

sub CountCombos {
    my ($oh, $type, $hash) = @_;
    print $oh "Source Database Counts for $type\n\n";
    print $oh "Sources\tCount\n";
    my @sources = sort keys %$hash;
    while (my $source = shift @sources) {
        my $memberH = $hash->{$source};
        my $count = scalar(keys %$memberH);
        print $oh "$source\t$count\n";
        for my $source2 (@sources) {
            my $m2H = $hash->{$source2};
            my $common = scalar grep { $m2H->{$_} } keys %$memberH;
            print $oh "$source,$source2\t$common\n";
        }
    }
    print $oh "\n\n";
}
