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


package GEO;

    use strict;
    use warnings;
    use GenomeTypeObject;
    use RoleParse;
    use BasicLocation;
    use P3DataAPI;
    use Stats;
    use P3Utils;
    use SeedUtils;
    use URI::Escape;
    use File::Spec;
    use RepGenome;
#    use Data::Dumper;
#    use Carp;

=head1 Genome Evaluation Object

This object is used by the genome evaluation libraries-- L<EvalCon>, L<EvalCom::Tax>, L<BinningReports>, and the various scripts that
use them. Methods are provided to construct the object from a GTO or from web queries to PATRIC itself.

This object has the following fields.

=over 4

=item good_seed

TRUE if the genome has a good seed protein (Phenylalanyl tRNA synthetase alpha chain), else FALSE.

=item roleFids

Reference to a hash that maps each mapped role to a list of the IDs of the features that contain it.

=item id

The ID of the genome in question.

=item name

The name of the genome in question.

=item domain

The domain of the genome in question-- either C<Bacteria> or C<Archaea>.

=item taxon

The taxonomic grouping ID for the genome in question.

=item lineage

Reference to a list of taxonomic grouping IDs, representing the complete lineage of the genome, in order from largest group
to smallest.

=item seed

Seed protein sequence for the genome in question, if it has one.

=item gc

Genetic code for the genome.

=back

The following fields are usually passed in by the client.

=over 4

=item roleCount

The number of distinct roles found in the genome.

=item hypoCount

The total number of hypothetical protein-encoding genes found in the genome.

=item pegCount

The total number of non-hypothetical protein-encoding genes found in the genome.

=item cdsPercent

The percent of features that are protein-encoding genes.

=item hypoPercent

The percent of features that are hypothetical.

=item plfamPercent

The percent of features that belong to local protein families.

=item nameMap

Reference to a hash that maps role IDs to role names.

=item checkMap

Reference to a hash that maps role checksums to role IDs.

=back

The following optional fields may also be present.

=over 4

=item refGeo

Reference to a list of L<GEO> objects for associated reference genomes believed to be close, but of better quality.

=item fidLocs

Reference to a hash that maps each feature belonging to an mapped role to its location.

=item contigs

Reference to a hash that maps each contig ID to the contig length.

=item proteins

Reference to a hash that maps each feature to its protein sequence.

=item binContigs

Reference to a hash that maps contig IDs to the relevant sequence IDs in PATRIC.

=item gtoFile

The absolute file name of the GTO file from which this object was created (if any).

=item quality

Reference to a hash containing the following fields relating to the genome's evaluation. This is only present
if the genome has been evaluated. Note also that only a subset of these fields may be present depending on
the detail level of the evaluation.

=over 8

=item fine_consis

Fine consistency percentage.

=item coarse_consis

Coarse consistency percentage.

=item complete

Completeness percentage.

=item contam

Contamination percentage.

=item group

Name of the grouping used to compute completeness and contamination.

=item metrics

A reference to a hash of contig length metrics with the following fields.

=over 12

=item L50

The L50 of the contigs, which is the smallest number of contigs that contain 50% or more of the DNA.

=item N50

The N50 of the contig lengths, which is the largest contig such that 50% or more of the DNA is in contigs that size or
larger.

=item N70

The N70 of the contig lengths.

=item N90

The N90 of the contig lengths.

=item totlen

The total DNA length.

=item complete

C<1> if the genome is mostly complete, else C<0>.

=back

=item over_roles

Number of over-represented roles.

=item under_roles

Number of under-represented roles.

=item pred_roles

Number of predicted roles.

=item consistency_roles

Reference to a hash that maps the ID of each role examined by L<EvalCon> to a 2-tuple consisting of (0) the predicted count
and (1) the actual count.

=item completeness_roles

Reference to a hash that maps the ID of each role examined by L<EvalCom::Tax> to a 2-tuple consisting of (0) the predicted count and
(1) the actual count.

=item role_comments

Reference to a hash that maps the ID of each problematic role to an HTML comment about why it doesn't match the predictions.

=item contigs

Reference to a hash that maps the ID of each contig to a list consisting of a count of the good roles followed
by the IDs of the features containing bad roles.

=back

=back

=head2 Special Methods

=head3 CreateFromPatric

    my $gHash = GEO->CreateFromPatric(\@genomes, %options);

Create a set of genome evaluation objects directly from PATRIC.

=over 4

=item genomes

Reference to a list of PATRIC genome IDs.

=item options

A hash containing zero or more of the following keys.

=over 8

=item roleHashes

Reference to a 2-tuple containing reference to role-mapping hashes-- (0) a map of role IDs to names, and (1) a map of role checksums
to IDs. If omitted, the role hashes will be loaded from the global roles.in.subsystems file.

=item p3

Reference to a L<P3DataAPI> object for accessing PATRIC. If omitted, one will be created.

=item stats

Reference to a L<Stats> object for tracking statistical information. If omitted, the statistics will be discarded.

=item detail

Level of detail-- C<0> roles only, C<1> roles and contigs, C<2> roles, contigs, and proteins.

=item logH

Open file handle for status messages. If not specified, no messages will be written.

=item rolesToUse

If specified, a hash of role IDs. Only roles in the hash will be kept in the role maps.

=back

=item RETURN

Returns a reference to a hash that maps each genome ID to the evaluation object created for it. Genomes that were not found
in PATRIC will not be included.

=back

=cut

