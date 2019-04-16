=head1 Find Long Runs of Amino or Nucleic Acids in a FASTA file

    p3-nucleon-runs.pl [options] letter inFile [inFile2]

Search a set of contigs for runs of a particular amino acid or nucleic acid.  We will output the number of runs greater than a
certain size, and the location of the longest run.

=head2 Parameters

The first positional parameter is the DNA or amino acid letter for which to search.

The second positional parameter is the input FASTA file or interlaced FASTQ file.  If a paired FASTQ file is specified, the
third positional parameter should be its name.

Additional command-line options are the following.

=over 4

=item geneticCode

If specified, the DNA is translated using the specified genetic code and the input letter is presumed to be an amino acid.

=item run

The size of the desired runs.  The default is C<10>.  Only runs of the specified size or greater will be counted.

=item reads

If specified, the input is FASTQ instead of FASTA.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use FastA;
use FastQ;
use SeedUtils;

# Get the command-line options.
my $opt = P3Utils::script_opts('letter inFile inFile2',
        ['geneticCode|geneticcode|code|gc=i', 'genetic code for protein translation'],
        ['run=i', 'minimum run size', { default => 10 }],
        ['reads|fastq', 'input is FASTQ, not FASTA']
        );
# Compute the genetic code for protein mode.
my $prot = $opt->geneticcode;
if ($prot) {
    $prot = SeedUtils::genetic_code($prot);
}
# Get the run size.
my $runSize = $opt->run;
# Get the input mode.
my $fastq = $opt->reads;
# Validate the positional parameters.
my ($letter, $inFile, $inFile2) = @ARGV;
if (! $letter) {
    die "No letter specified.";
} elsif (! $inFile) {
    die "No input file specified.";
} elsif (! -s $inFile) {
    die "Input file $inFile not found or empty.";
} elsif ($inFile2) {
    if (! $fastq) {
        die "Two input files specified in FASTA mode.";
    } elsif (! -s $inFile2) {
        die "Input file $inFile2 not found or empty.";
    }
}
unless ($prot || $letter =~ /[AGCTN\-]/) {
    die "No genetic code specified for amino acid scan.";
}
unless (length $letter == 1) {
    die "Search target must be a single letter.";
}
unless (! $prot || $letter =~ /[ARNDCQEGHILKMFPOSUTWYV]/) {
    die "Invalid amino acid code.";
}
# Open the input file.
my $fh;
if ($fastq) {
    $fh = FastQ->new($inFile, $inFile2);
} else {
    $fh = FastA->new($inFile);
}
# This will be the length and location of the largest run.
my ($bestLen, $bestLoc) = ($runSize - 1, undef);
# This is the initial search string.
my $minimum = $letter x $runSize;
# This will be the count.
my $runCount = 0;
# Loop through the contigs.
while ($fh->next) {
    my $contigID = $fh->id;
    for my $fseq ($fh->left, $fh->right) {
        my $rseq = SeedUtils::reverse_comp($fseq);
        for my $seq ($fseq, $rseq) {
            # The mode determines how we scan.  In protein mode there are three frames on each strand.
            if ($prot) {
                for my $frame (0, 1, 2) {
                    my $aaString = SeedUtils::translate(\$seq, $frame, $prot);
                    Scan($aaString, $contigID);
                }
            } else {
                Scan($seq, $contigID);
            }
        }
    }
}
if (! $bestLoc) {
    print "No runs found.\n"
} else {
    print "$runCount runs found.  Longest is $bestLen in $bestLoc.\n";
}

## Scan a sequence for runs.
sub Scan {
    my ($seq, $contigID) = @_;
    # Start at the first position.
    my $pos = index($seq, $minimum);
    while ($pos >= 0) {
        # Determine the run length.
        my $pos0 = $pos++;
        while (substr($seq, $pos, 1) eq $letter) { $pos++; }
        my $runLen = $pos - $pos0;
        if ($runLen > $bestLen) {
            ($bestLen, $bestLoc) = ($runLen, $contigID);
        }
        $runCount++;
        $pos = index($seq, $minimum, $pos);
    }
}