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


package GenomeEvalObject;

    use strict;
    use warnings;
    use GenomeTypeObject;
    use RoleParse;
    use BasicLocation;
    use P3DataAPI;
    use Stats;
    use P3Utils;
    use SeedUtils;

=head1 Genome Evaluation Object

This object is used by the genome evaluation libraries-- L<EvalCon>, L<GtoChecker>, L<BinningReports>, and the various scripts that
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

=back

The following fields are usually passed in by the client.

=over 4

=item nameMap

Reference to a hash that maps role IDs to role names.

=item checkMap

Reference to a hash that maps role checksums to role IDs.

=back

The following optional fields may also be present.

=over 4

=item fidLocs

Reference to a hash that maps each feature belonging to an mapped role to a list of its locations.

=item contigs

Reference to a hash that maps each contig ID to the contig length.

=item quality

If the quality results have been processed, a reference to a hash containing genome quality information,
with the following keys.

=over 8

=item fine_consis

Fine consistency percentage.

=item coarse_consis

Coarse consistency percentage.

=item complete

Completeness percentage.

=item contam

Contamination percentage.

=item taxon

Name of the taxonomic grouping used to compute completeness and contamination.

=item metrics

A reference to a hash of contig length metrics with the following fields.

=over 12

=item N50

The N50 of the contig lengths (see L</n_metric>).

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

=back

=back

=head2 Special Methods

=head3 CreateFromPatric

    my $gHash = GenomeEvalObject->CreateFromPatric(\@genomes, %options);

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

=item abridged

If specified, no contig information will be included in the object.

=item logH

