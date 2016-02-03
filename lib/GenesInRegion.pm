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


package GenesInRegion;

    use strict;
    use warnings;
    use BasicLocation;
    use ServicesUtils;

=head1 Find Genes in a Region

This object contains methods useful in doing genes-in-region processing. It is mainly concerned with
manipulating and merging locations. It contains the following fields.

=over 4

=item rangeLoc

A L<BasicLocation> describing the region whose genes are desired.

=item helper

A helper object (L<STKServices> or equivalent) for accessing the database.

=back

=head2 Special Methods

=head3 new

    my $gir = GenesInRegion->new($helper, $contig, $start, $end);

Create a genes-in-region object for a specific contig region.

=over 4

=item helper

Helper object (L<STKServices> or equivalent) for accessing the database.

=item contig

ID of the relevant contig.

=item start

Starting location of the region.

=item end

Ending location of the region.

=back

=cut

sub new {
    my ($class, $helper, $contig, $start, $end) = @_;
    # Insure the start is less than the end.
    if ($start > $end) {
        ($start, $end) = ($end, $start);
    }
    # Create the contig location.
    my $regionLoc = BasicLocation->new($contig, $start, '_', $end);
    # Create the object.
    my $retVal = {
        rangeLoc => $regionLoc,
        helper => $helper,
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head2 Public Methods

=head3 Process

    my $fList = $gir->Process(%options);

Compute the features in the specified region.

=over 4

=item options

A hash containing zero or more of the following options.

=over 8

=item gto

A L<GenomeTypeObject> from which the features should be taken. If this is not specified, the features will
be taken from the database.

=item missing

If specified, the name of a tab-delimited file containing missing-role data (generally output from
L<svc_missing_roles.pl>). The missing gene's role ID and name should be in the first two columns,
and the location in the 6th column.

=item priv

Privilege level for function assignments. The default is C<0>.

=back

=cut

sub Process {
    my ($self, %options) = @_;
    # Get the range location.
    my $rangeLoc = $self->{rangeLoc};
    # Get the helper object.
    my $helper = $self->{helper};
    # We will keep our features in here.
    my @genes;
    # Get the important options.
    my $priv = $options{priv} // 0;
    # Do we have missing roles?
    if ($options{missing}) {
        # Open the missing-roles file.
        open(my $ih, '<', $options{missing}) || die "Could not open missing-roles file: $!";
        # Loop through the missing roles.
        while (! eof $ih) {
            my ($roleID, $roleName, $locString) = ServicesUtils::get_cols($ih, 1, 2, 6);
            # Convert the location string to a location.
            my $loc = BasicLocation->new($locString);
            # Is this location in range?
            if ($rangeLoc->OverlapLoc($loc)) {
                # Yes. Output the missing role.
                push @genes, [missing => $loc, $roleID, $roleName];
            }
        }
    }
    # Are we reading from a genome-typed-object?
    if ($options{gto}) {
        # Yes. Get the GTO.
        my $gto = $options{gto};
        my $featureList = $gto->features;
        # Get the contig ID.
        my $contig = $rangeLoc->Contig;
        # Loop through the features. We will keep any features in range.
        # Initially the function IDs are blank, and we fill them in later.
        my %funcNames;
        for my $feature (@$featureList) {
            my $locList = $feature->{location};
            # Get location objects for all the locations on our contig.
            my @locs = map { BasicLocation->new(@$_) } grep { $_->[0] eq $contig } @$locList;
            if (@locs) {
                # Merge the locations. We arbitrarily keep the direction of the first. Most of the
                # time, all the directions are the same anyway.
                my $fullLoc = shift @locs;
                for my $loc (@locs) {
                    $fullLoc->Merge($loc);
                }
                if ($rangeLoc->OverlapLoc($fullLoc)) {
                    # This feature is in the region. Keep it!
                    my $func = $feature->{function};
                    push @genes, [$feature->{id}, $fullLoc, '', $func];
                    # Save the function.
                    $funcNames{$func} = 1;
                }
            }
        }
        # Get the IDs for the functions.
        my $funcMap = $helper->desc_to_function([keys %funcNames]);
        for my $gene (@genes) {
            my $funcID = $funcMap->{$gene->[3]};
            if ($funcID) {
                $gene->[2] = $funcID;
            }
        }
    } else {
        # Here we need the genes from the database. We ask the helper.
        my $feats = $helper->genes_in_region($rangeLoc, $priv);
        push @genes, @$feats;
    }
    # Sort the output.
    my @retVal = sort { BasicLocation::Cmp($a->[1], $b->[1]) } @genes;
    return \@retVal;
}

1;