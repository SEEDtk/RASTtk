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
    if ($line =~ /^>(\S+)/) {
        $retVal->{next_id} = $1;
    }
    # Bless and return this object.
    bless $retVal, $class;
    return $retVal;
}


=head2 Public Manipulation Methods

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
    # Loop until we hit a new record or we hit the end of the file.
    my $done;
    while (! eof $ih && ! $done) {
        # Read the data lines until we hit the end.
        my $line = <$ih>;
        if ($line =~ /^>(\S+)/) {
            # Here we have a header for a new record.
            ($self->{id}, $self->{next_id}) = ($self->{next_id}, $1);
            $done = 1;
        } else {
            # Here we have sequence data.
            $line =~ s/[\r\n]+$//;
            push @seqs, $line;
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

=head3 Write

    $fqhandle->Write($oh);

Write the current record to the specified file handle in FASTA format.

=over 4

=item oh

An open file handle onto which the current record's sequences should be written.

=back

=cut

sub Write {
    my ($self, $oh) = @_;
    my $id = $self->id;
    print $oh ">$id\n$self->{left}\n";
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

=head3 seqs

    my @seqs = $fqhandle->seqs;

Return a list of the sequences stored in the object. (There is only one.)

=cut

sub seqs {
    my ($self) = @_;
    return ($self->{left});
}

=head2 Internal Utilities

=head3 _read_fastq

    $fqhandle->_read_fastq($ih, $dir);

Read the next record from the indicated FASTQ input stream and store its data in the specified object members.

=over 4

=item ih

Open file handle for the FASTQ file.

=item dir

C<left> for a left record and C<right> for a right record.

=back

=cut

sub _read_fastq {
    my ($self, $ih, $dir) = @_;
    # Compute the quality string member name.
    my $qual = substr($dir, 0, 1) . 'qual';
    # This will hold the sequence ID.
    my $id;
    # Read the ID line.
    my $line = <$ih>;
    if ($line =~ /^\@(\S+)/) {
        $id = $1;
    } else {
        die "Invalid FASTQ input: $line";
    }
    # Read the data line.
    my $data = <$ih>;
    die "Missing data line for $id in FASTQ file." if ! defined $data;
    chomp $data;
    $self->{$dir} = $data;
    # Read the quality header.
    $line = <$ih>;
    if (! $line || substr($line, 0, 1) ne '+') {
        die "Invalid quality header for $id in FASTQ file.";
    } else {
        # Read the quality data.
        $line = <$ih>;
        die "Missing quality line for $id in FASTQ file." if ! defined $line;
        chomp $line;
        if (length($line) ne length($data)) {
            die "Incorrect length for quality line belonging to $id in FASTQ file.";
        } else {
            $self->{$qual} = $line;
        }
    }
    # Normalize the ID and store it.
    $self->{id} = norm_id($id);
}


1;