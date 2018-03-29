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


package GtoChecker;

    use strict;
    use warnings;
    use RoleParse;
    use ScriptUtils;
    use Stats;
    use FIG_Config;
    use SeedUtils;

=head1 Data Structures to Check GTOs for Completeness

This object manages data structures to check GTOs for completeness and contamination. The algorithm is simple, and
is based on files created by the scripts L<taxon_analysis.pl>, L<group_marker_roles.pl>, and L<compute_taxon_map.pl>
plus the global role-mapping file C<roles.in.subsystems>.

For each taxonomic group, there is a list of roles that appear singly in 95% of the genomes in that taxonomic grouping
and an associated weight for each. Completeness is measured by the wieghted percent of those roles that actually occur.
Contamination is measured by the weighted number of duplicates found.

This object contains the following fields.

=over 4

=item taxonMap

A hash mapping taxonomic IDs to the ID of the taxonomic group that should be used to judge its completeness.

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

=item taxSizes

A hash mapping each taxonomic group ID to its total role weight.

=back

=head2 Special Methods

=head3 new

    my $checker = GtoChecker->new($checkDir, %options);

Create a new GTO checker object.

=over 4

=item checkDir

The name of a directory containing the main input files-- C<roles.tbl> from L<taxon_analysis.pl> and C<taxon_map.tbl>, which is
created by L<compute_taxon_map.pl>.

=item options

A hash containing zero or more of the following keys.

=over 8

=item rolesInSubsystems

The name of the file containing the master list of roles. This is a tab-delimited file with no headers. The first column of each
record is the role ID, the second is the role checksum, and the third is the role name. The default file is C<roles.in.subsystems>
in the global data directory.

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
    my $stats = $options{stats} // Stats->new();
    my $logH = $options{logH};
    my $roleFile = $options{rolesInSubsystems} // "$FIG_Config::global/roles.in.subsystems";
    # We will track the roles of interest in here. When we read roles.in.subsystems we will fill in the role names.
    my %nameMap;
    # This will be our map of taxonomic group IDs to role hashes.
    my %roleLists;
    # This will map group IDs to total weight.
    my %taxSizes;
    # This will map group IDs to names.
    my %taxNames;
    # This will map taxon IDs to group IDs.
    my %taxonMap;
    # This will map role checksums to role IDs.
    my %roleMap;
    # Create and bless the object.
    my $retVal = { taxonMap => \%taxonMap, taxNames => \%taxNames, roleMap => \%roleMap,
            nameMap => \%nameMap, taxSizes => \%taxSizes, stats => $stats,
            roleLists => \%roleLists, logH => $logH };
    bless $retVal, $class;
    # Get the roles.tbl file.
    $retVal->Log("Processing weighted.tbl.\n");
    open(my $rh, "<$checkDir/weighted.tbl") || die "Could not open weighted.tbl in $checkDir: $!";
    # Skip the header.
    my $line = <$rh>;
    # Loop through the taxonomic groups.
    while (! eof $rh) {
        my ($taxon, $size, $name) = ScriptUtils::get_line($rh);
        $taxNames{$taxon} = $name;
        $taxSizes{$taxon} = $size;
        $stats->Add(taxGroupIn => 1);
        # Now we loop through the roles.
        my $done;
        my %weights;
        while (! eof $rh && ! $done) {
            my ($role, $weight) = ScriptUtils::get_line($rh);
            if ($role eq '//') {
                $done = 1;
            } else {
                # We need to track the roles in the name map as well as the group's role hash.
                # Later the name map is used to fill in the role names for the roles we need.
                $nameMap{$role} = $role;
                $weights{$role} = $weight;
                $stats->Add(taxRoleIn => 1);
            }
        }
        $roleLists{$taxon} = \%weights;
    }
    close $rh; undef $rh;
    my $markerCount = scalar keys %nameMap;
    $retVal->Log("$markerCount marker roles found in " . scalar(keys %roleLists) . " taxonomic groups.\n");
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
    # All that is left is to read in the taxonomic ID mapping.
    $retVal->Log("Processing taxon_map.tbl.\n");
    open(my $th, "<$checkDir/taxon_map.tbl") || die "Could not open taxon_map.tbl in $checkDir: $!";
    # Discared the header.
    $line = <$th>;
    # Loop through the taxonomic IDs.
    while (! eof $th) {
        my ($taxonID, $groupID) = ScriptUtils::get_line($th);
        $taxonMap{$taxonID} = $groupID;
        $stats->Add(taxonIn => 1);
    }
    $retVal->Log("Taxonomic groups loaded.\n");
    # Return the object created.
    return $retVal;
}


