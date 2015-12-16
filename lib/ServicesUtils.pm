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
    ## TODO more use clauses

=head1 Service Script Utilities

This is a simple package that contains the basic utility methods for common service scripts. The common
service scripts provide a single interface to multiple different genomic databases-- including SEEDtk and
PATRIC, and are designed to allow the creation of command-line pipelines for research.

=head2 Public Methods

    my ($opt, $helper) = ServicesUtils::get_options($parmComment, @options, \%flags);

Parse the command-line options for a services command and return the helper object.

The helper object is only returned if a database connection is required (this is the default).
The type of helper object is determined by the value of the environment variable C<SERVICES>
or by the command-line option --db. The possible choices are

=over 4

=item SEEDtk

Use the L<Shrub> database in the SEEDtk environment.

=back

Thus, to use L<all_genomes> with SEEDtk, you would either need to submit

    all_genomes --db=SEEDtk

or

    export SERVICES=SEEDtk
    all_genomes

The command-line option overrides the environment variable.

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

=item noinput

If TRUE, then it is presumed there is no standard input.

=item nodb

If TRUE, then it is presumed there is no need for a database connection. No helper object will be returned.

=back

=item RETURN

Returns a two-element list consisting of (0) the options object (L<Getopt::Long::Descriptive::Opts>)and
(1) the relevant services helper object (e.g. L<STKServices>). Every command-line option's value may be
retrieved using a method on the options object. All of the commands that require database access are
implemented as methods on the services helper object.

=back

=cut

sub get_options {
    my ($parmComment, @options) = @_;
    # Check for the flags hash.
    my $flags = {};
    if (ref $options[-1] eq 'HASH') {
        $flags = pop @options;
    }
    # Now we must determine the operating environment. Check for a command-line option.
    my $loc = 0; while ($ARGV[$loc] !~ /^--db=(\S+)/) { $loc++ }
}

1;