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

=head3 get_col

    my @values = ScriptUtils::get_col($ih, $col);

Read from the specified tab-delimited input stream and extract the values from the specified column.
An undefined or zero value for the column index will retrieve the last column in each row.

=over 4

=item ih

Open input handle for a tab-delimited file.

=item col

Index (1-based) of the desired column. A zero or undefined value may be used to specified the last column.

=item RETURN

Returns a list of the values retrieved.

=back

=cut

sub get_col {
    my ($ih, $col) = @_;
    my @retVal;
    while (! eof $ih) {
        my $line = <$ih>;
        $line =~ s/\r?\n$//;
        my @flds = split /\t/, $line;
        if ($col) {
            push @retVal, $flds[$col - 1];
        } else {
            push @retVal, pop @flds;
        }
    }
    return @retVal;
}

1;
