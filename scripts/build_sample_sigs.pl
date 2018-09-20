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
use KmerDb;
use FastA;
use Stats;
use P3Utils;
use P3DataAPI;

=head1 Create Signature DNA Kmers for Representative Genomes

    build_sample_sigs.pl [ options ] repDir

This script creates a signature kmer database for representative genomes.

=head2 Parameters

The positional parameter is the name of the representative-genome directory.

The command-line options are the following.

=over 4

=item kmer

Kmer size to use, in base pairs. The default is C<23>.

=item maxFound

The maximum number of times a kmer can be found before it is considered common. Common kmers are removed from the hash. The
default is C<10>.

=item indicative

If specified, the kmers will be indicative, rather than signature.  Normally, only kmers unique to a genome will be put in
the database. In indicative mode, all uncommon kmers are kept.

=item reduced

If specified, the kmers will be based solely on the seed proteins. If this is the case, there must be a C<6.1.1.20.dna.fasta>
file in the representative-genomes directory.

=item outFile

The name to give to the output file. The default is I<type>I<scope>C<.>I<KK>C<.json>, where I<type> is C<sig> for signatures
and C<kmer> in B<indicative> mode, I<KK> is the kmer size, and I<scope> is C<Prot> in reduced mode and empty otherwise.

=item subset

If specified, the name of a file containing genome IDs in the first column. Only the genomes in the subset will be used.

=back

=cut

$| = 1;
# Get the command-line parameters.
my $opt = P3Utils::script_opts('repDir',
        ['kmer|K=i', 'kmer size to use', { default => 23 }],
        ['indicative|I', 'indicative instead of signature kmers'],
        ['maxFound|m=i', 'maximum number of occurrences before a kmer is considered common', { default => 10 }],
        ['reduced', 'process the seed proteins only'],
        ['outfile=s', 'name to give to the output file'],
        ['subset=s', 'if specified, the name of a file containing a restricted set of genome IDs']
        );
my $stats = Stats->new();
# Get the representative genome directory.
my ($repDir) = @ARGV;
if (! $repDir) {
    die "No representative genome directory specified.";
} elsif (! -s "$repDir/complete.genomes") {
    die "$repDir does not have a complete.genomes file.";
}
# Get the options.
my $K = $opt->kmer;
my $maxFound = $opt->maxfound;
my $indicMode = $opt->indicative;
my $reduced = $opt->reduced;
print "Kmer size is $K.\n";
# Compute the output file name.
my $outFile = $opt->outfile;
if (! $outFile) {
    $outFile = "$repDir/" . join('.', ($indicMode ? 'kmer' : 'sig') . ($reduced ? 'Prot' : ''), $K, 'json');
}
if ($reduced && ! -s "$repDir/6.1.1.20.dna.fasta") {
    die "$repDir does not have a DNA FASTA file.";
}
# Connect to the database.
my $p3 = P3DataAPI->new();
# Create the kmer database.
my $kmerDb = KmerDb->new(kmerSize => $K, maxFound => $maxFound, mirror => 1);
# Check for the subset file.
my %subset;
my $subFile = $opt->subset;
if ($subFile) {
    open(my $ih, '<', $subFile) || die "Could not open subset file: $!";
    while (! eof $ih) {
        my $line = <$ih>;
        if ($line =~ /(\d+\.\d+)/) {
            $subset{$1} = 1;
        }
    }
}
# Read in the genome IDs and compute the names.
my %genomes;
open(my $gh, "<$repDir/complete.genomes") || die "Could not open complete.genomes: $!";
while (! eof $gh) {
    my $line = <$gh>;
    if ($line =~ /^(\d+\.\d+)\t(.+)/) {
        my ($genome, $name) = ($1, $2);
        if ($subFile && ! $subset{$genome}) {
            $stats->Add(genomeSkipped => 1);
        } else {
            $kmerDb->AddGroup($genome, $name);
            $genomes{$genome} = $name;
            $stats->Add(genomeIn => 1);
        }
    }
}
print "Genome names stored.\n";
close $gh;
# Loop through the DNA sequences.
if ($reduced) {
    # Reduced mode. Read the DNA fasta file.
    my $fh = FastA->new("$repDir/6.1.1.20.dna.fasta");
    while ($fh->next) {
        my $id = $fh->id;
        if ($id =~ /(\d+\.\d+)/) {
            my $genome = $1;
            if ($genomes{$genome}) {
                $kmerDb->AddSequence($genome, $fh->left);
                $stats->Add(sequenceIn => 1);
            }
        }
    }
} else {
    # Full mode: read the DNA sequences.
    for my $genome (sort keys %genomes) {
        my $name = $kmerDb->name($genome);
        print "Processing $genome $name.\n";
        $stats->Add(genomeScanned => 1);
        my $seqs = P3Utils::get_data($p3, contig => [['eq', 'genome_id', $genome]], ['sequence']);
        for my $seq (@$seqs) {
            my $sequence = $seq->[0];
            $kmerDb->AddSequence($genome, $sequence);
            $stats->Add(sequenceIn => 1);
        }
    }
}
# Now we finalize depending on the mode.
if ($indicMode) {
    print "Finalizing indicators.\n";
    $kmerDb->Finalize();
} else {
    print "Finalizing discriminators.\n";
    $kmerDb->ComputeDiscriminators();
}
# Write the output file.
print "Saving database as $outFile.\n";
$kmerDb->Save($outFile);
print "All done.\n" . $stats->Show();
