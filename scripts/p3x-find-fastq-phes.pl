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

=head1 Find Seed Proteins in a FASTQ Sample

    p3x-find-fastq-phes.pl [options] file1 file2 file3

This script will read FASTQ data and BLAST it against a PheS DNA database to identify the organisms found therein.  The output will be the genome ID
and name of each organism found, which can then be used as reference genomes for binning.

The basic strategy is to batch up the sequences and blast each batch.  A match over a sufficient length of the incoming read and having a low enough
e-value against a sequence of sufficient quality is considered a hit.

=head2 Parameters

The positional parameters are the names of the FASTQ files.  A single file is presumed to be interlaced.  Two files
are presumed to be paired-end reads.  If three files are specified, the first two are paired and the third is
singletons.

The command-line options are as follows.

=over 4

=item seedfasta

The name of the BLAST database for the seed protein in the various PATRIC genomes. The default is
C<PhenTrnaSyntAlph.fa> in the global data directory.

=item refMaxE

The maximum acceptable E-value for blasting. The default is C<1e-10>.

=item minlen

The minimum length for a BLAST hit. A BLAST hit that matches less than this number of positions in a read
will  be discarded.  The default is C<80>.

=item minqual

The minimum mean quality for a read to be considered eligible for BLASTing.  The default is C<0.50>.

=item old_illumina

If specified, then the FASTQ file was produced by an older version of Illumina so the quality strings
use a different format.

=item batchSize

Batch size for BLAST calls. The default is C<4000>.

=item minHits

The minimum number of hits for a matched sequence to be output.  The default is C<60>.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use FastQ;
use ReadBlaster;
use Stats;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('file1 file2 file3',
                ['seedfasta|F=s', 'BLAST database (or FASTA file) of seed protein in all genomes', { default => "$FIG_Config::p3data/PhenTrnaSyntAlph.fa"}],
                ['refMaxE=f', 'maximum acceptable e-value for reference genome blast hits', { default => 1e-10 }],
                ['minlen|l=i', 'minimum acceptable match length', { default => 80 }],
                ['minqual|q=i', 'minimum acceptable read quality', { default => 0.50 }],
                ['old_illumina', 'TRUE if the quality strings are in old Illumina format'],
                ['batchSize|b=i', 'BLAST batch size', { default => 4000 }],
                ['minHits|m=i', 'minimum number of hits for an acceptable match', { default => 60 }]
        );
my $stats = Stats->new();
# Create the ReadBlaster.
print STDERR "Connecting to BLAST database.\n";
my $readBlaster = ReadBlaster->new($opt->seedfasta, maxE => $opt->refmaxe, minlen => $opt->minlen,
        minqual => $opt->minqual, batchSize => $opt->batchsize,
        stats => $stats);
# Set up the options hash for FASTQ;
my $fqOpt = { old_illumina => $opt->old_illumina, unsafe => 1, singleton => 1 };
my $minHits = $opt->minhits;
# Loop through the FASTQ files.
my @files = @ARGV;
my $mapping = {};
for my $file (@files) {
    print "Processing $file.\n";
    # Blast the FastQ file.
    my $fq = FastQ->new($file, $fqOpt);
    $readBlaster->BlastSample($fq, $mapping);
}
# Count the hits.
my %gNames;
my %gHits;
for my $queryID (keys %$mapping) {
    my (undef, undef, $label) = @{$mapping->{$queryID}};
    my ($genome, $name) = split /\t/, $label;
    $gNames{$genome} = $name;
    $gHits{$genome}++;
}
# Now write the output.
my @genomes = sort { $gHits{$b} <=> $gHits{$a} } grep { $gHits{$_} >= $minHits } keys %gHits;
P3Utils::print_cols([qw(genome_id hits genome_name)]);
for my $genome (@genomes) {
    P3Utils::print_cols([$genome, $gHits{$genome}, $gNames{$genome}]);
}
print STDERR "All done.\n" . $stats->Show();
