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


package EvalCon;

    use strict;
    use warnings;
    use RoleParse;
    use FIG_Config;
    use SeedUtils;
    use Stats;

=head1 Genome Quality Analysis Utilities

This module performs utility functions used in genome quality analysis.

The following fields are present in this object.

=over 4

=item cMap

Reference to a hash mapping role checksums to role IDs.

=item nMap

Reference to a hash mapping role IDs to role names.

=item roles

Reference to a list of the role IDs to use for quality control.

=item predictors

Name of the function predictors directory.

=item stats

A L<Stats> object containing statistics about the process.

=item matrix_X

An reference to a list of lists, corresponding to an in-memory copy of the X matrix from a predictor directory.

=item matrix_row

A reference to a list corresponding to an in-memory copy of the row.h map from a predictor directory.

=item matrix_col

A reference to a list corresponding to an in-memory copy of the col.h map from a predictor directory.

=item rh

Open handle for the current C<row.h> file.

=item xh

Open handle for the current C<X> file.

=item rCount

Number of rows currently in the C<X> and X<row.h> files.

=item logH

Open file handle for log messages, or C<undef> if no logging is desired.

=back

=head2 Special Methods

=head3 role_options

This is a list of the option specifiers for the predictors and role files. The options are as follows.

=over 4

=item predictors

The directory containing the function predictors. The default is C<FunctionPredictors> in the SEEDtk global directory.

=item roleFile

The C<roles.in.subsystems> file containing the role IDs, checksums, and names for the stable roles. The default is the
file of that name in the function predictors directory, or the one in the SEEDtk global directory if the predictors do
not have one.

=item rolesToUse

The C<roles.to.use> file containing the IDs of the roles for which predictors exist. The default is the file of that name
in the function predictors directory, or the one in the SEEDtk global directory if the predictors do not have one.

=back

=cut

sub role_options {
    return (['predictors|P=s', 'function predictors directory'],
            ['roleFile|rolefile|R=s', 'role definition file'],
            ['rolesToUse|rolestouse|r=s', 'usefule role list file']);
}

=head3 new

    my $eval = EvalCon->new(%options);

Create a new quality analysis object.

=over 4

=item options

A hash containing zero or more of the following keys.

=over 8

=item roleFile

Name of the the C<roles.in.subsystems> file. This is a tab-delimited file of interesting roles, each record containing (0) a role
ID, (1) a role checksum, and (2) a role name. The default is C<roles.in.subsystems> in the SEEDtk global directory.

=item rolesToUse

Name of the C<roles.to.use> file. This is a tab-delimited file containing the list of roles of interest. Each record contains
a role ID in its first column. The default is C<roles.to.use> in the SEEDtk global directory.

=item predictors

Name of the directory containing the function predictors. The default is C<FunctionPredictors> in the SEEDtk global directory.
If a C<roles.to.use> file and/or a C<roles.in.subsystems> file exists in this directory, it overrides the defaults above.

=item stats

A L<Stats> object containing statistics about the data processed. If not specified, one will be created for this object.

=item logH

An open file handle for a file to contain status messages.

=back

=back

=cut

sub new {
    my ($class, %options) = @_;
    # Get the log file and the stats object.
    my $logH = $options{logH};
    my $stats = $options{stats} // Stats->new();
    # Create the object and bless it.
    my $retVal = { logH => $logH, stats => $stats };
    bless $retVal, $class;
    # Analyze the options, starting with the predictors.
    my ($predictors, $rolesToUse, $roleFile) =  map { "$FIG_Config::global/$_"} qw(FunctionPredictors roles.to.use roles.in.subsystems);
    if ($options{predictors}) {
        $predictors = $options{predictors};
    }
    if (-s "$predictors/roles.in.subsystems") {
        $roleFile = "$predictors/roles.in.subsystems";
    }
    if (-s "$predictors/roles.to.use") {
        $rolesToUse = "$predictors/roles.to.use";
    }
    if ($options{roleFile}) {
        $roleFile = $options{roleFile};
    }
    if ($options{rolesToUse}) {
        $rolesToUse = $options{rolesToUse};
    }
    $retVal->{predictors} = $predictors;
    $retVal->_log("Predictors are in $predictors.\nRole files are $roleFile and $rolesToUse.\n");
    # Create the role definition hashes.
    my ($nMap, $cMap) = LoadRoleHashes($roleFile, $stats);
    $retVal->{cMap} = $cMap;
    $retVal->{nMap} = $nMap;
    # Create the roles-of-interest hash.
    open(my $rh, "<$rolesToUse") || die "Could not open $rolesToUse: $!";
    my @roles;
    while (! eof $rh) {
        my $line = <$rh>;
        if ($line =~ /^(\S+)/) {
            push @roles, $1;
            $stats->Add(usedRole => 1);
        }
    }
    $retVal->{roles} = \@roles;
    $retVal->_log(scalar(keys %$nMap) . " roles of interest. " . scalar(@roles) . " used.\n");
    # Return it to the client.
    return $retVal;
}

