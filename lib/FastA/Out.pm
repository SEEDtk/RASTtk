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


package FastA::Out;

    use strict;
    use warnings;

=head1 FASTA Writer

This object will output records from a L<FastA> object.  It is designed to be interface-compatible with L<FastQ::Out>,
which performs the same service for L<FastQ> objects.

=head2 Special Methods

=head3 new

    my $oh = FastA::Out->new($fileName);

Create a FASTA output file with the given file name. The extension C<.fasta> will be appended.

=over 4

=item fileName

The name to give to the output file, without the filename extension.

=back

=cut

sub new {
    my ($class, $fileName) = @_;
    # Create the output file.
    open(my $oh, ">$fileName.fasta") || die "Could not open $fileName fasta: $!";
    # Create the object.
    my $retVal = { oh => $oh };
    bless $retVal, $class;
    # Return it.
    return $retVal;
}

=head2 Public Manipulation Methods

=head3 Write

    $oh->Write($fa);

Write the current record from a L<FastA> object to this file.

=over 4

=item fa

A L<FastA> object currently positioned on a sequence.

=back

=cut

sub Write {
    my ($self, $fa) = @_;
    $fa->Write($self->{oh});
}

=head3 Close

    $oh->Close();

Close this object's files.

=cut

sub Close {
    my ($self) = @_;
    close $self->{oh};
}


1;