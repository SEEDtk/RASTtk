#!/usr/bin/env perl -w
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

=head1 Create a GenomeTypeObject from a SEED Genome

   fetch_seed_gto -s seed-to-get-it-from -g genome_ID > gto.file
   fetch_seed_gto -s seed-to-get-it-from -g genome_ID -o outfile

This script uses the C<genome_object> web service of the specified SEED to load a L<GenomeTypeObject>
into memory. Because a web service is used, it does not need local machine access to the SEED in question.

=cut

use strict;
use warnings;
use SeedURLs;
use ScriptUtils;
use LWP::Simple;
use Data::Dumper;

# Get the command-line parameters.

my $seeds = SeedURLs::names();

my $opt = ScriptUtils::Opts(
    '',
    [ 'genome|g=s', 'ID of the genome',                       { required => 1 } ],
    [ 'output|o=s', 'output file name',                                         ],
    [ 'seed|s=s',   "name of a SEED ($seeds), or a SEED URL", { required => 1 } ]
);

my $genome  = $opt->genome;
my $outfile = $opt->output;
my $seed    = $opt->seed;

my $where = SeedURLs::url( $seed );
if ( $where )
{
    # Get the JSON text from the SEED:

    my $ref_text = LWP::Simple::get( "$where/genome_object.cgi?genome=$genome" );
    if ( $ref_text )
    {
        my $fh = \*STDOUT;
        if ( $outfile )
        {
            open( $fh, '>', $outfile ) || die "Failed to open '$outfile' for writing.\n";
        }

        print $fh $ref_text, "\n";
    }
    else
    {
        print STDERR "Nothing returned from '$seed' SEED for genome '$genome'.\n";
    }
}
else
{
    print STDERR "Unknown SEED '$seed'.\n",
                 "Valid SEED names include: $seeds.\n",
                 "A URL starting with 'http://' also works.\n\n";
}

