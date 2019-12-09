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

=head1 Bin Reads Using PATRIC Reference Genomes

    p3x-bin-fastq.pl [options] file1 file2 file3

This script uses the output of L<p3x-find-fastq-phes.pl> to sort reads into bins.  The script will build a BLAST
database out of the reference genomes found by the aforementioned script, then BLAST reads against it in batches.
For each read, its longest match will be used to place it into a bin.  Each bin will be output as a tripled FASTQ
file (pair1, pair2, singleton).

The standard input is three columns.  The first column should contain reference genome IDs and the third should
contain the reference genome names.

=head2 Parameters

The positional parameters are the names of the incoming FASTQ files. A single file is treated as interlaced.
A pair of files is treated as paired-end.  If a third file is specified, it should contain singletons.

The standard input can be overridden using the options in L<P3Utils/ih_options>.


=cut

use strict;
use P3DataAPI;
use P3Utils;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('file1 file2 file3', P3Utils::ih_options(),
    ## TODO more options
    );

# Get access to PATRIC.
my $p3 = P3DataAPI->new();
## TODO process stuff