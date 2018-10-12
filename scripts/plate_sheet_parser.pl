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
use Spreadsheet::ParseExcel;
use File::Copy::Recursive;
use IC50;
use Excel::Writer::XLSX;


=head1 Parse Dose Response Spreadsheets

    plate_sheet_parser.pl [ options ] sheetDir outDir

This script extracts growth data from single-drug dose-response spreadsheets.  Each input spreadsheet represents a
particular cell line (named in [Raw data]!B2).  The cell population data is stored in cells E17 to AA32 of the [Raw data]
page. The first column is not used. Each subsequent pair of columns represents a dose/drug pair. The last column contains
the initial population. In each pair of columns, there are 22 drugs applied to the 22 cells in the column pair, at the
appropriate dosages (first dose for the first column pair, second dose for the second column pair, and so forth). The
C<drugs.tbl> file in the input directory contains the list of drugs in their appropriate positions. The C<doses.tbl>
file lists the dosages for each drug in column order.

An output flat file-- C<all.responses.tbl>-- will be produced that contains four columns-- (0) drug name, (1) cell line name,
(2) concentration, (3) growth.  The growth is expressed as a percent of the growth without drugs, so a negative
number indicates the drug shrinks the sample, and a number greater than 100 indicates it is harmful.

A second flat file-- C<ic50.tbl>-- will be produced that contains eight columns-- (0) drug name, (1) cell line name, (2) absolute
IC50, (3) relative IC50, (4) log absolute IC50, (5) log relative IC50, (6) Rick prediction, (7) FangFang prediction.  For each
drug, a spreadsheet containing the last seven columns of this table will be produced as well.

All output drug and cell line names will be cleaned.

=head2 Parameters

The positional parameters are the name of the input directory containing C<doses.tbl>, C<predictions.tbl>, and C<drugs.tbl> as
well as the spreadsheets, and the name of the output directory.

The command-line options are as follows.

=over 4

=item clear

Erase the output directory before starting.

=back

=cut

use constant LOG10 => log(10.0);

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('sheetDir outDir',
        ['clear', 'erase the output directory before starting']
        );
