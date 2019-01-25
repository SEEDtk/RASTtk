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


package RepGenome;

    use strict;
    use warnings;
    use Carp;

=head1 Representative Genome Descriptor

This object encapsulates a representative genome. For each such genome, we need to know the ID, the name, its identifying protein sequence,
and a list of its represented genomes and how close they are.

The fields in this object are as follows.

=over 4

=item prot

The ID of the genome.

=item name

The name of the genome.

=item prot

The sequence of the genome's identifying protein.

=item repMap

Reference to a hash mapping the ID of each represented genome to its similarity score (number of kmers in common).

=item K

The kmer size to use.

=item kMap

Reference to a hash containing the kmers in the protein sequence.

=back

=head2 Special Methods

=head3 new

    my $repGenome = RepGenome->new($id, %options);

Create a new, blank representative genome object.

=over 4

=item id

The ID of the representative genome.

=item options

A hash with zero or more of the following keys, representing additional data.

=over 8

=item name

The name of the genome.

=item prot

The amino acid sequence of the genome's identifying protein.

=item K

Kmer size to use. The default is C<8>.

=back

=back

=cut

sub new {
    my ($class, $id, %options) = @_;
    # Create the object.
    my $K = $options{K} // 8;
    my $retVal = {
        id => $id,
        repMap => {},
        kMap => {},
        K => $K,
    };
    bless $retVal, $class;
    # Add the optional fields.
    if ($options{name}) {
        $retVal->name($options{name});
    }
    if ($options{prot}) {
        $retVal->prot($options{prot});
    }
    # Return it.
    return $retVal;
}


=head2 Field Methods

=head3 id

    my $id = $repGenome->id();

or

    $repGenome->id($newValue);

Get or set the genome ID.

=over 4

=item newValue

Proposed new genome ID.

=item RETURN

Returns the genome ID.

=back

=cut

sub id {
    my ($self, $newValue) = @_;
    if (defined $newValue) {
        $self->{id} = $newValue;
    }
    return $self->{id};
}

=head3 name

    my $name = $repGenome->name();

or

    $repGenome->name($newValue);

Get or set the genome name.

=over 4

=item newVaule

Proposed new genome name.

=item RETURN

Returns the genome name.

=back

=cut

sub name {
    my ($self, $newValue) = @_;
    if (defined $newValue) {
        $self->{name} = $newValue;
    }
    return $self->{name};
}

=head3 prot

    my $prot = $repGenome->prot();

or

    $repGenome->prot($newValue);

Get or set the genome's identifying protein sequence.

=over 4

=item newValue

Proposed new identifying protein sequence..

=item RETURN

Returns the identifying protein sequence.

=back

=cut

sub prot {
    my ($self, $newValue) = @_;
    if (defined $newValue) {
        # Store the protein sequence.
        $self->{prot} = $newValue;
        # Compute the kmer hash.
        my %kHash;
        my $K = $self->{K};
        my $len = length($newValue) - $K;
        for (my $i = 0; $i < $len; $i++) {
            $kHash{lc substr($newValue, $i, $K)} = 1;
        }
        # Store the kmer hash.
        $self->{kMap} = \%kHash;
    }
    return $self->{prot};
}

=head2 Query Methods

=head3 score

    my $score = $repGenome->score($id);

Return the similarity score between the specified genome and this representative. If the genome is not in the representative's set,
returns 0.

=over 4

=item id

ID of the genome to check.

=item RETURN

Returns C<0> if the genome is not in this represented set, else returns the similarity score.

=back

=cut

sub score {
    my ($self, $id) = @_;
    my $repMap = $self->{repMap};
    return ($repMap->{$id} // 0);
}


=head3 check_genome

    my $score = $repGenome->check_genome($protSeq);

Determine the similarity score between the specified protein sequence and this genome.

=over 4

=item protSeq

The protein sequence to compare to our identifying protein.

=item RETURN

Returns the number of kmers in common between the identifying proteins.

=back

=cut

sub check_genome {
    my ($self, $protSeq) = @_;
    # Get the kmer size and the hash.
    my $K = $self->{K};
    my $kMap = $self->{kMap};
    # This will count the kmers in common.
    my $retVal = 0;
    # Loop through the kmers of the incoming sequence.
    my $len = length($protSeq) - $K;
    for (my $i=0; $i < $len; $i++) {
        if ($kMap->{lc substr($protSeq, $i, $K)}) {
            $retVal++;
        }
    }
    # Return the count.
    return $retVal;
}

=head3 distance

    my $distance = $repGenome->distance($repGenome2);

Compute the distance between to representative genome objects.  The distance is a number between 0 and 1 expressed as the number
of distinct kmers not in common divided by the total number of distinct kmers in both sequences (difference over union).  This
number is generally inverse of the similarity score normally used, but it is a true distance measure that forms the genomes into
a metric space.

=over 4

=item repGenome2

A L<RepGenome> object for the other genome to which this one is being compared.

=item RETURN

Returns a number between 0 and 1 indicating the distance between the two genomes.

=back

=cut

sub distance {
    my ($self, $repGenome2) = @_;
    # Get the kmer hashes.
    my $kMap = $self->{kMap};
    my $kMap2 = $repGenome2->{kMap};
    # We want to compute the union and intersection counts.  The union starts with the count in map 1.  We then run through
    # map 2.  Each kmer in map 1 increments the intersection count.  Each kmer not in map 1 increments the union count.
    my $union = scalar keys %$kMap;
    my $intersection = 0;
    for my $kmer (keys %$kMap2) {
        if ($kMap->{$kmer}) {
            $intersection++;
        } else {
            $union++;
        }
    }
    # Compute the distance.
    my $retVal = ($union - $intersection) / $union;
    return $retVal;
}

=head3 rep_list

    my $repList = $repGenome->rep_list();

Return a list of the represented genomes. The return value will be a reference to a list of 2-tuples, each consisting of (0) a genome ID and (1) a similarity score.

=cut

sub rep_list {
    my ($self) = @_;
    my $repMap = $self->{repMap};
    my @retVal = map { [$_, $repMap->{$_}] } sort keys %$repMap;
    return \@retVal;
}

=head3 kCount

    my $count = $repGenome->kCount;

Return the number of kmers in this protein.

=cut

sub kCount {
    my ($self) = @_;
    my $kMap = $self->{kMap} // {};
    return scalar keys %$kMap;
}


=head2 Public Manipulation Methods

=head3 AddGenome

    $repGenome->AddGenome($id, $score);

Add the specified genome to our representative set.

=over 4

=item id

ID of the genome to add.

=item score

Kmer similarity score for the genome.

=back

=cut

sub AddGenome {
    my ($self, $id, $score) = @_;
    my $repMap = $self->{repMap};
    $repMap->{$id} = $score;
}


1;