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

=head1 Next-Generation RAST pipeline

    RASTng_pipeline.pl [options] fastaFile workDir

This script takes a FASTA file as input and produces a fully-annotated L<GenomeTypeObject> file.  It works as a pipeline, creating a skeleton GTO
in the first step and then performing transformations using scripts listed in the COMMANDS constant.  Each command takes a GTO as standard input
and produces one on the standard output.  All of these scripts load the input at the beginning and write the output at the end.  All of them
support at C<--input> option to specify the input file, an C<--output> option to specify the output file, and a C<--verbose> option for status
output to STDERR.  Clearing the working directory is not allowed.

=head2 COMMANDS

The COMMANDS constant contains a list of the commands to be executed.  The string C<${workDir}> can be used to represent the working directory
name.  Options to this script are represented by C<${>I<optionName>C<}>.

=head2 Parameters

The positional parameters are ##TODO positionals

The standard input can be overridden using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/data_options> and L<P3Utils/col_options> plus the following.

=over 4

=item fields

List the available field names.

##TODO additional options

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('fastaFile workDir',
    ['fields|f', 'Show available fields']);

# Get access to PATRIC.
my $p3 = P3DataAPI->new();
my $fields = ($opt->fields ? 1 : 0);
if ($fields) {
    my $fieldList = P3Utils::list_object_fields($p3, 'object');
    print join("\n", @$fieldList, "");
    exit();
}
# Compute the output columns.
my ($selectList, $newHeaders) = P3Utils::select_clause($p3, object => $opt);
# Compute the filter.
my $filterList = P3Utils::form_filter($opt);
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Form the full header set and write it out.
if (! $opt->nohead) {
    push @$outHeaders, @$newHeaders;
    P3Utils::print_cols($outHeaders);
}
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    ##TODO process the input to produce the output
    # Get the output rows for these input couplets.
    my $resultList = P3Utils::get_data_batch($p3, object => $filterList, $selectList, $couplets);
    # Print them.
    for my $result (@$resultList) {
        P3Utils::print_cols($result, opt => $opt);
    }
}