# Check the parameters.
my ($sheetDir, $outDir) = @ARGV;
if (! $sheetDir) {
    die "No input directory specified.";
} elsif (! -d $sheetDir) {
    die "Input directory $sheetDir missing or invalid.";
} elsif (! $outDir) {
    die "No output directory specified.";
} elsif (! -d $outDir) {
    print "Creating output directory $outDir.\n";
    File::Copy::Recursive::pathmk($outDir) || die "Could not create $outDir: $!";
} elsif ($opt->clear) {
    print "Erasing output directory $outDir.\n";
    File::Copy::Recursive::pathempty($outDir) || die "Could not erase $outDir: $!";
}
# Connect to Excel.
my $parser = Spreadsheet::ParseExcel->new();
# We need to read in the doses and drugs. The following two-dimensional arrays ([row][col]) will contain the drug and dose level for each of
# the cells in the raw data region of the input spreadsheet.
my @drugs;
my @doses;
# We read in the drugs first.
print "Reading drug file.\n";
open(my $ih, '<', "$sheetDir/drugs.tbl") || die "Could not open drugs.tbl: $!";
while (! eof $ih) {
    my ($drug1, $drug2) = map { IC50::clean($_) } ScriptUtils::get_line($ih);
    push @drugs, [($drug1, $drug2) x 10];
}
close $ih; undef $ih;
# Now we compute the doses. This will be the current row index. An undefined dose means there is no useful result in that column.
# The doses are in absolute units, so we convert to log10 to match everybody else.
open($ih, '<', "$sheetDir/doses.tbl") || die "Could not open doses.tbl: $!";
my %doseH;
print "Reading dose file.\n";
while (! eof $ih) {
    my ($rowDrug, @rowDoses) = ScriptUtils::get_line($ih);
    $rowDrug = IC50::clean($rowDrug);
    @rowDoses = map { log($_) / LOG10 } @rowDoses;
    my @doseList = map { $_, $_ } @rowDoses;
    $doseH{$rowDrug} = \@doseList;
}
print "Creating dosage array.\n";
for (my $r = 0; $r < @drugs; $r++) {
    for (my $c = 0; $c < 20; $c++) {
        my $drug = $drugs[$r][$c];
        my $dose;
        if ($doseH{$drug}) {
            $dose = $doseH{$drug}[$c];
        }
        $doses[$r][$c] = $dose;
    }
}
# Clean up memory.
undef %doseH;
close $ih; undef $ih;
# Now we have a perfect map of the raw data. We need to loop through the spreadsheets.
opendir($ih, $sheetDir) || die "Could not open $sheetDir: $!";
my @sheets = grep { $_ =~ /\.xls$/ && -s "$sheetDir/$_" } readdir $ih;
closedir $ih; undef $ih;
print scalar(@sheets) . " spreadsheets found.\n";
# This hash will contain the IC50s, keyed by drug and then cell line, in the form [abs, rel].
my %ic50;
# Open the main output file.
open(my $oh, '>', "$outDir/all.responses.tbl") || die "Could not open output file: $!";
print $oh join("\t", qw(drug cell_line log_dosage growth)) . "\n";
# Now loop through the sheets.
for my $sheet (@sheets) {
    my $workbook = $parser->parse("$sheetDir/$sheet");
    if (! $workbook) {
        die "Error in $sheet: " . $parser->error();
    } else {
        # Get the cell line.
        my $rawData = $workbook->worksheet('Raw data');
        if (! $rawData) {
            print "Invalid spreadsheet $sheet -- skipping.\n";
        } else {
            my $cell_line = IC50::clean(cell_value($rawData, 1, 1));
            print "Processing $sheet for $cell_line.\n";
            # Extract the default growth and the starting growth for each drug.
            my (%baseline, %growth);
            for (my $r = 0; $r < @drugs; $r++) {
                for (my $c = 0; $c < 2; $c++) {
                    my $drug = $drugs[$r][$c];
                    $baseline{$drug} = cell_value($rawData, $r + 17, 26);
                    $growth{$drug} = cell_value($rawData, $r + 17, $c + 24) - $baseline{$drug};
                }
            }
            # Write the growth for each dosage.
            for (my $r = 0; $r < @drugs; $r++) {
                for (my $c = 0; $c < 20; $c++) {
                    my $drug = $drugs[$r][$c];
                    my $dose = $doses[$r][$c];
                    if (defined $dose) {
                        my $response = (cell_value($rawData, $r + 17, $c + 4) - $baseline{$drug}) * 100;
                        if ($response < 0) {
                            $response /= $baseline{$drug};
                        } else {
                            $response /= $growth{$drug};
                        }
                        print $oh join("\t", $drug, $cell_line, $dose, $response) . "\n";
                    }
                }
            }
            # Get the IC50 sheet. The drug names are in A9 through A34, the absolute IC50s in E9
            # through E34, and the relative IC50s in F9 through F34. The cell line name must be
            # stripped from the end of the drug name.
            my $ic50sheet = $workbook->worksheet('IC50 Summary');
            if (! $ic50sheet) {
                die "IC50 summary not found for $sheet.";
            } else {
                for (my $r = 8; $r < 34; $r++) {
                    my $drug = cell_value($ic50sheet, $r, 0);
                    $drug =~ s/[^_]+$//;
                    $drug = IC50::clean($drug);
                    # Get the two IC50s.
                    my ($abs, $rel) = (cell_value($ic50sheet, $r, 4), cell_value($ic50sheet, $r, 5));
                    $abs =~ s/<|>//;
                    $ic50{$drug}{$cell_line} = [$abs, $rel];
                }
            }
        }
    }
}
close $oh; undef $oh;
# For this next part we need the predictions. This table maps {drug}{cell_line} to [Rick, FangFang].
my %pred;
open($ih, '<', "$sheetDir/predictions.tbl") || die "Could not open predictions file: $!";
# Discard the header line.
my $line = <$ih>;
print "Reading predictions file.\n";
while (! eof $ih) {
    my ($drug, $cl, $rick, $ff) = ScriptUtils::get_line($ih);
    $pred{$drug}{$cl} = [$rick, $ff];
}
close $ih; undef $ih;
# Now write out the IC50s. Each drug's data goes in a spreadsheet and in the master flat file.
open($oh, '>', "$outDir/ic50.tbl") || die "Could not open IC50 output file: $!";
print $oh join("\t", qw(drug cell_line abs_ic50 rel_ic50 abs_log_ic50 rel_log_ic50 Rick FangFang)) . "\n";
for my $drug (sort keys %ic50) {
    # Get the hashes for this drug.
    my $lineH = $ic50{$drug};
    my $predH = $pred{$drug} // {};
    # Create the output spreadsheet.
    my $outbook = Excel::Writer::XLSX->new("$outDir/ic50_$drug.xlsx");
    if (! $outbook) {
        die "Could not create workbook for $drug.";
    }
    print "Creating IC50s for $drug.\n";
    my $ic50Sheet = $outbook->add_worksheet("IC50");
    $ic50Sheet->write_string(0, 0, "Cell line");
    $ic50Sheet->write_string(0, 1, "AbsIC50");
    $ic50Sheet->write_string(0, 2, "RelIC50");
    $ic50Sheet->write_string(0, 3, "Log AbsIC50");
    $ic50Sheet->write_string(0, 4, "Log RelIC50");
    $ic50Sheet->write_string(0, 5, "Rick");
    $ic50Sheet->write_string(0, 6, "FangFang");
    my $r = 1;
    # This array is used to compute the correlation.
    my @x;
    # We need to sort the cell lines by rel IC50.
    my @clist = sort { $lineH->{$a}[1] <=> $lineH->{$b}[1] } keys %$lineH;
    # Loop through the cell lines.
    for my $cell_line (@clist) {
        my ($abs, $rel) = @{$lineH->{$cell_line}};
        my ($absL, $relL) = map { logD($_) } ($abs, $rel);
        my $predL = $predH->{$cell_line} // ['', ''];
        if ($predL->[1] ne '') {
            push @x, [$rel, $predL->[1]];
        }
        print $oh join("\t", $drug, $cell_line, $abs, $rel, $absL // '', $relL // '', $predL->[0], $predL->[1]) . "\n";
        $ic50Sheet->write_string($r, 0, $cell_line);
        writeNum($ic50Sheet, $r, 1, $abs);
        writeNum($ic50Sheet, $r, 2, $rel);
        writeNum($ic50Sheet, $r, 3, $absL);
        writeNum($ic50Sheet, $r, 4, $relL);
        writeNum($ic50Sheet, $r, 5, $predL->[0]);
        writeNum($ic50Sheet, $r, 6, $predL->[1]);
        $r++;
    }
    # Compute the correlation.
    my $cf = correlation(\@x);
    # Create the line graph.
    my $chart = $outbook->add_chart( type => 'line', embedded => 1);
    my %options = (categories => ['IC50', 1, $r-1, 0, 0]);
    $chart->set_size(width => 1024, height => 640);
    $chart->set_title(name => 'Predictions Ordered by Relative IC50');
    $chart->set_legend(position => 'top');
    $chart->add_series( values => ['IC50', 1, $r-1, 5, 5], name => 'Rick', %options);
    $chart->add_series( values => ['IC50', 1, $r-1, 6, 6], name => 'FangFang', %options);
    $ic50Sheet->insert_chart(1, 8, $chart);
    # Create the scatter graph.
    $chart = $outbook->add_chart( type => 'scatter', name => 'Scatter Plot' );
    $chart->set_legend(position => 'top');
    $chart->add_series( values => ['IC50', 1, $r-1, 5, 5], name => 'Rick',
                        categories => ['IC50', 1, $r-1, 2, 2]);
    $chart->add_series( values => ['IC50', 1, $r-1, 6, 6], name => 'FangFang',
                        categories => ['IC50', 1, $r-1, 2, 2]);
    $chart->set_title(name => "FangFang Correlation Coefficient = $cf");
    # Close the spreadsheet.
    $outbook->close();
}
close $oh;
print "All done.\n";

## Get the cell value at the specified row and column.
sub cell_value {
    my ($worksheet, $r, $c) = @_;
    my $retVal;
    my $cell = $worksheet->get_cell($r, $c);
    if ($cell) {
        $retVal = $cell->unformatted();
    }
    return $retVal;
}

## Compute the log of a dosage. If the dosage is 0, return undef.
sub logD {
    my ($value) = @_;
    my $retVal;
    if ($value > 0) {
        $retVal = log($value) / LOG10;
    }
    return $retVal;
}

## Write a number or empty string to the spreadsheet.
sub writeNum {
    my ($sheet, $r, $c, $val) = @_;
    if (! defined $val || $val eq '') {
        $sheet->write_string($r, $c, '');
    } else {
        $sheet->write_number($r, $c, $val);
    }
}

## Correlation coefficient stuff.
sub mean {
   my ($x)=@_;
   my $num = scalar(@{$x}) - 1;
   my $sum_x = '0';
   my $sum_y = '0';
   for (my $i = 1; $i < scalar(@{$x}); ++$i){
      $sum_x += $x->[$i][0];
      $sum_y += $x->[$i][1];
   }
   my $mu_x = $sum_x / $num;
   my $mu_y = $sum_y / $num;
   return($mu_x,$mu_y);
}

### ss = sum of squared deviations to the mean
sub ss {
   my ($x,$mean_x,$mean_y,$one,$two)=@_;
   my $sum = '0';
   for (my $i=1;$i<scalar(@{$x});++$i){
     $sum += ($x->[$i][$one]-$mean_x)*($x->[$i][$two]-$mean_y);
   }
   return $sum;
}

sub correlation {
   my ($x) = @_;
   my ($mean_x,$mean_y) = mean($x);
   my $ssxx=ss($x,$mean_x,$mean_y,0,0);
   my $ssyy=ss($x,$mean_x,$mean_y,1,1);
   my $ssxy=ss($x,$mean_x,$mean_y,0,1);
   my $correl=correl($ssxx,$ssyy,$ssxy);
   return($correl);

}

sub correl {
   my($ssxx,$ssyy,$ssxy)=@_;
   my $correl = 'invalid';
   if ($ssxx && $ssyy) {
       my $sign=$ssxy/abs($ssxy);
       $correl=$sign*sqrt($ssxy*$ssxy/($ssxx*$ssyy));
       $correl=sprintf("%.4f",$correl);
   }
   return $correl;
}
