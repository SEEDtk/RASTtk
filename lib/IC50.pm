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
    use Statistics::LineFit;

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

A hash containing option values. Currently, there are none.

=back

=cut

sub new {
    my ($class, %options) = @_;
    my $retVal = {
        fitter => Statistics::LineFit->new(),
    };
    bless $retVal, $class;
    return $retVal;
}


=head2 Query Methods

=head3 compute

    my $ic50Value = $ic50->compute(\%growthMap);

Estimate the IC50 for a specific drug given a set of dosage/growth mappings.

=over 4

=item growthMap

Reference to a hash that maps a log-dosage values to growth reduction percentages.

=item RETURN

Returns the estimated log-dosage at which growth reduction will be 50%, or C<undef> if the data is insufficient.

=back

=cut

sub compute {
    my ($self, $growthMap) = @_;
    # Initialize the x-y values.
    my $fitter = $self->{fitter};
    my @xy = map { [$_, $growthMap->{$_}] } keys %$growthMap;
    $fitter->setData(\@xy);
    # Compute the slope and intercept.
    my ($b, $m) = $fitter->coefficients();
    # Compute the IC50.
    my $retVal;
    $retVal = (50.0 - $b) / $m;
    return $retVal;
}

=head3 computeMap

    my $ic50Map = $ic50->computeMap(\%growthMap2);

Compute the IC50 of a drug (drug 2) at each dosage level of another drug (drug 1).

=over 4

=item growthMap2

Reference to a two-dimensional hash that maps a pair of log-dosages to a percent growth reduction. The first dimension is
the log of the drug 1 dosage; the second is the log of the drug 2 dosage.

=item RETURN

Returns a reference to a hash mapping each log-dosage for drug 1 to the IC50 of drug 2 at that dosage level for drug 1.

=back

=cut

sub compute2 {
    my ($self, $growthMap2) = @_;
    # This will be our return hash.
    my %retVal;
    # Loop through the drug 1 dosages.
    for my $dose1 (keys %$growthMap2) {
        my $growthMap = $growthMap2->{$dose1};
        my $ic50 = $self->compute($growthMap);
        # If we found a value, put it in the output hash.
        if (defined $ic50) {
            $retVal{$dose1} = $ic50;
        }
    }
    # Return the results.
    return \%retVal;
}

1;