=head3 Log

    $checker->Log($message);

Write a message to the log stream, if it exists.

=over 4

=item message

Message string to write.

=back

=cut

sub Log {
    my ($self, $message) = @_;
    my $logH = $self->{logH};
    if ($logH) {
        print $logH $message;
    }
}


=head2 Query Methods

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

=head2 Public Manipulation Methods

=head3 Check

    my $dataH = $checker->Check($gto);

Check a L<GenomeTypeObject> for completeness and contamination. A hash of the problematic roles will be returned as well.

=over 4

=item gto

The L<GenomeTypeObject> to be checked.

=item RETURN

Returns a reference to a hash with the following keys.

=over 8

=item complete

The percent completeness.

=item contam

The percent contamination.

=item extra

The percent of extra genomes. This is an attempt to mimic the checkM contamination value.

=item roleData

Reference to a hash mapping each marker role ID to the number of times it was found.

=item taxon

Name of the taxonomic group used.

=back

=back

=cut

sub Check {
    my ($self, $gto) = @_;
    # These will be the return values.
    my ($complete, $contam, $multi);
    my $taxGroup = 'root';
    # Get the statistics object.
    my $stats = $self->{stats};
    # This hash will count the roles.
    my %roleData;
    # Get the role map. We use this to compute role IDs from role names.
    my $roleMap = $self->{roleMap};
    # Compute the appropriate taxonomic group for this GTO and get its role list.
    my $taxon = $gto->{ncbi_taxonomy_id};
    my $groupID = $self->{taxonMap}{$taxon};
    if (! defined $groupID) {
        # No group. We will return undef for the results.
        $self->Log("No taxonomic group in database that includes $taxon.\n");
    } else {
        # Get the group name.
        $taxGroup = $self->{taxNames}{$groupID};
        # Fill the roleData hash from the role list.
        my $roleHash = $self->{roleLists}{$groupID};
        %roleData = map { $_ => 0 } keys %$roleHash;
        my $markers = scalar keys %roleData;
        my $size = $self->{taxSizes}{$groupID};
        $self->Log("$markers markers with total weight $size for group $groupID: $self->{taxNames}{$groupID}.\n");
        # Now we run through the features of the GTO, tallying the roles found.
        $self->Log("Processing features.\n");
        my $featList = $gto->{features};
        for my $feat (@$featList) {
            my $function = $feat->{function};
            $stats->Add(featureProcessed => 1);
            if ($function) {
                my @roles = SeedUtils::roles_of_function($function);
                for my $role (@roles) {
                    my $checksum = RoleParse::Checksum($role);
                    if (! $roleMap->{$checksum}) {
                        $stats->Add(roleNotMarker => 1);
                    } else {
                        my $roleID = $roleMap->{$checksum};
                        if (exists $roleData{$roleID}) {
                            $stats->Add(roleMarker => 1);
                            $roleData{$roleID}++;
                        } else {
                            $stats->Add(roleNotMarker => 1);
                        }
                    }
                }
            }
        }
        # Now we count the markers.
        my ($found, $extra, $total) = (0, 0, 0);
        for my $roleID (keys %roleData) {
            my $count = $roleData{$roleID};
            if ($count >= 1) {
                my $weight = $roleHash->{$roleID};
                $found += $weight;
                $extra += ($count - 1) * $weight;
            }
        }
        # Compute the percentages.
        $complete = $found * 100 / $size;
        $contam = ($extra > 0 ? $extra * 100 / ($found + $extra) : 0);
        $multi = $extra * 100 / $size;
    }
    # Return the results.
    my $retVal = { complete => $complete, contam => $contam, multi => $multi, roleData => \%roleData, taxon => $taxGroup };
    return $retVal;
}


1;