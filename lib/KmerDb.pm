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


package KmerDb;

    use strict;
    use warnings;
    use SeedUtils;

=head1 Manage a Kmer Database

A kmer database contains a list of all the kmers in each of several sequence collections called I<groups>. The
most common type of group is a genome, in which case each sequence is a contig. Once the database is built, we
can use it to compute the number of kmer hits in other groups (I<sources>). The hit counts provide a measure of
how close each group is to each source. If groups and sources are both genomes, then we would be using the kmer
database to determine which database genomes are closest to incoming new genomes. We use the rather uncomfortable
general terms I<group> and I<source> because we envision doing comparisons with things like protein families or
metagenomic bins.

This object has the following fields.

=over 4

=item kmerSize

The size of a kmer.

=item maxFound

The maximum number of groups in which a kmer can be found before it is considered common. Common kmers are removed from
the hash. A value of C<0> indicates no kmers will be considered common.

=item kmerHash

Reference to a hash mapping each kmer to a list reference of the groups to which it belongs.

=item groupHash

Reference to a hash mapping each group ID to the group name.

=item finalized

TRUE if the object has been finalized, else FALSE. Finalizing the object removes kmers considered too common
to be useful.

=back

=head2 Special Methods

=head3 new

    my $kmerdb = KmerDb->new(%options);

Create a new, blank KMER database. The following options are supported.

=over 4

=item kmerSize

The size of a kmer. The default is C<10>.

=item maxFound

The maximum number of groups in which a kmer can be found before it is considered common. Common kmers are removed from
the hash. The default is C<10>.

=item json

The name of a JSON file (or an open file handle) containing the group and kmer hashes. This file is created by
the L</Save> method.

=back

=cut

