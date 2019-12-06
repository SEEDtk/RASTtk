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


package ReadBlaster;

    use strict;
    use warnings;
    use BlastUtils;
    use Stats;

=head1 BLAST Control Object for FastQ BLASTing

This object is used to manage BLAST runs against a DNA BLAST database for a FASTQ file.  The FASTQ DNA sequences are BLASTed in batches,
and a summary of the hits is returned, detailing how many by each incoming read against each subject sequence.  The reads form the query
sequences.

The fields of this object are as follows.

=over 4

=item blastdb

The name of the BLAST database, a DNA sequence FASTA (with associated data evantually added if not already present) that is to be the
target of the incoming reads.

=item maxE

The maximum permissible E-value for an acceptable hit.

=item minlen

The minimum acceptable length for a hit.  The length is computed as the length of the matching query sequence substring less the number
of gap characters.

=item minqual

The minimum acceptable quality of a read, expressed as a fraction from 0 to 1.

=item batchSize

The target batch size for blasting when a whole FASTQ is passed in.

=item stats

A L<Stats> object for recording statistics.

=item seqID

An ID number to assign to the next query sequence.

=item batchCount

Number of batches processed.

=back

=head2 Special Methods

=head3 new

    my $readBlaster = ReadBlaster->new($blastDB, %options);

Create a new blasting object for a specified subject file.

=over 4

=item blastDB

The name of the subject FASTA file / BLAST database for this object.

=item options

A hash containing zero or more of the following options.

=over 8

=item maxE

The maximum permissible e-value for a BLAST hit.  The default is 1e-20.

=item minlen

The minimum permissible length for a BLAST hit.  The default is C<80>.

=item minqual

The minimum acceptable quality fraction for a read.  The default is C<0.50>.

=item batchSize

The target batch size when a whole file is being processed.  The default is C<100>.

=item stats

A L<Stats> object for processing statistics.  If none is provided, one will be created internally.

=back

=back

=cut

