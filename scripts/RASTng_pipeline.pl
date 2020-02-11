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

    RASTng_pipeline.pl [options] workDir

This script takes a FASTA file as input and produces a fully-annotated L<GenomeTypeObject> file.  It works as a pipeline, creating a skeleton GTO
in the first step and then performing transformations using scripts listed in the COMMANDS constant.  Each command takes a GTO as standard input
and produces one on the standard output.  All of these scripts load the input at the beginning and write the output at the end.  All of them
support at C<--input> option to specify the input file, an C<--output> option to specify the output file, and a C<--verbose> option for status
output to STDERR.  Clearing the working directory is not allowed.

=head2 COMMANDS

The COMMANDS constant contains a list of the commands to be executed.  It is evaluated at run-time after the options have been parsed.

=head2 Parameters

The positional parameter is the name of the work directory

The standard input can be overridden using the options in L<P3Utils/ih_options>.  It should contain the FASTA file to annotate.

The standard output can be overridden using the options in L<P3Utils/oh_options>.  It will contain the GTO of the annotated genome.

The standard error output will contain progress messages.

Additional command-line options are the following.

=over 4

=item maxE

The maximum acceptable E-value for a BLAST hit.  The default is C<1e-40>.

=item minlen

The minimum fraction of the query length that must be found in the target genome.  The default is C<0.90>, indicating 90% of the length.

=item maxHits

The maximum number of BLAST hits to return for each query sequence.  The default is C<5>.

=item minStrength

The minimum strength of a kmer indication.  The default is C<0.2>.

=item kmerSize

The kmer length to use.  The default is C<8>.

=item seedFasta

Protein FASTA file used to find the seed protein in the incoming genome.  The default is C<rep10.faa> in the SEEDtk global directory.

=item repDb

Representative-genome database.  This contains the seed proteins for all the possible reference genomes along with other useful information.
The default is C<repFinder.db> in the SEEDtk global directory.

=item minSim

Minimum acceptable kmer similarity for an acceptable close genome. The default is C<100>.

=item maxClose

The maximum number of close genomes to use.  The default is C<10>.

=item nameSuffix

Suffix to add to the species name in order to form the genome name.

=item eval

The name of the directory containing the current evaluation information.

=item id

If specified, an ID to assign to the genome.  This is also used to infer the low-level taxonomic ID.  The default value
of C<computed> means the ID will be assigned using the ID server.

=item clear

If specified, the work directory will be cleared before running the script.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use CloseAnno;
use RepDbFile;
use FastA;
use IPC::Run3;

$| = 1;
my $start = time;
# Get the command-line options.
my $opt = P3Utils::script_opts('workDir', P3Utils::ih_options(), P3Utils::oh_options(),
        ["minlen|min|m=f", "minimum fraction of length for a successful match", { default => 0.60 }],
        ["algorithm=s", "type of kmer algorithm", { default => "AGGRESSIVE" }],
        ["maxE=f", "maximum permissible E-value for a successful match", { default => 1e-20 }],
        ["seedFasta=s", "seed protein FASTA file", { default => "$FIG_Config::p3data/seedprot.fa" }],
        ["repDb=s", "representative-genome database", { default => "$FIG_Config::p3data/repFinder.db"}],
        ["minSim=i", "minimum acceptable similarity for a close genome", { default => 50 }],
        ["maxClose=i", "maximum number of close genomes", { default => 10 }],
        ["maxHits=i", "maximum hits for each query peg", { default => 5 }],
        ["nameSuffix=s", "suffix to give to the genome name"],
        ["eval=s", "name of evaluation directory", { default => "$FIG_Config::p3data/Eval" }],
        ["id=s", "if specified, an ID to use for the genome", { default => "computed" }],
        ["minStrength=f", "minimum strength of a kmer indication", { default => 0.2 }],
        ["clear", "clear the work directory before starting"],
        ["kmerSize|kmer|K=i", "protein kmer size", { default => 8 }],
    );
