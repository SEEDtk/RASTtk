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


package P3Signatures;

    use strict;
    use warnings;
    use P3Utils;
    use P3DataAPI;

=head1 Compute Signature Families

This module computes genetic signature families. It takes as input two sets of genomes and searches for
families that are common in the first and uncommon in the second. The output is a hash mapping family IDs
to occurrence counts.

=head2 Special Methods

=head3 Process

    my $familyHash = P3Signatures::Process(\@gs1, \@gs2, $min_in, $max_out);

Compute the protein families that distinguish genome set 1 from genome set 2.

=over 4

=item gs1

Reference to a list of the IDs of the first genomes. The signature families must occur in most of these genomes.

=item gs2

Reference to a list of the IDs of the second genomes. The signature families must occur in few of these genomes.

=item min_in

The fraction of genomes in set 1 that must contain a signature family. A value of C<1> means all genomes must contain it.

=item max_out

The fraction of genomes in set 2 that may contain a signature family. A value of C<0> means no genomes can contain it.

=item jobObject (optional)

If specified, a L<Job> object for reporting progress.

=item RETURN

Returns a hash mapping the ID of each signature family to a 3-tuple consisting of (0) the number of genomes in set 1 containing 
the family, (1) the number of genomes in set 2 containing the family, and (2) the functional role of the family. 
 
=back

=cut

sub Progress {
    my ($gs1, $gs2, $min_in, $max_out, $jobObject) = @_;
    # Get access to PATRIC.
    my $p3 = P3DataAPI->new();
    # Copy both sets of genomes to a hash.
    my %gs1 = map { $_ => 1 } @$gs1;
    my %gs2 = map { $_ => 1 } @$gs2;
    
    # This hash will count the number of times each family is found in the sets.
    # It is keyed by family ID, and each value is a sub-hash with keys "in" and "out"
    # pointing to counts.
    my %counts;
    # This hash maps families to their annotation product.
    my %families;
    # This hash maps "in" to a list of all the genomes in the set, and "out" to a list of all
    # the genomes not in the set.
    my %genomes = (in => [keys %gs1], out => [keys %gs2]);
    for my $type (qw(in out)) {
        my $genomeL = $genomes{$type};
        my $gCount = 0;
        for my $genome (@$genomeL) {
            $gCount++;
            # Get all of the protein families in this genome. A single family may appear multiple times.
            if ($jobObject) {
                $jobObject->Progress("Reading features for $genome ($gCount of \"$type\").");
            }
            my $resultList = P3Utils::get_data($p3, feature => [['eq', 'genome_id', $genome], ['eq', 'plfam_id', '*']], ['plfam_id', 'product']);
            # Save the families and count the unique ones.
            my %uniques;
            for my $result (@$resultList) {
                my ($fam, $product) = @$result;
                $families{$fam} = $product;
                if (! $uniques{$fam}) {
                    $counts{$fam}{$type}++;
                    $uniques{$fam} = 1;
                } 
            }
        }
    }
    # This will be our return hash.
    my %retVal;
    # Determine which families qualify as signatures.
    my $szI = scalar keys %gs1;
    my $szO = scalar keys %gs2;
    foreach my $fam (keys(%counts)) {
        my $x1 = $counts{$fam}->{in} // 0;
        my $x2 = $counts{$fam}->{out} // 0;
        if ((($x2/$szO) <= $max_out) && (($x1/$szI) >= $min_in)) {
            $retVal{$fam} = [$x1, $x2, $families{$fam}];
        }
    }
    # Return the hash.
    return \%retVal;
}


1;