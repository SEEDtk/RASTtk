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
use Stats;

=head1 Extract Dose Response Data from PATRIC Files

    dose_response_extract.pl [ options ] pDir drugFile lineFile

This script will access a PATRIC dose-response directory and extract data for specified cell lines and drugs.
Each basic source type (e.g. C<CCLE>, C<NCI60>) has files in the C<drugs>, C<dose_response>, and C<cell_lines>
directories. All files are tab-delimited with headers. Cell Line name mappings have the file name I<XXXX>C<_cl>
in the C<cell_lines> directory. The first column is the ID used in the dose-response file and the third is the
clean name expected as input. Drug name mappings have the file name I<XXXX>C<_drugs> in the C<drugs> directory.
Again, the first column is the ID used in the dose-response file and the third is the clean name. The actual data
is in a file called I<XXXX>C<_dose_response> in the C<dose_response> directory. Each line contains the drug ID in the
first column, the cell line ID in the second column, the concentration unit in the third column, the log of the
concentration in the fourth, and the percent growth in the fifth column.

Dose-reponse lines that contain both a desired drug and a desired cell line will be output in roughly the same
format as input, except that the drug and cell line IDs will be replaced with the clean names, and the fourth column
(not used from the input) will be replaced with the source type code.

=head2 Parameters

The positional parameters are the name of the PATRIC data directory, the name of the file containing the cleaned drug
names, and the name of the file containing the cleaned cell line names. The name files should contain one name per line.

The command-line options are the following (currently none).

=over 4

## TODO more command-line options

=back

=cut

# list of report types
use constant TYPES => [qw(CCLE CTRP GDSC gCSI NCI60)];

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('pDir drugFile lineFile',
        );
# Validate the parameters.
my ($pDir, $drugFile, $lineFile) = @ARGV;
if (! $pDir) {
    die "No input directory specified.";
} elsif (! -d $pDir) {
    die "$pDir is missing or invalid.";
} elsif (! $drugFile) {
    die "No drug name file specified.";
} elsif (! -s $drugFile) {
    die "$drugFile is missing or empty.";
} elsif (! $lineFile) {
    die "No cell line name file specified.";
} elsif (! -s $lineFile) {
    die "$lineFile is missing or empty.";
}
my $stats = Stats->new();
# Read in the cell line and drug IDs of interest.
my $clHash = ReadNames("$pDir/cell_lines", cl => $lineFile);
my $drugHash = ReadNames("$pDir/drugs", drugs => $drugFile);
# Write the output header.
print join("\t", qw(drug cell-line unit log-conc source growth) ) . "\n";
# Loop through the dose/response files.
for my $source (@{TYPES()}) {
    print STDERR "Processing dose-reponse for $source.\n";
    my $fname = $source . "_dose_response";
    open(my $ih, "<$pDir/dose_response/$fname") || die "Could not open $fname: $!";
    # Eject the header line.
    my $line = <$ih>;
    # Loop through the data lines.
    while (! eof $ih) {
        my ($drug, $cl, $unit, $conc, undef, $growth) = ScriptUtils::get_line($ih);
        my $dName = $drugHash->{$drug};
        my $clName = $clHash->{$cl};
        if ($dName && $clName) {
            $stats->Add("$source-dataFound" => 1);
            print join("\t", $dName, $clName, $unit, $conc, $source, $growth) . "\n";
        } else {
            $stats->Add("$source-dataSkipped" => 1);
        }
    }
}
print STDERR "All done.\n" . $stats->Show();

## Create the id-to-name mappings for drugs or cell lines.
sub ReadNames {
    my ($dir, $type, $inFile) = @_;
    # This will be the return hash.
    my %retVal;
    # Read in the names of interest.
    print STDERR "Reading $inFile for $type names.\n";
    open(my $ih, "<$inFile") || die "Could not open $inFile: $!";
    my %names;
    while (! eof $ih) {
        my $line = <$ih>;
        chomp $line;
        $stats->Add("$type-in" => 1);
        $names{$line} = 1;
    }
    close $ih;
    # We need to process each data source.
    for my $source (@{TYPES()}) {
        # Open the data source's mapping file.
        my $fname = $source . "_$type";
        open(my $dh, "<$dir/$fname") || die "Could not open $fname: $!";
        # Skip the header.
        my $line = <$dh>;
        # Read the IDs.
        while (! eof $dh) {
            my ($id, undef, $name) = ScriptUtils::get_line($dh);
            if (! $name) {
                print STDERR "Bug for $id in $fname.\n";
            } elsif ($names{$name}) {
                $retVal{$id} = $name;
                $stats->Add("$type-mapped" => 1);
            } else {
                $stats->Add("$type-skipped" => 1);
            }
        }
    }
    # Return the hash table.
    return \%retVal;
}
