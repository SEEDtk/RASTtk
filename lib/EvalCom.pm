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


package EvalCom;

    use strict;
    use warnings;
    use Math::Round;

=head1 Evaluate the Completeness of a Genome

This package is the base object for evaluating the completeness and contamination of a genome.  It takes as input a L<GEO>
and a hash mapping role IDs to weights.  Each role identified is considered a universal role for genomes of the type to which
the GEO belongs.  The completeness is the sum of the weights of the roles present over the total weight.  The contamination
is the sum of the weights of the duplicate roles over the weights of the roles present.  Both these numbers are converted to
percentages.

This object is used as a base object for other completeness/contamination evaluators.  The primary difference between the subclasses
is the mechanism for determining which set of roles to use.

The following fields are stored in this object.

=over 4

=item stats

A L<Stats> object for keeping statistics.

=item logH

If specified, an open output handle for a file onto which to write log messages.

=back

=head2 Special Methods

=head3 new

    my $evalCom = EvalCom->new(%options);

Construct a new completeness evaluator.  This method should be called from the constructor of the subclass.

=over 4

=item options

A hash containing zero or more of the following keys.

=over 8

=item logH

Open handle for an output stream to contain log messages. The default is to not write log messages.

=item stats

A L<Stats> object for tracking statistics. If none is specified, one will be created.

=back

=back

=cut

sub new {
    my ($class, %options) = @_;
    # Process the options.
    my $stats = $options{stats} // Stats->new();
    my $logH = $options{logH};
    # Create and bless the object.
    my $retVal = { stats => $stats, logH => $logH };
    bless $retVal, $class;
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
    die "Missing Choose function for $self.";
}

=head2 Query Methods

=head3 stats

    my $stats = $checker->stats;

Return the embedded L<Stats> object.

=cut

sub stats {
    my ($self) = @_;
    return $self->{stats};
}

=head2 Public Manipulation Methods

=head3 Check

    my $dataH = $checker->Check($geo);

Check a L<GEO> for completeness and contamination. A hash of the problematic roles will be returned as well.

=over 4

=item geo

The L<GenomeEvalObject> to be checked.

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

=item group

Name of the evaluation group used.

=back

=back

=cut

sub Check {
    my ($self, $geo) = @_;
    # These will be the return values.
    my ($complete, $contam, $multi);
    # Get the statistics object.
    my $stats = $self->{stats};
    # This hash will count the roles.
    my %roleData;
    # Compute the proper role hash to use.
    my ($group, $roleHash) = $self->Choose($geo);
    # It's possible the genome is unclassifiable, so we only proceed if the choose worked.
    if (! $group) {
        # Use defaults to cover a failure.
        $group = '<none>';
        $complete = 0;
        $contam = 100;
        $multi = 100;
    } else {
        # Here we can check for completeness and contamination.
        $self->Log("Group $group selected for " . $geo->name . "\n");
        # Fill the roleData hash from the role list.
        %roleData = map { $_ => 0 } keys %$roleHash;
        my $markers = scalar keys %roleData;
        # Get the role counts for the genome.
        my $countsH = $geo->roleCounts;
        # Now we count the markers.
        my ($found, $extra, $total) = (0, 0, 0);
        for my $roleID (keys %roleData) {
            my $count = $countsH->{$roleID} // 0;
            $roleData{$roleID} = $count;
            my $weight = $roleHash->{$roleID};
            $total += $weight;
            if ($count >= 1) {
                $found += $weight;
                $extra += ($count - 1) * $weight;
            }
        }
        # Compute the percentages.
        $complete = $found * 100 / $total;
        $contam = ($extra > 0 ? $extra * 100 / ($found + $extra) : 0);
        $multi = $extra * 100 / $total;
    }
    # Return the results.
    my $retVal = { complete => $complete, contam => $contam, multi => $multi, roleData => \%roleData, group => $group };
    return $retVal;
}

=head3 Check2

    my ($complete, $contam, $group, $seedFlag) = $checker->Check2($geo, $oh);

This performs the same job as L</Check> (evaluating a genome for completeness and contamination),
but it returns a list of the key metrics in printable form. If an output file handle is
provided, it will also write the results to the output file.

=over 4

=item geo

The L<GEO> to be checked.

=item oh (optional)

If specified, an open file handle to which the output should be written. This consists of the labeled metrics
followed by the (role, predicted, actual) tuples in tab-delimited format.

=item RETURN

Returns a list containing the percent completeness, percent contamination, the name of the grouping
used, and a flag that is 'Y' if the seed protein is good and 'N' otherwise. The two percentages will be rounded
to the nearest tenth of a percent.

=back

=cut

sub Check2 {
    my ($self, $geo, $oh) = @_;
    # Get the stats object.
    my $stats = $self->{stats};
    # Do the evaluation and format the output values.
    my $evalH = $self->Check($geo);
    my ($complete, $contam, $group) = (0, 100, 'N/F');
    if (defined $evalH->{complete}) {
        $complete = Math::Round::nearest(0.1, $evalH->{complete} // 0);
        $contam = Math::Round::nearest(0.1, $evalH->{contam} // 100);
        $group = $evalH->{group};
    }
    my $seedFlag = ($geo->good_seed ? 'Y' : '');
    my $roleH = $evalH->{roleData};
    # Update the statistics.
    if (! $roleH) {
        $stats->Add(evalComFailed => 1);
    } else {
        $stats->Add(genomeComplete => 1) if GEO::completeX($complete);
        $stats->Add(genomeClean => 1) if GEO::contamX($contam);
    }
    if ($seedFlag) {
        $stats->Add(genomeGoodSeed => 1);
    } else {
        $stats->Add(genomeBadSeed => 1);
    }
    if ($oh) {
        # Output the check results.
        print $oh "Good Seed: $seedFlag\n";
        print $oh "Completeness: $complete\n";
        print $oh "Contamination: $contam\n";
        print $oh "Group: $group\n";
        # Now output the role counts.
        if ($roleH) {
            for my $role (sort keys %$roleH) {
                my $count = $roleH->{$role};
                print $oh "$role\t1\t$count\n";
            }
        }
    }
    return ($complete, $contam, $group, $seedFlag);
}

=head2 Subclass Methods

=head3 read_weights

    my $uniHash = $checker->read_weights($ih);

Read role IDs and weights from the specified input stream and return a universal-role hash.

=over 4

=item ih

An open input file handle.  The universal roles and weights will be read from this stream.

=item RETURN

Returns a reference to a hash mapping each universal role ID to its weight.

=back

=cut

sub read_weights {
    my ($self, $ih) = @_;
    my $stats = $self->stats;
    my %retVal;
    my $done;
    while (! $done && ! eof $ih) {
        my $line = <$ih>;
        chomp $line;
        if ($line eq '//') {
            $done = 1;
        } else {
            my ($role, $weight) = split /\t/, $line;
            $retVal{$role} = $weight;
            $stats->Add(groupRoleIn => 1);
        }
    }
    $stats->Add(groupWeightsIn => 1);
    return \%retVal;
}

1;