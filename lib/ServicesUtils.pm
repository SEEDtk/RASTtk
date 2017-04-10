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


package ServicesUtils;

    use strict;
    use warnings;
    use Getopt::Long::Descriptive;



=head1 Service Script Utilities

This is a simple package that contains the basic utility methods for common service scripts. The common
service scripts provide a single interface to multiple different genomic databases-- including SEEDtk and
PATRIC, and are designed to allow the creation of command-line pipelines for research.

=head2 Public Methods

=head3 get_options

    my ($opt, $helper) = ServicesUtils::get_options($parmComment, @options, \%flags);

Parse the command-line options for a services command and return the helper object.

The helper object is only returned if a database connection is required (this is the default).
The type of helper object is determined by the value of the environment variable C<SERVICE>
or by the command-line option --db. The possible choices are

=over 4

=item STK

Use the L<Shrub> database in the SEEDtk environment.

=item P3

Use the PATRIC web interface.

=item GP

Use the GenomePackages directory.

=back

Thus, to use L<svc_all_genomes.pl> with SEEDtk, you would either need to submit

    svc_all_genomes --db=SEEDtk

or

    export SERVICE=SEEDtk
    svc_all_genomes

The command-line option overrides the environment variable.

Most commands have the following common command-line options.

=over 4

=item input

Name of the input file. The default is C<->, which uses the standard input.

=item col

Index of the input column (1-based). The default is C<0>, indicating the last column.

=item batch

The number of input records to process in a batch. Most retrieval methods are more efficient operating
on multiple input lines at once, but if commands are strung together in a pipe, breaking the input into
smaller batches increases the opportunity for parallelism. The default is C<500>.

=back

The parameters to this method are as follows:

=over 4

=item parmComment

A string that describes the positional parameters for display in the usage statement. This parameter is
REQUIRED. If there are no positional parameters, use an empty string.

=item options

A list of options such as are expected by L<Getopt::Long::Descriptive>.

=item flags (optional)

A reference to a hash of modifiers to the initialization. This can be zero or more of the following.

=over 8

=item input

Style of input. If C<none>, then there is no input file. If C<file>, then the entire file is input.
If C<col>, then a single column is used as input. The default is C<col>.

=item nodb

If TRUE, then it is presumed there is no need for a database connection. No helper object will be returned.

=item batchSize

The default batch size to use. If C<0>, then no batching is performed. The default default batch size is C<1000>.

=back

=item RETURN

Returns a two-element list consisting of (0) the options object (L<Getopt::Long::Descriptive::Opts>)and
(1) the relevant services helper object (e.g. L<STKServices>). Every command-line option's value may be
retrieved using a method on the options object. All of the commands that require database access are
implemented as methods on the services helper object.

=back

=cut

use constant HELPER_NAMES => { SEEDtk => 'STKServices', P3 => 'P3Services', GP => 'GPServices' };