my $minlen = $opt->minlen;
my $maxE = $opt->maxe;
my $maxHits = $opt->maxhits;
my $ih = P3Utils::ih($opt);
my $oh = P3Utils::oh($opt);
my $repDb = $opt->repdb;
my $minSim = $opt->minsim;
my $maxClose = $opt->maxclose;
my $seedFasta = $opt->seedfasta;
my $nameSuffix = $opt->namesuffix;
my $eval = $opt->eval;
my $genomeID = $opt->id;
my $minStrength = $opt->minstrength;
my $kmerSize = $opt->kmersize;
my $algorithm = $opt->algorithm;
# Connect to PATRIC.
my $p3 = P3DataAPI->new();
# Get the positional parameters.
my ($workDir) = @ARGV;
if (! $workDir) {
    die "No working directory specified.";
} elsif (! -d $workDir) {
    print STDERR "Creating work directory $workDir.\n";
    File::Copy::Recursive::pathmk($workDir) || die "Could not create $workDir: $!";
} elsif ($opt->clear) {
    print STDERR "Erasing work directory $workDir.\n";
    File::Copy::Recursive::pathempty($workDir) ||
        print STDERR "Error clearing work directory: $!\n";
}
my $stats = Stats->new();
# Create the argument list for the name suffix.
my @nameSpec;
if ($nameSuffix) {
    @nameSpec = ('--nameSuffix', $nameSuffix);
}
# Create the GTO.
print STDERR "Creating GenomeTypeObject from input FASTA.\n";
my $gto = GenomeTypeObject->new();
# Read in the contigs.
my @contigs;
my $fastH = FastA->new($ih);
while ($fastH->next()) {
    my $contig = { id => $fastH->id, dna => $fastH->left };
    push @contigs, $contig;
    $stats->Add(contigIn => 1);
}
$gto->{contigs} = \@contigs;
# Create a disk copy of the FASTA;
my $genomeFastaFile = "$workDir/target.fa";
# Make sure there is no residual blast database.
for my $file (qw(target.fa.nhr target.fa.nin target.fa.nsq)) {
    if (-f "$workDir/$file") {
        unlink "$workDir/$file";
    }
}
print STDERR "Creating working FASTA file $genomeFastaFile.\n";
$gto->write_contigs_to_file($genomeFastaFile);
# Create the annotation object.
print STDERR "Creating annotation object.\n";
my $closeAnno = CloseAnno->new($genomeFastaFile, stats => $stats, maxE => $maxE, minlen => $minlen,
    workDir => $workDir, verbose => 1, maxHits => $maxHits);
# Locate the seed protein.  The protein that we are using works the same for genetic codes 4 and 11, so we use 11.
my $seedProt = $closeAnno->findProtein($seedFasta, 11);
if (! $seedProt) {
    die "No seed protein found in genome.\n";
} else {
    # Clear the seed-protein BLAST results.
    $closeAnno->Reset();
}
# Compute the close genomes and the genetic code.
print STDERR "Computing close genomes.\n";
my ($gc, $closeGenomes) = RepDbFile::findCloseGenomes($seedProt, $repDb, $minSim, $maxClose);
$gto->{close_genomes} = $closeGenomes;
$gto->{gc} = $gc;
if (! scalar @$closeGenomes) {
    die "No close genomes found.";
} else {
    print STDERR scalar(@$closeGenomes) . " close genomes found.\n";
}
# Assign the genetic code to the contigs.
$gto->{genetic_code} = $gc;
for my $contig (@contigs) {
    $contig->{genetic_code} = $gc;
}
# Store a dummy genome ID.
$gto->{id} = ($genomeID ne "computed" ? $genomeID : "99.99");
# Save the GTO in the working directory.
print STDERR "Saving initial GTO.\n";
my $gtoFile = "$workDir/target1.gto";
$gto->destroy_to_file($gtoFile);
undef $gto;

############## COMMAND LIST ############# (* denotes where to insert input and output)
my @COMMANDS = (
    [Tax_Comp =>  '*', '--verbose', '--id', $genomeID, @nameSpec, $workDir],
#    [Close_Anno =>  '*', '--verbose', '--internal', '--maxHits', $maxHits, '--minSim', $minSim, '--maxE', $maxE, $workDir],
    ["kmers.anno" => 'kmers', '*', '--nGenomes', $maxClose, '--minStrength', $minStrength, "-K", $kmerSize, "--algorithm", $algorithm],
#    [Eval_Gto =>  '*', '--verbose', '--eval', $eval, $workDir],
    ["dl4j.eval" =>  'gto', '*', '--verbose', '--format', 'DEEP', '--outDir', $workDir, $eval]
);


# These variables will hold the names of the input GTO and the output GTO.
my ($input, $output) = ("$workDir/target1.gto", "$workDir/target2.gto");
for my $command (@COMMANDS) {
    # Add the input and output files.
    my @actual;
    for my $parm (@$command) {
        if ($parm eq '*') {
            push @actual, '--input', $input, '--output', $output;
        } else {
            push @actual, $parm;
        }
    }
    print STDERR "**** Executing " . join(' ', @actual) . "\n";
    my $rc = system(@actual);
    print STDERR "**** Return value from $actual[0] was $rc.\n";
    if ($rc > 0) {
        die "Terminating due to bad return from $actual[0].";
    }
    ($input, $output) = ($output, $input);
}
# Write the final output.  Note that because we swapped after the command, its output is in $input.
print STDERR "Spooling from $input to output.\n";
$gto = GenomeTypeObject->create_from_file($input);
$gto->destroy_to_file($oh);
my $minutes = int((time - $start) / 60);
print STDERR "All done in $minutes minutes.\n" . $stats->Show();