Open file handle for status messages. If not specified, no messages will be written.

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
    my $abridged = $options{abridged};
    # Compute the feature columns for the current mode.
    my @fCols = qw(patric_id product aa_length);
    if (! $abridged) {
        push @fCols, qw(sequence_id start na_length strand);
    }
    # Now we have everything in place for loading. We start by getting the genome information.
    my $gCount = scalar @$genomes;
    $stats->Add(genomesIn => $gCount);
    _log($logH, "Requesting $gCount genomes from PATRIC.\n");
    my $genomeTuples = P3Utils::get_data_keyed($p3, genome => [], ['genome_id', 'genome_name',
            'kingdom', 'taxon_id'], $genomes);
    # Loop through the genomes found.
    for my $genomeTuple (@$genomeTuples) {
        my ($genome, $name, $domain, $taxon) = @$genomeTuple;
        $retVal{$genome} = { id => $genome, name => $name, domain => $domain, nameMap => $nMap, checkMap => $cMap,
            taxon => $taxon };
        $stats->Add(genomeFoundPatric => 1);
        # Compute the aa-len limits for the seed protein.
        my ($min, $max) = (209, 405);
        if ($domain eq 'Archaea') {
            ($min, $max) = (293, 652);
        }
        my $seedCount = 0;
        my $goodSeed = 1;
        # Now we need to get the roles. For each feature we need its product (function), ID, and protein length.
        # If we are NOT in abridged mode, we also need the location data.
        _log($logH, "Reading features for $genome.\n");
        my $featureTuples = P3Utils::get_data($p3, feature => [['eq', 'genome_id', $genome]],
                \@fCols);
        # Build the role and location hashes in here.
        my (%roles, %locs);
        for my $featureTuple (@$featureTuples) {
            $stats->Add(featureFoundPatric => 1);
            # Note only the first three will be present if we are abridged.
            my ($fid, $function, $aaLen, $contig, $start, $len, $dir) = @$featureTuple;
            # Only features with functions matter to us.
            if ($function) {
                my @roles = SeedUtils::roles_of_function($function);
                my $mapped = 0;
                for my $role (@roles) {
                    my $checkSum = RoleParse::Checksum($role);
                    $stats->Add(roleFoundPatric => 1);
                    my $rID = $cMap->{$checkSum};
                    if (! $rID) {
                        $stats->Add(roleNotMapped => 1);
                    } else {
                        $stats->Add(roleMapped => 1);
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
                if (! $abridged && $mapped) {
                    # If we are NOT abridged and this feature had an interesting role, we
                    # also need to save the location.
                    $locs{$fid} = BasicLocation->new([$contig, $start, $dir, $len]);
                }
            }
        }
        # Store the role map.
        $retVal{$genome}{roleFids} = \%roles;
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
        if (! $abridged) {
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
        }
    }
    # Run through all the objects, blessing them.
    for my $genome (keys %retVal) {
        bless $retVal{$genome}, $class;
    }
    # Return the hash of objects.
    return \%retVal;
}

=head3 CreateFromGtoFiles

    my $gHash = GenomeEvalObject->CreateFromGtoFiles(\@files, %options);

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

=item abridged

If specified, no contig information will be included in the object.

=item logH

Open file handle for status messages. If not specified, no messages will be written.

=back

=item RETURN

Returns a reference to a hash that maps each genome ID to the evaluation object created for it. Genomes files that were not
found will be ignored.

=back

=cut

sub CreateFromGtoFile {
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
    my $abridged = $options{abridged};
    # Loop through the GTO files.
    for my $file (@$files) {
        $stats->Add(genomesIn => 1);
        _log($logH, "Processing genome file $file.\n");
        my $gto = GenomeTypeObject->create_from_file($file);
        if (! $gto) {
            _log($logH, "No genome found in $file.\n");
        } else {
            $stats->Add(genomeFoundFile => 1);
            # Get the basic genome information.
            my $genome = $gto->{id};
            my $name = $gto->{scientific_name};
            my $domain = $gto->{domain};
            my $taxon = $gto->{ncbi_taxonomy_id};
            $retVal{$genome} = { id => $genome, name => $name, domain => $domain, nameMap => $nMap, checkMap => $cMap,
                taxon => $taxon };
            # Compute the aa-len limits for the seed protein.
            my ($min, $max) = (209, 405);
            if ($domain eq 'Archaea') {
                ($min, $max) = (293, 652);
            }
            my $seedCount = 0;
            my $goodSeed = 1;
            # Create the role tables.
            my (%roles, %locs);
            _log($logH, "Processing features for $genome.\n");
            for my $feature (@{$gto->{features}}) {
                $stats->Add(featureFoundFile => 1);
                my $fid = $feature->{id};
                my $function = $feature->{function};
                # Only features with functions matter to us.
                if ($function) {
                    my @roles = SeedUtils::roles_of_function($function);
                    my $mapped = 0;
                    for my $role (@roles) {
                        my $checkSum = RoleParse::Checksum($role);
                        $stats->Add(roleFoundFile => 1);
                        my $rID = $cMap->{$checkSum};
                        if (! $rID) {
                            $stats->Add(roleNotMapped => 1);
                        } else {
                            $stats->Add(roleMapped => 1);
                            push @{$roles{$rID}}, $fid;
                            $mapped++;
                            if ($rID eq 'PhenTrnaSyntAlph') {
                                $seedCount++;
                                my $aaLen = length $feature->{protein_translation};
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
                    if (! $abridged && $mapped) {
                        # If we are NOT abridged and this feature had an interesting role, we
                        # also need to save the location.
                        my $locs = $feature->{location};
                        my $region = shift @$locs;
                        my $loc = BasicLocation->new($region->{contig_id}, $region->{begin}, $region->{dir}, $region->{length});
                        for $region (@$locs) {
                            $loc->Combine(BasicLocation->new($region->{contig_id}, $region->{begin}, $region->{dir}, $region->{length}));
                        }
                        $locs{$fid} = $loc;
                    }
                }
            }
            # Store the role map.
            $retVal{$genome}{roleFids} = \%roles;
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
            if (! $abridged) {
                # Here we also need to store the location map.
                $retVal{$genome}{fidLocs} = \%locs;
                # Finally, we need the contig lengths.
                _log($logH, "Reading contigs for $genome.\n");
                my %contigs;
                for my $contig (@{$gto->{contigs}}) {
                    $stats->Add(contigFoundFile => 1);
                    my $contigID = $contig->{id};
                    my $len = length($contig->{sequence});
                    $contigs{$contigID} = $len;
                }
                $retVal{$genome}{contigs} = \%contigs;
            }
        }
    }
    # Run through all the objects, blessing them.
    for my $genome (keys %retVal) {
        bless $retVal{$genome}, $class;
    }
    # Return the hash of objects.
    return \%retVal;
}

## TODO method documentation and code

=head2 Internal Methods

=head3 _log

    GenomeEvalObject::_log($lh, $msg);

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


1;
