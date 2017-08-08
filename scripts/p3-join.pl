=head1 Join Two Files on a Key Field

    p3-join.pl [options] file1 file2

Join two files together on a single key field. Each record in the output will contain the fields from the first
file followed by the fields from the second file except for its key field. For each record in the first file,
every matching record in the second file will be appended. If no second-file records match, the first-file record
will be skipped.

=head2 Parameters

The positional parameters are the names of the two files. If only one file is specified, the second file
will be taken from the standard input.

The standard input can be overriddn using the options in L<P3Utils/ih_options>.

Additional command-line options are the following.

=over 4

=item key1

The index (1-based) or name of the key column in the first file. The default C<0>, indicating the last column.

=item key2

The index (1-based) or name of the key column in the second file. The default is the value of C<--key1>.

=back

=cut

use strict;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('file1 file2', P3Utils::ih_options(),
        ['nohead', 'input files have no headers'],
        ['batchSize=i', 'hidden', { default => 10 }],
        ['key1|k1|1=s', 'key field for file 1', { default => 0 }],
        ['key2|k2|2=s', 'key field for file 2']
        );
# Get the key field parameters.
my $key1 = $opt->key1;
my $key2 = $opt->key2 // $key1;
# Get the two file names.
my ($file1, $file2) = @ARGV;
if (! $file1) {
    die "At least one file name is required.";
} elsif (! -f $file1) {
    die "File $file1 not found or invalid.";
}
# Get the second file. We will read this into memory.
my %file2;
my $ih;
if ($file2) {
    open($ih, '<', $file2) || die "Could not open second file $file2: $!";
} else {
    $ih = P3Utils::ih($opt);
}
# Compute the key column for file 2.
my ($headers2) = P3Utils::process_headers($ih, $opt, 1);
my $col2 = P3Utils::find_column($key2, $headers2);
# Remove the key column from the headers.
splice @$headers2, $col2, 1;
# Loop through the file, filling the hash.
while (! eof $ih) {
    my $line = <$ih>;
    my @fields = P3Utils::get_fields($line);
    my ($key) = splice @fields, $col2, 1;
    push @{$file2{$key}}, \@fields;
}
close $ih; undef $ih;
# Now we open up the first file and get the headers.
open($ih, '<', $file1) || die "Could not open $file1: $!";
my ($headers1) = P3Utils::process_headers($ih, $opt, 1);
my $col1 = P3Utils::find_column($key1, $headers1);
# Output the headers.
if (! $opt->nohead) {
    my @outHeaders = (@$headers1, @$headers2);
    P3Utils::print_cols(\@outHeaders);
}
# Loop through the first file, joining with the second file.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $col1, $opt);
    for my $couplet (@$couplets) {
        my ($key, $line) = @$couplet;
        # We now need the list of file2 records matching this key.
        my $joinList = $file2{$key} // [];
        for my $joinLine (@$joinList) {
            P3Utils::print_cols([@$line, @$joinLine]);
        }
    }
}