=head3 new_for_script

    my $eval = EvalCon->new_for_script($opt, $logH);

Create a new quality analysis object using command-line options for a script.

=over 4

=item opt

A L<Getopt::Long::Descriptive::Opts> object containing the options from L</role_options>.

=item logH (optional)

Open file handle for log messages.

=back

=cut

sub new_for_script {
    my ($class, $opt, $logH) = @_;
    return EvalCon::new($class, predictors => $opt->predictors, roleFile => $opt->rolefile, rolesToUse => $opt->rolestouse, logH => $logH);
}


=head3 LoadRoleHashes

    my ($nMap, $cMap) = EvalCon::LoadRoleHashes($roleFile, $stats, \@rolesToUse);

Load the role hashes from the C<roles.in.subsystems> file.

=over 4

=item roleFile

The file containing the role IDs, names, and checksums. This file is tab-delimited, each line containing (0) a role ID, (1) a role checksum, and (2) a role name.

=item stats (optional)

A L<Stats> object for tracking statistics.

=item rolesToUse (optional)

If specified, a reference to a list of role IDs.  Only those roles will be included in the hashes.  The default is to
include all roles.

=item RETURN

Returns a two-element list containing (0) a reference to a hash from role IDs to role names, and (1) a reference to a hash from role checksums to role IDs.

=back

=cut

sub LoadRoleHashes {
    my ($roleFile, $stats, $rolesToUse) = @_;
    # Get the stats object.
    $stats //= Stats->new();
    # Compute the role-filter hash.
    my $filterH;
    if ($rolesToUse) {
        $filterH = { map { $_ => 1 } @$rolesToUse };
    }
    open(my $rh, "<$roleFile") || die "Could not open $roleFile: $!";
    my (%nMap, %cMap);
    while (! eof $rh) {
        my $line = <$rh>;
        chomp $line;
        my ($id, $checksum, $name) = split /\t/, $line;
        if (! $filterH || $filterH->{$id}) {
            $nMap{$id} = $name;
            $cMap{$checksum} = $id;
            $stats->Add(subsysRole => 1);
        }
    }
    close $rh; undef $rh;
    return (\%nMap, \%cMap);
}

=head2 Query Methods

=head3 predictors

    my $predictorDir = $eval->predictors;

Return the directory containing the function predictors.

=cut

sub predictors {
    my ($self) = @_;
    return $self->{predictors};
}

=head3 stats

    my $stats = $eval->stats;

Return the internal L<Stats> object.

=cut

sub stats {
    my ($self) = @_;
    return $self->{stats};
}

=head3 roleHashes

    my ($nMap, $cMap) = $eval->roleHashes;

Return references to the role name map (ID to name) and the role checksum map (checksum to ID) so they can be used by the
client for role parsing.

=cut

sub roleHashes {
    my ($self) = @_;
    return ($self->{nMap}, $self->{cMap});
}


=head3 roles

    my @ids = $eval->roles($function);

Compute the IDs for the roles in a given functional assignment.

=over 4

=item function

The functional assignment to parse.

=item RETURN

Returns a list of the role IDs for the roles in the function. If none of the roles could be mapped, it will return an empty
list.

=back

=cut

sub roles {
    my ($self, $function) = @_;
    # Get the checksum-to-ID map.
    my $cMap = $self->{cMap};
    # Separate the incoming function into roles.
    my @roles = SeedUtils::roles_of_function($function);
    # Parse the roles to get the checksums, and convert the checksums to IDs.
    my @retVal;
    for my $role (@roles) {
        my $checkSum = RoleParse::Checksum($role);
        my $roleID = $cMap->{$checkSum};
        if ($roleID) {
            push @retVal, $roleID;
            $self->{stats}->Add(roleMapped => 1);
        } else {
            $self->{stats}->Add(roleNotMapped => 1);
        }
    }
    # Return the roles found.
    return @retVal;
}

