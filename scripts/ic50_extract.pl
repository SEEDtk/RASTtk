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
print join("\t", qw(drug cell-line source ic50) ) . "\n";
print STDERR "Processing matrix file.\n";
open(my $ih, "<$pDir/dtp.GI50_OCT06.a_matrix.txt") || die "Could not open matrix file.\n";
# Parse the header line.
my @lines = ScriptUtils::get_line($ih);
# This hash will map cell lines to column numbers.
my %lineCol;
for (my $i = 0; $i < @lines; $i++) {
    my $name = $lines[$i];
    if ($name =~ /:(.+)/) {
        my $clName = $clHash->{"NCI60.$1"};
        if ($clName) {
            $lineCol{$clName} = $i;
            print STDERR "Column $i found for $clName.\n";
            $stats->Add(drugFound => 1);
        }
    }
}
# Loop through the drugs.
while (! eof $ih) {
    my @cols = ScriptUtils::get_line($ih);
    $stats->Add(lineIn => 1);
    my $drugCol = $cols[0];
    my $drug = $drugHash->{$drugCol};
    if ($drug) {
        print STDERR "Data found for $drug.\n";
        $stats->Add(drugFound => 1);
        for my $cl (sort keys %lineCol) {
            my $ic50 = $lineCol{$cl};
            print join("\t", $drug, $cl, 'matrix', -$ic50) . "\n";
            $stats->Add(lineOut => 1);
        }
    }
}
print STDERR "All done.\n" . $stats->Show();

## Clean a name.
sub clean {
    my ($text) = @_;
    my $retVal = uc $text;
    $retVal =~ s/\W+//g;
    return $retVal;
}

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
