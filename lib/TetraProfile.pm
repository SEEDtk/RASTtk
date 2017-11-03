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


package TetraProfile;

    use strict;
    use warnings;


=head1 Tetramer Profile

This object represents a tetramer profile. Given a L<TetraMap>, it will accumulate a list of tetramer vectors based on that map and its
input sequences. It can then be used to compute statistics about tetramer differences. 

The fields in this object are as follows.

=over 4

=item map

The L<TetraMap> to be used to compute the vectors.

=item global

The global tetramer vector for all the DNA chunks processed so far. The vector is un-normalized.

=item chunkSize

The chunk size to use for large sequences.

=item locals

Reference to a list of the chunk profile vectors. The vectors are normalized.

=item keepLocals

If TRUE, local vectors will be kept; otherwise they will be discarded.

=back

=head2 Special Methods

    my $profile = TetraProfile->new($map, %options);

Create a new, empty tetramer profile.

=over 4

=item map

The L<TetraMap> object used to compute the tetramer vectors.

=item options

A hash of options, including 0 or more of the following.

=over 8

=item nolocals

If TRUE, no local vectors will be kept. In this case, the L</stats> method is meaningless.

=item chunkSize

The number of base pairs to use in each sampling chunk. The default is C<1000>. A value of C<0> disables chunking.

=back

=back

=cut

sub new {
    my ($class, $map, %options) = @_;
    # Process the options.
    my $chunkSize = $options{chunkSize} // 1000;
    my $keepLocals = ! $options{nolocals};
    # Create the object.
    my $retVal = {
        'map' => $map,
        chunkSize => $chunkSize,
        global => $map->empty(),
        locals => [],
        keepLocals => $keepLocals,
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head2 Query Methods

=head3 global

    my $global = $profile->global();

Return a normalized copy of the global profile.

=cut

sub global {
    my ($self) = @_;
    my $global = $self->{global};
    my $n = scalar @$global;
    my $len = TetraMap::len($global);
    # Get an empty vector of the right length.
    my $retVal = $self->{map}->empty();
    # Normalize the global vector into it.
    for (my $i = 0; $i < $n; $i++) {
        $retVal->[$i] = $global->[$i] / $len;
    }
    # Return the copy.
    return $retVal;
}

=head3 stats

    my ($min, $max, $mean, $sdev, $tol) = $profile->stats($type);

Return the minimum, maximum, mean, standard deviation, and tolerance of the distances of the local tetramer vectors from the normalized global.

=over 4

=item type

Either C<dot> for inverted dot products or C<dist> for real distances. The default is C<dist>.

=item RETURN

Returns a list containing the minimum, maximum, mean, standard deviation, and tolerance (maximum expected value) for the values computed. 

=cut

sub stats {
    my ($self, $type) = @_;
    $type //= 'dist';
    # Get the normalized global.
    my $global = $self->global;
    # Compute the stats. Note that 2 is an infinite distance here, since all the vectors are unit length.
    my ($min, $max, $sum, $sqrs, $count) = (2, 0, 0, 0, 0);
    for my $local (@{$self->{locals}}) {
        my $dist;
        if ($type eq 'dot') {
            $dist = 1 - TetraMap::dot($global, $local);
        } else {
            $dist = TetraMap::dist($global, $local);
        }
        $min = $dist if ($dist < $min);
        $max = $dist if ($dist > $max);
        $sum += $dist;
        $sqrs += $dist * $dist;
        $count++;
    }
    # Compute the mean and standard deviation.
    my $mean = $sum / $count;
    my $sdev = sqrt($sqrs/$count - $mean/$count);
    # Compute the tolerance.
    my $tol = $mean + 2 * $sdev;
    # Return the statistics.
    return ($min, $max, $mean, $sdev, $tol);
}


=head2 Public Manipulation Methods

=head3 ProcessContig

    $profile->ProcessContig($contig);

Process a single contig string. The entire contig will be merged into the global vector, and chunks of it will be
processed as local vectors.

=over 4

=item contigP

The string containing the contig.

=back

=cut

sub ProcessContig {
    my ($self, $contig) = @_;
    # Get the object fields.
    my $chunkSize = $self->{chunkSize};
    my $map = $self->{map};
    my $global = $self->{global};
    my $localL = $self->{locals};
    my $lenL = $self->{lens};
    my $keep = $self->{keepLocals};
    # Get the contig length.
    my $len = length $contig;
    # Change a chunk size of 0 to the contig length to prevent chunking.
    $chunkSize ||= $len;
    # Loop through the chunks, computing profile vectors. We have to do a fancy loop because
    # we don't want any chunks that are less than 100 base pairs.
    my ($offset, $next) = (0, $chunkSize);
    while ($offset < $len) {
        # Insure we don't have a too-short fragment at the end. 
        if ($len - $next < 100) {
            $next = $len;
        }
        my $chunk = substr($contig, $offset, $next - $offset);
        my $local = $map->ProcessString($chunk);
        # Each local vector is merged into the global before it is normalized.
        TetraMap::Add($global, $local);
        # Normalize and save the local vector.
        if ($keep) {
            TetraMap::Norm($local);
            push @$localL, $local;
        }
        # Position at the next chunk.
        $offset = $next;
        $next += $chunkSize;
    }
}

=head3 ProcessFasta

    $profile->ProcessFasta($ih);

Read and process all the contigs in a FASTA input file.

=over 4

=item ih

Open input handle for the FASTA file, or the name of the FASTA file.

=back

=cut

sub ProcessFasta {
    my ($self, $ih) = @_;
    # Insure we have an open file handle.
    if (ref $ih ne 'GLOB') {
        open(my $fh, "<", $ih) || die "Could not open FASTA input file $ih: $!";
        $ih = $fh;
    }
    # Loop through the input file.
    my @dna;
    while (! eof $ih) {
        my $line = <$ih>;
        # Is this a header line?
        if ($line =~ /^>(\S+)/) {
            # Yes. Process the current DNA, if any.
            if (@dna) {
                my $dna = join("", @dna);
                $self->ProcessContig($dna);
            }
            # Set up for the next contig.
            @dna = ();
        } else {
            # Not a header line. Save the DNA.
            chomp $line;
            push @dna, $line;
        }
    }
    # If there is leftover DNA, process it.
    if (@dna) {
        my $dna = join("", @dna);
        $self->ProcessContig($dna);
    }
}


=head3 ProcessGto

    $profile->ProcessGto($gto);

Process all the contigs in a L<GenomeTypeObject>.

=over 4

=item gto

The L<GenomeTypeObject> whose contigs are to be merged into the profile.

=back

=cut

sub ProcessGto {
    my ($self, $gto) = @_;
    my $contigs = $gto->{contigs};
    for my $contig (@$contigs) {
        $self->ProcessContig($contig->{dna});
    }
}


1;