=head3 rolesToUse

    my $rolesL = $eval->rolesToUse

Return a reference to a list of the roles in the roles-to-use list.

=cut

sub rolesToUse {
    my ($self) = @_;
    return $self->{roles};
}


=head2 Public Manipulation Methods

=head3 BuildFileMatrix

    $eval->BuildFileMatrix($fileName, $outDir);

Create matrix structures from a C<raw.table> file such as that created by L<build_role_files.pl>. This is a tab-delimtied file
without headers, each record consisting of (0) a role name, (1) a role ID, and (2) a feature ID. We first create a hash of role
counts for each genome, then feed these into the matrix I/O methods.

=over 4

=item fileName

The name of the file containing the feature information.

=item outDir

The output directory to contain the matrix files.

=back

=cut

sub BuildFileMatrix {
    my ($self, $fileName, $outDir) = @_;
    # Get the statistics object.
    my $stats = $self->{stats};
    # Get a hash of the roles to use.
    my %roles = map { $_ => 1 } @{$self->{roles}};
    # The counts will be put in here. It is a two-dimensional hash keyed on genome ID and then role ID.
    my %counts;
    # Open the raw.table file.
    open(my $ih, "<$fileName") || die "Could not open $fileName: $!";
    # Loop through the records.
    while (! eof $ih) {
        my $line = <$ih>;
        $stats->Add(rawLineIn => 1);
        if ($line =~ /\t(\S+)\tfig\|(\d+\.\d+)/) {
            my ($role, $genome) = ($1, $2);
            if ($roles{$role}) {
                $stats->Add(rawLineUsed => 1);
                $counts{$genome}{$role}++;
            }
        } else {
            $stats->Add(rawLineBad => 1);
        }
    }
    close $ih;
    # Create the matrix files.
    $self->OpenMatrix($outDir);
    # Loop through the genomes, folding them in.
    for my $genome (sort keys %counts) {
        my $countH = $counts{$genome};
        $self->_MatrixAdd($genome, $countH);
    }
    # Close the matrix files.
    $self->CloseMatrix();
}

=head3 LoadMatrix

    $eval->LoadMatrix($inDir);

Load a matrix from the specified predictor directory.

=over 4

=item inDir

A directory containing the C<col.h>, C<row.h>, and C<X> files for a predictor matrix. These files will be loaded
into memory and stored in this object.

=back

=cut

sub LoadMatrix {
    my ($self, $inDir) = @_;
    my $stats = $self->{stats};
    # Read in the columns. These are roles.
    my @cols;
    open(my $ih, "<$inDir/col.h") || die "Could not open col.h for $inDir: $!";
    while (! eof $ih) {
        my ($i, $role) = SeedUtils::fields_of($ih);
        $cols[$i] = $role;
    }
    close $ih; undef $ih;
    # Read in the rows. These are genomes.
    my @rows;
    open($ih, "<$inDir/row.h") || die "Could not open row.h for $inDir: $!";
    while (! eof $ih) {
        my ($i, $genome) = SeedUtils::fields_of($ih);
        $rows[$i] = $genome;
    }
    close $ih; undef $ih;
    # Read in the matrix itself.
    my @X;
    open($ih, "<$inDir/X") || die "Could not open X for $inDir: $!";
    while (! eof $ih) {
        push @X, [SeedUtils::fields_of($ih)];
    }
    close $ih; undef $ih;
    # Store the matrix.
    $self->{matrix_row} = \@rows;
    $self->{matrix_col} = \@cols;
    $self->{matrix_X} = \@X;
    $stats->Add(matrixIn => 1);
}


=head3 PartitionMatrix

    $eval->PartitionMatrix($col, $outDir);

Create a partition of the loaded matrix in the specified output directory. The specified column will be extracted and used as
a Y file. The resulting matrix lists the specified column's results for each row given the values in the other columns.

=over 4

=item col

The index of the column on which to partition.

=item outDir

The name of the output directory to contain the new matrix.

=back

=cut