sub get_options {
    my ($parmComment, @options) = @_;
    # Check for the flags hash.
    my $flags = {};
    if (ref $options[-1] eq 'HASH') {
        $flags = pop @options;
    }
    my $inputStyle = $flags->{input} // 'col';
    my $batchDefault = $flags->{batchSize} // 200;
    # This will contain the name of the helper object.
    my $helperName;
    # This will contain the helper object itself.
    my $helper;
    # This will contain the connection options for the helper.
    my @connectOptions;
    # Do we need a database connection?
    unless ($flags->{nodb}) {
        # Yes. Now we must determine the operating environment. Check for a command-line option.
        my $type;
        my $n = scalar @ARGV;
        for (my $loc = 0; $loc < $n && ! $type; $loc++) {
            if ($ARGV[$loc] =~ /^--db=(\S+)/) {
                $type = $1;
            }
        }
        if (! $type) {
            # No command-line option. Pull from the environment.
            $type = $ENV{SERVICE} // 'SEEDtk';
        }
        # Get the helper name.
        $helperName = HELPER_NAMES->{$type};
        if (! $helperName) {
            die "Invalid database connection type $type.";
        }
        # Create the helper object.
        require "$helperName.pm";
        $helper = eval("$helperName->new()");
        # Get the connection options.
        push @connectOptions, $helper->script_options(),
           [ "db=s", "type of database-- SEEDtk or P3 (if omitted, SERVICE environment variable is used)",
                { default => $ENV{SERVICE} }];
    }
    # Do we need a standard input?
    unless ($inputStyle eq 'none') {
        # Yes. Add the input option.
        push @connectOptions, ["input|i=s", "name of the input file (defaults to standard input)", { default => '-' }];
        # Check for a column specifier.
        if ($inputStyle eq 'col') {
            push @connectOptions, ["col|c=i", "column to use for input (0 for the last)", { default => 0 }];
            push @connectOptions, ["batch|b=i", "number of input records to process per batch (0 for all)", { default => $batchDefault }]
        }
    }
    # Parse the command line. Note that the "db" option is included for documentation purposes,
    # but it has already been examined if it is present.
    my ($opt, $usage) = describe_options('%c %o ' . $parmComment, @options, @connectOptions,
           [ "help|h", "display usage information", { shortcircuit => 1}]);
    # The above method dies if the options are invalid. We check here for the HELP option.
    if ($opt->help) {
        print $usage->text;
        exit;
    }
    # Do we have a database?
    unless ($flags->{nodb}) {
        # Yes. Connect to it.
        $helper->connect_db($opt);
    }
    # Return the results.
    return ($opt, $helper);
}


=head3 ih

    my $ih = ServicesUtils::ih($opt);

Return an open file handle for the standard input.

=over 4

=item opt

L<Getopt::Long::Descriptive::Opts> object returned by L</get_options>.

=back

=cut

sub ih {
    my ($opt) = @_;
    my $fileName = $opt->input;
    my $retVal;
    if ($fileName eq '-') {
        $retVal = \*STDIN;
    } else {
        open($retVal, "<$fileName") || die "Could not open input file $fileName: $!";
    }
    return $retVal;
}

=head3 get_batch

    my @tuples = ServicesUtils::get_batch($ih, $opt, $noBatching);

Get a batch of input to process. This method is used for the common case where we are loading a single
input column from the input file and processing it against the data. The column is specified as a command-line
option, with the default being the last column. The returned batch consists of two-tuples with the input
column in the first element and the fields of the original row as a list reference in the second.

=over 4

=item ih

Open handle to the input file.

=item opt

L<Getopt::Long::Descriptive::Opts> object returned by L</get_options>.

=item noBatching (optional)

If TRUE, then the entire input is read regardless of the batch size.

=item RETURN

Returns a list of 2-tuples, each consisting of (0) an input value from the selected column, and (1) a reference
to a list of all values in the input row (including the input column). If end-of-file is read, an empty list
will be returned.

=back

=cut