sub CreateFromPatric {
    my ($class, $genomes, %options) = @_;
    # This will be the return hash.
    my %retVal;
    # Get the log file.
    my $logH = $options{logH};
    # Get the stats object.
    my $stats = $options{stats} // Stats->new();
    # Process the options.
    my ($nMap, $cMap) = _RoleMaps($options{roleHashes}, $logH, $stats);
    my $p3 = $options{p3} // P3DataAPI->new();
    my $detail = $options{detail};
    my $rToUseH = $options{rolesToUse};
    # Compute the feature columns for the current mode.
    my @fCols = qw(patric_id product aa_length);
    if ($detail) {
        push @fCols, qw(sequence_id start na_length strand);
        if ($detail > 1) {
            push @fCols, qw(aa_sequence);
        }
    }
    # Now we have everything in place for loading. We start by getting the genome information.
    my $gCount = scalar @$genomes;
    $stats->Add(genomesIn => $gCount);
    _log($logH, "Requesting $gCount genomes from PATRIC.\n");
    my $genomeTuples = P3Utils::get_data_keyed($p3, genome => [], ['genome_id', 'genome_name',
            'kingdom', 'taxon_id', 'taxon_lineage_ids', 'cds_ratio', 'hypothetical_cds_ratio',
            'plfam_cds_ratio'], $genomes);
    # Now we retrieve the seed proteins.
    my %protHash;
    my $protTuples = P3Utils::get_data_keyed($p3, feature => [['eq', 'product', 'Phenylalanyl-tRNA synthetase alpha chain']],
            ['genome_id', 'product', 'aa_sequence'], $genomes, 'genome_id');
    for my $protTuple (@$protTuples) {
        my ($genome, $function, $prot) = @$protTuple;
        my @roles = SeedUtils::roles_of_function($function);
        for my $role (@roles) {
            my $checksum = RoleParse::Checksum($role);
            if ($checksum eq 'WCzieTC/aZ6262l19bwqgw') {
                my $oldseq = $protHash{$genome} // '';
                if (length($prot) > length($oldseq)) {
                    $protHash{$genome} = $prot;
                }
            }
        }
    }
    # Loop through the genomes found.  We need to keep the tax IDs for finding the genetic code.
    my %taxes;
    for my $genomeTuple (@$genomeTuples) {
        my ($genome, $name, $domain, $taxon, $lineage, $cdsRatio, $hypoRatio, $plfamRatio) = @$genomeTuple;
        push @{$taxes{$taxon}}, $genome;
        my $cdsPercent = ($cdsRatio ? $cdsRatio * 100 : '');
        my $hypoPercent = ($hypoRatio ? $hypoRatio * 100 : '');
        my $plfamPercent = ($plfamRatio ? $plfamRatio * 100 : '');
        $retVal{$genome} = { id => $genome, name => $name, domain => $domain, nameMap => $nMap, checkMap => $cMap,
            taxon => $taxon, lineage => ($lineage || []), binFlag => 0, seed => $protHash{$genome}, gc => 11,
            cdsPercent => $cdsPercent, hypoPercent => $hypoPercent, plfamPercent => $plfamPercent};
        $stats->Add(genomeFoundPatric => 1);
        # Compute the aa-len limits for the seed protein.
        my ($min, $max) = (209, 405);
        if ($domain eq 'Archaea') {
            ($min, $max) = (293, 652);
        }
        my $seedCount = 0;
        my $goodSeed = 1;
        # Now we need to get the roles. For each feature we need its product (function), ID, and protein length.
        # Depending on the detail level, we also get location and the aa-sequence.
        _log($logH, "Reading features for $genome.\n");
        my $featureTuples = P3Utils::get_data($p3, feature => [['eq', 'genome_id', $genome]],
                \@fCols);
        # These are used to count the pegs and roles.
        my %ckHash;
        my ($pegCount, $hypoCount) = (0, 0);
        # Build the role, protein, and location hashes in here.
        my (%roles, %proteins, %locs);
        for my $featureTuple (@$featureTuples) {
            $stats->Add(featureFoundPatric => 1);
            # Note that some of these will be undef if we are at a low detail level.
            my ($fid, $function, $aaLen, $contig, $start, $len, $dir, $prot) = @$featureTuple;
            if ($fid =~ /\.peg\./) {
                if (SeedUtils::hypo($function)) {
                    $hypoCount++;
                } else {
                    $pegCount++;
                }
            }
            # Only features with functions matter to us.
            if ($function) {
                my @roles = SeedUtils::roles_of_function($function);
                my $mapped = 0;
                for my $role (@roles) {
                    my $checkSum = RoleParse::Checksum($role);
                    $ckHash{$checkSum}++;
                    $stats->Add(roleFoundPatric => 1);
                    my $rID = $cMap->{$checkSum};
                    if (! $rID) {
                        $stats->Add(roleNotMapped => 1);
                    } else {
                        $stats->Add(roleMapped => 1);
                        if ($rToUseH && ! $rToUseH->{$rID}) {
                            $stats->Add(roleSkipped => 1);
                        } else {
                            push @{$roles{$rID}}, $fid;
                            $mapped++;
                            if ($rID eq 'PhenTrnaSyntAlph') {
                                $seedCount++;
                                if ($aaLen < $min) {
                                    $stats->Add(seedTooShort => 1);
                                    $goodSeed = 0;
                                } elsif ($aaLen > $max) {
                                    $stats->Add(seedTooLong => 1);
                                    $goodSeed = 0;
                                }
                            }
                        }
                    }
                }
                if ($detail && $mapped) {
                    # If we are saving details and this feature had an interesting role, we
                    # also need to save the location.
                    $locs{$fid} = BasicLocation->new([$contig, $start, $dir, $len]);
                }
                if ($prot) {
                    # If we have a protein sequence, save that too.
                    $proteins{$fid} = $prot;
                }
            }
        }
        # Store the role map.
        $retVal{$genome}{roleFids} = \%roles;
        # Store the role counts.
        $retVal{$genome}{pegCount} = $pegCount;
        $retVal{$genome}{hypoCount} = $hypoCount;
        $retVal{$genome}{roleCount} = scalar keys %ckHash;
        # Compute the good-seed flag.
        if (! $seedCount) {
            $stats->Add(seedNotFound => 1);
            $goodSeed = 0;
        } elsif ($seedCount > 1) {
            $stats->Add(seedTooMany => 1);
            $goodSeed = 0;
        }
        $retVal{$genome}{good_seed} = $goodSeed;
        # Check for the optional stuff.
        if ($detail) {
            # Here we also need to store the location map.
            $retVal{$genome}{fidLocs} = \%locs;
            # Finally, we need the contig lengths.
            _log($logH, "Reading contigs for $genome.\n");
            my %contigs;
            my $contigTuples = P3Utils::get_data($p3, contig => [['eq', 'genome_id', $genome]], ['sequence_id', 'length']);
            for my $contigTuple (@$contigTuples) {
                $stats->Add(contigFoundPatric => 1);
                my ($contigID, $len) = @$contigTuple;
                $contigs{$contigID} = $len;
            }
            $retVal{$genome}{contigs} = \%contigs;
            $retVal{$genome}{proteins} = \%proteins;
        }
    }
    # Read the taxonomy table to get the genetic codes.
    my $taxTuples = P3Utils::get_data_keyed($p3, taxonomy => [], ['taxon_id', 'genetic_code'], [keys %taxes]);
    for my $taxTuple (@$taxTuples) {
        my ($taxID, $gc) = @$taxTuple;
        my $genomes = $taxes{$taxID};
        for my $genome (@$genomes) {
            $retVal{$genome}{gc} = $gc;
        }
    }
    # Run through all the objects, blessing them.
    for my $genome (keys %retVal) {
        bless $retVal{$genome}, $class;
    }
    # Return the hash of objects.
    return \%retVal;
}

=head3 CreateFromGto

    my $geo = GEO->CreateFromGto($gto, %options);

Create a genome evaluation object from an in-memory L<GenomeTypeObject>.

=over 4

=item gto

A L<GenomeTypeObject> from which the GEO is to be created, or the name of a file containing the object in JSON form.

=item options

A hash containing zero or more of the following keys.

=over 8

=item roleHashes

Reference to a 2-tuple containing reference to role-mapping hashes-- (0) a map of role IDs to names, and (1) a map of role checksums
to IDs. If omitted, the role hashes will be loaded from the global roles.in.subsystems file.

=item p3

Reference to a L<P3DataAPI> object for accessing PATRIC. If omitted, one will be created.

=item stats

Reference to a L<Stats> object for tracking statistical information. If omitted, the statistics will be discarded.

=item detail

Level of detail-- C<0> roles only, C<1> roles and contigs, C<2> roles, contigs, and proteins.

=item logH

Open file handle for status messages. If not specified, no messages will be written.

=item binned

If TRUE, then it will be presumed this genome comes from the binning process, and the contig names are node names rather than sequence IDs.

=item external

If TRUE, then it will be presumed this genome's contig IDs are not found in PATRIC, and no contig links will be generated.

=item rolesToUse

If specified, a hash of role IDs. Only roles in the hash will be kept in the role maps.

=back

=item RETURN

Returns a GEO built from the specified L<GenomeTypeObject>.

=back

=cut

sub CreateFromGto {
    my ($class, $gto, %options) = @_;
    # Get the stats object.
    my $stats = $options{stats} // Stats->new();
    # Process the options.
    my $logH = $options{logH};
    my ($nMap, $cMap) = _RoleMaps($options{roleHashes}, $logH, $stats);
    my $p3 = $options{p3} // P3DataAPI->new();
    # Verify that we have a real GTO.
    if (! ref $gto) {
        $gto = GenomeTypeObject->create_from_file($gto);
    }
    # Create the GEO and bless it.
    my $retVal = _BuildGeo($gto, $p3, $nMap, $cMap, $stats, \%options);
    bless $retVal, $class;
    # Compute the taxonomic lineage, if needed.
    if (! $retVal->{lineage}) {
        my $taxon = $retVal->taxon;
        my $taxResults = P3Utils::get_data_keyed($p3, taxonomy => [], ['taxon_id', 'lineage_ids'], [$taxon]);
        # Default to just the input taxon ID.
        my $lineage = [$taxon];
        # Update if we got something. Note we can get a null string even if a result did come back.
        if (@$taxResults) {
            $lineage = $taxResults->[0][1] || [$taxon];
        }
        $retVal->{lineage} = $lineage;
    }
    # Return the result.
    return $retVal;
}

=head3 CreateFromGtoFiles

    my $gHash = GEO->CreateFromGtoFiles(\@files, %options);

Create a set of genome evaluation objects from L<GenomeTypeObject> files.

=over 4

=item files

Reference to a list of file names, each containing a L<GenomeTypeObject> in JSON form.

=item options

A hash containing zero or more of the following keys.

=over 8

=item roleHashes

Reference to a 2-tuple containing reference to role-mapping hashes-- (0) a map of role IDs to names, and (1) a map of role checksums
to IDs. If omitted, the role hashes will be loaded from the global roles.in.subsystems file.

=item p3

Reference to a L<P3DataAPI> object for accessing PATRIC. If omitted, one will be created.

=item stats

Reference to a L<Stats> object for tracking statistical information. If omitted, the statistics will be discarded.

=item detail

Level of detail-- C<0> roles only, C<1> roles and contigs, C<2> roles, contigs, and proteins.

=item logH

Open file handle for status messages. If not specified, no messages will be written.

=item binned

If TRUE, then it will be presumed this genome comes from the binning process, and the contig names are node names rather than sequence IDs.

=item external

If TRUE, then it will be presumed this genome's contig IDs are not found in PATRIC, and no contig links will be generated.

=item rolesToUse

If specified, a hash of role IDs. Only roles in the hash will be kept in the role maps.

=back

=item RETURN

Returns a reference to a hash that maps each genome ID to the evaluation object created for it. Genomes files that were not
found will be ignored.

=back

=cut

