=head1 Merge Two Files-- Union, Intersection, or Difference

    p3-merge.pl [options] file1 file2

This script reads two files and outputs a new one containing whole lines from those files. The output file can be the union (all lines from both files),
intersection (all lines present in both files), or difference (all lines in the first but not the second). Both files must have the same header line.
This is similar to L<p3-file-filter.pl>, except that script uses a single key field instead of whole lines.

Duplicate lines will be removed. That is, a line that occurs in both files or occurs once in either file will only appear once in the output.

Either file can be replaced by the standard input.

=head2 Parameters

The positional parameters are the names of the two files. A minus sign (C<->) can be used to represent the standard input.

The standard input can be overridden using the options in L<P3Utils/ih_options>.

Additional command-line options are the following.

=over 4

=item nohead

If specified, the files are presumed to have no headers.

=item and

The output should only contain lines found in both files. This is mutually exclusive with C<or> and C<diff>.

=item or

The output should contain all lines from either file. This is the default.

=item diff

The output should contain lines from the first file not found in the second. This is mutually exclusive with C<and> and C<diff>.

=back

=cut

use strict;
use P3Utils;
use Digest::MD5;

# Get the command-line options.
my $opt = P3Utils::script_opts('file1 file2', P3Utils::ih_options(),
        ['nohead', 'input files do not have headers'],
        ['mode' => hidden => { one_of => [['and', 'output lines in both files'],
                                          ['or', 'output lines in either file'],
                                          ['diff', 'output lines only in first']],
                               default => 'or' }]
        );
# Get the input file names.
my ($file1, $file2) = @ARGV;
# Validate the file names.
if (! $file2 || ! $file1) {
    die "Two file names must be specified.";
} elsif ($file2 eq $file1) {
    die "The two files must be different.";
} elsif ($file1 ne '-' && ! -f $file1) {
    die "File $file1 is not found or invalid.";
} elsif ($file2 ne '-' && ! -f $file2) {
    die "File $file2 is not found or invalid.";
}
# Compute the mode and the header option.
my $mode = $opt->mode;
my $nohead = $opt->nohead;
# This will hold the header line.
my $header;
# Now we open the two files. The handles will be put in this list.
my @fh;
for my $file ($file1, $file2) {
    my $fh;
    if ($file eq '-') {
        $fh = P3Utils::ih($opt);
    } else {
        open($fh, "<$file") || die "Could not open $file: $!";
    }
    if (! $nohead) {
        my $headLine = <$fh>;
        # We do this next bit everywhere. In Windows, the standard input comes in with CRLF and everything else with just LF,
        # so we have to normalize the input lines.
        $headLine =~ s/[\r\n]+//;
        if (! defined $header) {
            $header = $headLine;
            print "$header\n";
        } elsif ($headLine ne $header) {
            die "Files have incompatible headers.";
        }
    }
    push @fh, $fh;
}
# Now the header has been processed and output, and we have the file handles.
# This hash tracks records we've seen.
my %seen;
if ($mode eq 'or') {
    # Here we're taking the union of the files. We read both files in order
    # and print the records we've not seen.
    for my $fh (@fh) {
        print_unseen($fh, \%seen);
    }
} elsif ($mode eq 'diff') {
    # Here we're taking the difference. We read the second file and print the unseen ones in the first.
    print_none($fh[1], \%seen);
    print_unseen($fh[0], \%seen);
} elsif ($mode eq 'and') {
    # Here we're taking the intersection. We read the second file and print the seen ones in the first.
    print_none($fh[1], \%seen);
    print_new_seen($fh[0], \%seen);
}


# Read a line and get its key.
sub read_line {
    my ($fh) = @_;
    my $line = <$fh>;
    $line =~ s/[\n\r]+$//;
    my $key = Digest::MD5::md5_base64($line);
    $line .= "\n";
    return ($key, $line);
}

# Read a file into the seen-hash.
sub print_none {
    my ($fh, $seenH) = @_;
    while (! eof $fh) {
        my ($key, $line) = read_line($fh);
        $seenH->{$key} = 1;
    }
}

# Read a file and print unseen lines.
sub print_unseen {
    my ($fh, $seenH) = @_;
    while (! eof $fh) {
        my ($key, $line) = read_line($fh);
        if (! $seenH->{$key}) {
            print $line;
            $seenH->{$key} = 1;
        }
    }
}

# Read a file and print seen lines. We need a second hash here to prevent duplicates
# in the new file.
sub print_new_seen {
    my ($fh, $seenH) = @_;
    my %seen;
    while (! eof $fh) {
        my ($key, $line) = read_line($fh);
        if ($seenH->{$key} && ! $seen{$key}) {
            print $line;
            $seen{$key} = 1;
        }
    }
}