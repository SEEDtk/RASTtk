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

=head1 Close-Genome Annotation

    Close_Anno.pl [options] workDir

This is a script for performing close-genome annotation.  It takes as input a L<GenomeTypeObject> with just
the contigs.  It produces as output a GTO with protein annotations, the genetic code, and a close-genome
list included.  A dummy genome ID and a possible name will be inserted.  These should be replaced at a later step,
but doing so will require renaming all the features.

Each close genome's proteins will be blasted against the target genome FASTA file using the specified genetic code.
The best match for any ORF will be output.

=head2 Parameters

The positional parameter is the name of a working directory for temporary files.

The command-line options are those in L<P3Utils/ih_options> and L<P3Utils/oh_options> plus the following.

=over 4

=item verbose

Write progress messages to STDERR.

=item maxE

The maximum acceptable E-value for a BLAST hit.  The default is C<1e-40>.

=item minlen

The minimum fraction of the query length that must be found in the target genome.  The default is C<0.90>, indicating 90% of the length.

=item maxHits

The maximum number of BLAST hits to return for each query sequence.  The default is C<5>.

=item repDb

Representative-genome database.  This contains the seed proteins for all the possible reference genomes along with other useful information.
The default is C<repFinder.db> in the SEEDtk global directory.

=item minSim

Minimum acceptable kmer similarity for an acceptable close genome. The default is C<100>.

=item internal

If specified, the script is being called internally and the target FASTA file already exists on disk.

=item

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use Stats;
use CloseAnno;
use File::Copy::Recursive;
use GenomeTypeObject;

$| = 1;
my $start = time;
# Get the command-line options.
my $opt = P3Utils::script_opts('workDir', P3Utils::ih_options(), P3Utils::oh_options(),
        ["verbose|debug|v", "display progress on STDERR"],
        ["minlen|min|m=f", "minimum fraction of length for a successful match", { default => 0.80 }],
        ["maxE=f", "maximum permissible E-value for a successful match", { default => 1e-40 }],
        ["minSim=i", "minimum acceptable similarity for a close genome", { default => 100 }],
        ["maxHits=i", "maximum hits for each query peg", { default => 5 }],
        ["internal", "target.fa file is already created"]
    );
my $minlen = $opt->minlen;
my $maxE = $opt->maxe;
my $maxHits = $opt->maxhits;
my $debug = $opt->verbose;
my $ih = P3Utils::ih($opt);
my $oh = P3Utils::oh($opt);
my $minSim = $opt->minsim;
# Connect to PATRIC.
my $p3 = P3DataAPI->new();
# Get the positional parameters.
my ($workDir) = @ARGV;
if (! $workDir) {
    die "No working directory specified.";
} elsif (! -d $workDir) {
    print STDERR "Creating work directory $workDir.\n" if $debug;
    File::Copy::Recursive::pathmk($workDir);
}
my $stats = Stats->new();
# Load the GTO file.
print STDERR "Loading the GTO for Close-Genome Annotation.\n" if $debug;
my $gto = GenomeTypeObject->create_from_file($ih);
# Create a FASTA from the contigs.
my $genomeFastaFile = "$workDir/target.fa";
if (! $opt->internal || ! -s $genomeFastaFile) {
    # Make sure there is no residual blast database.
    for my $file (qw(target.fa.nhr target.fa.nin target.fa.nsq)) {
        if (-f "$workDir/$file") {
            unlink "$workDir/$file";
        }
    }
    print STDERR "Creating FASTA file $genomeFastaFile from input GTO.\n" if $debug;
    $gto->write_contigs_to_file($genomeFastaFile);
}
# Create the annotation object.
my $closeAnno = CloseAnno->new($genomeFastaFile, stats => $stats, maxE => $maxE, minlen => $minlen,
    workDir => $workDir, verbose => $debug, maxHits => $maxHits);
# Get the close genomes and the genetic code from the GTO.
my $gc = $gto->{genetic_code};
my $closeGenomes = $gto->{close_genomes};
# Loop through the close genomes.
for my $closeGenome (@$closeGenomes) {
    my $genomeID = $closeGenome->{genome};
    print STDERR "Downloading $genomeID: $closeGenome->{genome_name}.\n";
    my $fastaFile = "$workDir/$genomeID.fa";
    P3Utils::protein_fasta($p3, $genomeID, $fastaFile);
    $stats->Add(closeGenomeIn => 1);
    # Look for hits in the file.
    $closeAnno->findHits($fastaFile, $gc);
}
# Now unspool the output.
my $all_stops = $closeAnno->all_stops;
$closeAnno->log(scalar(@$all_stops) . " features found.\n") if $debug;
for my $stopLoc (@$all_stops) {
    my ($contig, $start, $dir, $stop, $function) = $closeAnno->feature_at($stopLoc);
    $closeAnno->add_feature_at($gto, $stopLoc);
}
print STDERR "Storing GTO from Close-Genome Annotation.\n";
$gto->destroy_to_file($oh);
$stats->Add(duration => time - $start);
print STDERR "All done.\n" . $stats->Show() if $debug;
