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

=head1 Compare IC50s From Different Sources

    ic50_compare.pl [ options ]

This script takes as input the file produced by L<dose_response_ic50.pl> and outputs a comparison of IC50 results for the same
drug / cell line combination from different sources.

=head2 Parameters

There are no positional parameters.

The standard input is taken from L<ScriptUtils/ih_options>. Output is tab-delimited with headers to the standard output.

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('', ScriptUtils::ih_options(),
        );
# Open the input file.
my $ih = ScriptUtils::IH($opt->input);
# This is a 3-level hash-- drug, cell-line, source.
my %ic50;
# This tracks the total of all the distances.
my $totErr = 0;
# This tracks the number of distances.
my $numErr = 0;
# This tracks the number of inputs.
my $lineIn = 0;
# This tracks the error by 0.5 brackets.
my %cats;
# Skip the header line.
my $line = <$ih>;
# Write the output header.
print join("\t", qw(drug cell-line source1 source2 err cat)) . "\n";
# Loop through the input file.
while (! eof $ih) {
    my ($source, $drug, $cl, $ic50) = ScriptUtils::get_line($ih);
    $lineIn++;
    # Get any previous results for this pair.
    my $prevH = $ic50{$drug}{$cl};
    if ($prevH) {
        # Here we found previous results.
        for my $source2 (sort keys %$prevH) {
            my $ic50_2 = $prevH->{$source2};
            my $err = abs($ic50 - $ic50_2);
            my $cat = int($err * 2);
            print join("\t", $drug, $cl, $source, $source2, $err, $cat) . "\n";
            $totErr += $err;
            $numErr++;
            $cats{$cat}++;
        }
    }
    # Store this result.
    $ic50{$drug}{$cl}{$source} = $ic50;
}
my $meanErr = $totErr / $numErr;
print STDERR "All done. Average = $meanErr. $lineIn in, $numErr out.\n";
