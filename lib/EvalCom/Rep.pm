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


package EvalCom::Rep;

    use strict;
    use warnings;
    use RepGenome;
    use ScriptUtils;
    use base qw(EvalCom);

=head1 Evaluate Completeness Based on Representative Genomes

This is a subclass of L<EvalCom> that classifies genomes according to their closest representative genome rather than their taxonomic
grouping.  The theory is that this will reduce errors due to incorrect taxonomic classification and genome distribution bias.

As a fallback, the universal role tables for Archaea and Bacteria are used from the taxonomic analysis if no close representative
can be found.

The input files are found in the working directory (usually C<CheckR> in the SEEDtk global directory).  C<backup.tbl> contains the
universal roles for the Bacteria and Archaea domains.  C<weighted.tbl> contains the universal roles for each representative genome
group.

The goal of this object is to, given a GEO, find the appropriate universal-role hash to use for computing completeness and
contamination.  A universal-role hash maps role IDs to weights (see L<EvalCom>).

The object contains the following fields.

=over 4

=item domains

A hash mapping top-level domain taxon IDs to universal role hashes.

=item dNames

A hash mapping top-level domain taxon IDs to domain names.

=item repObjects

A hash mapping representative-genome group IDs to L<RepGenome> objects.  The genome name will be the group name.

=item repRoles

A hash mapping representative-genome group IDs to universal-role hashes.

=item repScores

A hash mapping representative-genome group IDs to minimum similarity scores.

=item repList

A sorted list of representative groups, with the highest-scoring ones first.

=back

=head2 Special Methods

=head3 new

    my $checker = EvalCom::Rep->new($inputDir, %options);

Create a new consistency/completeness checker from the specified input directory.

=over 4

=item inputDir

The input directory containing the C<weighted.tbl> and C<backup.tbl> files.

=item options

A hash containing zero or more of the following keys.

=over 8

=item K

The kmer length for the similarity checks.

=item logH

Open handle for an output stream to contain log messages. The default is to not write log messages.

=item stats

A L<Stats> object for tracking statistics. If none is specified, one will be created.

=back

=back

=cut

sub new {
    my ($class, $inputDir, %options) = @_;
    # Create and bless the object.
    my $retVal = EvalCom::new($class, %options);
    # Get the statistics object.
    my $stats = $retVal->stats;
    # Get the kmer size.
    my $K = $options{K} // 8;
    $retVal->{K} = $K;
    # Create the domain hashes.
    my (%domains, %dNames);
    my $groupCount = 0;
    open(my $ih, '<', "$inputDir/backup.tbl") || die "Could not open backup.tbl: $!";
    while (! eof $ih) {
        # Read the header line.
        my ($id, $name) = ScriptUtils::get_line($ih);
        $dNames{$id} = $name;
        $domains{$id} = $retVal->read_weights($ih);
        $stats->Add(domainGroupIn => 1);
        $groupCount++;
    }
    close $ih; undef $ih;
    $retVal->{dNames} = \%dNames;
    $retVal->{domains} = \%domains;
    $retVal->Log("$groupCount taxonomic groups read.\n");
    # Read the representative-genome hashes.
    my (%repObjects, %repRoles, %repScores);
    open($ih, '<', "$inputDir/weighted.tbl") || die "Could not open weighted.tbl: $!";
    $groupCount = 0;
    while (! eof $ih) {
        # Read the header line.
        my ($id, $name, $prot, $score) = ScriptUtils::get_line($ih);
        $repObjects{$id} = RepGenome->new($id, name => $name, prot => $prot);
        $repScores{$id} = $score;
        $stats->Add("group${score}In" => 1);
        # Read the universal role hash.
        $repRoles{$id} = $retVal->read_weights($ih);
        $groupCount++;
    }
    $retVal->Log("$groupCount representative-genome groups read.\n");
    close $ih; undef $ih;
    $retVal->{repObjects} = \%repObjects;
    $retVal->{repScores} = \%repScores;
    $retVal->{repRoles} = \%repRoles;
    # Now we sort the groups by score limit.
    my @repList = sort { ($repScores{$b} <=> $repScores{$a}) && $a cmp $b } keys %repRoles;
    $retVal->{repList} = \@repList;
    # Return the object.
    return $retVal;
}

=head2 Virtual Methods

=head3 Choose

    my ($group, $roleH) = $checker->Choose($geo);

Select the evaluation group for this genome.  The group name and the universal role hash are returned.

This method MUST be overridden by the subclass.

=over 4

=item geo

The L<GEO> for the genome to evaluate.

=item RETURN

Returns a two-element list consisting of (0) the name of the evaluation group and (1) a hash mapping each universal role ID to its weight.

=back

=cut

sub Choose {
    my ($self, $geo) = @_;
    # These will be the return values.
    my $repGroup = '';
    my $roleHash;
    # Get the statistics object.
    my $stats = $self->{stats};
    # Get the domain hash.
    my $roleLists = $self->{domains};
    # Compute the domain taxonomic group for this GEO.  This is our backup.
    my $lineage = $geo->lineage || [];
    my @taxons = @$lineage;
    while (! $repGroup && @taxons) {
        my $domain = shift @taxons;
        if ($roleLists->{$domain}) {
            $repGroup = $self->{dNames}{$domain};
            $roleHash = $roleLists->{$domain};
        }
    }
    if (! $repGroup) {
        $self->Log($geo->id . " is not prokaryotic.\n");
        $stats->Add(noBackupGroup => 1);
    }
    # Now we do the representative-genome search.  Get the seed protein.
    my $prot = $geo->seed;
    # Get the hashes.
    my $repScores = $self->{repScores};
    my $repObjects = $self->{repObjects};
    my $repRoles = $self->{repRoles};
    my $repList = $self->{repList};
    # Find the best-scoring group.
    my $bestScore = 0;
    for my $group (@$repList) {
        my $score = $repObjects->{$group}->check_genome($prot);
        if ($score > $bestScore && $score >= $repScores->{$group}) {
            $repGroup = $repObjects->{$group}->name;
            $roleHash = $repRoles->{$group};
        }
    }
    return ($repGroup, $roleHash);
}

1;