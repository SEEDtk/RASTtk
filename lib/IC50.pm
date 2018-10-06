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


package IC50;

    use strict;
    use warnings;
    use Math::Vector::Real;

=head1 Utilities for IC50 Computation

This object provides methods for computing drug effectiveness and synergy.

The common input object is a hash that maps log-dosage to percent growth reduction. A negative reduction means the drug was counter-productive.
The IC50 number is the log-dosage at which the growth reduction is 50 percent.

=head2 Special Methods

=head3 new

    my $ic50 = IC50->new(%options);

Create a new, blank IC50 computation object.

=over 4

=item options

A hash containing zero or more of the following option values.

=over 8

=item negative

If TRUE, then the IC50 will be at -50 instead of +50. The default is FALSE.

=back

=back

=cut

sub new {
    my ($class, %options) = @_;
    my $target = ($options{negative} ? -50 : 50);
    my $retVal = {
        target => $target,
    };
    bless $retVal, $class;
    return $retVal;
}

=head3 clean

    my $cleaned = IC50::clean($name);

Clean a drug or cell line name.

=over 4

=item name

The drug or cell line name to clean.

=item RETURN

Returns an uppercase version of the name with no special characters.

=back

=cut

sub clean {
    my ($name) = @_;
    my $retVal = uc $name;
    $retVal =~ s/[^A-Z0-9]//g;
    return $retVal;
}


=head2 Query Methods

=head3 compute

    my $ic50Value = $ic50->compute(\%growthMap);

Estimate the IC50 for a specific drug given a set of dosage/growth mappings.

=over 4

=item growthMap

Reference to a hash that maps a log-dosage values to growth percentages.

=item RETURN

Returns the estimated log-dosage at which growth will be 50%, or C<undef> if the data is insufficient.

=back

=cut

sub compute {
    my ($self, $growthMap) = @_;
    my @xy = map { [$_, $growthMap->{$_}] } keys %$growthMap;
    my $retVal = $self->computeFromPairs(\@xy);
    return $retVal;
}

=head3 computeFromPairs

    my $ic50Value = $ic50->compute(\@growthPairs);

Compute the IC50 from a set of dosage/growth pairs.

=over 4

=item growthPairs

Reference to a list of [log-dosage, growth-precentage] pairs.

=item RETURN

Returns the estimated log-dosage at which growth will be 50%, or C<undef> if the data is insufficient.

=back

=cut

sub computeFromPairs {
    my ($self, $growthPairs) = @_;
    # Compute the quadratic fit.
    my ($a, $b, $c) = $self->quadFit($growthPairs);
    # This will be the return value.
    my $retVal;
    # Compute the IC50.
    if ($a == 0.0) {
        # Linear fit.
        if ($b != 0.0) {
            $retVal = ($self->{target} - $c) / $b;
        }
    } else {
        my $discrim = $b * $b - 4 * $a * ($c - $self->{target});
        if ($discrim >= 0.0) {
            $discrim = sqrt($discrim);
            my $scale = 2 * $a;
            my ($x1, $x2) = (($discrim - $b) / $scale, -($discrim + $b) / $scale);
            my $oldX = $growthPairs->[0][0];
            for (my $i = 1; $i < @$growthPairs && ! defined $retVal; $i++) {
                my $newX = $growthPairs->[$i][0];
                if ($oldX <= $x1 && $x1 <= $newX) {
                    $retVal = $x1;
                } elsif ($oldX <= $x2 && $x2 <= $newX) {
                    $retVal = $x2;
                } else {
                    $oldX = $newX;
                }
            }
        }
    }
    return $retVal;
}

=head3 quadFit

    my ($a, $b, $c) = $ic50->quadFit(\@growthPairs);

Fit a quadratic curve to the growth data.

=over 4

=item growthPairs

Reference to a list of [log-dosage, growth-precentage] pairs.

=item RETURN

Returns a three-element list containing the quadratic, linear, and constant terms of the best-fit curve. If no such
curve exists, it will return C<undef> for all elements.

=back

=cut

sub quadFit {
    my ($self, $growthPairs) = @_;
    # These will be the return variables.
    my ($a, $b, $c);
    # Compute the various summations.
    my ($n, $Sx, $Sx2, $Sx3, $Sx4, $Sy, $Syx, $Syx2) = (0, 0, 0, 0, 0, 0);
    for my $pair (@$growthPairs) {
        my ($x, $y) = @$pair;
        $n += 1.0;
        $Sx += $x;
        $Sx2 += $x*$x;
        $Sx3 += $x*$x*$x;
        $Sx4 += $x*$x*$x*$x;
        $Sy += $y;
        $Syx += $y*$x;
        $Syx2 += $y*$x*$x;
    }
    # Create the equations.
    my $eq1 = V($n, $Sx, $Sx2, $Sy);
    my $eq2 = V($Sx, $Sx2, $Sx3, $Syx);
    my $eq3 = V($Sx2, $Sx3, $Sx4, $Syx2);
    # Solve the equations.
    $eq1 /= $n;
    $eq2 -= $eq1 * $eq2->[0];
    $eq3 -= $eq1 * $eq3->[0];
    if ($eq2->[1] != 0.0) {
        $eq2 /= $eq2->[1];
        $eq3 -= $eq2 * $eq3->[1];
        if ($eq3->[2] != 0.0) {
            $eq3 /= $eq3->[2];
            $a = $eq3->[3];
            $b = $eq2->[3] - $a * $eq2->[2];
            $c = $eq1->[3] - $a * $eq1->[2] - $b * $eq1->[1];
        }
    }
    # Return the result.
    return ($a, $b, $c);
}

1;