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

The standard input is three columns.  The first column should contain reference genome IDs, the second the number of
seed protein hits, and the third should contain the reference genome names.

=head2 Parameters

The positional parameters are the name of a working directory followed by the names of the incoming FASTQ files.
A single file is treated as interlaced. A pair of files is treated as paired-end.  If a third file is specified,
it should contain singletons.

The standard input can be overridden using the options in L<P3Utils/ih_options>.

=over 4

=item refMaxE

Maximum e-value for a successful match.  The default is C<1e-10>.

=item minlen

Minimum length (in base pairs) for a successful match.  The default is C<80>.

=item batchSize

Batch size for BLAST calls. The default is C<4000>.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use Stats;
use ReadBlaster;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('workDir file1 file2 file3', P3Utils::ih_options(),
                ['refMaxE=f', 'maximum acceptable e-value for reference genome blast hits', { default => 1e-10 }],
                ['minlen|l=i', 'minimum acceptable match length', { default => 80 }],
                ['batchSize|b=i', 'BLAST batch size', { default => 4000 }],
    );
my $stats = Stats->new();
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Validate the FASTQ file names.
my ($file1, $file2, $file3) = @ARGV;
if (! $file1) {
    die "No FASTQ files specified.";
} else {
    for my $file ($file1, $file2, $file2) {
        if ($file && ! -s $file) {
            die "FASTQ input file $file not found or invalid.";
        }
    }
}
# Get the options.
my $refMaxE = $opt->refmaxe;
my $minlen = $opt->minlen;
my $batchSize = $opt->batchsize;
# Open the input file.
my $ih = P3Utils::ih($opt);
# Skip the header line.
my $line = <$ih>;
# Read in the list of reference genomes.
print "Reading reference genomes.\n";
my %refGenomeHits;
my %refGenomeNames;
while (! eof $ih) {
    my ($genome, $hits, $name) = P3Utils::get_fields($ih);
    $refGenomeNames{$genome} = $name;
    $refGenomeHits{$genome} = $hits;
}
my @refIds = keys %refGenomeHits;
my $refCount = scalar @refIds;
print "$refCount reference genomes read.\n";
# Read the taxonomy-related data for each genome and pick the best strain of each species.
my %refBest;
my $gData = P3Utils::get_data_keyed($p3, genome => [], ['genome_id', 'species'], \@refIds);
for my $gDatum (@$gData) {
    my ($genome, $species) = @$gDatum;
    my $refBest = $refBest{$species};
    if (! $refBest) {
        $refBest{$species} = $genome;
    } elsif ($refGenomeHits{$refBest} < $refGenomeHits{$genome}) {
        $refBest{$species} = $genome;
    }
}
@refIds = sort { $refGenomeHits{$b} <=> $refGenomeHits{$a} } values %refBest;
$refCount = scalar @refIds;
print "$refCount species found.\n";
for my $refId (@refIds) {
    print "Using $refId ($refGenomeHits{$refId} hits) $refGenomeNames{$refId}.\n";
}
# Create the BLAST database from the contig sequences.

## TODO process stuff
