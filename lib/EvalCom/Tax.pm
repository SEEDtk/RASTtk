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


package EvalCom::Tax;

    use strict;
    use warnings;
    use RoleParse;
    use ScriptUtils;
    use Stats;
    use FIG_Config;
    use SeedUtils qw();
    use base qw(EvalCom);
    use Data::Dumper;

=head1 Evaluate Completeness Based on Taxonomic Groupings

This object manages data structures to check genomes for completeness and contamination based on their taxonomic
lineage. The algorithm is simple, and is based on files created by the scripts L<taxon_analysis.pl>,
L<group_marker_roles.pl>, and L<compute_taxon_map.pl> plus the global role-mapping file C<roles.in.subsystems>.

For each taxonomic group, there is a list of roles that appear singly in 97% of the genomes in that taxonomic grouping
and an associated weight for each. Completeness is measured by the weighted percent of those roles that actually occur.
Contamination is measured by the weighted number of duplicates found.

This object contains the following fields.

=over 4

=item taxNames

A hash mapping taxonomic group IDs to names.

=item roleMap

A hash mapping role checksums to role IDs.

=item nameMap

A hash mapping role IDs to names.

=item stats

A L<Stats> object for tracking statistics.

=item logH

Handle of a log file for status messages, or C<undef> if no status messages should be produced.

=item roleLists

A hash mapping each taxonomic group ID to a hash of the identifying role IDs and their weights. (In other words, the key of
the sub-hash is role ID and the value is the role weight).

=back

=cut

=head2 Special Methods

=head3 new

    my $checker = EvalCom::Tax->new($checkDir, %options);

Create a new genome-checker object.

=over 4

=item checkDir

The name of a directory containing the main input file-- C<weighted.tbl> from L<p3-taxon-analysis.pl> and L<group_marker_roles.pl>.

=item options

A hash containing zero or more of the following keys.

=over 8

=item rolesInSubsystems

The name of the file containing the master list of roles. This is a tab-delimited file with no headers. The first column of each
record is the role ID, the second is the role checksum, and the third is the role name. The default file is C<roles.in.subsystems>
in the global data directory.

=item roleHashes

If specified, overrides B<rolesInSubsystems>. A 2-tuple containing (0) a reference to a hash that maps role IDs to names,
and (1) a reference to a hash that maps role checksums to role IDs.

=item logH

Open handle for an output stream to contain log messages. The default is to not write log messages.

=item stats

A L<Stats> object for tracking statistics. If none is specified, one will be created.

=back

=back

=cut

sub new {
    my ($class, $checkDir, %options) = @_;
    # Process the options.
    my $roleFile = $options{rolesInSubsystems} // "$FIG_Config::global/roles.in.subsystems";
    # We will track the roles of interest in here. When we read roles.in.subsystems we will fill in the role names.
    my %nameMap;
    # This will map role checksums to role IDs.
    my %roleMap;
    # This will be set to TRUE if we already have the name and role maps from the client.
    my $preLoaded;
    # These will be the pointers to the name and role maps. If the client specified the role hashes, we put them in here.
    my ($nameMap, $roleMap) = (\%nameMap, \%roleMap);
    if ($options{roleHashes}) {
        $nameMap = $options{roleHashes}[0];
        $roleMap = $options{roleHashes}[1];
        $preLoaded = 1;
    }
    # This will be our map of taxonomic group IDs to role hashes.
    my %roleLists;
    # This will map group IDs to names.
    my %taxNames;
    # This will map taxon IDs to group IDs.
    my %taxonMap;
    # Create and bless the object.
    my $retVal = EvalCom::new($class, %options);
    $retVal->{taxNames} = \%taxNames;
    $retVal->{roleMap} = $roleMap;
    $retVal->{nameMap} = $nameMap;
    $retVal->{roleLists} = \%roleLists;
    # Get the stats.
    my $stats = $retVal->stats;
    # Get the roles.tbl file.
    $retVal->Log("Processing weighted.tbl.\n");
    open(my $rh, "<$checkDir/weighted.tbl") || die "Could not open weighted.tbl in $checkDir: $!";
    # Loop through the taxonomic groups.
    while (! eof $rh) {
        my ($taxon, $name) = ScriptUtils::get_line($rh);
        $taxNames{$taxon} = $name;
        $stats->Add(taxGroupIn => 1);
        # Now we loop through the roles.
        my $weights = $retVal->read_weights($rh);
        $roleLists{$taxon} = $weights;
        # We need to track the roles in the name map as well as the group's role hash.
        # Later the name map is used to fill in the role names for the roles we need.
        for my $role (keys %$weights) {
            $nameMap{$role} = $role;
        }
    }
    close $rh; undef $rh;
    my $markerCount = scalar keys %nameMap;
    $retVal->Log("$markerCount marker roles found in " . scalar(keys %roleLists) . " taxonomic groups.\n");
    # If we are NOT preloaded, we need to create the role-parsing hashes.
    if (! $preLoaded) {
        # Now we need to know the name and checksum of each marker role. This is found in roles.in.subsystems.
        $retVal->Log("Processing $roleFile.\n");
        open($rh, "<$roleFile") || die "Could not open $roleFile: $!";
        # Loop through the roles.
        while (! eof $rh) {
            my ($role, $checksum, $name) = ScriptUtils::get_line($rh);
            if ($nameMap{$role}) {
                $stats->Add(roleNamed => 1);
                $nameMap{$role} = $name;
                $roleMap{$checksum} = $role;
            } else {
                $stats->Add(roleNotUsed => 1);
            }
        }
        close $rh; undef $rh;
        # Verify we got all the roles.
        my $roleCount = scalar(keys %roleMap);
        if ($roleCount != $markerCount) {
            die "$markerCount role markers in roles.tbl, but only $roleCount were present in $roleFile.";
        }
    } else {
        # Here we are pre-loaded. Verify that we have all the roles we need.
        my $notFound;
        for my $role (keys %nameMap) {
            if (! $nameMap->{$role}) {
                $notFound++;
            }
        }
        if ($notFound) {
            die "$notFound roles missing from pre-loaded role hashes.";
        }
    }
    # Return the object created.
    return $retVal;
}


