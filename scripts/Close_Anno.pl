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

    Close_Anno.pl [options] genomeFastaFile controlFile workDir

This is a preliminary script for performing close-genome annotation.

The program uses a control file, tab-delimited with no headers.  Each record contains the name of a FASTA file and a
genetic code number.  The FASTA file should contain protein sequences with a FIG feature ID as the sequence ID, the
functional assignment as the comment, and the protein sequence as the sequence.  Each such file will be blasted against
the target genome FASTA file using the specified genetic code.  The best match for any ORF will be output.

=head2 Parameters

The positional parameters are the name of the target genome FASTA file, the name of the
control file, and the name of a working directory for temporary
files.

The command-line options are as follows.

=over 4

=item gto

If specified, the target genome is assumed to be a de-annotated L<GenomeTypeObject> instead of a FASTA file.
The contigs will be copied to a FASTA file in the working directory (C<target.fa>) and a new GTO file will
be created with the annotations.  The value of the parameter should be the name of the output GTO.

=item verbose

Write progress messages to STDERR.

=item maxE

The maximum acceptable E-value for a BLAST hit.  The default is C<1e-40>.

=item minlen

The minimum fraction of the query length that must be found in the target genome.  The default is C<0.90>, indicating 90% of the length.

=item maxHits

The maximum number of BLAST hits to return for each query sequence.  The default is C<5>.

=item log

Specifies a file to contain progress messsages (in addition to STDERR).

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
# Get the command-line options.
my $opt = P3Utils::script_opts('genomeFastaFile controlFile workDir',
        ["gto=s", "input is a GTO, produce an annotated GTO file as output"],
        ["verbose|debug|v", "display progress on STDERR"],
        ["log=s", "log progress messages to a file (implies verbose)"],
        ["minlen|min|m=f", "minimum fraction of length for a successful match", { default => 0.80 }],
        ["maxE=f", "maximum permissible E-value for a successful match", { default => 1e-40 }],
        ["maxHits=i", "maximum hits for each query peg", { default => 5 }]
    );
my $minlen = $opt->minlen;
my $maxE = $opt->maxe;
my $maxHits = $opt->maxhits;
my $gtoFile = $opt->gto;
my $logFile = $opt->log;
my $debug = $opt->verbose || $opt->log;
# Get the positional parameters.
my ($genomeFastaFile, $controlFile, $workDir) = @ARGV;
if (! $genomeFastaFile) {
    die "No genome file specified."
} elsif (! -s $genomeFastaFile) {
    die "Invalid or missing genome file $genomeFastaFile.";
} elsif (! $controlFile) {
    die "No control file specified.";
} elsif (! -s $controlFile) {
    die "Invalid or missing control file $controlFile.";
} elsif (! $workDir) {
    die "No working directory specified.";
} elsif (! -d $workDir) {
    print STDERR "Creating work directory $workDir.\n" if $debug;
    File::Copy::Recursive::pathmk($workDir);
}
my $stats = Stats->new();
# Is the input a GTO file?
my $gto;
if ($gtoFile) {
    # Load the GTO file.
    print STDERR "GTO mode in effect.\n" if $debug;
    $gto = GenomeTypeObject->create_from_file($genomeFastaFile);
    $genomeFastaFile = "$workDir/target.fa";
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
    workDir => $workDir, verbose => $debug, logFile => $logFile, maxHits => $maxHits);
# Loop through the input.
open(my $ih, '<', $controlFile) || die "Could not open $controlFile: $!";
while (! eof $ih) {
    my $line = <$ih>;
    $stats->Add(lineIn => 1);
    # Get the file name and genetic code.
    if ($line =~ /^([^\t]+)\t(\d+)/) {
        my ($fastaFile, $gc) = ($1, $2);
        if (! -s $fastaFile) {
            $closeAnno->log("WARNING: $fastaFile not found or empty.\n") if $debug;
            $stats->Add(queryFileNotFound => 1);
        } else {
            # Look for hits in the file.
            $stats->Add(queryFileFound => 1);
            $closeAnno->findHits($fastaFile, $gc);
        }
    }
}
# Now unspool the output.
my $all_stops = $closeAnno->all_stops;
$closeAnno->log(scalar(@$all_stops) . " features found.\n") if $debug;
print "contig\tstart\tdir\tstop\tfunction\n";
for my $stopLoc (@$all_stops) {
    my ($contig, $start, $dir, $stop, $function) = $closeAnno->feature_at($stopLoc);
    print "$contig\t$start\t$dir\t$stop\t$function\n";
    if ($gto) {
        $closeAnno->add_feature_at($gto, $stopLoc);
    }
}
if ($gto) {
    $gto->destroy_to_file($gtoFile);
}
$closeAnno->log("All done.\n" . $stats->Show()) if $debug;
