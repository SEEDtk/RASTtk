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
use ScriptUtils;
use FastQ;

=head1 Convert FASTQ to FASTA

    fq_to_fa.pl [ options ] file1 file2 ... fileN

This script converts paired-end FASTQ files to a FASTA format. All the quality information will be lost. It operates on both paired and
interlaced files. So, for example, if the files are paired, the command would look something like


    fq_to_fa SRR05102_1.fq SRR05102_2.fq SRR05103_1.fq SRR05103_2.fq SRR05104_1.fq SRR05104_2.fq

with an even number of files, each right-end file specified after its left-end counterpart. If the files are interlaced, then each file
contains both the left and right sequences, so the files are specified singly.

    fq_to_fa --interlaced SRR05102.fq SRR05103.fq SRR05104.fq

The FASTA file will be produced on the standard output.

=head2 Parameters

The positional parameters are the names of the input FASTQ files. If the files are paired, they must be input
in the order

    left1 right1 left2 right2 ... leftN rightN

The command-line options are as follows:

=over 4

=item interlaced

If specified, the files are treated as interlaced instead of paired.

=back

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('file1 file2 .. fileN',
        ['interlaced|inter|i', 'files are in interlaced format']
        );
# Get the file pairs.
my @files;
if ($opt->interlaced) {
    @files = map { [$_] } @ARGV;
} else {
    my $n = scalar @ARGV;
    if ($n & 1) {
        die "Odd number of files specified in paired mode.";
    }
    for (my $i = 0; $i < $n; $i += 2) {
        push @files, [$ARGV[$i], $ARGV[$i+1]];
    }
}
# Now each element of @files contains all the parameters for the FastQ object invocation.
# Loop through the list.
for my $filePair (@files) {
    my $fqh = FastQ->new(@$filePair);
    # Read through this file set.
    while ($fqh->next) {
        $fqh->Echo(\*STDOUT);
    }
}