sub get_batch {
    my ($ih, $opt, $noBatching) = @_;
    # Access the batch size and the column number.
    my $batchSize = ($noBatching ? 0 : $opt->batch);
    my $col = $opt->col - 1;
    # This will count the number of rows processed.
    my $count = 0;
    # We will stop when the count equals the batch size. It will never equal -1. Note that a batch
    # size of 0 also counts as unlimited.
    $batchSize ||= -1;
    # This will be the return list.
    my @retVal;
    # Loop until done.
    while (! eof $ih && $count != $batchSize) {
        # Get the line and strip off the line-end. We do some fancy dancy for Windows compatability.
        my $line = <$ih>;
        my @flds = split /\t/, $line;
        # Only proceed if the line is nonblank.
        if (@flds) {
        $flds[$#flds] =~ s/[\r\n]+$//;
            # Extract the desired column.
            my $value = $flds[$col];
            # Store and count the result.
            push @retVal, [$value, \@flds];
            $count++;
        }
    }
    return @retVal;
}

=head3 get_column

    my $valueList = ServicesUtils::get_column($fileName, $col);

Get all the values from the specified column in a tab-delimited file.

=over 4

=item fileName

Name of a tab-delimited file, or an open file handle for the input.

=item col

Index (1-based) of the column from which to get the values. A value of C<0> indicates the last column.

=item RETURN

Returns a reference to a list of the values read.

=back

=cut

sub get_column {
    my ($fileName, $col) = @_;
    my $ih;
    if (ref $fileName eq 'GLOB') {
        $ih = $fileName;
    } else {
        open($ih, "<$fileName") || die "Could not open $fileName: $!";
    }
    my @retVal;
    while (! eof $ih) {
        # Get the input line.
        my $line = <$ih>;
        # Split into columns.
        my @cols = split /\t/, $line;
        if (@cols) {
            $cols[$#cols] =~ s/\r?\n$//;
        }
        push @retVal, $cols[$col - 1];
    }
    return \@retVal;
}


=head3 get_cols

    my @values = ServicesUtils::get_cols($ih, @cols);

Get one or more columns from the next input line.

=over 4

=item ih

Open file handle for the input file. The next line will be read and parsed into columns.

=item cols

List containing the 1-based column indexes. A column index of 0 indicates the last column.
The string 'all' indicates all columns.

=item RETURN

Returns a list of the values found in the specified columns.

=back

=cut

sub get_cols {
    my ($ih, @cols) = @_;
    # Get the input line.
    my $line = <$ih>;
    # Split into columns.
    my @values = split /\t/, $line;
    # Strip off the line-end characters.
    if (@values) {
        $values[$#values] =~ s/\r?\n$//;
    }
    # Extract the desired values.
    my @retVal;
    for my $col (@cols) {
        if ($col eq 'all') {
            push @retVal, @values;
        } else {
            push @retVal, $values[$col - 1];
        }
    }
    # Return the result.
    return @retVal;
}

=head3 log_print

    ServicesUtils::log_print($logh, $message);

Display the specified message on a log file. If the log file handle is undefined, nothing will happen.

=over 4

=item logh

Open output handle for the log file, or C<undef> to suppress logging.

=item message

Message to print if logging is in effect.

=back

=cut

sub log_print {
    my ($logh, $message) = @_;
    if ($logh) {
        print $logh $message;
    }
}

=head3 json_field

    my $value = json_field($object, $name, %options);

Get the value of a field from an object that is believed to have been read from JSON format. If the
object is a workspace object, it is dereferenced. If the field is not found, an error is thrown.

=over 4

=item object

Object from which to extract the field.

=item name

Name of the field to extract.

=item options

A hash of options, containing zero or more of the following keys.

=over 8

=item optional

If TRUE, then a missing field will return an undefined value instead of an error.

=back

=item RETURN

Returns the value of the specified field.

=back

=cut

sub json_field {
    my ($object, $name, %options) = @_;
    my $retVal;
    # Check for the field.
    if (exists ($object->{$name})) {
        $retVal = $object->{$name};
    } else {
        # Try de-referencing.
        if (! exists $object->{data}) {
            if (! $options{optional}) {
                die "Field $name not found in input object.";
            }
        } else {
            my $data = $object->{data};
            if (! exists $data->{$name}) {
                if (! $options{optional}) {
                    die "Field $name not found in input object.";
                }
            } else {
                $retVal = $data->{$name};
            }
        }
    }
    # Return the result.
    return $retVal;
}

=head3 contig_tuples

    my $contigTuples = ServicesUtils::contig_tuples($jsonObject);

Extract the contigs from a genome type object. The object can be a workspace object, a real
L<GenomeTypeObject>, or a kBase contigs object. The fields of the object are examined in order
to determine the type of object and the method for extraction.

=over 4

=item jsonObject

A L<GenomeTypeObject>, a kBase contigs object, or a kBase workspace contigs object.


=item RETURN

Returns a reference to a list of tuples, each consisting of a contig ID, an empty string, and
a sequence.

=back

=cut

sub contig_tuples {
    my ($jsonObject) = @_;
    # Get the contig list.
    my $contigList = json_field($jsonObject, 'contigs');
    # This will contain the tuples to return.
    my @retVal = map { [$_->{id}, '', ($_->{dna} // $_->{sequence}) ] } @$contigList;
    # Return the result.
    return \@retVal;
}

1;