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
use Spreadsheet::WriteExcel;
use IC50;

=head1 Extract Dose Response Data from PATRIC Files Into a Spreadsheet

    dose_response_sheets.pl [ options ] pDir drugFile lineFile

This script will access a PATRIC dose-response directory and extract data for specified cell lines and drugs.
Each basic source type (e.g. C<CCLE>, C<NCI60>) has files in the C<drugs>, C<dose_response>, and C<cell_lines>
directories. All files are tab-delimited with headers. Cell Line name mappings have the file name I<XXXX>C<_cl>
in the C<cell_lines> directory. The first column is the ID used in the dose-response file and the third is the
clean name expected as input. Drug name mappings have the file name I<XXXX>C<_drugs> in the C<drugs> directory.
Again, the first column is the ID used in the dose-response file and the third is the clean name. The actual data
is in a file called C<combined_single_drug_growth> in the C<dose_response> directory. Each line contains the source
in the first column, the drug ID in the second column, the cell line ID in the third column, the concentration unit
in the fourth column, the log of the concentration in the fifth, and the percent growth in the seventh column.

Dose-reponse lines that contain both a desired drug and a desired cell line will be output into an Excel Workbook.
There will be one sheet for each cell/drug pair. The A column will be the log dosage and each successive column
will contain the growth rate for a single source. Only one of the growth rate columns will have a value. This
makes it easier to generate Excel charts from the output.

=head2 Parameters

The positional parameters are the name of the PATRIC data directory, the name of the file containing the cleaned drug
names, and the name of the file containing the cleaned cell line names. The name files should contain one name per line.

The command-line options are the following.

=over 4

=item workbook

The name of the output spreadsheet. If the file exists, it will be destroyed. The default is C<growth.xlsm> in the
input directory.

=back

=cut

