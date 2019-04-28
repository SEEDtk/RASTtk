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


package Bin;

    use strict;
    use warnings;
    use SeedUtils;
    use Carp;
    use Bin::Contig;

=head1 Metagenomic Community Bin

A I<community bin> is a set of one or more contigs from a set of metagenomic samples. Multiple samples
are combined to produce a single set of contigs, and the contigs are then divided into bins according
to which original organism they came from. Thus, organizing metagenomic contigs into bins is a way
of separating genomes out of metagenomes.

The community bin object contains the contig IDs but not their contents. Instead, it contains information
about the contig contents that can be used to decide if bins should be combined or kept apart. The basic
binning algorithm starts with a single contig in each bin and then combines the ones that belong together.

This object contains the following fields.

=over 4

=item contigs

Reference to a list of L<Bin/Contig> objects for the contained contigs.

=item refGenomes

Reference to a sorted list of genome IDs, consisting of all the reference genomes sufficiently close to one or more of the
contigs in the bin.

=item uniProts

Reference to a hash mapping each universal protein role ID to a count of the number of times the role is found in the
bins.

=item taxonID

If present, the proposed taxonomy ID for the bin.

=item name

If present, the proposed genome name for the bin.

=back

=head2 Bin Exchange Format

A bin containing a single contig can be read from a tab-delimited file. The file will contain five records, as follows

=over 4

=item 1

The contig ID followed by the contig length and the mean coverage.

=item 2

The close reference genome IDs.

=item 3

The IDs of the universal roles found in the contig.

=back

Note the assumption that each universal role only occurs once per contig. In addition, a file can contain multiple
single-contig bins that can be read sequentially as follows.

    my @contigs;
    open(my $ih, "<$fileName");
    while (! eof $ih) {
        push @contigs, Bin->new_from_file($ih);
    }

=head2 Special Methods

=head3 new_from_file

    my $bin = Bin->new_from_file($ih);

Create a single-contig bin from an open input file. The file must be tab-delimited, positioned on the first of the five
records containing the contig data.

=over 4

=item ih

Open input handle for the input file.

=back

=cut

