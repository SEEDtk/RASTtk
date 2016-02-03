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


package MissingRoles;

    use strict;
    use warnings;
    use File::Copy::Recursive;
    use SeedUtils;
    use KmerDb;
    use FileHandle;
    use BlastInterface;
    use ServicesUtils;
    use Hsp;

=head1 Search for Missing Roles in Contigs

This object takes as input an object containing contigs and possibly a second containing annotations.
If no annotations are provided, they will be computed by RAST. The genomes in the Shrub database close
to the incoming contigs will be examined for roles not present in the annotations, and these will be
returned as potential missing roles, along with proposals for where they might be on the contigs.

The object has the following fields.

=over 4

=item helper

Helper object (e.g. L<STKServices>) for accessing the database.

=item logh

Open output handle for log messages.

=item workDir

Name of a working directory for intermediate files.

=item annotations

A L<GenomeTypeObject> or workspace object containing the annotations. If omitted, the annotation are presumed
to be in the input file. If they are not, the contigs are called using RAST.

=item minHits

The minimum number of hits from the kmer database for a genome to be considered close. The default is
C<400>.

=item keep

The number of close genomes to keep. The default is C<10>.

=item maxE

The maximum permissible E-value from a BLAST hit. The default is C<1e-20>.

=item minLen

The minimum permissible percent length for a BLAST hit. The default is C<50>.

=item geneticCode

The genetic code to use for protein translations. The default is C<11>.

=item domain

Domain code for the organism-- C<B>, C<E>, or C<A>. The default is C<B>.

=item workDir

Working directory for intermediate files. The default is constructed from the genome ID under the
current directory, and will be created if it does not exist.

=item user

User name for calls to RAST (if needed).

=item password

Password for calls to RAST (if needed).

=item genomeID

Genome ID for the incoming contigs.

=item name

Genome name for the incoming contigs.

=back

=head2 Special Methods

=head3 new

    my $mrComputer = MissingRoles->new($contigs, $annotations, $workDir, %options);

Create a new missing-roles object for a specific seet of contigs.

=over 4

=item contigs

An object containing contig sequences. This can be a L<GenomeTypeObject>, a workspace object, or
a contigs object.

=item annotations (optional)

An object containing annotations of the contigs. This can be a L<GenomeTypeObject> or a workspace
object. If omitted, the annotations are queried from the contigs object, or if that fails, computed
by RAST.

=item helper

Helper object (e.g. L<STKServices>) for accessing the database.

=item workDir

The name of a working directory to use for temporary and output files.

=item options

A hash of option values.

=over 8

=item minHits

The minimum number of hits from the kmer database for a genome to be considered close. The default is
C<400>.

=item keep

The number of close genomes to keep. The default is C<10>.

=item maxE

The maximum permissible E-value from a BLAST hit. The default is C<1e-20>.

=item minLen

The minimum permissible percent length for a BLAST hit. The default is C<50>.

=item geneticCode

The genetic code to use for protein translations. The default is C<11>.

=item warn

If specified, log messages will be written to STDERR instead of the log file.

=item domain

Domain code for the organism-- C<B>, C<E>, or C<A>. The default is C<B>.

=item workDir

Working directory for intermediate files. The default is constructed from the genome ID under the
current directory, and will be created if it does not exist.

=item user

User name for calls to RAST (if needed). If no user name is specified, the environment variable C<RASTUSER>
will be interrogated.

=item password

Password for calls to RAST (if needed). If no password is specified, the environment variable C<RASTPASS>
will be interrogated.

=item genomeID

ID of the genome containing the incoming contigs. The default is taken from the ID of the contigs object.

=item genomeName

Name of the genome containing the incoming contigs. The default is taken from the name of the contigs object.

=back

=back

=cut

