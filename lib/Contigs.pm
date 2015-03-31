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


package Contigs;

    use strict;
    use warnings;
    use gjoseqlib;
    use SeedUtils;
    use BasicLocation;

=head1 Contig Management Object

This object contains the contigs for a specific genome. it provides methods for extracting
DNA and exporting the contigs in different forms.

The object is a subclass of L<Contigs> that gets the contig data from the L<Shrub> database.

=over 4

=item genome

ID of the relevant genome.

=item comments

Reference to a hash mapping each contig ID to its comment.

=item seqs

Reference to a hash mapping each contig ID to its sequence.

=item lens

Reference to a hash mapping each contig ID to its length.

=back

=head2 Special Methods

=head3 new

    my $contigObj = Contigs->new($contigFile, %options);

Create a contig object from a FASTA file.

=over 4

=item contigFile

Name of a FASTA file containing the contig DNA.

=item options

A hash of options, containing zero or more of the following keys.

=over 8

=item genomeID

ID of the relevant genome. If omitted, the default is C<unknown>.

=item geneticCode

Genetic code of the contigs. If omitted, the default is C<11>.

=back

=back

=cut

sub new {
    # Get the parameters.
    my ($class, $contigFile, $genomeID) = @_;
    # Read the specified FASTA file.
    my $triplesList = gjoseqlib::read_fasta($contigFile);
    # Use the triplets we just read to build the object.
    my %comments = map { $_->[0] => $_->[1] } @$triplesList;
    my %seqs = map { $_->[0] => $_->[2] } @$triplesList;
    my %lens = map { $_->[0] => length($_->[2]) } @$triplesList;
    my $retVal = {
        genome => $genomeID,
        comments => \%comments,
        seqs => \%seqs,
        lens => \%lens,
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}


=head2 Query Methods

=head3 dna

    my $seq = $contigs->dna(@locs);

Return the DNA at the specified locations. The locations must be in this object's
genome.

=over 4

=item locs

A list of locations. These can be in the form of location strings or L<BasicLocation>
objects.

=item RETURN

Returns a DNA sequence corresponding to the specified locations.

=back

=cut

sub dna {
    # Get the parameters.
    my ($self, @locs) = @_;
    # We'll stash the DNA in here.
    my @retVal;
    # Loop through the locations, creating DNA. Note we convert each
    # one to a basic location object.
    for my $loc (map { BasicLocation->new($_) } @locs) {
        # Get the contig ID.
        my $contigID = $loc->Contig;
        # Does the contig exist?
        my $seqH = $self->{seqs};
        if (! exists $seqH->{$contigID}) {
            # No. Return a bunch of hyphens.
            push @retVal, '-' x $loc->Length;
        } else {
            # Yes. Extract the dna.
            my $dna = substr($seqH->{$contigID}, $loc->Left, $loc->Length);
            # If the direction is negative, reverse complement it.
            SeedUtils::rev_comp(\$dna);
            # Keep the result.
            push @retVal, $dna;
        }
    }
    # Return the DNA.
    return join("", @retVal);
}


=head3 kmer

    my $kmer = $contigs->kmer($contigID, $pos, $revFlag, \%options);

or

    my ($kmer, $kmerR) = $contigs->kmer($contigID, $pos, $revFlag, \%options);

Get the kmer at the specified position in the specified contig. The options indicate the
length and type of the kmer. An invalid kmer will come back as an empty string. A kmer
that falls off either end of the contig will come back undefined. Thus, when looping
through a contig you can use an undefined result to terminate the loop.

In scalar context, this method returns the desired kmer. In list context it returns
both the kmer and its reverse complement.

=over 4

=item contigID

ID of the contig whose kmer is desired.

=item pos

Position in the contig (1-based) of the kmer origin.

=item revFlag (optional)

TRUE if we want the reverse complement (minus strand) kmer, FALSE for the normal
(plus strand) kmer. The default is FALSE.

=item options (optional)

Reference to a hash of options describing the kmer. This includes the following keys.

=over 8

=item k

Result length of the kmer. The default is C<30>.

=item style

Style of the kmer. The default is C<normal>, which is a normal kmer taken from the
nucleotides at the current position. There is also C<2of3>, which constructs the
kmer from the first two of every three nucleotides.

=back

=item RETURN

In scalar context, returns the specified kmer. In list context, returns a 2-element
list consisting of the kmer and the kmer for the reverse complement of the same
region.

=back

=cut

sub kmer {
    # Get the parameters.
    my ($self, $contigID, $pos, $revflag, $options) = @_;
    # Adjust if the optional arguments are omitted.
    if ($revflag && ref $revflag eq 'HASH') {
        $options = $revflag;
        $revflag = 0;
    } elsif (! $options) {
        $options = {};
    }
    # The return values will go in here.
    my @retVal;
    # Compute the kmer type.
    my $k = $options->{k} // 30;
    my $style = $options->{style} // 'normal';
    # Create the kmer location.
    my $dir = ($revflag ? '-' : '+');
    my $klen = (($style eq '2of3') ? ($k >> 1) + $k : $k);
    my $kloc = BasicLocation->new($contigID, $pos, $dir, $klen);
    # Verify that we're inside the contig.
    if ($kloc->Left > 0 && $kloc->Right <= $self->{lens}{$contigID}) {
        # Get the DNA.
        my @bases = uc $self->dna($kloc);
        # Only proceed if it's valid.
        if ($bases[0] =~ /[^AGCT]/) {
             # Invalid, so return empty strings.
             @retVal = ('', '');
        } else {
            # If the user wants an array, he wants the reverse complement.
            if (wantarray()) {
                push @bases, SeedUtils::rev_comp($bases[0]);
            }
            # Process according to the style.
            for my $base (@bases) {
                if ($style eq '2of3') {
                    push @retVal, join( '', $base =~ m/(..).?/g );
                } else {
                    push @retVal, $base;
                }
            }
        }
    }
    # Return the kmer in scalar mode, the list of kmers in list mode.
    if (wantarray()) {
        return @retVal;
    } else {
        return $retVal[0];
    }
}


=head3 xlate

    my $protSeq = $contigs->xlate(@locs, \%options);

Return the protein translation of a DNA sequence. The DNA can be passed in directly as a
scalar reference or computed from a list of locations.

=over 4

=item locs

List of locations. These can be location strings or B<BasicLocation> objects.

=item options

Reference to a hash of options. The keys can be zero or more of the following.

=over 8

=item fix

If TRUE, the first triple is to get special treatment. A value of C<ATG>, C<TTG> or C<GTG>
in the first position is translated to C<M> regardless of the genetic code. If FALSE, the
first triple is translated normally.

=item code

If specified, reference to a hash that specifies the genetic code. If omitted, the genetic
code determined by the code number stored in this object is used.

=back

=item RETURN

Returns the protein sequence determined by the specified DNA sequence.

=back

=cut

sub xlate {
    # Get the parameters.
    my ($self, @locs) = @_;
    # This will be the return value.
    my $retVal = '';
    # Only proceed if we have locations.
    if (@locs) {
        # Check for options.
        my $options = {};
        if (ref $locs[$#locs] eq 'HASH') {
            $options = pop @locs;
        }
        ## TODO translate the protein
    }
    # Return the protein sequence.
    return $retVal;
}

1;