sub new_from_file {
    # Get the parameters.
    my ($class, $ih) = @_;
    # Read the contig ID and length.
    my ($id, $len, $covg) = SeedUtils::fields_of($ih);
    # Read the close-reference genome IDs. Note that we need to deal with a blank line reading as a null string.
    my @genomes = grep { $_ } SeedUtils::fields_of($ih);
    # Read the universal protein IDs.
    my %uniProts = map { $_ => 1 } grep { $_ } SeedUtils::fields_of($ih);
    # Create the object to return.
    my $contig = Bin::Contig->new($id, $len, $covg);
    my $retVal = {
        contigs => [$contig],
        refGenomes => [sort @genomes],
        uniProts => \%uniProts
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head3 new_from_json

    my $bin = Bin->new_from_json($ih);

Create a bin from a json-encoded file. The bin will be read from an open file handle.

=over 4

=item ih

Open file handle positioned on the json-encoded bin.

=back

=cut

sub new_from_json {
    my ($class, $ih) = @_;
    # Read the object from the JSON file.
    my @parts;
    my $line = <$ih>;
    while (substr($line, 0, 2) ne "//") {
        push @parts, $line;
        $line = <$ih>;
    }
    my $json = join("", @parts);
    my $retVal = SeedUtils::read_encoded_object(\$json);
    # Bless the contig objects.
    $retVal->{contigs} = [map { Bin::Contig->new(@$_) } @{$retVal->{contigs}}];
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head3 new_copy

    my $bin = Bin->new_copy($bin2);

Create a new bin by copying an old one.

=over 4

=item bin2

Bin object to copy.

=back

=cut

sub new_copy {
    my ($class, $bin2) = @_;
    # Copy the arrays.
    my $refs = [ $bin2->refGenomes ];
    my $contigs = [@{$bin2->{contigs}}];
    # Copy the hash.
    my $uniProts2 = $bin2->uniProts;
    my %uniProts;
    for my $prot (keys %$uniProts2) {
        $uniProts{$prot} = $uniProts2->{$prot};
    }
    # Create the object.
    my $retVal = {
        contigs => $contigs,
        refGenomes => $refs,
        uniProts => \%uniProts
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head3 new

    my $bin = Bin->new($contigID, $len, $covg);

Create a new, blank bin for a single contig.

=over 4

=item contigID

ID of the single contig to be in this bin.

=item len

Length of the contig, in base pairs.

=item covg

Mean coverage of the contig.

=back

=cut

sub new {
    my ($class, $contigID, $len, $covg) = @_;
    # Create the object.
    my $retVal = {
        contigs => [Bin::Contig->new($contigID, $len, $covg)],
        refGenomes => [],
        uniProts => {}
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}


=head3 ReadBins

    my $binList = Bin::ReadBins($ih);

or

    my $binList = Bin::ReadBins($fileName);

Read a list of bins from a file. The file should contain one or more JSON strings encoded from bin objects.

=over 4

=item ih

An open input file handle or the name of the input file.

=item RETURN

Returns a reference to a list of bin objects read from the file.

=back

=cut

sub ReadBins {
    my ($ih) = @_;
    # Insure we have an open file handle.
    if (! ref $ih) {
        open(my $fh, "<", $ih) || die "Could not open file $ih: $!";
        $ih = $fh;
    }
    # This will be the return list.
    my @retVal;
    # Loop through the file, reading bin objects.
    while (! eof $ih) {
        push @retVal, Bin->new_from_json($ih);
    }
    # Return the list of bins.
    return \@retVal;
}

=head3 ReadContigs

    my $binList = Bin::ReadContigs($ih);

or

    my $binList = Bin::ReadContigs($fileName);

Read a list of bins from a file. The file should contain one or more single-contig bin specifications in
tab-delimited form. Each such specification contains five records, as described in L</Bin Exchange Format>.

=over 4

=item ih

An open input file handle or the name of the input file.

=item RETURN

Returns a reference to a list of bin objects read from the file.

=back

=cut

sub ReadContigs {
    my ($ih) = @_;
    # Insure we have an open file handle.
    if (! ref $ih) {
        open(my $fh, "<", $ih) || die "Could not open file $ih: $!";
        $ih = $fh;
    }
    # This will be the return list.
    my @retVal;
    # Loop through the file, reading bin objects.
    while (! eof $ih) {
        push @retVal, Bin->new_from_file($ih);
    }
    # Return the list of bins.
    return \@retVal;
}

=head3 cmp

    my $val = Bin::cmp($a, $b);

Compare two bins. Sort the one with the most universal proteins first, and after that, the one with the biggest length.

=over 4

=item a

First Bin to compare.

=item b

Second Bin to compare.

=back

=cut

sub cmp {
    my ($a, $b) = @_;
    my $aUni = scalar keys %{$a->{uniProts}};
    my $bUni = scalar keys %{$b->{uniProts}};
    my $retVal = ($bUni <=> $aUni);
    if (! $retVal) {
        $retVal = ($b->len <=> $a->len);
    }
    return $retVal;
}

=head2 Member Access Methods

=head3 contigs

    my @contigs = $bin->contigs;

Return the list of contigs in this bin.

=cut

sub contigs {
    my ($self) = @_;
    return map { $_->id } @{$self->{contigs}};
}

=head3 all_contigs

    my $contigObjs = $bin->all_contigs;

Return a reference to the list of contig objects for this bin.

=cut

sub all_contigs {
    my ($self) = @_;
    return $self->{contigs};
}

=head3 contig1

    my $contigID = $bin->contig1;

Return the ID of the first contig in the bin. This is used as the bin ID.

=cut

sub contig1 {
    my ($self) = @_;
    return $self->{contigs}[0]->id;
}

=head3 contigCount

    my $count = $bin->contigCount;

Return the number of contigs in this bin.

=cut

sub contigCount {
    my ($self) = @_;
    return scalar @{$self->{contigs}};
}

=head3 len

    my $len = $bin->len;

Return the total length of the contigs in this bin.

=cut

sub len {
    my ($self) = @_;
    my $retVal = 0;
    for my $contig (@{$self->{contigs}}) {
        $retVal += $contig->len;
    }
    return $retVal;
}

=head3 coverage

    my $coverage = $bin->coverage;

Return the mean coverage for this bin.

=cut

sub coverage {
    my ($self) = @_;
    my ($retVal, $count) = (0, 0);
    for my $contig (@{$self->{contigs}}) {
        $retVal += $contig->covg;
        $count++;
    }
    if ($count > 0) { $retVal /= $count; }
    return $retVal;
}

=head3 name

    my $name = $bin->name;

Return the name of the bin (if any).

=cut

sub name {
    my ($self) = @_;
    return $self->{name};
}

=head3 taxonID

    my $taxonID = $bin->taxonID;

Return the taxonomy ID of the bin (if any).

=cut

sub taxonID {
    my ($self) = @_;
    return $self->{taxonID};
}

=head3 refGenomes

    my @refGenomes = $bin->refGenomes;

Return the list of close reference genomes for this bin.

=cut

sub refGenomes {
    my ($self) = @_;
    return @{$self->{refGenomes}};
}

=head3 hasHits

    my $flag = $bin->hasHits;

Return TRUE if this bin has reference genomes attached to it.

=cut

sub hasHits {
    my ($self) = @_;
    return ((scalar @{$self->{refGenomes}}) ? 1 : 0);
}

=head3 uniProts

    my $uniProtH = $bin->uniProts;

Return a reference to a hash mapping each universal protein role ID to the number of times it occurs in the bin.

=cut

sub uniProts {
    my ($self) = @_;
    return $self->{uniProts};
}

=head2 Public Manipulation Methods

=head3 Merge

    $bin->Merge($bin2);

Merge another bin into this bin. This involves adding the other bin's contigs and merging together the
scoring data.

=over 4

=item bin2

Another L<Bin> object whose contigs are to be added to this bin.

=back

=cut

sub Merge {
    my ($self, $bin2) = @_;
    # Add the other bin's contigs.
    push @{$self->{contigs}}, @{$bin2->{contigs}};
    # Combine the reference genomes.
    my %refs = map { $_ => 1 } ($self->refGenomes, $bin2->refGenomes);
    $self->{refGenomes} = [sort keys %refs];
    # Combine the universal roles.
    my $roles1 = $self->uniProts;
    my $roles2 = $bin2->uniProts;
    for my $role (keys %$roles2) {
        $roles1->{$role} += $roles2->{$role};
    }
}

=head3 AdjustContigList

    $bin->AdjustContigList(\@contigIDs);

Remove any contigs not in the provided contig list.

=over 4

=item contigIDs

Reference to a list of contig IDs.

=back

=cut

sub AdjustContigList {
    my ($self, $contigIDs) = @_;
    # This will be the new contig list.
    my @newContigs;
    # Create a hash of eligible contig IDs.
    my %cHash = map { $_ => 1 } @$contigIDs;
    # Loop through the old contig objects.
    my $oldContigs = $self->{contigs};
    for my $contig (@$oldContigs) {
        if ($cHash{$contig->id}) {
            push @newContigs, $contig;
        }
    }
    $self->{contigs} = \@newContigs;
}

=head3 set_name

    $bin->set_name($name, $taxonID);

Store the bin's name and taxonomy ID.

=over 4

=item name

Proposed name of the bin.

=item taxonID

Proposed taxonomy ID for the bin.

=back

=cut

sub set_name {
    my ($self, $name, $taxonID) = @_;
    $self->{name} = $name;
    $self->{taxonID} = $taxonID;
}

=head3 set_coverage

    $bin->set_coverage(\@coverages);

or

    $bin->set_coverage($coverage);

Store the mean coverage for this bin.

=over 4

=item converages

Reference to a list of coverage numbers.  These are averaged together to get the mean.

=item coverage

The mean coverage to store.

=back

=cut

sub set_coverage {
    my ($self, $coverages) = @_;
    # Insure we have a vector.
    if (! ref $coverages) {
        $coverages = [$coverages];
    }
    my ($total, $count) = (0, 0);
    for my $covg (@$coverages) {
        $total += $covg;
        $count++;
    }
    if ($count) {
        $total /= $count;
    }
    # Assign this coverage to all the contigs.
    for my $contig (@{$self->{contigs}}) {
        $contig->set_coverage($total);
    }
}

=head3 add_ref

    $bin->add_ref(@genomes);

Add a list of reference genomes to this bin's list of close reference genomes.

=over 4

=item genomes

List of IDs for the genomes to add.

=back

=cut

sub add_ref {
    my ($self, @genomes) = @_;
    # Check for blanks.
    my $count = grep { ! $_ } @genomes;
    if ($count) {
        confess "Blank reference genome found.\n";
    }
    # Compute the new genome list and sort it.
    $self->{refGenomes} = [ sort (@{$self->{refGenomes}}, @genomes) ];
}

=head3 add_prots

    $bin->add_prots(@prots);

Increment the counts for the specified universal proteins.

=over 4

=item prots

List of universal protein role IDs.

=back

=cut

sub add_prots {
    my ($self, @prots) = @_;
    # Get the universal protein hash.
    my $uniProts = $self->{uniProts};
    # Loop through the incoming proteins.
    for my $prot (@prots) {
        $uniProts->{$prot}++;
    }
}

=head3 incr_prot

    $bin->incr_prot($prot, $count);

Add the specified number of hits for the specified universal protein.

=over 4

=item prot

Universal protein ID.

=item count

Hit count to add.

=back

=cut

sub incr_prot {
    my ($self, $prot, $count) = @_;
    # Get the universal protein hash.
    my $uniProts = $self->{uniProts};
    # Update this protein.
    $uniProts->{$prot} += $count;
}

=head3 merge_prots

    $bin->merge_prots(@prots);

Denote that the bin contains the specified universal proteins. Unlike L</add_prots>, this does not increment counts, it
sets them to C<1>. Use this method when we are BLASTing multiple reference genomes against a single contig, because we
expect to get hits from multiple genomes against the same protein.

=over 4

=item prots

List of universal protein role IDs.

=back

=cut

sub merge_prots {
    my ($self, @prots) = @_;
    # Get the universal protein hash.
    my $uniProts = $self->{uniProts};
    # Loop through the incoming proteins.
    for my $prot (@prots) {
        $uniProts->{$prot} = 1;
    }
}


=head3 replace_prots

    $bin->replace_prots(@prots);

Denote that the bin contains the specified universal proteins. This completely erases the current universal protein data
and replaces it with the new protein list.

=over 4

=item prots

List of universal protein role IDs.

=back

=cut

sub replace_prots {
    my ($self, @prots) = @_;
    # Create a new universal protein hash.
    my %uniProts = map { $_ => 1 } @prots;
    # Save it in this object.
    $self->{uniProts} = \%uniProts;
}


=head2 Output Methods

=head3 Write

    $bin->Write($oh);

Write this object in JSON format to an output file.

=over 4

=item oh

An open output handle to which this object's JSON representation should be written.

=back

=cut

sub Write {
    my ($self, $oh) = @_;
    # Get an unblessed version of this object.
    my $copy = { %$self };
    # Unbless the contigs.
    $copy->{contigs} = [map { [ @$_ ] } @{$self->{contigs}}];
    # Write it to the output.
    SeedUtils::write_encoded_object($copy, $oh);
    # Add a trailer.
    print $oh "//\n";
}

=head3 WriteContig

    $bin->WriteContig($oh);

Write this object in L</Bin Exchange Format> to an output file. The object must be a single-contig bin.

=over 4

=item oh

An open output handle to which this object's exchange format representation should be written.

=back

=cut

sub WriteContig {
    my ($self, $oh) = @_;
    # Write the contig ID and the length.
    print $oh join("\t", $self->contig1, $self->len, $self->coverage) . "\n";
    # Write the reference genome list.
    print $oh join("\t", @{$self->{refGenomes}}) . "\n";
    # Write the universal proteins.
    print $oh join("\t", keys %{$self->{uniProts}}) . "\n";
}


1;