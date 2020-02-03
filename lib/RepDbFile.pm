#
# Copyright (c) 2003-2019 University of Chicago and Fellowship
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


package RepDbFile;

    use strict;
    use warnings;
    use P3Utils;

=head1 Representative-Genome File

This package is used to load and process data in the giant representative-genome database file.
This file is tab-delimited with headers, and each record contains six columns: (0) a genome ID,
(1) the genome name, (2) a quality score, (3) the ID of the genome's representative, (4) the
genome's genetic code, and (5) the genome's seed protein sequence.  The initial records are of
genomes that represent themselves.  These are terminated by a double-slash record (C<//>).
The remaining genomes are sorted in quality order and are represented by the first genomes.

This package exists to support the L</findCloseGenomes> method, which uses the first part of
the file to compute the closest representatives and then runs through the rest to find the
closest.  Due to the size of the file, we only want to read it once, so we do everything we
need to do in a single pass.

=head2 Special Methods

=head3 findCloseGenomes

    my ($gc, $closeGenomes) = $closeAnno->findCloseGenomes($seedProt, $repDb, $minSim, $maxClose);

Use representative-genome data to find the closest genomes to the target genome being annotated
and compute the genetic code.

=over 4

=item seedProt

The seed protein sequence for the target genome.

=item repDb

The file name of a representative-genome database file.

=item minSim

The minimum similarity for two genomes to be considered close.

=item maxClose

The maxmimum number of close genomes to return.

=item RETURN

Returns a two-element list consisting of (0) the genetic code of the closest genome, and (1) a
reference to a list of close-genome objects suitable for storing in a L<GenomeTypeObject>.

=back

=cut

sub findCloseGenomes {
    my ($seedProt, $repDb, $minSim, $maxClose) = @_;
    # Start by creating a kmer hash for the seed protein.
    my $seedHash = kmers($seedProt);
    # Open the rep-genome DB file.
    open(my $rh, '<', $repDb) || die "Could not open $repDb: $!";
    # Discard the header line and read the first data line.
    my $line = <$rh>;
    $line = <$rh>;
    # Loop through the file. finding the best reps.
    my @reps;
    while ($line && substr($line, 0, 2) ne '//') {
        chomp $line;
        my ($genome, $name, $quality, $rep_id, $gc, $prot) = split /\t/, $line;
        my $score = sim($seedHash, kmers($prot));
        if ($score >= $minSim) {
            push @reps, [$genome, $score, $quality, $name, $gc];
        }
        $line = <$rh>;
    }
    # Now we process these representatives to get all the other genomes in range.
    # We read through the rest of the file, filtering by rep-id.
    my %repH = map { $_->[0] => 1 } @reps;
    while (! eof $rh) {
        my $line = <$rh>;
        chomp $line;
        my ($genome, $name, $quality, $rep_id, $gc, $prot) = split /\t/, $line;
        if ($repH{$rep_id}) {
            my $score = sim($seedHash, kmers($prot));
            if ($score >= $minSim) {
                push @reps, [$genome, $score, $quality, $name, $gc];
            }
        }
    }
    # Now lop off the top N.
    my @found = (sort { $b->[1] <=> $a->[1] || $b->[2] <=> $a->[2] } @reps);
    if (scalar(@found) > $maxClose) {
        splice @found, $maxClose;
    }
    my $closeGenomes = [ map { { genome => $_->[0], genome_name => $_->[3], closeness_measure => $_->[1], analysis_method => 'kmers.reps' } } @found ];
    my $gc = (@found ? $found[0][4] : 11);
    # Return the results.
    return ($gc, $closeGenomes);
}

=head2 Utility Methods

=head3 kmers

    my $kHash = RepDbFile::kmers($prot, $K);

Return a kmer hash for the specified protein sequence.

=over 4

=item prot

The protein sequence to hash.

=item K

The kmer size to use.  The default is C<8>.

=item RETURN

Returns a hash of the kmers in the protein sequence.

=back

=cut

sub kmers{
    my $seq = shift;
    my $n	= shift // 8; # default 8-mers
    my $len	= length $seq;
    my $kmers;
    # Pull out all substrings into hash
    for my $i (0..$len-$n){
        $kmers->{substr $seq, $i, $n} = 1;
    }
    return $kmers;
}

=head3 sim

    my $score = RepDbFile::sim($hash1, $hash2);

Compute the similarity score for two kmer hashes.

=over 4

=item hash1

A kmer hash for the first protein.

=item hash2

A kmer hash for the second protein.

=item RETURN

Returns the number of distinct kmers in common.

=back

=cut

sub sim {
    my ($hash1, $hash2) = @_;
    my @keys1 = keys %$hash1;
    my $retVal = 0;
    # Check hash2 for entries matching keys of hash1
    for my $key (@keys1){
        if (defined $hash2->{$key}){
            $retVal++;
        }
    }
    # Only interested in number of kmers in common
    return $retVal;
}

1;