sub new {
    my ($class, %options) = @_;
    # Create the object.
    my $retVal = {
        kmerSize => ($options{kmerSize} // 10),
        maxFound => ($options{maxFound} // 10),
        groupHash => {},
        kmerHash => {},
        finalized => 0
    };
    # Check for a JSON file.
    if ($options{json}) {
        my $hashes = SeedUtils::read_encoded_object($options{json});
        $retVal->{groupHash} = $hashes->{groupHash};
        $retVal->{kmerHash} = $hashes->{kmerHash};
        $retVal->{kmerSize} = $hashes->{kmerSize};
        $retVal->{finalized} = 1;
    }
    # Bless and return the object.
    bless $retVal, $class;
    return $retVal;
}


=head2 Public Manipulation Methods

=head3 AddSequence

    $kmerdb->AddSequence($groupID, $sequence, $name);

Extract the kmers from the specified sequence.

=over 4

=item groupID

ID of the group to which the sequence belongs.

=item sequence

Sequence to break into kmers.

=item name (optional)

If specified, the name of the group to which the sequence belongs.

=back

=cut

sub AddSequence {
    my ($self, $groupID, $sequence, $name) = @_;
    # Get the kmer length and the location of the last kmer in the sequence.
    my $klen = $self->{kmerSize};
    my $last = length($sequence) - $klen;
    # Get the kmer hash.
    my $kmerHash = $self->{kmerHash};
    # Loop through the sequence, processing the kmers. We normalize them to
    # upper case.
    for (my $i = 0; $i < $last; $i++) {
        my $kmer = uc substr($sequence, $i, $klen);
        $kmerHash->{$kmer}{$groupID}++;
    }
    # Process the group name if we got one.
    if ($name) {
        $self->AddGroup($groupID, $name);
    }
}


=head3 AddGroup

    $kmerdb->AddGroup($groupID, $groupName);

Specify the name for a sequence group.

=over 4

=item groupID

ID of the group in question.

=item groupName

Name to associate with the ID.

=back

=cut

sub AddGroup {
    my ($self, $groupID, $groupName) = @_;
    my $groupHash = $self->{groupHash};
    $groupHash->{$groupID} = $groupName;
}

=head3 Finalize

    $kmerdb->Finalize();

Clean up the kmer hash to remove common kmers, prepapring it for use.

=cut

sub Finalize {
    my ($self) = @_;
    # Get the common-kmer threshold.
    my $maxFound = $self->{maxFound};
    # Only proceed if it is nonzero. Zero means we don't care about common kmers.
    if ($maxFound > 0) {
        # Loop through the kmers.
        my $kmerHash = $self->{kmerHash};
        for my $kmer (keys %$kmerHash) {
            # Get this kmer's list.
            my $groupHash = $kmerHash->{$kmer};
            my $count = 0;
            for my $group (keys %$groupHash) {
                $count += $groupHash->{$group};
            }
            # Are we keeping it?
            if ($count > $maxFound) {
                # No, it is too common.
                delete $kmerHash->{$kmer};
            } else {
                # Yes. Remove the duplicates.
                $kmerHash->{$kmer} = [keys %$groupHash];
            }
        }
    }
    # Denote this database is finalized.
    $self->{finalized} = 1;
}

=head3 ComputeDiscriminators

    $kmerdb->ComputeDiscriminators();

Clean up the kmer hash to remove kmers found in more than one group. This is an alternative to
L<Finalize>.

=cut

sub ComputeDiscriminators {
    my ($self) = @_;
    # Loop through the kmers.
    my $kmerHash = $self->{kmerHash};
    for my $kmer (keys %$kmerHash) {
        # Get this kmer's list and remove duplicate groups.
        my $groupHash = $kmerHash->{$kmer};
        my @groups = keys %$groupHash;
        # Is this kmer in only one group?
        if (scalar @groups == 1) {
            # Yes, keep it.
            $kmerHash->{$kmer} = \@groups;
        } else {
            # No, delete it.
            delete $kmerHash->{$kmer};
        }
    }
    # Denote this database is finalized.
    $self->{finalized} = 1;
}

=head3 Save

    $kmerdb->Save($file);

Save this kmer's hashes to a file. If the database is not finalized, it will be.

=over 4

=item file

The name of an output file, or an open output file handle, or a reference to a scalar variable. The hashes
will be converted to json format and either written to the file or stored in the variable.

=back

=cut

sub Save {
    my ($self, $file) = @_;
    # Insure we are finalized.
    if (! $self->{finalized}) {
        $self->Finalize();
    }
    # Write out the hashes.
    my $hashes = { kmerHash => $self->{kmerHash}, groupHash => $self->{groupHash}, kmerSize => $self->{kmerSize} };
    SeedUtils::write_encoded_object($hashes, $file);
}

=head2 Query Methods

=head3 kmer_list

    my $kmerList = $kmerdb->kmer_list();

Return a list of the kmers in the database.

=cut

sub kmer_list {
    # Get the parameters.
    my ($self) = @_;
    # Get the kmer hash.
    my $kmerH = $self->{kmerHash};
    # Get the keys of the hash.
    my $retVal = [keys %$kmerH];
    # Return the result.
    return $retVal;
}

=head3 groups_of

    my $groupList = $kmerdb->groups_of($kmer);

Return a list of the groups containing a specified kmer.

=over 4

=item kmer

The kmer whose group list is desired.

=item RETURN

Returns a reference to a list of group IDs, or an empty list if the kmer is not in the database.

=back

=cut

sub groups_of {
    # Get the parameters.
    my ($self, $kmer) = @_;
    # Get the kmer hash.
    my $kmerH = $self->{kmerHash};
    # Get the group list. We return an empty list if the kmer is not in the hash.
    my $hash = $kmerH->{$kmer};
    my $retVal;
    if ($hash) {
        $retVal = [keys %$hash];
    } else {
        $retVal = [];
    }
    # Return the result.
    return $retVal;
}


=head3 count_hits

    $kmerdb->count_hits($sequence, \%counts, $genetic_code);

Count the kmer hits for each group in the specified sequence.

=over 4

=item sequence

Sequence to be compared to the kmer database.

=item counts

Reference to a hash where the counts will be accumulated. The counts will be added to existing data in the
hash.

=item genetic_code (optional)

If specified, the sequence will be translated using the specified genetic code; otherwise, the sequence will
be used unmodified.

=back

=cut

sub count_hits {
    my ($self, $sequence, $counts, $genetic_code) = @_;
    # Compute the kmer length in the sequence.
    my $kmerLen = $self->{kmerSize};
    # Normalize the sequence to upper case.
    my $nsequence = uc $sequence;
    # Are we translating?
    if (! $genetic_code) {
        # No translation. Accumulate the hits on the forward strand.
        $self->accumulate_hits($nsequence, $counts);
        # Get the other strand and accumulate those hits.
        SeedUtils::rev_comp($nsequence);
        $self->accumulate_hits($nsequence, $counts);
    } else {
        # Yes. Gget the genetic code.
        my $xlateH = SeedUtils::genetic_code($genetic_code);
        # Only proceed if the sequence is long enough for at least one codon.
        if (length($sequence) >= 3) {
            # Loop through the frame start points.
            for my $offset (0,1,2) {
                # Get this frame.
                my $frame = substr($nsequence, $offset);
                # Translate it.
                my $psequence = SeedUtils::translate($frame, $xlateH);
                # Accumulate the hits.
                $self->accumulate_hits($psequence, $counts);
                # Get the other strand and translate it.
                SeedUtils::rev_comp(\$frame);
                $psequence = SeedUtils::translate($frame, $xlateH);
                # Accumulate those hits.
                $self->accumulate_hits($psequence, $counts);
            }
        }
    }
}


=head3 name

    my $groupName = $kmerdb->name($groupID);

Return the name of a group.

=over 4

=item groupID

ID of the group whose name is desired.

=item RETURN

Returns the name of the identified group. If the group is not found in the group name hash, returns
the incoming group ID.

=back

=cut

sub name {
    my ($self, $groupID) = @_;
    my $retVal = $self->{groupHash}{$groupID} // $groupID;
    return $retVal;
}

=head2 Internal Methods

=head3 accumulate_hits

    $kmerdb->accumulate_hits($sequence, \%counts);

Accumulate the kmer hits in a sequence. The sequence must already be translated if translation is
needed.

=over 4

=item sequence

Sequence to examine for kmers.

=item counts

Reference to a hash mapping group IDs to hit counts.

=back

=cut

sub accumulate_hits {
    my ($self, $sequence, $counts) = @_;
    # Get the kmer length and the hash.
    my $kmerSize = $self->{kmerSize};
    my $kmerHash = $self->{kmerHash};
    # Loop through the kmers.
    my $n = length($sequence) - $kmerSize;
    for (my $i = 0; $i <= $n; $i++) {
        my $kmer = substr($sequence, $i, $kmerSize);
        my $groups = $kmerHash->{$kmer};
        if ($groups) {
            for my $group (@$groups) {
                $counts->{$group}++;
            }
        }
    }
}

1;