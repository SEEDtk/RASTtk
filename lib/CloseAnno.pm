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


package CloseAnno;

    use strict;
    use warnings;
    use GenomeTypeObject;
    use BlastUtils;
    use Stats;
    use SeedUtils;
    use Hsp;

=head1 Close-Genome Annotation Object

This object maintains data structures used to annotate a genome using close-strain comparison.  A close-strain comparison annotation relies on a set
of protein families restricted to reference genomes.  Each family is BLASTED against the target FASTA file, and a solid hit is used to call a protein
with the same function as the family.

The fields in this object are as follows.

=over 4

=item genomes

Reference to a hash mapping each genome ID to a bin name.

=item families

Reference to a hash that maps each protein family ID to a list of triples, each triple containing (0) a feature ID, (1) a functional assignment, and (2) a protein sequence.

=item stats

A L<Stats> object containing statistics about the operation.

=item maxE

The maximum acceptable E-value for a BLAST hit.

=item minlen

The minimum fraction of the query length that must be found in the target genome.

=back

=head2 Special Methods

=head3 new

    my $closeAnno = CloseAnno->new(%options);

Create a new, blank close-genome annotation object.

=over 4

=item options

A hash containing zero or more of the following keys.

=over 8

=item stats

A L<Stats> object for creating statistics.  If none is specified, one will be generated internally.

=item maxE

The maximum acceptable E-value for a BLAST hit.  The default is C<1e-5>.

=item minlen

The minimum fraction of the query length that must be found in the target genome.  The default is C<0.75>, indicating 75% of the length.

=back

=back

=cut

sub new {
    my ($class, %options) = @_;
    my $stats = $options{stats} // Stats->new();
    my $maxE = $options{maxE} // 1e-5;
    my $minlen = $options{minlen} // 0.75;
    my $retVal = { genomes => {}, families => {},
        stats => $stats, maxE => $maxE, minlen => $minlen };
    bless $retVal, $class;
    return $retVal;
}


=head2 Definition Methods

=head3 DefineGenome

    $closeAnno->DefineGenome($genomeID, $bin);

Associate a genome with a bin name.

=over 4

=item genomeID

ID of the relevant genome.

=item bin

Name of the genome's bin.

=back

=cut

sub DefineGenome {
    my ($self, $genomeID, $bin) = @_;
    $self->{genomes}{$genomeID} = $bin;
    $self->{stats}->Add(genomeIn => 1);
}

=head3 StoreProtein

    $closeAnno->StoreProtein($pgfamID, $fid, $function, $sequence);

Store a protein in the object to use for annotation.

=over 4

=item pgfamID

ID of the protein's family.

=item fid

ID of the feature containing the protein.

=item function

Functional assignment of the protein.

=item sequence

Amino acid sequence of the protein.

=back

=cut

sub StoreProtein {
    my ($self, $pgfamID, $fid, $function, $sequence) = @_;
    my $families = $self->{families};
    my $stats = $self->{stats};
    if (! $families->{$pgfamID}) {
        $families->{$pgfamID} = [];
        $stats->Add(protFamilyIn => 1);
    }
    my $pgfamL = $families->{$pgfamID};
    push @$pgfamL, [$fid, $function, $sequence];
}

=head2 Query Methods

=head3 stats

    my $stats = $closeAnno->stats;

Return the statistics object.

=cut

sub stats {
    my ($self) = @_;
    return $self->{stats};
}

=head3 families

    my $familiesH = $closeAnno->families;

Return the protein family hash table.

=cut

sub families {
    my ($self) = @_;
    return $self->{families};
}

=head3 findHit

    my $hspL = $closeAnno->findHit($family, $genomeFastaFile);

Find the best hit for the specified protein family.

=over 4

=item family

The ID of a protein family stored in this object.

=item genomeFastaFile

The name of a BLAST database for the target genome.

=item RETURN

Returns a reference to a list L<Hsp> objects for the acceptable hits.

=back

=cut

sub findHit {
    my ($self, $family, $genomeFastaFile) = @_;
    my $stats = $self->stats;
    # This will be the return value.
    my @retVal;
    # Get the minimum length fraction.
    my $minlen = $self->{minlen};
    # Get the query sequences.
    my $triples = $self->{families}{$family};
    if ($triples) {
        # Find all the matches.
        $stats->Add(familyFound => 1);
        my $matches = BlastUtils::blast($triples, $genomeFastaFile, 'tblastn', { maxE => $self->{maxE}, outForm => 'hsp' });
        # Sort them by location.
        $matches = [ sort { ($a->sid cmp $b->sid) or ($a->s1 <=> $b->s1) } @$matches ];
        # We want to keep the matches that exceed a certain length.  If, however, the hit locations overlap, we only keep the long one.
        # The following variables are used for the overlap check.
        my ($oldContig, $oldRight, $oldLen) = ('', 0, 0);
        for my $hit (@$matches) {
            $stats->Add(match => 1);
            my $newLen = $hit->n_mat - $hit->n_gap;
            if ($newLen >= $minlen * $hit->qlen) {
                # Here the match is long enough.  Check for overlap.
                my ($newLeft, $newRight) = ($hit->s1, $hit->s2);
                if ($hit->dir eq '-') {
                    ($newLeft, $newRight) = ($newRight, $newLeft);
                }
                if ($hit->sid eq $oldContig && $newLeft <= $oldRight) {
                    $stats->Add(matchOverlap => 1);
                    # We have overlap.  Keep the longest.
                    if ($oldLen < $newLen) {
                        pop @retVal;
                        push @retVal, $hit;
                        ($oldContig, $oldRight, $oldLen) = ($hit->sid, $newRight, $newLen);
                    }
                } else {
                    # No overlap.  Keep the new match.
                    push @retVal, $hit;
                    ($oldContig, $oldRight, $oldLen) = ($hit->sid, $newRight, $newLen);
                    $stats->Add(matchNew => 1);
                }
            } else {
                # Here the match was too short.
                $stats->Add(matchRejected => 1);
            }
        }
    }
    # Return the matches found.
    return \@retVal;
}

1;


