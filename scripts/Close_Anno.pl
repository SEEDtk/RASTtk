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

    Test_Anno.pl [options] genomeFastaFile closeProteinsFile workDir

This is a preliminary script for performing close-genome annotation.  A <CloseAnno> object is built from the incoming file of protein specifications,
and then the individual families are BLASTed again the input FASTA.  The resulting hits are used to find pegs on the genome.

=head2 Parameters

The positional parameters are the name of the genome FASTA file, the name of a tab-delimited file containing proteins, and the name of the working directory.
The first record of the tab-delimited file is a header; each remaining record contains (0) a genome ID, (1) a feature ID, (2) a protein family ID, (3) the feature's
functional assignment, and (4) the feature's protein sequence.

The command-line options are as follows.

=over 4

=item verbose

Write progress messages to STDERR.

=item maxE

The maximum acceptable E-value for a BLAST hit.  The default is C<1e-5>.

=item minlen

The minimum fraction of the query length that must be found in the target genome.  The default is C<0.90>, indicating 75% of the length.

=item gap

The maximum permissible gap between BLAST hits that are to be merged. BLAST hits on the same contig in the same
direction that are closer than this number of base pairs are merged into a single hit.  The default is C<100>.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use Stats;
use CloseAnno;
use BlastUtils;
use File::Copy::Recursive;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('genomeFastaFile closeProteinsFile workDir',
        ["verbose|debug|v", "display progress on STDERR"],
        ["minlen|min|m=f", "minimum fraction of length for a successful match", { default => 0.90 }],
        ["maxE=f", "maximum permissible E-value for a successful match", { default => 1e-5 }]
    );
my $debug = $opt->verbose;
my $minlen = $opt->minlen;
my $maxE = $opt->maxe;
# Get the positional parameters.
my ($genomeFastaFile, $closeProteinsFile, $workDir) = @ARGV;
if (! $genomeFastaFile) {
    die "No genome file specified."
} elsif (! -s $genomeFastaFile) {
    die "Invalid or missing genome file $genomeFastaFile.";
} elsif (! $closeProteinsFile) {
    die "No proteins file specified.";
} elsif (! -s $closeProteinsFile) {
    die "Invalid or missing protein file $closeProteinsFile.";
} elsif (! $workDir) {
    die "No working directory specified.";
} elsif (! -d $workDir) {
    print STDERR "Creating work directory $workDir.\n" if $debug;
    File::Copy::Recursive::pathmk($workDir);
}
my $stats = Stats->new();
# Create the output headers.
P3Utils::print_cols([qw(qid qdef qlen sid sdef slen scr e_val p_n p_val n_mat n_id n_pos n_gap dir q1 q2 qseq s1 s2 sseq)]);
print STDERR "Reading proteins.\n" if $debug;
open(my $ph, '<', $closeProteinsFile) || die "Could not open protein file: $!";
my ($headers, $cols) = P3Utils::find_headers($ph, "protein file" => qw(genome_id patric_id pgfam_id product aa_sequence));
# Process the protein file.  Here we will build the database of genomes and protein families.
my $closeAnno = CloseAnno->new(stats => $stats, maxE => $maxE, minlen => $minlen);
my $protCount = 0;
my $oldGenome = '';
while (! eof $ph) {
    my ($genome, $fid, $family, $function, $seq) = P3Utils::get_cols($ph, $cols);
    if ($genome ne $oldGenome) {
        # Make sure we know this genome's bin.
        $closeAnno->DefineGenome($genome, 1);
        $oldGenome = $genome;
    }
    # Store this protein.
    $closeAnno->StoreProtein($family, $fid, $function, $seq);
    $protCount++;
    print STDERR "$protCount proteins processed.\n" if $debug && $protCount % 1000 == 0;
}
print STDERR "$protCount proteins stored for processing.\n" if $debug;
my $familyH = $closeAnno->families();
my $familyL = [ keys %$familyH ];
my $famCount = 0;
print STDERR scalar(@$familyL) . " protein families found.\n" if $debug;
for my $family (@$familyL) {
    my $hspList = $closeAnno->findHit($family, $genomeFastaFile);
    for my $hsp (@$hspList) {
        P3Utils::print_cols($hsp);
    }
    $famCount++;
    print STDERR "$famCount families processed.\n" if $debug && $famCount % 50 == 0;
}
print STDERR "All done.\n" . $stats->Show() if $debug;