sub new {
    my ($class, $contigs, $annotations, $helper, $workDir, %options) = @_;
    # Compute the genome ID and name.
    my $genomeID = $options{genomeID} // ServicesUtils::json_field($contigs, 'id');
    my $name = $options{genomeName} // ServicesUtils::json_field($contigs, 'scientific_name', optional => 1)
            // ServicesUtils::json_field($contigs, 'name');
    # Compute the working directory.
    if (! $workDir) {
        $workDir = "$genomeID.files";
    }
    if (! -d $workDir) {
        File::Copy::Recursive::pathmk($workDir) || die "Could not create $workDir: $!";
    }
    # Set up the log file.
    my $logh;
    if ($options{warn}) {
        $logh = \*STDERR;
    } else {
        open($logh, ">$workDir/status.log") || die "Could not open log file: $!";
    }
    # Correct the genome ID if this is a contigs object.
    if ($genomeID =~ /^(\d+\.\d+)/) {
        $genomeID = $1;
    } else {
        $genomeID = '6666666.6';
    }
    # Compute the options.
    my $retVal = {
        contigs => $contigs,
        helper => $helper,
        logh => $logh,
        workDir => $workDir,
        annotations => $annotations,
        minHits => ($options{minHits} // 400),
        keep => ($options{keep} // 10),
        maxE => ($options{maxE} // 1e-20),
        minLen => ($options{minLen} // 50),
        geneticCode => ($options{geneticCode} // 11),
        domain => ($options{domain} // 'B'),
        user => $options{user} // $ENV{RASTUSER},
        password => $options{password} // $ENV{RASTPASS},
        genomeID => $genomeID,
        name => $name
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head2 Public Methods

=head3 Process

    my \@roleTuples = $mrComputer->Process($kmerFile);

Process the contigs to find the missing roles.

=over 4

=item kmerFile

Name of the json-format Kmer database.

=item RETURN

Returns a reference to a list of 6-tuples, each consisting of (0) the ID of a missing role, (1) the role
description, (2) the number of close genomes containing the role, (3) the BLAST score of a role hit in the
contigs, (4) the percent identity of that hit, and (5) the location string of that hit.

=back

=cut

sub Process {
    my ($self, $kmerFile) = @_;
    my $logh = $self->{logh};
    my $workDir = $self->{workDir};
    my $genomeID = $self->{genomeID};
    my $name = $self->{name};
    my $helper = $self->{helper};
    # We'll use this for output handles.
    my $oh;
    print $logh "Incoming genome is $genomeID: $name.\n";
    # Create a FASTA file from the contigs.
    my $contigList = ServicesUtils::contig_tuples($self->{contigs});
    my $fastaFile = $self->CreateContigFasta($contigList, $genomeID, $workDir);
    # Get the feature list from the incoming genome.
    my $featureList = ServicesUtils::json_field($self->{contigs}, 'features', optional => 1);
    if (! $featureList) {
        if ($self->{annotations}) {
            # Here we have annotations in a separate object.
            $featureList = ServicesUtils::json_field($self->{annotations}, 'features');
        } else {
            # Here we need to use RAST.
            $featureList = $self->FeaturesFromRast($contigList, $genomeID, $name, $self->{geneticCode},
                    $self->{domain}, $self->{user}, $self->{password});
        }
    }
    my $roleH = $self->LoadRoles($featureList);
    print $logh  scalar(keys %$roleH) . " roles found in $genomeID.\n";
    # Spool the roles found.
    my $gRoleFile = "$workDir/genome.roles.tbl";
    open($oh, ">$gRoleFile") || die "Could not open $gRoleFile: $!";
    for my $role (sort keys %$roleH) {
        print $oh join("\t", $role, $roleH->{$role}) . "\n";
    }
    close $oh; undef $oh;
    # The next step is to get the close genomes. Read the kmer database.
    print $logh  "Reading kmer database from $kmerFile.\n";
    my $kmerdb = KmerDb->new(json => $kmerFile);
    # Loop through the contigs, counting hits.
    my %counts;
    for my $contig (@$contigList) {
        my $contigID = $contig->[0];
        my $sequence = $contig->[2];
        print $logh  "Processing contig $contigID.\n";
        $kmerdb->count_hits($sequence, \%counts, $self->{geneticCode});
    }
    # Get the best genomes.
    my ($deleted, $kept) = (0, 0);
    for my $closeG (keys %counts) {
        if ($counts{$closeG} >= $self->{minHits}) {
            $kept++;
        } else {
            delete $counts{$closeG};
            $deleted++;
        }
    }
    print $logh  "$kept close genomes found, $deleted genomes discarded.\n";
    my @sorted = sort { $counts{$b} <=> $counts{$a} } keys %counts;
    $deleted = 0;
    while ($kept > $self->{keep}) {
        my $deleteG = pop @sorted;
        $deleted++;
        $kept--;
        delete $counts{$deleteG};
    }
    print $logh  "$kept close genomes in final list.\n";
    my $closeFile = "$workDir/close.tbl";
    open($oh, ">$closeFile") || die "Could not open $closeFile: $!";
    for my $sortedG (@sorted) {
        print $oh join("\t", $sortedG, $counts{$sortedG}, $kmerdb->name($sortedG)) . "\n";
    }
    close $oh; undef $oh;
    print $logh  "Close genomes written to $closeFile.\n";
    # Release the memory for the kmer database.
    undef $kmerdb;
    # This hash will contain the roles found in the close genomes but not in the new genome.
    my %roleCounts;
    # Get the roles in the close genomes.
    my $genomeRolesH = $helper->roles_in_genomes(\@sorted, 0, 'ssOnly');
    # Filter out the ones already in the new genome.
    for my $closeG (@sorted) {
        print $logh  "Processing roles in $closeG.  ";
        # Get the close genome's roles.
        my ($count, $total) = (0, 0);
        my $rolesL = $genomeRolesH->{$closeG};
        for my $role (@$rolesL) {
            $total++;
            if (! $roleH->{$role}) {
                $roleCounts{$role}++;
                $count++;
            }
        }
        print $logh "$count of $total found.\n";
    }
    # Get the role descriptions.
    my $roleNamesH = $helper->role_to_desc([keys %roleCounts]);
    # Spool the roles to the work directory.
    my $roleFile = "$workDir/missing.roles.tbl";
    print $logh  "Writing roles to $roleFile.\n";
    open($oh, ">$roleFile") || die "Could not open $roleFile: $!";
    my @sortedRoles = sort { $roleCounts{$b} <=> $roleCounts{$a} } keys %roleCounts;
    for my $role (@sortedRoles) {
        print $oh join("\t", $role, $roleCounts{$role}, $roleNamesH->{$role}) . "\n";
    }
    close $oh; undef $oh;
    # Now we need to get the features for these roles and blast them.
    print $logh  "Retrieving features from close genomes using " . scalar(@sortedRoles) . " roles.\n";
    my $triples = $self->GetRoleFeatureTuples(\@sortedRoles, \@sorted);
    # Run the BLAST.
    print $logh  "Performing BLAST on " . scalar(@$triples) . " features.\n";
    my $matches = $self->RunBlast($triples, $fastaFile, $self->{maxE}, $self->{minLen});
    my $blastFile = "$workDir/blast.tbl";
    # Now we process the matches. We spool them to an intermediate file at the same time
    # we queue them to the output. Only the best match for a role is kept inthe final output.
    print $logh  "Spooling BLAST output to $blastFile.\n";
    my @retVal;
    my $oldRole = "";
    open($oh, ">$blastFile") || die "Could not open $blastFile: $!";
    for my $match (@$matches) {
        # Spool to the blast file.
        print $oh join("\t", @$match) . "\n";
        # Is this a new role?
        my $role = $match->qdef;
        if ($role ne $oldRole) {
            $oldRole = $role;
            # Get the output fields.
            my $desc = $roleNamesH->{$role};
            my $count = $roleCounts{$role};
            my $score = $match->scr;
            my $pct = $match->pct;
            my $seq = $match->sseq;
            my $loc = $match->sid . "_" . $match->s1 . $match->dir . $match->n_mat;
            push @retVal, [$role, $desc, $count, $score, $pct, $loc, $seq];
        }
    }
    close $oh; undef $oh;
    print $logh  "All done.\n";
    # Return the results.
    return \@retVal;
}

=head2 Internal Methods

=head3 RunBlast

    my $matches = $mrComputer->RunBlast($triples, $fastaFile, $maxe, $minlen);

Run BLAST against the feature triples to find hits in the new genome's
contigs.

=over 4

=item triples

Reference to a list of FASTA triples for the features from the close genomes.

=item fastaFile

Name of the FASTA file for the new genome's contigs.

=item maxe

Maximum permissible E-value.

=item minlen

Minimum percentage of the query length that must match (e.g. C<50> would require a match for half the
length).

=item RETURN

Returns a reference to a list of L<Hsp> objects for the matches found.

=back

=cut

sub RunBlast {
    # Get the parameters.
    my ($self, $triples, $fastaFile, $maxe, $minlen) = @_;
    my $logh = $self->{logh};
    # Declare the return variable.
    my @retVal;
    # Get the matches.
    my $matches = BlastInterface::blast($triples, $fastaFile, 'tblastn',
            { outForm => 'hsp', maxE => $maxe, tmpdir => $self->{workDir} });
    # Fix the matches in case we have the wrong BlastInterface.
    for my $match (@$matches) {
        if (ref $match eq 'ARRAY') {
            bless $match, 'Hsp';
        }
    }
    # Filter by length.
    my ($rejected, $kept) = (0, 0);
    for my $match (@$matches) {
        my $minForMatch = $match->qlen * $minlen / 100;
        if ($match->n_id >= $minForMatch) {
            push @retVal, $match;
            $kept++;
        } else {
            $rejected++;
        }
    }
    print $logh  "$rejected matches rejected by length check; $kept kept.\n";
    # Return the result.
    return \@retVal;
}


=head3 GetRoleFeatureTuples

    my $triples = $mrComputer->GetRoleFeatureTuples(\@roles, \@genomes);

Compute the FASTA triples for the features in the close genomes belonging
to the specified roles. The comment field is the role ID. The sequence
will be the feature's protein translation.

=over 4

=item roles

Reference to a list of the roles whose features are desired.

=item genomes

Reference to a list of the close genomes from which the features should be taken.

=item RETURN

Returns a reference to a list of FASTA triples for the desired features.

=back

=cut

sub GetRoleFeatureTuples {
    # Get the parameters.
    my ($self, $roles, $genomes) = @_;
    my $logh = $self->{logh};
    my $helper = $self->{helper};
    # Declare the return variable.
    my @retVal;
    # Get the features for the roles.
    my $roleH = $helper->role_to_features($roles, 0, $genomes);
    # Get the translations.
    for my $role (keys %$roleH) {
        my $fids = $roleH->{$role};
        my $fidHash = $helper->translation($fids);
        for my $fid (keys %$fidHash) {
            push @retVal, [$fid, $role, $fidHash->{$fid}];
        }
    }
    # Return the result.
    return \@retVal;
}



=head3 LoadRoles

    my $roleH = $mrComputer->LoadRoles($featureList);

Get the list of roles from the specified list of feature descriptors.

=over 4

=item featureList

Reference to a list of feature descriptors. Each is a hash reference, and the
functional assignment must be in the C<function> member.

=item RETURN

Returns a reference to a hash keyed by role ID for all the roles in the feature list.

=back

=cut

sub LoadRoles {
    # Get the parameters.
    my ($self, $featureList) = @_;
    my $helper = $self->{helper};
    # Create a role hash.
    my %rolesH;
    for my $feature (@$featureList) {
        my $function = $feature->{function};
        my @roles = SeedUtils::roles_of_function($function);
        for my $role (@roles) {
            $rolesH{$role} = 1;
        }
    }
    # Now we have all the roles. Compute the descriptions.
    my $descH = $helper->desc_to_role([keys %rolesH]);
    # Reverse the hash to get the role IDs.
    my %retVal = map { $descH->{$_} => $_ } keys %$descH;
    # Return the result.
    return \%retVal;
}


=head3 FeaturesFromRast

    my $featureList = $mrComputer->FeaturesFromRast($contigs, $genomeID, $name,
            $geneticcode, $domain, $user, $pass);

Use RAST to compute the features in the new genome.

=over 4

=item contigs

Reference to a list of contig triples, each consisting of (0) a contig ID, (1) a comment, and (2) the
contig DNA sequence.

=item genomeID

ID of the new genome.

=item name

Name of the new genome.

=item geneticcode

Genetic code for the new genome.

=item domain

Domain code for the new genome (e.g. C<B> for bacteria, C<A> for archaea).

=item user

RAST user name.

=item pass

RAST password.

=item RETURN

Returns a reference to a list of feature descriptors.

=back

=cut

sub FeaturesFromRast {
    # Get the parameters.
    my ($self, $contigs, $genomeID, $name, $geneticcode, $domain, $user, $pass) = @_;
    my $logh = $self->{logh};
    my $workDir = $self->{workDir};
    # Load the RAST library.
    require RASTlib;
    # Annotate the contigs.
    print $logh "Annotating contigs using RAST.\n";
    my $gto = RASTlib::Annotate($contigs, $genomeID, $name, user => $user, password => $pass,
            domain => $domain, geneticCode => $geneticcode);
    # Spool the GTO to disk.
    print $logh "Spooling RAST annotations.\n";
    open(my $oh, ">$workDir/genome.json") || die "Could not open GTO output file: $!";
    SeedUtils::write_encoded_object($gto, $oh);
    # Extract the features.
    my $retVal = $gto->{features};
    # Return the result.
    return $retVal;
}


=head3 CreateContigFasta

    my $fastaFile = $mrComputer->CreateContigFasta($contigList, $genomeID, $workDir);

Create a contig FASTA file. The file will be created in the specified working
directory and the file name will be returned. The specified genome ID will be
used as the comment string for each contig.

=over 4

=item contigList

Reference to a list of contig triples [id, comment, sequence].

=item genomeID

Genome ID of the incoming genome.

=item workDir

Working directory to contain the FASTA file.

=item RETURN

Returns the name of the file created.

=back

=cut

sub CreateContigFasta {
    # Get the parameters.
    my ($self, $contigList, $genomeID, $workDir) = @_;
    my $logh = $self->{logh};
    # Declare the return variable.
    my $retVal = "$workDir/contigs.fasta";
    # Open the output file.
    open(my $oh, ">$retVal") || die "Could not open $retVal: $!";
    # Loop through the contigs, writing the FASTA.
    my $count = 0;
    for my $contig (@$contigList) {
        print $oh ">$contig->[0] $genomeID\n$contig->[2]\n";
        $count++;
    }
    print $logh  "$count contigs written to $retVal.\n";
    # Return the result.
    return $retVal;
}


1;