=head2 Query Methods

=head3 roleHashes

    my $roleHashes = $checker->roleHashes;

Return a 2-tuple of hash references-- (0) a map of role IDs to names, and (1) a map of role checksums to IDs.

=cut

sub roleHashes {
    my ($self) = @_;
    return [$self->{nameMap}, $self->{roleMap}];
}

=head3 role_name

    my $name = $checker->role_name($role);

Return the name of a role given its ID. If the role is not in the role hash, the role ID itself will be returned.

=over 4

=item role

ID of a role.

=item RETURN

Return the name of the role.

=back

=cut

sub role_name {
    my ($self, $role) = @_;
    return $self->{nameMap}{$role} // $role;
}

=head3 roles_of_function

    my @roles = $checker->roles_of_function($function);

Return the IDs of the roles found in the specified function. This may be an empty list.

=over 4

=item function

A functional assignment description.

=item RETURN

Returns a list of the IDs for the roles found in the function.

=back

=cut

sub roles_of_function {
    my ($self, $function) = @_;
    # Get the role map.
    my $roleMap = $self->{roleMap};
    # Divide the function into roles.
    my @roles = SeedUtils::roles_of_function($function // '');
    # Convert each role into an ID.
    my @retVal;
    for my $role (@roles) {
        my $check = RoleParse::Checksum($role);
        my $id = $roleMap->{$check};
        if ($id) {
            push @retVal, $id;
        }
    }
    # Return the roles found.
    return @retVal;
}


=head3 taxon_data

    my ($name, $roleHash) = $checker->taxon_data($taxonID);

Return the name and the hash of universal roles for a taxonomic group.

=over 4

=item taxonID

The taxonomic ID of the group whose data is desired.

=item RETURN

Returns a two-element list containing the name of the taxonomic group and a reference to a hash mapping each universal role to its weight. If the taxonomic group
is not in this object, undefined values will be returned.

=back

=cut

sub taxon_data {
    my ($self, $taxonID) = @_;
    # These will be the return values.
    my ($name, $roleHash);
    # Look for the group name.
    $name = $self->{taxNames}{$taxonID};
    if ($name) {
        # We found it, so get the role hash, too.
        $roleHash = $self->{roleLists}{$taxonID};
        # Add the tax ID to the name.
        $name .= " ($taxonID)";
    }
    # Return the results.
    return ($name, $roleHash);
}


=head2 Virtual Overrides

=head3 Choose

    my ($group, $roleH) = $self->Choose($geo);

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
    my $taxGroup;
    my $roleHash;
    # Get the statistics object.
    my $stats = $self->{stats};
    # Get the hash of role lists.
    my $roleLists = $self->{roleLists};
    # Compute the appropriate taxonomic group for this GEO and get the group's role list.
    my $lineage = $geo->lineage || [];
    my @taxons = @$lineage;
    my $groupID;
    my $taxon = $geo->taxon;
    while (! $groupID && (my $taxon1 = pop @taxons)) {
        if ($roleLists->{$taxon1}) {
            $groupID = $taxon1;
        }
    }
    if (! $taxon) {
        # No taxonomic data at all.
        $self->Log("No taxonomic information available for " . $geo->id . "\n");
    } else {
        if (! defined $groupID) {
            # Taxonomic data, but no group.
            my $domain = $geo->domain;
            $self->Log("No taxonomic group in database that includes $taxon.\n");
            if ($domain eq 'Bacteria') {
                $groupID = 2;
            } elsif ($domain eq 'Archaea') {
                $groupID = 2157;
            }
        }
        if (defined $groupID) {
            # Get the group data.
            ($taxGroup, $roleHash) = $self->taxon_data($groupID);
            $self->Log("Group $groupID: $taxGroup selected for $taxon.\n");
        }
    }
    return ($taxGroup, $roleHash);
}


1;