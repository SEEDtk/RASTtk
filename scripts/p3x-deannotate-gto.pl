#!/usr/bin/env perl
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

=head1 Remove Annotations from a GTO file

    p3x-deannotate-gto.pl [options]

This is a simple script that removes all annotations from an incoming L<GenomeTypeObject> and then writes the result.

=head2 Parameters

There are no positional parameters.

The standard input can be overridden using the options in L<P3Utils/ih_options>.


=cut

use strict;
use P3DataAPI;
use P3Utils;
use GenomeTypeObject;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::ih_options());

# Open the input file.
my $ih = P3Utils::ih($opt);
# Read in the GTO.
my $gto = GenomeTypeObject->create_from_file($ih);
# Delete the annotations.
$gto->{features} = [];
delete $gto->{quality} if $gto->{quality};
$gto->{subsystems} = [];
# Write the result.
$gto->destroy_to_file(\*STDOUT);
