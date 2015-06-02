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

package ScriptUtils;

    use strict;
    use warnings;
    use Getopt::Long::Descriptive;


=head1 Script Utilities

This package contains utilities that are useful in coding SEEDtk command-line scripts.

=head2 Special Methods

=head3 WarnHandler

The Perl EPIC debugger does not handle warnings properly. This method fixes the problem.
It is hooked into the warning signal if the environment variable STK_TYPE is not set.
That variable is set by the various C<user-env> scripts, which are more or less required
in the non-debugging environments. If it is executed accidentally, it does no harm.

=cut

sub WarnHandler {
    print STDERR @_ ;
}
if (! $ENV{STK_TYPE}) {
    $SIG{'__WARN__'} = 'WarnHandler';
}


=head2 Public Methods

=head3 IH

    my $ih = ScriptUtils::IH($fileName);

Get the input file handle. If the parameter is undefined or empty, the
standard input will be used. Otherwise the file will be opened and an
error thrown if the open fails. When debugging in Eclipse, the
standard input is not available, so this method provides a cheap way for
the input to ber overridden from the command line. This method provides a
compact way of insuring this is possible. For example, if the script has
two positional parameters, and the last is an optional filename, you
would code

    my $ih = ScriptUtils::IH($ARGV[1]);

If the C<-i> option contains the input file name, you would code

    my $ih = ScriptUtils::IH($opt->i);

=over 4

=item fileName

Name of the file to open for input. If the name is empty or omitted, the
standard input will be returned.

=item RETURN

Returns an open file handle for the script input.

=back

=cut

sub IH {
    # Get the parameters.
    my ($fileName) = @_;
    # Declare the return variable.
    my $retVal;
    if (! $fileName) {
        # Here we have the standard input.
        $retVal = \*STDIN;
    } else {
        # Here we have a real file name.
        open($retVal, "<$fileName") ||
            die "Could not open input file $fileName: $!";
    }
    # Return the open handle.
    return $retVal;
}


=head3 ih_options

    my @opt_specs = ScriptUtils::ih_options();

These are the command-line options for specifying a standard input file.

=over 4

=item input

Name of the main input file. If omitted and an input file is required, the standard
input is used.

=back

This method returns the specifications for these command-line options in a form
that can be used in the L<ScriptUtils/Opts> method.

=cut

sub ih_options {
    return (
            ["input|i=s", "name of the input file (if not the standard input)"]
    );
}


=head2 Command-Line Option Methods

=head3 Opts

    my $opt = ScriptUtils::Opts($parmComment, @options);

Parse the command line using L<Getopt::Long::Descriptive>. This method automatically handles
the C<help> option and dies if the command parse fails.

=over 4

=item parmComment

A string that describes the positional parameters for display in the usage statement.

=item options

A list of options such as are expected by L<Getopt::Long::Descriptive>.

=item RETURN

Returns the options object. Every command-line option's value may be retrieved using a method
on this object.

=back

=cut

sub Opts {
    # Get the parameters.
    my ($parmComment, @options) = @_;
    # Parse the command line.
    my ($retVal, $usage) = describe_options('%c %o ' . $parmComment, @options,
           [ "help|h", "display usage information", { shortcircuit => 1}]);
    # The above method dies if the options are invalid. Check here for the HELP option.
    if ($retVal->help) {
        print $usage->text;
        exit;
    }
    return $retVal;
}

=head3 GetBatch

    my @lines = ScriptUtils::GetBatch($ih, $size);

Get a batch of work to do. The specified input stream will be read, and a
list of IDs pulled out, along with the contents of the input lines on
which the IDs were found. The input stream can be an open file handle or a
list of singleton values to return.

=over 4

=item ih

Open input file handle, or alternatively a reference to a list of values to return.
If a list is specified, the items will be removed from the list as they are returned.

=item size (optional)

Maximum permissible batch size. If omitted, the default is C<1000>.

=item column (optional)

Index (1-based) of the column containing the IDs. The default is the last
column.

=item RETURN

Returns a list of 2-tuples; each 2-tuple consists of an ID followed by the text
of the input line containing the ID (with the trailing new-line removed).

=back

=cut

sub GetBatch {
    # Get the parameters.
    my ($ih, $size, $column) = @_;
    # Declare the return variable.
    my @retVal;
    # Compute the batch size.
    my $linesLeft = $size || 1000;
    # Determine the mode in which we're operating.
    if (ref $ih eq 'ARRAY') {
        # Here we have a list reference. Loop through it until we run out or fill
        # the batch.
        while ($linesLeft-- > 0 && @$ih > 0) {
            # Get the next list entry.
            my $id = shift @$ih;
            # Put it in the return list as the desired ID and the line it appeared on.
            push @retVal, [$id, $id];
        }
    } else {
        # Loop through the input until we run out or fill the batch.
        while ($linesLeft-- > 0 && ! eof $ih) {
            # Get the next input line.
            my $line = <$ih>;
            chomp $line;
            # Only proceed if it's nonblank.
            if ($line =~ /\S/) {
                # We'll put our desired column in here.
                my $id = GetColumn($line, $column);
                # Put it in the return list.
                push @retVal, [$id, $line];
            }
        }
    }
    # Return the result.
    return @retVal;
}

=head3 GetColumn

    my $id = ScriptThing::GetColumn($line, $column);

Get the specified column from a tab-delimited input line.

=over 4

=item line

A tab-delimited line of text.

=item column

The index (1-based) of the column whose value is desired. If undefined or 0,
then the last column will be extracted.

=item RETURN

Returns the value of the desired column. Note that if it is the last column, no
trimming of new-line characters will take place.

=back

=cut

sub GetColumn {
    # Get the parameters.
    my ($line, $column) = @_;
    # Declare the return variable.
    my $retVal;
    # Are we looking for a specific column or the last one?
    if ($column) {
        # We want a specific column.
        my @cols = split /\t/, $line;
        $retVal = $cols[$column - 1];
    } else {
        # We want the last column.
        if ($line =~ /.*\t(.+)$/) {
            $retVal = $1;
        } else {
            $retVal = $line;
        }
    }
    # Return the result.
    return $retVal;
}

1;