sub PartitionMatrix {
    my ($self, $col, $outDir) = @_;
    # Get the currently-loaded matrix.
    my $rows = $self->{matrix_row};
    my $cols = $self->{matrix_col};
    my $X = $self->{matrix_X};
    # Get the old roles list.
    my $oldRoles = $self->{roles};
    my $n = scalar(@$oldRoles) - 1;
    # We need a map of roles to old column IDs and a list of new roles with the selected column spliced out.
    my @newRoles;
    my %roleCols;
    # Create a map of roles to output columns.
    for (my $i = 0; $i <= $n; $i++) {
        if ($i != $col) {
            my $role = $oldRoles->[$i];
            push @newRoles, $role;
            $roleCols{$role} = $i;
        }
    }
    # Start the output.
    $self->OpenMatrix($outDir, \@newRoles);
    open(my $yh, ">$outDir/y") || die "Could not open y-file in $outDir: $!";
    # Process the rows.
    my $r = 0;
    for my $x_row (@$X) {
        my $y = $x_row->[$col];
        my %new_x = map { $_ => $x_row->[$roleCols{$_}] } @newRoles;
        $self->_MatrixAdd($cols->[$r], \%new_x, \@newRoles);
        print $yh "$y\n";
    }
    # Close the output.
    close $yh;
    $self->CloseMatrix();
}

=head2 Incremental Matrix Build

=head3 OpenMatrix

    $eval->OpenMatrix($outDir, $roles);

Initialize a matrix directory. The C<col.h> will be written and C<row.h> and C<X> open for output.

=over 4

=item outDir

The name of the output directory into which the files will be written.

=item roles

A list of the roles to use. If omitted, the main role list is used.

=back

=cut

sub OpenMatrix {
    my ($self, $outDir, $roles) = @_;
    # Get the role list.
    $roles //= $self->{roles};
    # Create the role file.
    open(my $ch, ">$outDir/col.h") || die "Could not create col.h in $outDir: $!";
    my $n = scalar @$roles;
    for (my $i = 0; $i < $n; $i++) {
        print $ch "$i\t$roles->[$i]\n";
    }
    close $ch;
    # Open the other two files.
    open(my $rh, ">$outDir/row.h") || die "Could not create row.h in $outDir: $!";
    open(my $xh, ">$outDir/X") || die "Could not create X in $outDir: $!";
    # Store the open handles and denote we have no rows yet.
    $self->{rh} = $rh;
    $self->{xh} = $xh;
    $self->{rCount} = 0;
}

=head3 AddGeoToMatrix

    $eval->AddGeoToMatrix($geo);

Add the role data from the specified L<GenomeEvalObject> to the predictor matrix currently being built.

=over 4

=item geo

A L<GenomeEvalObject> to serve as the next row of the predictor matrix.

=back

=cut

sub AddGeoToMatrix {
    my ($self, $geo) = @_;
    # Get the role counts for the genome.
    my $countsH = $geo->roleCounts;
    # Write the genome.
    $self->_MatrixAdd($geo->id, $countsH);
}

=head3 CloseMatrix

    $eval->CloseMatrix();

Close the matrix files.

=cut

sub CloseMatrix {
    my ($self) = @_;
    # Close the files.
    close $self->{rh};
    close $self->{xh};
    # Clear the status variables.
    $self->{rh} = undef;
    $self->{xh} = undef;
    # Record this update.
    $self->{stats}->Add(matrixOut => 1);
}


=head2 Internal Utilities

=head3 _log

    $eval->_log($message);

Write a message to the log stream, if it exists.

=over 4

=item message

Message string to write.

=back

=cut

sub _log {
    my ($self, $message) = @_;
    my $logH = $self->{logH};
    if ($logH) {
        print $logH $message;
    }
}

=head3 _MatrixAdd

    $eval->_MatrixAdd($genomeID, \%counts, \@roles);

Write a genome to the output matrix. The genome will be added as a new row.

=over 4

=item genomeID

The ID of this genome.

=item counts

Reference to a hash mapping role IDs to occurrence counts.

=item roles

A list of the roles to use. If omitted, the main role list is used.

=back

=cut

sub _MatrixAdd {
    my ($self, $genomeID, $countsH, $roles) = @_;
    # Get the role list.
    $roles //= $self->{roles};
    # Write the genome ID to the row file. Note we increment the count for the next row.
    my $row = $self->{rCount}++;
    my $rh = $self->{rh};
    print $rh "$row\t$genomeID\n";
    # Create the matrix row from the roles.
    my $mRow =  join("\t", map { sprintf('%.1f', $countsH->{$_} // 0.0) } @$roles);
    # Write it out.
    my $xh = $self->{xh};
    print $xh "$mRow\n";
}


1;