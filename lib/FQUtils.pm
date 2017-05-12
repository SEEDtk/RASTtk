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


package FQUtils;

    use strict;
    use warnings;

=head1 FASTQ Manipulation Utilities

This package contains useful utilities for manipulating FASTQ files.

=head2 Public Methods

=head3 FilterFastQ

    FQUtils::FilterFastQ($fqHandle, \%idList, $oh);

Write out the sequences with the selected identifiers. This method processes input from a L<FastQ> object connected to a single
or paired FASTQ file and writes an interlaced file to the specified output.

=over 4

=item fqHandle

Open L<FastQ> object for reading the sequences to filter.

=item idList

Reference to a hash whose keys are the IDs of the sequences to keep.

=item oh

Open output file handle.

=back

=cut

sub FilterFastQ {
    my ($fqHandle, $idList, $oh) = @_;
    # Loop through the input sequences.
    while ($fqHandle->next) {
        # Check to see if we want this sequence
        my $id = $fqHandle->id;
        if ($idList->{$id}) {
            # We do, so write it to the output.
            print $oh "\@$id/1\n" . $fqHandle->left  . "\n+\n" . $fqHandle->lqual . "\n";
            print $oh "\@$id/2\n" . $fqHandle->right . "\n+\n" . $fqHandle->rqual . "\n";
        }
    }
}

1;