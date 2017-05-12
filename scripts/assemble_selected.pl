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
use ScriptUtils;
use FastQ;
use FQUtils;
use SeedAware;

=head1 Assemble Selected Reads Into Contigs

    assemble_selected.pl [ options ] workDir file1 file2 ... fileN

This script will assemble selected reads from FASTQ files into contigs. The sequences specified in the standard
input file will be selected from the specified FASTQ files and then written into an interlaced FASTQ work file.
This file is then input into the SPAdes assembler to be converted into contigs. The output will be in the file
C<contigs.fasta> in the specified work directory.

=head2 Parameters

The positional parameters should be the name of the working directory followed by the names of the input FASTQ files,
in sequence. If the input files are paired (rather than interlaced), each left-end files should be specified
immediately before its paired right-end file.

The standard inptu should be tab-delimited, with the sequence IDs in the first column.

The working files used by SPAdes and the output FASTA file will be put in the working directory.

The command-line options are those found in L<ScriptUtils/ih_options> (to specify the standard input) plus the following.

=over 4

=item interlaced

If specified, the input FASTQ files are presumed to be interlaced rather than paired.

=back

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('file1 file2 ... fileN', ScriptUtils::ih_options(),
        ['interlaced|inter|i', 'files are in interlaced format']
        );
# Verify that we have a good working directory.
my ($workDir, @files) = @ARGV;
if (! $workDir) {
    die "No working directory specified.\n";
} elsif (! -d $workDir) {
    # No directory. Try to create it.
    print "Creating $workDir.\n";
    mkdir $workDir;
}
# Processing the list of input files.
my $fileList = FastQ::OrganizeFiles($opt->interlaced, @files);
print scalar(@$fileList) . " input sets found.\n";
# Create a hash of the desired sequences.
print "Reading IDs from input.\n";
my %idList;
my $ih = ScriptUtils::IH($opt->input);
while (! eof $ih) {
    my $line = <$ih>;
    if ($line =~ /^(\S+)/) {
        # Normalize the ID in case there is a direction suffix.
        my $id = FastQ::norm_id($1);
        $idList{$id} = 1;
    }
}
print scalar(keys %idList) . " IDs read from input.\n";
close $ih;
# Open the output file.
open(my $oh, ">$workDir/sampling.fastq") || die "Could not open FASTQ output file: $!";
# Loop through the input files.
for my $filePair (@$fileList) {
    # Open the input files.
    print "Processing input " . join(' ', @$filePair) . "\n";
    my $fqh = FastQ->new(@$filePair);
    FQUtils::FilterFastQ($fqh, \%idList, $oh);
}
# Close the output.
close $oh;
# Call SPAdes to assemble the sequences.
print "Invoking the SPAdes assembler.\n";
my $cmdPath = SeedAware::executable_for('spades.py');
my @parms = ('-o', $workDir, '-12', "$workDir/sampling.fastq");
my $rc = system($cmdPath, @parms);
die "Error exit $rc from SPAdes." if $rc;
print "All done.\n";