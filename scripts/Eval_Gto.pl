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

=head1 Genome Quality Evaluation

    Eval_Gto.pl [options] workDir

Evaluate a genome to determine the annotation quality.  The genome is presented as a GTO on the standard input,
and it is written to the standard output with the quality information included.

=head2 Parameters

The positional parameter is the name of the working directory.

The standard input can be overridden using the options in L<P3Utils/ih_options>.

The standard output can be overridden using the options in L<P3Utils/oh_options>.

Additional command-line options are the following.

=over 4

=item verbose

Display progress messages on STDERR.

=item eval

The name of the directory containing the current evaluation information.  The default is C<Eval> in the SEEDtk global
directory.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use GenomeTypeObject;
use Stats;
use EvalHelper;

$| = 1;

# Get the command-line options.
my $opt = P3Utils::script_opts( 'workDir', P3Utils::ih_options(), P3Utils::oh_options(),
        ['verbose|v', 'Display progress messages on STDERR'],
        ["eval=s", "name of evaluation directory", { default => "$FIG_Config::p3data/Eval" }],
    );
my $stats = Stats->new();
my $evalDir = $opt->eval;

# Get access to PATRIC.
my $p3 = P3DataAPI->new();

# Get the options.
my $oh    = P3Utils::oh($opt);
my $debug = $opt->verbose;

# Process the positional parameters.
my ($workDir) = @ARGV;
if ( !$workDir ) {
    die "No working directory specified.";
}
elsif ( !-d $workDir ) {
    die "Invalid or missing working directory $workDir.";
}

# Read the input GTO.
print STDERR "Loading GTO for Evaluation.\n" if $debug;
my $ih  = P3Utils::ih($opt);
my $gto = GenomeTypeObject->create_from_file($ih);
# Evaluate the genome.
EvalHelper::ProcessGto($gto, checkDir => "$evalDir/CheckR", predictors => "$evalDir/FunctionPredictors",
        p3 => $p3, workDir => $workDir, roleFile => "$evalDir/roles.in.subsystems", rolesToUse => "$evalDir/roles.to.use");
# Write the modified GTO.
print STDERR "Storing GTO from Quality Evaluation.\n" if $debug;
$gto->destroy_to_file($oh);
print STDERR "All done.\n" . $stats->Show() if $debug;
