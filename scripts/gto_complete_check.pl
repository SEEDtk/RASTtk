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
use GenomeTypeObject;
use Stats;

=head1 Check GTO Completeness

    gto_complete_check.pl [ options ] gto1 gto2 ... gtoN

This script checks one or more LGenomeTypeObject> files to determine whether or not the described genomes are
considered complete in the sense that 70% of the DNA is in long contigs (that is, contigs of length greater than
or equal to 20 kilobases). The output is a two-column tab-delimited file consisting of the GTO file name in the
first column and a value of C<1> (complete) or C<0> (incomplete) in the second column.

=head2 Parameters

The positional parameters are the file names of the JSON-format GenomeTypeObjects.

The command-line options are as follows.

=over 4

=item recursive

If specified, should be the name of a directory. All of the C<.gto> files in the directory will be examined.

=item cleanup

If specified, the files for incomplete genomes will be deleted. The default is to not delete any files.

=item stats

If specified, statistics will be written to the standard error file. The default is  to not write any statistics.

=back

=cut

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('gto1 gto2 ... gtoN',
        ['recursive|R=s', 'directory containing GTOs to examine'],
        ['cleanup', 'delete incomplete GTO files'],
        ['stats|v', 'display statistics on STDERR']
        );
my $cleanup = $opt->cleanup;
my $stats = Stats->new();
my $recursive = $opt->recursive;
if ($recursive && ! -d $recursive) {
    die "Invalid directory $recursive.";
}
# Create the list of GTOs.
my @gtos = @ARGV;
if ($recursive) {
    opendir(my $dh, $recursive) || die "Could not open directory $recursive: $!";
    my @inDir = grep { $_ =~ /\.gto$/ && -s "$recursive/$_" } readdir $dh;
    push @gtos, map { "$recursive/$_" } @inDir;
}
# Loop through the list.
for my $gtoFile (@gtos) {
    if (! -f $gtoFile) {
        die "File $gtoFile not found.";
    } else {
        my $gto = GenomeTypeObject->create_from_file($gtoFile);
        $stats->Add(fileIn => 1);
        if ($gto->is_complete) {
            $stats->Add(complete => 1);
            print "$gtoFile\t1\n";
        } else {
            $stats->Add(incomplete => 1);
            print "$gtoFile\t0\n";
            if ($cleanup) {
                unlink $gtoFile;
                $stats->Add(deleted => 1);
            }
        }
    }
}
if ($opt->stats) {
    print STDERR $stats->Show();
}