sub CreateFromGtoFiles {
    my ($class, $files, %options) = @_;
    # This will be the return hash.
    my %retVal;
    # Get the log file.
    my $logH = $options{logH};
    # Get the stats object.
    my $stats = $options{stats} // Stats->new();
    # Process the options.
    my ($nMap, $cMap) = _RoleMaps($options{roleHashes}, $logH, $stats);
    my $p3 = $options{p3} // P3DataAPI->new();
    # Loop through the GTO files.
    for my $file (@$files) {
        $stats->Add(genomesIn => 1);
        _log($logH, "Processing genome file $file.\n");
        my $gto = GenomeTypeObject->create_from_file($file);
        if (! $gto) {
            _log($logH, "No genome found in $file.\n");
        } else {
            $stats->Add(genomeFoundFile => 1);
            # Build the GEO.
            my $geo = _BuildGeo($gto, $p3, $nMap, $cMap, $stats, \%options);
            # Get the absolute file name.
            $geo->{gtoFile} = File::Spec->rel2abs($file);
            # Store the GEO.
            $retVal{$geo->{id}} = $geo;
        }
    }
    # Run through all the objects, blessing them and extracting the taxonomic IDs of the ones that need lineages.
    my %taxons;
    my $lineageNeeded;
    for my $genome (keys %retVal) {
        my $geo = $retVal{$genome};
        bless $geo, $class;
        if (! $geo->{lineage}) {
            push @{$taxons{$geo->taxon}}, $geo;
            $lineageNeeded = 1;
        }
    }
    # Get the lineage for each GEO that needs one.
    if ($lineageNeeded) {
        my $taxResults = P3Utils::get_data_keyed($p3, taxonomy => [], ['taxon_id', 'lineage_ids'], [keys %taxons]);
        for my $taxResult (@$taxResults) {
            my ($taxon, $lineage) = @$taxResult;
            $lineage ||= [$taxon];
            my $geos = $taxons{$taxon} // [];
            for my $geo (@$geos) {
                $geo->{lineage} = $lineage;
            }
        }
    }
    # Return the hash of objects.
    return \%retVal;
}

# Good/Bad criteria
sub MIN_CHECKM { return 80; }
sub MIN_SCIKIT { return 87; }
sub MAX_CONTAM { return 10; }

=head3 completeX

    my $ok = GEO::completeX($pct);

Return TRUE if the specified percent complete is sufficient.

=over 4

=item pct

A percent completeness.

=item RETURN

Returns TRUE if the value is high enough, else FALSE.

=back

=cut

sub completeX {
    my ($pct) = @_;
    return ($pct >= MIN_CHECKM);
}

=head3 consistX

    my $ok = GEO::consistX($pct);

Return TRUE if the specified percent fine consistency is sufficient.

=over 4

=item pct

A percent fine consistency.

=item RETURN

Returns TRUE if the value is high enough, else FALSE.

=back

=cut

sub consistX {
    my ($pct) = @_;
    return ($pct >= MIN_SCIKIT);
}

=head3 contamX

    my $ok = GEO::contamX($pct);

Return TRUE if the specified percent contamination is acceptable.

=over 4

=item pct

A percent of genome contamination.

=item RETURN

Returns TRUE if the value is low enough, else FALSE.

=back

=cut

sub contamX {
    my ($pct) = @_;
    return ($pct <= MAX_CONTAM);
}

=head3 qscoreX

    my $score = GEO::qscoreX($coarse, $fine, $complete, $contam);

Return the overall quality score from the basic quality metrics-- coarse consistency, fine consistency, completeness, and contamination.

=over 4

=item coarse

The coarse consistency, in percent.

=item fine

The fine consistency, in percent.

=item complete

The percent completeness.

=item contam

The percent contamination.

=item RETURN

Returns a number from -500 to 209 indicating the relative quality of the genome.

=back

=cut

sub qscoreX {
    my ($coarse, $fine, $complete, $contam) = @_;
    my $retVal = $fine * 1.09 + $complete - 5 * $contam;
    return $retVal;
}

=head3 closest_protein

    my ($id, $score) = GEO::closest_protein($target, \%others, $k);

Use kmers to compute which of the specified other proteins is closest to the target. The ID of the closest protein will be returned, along with its score.

=over 4

=item target

The target protein.

=item others

Reference to a hash mapping IDs to protein sequences.

=item k

The proposed kmer size. The default is C<8>.

=item RETURN

Returns the ID of the closest protein and its kmer similarity score. An undefined ID will be returned if no similarity exists.

=back

=cut

sub closest_protein {
    my ($target, $others, $k) = @_;
    $k //= 8;
    # Create a kmer hash for the target.
    my %kHash;
    my $n = length($target) - $k;
    for (my $i = 0; $i <= $n; $i++) {
        $kHash{substr($target, $i, $k)} = 1;
    }
    # These will be the return values.
    my ($id, $score) = (undef, 0);
    # Test all the other sequences.
    for my $seqID (sort keys %$others) {
        my $sequence = $others->{$seqID};
        my $newScore = 0;
        my $n = length($sequence) - $k;
        for (my $i = 0; $i < $n; $i++) {
            if ($kHash{substr($sequence, $i, $k)}) {
                $newScore++;
            }
        }
        if ($newScore > $score) {
            $id = $seqID;
            $score = $newScore;
        }
    }
    return ($id, $score);
}

=head3 FindBBHs

    my (\@pairs, \@orphans1, \@orphans2) = GEO::FindBBHs(\%prots1, \%prots2);

Find the bidirectional best hits between two sets of proteins.

=over 4

=item prots1

A reference to a hash mapping IDs to protein sequences.  This is the first set.

=item prots2

A reference to a hash mapping IDs to protein sequences.  This is the second set.

=item RETURN

Returns a three-element list, consisting of (0) a reference to a list of 3-tuples describing the bidirectional
best hit pairs in the form [id1, id2, score], (1) a reference to a list of the IDs in the first set not having a match,
and (2) a reference to a list of the IDs in the second set not having a match.

=back

=cut

sub FindBBHs {
    my ($prots1, $prots2) = @_;
    # We start by computing all the pair-wise distances.
    my %scores;
    for my $id1 (keys %$prots1) {
        my $rep1 = RepGenome->new($id1, prot => $prots1->{$id1});
        for my $id2 (keys %$prots2) {
            my $score = $rep1->check_genome($prots2->{$id2});
            # Only store a nonzero score.
            if ($score) {
                $scores{$id1}{$id2} = $score;
                $scores{$id2}{$id1} = $score;
            }
        }
    }
    # This will hold the best-match pairs.
    my @pairs;
    # These hashes track the orphans.
    my %orphans1 = map { $_ => 1 } keys %$prots1;
    my %orphans2 = map { $_ => 1 } keys %$prots2;
    # Now we find the bidirectional best hits for each protein in set 1.
    for my $id1 (keys %$prots1) {
        # Get the best matches for this protein.
        my ($bestId2L, $score) = _find_best_match($id1, \%scores);
        # Now we loop through the IDs returned.  If one of them has us for a best match, we keep it.
        my $done;
        while (! $done) {
            my $id2 = pop @$bestId2L;
            if (! $id2) {
                $done = 1;
            } else {
                my ($bestId1L) = _find_best_match($id2, \%scores);
                if (grep { $_ eq $id1 } @$bestId1L) {
                    push @pairs, [$id1, $id2, $score];
                    $orphans1{$id1} = 0;
                    $orphans2{$id2} = 0;
                    $done = 1;
                }
            }
        }
    }
    # The final step is to compute the orphans.
    my @orphans1 = grep { $orphans1{$_} } keys %orphans1;
    my @orphans2 = grep { $orphans2{$_} } keys %orphans2;
    # Return the three lists.
    return (\@pairs, \@orphans1, \@orphans2);
}

=head2 Query Methods

=head3 id

    my $genomeID = $geo->id;

Return the ID of this genome.

=cut

sub id {
    my ($self) = @_;
    return $self->{id};
}

=head3 gc

    my $genetic_code = $geo->gc

Return the genetic code for this genome's proteins.

=cut

sub gc {
    my ($self) = @_;
    return $self->{gc};
}

=head3 domain

    my $domain = $geo->domain

Return the domain for this genome.

=cut

sub domain {
    my ($self) = @_;
    return $self->{domain};
}

=head3 pegCount

    my $genomeID = $geo->pegCount;

Return the total number of non-hypothetical protein-encoding genes in this genome.

=cut

sub pegCount {
    my ($self) = @_;
    return $self->{pegCount};
}

=head3 hypoCount

    my $genomeID = $geo->hypoCount;

Return the total number of hypothetical protein-encoding genes in this genome.

=cut

sub hypoCount {
    my ($self) = @_;
    return $self->{hypoCount};
}

=head3 roleCount

    my $genomeID = $geo->roleCount;

Return the number of distinct roles in this genome.

=cut

sub roleCount {
    my ($self) = @_;
    return $self->{roleCount};
}

=head3 cdsPercent

    my $genomeID = $geo->cdsPercent;

Return the percent of features that are protein-encoding genes in this genome.

=cut

sub cdsPercent {
    my ($self) = @_;
    return $self->{cdsPercent};
}

=head3 hypoPercent

    my $genomeID = $geo->hypoPercent;

Return the percent of features that are hypothetical proteins in this genome.

=cut

sub hypoPercent {
    my ($self) = @_;
    return $self->{hypoPercent};
}

