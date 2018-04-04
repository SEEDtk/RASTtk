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

The command-line options are those found in L<ScriptUtils/ih_options> (to select the input).

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('', ScriptUtils::ih_options(),
        );
my $stats = Stats->new();
# Create the IC50 object.
my $ic50 = IC50->new();
# Open the input file.
my $ih = ScriptUtils::IH($opt->input);
# This is a three-level hash. The primary key is drug names. For each drug name, there will be one sub-hash per cell line.
# For each drug/cell-line pair there will be a hash mapping dosages to shrinkage rates. This last hash is passed to the IC50
# engine.
my %drugs;
print STDERR "Gathering input.\n";
# Skip the header.
my $line = <$ih>;
# Loop through the data.
while (! eof $ih) {
    my ($drug, $cl, undef, $conc, undef, $growth) = ScriptUtils::get_line($ih);
    $stats->Add(lineIn => 1);
    # Note we negate the growth. Our data file is the opposite of the one used to write the IC50 module.
    $drugs{$drug}{$cl}{$conc} = -$growth;
}
# Now we produce the output.
print join("\t", qw(Drug Cell-Line IC50 Min Max Bad)) . "\n";
# Loop through the drug / line pairs.
for my $drug (sort keys %drugs) {
    my $lineH = $drugs{$drug};
    $stats->Add(drug => 1);
    for my $cl (sort keys %$lineH) {
        my $dataHash = $lineH->{$cl};
        $stats->Add(pairs => 1);
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
            if ($mid < $min || $mid > $max) {
                $stats->Add(iffyPairs => 1);
                $bad = '*';
            } else {
                $stats->Add(goodPairs => 1);
            }
            print join("\t", $drug, $cl, $mid, $min, $max, $bad) . "\n";
            $stats->Add(lineOut => 1);
        }
    }
}
print STDERR "All done.\n" . $stats->Show();

