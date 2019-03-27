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


package FastA;

    use strict;
    use warnings;

=head1 FASTA Reader

This package provides a mechanism for reading FASTA files that is compatible with the L<FastQ> reader. It allows input of FASTA
files into FASTQ-oriented programs. A FASTA file is treated as high quality for its entire length, and the r-string is always
empty.

This object contains the following fields.

=over 4

=item ih

Open file handle for the FASTA file.

=item left

Left DNA string.

=item right

Right DNA string.

=item lqual

Left quality string.

=item rqual

Right quality string.

=item id

ID of the current node.

=item next_id

ID of the next node.

=item comment

Comment of the current node.

=item next_comment

Comment of the next node.

=back

=head2 Special Methods

=head3 new

    my $fqhandle = FastA->new($file);

Construct a new FASTA handler for the specified file.

=over 4

=item file

Name of the FASTA file, or an open file handle for it.

=back

=cut

sub new {
    my ($class, $file) = @_;
    # This will be the new object. It starts blank.
    my $retVal = {
        left => '',  right => '',
        lqual => '', rqual => '',
        id => undef
    };
    # Store the handle for the file.
    my $ih;
    if (ref $file eq 'GLOB') {
        $ih = $file;
    } else {
        open($ih, "<$file") || die "Could not open FASTA file $file: $!";
    }
    $retVal->{ih} = $ih;
    # Read the first header.
    my $line = <$ih>;
    if ($line =~ /^>(\S+)(?:\s+(\S.*))?/) {
        $retVal->{next_id} = $1;
        $retVal->{next_comment} = $2 // '';
    }
    # Bless and return this object.
    bless $retVal, $class;
    return $retVal;
}


=head2 Public Manipulation Methods

=head3 next

    my $found = $fqhandle->next;

Move forward to the next record, returning TRUE if one was found.

=cut

sub next {
    my ($self) = @_;
    # This will be set to TRUE if everything works.
    my $retVal;
    # Get the file handle.
    my $ih = $self->{ih};
    # This will hold the current sequence.
    my @seqs;
    # Only proceed if there is data left in the file.
    if (! eof $ih) {
        # Loop until we hit a new record or we hit the end of the file.
        my $done;
        while (! $done) {
            # Read the data lines until we hit the end.
            my $line = <$ih>;
            if (! defined $line) {
                $self->{id} = $self->{next_id};
                $done = 1;
            } elsif ($line =~ /^>(\S+)(?:\s+(\S.*))?/) {
                # Here we have a header for a new record.
                ($self->{id}, $self->{next_id}) = ($self->{next_id}, $1);
                ($self->{comment}, $self->{next_comment}) = ($self->{next_comment}, $2);
                # Note we skip empty sequences.
                if (@seqs) {
                    $done = 1;
                }
            } else {
                # Here we have sequence data.
                $line =~ s/[\r\n]+$//;
                push @seqs, $line;
            }
        }
    }
    # Did we find anything?
    if (@seqs) {
        # Denote we have our data.
        $retVal = 1;
        # Format the sequence and quality strings.
        my $seq = join("", @seqs);
        my $len = length $seq;
        my $qual = '~' x $len;
        # Store the input.
        $self->{left} = $seq;
        $self->{lqual} = $qual;
        $self->{right} = '';
        $self->{rqual} = '';
    }
    # Return the success indication.
    return $retVal;
}

=head3 at_end

    my $eofFlag = $fqhandle->at_end();

Return TRUE if the current sequence is the last one in the file, else FALSE.

=cut

sub at_end {
    my ($self) = @_;
    return (eof $self->{ih});
}

=head3 Write

    $fqhandle->Write($oh, $comment);

Write the current record to the specified file handle in FASTA format.

=over 4

=item oh

An open file handle onto which the current record's sequences should be written.

=item comment (optional)

A comment to add to the output.  If omitted and a comment is present in the object, it will be used.

=back

=cut

sub Write {
    my ($self, $oh, $comment) = @_;
    my $header = $self->id;
    if ($comment) {
        $header .= " $comment";
    } elsif ($self->{comment}) {
        $header .= " $self->{comment}";
    }
    print $oh ">$header\n$self->{left}\n";
}

=head3 Out

    my $fqhandle->Out($fileName);

Open an output file with the given name. The file name should not have an extension: one will be added.

=over 4

=item fileName

The name to give to the output file, without an extension.  The extension C<.fa> will be appended.

=item RETURN

Returns a L<FastA::Out> object for writing to the file.

=back

=cut

sub Out {
    my ($self, $fileName) = @_;
    require FastA::Out;
    return FastA::Out->new($fileName);
}


=head2 Data Access Methods

=head3 id

    my $id = $fqhandle->id;

Return the current sequence ID.

=cut

sub id {
    my ($self) = @_;
    return $self->{id};
}

=head3 left

    my $dna = $fqhandle->left;

Return the left data string.

=cut

sub left {
    my ($self) = @_;
    return $self->{left};
}

=head3 lqual

    my $dna = $fqhandle->lqual;

Return the left quality string.

=cut

sub lqual {
    my ($self) = @_;
    return $self->{lqual};
}

=head3 right

    my $dna = $fqhandle->right;

Return the right data string.

=cut

sub right {
    my ($self) = @_;
    return $self->{right};
}

=head3 rqual

    my $dna = $fqhandle->rqual;

Return the right quality string.

=cut

sub rqual {
    my ($self) = @_;
    return $self->{rqual};
}

=head3 comment

    my $comment = $fqhandle->comment;

Return the current record's comment.

=cut

sub comment {
    my ($self) = @_;
    return $self->{comment};
}

=head3 seqs

    my @seqs = $fqhandle->seqs;

Return a list of the sequences stored in the object. (There is only one.)

=cut

sub seqs {
    my ($self) = @_;
    return ($self->{left});
}

1;