sub new {
    my ($class, $blastDB, %options) = @_;
    # Get the options.
    my $maxE = $options{maxE} // 1e-20;
    my $minlen = $options{minlen} // 80;
    my $minqual = $options{minqual} // 0.50;
    my $batchSize = $options{batchSize} // 100;
    my $stats = $options{stats} // Stats->new();
    # Create the object.
    my $retVal = {
        blastdb => $blastDB,
        maxE => $maxE,
        minlen => $minlen,
        minqual => $minqual,
        batchSize => $batchSize,
        stats => $stats,
        seqID => 1,
        batchCount => 0,
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head2 Query Methods

=head3 stats

    my $stats = $readBlaster->stats;

Return the statistics object.

=cut

sub stats {
    my ($self) = @_;
    return $self->{stats};
}


=head2 Public Manipulation Methods

=head3 BlastReads

    my $retHash = $readBlaster->BlastReads(\@reads, $retHash);

BLAST one or more reads against the subject database, storing the hits in the specified hash.

=over 4

=item reads

A reference to a list of 3-tuples, each consisting of (0) an ID, (1) a comment, and (2) a DNA sequence.  These represent the reads to BLAST against the database.
The comment should be the normalized ID of the sequence.  In other words, for paired reads, both parts of the pair will have the same comment.

=item retHash (optional)

A hash into which the results should be placed.  If this is specified, it will also be the value returned.  This allows multiple read batches to have their
results accumulated into a single hash.

=item RETURN

Returns a hash that maps each query sequence to the target subject sequence and length.  The query sequence will be identified by the comment (which is
the normalized sequence ID) and the value will be a 3-tuple consisting of (0) the match length, (1) the subject sequence ID, and (2) the subject comment.

=back

=cut

sub BlastReads {
    my ($self, $reads, $retHash) = @_;
    # Get the minimum match length and the stats object.
    my $stats = $self->{stats};
    my $minlen = $self->{minlen};
    # Count the BLAST call.
    ++$self->{batchCount};
    $stats->Add(batchBlasted => 1);
    my $matches = BlastUtils::blast($reads, $self->{blastdb}, 'blastn', { maxE => $self->{maxE}, outForm => 'hsp' });
    # This wil be the return hash.
    $retHash //= {};
    # Loop through the matches.
    for my $match (@$matches) {
        $stats->Add(blastMatch => 1);
        my $mlen = $match->n_mat - $match->n_gap;
        if ($mlen < $minlen) {
            $stats->Add(matchTooShort => 1);
        } else {
            my $query = $match->qdef;
            if (! $retHash->{$query}) {
                # Here we have a new match for this query.
                $stats->Add(matchNew => 1);
                $retHash->{$query} = [$mlen, $match->sid, $match->sdef];
            } else {
                # Here we have an existing match already in place.  Keep the new one if it is better.
                if ($retHash->{$query}[0] >= $mlen) {
                    $stats->Add(matchDuplicate => 1);
                } else {
                    $stats->Add(matchBetter => 1);
                    $retHash->{$query} = [$mlen, $match->sid, $match->sdef];
                }
            }
        }
    }
    # Return the results.
    return $retHash;
}


=head3 BlastSample

    my $retHash = $readBlaster->BlastSample($fq, $retHash);

This method blasts an entire FastQ sample against the database and returns a mapping from each query sequence hit to the best subject sequence hit.  It
essentially forms the FastQ input into batches and calls L</BlastReads>.

=over 4

=item fq

An open L<FastQ> handle for reading the input sequences.

=item retHash (optional)

A hash into which the results should be placed.  If this is specified, it will also be the value returned.  This allows multiple read batches to have their
results accumulated into a single hash.

=item RETURN

Returns a hash that maps each query sequence to the target subject sequence and length.  The query sequence will be identified by the comment (which is
the normalized sequence ID) and the value will be a 3-tuple consisting of (0) the match length, (1) the subject sequence ID, and (2) the subject comment.

=back

=cut

sub BlastSample {
    my ($self, $fq, $retHash) = @_;
    # Get the options.
    my $batchSize = $self->{batchSize};
    my $stats = $self->{stats};
    # This will be the current input batch.
    my $queries = [];
    # This will be our return hash.
    $retHash //= {};
    my $start = time;
    # Loop through the reads, forming batches.
    while ($fq->next()) {
        # Test the incoming sequences to see if they qualify.
        $self->_check_seq($queries, $fq->id, $fq->left, $fq->lq_mean);
        $self->_check_seq($queries, $fq->id, $fq->right, $fq->rq_mean);
        if (scalar(@$queries) >= $batchSize) {
            # Process this batch.
            $self->BlastReads($queries, $retHash);
            my $hits = scalar %$retHash;
            print STDERR "Batch $self->{batchCount} processed. " . (time - $start) . " seconds, $hits hits.\n";
            $queries = [];
        }
    }
    # Process any residual.
    if (scalar @$queries) {
        $self->BlastReads($queries, $retHash);
    }
    # Return the results.
    return $retHash;
}
1;


=head2 Internal Methods

=head3 _check_seq

    $readBlaster->_check_seq($queries, $seqID, $dna, $qual);

Check a sequence and insert it into the query queue if it is acceptable.  The sequence is acceptable if it is long enough and has high enough quality.

=over 4

=item queries

Reference to a list containing the 3-tuples to BLAST.  If the sequence is acceptable it will be formed into a triple and inserted into the list.

=item seqID

The ID of the sequence in question.

=item dna

The DNA for the sequence in question.

=item qual

The quality fraction of the sequence in question.

=back

=cut

sub _check_seq {
    my ($self, $queries, $seqID, $dna, $qual) = @_;
    my $stats = $self->{stats};
    # Verify the length.
    if (length($dna) < $self->{minlen}) {
        $stats->Add(readTooShort => 1);
    } elsif ($qual < $self->{minqual}) {
        $stats->Add(readTooPoor => 1);
    } else {
        $stats->Add(readKept => 1);
        my $readID = "read" . $self->{seqID}++;
        push @$queries, [$readID, $seqID, $dna];
    }
}