# list of report types
use constant TYPES => [qw(CCLE CTRP GDSC SCLC NCI60)];
use constant TYPEH => { CCLE => 1, CTRP => 2, GDSC => 3, SCLC => 4, NCI60 => 5, ALMANAC => 6, NCI60M => 7, ALMANACM => 8 };
use constant IC50H => { GDSC => 11, NCI60 => 12 };
use constant IC50L => 10;

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('pDir drugFile lineFile',
        ['workbook|wb|w=s', 'output file name'],
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
# Compute the output file name and create the spreadsheet writer.
my $output = $opt->workbook // "$pDir/growth.xls";
if (-f $output) {
    print "Deleting old $output.\n";
    unlink $output;
}
my $workbook = Spreadsheet::WriteExcel->new($output);
print "Spreadsheet created as $output.\n";
# Read in the cell line and drug IDs of interest.
my $clHash = ReadNames("$pDir/cell_lines", cl => $lineFile);
my $drugHash = ReadNames("$pDir/drugs", drugs => $drugFile);
# This is a two-level hash. It contains a list of [dosage,growth] tuples for each drug/cl pair.
# We use it to sort and process the data.
my %growthMap;
# Connect to the input file.
print "Processing input file.\n";
open(my $ih, "<$pDir/dose_response/combined_single_drug_growth") || die "Could not open input file: $!";
my ($count, $found) = (0, 0);
# Discard the header.
my $line = <$ih>;
# Loop through the data.
while (! eof $ih) {
    my ($type, $drug, $cl, undef, $dosage, undef, $growth) = ScriptUtils::get_line($ih);
    $stats->Add(lineIn => 1);
    # Check to see if we care about this data line.
    my $dName = $drugHash->{$drug};
    my $clName = $clHash->{$cl};
    if ($dName && $clName) {
        # Yes we do.
        $stats->Add(lineUsed => 1);
        push @{$growthMap{$dName}{$clName}{$type}}, [$dosage, $growth];
        $found++;
    } elsif (! $dName) {
        $stats->Add(lineNotDrug => 1);
    } else {
        $stats->Add(lineDrugNotCl => 1);
    }
    $count++;
    print "$count lines processed. $found used.\n" if $count % 100000 == 0;
}
close $ih; undef $ih;
print "Processing ALMANAC values.\n";
($count, $found) = (0, 0);
open($ih, "<$pDir/dose_response/growth.tbl") || die "Could not open ALMANAC file: $!";
# This is the output column for almanac.
my $col = TYPEH->{ALMANAC};
# Skip the header line.
$line = <$ih>;
while (! eof $ih) {
    my @cols = ScriptUtils::get_line($ih);
    $stats->Add(almanacIn => 1);
    if ($cols[14]) {
        $stats->Add(almanacDualLine => 1);
    } else {
        # Here we have a single-drug data line. Drugs are NSC numbers.
        my $drug = "NSC.$cols[8]";
        my $dName = $drugHash->{$drug};
        # Cell lines are NCI60 identifiers.
        my $cl = "NCI60.$cols[28]";
        my $clName = $clHash->{$cl};
        if ($dName && $clName) {
            $stats->Add(almanacFound => 1);
            my $rawDosage = $cols[11];
            my $dosage = log($rawDosage) / log(10);
            my $growth = $cols[19];
            push @{$growthMap{$dName}{$clName}{ALMANAC}}, [$dosage, $growth];
            $stats->Add(almanacUsed => 1);
            $found++;
        } else {
            $stats->Add(almanacSkipped => 1);
        }
    }
    $count++;
    print "$count lines processed. $found used.\n" if $count % 100000 == 0;
}
close $ih; undef $ih;
# Compute the mean values for the two high-volume sources.
for my $source (qw(NCI60 ALMANAC)) {
    print "Computing mean growth rates for $source.\n";
    my $meanType = $source . 'M';
    $col = TYPEH->{$meanType};
    for my $drug (keys %growthMap) {
        my $clMap = $growthMap{$drug};
        for my $cl (keys %$clMap) {
            my $srcMap = $clMap->{$cl}{$source};
            if ($srcMap) {
                # Here we need to compute the mean value for each dosage. Get total and count.
                my %growths;
                my %counts;
                for my $pair (@$srcMap) {
                    my ($dosage, $growth) = @$pair;
                    $growths{$dosage} += $growth;
                    $counts{$dosage}++;
                }
                # Now fill in the means.
                for my $dosage (keys %growths) {
                    my $growth = $growths{$dosage}/$counts{$dosage};
                    push @{$growthMap{$drug}{$cl}{$meanType}}, [$dosage, $growth];
                }
            }
        }
    }
}
# Now we need to read in the IC50 values from the two downloaded files.
my %ic50;
for my $type (keys %{IC50H()}) {
    ($count, $found) = (0, 0);
    print "Reading IC50 results for $type.\n";
    open($ih, "<$pDir/dose_response/${type}_IC50") || die "Could not open $type IC50 file: $!";
    my $line = <$ih>;
    while (! eof $ih) {
        my ($drug, $cl, $dose) = ScriptUtils::get_line($ih);
        $stats->Add("$type-ic50LineIn" => 1);
        # Check to see if we care about this data line.
        my $dName = $drugHash->{$drug};
        my $clName = $clHash->{$cl};
        if ($dName && $clName) {
            # Yes we do.
            $ic50{$dName}{$clName}{$type} = $dose;
            $stats->Add("$type-ic50LineUsed" => 1);
            $found++;
        }
        $count++;
        print "$count lines processed. $found used.\n" if $count % 100000 == 0;
    }
    close $ih; undef $ih;
}
# We need an IC50 computer.
my $ic50Thing = IC50->new();
# Now we have all of the data. We must write it into the spreadsheet.
print "Filling in spreadsheet.\n";
# First, create the IC50 master sheet.
my $ic50Sheet = $workbook->add_worksheet("IC50");
$ic50Sheet->write_string(0, 0, "Drug");
$ic50Sheet->write_string(0, 1, "Cell line");
for my $type (keys %{TYPEH()}) {
    $ic50Sheet->write_string(0, TYPEH->{$type} + 1, $type);
}
my $ic50Row = 0;
# Now process the drug / cell-line pairs.
for my $drug (sort keys %growthMap) {
    print "Processing drug $drug.\n";
    my $clMap = $growthMap{$drug};
    my $ic50Map = $ic50{$drug} // {};
    for my $cl (sort keys %$clMap) {
        my $ic50H = $ic50Map->{$cl} // {};
        print "Processing sheet $drug $cl.\n";
        # Here we need to open a sheet for this drug/CL pair.
        my $sheet = $workbook->add_worksheet("$drug $cl");
        $stats->Add(pairFound => 1);
        $sheet->write_string(2, 0, "Dosage");
        for my $type (keys %{TYPEH()}) {
            $sheet->write_string(2, TYPEH->{$type}, $type);
        }
        $ic50Row++;
        $ic50Sheet->write_string($ic50Row, 0, $drug);
        $ic50Sheet->write_string($ic50Row, 1, $cl);
        # The first row contains the offsets.
        $sheet->write_string(0, 0, "Offset");
        # The second row contains the computed IC50s.
        $sheet->write_string(1, 0, "IC50");
        my $pairMap = $clMap->{$cl};
        my @types = keys %$pairMap;
        for my $type (@types) {
            my $pairs = $pairMap->{$type};
            my $ic50 = $ic50Thing->computeFromPairs($pairs);
            if (defined $ic50) {
                $sheet->write_number(1, TYPEH->{$type}, $ic50);
                $ic50Sheet->write_number($ic50Row, TYPEH->{$type} + 1, $ic50);
                $stats->Add(ic50Computed => 1);
            }
        }
        # Past the end, the first two rows contain IC50 numbers from the web.
        $sheet->write_string(1, IC50L, "IC50");
        for my $type (keys %{IC50H()}) {
            $sheet->write_string(0, IC50H->{$type}, $type);
            my $value = $ic50H->{$type};
            if (defined $value) {
                $sheet->write_number(1, IC50H->{$type}, $value);
            }
        }
        # Get the map of source types to tuple lists. We must sort the lists and compute the offsets
        # To get each one starting at 100.
        print "Computing offsets and sorting dosages.\n";
        for my $type (@types) {
            my $tuples = $pairMap->{$type};
            my @sorted = sort { $a->[0] <=> $b->[0] } @$tuples;
            my $offset = 100 - $sorted[0][1];
            $sheet->write_number(0, TYPEH->{$type}, $offset);
            for my $tuple (@sorted) {
                $tuple->[1] += $offset;
            }
            $pairMap->{$type} = \@sorted;
        }
        # Now all the tuple lists are sorted and scaled. We do a sort of merge-y thing to put them
        # into the output in dosage order. We start on row 2.
        print "Writing data.\n";
        my $row = 3;
        while (@types) {
            # Get the minimum of the top dosage in each type.
            my $minDosage = 1000000;
            for my $type (@types) {
                my $dosage = $pairMap->{$type}[0][0];
                if ($minDosage > $dosage) { $minDosage = $dosage; }
            }
            # Output everything at this dosage level. Note we keep a list of types with data still in them.
            $sheet->write_number($row, 0, $minDosage);
            my @keepers;
            for my $type (@types) {
                my $tuples = $pairMap->{$type};
                if ($minDosage == $tuples->[0][0]) {
                    my $tuple = shift @$tuples;
                    if (@$tuples) {
                        push @keepers, $type;
                    }
                    $sheet->write_number($row, TYPEH->{$type}, $tuple->[1]);
                } else {
                    push @keepers, $type;
                }
            }
            @types = @keepers;
            $row++;
        }
    }
}
print "Updating spreadsheet.\n";
$workbook->close();
print "All done.\n" . $stats->Show();

## Clean a drug or cell line name.
sub clean {
    my ($name) = @_;
    my $retVal = uc $name;
    $retVal =~ s/[^A-Z0-9]//g;
    return $retVal;
}


## Create the id-to-name mappings for drugs or cell lines.
sub ReadNames {
    my ($dir, $type, $inFile) = @_;
    # This will be the return hash.
    my %retVal;
    # Read in the names of interest.
    print "Reading $inFile for $type names.\n";
    open(my $ih, "<$inFile") || die "Could not open $inFile: $!";
    my %names;
    while (! eof $ih) {
        my $line = <$ih>;
        chomp $line;
        $stats->Add("$type-in" => 1);
        $names{$line} = 1;
    }
    close $ih;
    print scalar(keys %names) . " $type names specified.\n";
    my %found;
    # We need to process each data source.
    for my $source (@{TYPES()}) {
        # Open the data source's mapping file.
        my $fname = $source . "_$type";
        if (! -s "$dir/$fname") {
            print "No file found for $source $type.\n";
        } else {
            open(my $dh, "<$dir/$fname") || die "Could not open $fname: $!";
            # Skip the header.
            my $line = <$dh>;
            # Read the IDs.
            while (! eof $dh) {
                my ($id, undef, $name) = ScriptUtils::get_line($dh);
                if (! $name) {
                    print "Missing value for for $id in $fname.\n";
                } elsif ($names{$name}) {
                    $retVal{$id} = $name;
                    $stats->Add("$type-mapped" => 1);
                    $found{$name} = 1;
                } else {
                    $stats->Add("$type-skipped" => 1);
                }
            }
        }
    }
    print scalar(keys %retVal) . " identifiers found for " . scalar(keys %found) . " $type names.\n";
    # Return the hash table.
    return \%retVal;
}
