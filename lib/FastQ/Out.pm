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


package FastQ::Out;

    use strict;
    use warnings;

=head1 FASTQ Writer

This object will output records from a L<FastQ> object.  It is designed to be interface-compatible with L<FastA::Out>,
which performs the same service for L<FastA> objects.

=head2 Special Methods

=head3 new

    my $oh = FastQ::Out->new($fileName);

Create FASTA paired output files with the given file name. The extensions C<_1.fastq> and C<_2.fastq> will be appended.

=over 4

=item fileName

The name to give to the output file, without the filename extensions.

=back

=cut

sub new {
    my ($class, $fileName) = @_;
    # Create the output files.
    open(my $oh1, ">${fileName}_1.fastq") || die "Could not open $fileName left fastq: $!";
    open(my $oh2, ">${fileName}_2.fastq") || die "Could not open $fileName right fastq: $!";
    # Create the object.
    my $retVal = { lh => $oh1, rh => $oh2 };
    bless $retVal, $class;
    # Return it.
    return $retVal;
}

=head2 Public Manipulation Methods

=head3 Write

    $oh->Write($fq);

Write the current record from a L<FastQ> object to this file.

=over 4

=item fq

A L<FastQ> object currently positioned on a sequence.

=back

=cut

sub Write {
    my ($self, $fq) = @_;
    $fq->WriteL($self->{lh});
    $fq->WriteR($self->{rh});
}

=head3 Close

    $oh->Close();

Close this object's files.

=cut

sub Close {
    my ($self) = @_;
    close $self->{lh};
    close $self->{rh};
}

1;