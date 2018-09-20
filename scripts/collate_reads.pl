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
use FastA;
use FastQ;
use File::Copy::Recursive;
use KmerDb;
use Stats;

=head1 Collate Reads Into Possible Bins

    collate_reads.pl [ options ] workDir kmerFile fq1 fq2

This script processes unassembled reads and attempts to collate them into bins based on signature kmers.  The reads
are read individually, and a stride-based check used to look for signature kmers.  The reads with signature kmers
are collected in a separate output stream for each potential bin.

The output files will be labeled C<bin1>, C<bin2>, ... and so forth. The index for the first bin can be set using
the C<--idx> parameter.

=head2 Parameters

The positional parameters are the name of a working directory, the name of a kmer database, and the names
of the input files.  The input files can either be a single FASTA file or a pair of paired-end FASTQ files. The number
of parameters will determine how the files are treated.

The command-line options are the following.

=over 4

=item stride

The number of positions to skip when checking kmers in a read. The default is C<10>. Use C<1> to insure every possible read
substring is checked.

=item min

Minimum number of kmer hits to consider a read worth including. The default is C<1>.

=item idx

The index number to give to the first bin produced.

=back

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('workDir kmerFile fq1 fq2',
        ['stride=i', 'distance between kmer checks in the read', { default => 10 }],
        ['min|m=i', 'minimum number of hits required to bin', { default => 1 }],
        ['idx|i=i', 'index of first bin', { default => 1 }]
        );
# Get the parameters.
my ($workDir, $kmerFile, @inFiles) = @ARGV;
if (! $workDir) {
    die "No output directory specified.";
} elsif (! -d $workDir) {
    print "Creating output directory $workDir.\n";
    File::Copy::Recursive::pathmk($workDir) || die "Could not create $workDir: $!";
} elsif (! $kmerFile) {
    die "No kmer file specified.";
} elsif (! -s $kmerFile) {
    die "Kmer file $kmerFile not found or empty.";
} elsif (! @inFiles) {
    die "No input files specified.";
}
my $stats = Stats->new();
# Get the options.
my $min = $opt->min;
my $stride = $opt->stride;
my $idx = $opt->idx;
# Load the kmer database.
print "Loading kmer database.\n";
my $kmerDb = KmerDb->new(json => $kmerFile);
# Create the reader.
my $ih;
if (@inFiles == 2) {
    $ih = FastQ->new(@inFiles);
} else {
    $ih = FastA->new(@inFiles);
}
# Create the output bins.
my $groups = $kmerDb->all_groups();
print scalar(@$groups) . " bins will be produced, starting with bin$idx.\n";
my %bins;
for my $group (@$groups) {
    my $name = $kmerDb->name($group);
    print "bin$idx is $group $name.\n";
    my $oh = $ih->Out("$workDir/bin$idx");
    $bins{$group} = $oh;
}
# Now read the input, counting bins and writing the output.
my ($progress, $binned) = (0, 0);
while ($ih->next) {
    $stats->Add(readIn => 1);
    my @seqs = $ih->seqs;
    my %counts;
    for my $seq (@seqs) {
        $kmerDb->count_hits($seq, \%counts, undef, $stride);
    }
    # Write the sequence to every bin that exceeds the minimum number of hits.
    my $used;
    for my $group (keys %counts) {
        my $hits = $counts{$group};
        $stats->Add(hitsFound => $hits);
        if ($hits >= $min) {
            $bins{$group}->Write($ih);
            $stats->Add("reads-$group" => 1);
            $used = 1;
        } else {
            $stats->Add(lowHits => 1);
        }
    }
    if ($used) {
        $stats->Add(readUsed => 1);
        $binned++;
    }
    $progress++;
    print "$progress reads processed, $binned binned.\n" if $progress % 10000 == 0;
}
# Close all the files.
print "Closing output files.\n";
for my $group (keys %bins) {
    $bins{$group}->Close();
}
print "All done.\n" . $stats->Show();