=head3 plfamPercent

    my $genomeID = $geo->plfamPercent;

Return the percent of features that are in local protein families in this genome.

=cut

sub plfamPercent {
    my ($self) = @_;
    return $self->{plfamPercent};
}

=head3 lineage

    my $lineageL = $geo->lineage;

Return a reference to a list of the IDs in the taxonomic lineage, or C<undef> if the lineage is not available.

=cut

sub lineage {
    my ($self) = @_;
    return $self->{lineage};
}

=head3 seed

    my $prot = $geo->seed;

Return the amino acid sequence of the seed protein.

=cut

sub seed {
    my ($self) = @_;
    return ($self->{seed} // '');
}

=head3 roleCounts

    my $roleH = $geo->roleCounts;

Return a hash mapping each role ID to its number of occurrences.

=cut

sub roleCounts {
    my ($self) = @_;
    my $roleMap = $self->{roleFids};
    my %retVal = map { $_ => scalar(@{$roleMap->{$_}}) } keys %$roleMap;
    return \%retVal;
}

=head3 roleMetrics

    my ($predicted, $actual, $comment) = $geo->roleMetrics($role);

Return the predicted count, actual count, and explanatory comment for the role with the specified ID. The numbers will only be meaningful
if quality data is present in the GEO.

=over 4

=item role

The ID of the role whose information is desired.

=item RETURN

Returns a 3-element list containing (0) the number of occurrences predicted, (1) the actual number of occurrences, and (2) an HTML comment.

=back

=cut

sub roleMetrics {
    my ($self, $role) = @_;
    my ($predicted, $actual, $comment) = (0, 0, '');
    my $quality = $self->{quality};
    if ($quality) {
        # Default to the completeness prediction.
        my $tuple = $quality->{completeness_roles}{$role};
        if ($tuple) {
            ($predicted, $actual, $comment) = (@$tuple, 'Universal role.');
        }
        # If there is a consistency prediction, it overrides if (1) it indicates a problem or (2)
        # the completeness prediction does not indicate a problem.
        $tuple = $quality->{consistency_roles}{$role};
        if ($tuple && ($tuple->[0] != $tuple->[1] || $predicted == $actual)) {
            ($predicted, $actual) = @$tuple;
        }
        # Check for a comment. If one exists, it overrides anything we have.
        if ($quality->{role_comments}) {
            $comment = $quality->{role_comments}{$role} || $comment;
        }
    }
    # Return the results.
    return ($predicted, $actual, $comment);
}


=head3 good_seed

    my $seedFlag = $geo->good_seed;

Return TRUE if this genome has a good seed protein, else FALSE.

=cut

sub good_seed {
    my ($self) = @_;
    return $self->{good_seed};
}

=head3 is_good

    my $goodFlag = $geo->is_good;

Return TRUE if this is a good genome, FALSE if it is not good or has not been evaluated.

=cut

sub is_good {
    my ($self) = @_;
    my $retVal = ($self->good_seed && $self->is_consistent && $self->is_complete && $self->is_clean);
    return $retVal;
}

=head3 taxon

    my $taxon = $geo->taxon;

Return the taxonomic ID for this genome.

=cut

sub taxon {
    my ($self) = @_;
    return $self->{taxon};
}

=head3 qscore

    my $score = $geo->qscore;

Return a measure of the quality of this genome. This only works if the quality data has been added by L</AddQuality>.

=cut

sub qscore {
    my ($self) = @_;
    my $retVal = 0;
    my $qHash = $self->{quality};
    if ($qHash) {
        $retVal = $qHash->{fine_consis} * 1.09 + $qHash->{complete} - 5 * $qHash->{contam};
    }
    return $retVal;
}

=head3 quality

    my $quality = $geo->quality;

Return the hash containing the genome's quality analysis data. If the genome has not been evaluated, this will return C<undef>.

=cut

sub quality {
    my ($self) = @_;
    return $self->{quality};
}


=head3 metrics

    my $metricsH = $geo->metrics;

Return the contig-length metrics hash from the quality member.

=cut

sub metrics {
    my ($self) = @_;
    return $self->{quality}{metrics};
}

=head3 name

    my $name = $geo->name;

Return the name of the genome.

=cut

sub name {
    my ($self) = @_;
    return $self->{name};
}

=head3 contigCount

    my $count = $geo->contigCount;

Return the number of contigs in the genome. If this object is abridged, it will return C<undef>.

=cut

sub contigCount {
    my ($self) = @_;
    my $retVal;
    my $contigs = $self->{contigs};
    if ($contigs) {
        $retVal = scalar keys %$contigs;
    }
    return $retVal;
}

=head3 refList

    my $refGeoList = $geo->refList;

Return a reference to a list of the reference genome L<GEO> objects. If there are none, an empty list will be returned.

=cut

sub refList {
    my ($self) = @_;
    my $retVal = $self->{refGeo} // [];
    return $retVal;
}

=head3 bestRef

    my $refGeo = $geo->bestRef

Return the best reference genome in the reference genome list (defined as having the closest ID number), or C<undef> if there are no reference genomes.

=cut

sub bestRef {
    my ($self) = @_;
    my $retVal;
    my $base = $self->{id};
    my $refsL = $self->{refGeo} // [];
    my @refs = @$refsL;
    if (scalar @refs) {
        $retVal = pop @refs;
        my $min = abs($base - $retVal->{id});
        for my $ref (@refs) {
            my $dist = abs($base - $ref->{id});
            if ($dist < $min) {
                $min = $dist;
                $retVal = $ref;
            }
        }
    }
    return $retVal;
}

=head3 protein

    my $aaSequence = $geo->protein($fid);

Return the protein sequence for the specified feature, or C<undef> if protein sequences are not available.

=over 4

=item fid

The feature ID of the desired protein.

=item RETURN

Returns the protein sequence for the specified feature, or C<undef> if the protein sequence is not available.

=back

=cut

sub protein {
    my ($self, $fid) = @_;
    return $self->{proteins}{$fid};
}


=head3 roleStats

    my ($over, $under, $predictable, $comp) = $geo->roleStats;

Return the number of roles over-represented, under-represented, the number for which there are predictions, and the number used for the completeness check.
If no quality data is present, these will all be zero.

=cut

sub roleStats {
    my ($self) = @_;
    my @retVal;
    my $qData = $self->{quality};
    if ($qData) {
        @retVal = ($qData->{over_roles}, $qData->{under_roles}, $qData->{pred_roles});
        my $cRoles = $qData->{completeness_roles};
        push @retVal, scalar keys %$cRoles;
    } else {
        @retVal = (0, 0, 0, 0);
    }
    return @retVal;
}

=head3 roleReport

    my $roleHash = $geo->roleReport;

Return a hash of all the problematic roles. Each role ID will map to a 3-tuple-- (0) predicted occurrences, (1) actual occurrences, (2) HTML comment.

=cut

sub roleReport {
    my ($self) = @_;
    my %retVal;
    my $qData = $self->{quality};
    if ($qData) {
        my $commentsH = $qData->{role_comments} // {};
        for my $hash ($qData->{completeness_roles}, $qData->{consistency_roles}) {
            for my $role (keys %$hash) {
                my ($predicted, $actual) = @{$hash->{$role}};
                if ($predicted != $actual) {
                    my $comment = $commentsH->{$role} // '';
                    $retVal{$role} = [$predicted, $actual, $comment];
                }
            }
        }
    }
    return \%retVal;
}

=head3 contigReport

    my $contigHash = $geo->contigReport;

Returns a hash of all the problematic contigs. Each contig ID will map to a count of good roles followed by a list of the bad ones.

=cut

sub contigReport {
    my ($self) = @_;
    my $retVal = {};
    my $qData = $self->{quality};
    if ($qData) {
        $retVal = $qData->{contigs};
    }
    return $retVal;
}

=head3 contigLen

    my $len = $geo->contigLen($contigID);

Return the length of the specified contig (if known).

=over 4

=item contigID

The ID of a contig in this genome.

=item RETURN

Returns the length of the contig in base pairs, or C<0> if the contig is not found or no contig data is present.

=back

=cut

sub contigLen {
    my ($self, $contigID) = @_;
    my $contigH = $self->{contigs};
    my $retVal = 0;
    if ($contigH) {
        $retVal = $contigH->{$contigID} // 0;
    }
    return $retVal;
}

=head3 roleFids

    my $fidList = $geo->roleFids($role);

Return all the features for the specified role ID, or an empty list if there are none.

=over 4

=item role

The ID of the role whose feature list is desired.

=item RETURN

Returns a reference to a list of the IDs for the features that implement the role.

=back

=cut

sub roleFids {
    my ($self, $role) = @_;
    my $retVal = $self->{roleFids}{$role} // [];
    return $retVal;
}

=head3 fidLoc

    my $loc = $geo->fidLoc($fid);

Return the location of a feature in the genome.  This only works at detail level 1 or better.

=over 4

=item fid

The ID of the feature whose location is desired.

=item RETURN

Returns a L<BasicLocation> object for the feature, or C<undef> if the feature does not exist or the detail level is
insufficient.

=back

=cut

sub fidLoc {
    my ($self, $fid) = @_;
    my $retVal;
    my $fidLocs = $self->{fidLocs};
    if ($fidLocs) {
        $retVal = $fidLocs->{$fid};
    }
    return $retVal;
}

=head3 fidProt

    my $prot = $geo->fidPProt($fid);

Return the protein sequence of a feature in the genome.  This only works at detail level 2 or better.

=over 4

=item fid

The ID of the feature whose protein sequence is desired.

=item RETURN

Returns the amino acid sequence of the protein, or C<undef> if the feature does not exist or the detail level is
insufficient.

=back

=cut

sub fidProt {
    my ($self, $fid) = @_;
    my $retVal;
    my $proteins = $self->{proteins};
    if ($proteins) {
        $retVal = $proteins->{$fid};
    }
    return $retVal;
}

=head3 protMap

    my $protHash = $geo->protMap;

Return a reference to a hash mapping each feature ID to its protein sequence.  This only works if we are at detail
level 2.

=cut

sub protMap {
    my ($self) = @_;
    return $self->{proteins} // {};
}

=head3 is_consistent

    my $goodFlag = $geo->is_consistent;

Return TRUE if this genome's annotations are sufficiently consistent. If the quality data is not present, it will automatically return FALSE.

=cut

sub is_consistent {
    my ($self) = @_;
    my $retVal = 0;
    my $qData = $self->{quality};
    if ($qData) {
        $retVal = consistX($qData->{fine_consis});
    }
    return $retVal;
}

=head3 is_complete

    my $goodFlag = $geo->is_complete;

Return TRUE if this genome is sufficiently complete. If the quality data is not present, it will automatically return FALSE.

=cut

sub is_complete {
    my ($self) = @_;
    my $retVal = 0;
    my $qData = $self->{quality};
    if ($qData) {
        $retVal = completeX($qData->{complete});
    }
    return $retVal;
}

=head3 is_clean

    my $goodFlag = $geo->is_clean;

Return TRUE if this genome is sufficiently free of contamination. If the quality data is not present, it will automatically return FALSE.

=cut

sub is_clean {
    my ($self) = @_;
    my $retVal = 0;
    my $qData = $self->{quality};
    if ($qData) {
        $retVal = contamX($qData->{contam});
    }
    return $retVal;
}

=head3 gtoFile

    my $fileName = $geo->gtoFile;

Return the name of the GTO file that created this object, if any.

=cut

sub gtoFile {
    my ($self) = @_;
    return $self->{gtoFile};
}

=head3 contig_link

    my $html = $geo->contig_link($contigID);

Return the PATRIC URL and label for the specified contig. This is complicated by the fact that the contig ID for a bin is not the sequence ID, so in
that case we have to check the map of contig IDs to sequence IDs and modify the link accordingly.

=over 4

=item contigID

The ID of the sequence of interest.

=item RETURN

Returns a hyperlink displaying the contig ID. When clicked, it will show all the proteins in the contig.

=back

=cut

sub contig_link {
    my ($self, $contigID) = @_;
    my $retVal;
    my $contigSequence = $contigID;
    if ($self->{binContigs}) {
        $contigSequence = $self->{binContigs}{$contigID};
    }
    if (! $contigSequence) {
        $retVal = $contigID;
    } else {
        $retVal = qq(<a href ="https://www.patricbrc.org/view/FeatureList/?and(eq(annotation,PATRIC),eq(sequence_id,$contigSequence),eq(feature_type,CDS))" target="_blank">$contigID</a>);
    }
    return $retVal;
}

=head3 scores

    my ($coarse, $fine, $complete, $contam, $group) = $geo->scores;

Return the quality scores for this genome in the form of a list.

=cut

sub scores {
    my ($self) = @_;
    my $qData = $self->{quality};
    my @retVal;
    if (! $qData) {
        @retVal = (0, 0, 0, 100, '');
    } else {
        @retVal = ($qData->{coarse_consis} // 0, $qData->{fine_consis} // 0, $qData->{complete} // 0, $qData->{contam} // 100, $qData->{group} // '');
    }
    return @retVal;
}


=head3 role_similarity

    my $score = $geo->role_similarity($geo2);

Return the percent of roles in common between two genomes.

=over 4

=item geo2

The L<GEO> of the genome to which this one is to be compared.

=item RETURN

Returns the percent of roles the two genomes have in common.

=back

=cut

sub role_similarity {
    my ($self, $geo2) = @_;
    my $rHash = $self->{roleFids};
    my $rHash2 = $geo2->{roleFids};
    my $retVal = 0;
    my $union = scalar keys %$rHash2;
    for my $role (keys %$rHash) {
        if ($rHash2->{$role}) {
            $retVal++;
        } else {
            $union++;
        }
    }
    if ($union) {
        $retVal = $retVal * 100 / $union;
    }
    return $retVal;
}

=head3 uni_similarity

    my $score = $geo->uni_similarity($geo2);

Return the percent of universal roles in common between two genomes.

=over 4

=item geo2

The L<GEO> of the genome to which this one is to be compared.

=item RETURN

Returns the percent of universal roles the two genomes have in common.

=back

=cut

sub uni_similarity {
    my ($self, $geo2) = @_;
    my $rHash = $self->uniHash();
    my $rHash2 = $geo2->uniHash();
    my $retVal = 0;
    my $union = scalar keys %$rHash2;
    for my $role (keys %$rHash) {
        if ($rHash2->{$role}) {
            $retVal++;
        } else {
            $union++;
        }
    }
    if ($union) {
        $retVal = $retVal * 100 / $union;
    }
    return $retVal;
}

=head3 uniHash

    my $roleH = $gto->uniHash();

Return a reference to a hash keyed on the IDs of the universal roles in this genome.  A role is universal if it occurs exactly once.

=cut

sub uniHash {
    my ($self) = @_;
    my $rHash = $self->{roleFids};
    my %retVal;
    for my $role (keys %$rHash) {
        my $fids = $rHash->{$role};
        if (scalar(@$fids) == 1) {
            $retVal{$role} = 1;
        }
    }
    return \%retVal;
}


=head3 UpdateGTO

    $geo->UpdateGTO($gto);

Copy the quality information from this GEO into a L<GenomeTypeObject>.

=over 4

=item gto

The L<GenomeTypeObject> whose quality data is to be updated from this object.

=back

=cut

sub UpdateGTO {
    my ($self, $gto) = @_;
    # Get our quality data.
    my $quality = $self->{quality};
    # Make sure there is a quality hash in the GTO and get access to it.
    my $gtoQ = $gto->{quality};
    if (! $gtoQ) {
        $gtoQ = {};
        $gto->{quality} = $gtoQ;
    }
    # Ditto for the PPR.
    my $ppr = $gtoQ->{problematic_roles_report};
    if (! $ppr) {
        $ppr = {};
        $gtoQ->{problematic_roles_report} = $ppr;
    }
    # Fill in the basic metrics.
    $gtoQ->{coarse_consistency} = $quality->{coarse_consis};
    $gtoQ->{fine_consistency} = $quality->{fine_consis};
    $gtoQ->{completeness} = $quality->{complete};
    $gtoQ->{contamination} = $quality->{contam};
    $gtoQ->{completeness_group} = $quality->{group};
    $gtoQ->{completeness_taxon} = $quality->{groupTaxon};
    $gtoQ->{genome_metrics} = $quality->{metrics};
    $ppr->{over_present} = $quality->{over_roles};
    $ppr->{under_present} = $quality->{under_roles};
    $ppr->{predicted_roles} = $quality->{pred_roles};
    # Copy the role predictions.
    $ppr->{completeness_roles} = $quality->{completeness_roles};
    $ppr->{consistency_roles} = $quality->{consistency_roles};
    # Build the role maps.
    my (%roleFids, %roleMap);
    my $nMap = $self->{nameMap};
    for my $hash ($ppr->{completeness_roles}, $ppr->{consistency_roles}) {
        for my $role (keys %$hash) {
            $roleFids{$role} = $self->roleFids($role);
            $roleMap{$role} = $nMap->{$role} || $role;
        }
    }
    # Store the role maps back in the GTO.
    $ppr->{role_map} = \%roleMap;
    $ppr->{role_fids} = \%roleFids;
}


=head2 Public Manipulation Methods

=head3 AddRefGenome

    $geo->AddRefGenome($geo2);

Store the GEO of a reference genome.

=over 4

=item geo2

The GEO of a close genome of higher quality.

=back

=cut

sub AddRefGenome {
    my ($self, $geo2) = @_;
    push @{$self->{refGeo}}, $geo2;
}


=head3 AddQualityData

    $geo->AddQualityData($summaryFile);

Read the basic quality information from the specified summary file. This updates the metrics and role counts,
but does not compute the comments.

=over 4

=item summaryFile

The name of the genome summary file produced by the evaluators for this genome. This contains the role
information and the quality metrics.

=back

=cut

# Commands for processing the summary file headings.
use constant HEADINGS => { 'Fine Consistency' => ['fine_consis', 'consistency_roles'],
                           'Coarse Consistency' => ['coarse_consis', 'consisency_roles'],
                           'Group' => ['group', 'completeness_roles'],
                           'Completeness' => ['complete', 'completeness_roles'],
                           'Contamination' => ['contam', 'completeness_roles']
};

sub AddQualityData {
    my ($self, $summaryFile) = @_;
    # This will be the quality member.
    my %quality;
    $self->{quality} = \%quality;
    # Compute the metrics based on the contig lengths.
    my $contigH = $self->{contigs};
    my @contigLengths = values %$contigH;
    $quality{metrics} = SeedUtils::compute_metrics(\@contigLengths);
    # Now it is time to read the quality file.
    open(my $ih, "<$summaryFile") || die "Could not open quality output file $summaryFile: $!";
    # These are the role prediction hashes.
    my (%consistency_roles, %completeness_roles);
    $quality{consistency_roles} = \%consistency_roles;
    $quality{completeness_roles} = \%completeness_roles;
    # This will track the current target hash. If there is not a command
    # at the beginning of the file, we will fail.
    my $roleHash = '';
    # This will contain all the predicted roles, which we will use for counting
    # later.
    my %roles;
    # Loop through the file.
    while (! eof $ih) {
        my $line = <$ih>;
        if ($line =~ /^([^\t]+):\s+(.+)/) {
            # Find out what we are supposed to do with this keyword.
            # We store a value and pick a target hash.
            my ($label, $value) = ($1, $2);
            my $command = HEADINGS->{$label};
            if ($command) {
                $quality{$command->[0]} = $value;
                $roleHash = $quality{$command->[1]};
            }
        } elsif ($line =~ /^(\S+)\t(\d+)\t(\d+)/) {
            # Here we have a role prediction.
            my ($role, $predicted, $actual) = ($1, $2, $3);
            # Store it in the quality hash.
            $roleHash->{$role} = [$predicted, $actual];
            # Track it for later counting.
            if ($predicted != $actual) {
                $roles{$role} = [$predicted, $actual];
            } elsif (! $roles{$role}) {
                $roles{$role} = [$predicted, $actual];
            }
        }
    }
    # Now compute over-present and under-present roles.
    my ($over, $under, $pred) = (0, 0, 0);
    for my $role (keys %roles) {
        my $roleData = $roles{$role};
        my ($predicted, $actual) = @$roleData;
        if ($predicted < $actual) {
            $over++;
        } elsif ($predicted > $actual) {
            $under++;
        }
        $pred++;
    }
    # Store the over and under numbers.
    $quality{over_roles} = $over;
    $quality{under_roles} = $under;
    $quality{pred_roles} = $pred;
    # We are all done reading the quality file.
}

=head3 AnalyzeQualityData

    $geo->AnalyzeQualityData();

This method analyzes the quality data read into the summary file, compares it with the reference genomes,
and produces the contig report and role comments.  It can be called after L</AddQualityData> or on a GEO
read from a L<GenomeTypeObject> with evaluation data in it.

=cut

# Maximum length for a short feature.
use constant SHORT_FEATURE => 180;

# Margin at the end of each contig.
use constant CONTIG_EDGE => 5;

sub AnalyzeQualityData {
    my ($self) = @_;
    # Get the reference genomes.
    my $refGeoL = $self->{refGeo} // [];
    my $refGeoCount = scalar @$refGeoL;
    # Get the role features hash and the feature-locations hash.
    my $roleFids = $self->{roleFids};
    my $fidLocs = $self->{fidLocs};
    # Get the quality data previously stored.
    my $quality = $self->{quality};
    # Build the list of good roles and the list of problematic roles. This list gives us the default comment
    # for each role prediction hash.
    my @hashData = ([$quality->{completeness_roles}, 'Universal role.'], [$quality->{consistency_roles}, '']);
    # This will hold the predicted roles that have actual occurrences.
    my @pred;
    # This will hold the problematic role comments.
    my %role_comments;
    $quality->{role_comments} = \%role_comments;
    for my $hashDatum (@hashData) {
        my ($roleH, $comment) = @$hashDatum;
        for my $role (keys %$roleH) {
            my ($pred, $actual) = @{$roleH->{$role}};
            if ($pred != $actual) {
                $role_comments{$role} = $comment;
            }
            if ($actual > 0) {
                push @pred, $role;
            }
        }
    }
    # Extract the good roles;
    my %good = map { $_ => 1 } grep { ! exists $role_comments{$_} } @pred;
    # Now compute the number of good roles in each contig.
    my %contigs;
    $quality->{contigs} = \%contigs;
    for my $role (keys %good) {
        my $fids = $roleFids->{$role};
        for my $fid (@$fids) {
            my $contig = $fidLocs->{$fid}->Contig;
            $contigs{$contig}[0]++;
        }
    }
    # Memorize the contigs with no good roles and the contigs shorter than
    # the N70.
    my $contigH = $self->{contigs};
    my $shortContig = $quality->{metrics}{N70};
    my %badContigs;
    for my $contig (keys %$contigH) {
        my $connect = 0;
        if (! $contigs{$contig}) {
            $badContigs{$contig} = 'has no good roles';
            $contigs{$contig} = [0];
            $connect = 1;
        }
        if ($contigH->{$contig} < $shortContig) {
            if ($connect) {
                $badContigs{$contig} .= ' and is short';
            } else {
                $badContigs{$contig} = 'is short';
            }
        }
    }
    # Get the protein hash for this genome.
    my $ourProteins = $self->{proteins};
    # Now we must analyze the features for each problematic role and update the
    # comments.
    for my $role (keys %role_comments) {
        my ($predicted, $actual, $comment) = $self->roleMetrics($role);
        # Set up to accumulate comments about the role in here.
        my @rComments;
        if ($comment) { push @rComments, $comment; }
        # If there are existing features for the role, we make comments on each one.
        if ($actual >= 1) {
            # Get the list of features found, and save their proteins.
            my $fids = $roleFids->{$role};
            my %proteins;
            for my $fid (@$fids) {
                # If this feature has a protein, save it.
                my $prot = $self->protein($fid);
                if ($prot) {
                    $proteins{$fid} = $prot;
                }
            }
            # We accumulate reference-genome comments for each feature in this hash.
            my %fComments;
            # If we have proteins, we can ask which feature is the best.
            if (scalar(keys %proteins) > 1) {
                # Check for this role in each reference genome.
                for my $refGeo (@$refGeoL) {
                    my $rFids = $refGeo->roleFids($role);
                    # Loop through the reference genome features.
                    for my $rFid (@$rFids) {
                        my $rProtein = $refGeo->protein($rFid);
                        if ($rProtein) {
                            my ($bestFid, $score) = closest_protein($rProtein, \%proteins);
                            if ($bestFid) {
                                # Here one of our features matches the reference genome's implementation of this role.
                                $fComments{$bestFid} = "is closest to " . _fid_link($rFid) . ", which performs this role in the reference genome ($score matching kmers)";
                                # Get the best match's location.
                                my $loc = $self->{fidLocs}{$bestFid};
                                if ($loc) {
                                    # This counts as a good feature in this contig, so increment the counter.
                                    my $contigID = $loc->Contig;
                                    $contigs{$contigID}[0]++;
                                }
                            } else {
                                # This reference genome feature is not associated with any feature in this genome possessing this role.
                                my $comment = _fid_link($rFid) . " performs this role in the reference genome";
                                # Look for a match in this genome that does not have this role.
                                my ($pFid, $score) = closest_protein($rProtein, $ourProteins);
                                if ($pFid) {
                                    $comment .= " and " . _fid_link($pFid) . " is the feature in this genome closest to it ($score matching kmers).";
                                } else {
                                    $comment .= " but has no close features in this genome."
                                }
                                push @rComments, $comment
                            }
                        }
                    }
                }
            }
            # Process the list of features found.
            for my $fid (@$fids) {
                # We will build our comments for this feature in here.
                my @comments;
                # Analyze the location.
                my $loc = $fidLocs->{$fid};
                my $len = $loc->Length;
                if ($len <= SHORT_FEATURE) {
                    push @comments, "is only $len bases long";
                }
                # Form its relationship to the contig.
                my $contigID = $loc->Contig;
                my $contigLen = $contigH->{$contigID};
                my $strand = $loc->Dir;
                my ($left, $right) = ($loc->Left < CONTIG_EDGE,
                                      $loc->Right > $contigLen - CONTIG_EDGE);
                my $position;
                if ($left && $right) {
                    $position = 'fills contig ';
                } elsif ($left && $strand eq '+' || $right && $strand eq '-') {
                    $position = 'starts near the edge of contig ';
                } elsif ($left || $right) {
                    $position = 'ends near the edge of contig ';
                } else {
                    $position = 'is in contig ';
                }
                # Form the contig link.
                $position .= $self->contig_link($contigID);
                # Add a qualifier.
                if ($badContigs{$contigID}) {
                    $position .= " (which $badContigs{$contigID})";
                }
                push @comments, $position;
                # Add the closest-role comment, if any.
                if ($fComments{$fid}) {
                    push @comments, $fComments{$fid};
                }
                # Now build the feature comment. There will be at least one, but may
                # be more.
                my $fcomment = _cr_link($fid) . ' ' . _format_comments(@comments);
                push @rComments, $fcomment;
                # Finally, we must record this feature as a bad feature for the contig.
                my $contigFids = $contigs{$contigID};
                if (! grep { $_ eq $fid } @$contigFids) {
                    push @$contigFids, $fid;
                }
            }
        } elsif ($refGeoCount) {
            # The role is missing, but we have a reference genome. Get its instances
            # of the same role.
            my %rProteins;
            for my $refGeo (@$refGeoL) {
                my $fids = $refGeo->{roleFids}{$role};
                if ($fids) {
                    for my $rFid (@$fids) {
                        my $rProtein = $refGeo->protein($rFid);
                        $rProteins{$rFid} = $rProtein;
                    }
                }
            }
            my $genomeWord = ($refGeoCount == 1 ? 'genome' : 'genomes');
            my $fidCount = scalar keys %rProteins;
            if (! $fidCount) {
                push @rComments, "Role is not present in the reference $genomeWord.";
            } else {
                my $verb = ($fidCount == 1 ? 'performs' : 'perform');
                push @rComments, _fid_link(sort keys %rProteins) . " $verb this role in the reference $genomeWord.";
                # Find the closest feature for each reference genome protein.
                for my $rFid (sort keys %rProteins) {
                    my $rProtein = $rProteins{$rFid};
                    if ($rProtein) {
                        my ($fid, $score) = closest_protein($rProtein, $ourProteins);
                        if ($fid) {
                            push @rComments, _cr_link($fid) . " is the closest protein to the reference feature " . _fid_link($rFid) . " with $score kmers in common.";
                        }
                    }
                }
            }
        }
        # Form all the comments for this role.
        $role_comments{$role} = join('<br />', @rComments);
    }
}

=head3 AddQuality

    $geo->AddQuality($summaryFile);

Add the quality information for this genome to this object, using the data in the specified summary file.
This method fills in the C<quality> member described above.

=over 4

=item summaryFile

The name of the genome summary file produced by the evaluators for this genome. This contains the role
information and the quality metrics.

=back

=cut

sub AddQuality {
    my ($self, $summaryFile) = @_;
    $self->AddQualityData($summaryFile);
    $self->AnalyzeQualityData();
}

=head3 FindBadContigs

    my $badH = $geo->FindGoodContigs();

Create a hash keyed on the bad contigs in this genome.  The L</AnalyzeQualityData> method must already have been called
on this object to fill in the contig counts.

A bad contig is one with no good features.  The return value will be a reference to a hash keyed on the IDs of these contigs.

=cut

sub FindBadContigs {
    my ($self) = @_;
    # This will be the return hash.
    my %retVal;
    # Get the contig quality hash.
    if ($self->{quality}) {
        my $contigs = $self->{quality}{contigs} // {};
        # Loop through the contigs in the hash.
        for my $contig (keys %$contigs) {
            if (! $contigs->{$contig}[0]) {
                $retVal{$contig} = 1;
            }
        }
    }
    # Return the results.
    return \%retVal;
}

=head2 Internal Methods

=head3 _find_best_match

    my (\@idList, $score) = GEO::_find_best_match($id, \%scores);

This is a utility subroutine for the bidirectional-best-hit search.  Given an ID from one set and a distance matrix,
it finds the IDs in the other set that have the highest score.

=over 4

=item id

The ID of the item whose best matches are desired.

=item scores

A reference to a two-dimensional hash that maps pairs of IDs to scores.  The incoming ID must be available in the
first dimension-- that is, it must have a sub-hash keyed on the other IDs.

=item min (optional)

The minimum score to permit.  The default is C<0>.

=item RETURN

Returns a list containing (0) a reference to a list of the IDs with the highest score for the incoming ID, and (2) the
relevant match score.

=back

=cut

sub _find_best_match {
    my ($id, $scores, $min) = @_;
    # Get the sub-hash for the incoming ID.  If there is none, we use an empty hash.
    my $matches = $scores->{$id} // {};
    # Default the minimum score.
    $min //= 0;
    # Start with an empty list and a score of 0.  There are no 0 scores in the matrix.
    my ($bestScore, @retVal) = ($min);
    # Loop through the scores.
    for my $id2 (keys %$matches) {
        my $score2 = $matches->{$id2};
        if ($score2 > $bestScore) {
            ($bestScore, @retVal) = ($score2, $id2);
        } elsif ($score2 == $bestScore) {
            push @retVal, $id2;
        }
    }
    # Return the result.
    return (\@retVal, $bestScore);
}


=head3 _format_comments

    my $sentence = _format_comments(@phrases).

Join the phrases together to form a sentence using commas and a conjunction.

=over 4

=item phrases

Zero or more phrases to be joined into a conjunction.

=item RETURN

Returns a string formed from the phrases using commas and a conjunction.

=back

=cut

sub _format_comments {
    my (@phrases) = @_;
    my $retVal = '';
    if (scalar(@phrases) == 1) {
        $retVal = $phrases[0];
    } elsif (scalar(@phrases) == 2) {
        $retVal = join(" and ", @phrases);
    } else {
        my @work = @phrases;
        my $last = pop @work;
        $last = "and $last";
        $retVal = join(", ", @work, $last);
    }
    return $retVal;
}

=head3 _cr_link

    my $html = GEO::_cr_link($fid);

Produce a labeled hyperlink to a feature's compare regions page.

=over 4

=item fid

The ID of the relevant feature.

=item RETURN

Returns a hyperlink to the feature's compare regions page with the text containing the feature
ID.

=back

=cut

sub _cr_link {
    my ($fid) = @_;
    my $fidInLink = uri_escape($fid);
    my $retVal = qq(<a href="https://www.patricbrc.org/view/Feature/$fidInLink#view_tab=compareRegionViewer" target="_blank">$fid</a>);
    return $retVal;
}

=head3 _fid_link

    my $html = GEO::_fid_link(@fids);

Return a hyperlink for viewing a list of PATRIC features or a single feature.

=over 4

=item fids

A list of feature IDs.

=item RETURN

Returns a hyperlink for viewing a single feature or a list of multiple features. For a single feature, the compare regions page will be pre-selected.

=back

=cut

sub _fid_link {
    my (@fids) = @_;
    my $retVal;
    if (@fids == 1) {
        my $fid = $fids[0];
        my $fidInLink = uri_escape($fid);
        $retVal = qq(<a href="https://www.patricbrc.org/view/Feature/$fidInLink#view_tab=compareRegionViewer" target="_blank">$fid</a>);
    } elsif (@fids > 1) {
        my $list = join(",", map { uri_escape(qq("$_")) } @fids);
        my $link = "https://www.patricbrc.org/view/FeatureList/?in(patric_id,($list))";
        my $count = scalar @fids;
        $retVal = qq(<a href="$link" target="_blank">$count features</a>);
    } else {
        $retVal = "0 features";
    }
    return $retVal;
}

=head3 _log

    GEO::_log($lh, $msg);

Write a log message if we have a log file.

=over 4

=item lh

Open file handle for the log, or C<undef> if there is no log.

=item msg

Message to write to the log.

=back

=cut

sub _log {
    my ($lh, $msg) = @_;
    if ($lh) {
        print $lh $msg;
    }
}

=head3 _RoleMaps

    my ($nMap, $cMap) = _RoleMaps($roleHashes, $logH, $stats);

Compute the role ID/name maps. These are either taken from the incoming parameter or they are read from the global
C<roles.in.subsystems> file.

=over 4

=item roleHashes

Either a 2-tuple containing (0) the name map and (1) the checksum map, or C<undef>, indicating the maps should be read
from the global role file.

=item logH

Optional open file handle for logging.

=item stats

A L<Stats> object for tracking statistics.

=back

=cut

sub _RoleMaps {
    my ($roleHashes, $logH, $stats) = @_;
    # These will be the return values.
    my ($nMap, $cMap);
    # Do we have role hashes from the client?
    if ($roleHashes) {
        # Yes. Use them.
        $nMap = $roleHashes->[0];
        $cMap = $roleHashes->[1];
    } else {
        # No. Read from the roles.in.subsystems file.
        $nMap = {}; $cMap = {};
        my $roleFile = "$FIG_Config::global/roles.in.subsystems";
        _log($logH, "Reading roles from $roleFile.\n");
        open(my $rh, '<', $roleFile) || die "Could not open roles.in.subsytems: $!";
        while (! eof $rh) {
            if (<$rh> =~ /^(\S+)\t(\S+)\t(.+)/) {
                $nMap->{$1} = $3;
                $cMap->{$2} = $1;
                $stats->Add(mappableRoleRead => 1);
            }
        }
    }
    return ($nMap, $cMap);
}


=head3 _BuildGeo

    my $geo = _BuildGeo($gto, $p3, $nMap, $cMap, $stats, $options);

Build most of a GEO from an in-memory L<GenomeTypeObject>. The missing piece will be the taxonomic lineage, which is handled differently depending on
how many GEOs we are building simultaneously.

=over 4

=item gto

The L<GenomeTypeObject> from which the GEO is to be built.

=item p3

The L<P3DataAPI> object for accessing the PATRIC database.

=item nMap

Reference to a hash mapping role IDs to role names.

=item cMap

Reference to a hash mapping role checksums to role IDs.

=item stats

A L<Stats> object for tracking runtime statistics.

=item options

Reference to a hash containing zero or more of the following options.

=item options

A hash containing zero or more of the following keys.

=over 8

=item detail

Level of detail-- C<0> roles only, C<1> roles and contigs, C<2> roles, contigs, and proteins. The default is C<0>.

=item logH

Open file handle for status messages. If not specified, no messages will be written.

=item binned

If TRUE, then it will be presumed this genome comes from the binning process, and the contig names are node names rather than sequence IDs.

=item external

If TRUE, then it will be presumed this genome's contig IDs are not found in PATRIC, and no contig links will be generated.

=item rolesToUse

If specified, a hash of role IDs. Only roles in the hash will be kept in the role maps.

=back

=item RETURN

Returns the GEO built from the GTO, but without the taxonomic ID lineage.

=back

=cut

sub _BuildGeo {
    my ($gto, $p3, $nMap, $cMap, $stats, $options) = @_;
    # Get the basic genome information.
    my $genome = $gto->{id};
    my $name = $gto->{scientific_name};
    my $domain = $gto->{domain};
    my $taxon = $gto->{ncbi_taxonomy_id};
    my $gc = $gto->{genetic_code};
    my $retVal = { id => $genome, name => $name, domain => $domain, nameMap => $nMap, checkMap => $cMap,
        taxon => $taxon, gc => $gc };
    # Get the options.
    my $rToUseH = $options->{rolesToUse};
    my $detail = $options->{detail} // 0;
    my $logH = $options->{logH};
    # Check for quality data in the GTO.
    if ($gto->{quality}) {
        my %quality;
        my $gtoQ = $gto->{quality};
        # Pull out the basic scores.
        $quality{coarse_consis} = $gtoQ->{coarse_consistency};
        $quality{fine_consis} = $gtoQ->{fine_consistency};
        $quality{complete} = $gtoQ->{completeness};
        $quality{contam} = $gtoQ->{contamination};
        $quality{group} = $gtoQ->{completeness_group};
        $quality{metrics} = $gtoQ->{genome_metrics};
        # Get the problematic role scores and counts.
        my $ppr = $gtoQ->{problematic_roles_report};
        $quality{over_roles} = $ppr->{over_present};
        $quality{under_roles} = $ppr->{under_present};
        $quality{pred_roles} = $ppr->{predicted_roles};
        $quality{consistency_roles} = $ppr->{consistency_roles};
        $quality{completeness_roles} = $ppr->{completeness_roles};
        # To get a full role report ("role_comments" and "contigs"), you
        # need to call AnalyzeQualityData.
        $retVal->{quality} = \%quality;
        # Now copy over the quality statistics.
        $retVal->{cdsPercent} = $gtoQ->{cds_ratio} * 100;
        $retVal->{hypoPercent} = $gtoQ->{hypothetical_cds_ratio} * 100;
        $retVal->{plfamPercent} = $gtoQ->{plfam_cds_ratio} * 100;
    }
    # Check for a lineage.
    if ($gto->{ncbi_lineage}) {
        $retVal->{lineage} = [map { $_->[1] } @{$gto->{ncbi_lineage}} ];
    }
    # Compute the aa-len limits for the seed protein.
    my ($min, $max) = (209, 405);
    if ($domain eq 'Archaea') {
        ($min, $max) = (293, 652);
    }
    my $seedCount = 0;
    my $goodSeed = 1;
    my $bestSeedLen = 0;
    # We need a hash to count role checksums and a counter for PEGs found.
    my ($pegCount, $hypoCount) = (0, 0);
    my %ckHash;
    # Create the role tables.
    my (%roles, %proteins, %locs);
    _log($logH, "Processing features for $genome.\n");
    for my $feature (@{$gto->{features}}) {
        $stats->Add(featureFoundFile => 1);
        my $fid = $feature->{id};
        my $function = $feature->{function};
        if ($feature->{type} =~ /^CDS|peg/) {
            if (! $function || SeedUtils::hypo($function)) {
                $hypoCount++;
            } else {
                $pegCount++;
            }
        }
        # Only features with functions matter to us.
        if ($function) {
            my @roles = SeedUtils::roles_of_function($function);
            my $mapped = 0;
            my $prot = $feature->{protein_translation};
            for my $role (@roles) {
                my $checkSum = RoleParse::Checksum($role);
                $ckHash{$checkSum}++;
                $stats->Add(roleFoundFile => 1);
                my $rID = $cMap->{$checkSum};
                if (! $rID) {
                    $stats->Add(roleNotMapped => 1);
                } else {
                    $stats->Add(roleMapped => 1);
                    if ($rToUseH && ! $rToUseH->{$rID}) {
                        $stats->Add(roleSkipped => 1);
                    } else {
                        push @{$roles{$rID}}, $fid;
                        $mapped++;
                        if ($rID eq 'PhenTrnaSyntAlph') {
                            $seedCount++;
                            my $aaLen = length $prot;
                            if ($aaLen > $bestSeedLen) {
                                $retVal->{seed} = $prot;
                            }
                            if ($aaLen < $min) {
                                $stats->Add(seedTooShort => 1);
                                $goodSeed = 0;
                            } elsif ($aaLen > $max) {
                                $stats->Add(seedTooLong => 1);
                                $goodSeed = 0;
                            }
                        }
                    }
                }
            }
            if ($detail && $mapped) {
                # If we are NOT abridged and this feature had an interesting role, we
                # also need to save the location.
                my $locs = $feature->{location};
                my ($region, @locList) = @$locs;
                my $loc = BasicLocation->new(@$region);
                for $region (@locList) {
                    $loc->Combine(BasicLocation->new(@$region));
                }
                $locs{$fid} = $loc;
            }
            if ($detail > 1 && $prot) {
                $proteins{$fid} = $prot;
                $stats->Add(proteinStored => 1);
            }
        }
    }
    # Store the role map and statistics.
    $retVal->{roleFids} = \%roles;
    $retVal->{roleCount} = scalar keys %ckHash;
    $retVal->{pegCount} = $pegCount;
    $retVal->{hypoCount} = $hypoCount;
    # Compute the good-seed flag.
    if (! $seedCount) {
        $stats->Add(seedNotFound => 1);
        $goodSeed = 0;
    } elsif ($seedCount > 1) {
        $stats->Add(seedTooMany => 1);
        $goodSeed = 0;
    }
    $retVal->{good_seed} = $goodSeed;
    # Check for the optional stuff.
    if ($detail) {
        # Here we also need to store the location map.
        $retVal->{fidLocs} = \%locs;
        # Finally, we need the contig lengths.
        _log($logH, "Reading contigs for $genome.\n");
        my %contigs;
        for my $contig (@{$gto->{contigs}}) {
            $stats->Add(contigFoundFile => 1);
            my $contigID = $contig->{id};
            my $len = length($contig->{dna});
            $contigs{$contigID} = $len;
        }
        $retVal->{contigs} = \%contigs;
        $retVal->{proteins} = \%proteins;
        # If we are binned, we must generate the contig map.
        if ($options->{binned}) {
            my @badContigIDs = grep { ! ($_ =~ /^\d+\.\d+\.con\.\d+$/) } keys %contigs;
            if (@badContigIDs) {
                _log($logH, "Processing contig mapping for binned GTO $genome.\n");
                my %binMap;
                my $realContigIDs = P3Utils::get_data($p3, contig => [['eq', 'genome_id', $genome]], ['sequence_id', 'description']);
                for my $idPair (@$realContigIDs) {
                    my ($realID, $fakeID) = @$idPair;
                    if ($contigs{$fakeID}) {
                        $binMap{$fakeID} = $realID;
                        $stats->Add(contigIdMapped => 1);
                    }
                }
                $retVal->{binContigs} = \%binMap;
            }
        } elsif ($options->{external}) {
            # Here we generate an empty contig map. The genome is external, so we don't want any contig links.
            $retVal->{binContigs} = {};
        }
    }
    return $retVal;
}

1;
