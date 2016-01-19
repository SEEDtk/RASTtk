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


package KmerRepGenomes;

    use strict;
    use Data::Dumper;
    use Carp;
    use gjoseqlib;
    use warnings;
    use SeedUtils;

=head1 Use Kmers to Find Representative Genomes

This object builds a KMER hash that can be used to find the closest representative genomes for a
set of contigs. The database looks for uncommon protein kmers in certain roles and relates them to genomes.
When analyzing a set of contigs, we count the genomes for each kmer found and take all of the genomes
with a certain number of hits.

This object saves its results in a JSON file in the working directory named C<rep_kmers.json>. The file is
loaded into memory each time the main L</FindGenomes> method is called, so that it is not permanently
resident.

This object has the following fields.

=over 4

=item fileName

Name of the file containing the kmer hash in JSON format.

=item minHits

The minimum number of hits for a genome to be considered relevant.

=item kmerSize

The protein kmer size.

=back

=head2 Special Methods

=head3 new

    my $kmers = KmerRepGenomes->new($shrub, $kmerFile, \@repRoles, %options);

Construct a new kmer analysis object.

=over 4

=item shrub

L<Shrub> object for accessing the database.

=item kmerFile

Name of the file containing the kmer database or which is to contain the kmer database.

=item repRoles

Reference to a list of the IDs for the representative roles. These roles are used to find the proteins that generate the
kmers.

=item options

A hash of options including zero or more of the following.

=over 8

=item force

If TRUE, the kmer hash will be recomputed even if it already exists on disk.

=item kmerSize

The size of a protein kmer. The default is C<10>.

=item minHits

The minimum number of hits for a genome to be considered relevant. The default is C<400>.

=item maxFound

The maximum number of genomes in which a kmer can be found before it is considered common. Common kmers are removed from
the hash.

=item priv

The privilege level at which the roles of a protein should be assessed. The default is C<1>.

=back

=back

=cut

sub new {
    my ($class, $shrub, $kmerFile, $repRoles, %options) = @_;
    # Compute the options.
    my $force = $options{force};
    my $kmerSize = $options{kmerSize} // 10;
    my $minHits = $options{minHits} // 400;
    my $maxFound = $options{maxFound} // 10;
    my $priv = $options{priv} // 1;
    # Do we need to rebuild?
    if ($force || ! -s $kmerFile) {
        # This is our working copy of the kmer hash.
        my %kmerHash;
        # Yes we must rebuild. Loop through the roles.
        for my $role (@$repRoles) {
            # Find all the proteins for this role.
            my @tuples = $shrub->GetAll('Function2Feature Feature Protein AND Feature Feature2Genome',
                    'Function2Feature(from-link) = ? AND Function2Feature(security) = ?',
                    [$role, $priv], 'Feature2Genome(to-link) Protein(sequence)');
            # Loop through the proteins.
            for my $tuple (@tuples) {
                my ($genome, $seq) = @$tuple;
                # Convert the string to upper case. An initial "M" is put in lower case so it is decoded correctly.
                $seq = uc $seq;
                if ($seq =~ /^M(.+)/) {
                    $seq = "m$1";
                }
                # Loop through the protein's kmers.
                my $n = length($seq) - $kmerSize;
                for (my $i = 0; $i <= $n; $i++) {
                    my $kmer = substr($seq, $i, $kmerSize);
                    # Note the same genome may occur multiple times for a single kmer. If it does, we want to count it twice.
                    # Such instances are rare enough (thanks to the roles chosen) that it is not worth trying to optimize them.
                    push @{$kmerHash{$kmer}}, $genome;
                }
            }
        }
        # Now copy the uncommon kmers.
        my %outHash;
        for my $kmer (keys %kmerHash) {
            my $genomes = $kmerHash{$kmer};
            if (scalar(@$genomes) <= $maxFound) {
                $outHash{$kmer} = $genomes;
            }
        }
        # Create a map of genome IDs to names.
        my %gHash = map { $_->[0] => $_->[1] } $shrub->GetAll('Genome', '', [], 'id name');
        # Save the resulting hashes.
        SeedUtils::write_encoded_object({ kmers => \%outHash, genomes => \%gHash }, $kmerFile);
    }
    # Create the object.
    my $retVal = {
        fileName => $kmerFile,
        minHits => $minHits,
        kmerSize => $kmerSize
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head2 Public Manipulation Methods

=head3 FindGenomes

    my $genomeHash = $kmers->FindGenomes($fastaFile);

Run through all the contigs in a FASTA file and use kmers to compute the sufficiently close genomes.

=over 4

=item fastaFile

The name of the FASTA file to read, or an open file handle for the FASTA file.

=item RETURN

Returns a reference to a hash mapping the IDs of genomes sufficiently close to have likely positive BLAST results to
their hit counts.

=back

=cut

sub FindGenomes {
    my ($self, $fastaFile) = @_;
    # This hash will count the hits per genome.
    my %hits;
    # Read the kmer hash.
    my $objects = SeedUtils::read_encoded_object($self->{fileName});
    my $kmerHash = $objects->{kmers};
    my $gHash = $objects->{genomes};
    # Count the contigs processed.
    my $contigCount = 0;
    # Open the FASTA file.
    my $ih;
    if (ref $fastaFile eq 'GLOB') {
        $ih = $fastaFile;
    } else {
        open($ih, "<", $fastaFile) || die "Could not open fasta file $fastaFile: $!";
    }
    my @tuples = &gjoseqlib::read_fasta($ih);
    foreach my $tuple (@tuples) {
        $self->ProcessHits($kmerHash,\%hits,[$tuple->[2]]);
    }

    # Save the genomes with a lot of hits.
    my $minHits = $self->{minHits};
    my %retVal;
    for my $genome (sort keys %hits) {
        if ($hits{$genome} >= $minHits) {
            $retVal{$genome} = [$hits{$genome}, $gHash->{$genome}];
        }
    }
    # Return the set of genomes found.
    return \%retVal;
}


=head2 Utility Methods

=head3 ProcessHits

    $kmers->ProcessHits(\%kmerHash, \%hits, \@seqs);

Record the kmer hits found in the specified sequence in the specified hash. The sequence comes in as chunks that
must be joined into a single string before processing.

=over 4

=item kmerHash

Reference to a hash that maps each protein kmer to a list of the genomes it hits.

=item hits

Reference to a hash that counts the number of hits found on each genome.

=item seqs

Reference to a list of the components of the sequence. The components are concatenated to form the final sequence.

=back

=cut

sub ProcessHits {
    my ($self, $kmerHash, $hits, $seqs) = @_;
    # Compute the kmer size in base pairs.
    my $kmerSize = $self->{kmerSize};  # in aa
    # Form the final sequence.
    my $seq = join("", @$seqs);
    foreach my $offset (0,1,2) {
        next if (length($seq) < 3);
        my $seq1 = substr($seq,$offset);      
        &hits(\$seq1,$kmerSize,$kmerHash,$hits);
        $seq1 = &SeedUtils::rev_comp($seq1);
        &hits(\$seq1,$kmerSize,$kmerHash,$hits);
    }
}

sub hits {
    my($seqP,$kmerSize,$kmerHash,$hits) = @_;

    # Loop through it, counting hits.
    my $translated = uc &SeedUtils::translate($$seqP);
    my $n = length($translated) - $kmerSize;
    for (my $i = 0; $i <= $n; $i++) {
        my $aa = substr($translated, $i, $kmerSize);
        my $genomes = $kmerHash->{$aa};
        if ($genomes) {
            for my $genome (@$genomes) {
                $hits->{$genome}++;
            }
        }
    }
}

1;
