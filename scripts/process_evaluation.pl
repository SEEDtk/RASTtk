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

=head1 Compute Score From Evaluation File

    process_evaluation.pl [ options ]

This script takes as input an I<evaluation file>, which is a four-column tab-delimited file, and produces a score from 0 to 100 as output.
The evaluation file contains one record per role, consisting of (0) the role ID, (1) the actual number of occurrences, (2) the predicted
number of occurrences, and (3) the reliability of the prediction (a number from 0 to 1). The score will be the sum of the reliabilities
for the correct predictions divided by the sum of all the reliabilities times 100 (to convert it to a percentage).

=head2 Parameters

The command-line options are those found in L<ScriptUtils/ih_options>, to specify the standard input.

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('', ScriptUtils::ih_options(),
        );
# Open the input file.
my $ih = ScriptUtils::IH($opt->input);
my ($count, $total) = (0, 0);
while (! eof $ih) {
    my $line = <$ih>;
    $line =~ s/[\r\n]+$//;
    if ($line) {
        my ($role, $actual, $predict, $weight) = split /\t/, $line;
        if ($actual == $predict) {
            $count += $weight;
        }
        $total += $weight;
    }
}
my $score = $count * 100 / $total;
printf("%.2f\n", $score);