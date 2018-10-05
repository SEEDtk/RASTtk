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
use IC50;
my $mode;
eval {
    require Excel::Writer::XLSX;
    $mode = 'x';
    print "Excel::Writer loaded.\n";
};
if ($@) {
    require Spreadsheet::WriteExcel;
    $mode = '';
    print "WriteExcel loaded.\n";
}

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

The name of the output spreadsheet. If the file exists, it will be destroyed. The default is C<growth.xls> in the
input directory.

=item prob

The name of the probability file. This file is tab-delimited, with two header rows. Each data row starts with a CCLE
cell line ID. For each drug, there are three columns of data, headed by a drug ID. The first such column
(with a sub-head of C<Prob>) contains the probability rating of the drug / cell-line combination. This value will be
put on the IC50 page in a column headed by a source type followed by C<-R>.

=item predictions

The name of the predictions file. This file is tab-delimited, with one header row. Each data row starts with a CCLE
cell line ID. For each drug, there is a column containing a prediction of growth modification for the drug / cell line
combination. This value will be put on the IC50 page in a column headed by a source type followed by C<-P>.

=item ic50only

If specified, the individual pages will not be produced, only the IC50 page. Use this when there are a lot of drug/line
combinations.

=back

=cut

# list of report types
use constant TYPES => [qw(CCLE CTRP GDSC SCLC NCI60 gCSI)];
use constant TYPEH => { CCLE => 1, CTRP => 2, GDSC => 3, SCLC => 4, NCI60 => 5, ALMANAC => 6, gCSI => 7, NCI60M => 8, ALMANACM => 9 };
use constant IC50H => { GDSC => 12, NCI60 => 13 };
use constant IC50L => 10;

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('pDir drugFile lineFile',
        ['workbook|wb|w=s', 'output file name'],
        ['predictions|p=s', 'prediction file'],
        ['prob|P=s', 'probability file'],
        ['ic50only', 'only create IC50 sheet']
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
# Save the options.
my $allSheets = ! $opt->ic50only;
# Compute the output file name and create the spreadsheet writer.
my $output = $opt->workbook // "$pDir/growth.xls$mode";
if (-f $output) {
    print "Deleting old $output.\n";
    unlink $output;
}
my $workbook;
print "Creating $output.\n";
if ($mode) {
    $workbook = Excel::Writer::XLSX->new($output);
} else {
    $workbook = Spreadsheet::WriteExcel->new($output);
}
if (! $workbook) {
    die "Could not create workbook.";
}
print "Spreadsheet created as $output.\n";
# Read in the cell line and drug IDs of interest.
my $clHash = ReadNames("$pDir/cell_lines", cl => $lineFile);
my $drugHash = ReadNames("$pDir/drugs", drugs => $drugFile);
# We are now going to set up the prediction/probability numbers. This tracks the next available
# column on the IC50 page.
my $sCol = IC50L + 1;
# This is a three-level hash. It contains the predicted probability of success for each drug/cl pair
# for each version of the drug. The third key is the source (taken from the column header drug ID).
my %probMap;
# This hash contains the sources found, mapping each one to a column number.
my %probType;
if ($opt->prob) {
    open(my $ph, '<', $opt->prob) || die "Could not open probability file: $!";
    # Read the headers. This hash will map each drug ID to a column number.
    my %drugCols;
    my @cols = ScriptUtils::get_line($ph);
    my @data = ScriptUtils::get_line($ph);
    for (my $i = 0; $i < @cols; $i++) {
        if ($drugHash->{$cols[$i]} && $data[$i] eq 'Prob') {
            $drugCols{$cols[$i]} = $i;
            $stats->Add(probCol => 1);
        }
    }
    print scalar(keys %drugCols) . " drug columns found in probability file.\n";
    # Now loop through the cell lines, saving the scores.
    my $count = 0;
    while (! eof $ph) {
        @data = ScriptUtils::get_line($ph);
        my $line = $clHash->{$data[0]};
        if ($line) {
            for my $drug (keys %drugCols) {
                my $dname = $drugHash->{$drug};
                my ($source) = split /\./, $drug;
                $probMap{$dname}{$line}{$source} = $data[$drugCols{$drug}];
                $count++;
                $probType{$source} = 1;
            }
            $stats->Add(probLine => 1);
        }
    }
    print "$count probability values stored.\n";
    # Set up the sources.
    for my $source (sort keys %probType) {
        $probType{$source} = $sCol;
        $sCol++;
        $stats->Add(probType => 1);
    }
}
# This is another three-level hash. It contains the predicted growth reduction for each drug/cl pair
# for each version of the drug. The third key is the source (taken from the column header drug ID).
my %predMap;
# This hash contains the sources found, mapping each one to a column number.
my %predType;
if ($opt->predictions) {
    open(my $ph, '<', $opt->predictions) || die "Could not open predictions file: $!";
    # Read the headers. This hash will map each drug ID to a column number.
    my %drugCols;
    my @cols = ScriptUtils::get_line($ph);
    for (my $i = 0; $i < @cols; $i++) {
        if ($drugHash->{$cols[$i]}) {
            $drugCols{$cols[$i]} = $i;
            $stats->Add(predCol => 1);
        }
    }
    print scalar(keys %drugCols) . " drug columns found in predictions file.\n";
    # Now loop through the cell lines, saving the scores.
    my $count = 0;
    while (! eof $ph) {
        my @data = ScriptUtils::get_line($ph);
        my $line = $clHash->{$data[0]};
        if ($line) {
            for my $drug (keys %drugCols) {
                my $dname = $drugHash->{$drug};
                my ($source) = split /\./, $drug;
                $predMap{$dname}{$line}{$source} = $data[$drugCols{$drug}];
                $count++;
                $predType{$source} = 1;
            }
            $stats->Add(predLine => 1);
        }
    }
    print "$count prediction values stored.\n";
    # Set up the sources.
    for my $source (sort keys %predType) {
        $predType{$source} = $sCol;
        $sCol++;
        $stats->Add(predType => 1);
    }
}
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
for my $type (keys %probType) {
    $ic50Sheet->write_string(0, $probType{$type}, "$type-R");
}
for my $type (keys %predType) {
    $ic50Sheet->write_string(0, $predType{$type}, "$type-P");
}
my $ic50Row = 0;
# Now process the drug / cell-line pairs.
for my $drug (sort keys %growthMap) {
    print "Processing drug $drug.\n";
    my $clMap = $growthMap{$drug};
    my $ic50Map = $ic50{$drug} // {};
    for my $cl (sort keys %$clMap) {
        my $ic50H = $ic50Map->{$cl} // {};
        print "Processing pair $drug $cl.\n";
        $stats->Add(pairFound => 1);
        # Here we need to open a sheet for this drug/CL pair.
        my $sheet;
        if ($allSheets) {
            $sheet = $workbook->add_worksheet(substr("$drug $cl", 0, 31));
            $sheet->write_string(2, 0, "Dosage");
            for my $type (keys %{TYPEH()}) {
                $sheet->write_string(2, TYPEH->{$type}, $type);
            }
            # The first row contains the offsets.
            $sheet->write_string(0, 0, "Offset");
            # The second row contains the computed IC50s.
            $sheet->write_string(1, 0, "IC50");
            # Past the end, the first two rows contain IC50 numbers from the web.
            $sheet->write_string(1, IC50L, "IC50");
            for my $type (keys %{IC50H()}) {
                $sheet->write_string(0, IC50H->{$type}, $type);
                my $value = $ic50H->{$type};
                if (defined $value) {
                    $sheet->write_number(1, IC50H->{$type}, $value);
                }
            }
        }
        # Do the IC50 sheet stuff.
        $ic50Row++;
        $ic50Sheet->write_string($ic50Row, 0, $drug);
        $ic50Sheet->write_string($ic50Row, 1, $cl);
        # Get the map of source types to tuple lists. We must sort the lists and compute the offsets
        # To get each one starting at 100.
        print "Computing offsets and sorting dosages.\n";
        my $pairMap = $clMap->{$cl};
        my @types = keys %$pairMap;
        for my $type (@types) {
            my $tuples = $pairMap->{$type};
            my @sorted = sort { $a->[0] <=> $b->[0] } @$tuples;
            my $offset = 100 - $sorted[0][1];
            if ($allSheets) {
                $sheet->write_number(0, TYPEH->{$type}, $offset);
            }
            for my $tuple (@sorted) {
                $tuple->[1] += $offset;
            }
            $pairMap->{$type} = \@sorted;
        }
        # Now compute and store the IC50s.
        for my $type (@types) {
            my $pairs = $pairMap->{$type};
            my $ic50 = $ic50Thing->computeFromPairs($pairs);
            if (defined $ic50) {
                if ($allSheets) {
                    $sheet->write_number(1, TYPEH->{$type}, $ic50);
                }
                $ic50Sheet->write_number($ic50Row, TYPEH->{$type} + 1, $ic50);
                $stats->Add(ic50Computed => 1);
            } else {
                $ic50Sheet->write_formula($ic50Row, TYPEH->{$type} + 1, "=NA()");
            }
        }
        # Process the probabilities and predictions (if any).
        for my $type (keys %probType) {
            my $prob = $probMap{$drug}{$cl}{$type};
            if (defined $prob) {
                $ic50Sheet->write_number($ic50Row, $probType{$type}, $prob);
            }
        }
        for my $type (keys %predType) {
            my $pred = $predMap{$drug}{$cl}{$type};
            if (defined $pred) {
                $ic50Sheet->write_number($ic50Row, $predType{$type}, $pred);
            }
        }
        if ($allSheets) {
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
}
print "Updating spreadsheet.\n";
$workbook->close();
print "All done.\n" . $stats->Show();

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
    for my $name (keys %names) {
        if (! $found{$name}) {
            print "No identifier found for $type $name.\n";
        }
    }
    print scalar(keys %retVal) . " identifiers found for " . scalar(keys %found) . " $type names.\n";
    # Return the hash table.
    return \%retVal;
}
