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


use strict;
use warnings;
use FIG_Config;
use ScriptUtils;
use File::Copy::Recursive;

=head1 Run CheckM Tool

    run_checkm.pl [ options ] fileName workDir

This script runs the CheckM binning evaluation tool. It only works on the maple.mcs.anl.gov server.

=head2 Parameters

The positional parameters are the name of a fasta file and the name of a working directory. The working directory is used to store
temporary files. The temporary files will be stored in a subdirectory whose name is taken from the process ID.

The scoring report will be sent to the standard output.

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('fileName workDir'
        );
# Verify that we have the necessary paths.
if (! ($ENV{PATH} =~ m#/disks/patric-common/runtime/bin#)) {
    $ENV{PATH} = "/disks/patric-common/runtime/bin:$ENV{PATH}";
}
my ($fileName, $workDir) = @ARGV;
if (! $workDir) {
    die "No working directory specified.";
} elsif (! -d $workDir) {
    die "Invalid working directory $workDir.";
} elsif (! $fileName) {
    die "No input file specified.";
} elsif (! -s $fileName) {
    die "Invalid input file $fileName.";
}
# Create the temporary directory.
my $tempDir = "$workDir/cm$$";
if (-d $tempDir) {
    File::Copy::Recursive::pathempty($tempDir);
} else {
    File::Copy::Recursive::pathmk($tempDir);
}
# Copy in the fasta file.
File::Copy::Recursive::fcopy($fileName, "$tempDir/contigs.fna");
# Run checkm.
system('checkm', 'lineage_wf', '--tmpdir', "$tempDir/Temp", $tempDir, "$tempDir/cm");
