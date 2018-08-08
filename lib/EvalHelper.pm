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


package EvalHelper;

    use strict;
    use warnings;
    use EvalCon;
    use GenomeChecker;
    use P3DataAPI;
    use P3Utils;
    use BinningReports;
    use GEO;
    use File::Temp;

=head1 Genome Evaluation Helper

This package is designed to help in evaluating genomes. It is not as efficient as the command-line scripts because it
only evaluates a single genome at a time; however, it is useful in web environments where a single genome evaluation is
all that is needed. The main L</Process> method takes as input a GTO file name or a PATRIC genome ID and an optional
reference genome ID and produces an output web page.

=head2 Special Methods

=head3 Process

    my $html = EvalHelper::Process($genome, %options);

Create a web page describing the evaluation of a genome.

=over 4

=item genome

The ID of a PATRIC genome or the file name of a L<GenomeTypeObject> for the genome to evaluate.

=item options

A hash containing zero or more of the following options.

=over 8

=item ref

The PATRIC ID of a reference genome to use for comparison. If specified, the C<deep> option is implied.

=item deep

Compares the genome to a reference genome in order to provide more details on problematic roles. If this
option is specified, C<ref> is not specified, a reference genome will be computed.

=item checkDir

The name of the directory containing the reference genome table and the completeness data files. The default
is C<CheckG> in the SEEDtk global data directory.

=item predictors

The name of the directory containing the role definition files and the function predictors for the consistency
checking. The default is C<FunctionPredictors> in the SEEDtk global data directory.

=item p3

A L<P3DataAPI> object for accessing the PATRIC database. If omitted, one will be created internally.

=item template

The name of the template file. The default is C<RASTtk/lib/BinningReports/webdetails.tt> in the SEEDtk module directory.

=item outDir

The name of an optional output directory. If specified, the C<.out> and C<.html> files will be placed in here. This directory must
exist. It will not be cleared or created.

=back

=item RETURN

Returns an HTML string for a self-contained web page describing the quality results.

=back

=cut

sub Process {
    my ($genome, %options) = @_;
    # Connect to PATRIC.
    my $p3 = $options{p3} // P3DataAPI->new();
    # Create the work directory.
    my $tmpObject = File::Temp->newdir();
    my $workDir = $tmpObject->dirname;
    # Get the output directory (if needed).
    my $outDir = $options{outDir};
    # This holds the name to give eval-matrix for the output directory. If we are not keeping the output we use the work directory.
    my $outputDir = $outDir // $workDir;
    # Create the consistency helper.
    my $evalCon = EvalCon->new(predictors => $options{predictors});
    # Get access to the statistics object.
    my $stats = $evalCon->stats;
    # Create the completeness helper.
    my $checkDir = $options{checkDir} // "$FIG_Config::global/CheckG";
    my ($nMap, $cMap) = $evalCon->roleHashes;
    my $evalG = GenomeChecker->new($checkDir, roleHashes=> [$nMap, $cMap], stats => $stats);
    # Compute the detail level.
    my $detailLevel = (($options{deep} || $options{ref}) ? 2 : 1);
    # Set up the options for creating the GEOs.
    my %geoOptions = (roleHashes => [$nMap, $cMap], p3 => $p3, stats => $stats, detail => $detailLevel);
    # Start the predictor matrix for the consistency checker.
    $evalCon->OpenMatrix($workDir);
    # This will be the two GEOs and actual genome ID (which is different if we have a GTO).
    my ($mainGeo, $refGeo, $genomeID);
    # Find out what kind of genome we have. If we have a GTO, we load it here. We wait on the PATRIC
    # load in case we need a reference genome ID.
    my @genomes;
    my $patricIn = 0;
    if ($genome =~ /^\d+\.\d+$/) {
        $patricIn = 1;
        $genomeID = $genome;
        push @genomes, $genomeID;
    } else {
        my $gHash = GEO->CreateFromGtoFiles([$genome], %geoOptions);
        # A little fancy dancing is required because we don't know the genome ID, and it's the key to the hash we got
        # back. Thankfully, the hash is at most a singleton.
        ($genomeID) = keys %$gHash;
        if ($genomeID) {
            $mainGeo = $gHash->{$genomeID};
        } else {
            die "Could not load genome from $genome.";
        }
    }
    # Do we have a reference genome ID?
    my $refID = $options{ref};
    my %refMap;
    if (! $refID && $options{deep}) {
        # Here we must compute it, so we need to load the reference map.
        open(my $rh, "<$checkDir/ref.genomes.tbl") || die "Could not open reference genome table: $!";
        while (! eof $rh) {
            my $line = <$rh>;
            if ($line =~ /^(\d+)\t(\d+\.\d+)/) {
                $refMap{$1} = $2;
            }
        }
        # Get the lineage ID list from PATRIC.
        my $taxResults;
        if ($mainGeo) {
            $taxResults = P3Utils::get_data_keyed($p3, taxonomy => [], ['lineage_ids'], [$mainGeo->taxon]);
        } else {
            $taxResults = P3Utils::get_data_keyed($p3, genome => [], ['taxon_lineage_ids'], [$genome]);
        }
        $refID = _FindRef($taxResults, \%refMap, $genomeID);
        if ($refID) {
            push @genomes, $refID;
        }
    }
    # Do we have PATRIC genomes to read?
    if (@genomes) {
        my $gHash = GEO->CreateFromPatric(\@genomes, %geoOptions);
        if (! $mainGeo) {
            $mainGeo = $gHash->{$genome};
        }
        if ($refID) {
            $refGeo = $gHash->{$refID};
        }
    }
    # Now we have the two GEOs. Attach the ref to the main.
    if (! $mainGeo) {
        die "Could not read $genome from PATRIC.";
    } elsif ($refGeo) {
        $mainGeo->AddRefGenome($refGeo);
    }
    # Open the output file for the quality data.
    my $outFile = "$workDir/$genomeID.out";
    open(my $oh, '>', $outFile) || die "Could not open work file: $!";
    # Output the completeness data.
    $evalG->Check2($mainGeo, $oh);
    close $oh;
    # Create the eval matrix for the consistency checker.
    $evalCon->OpenMatrix($workDir);
    $evalCon->AddGeoToMatrix($mainGeo);
    $evalCon->CloseMatrix();
    # Evaluate the consistency.
    my $rc = system('eval_matrix', '-q', $evalCon->predictors, $workDir, $outputDir);
    if ($rc) {
        die "EvalCon returned error code $rc.";
    }
    # Store the quality metrics in the GTO.
    $mainGeo->AddQuality("$outputDir/$genomeID.out");
    # Create the detail page.
    my $detailFile = $options{template} // "$FIG_Config::mod_base/RASTtk/lib/BinningReports/webdetails.tt";
    my $retVal = BinningReports::Detail(undef, undef, $detailFile, $mainGeo, $nMap);
    # If we are keeping output files, store the page here.
    if ($outDir) {
        open(my $oh, ">$outDir/$genomeID.html") || die "Could not open HTML output file: $!";
        print $oh $retVal;
    }
    # Return the result.
    return $retVal;
}

=head2 Internal Utilities

=head3 _FindRef

    my $refID = EvalHelper::_FindRef($taxResults, $refMap, $genome);

Compute the reference genome ID from the results of a taxonomy lineage ID search.

=over 4

=item taxResults

The results of a query for the taxonomic lineage IDs of the current genome.

=item refMap

A reference to a hash mapping taxonomic IDs to reference genomes.

=item genome

The ID of the genome whose reference is desired.

=item RETURN

Returns the ID of the reference genome, or C<undef> if none could be found or the genome is its own reference.

=back

=cut

sub _FindRef {
    my ($taxResults, $refMap, $genome) = @_;
    # This will be the return value.
    my $retVal;
    # Insure we have a result.
    if ($taxResults && @$taxResults) {
        my $lineage = $taxResults->[0][0];
        # Loop through the lineage until we find something. Note that sometimes the lineage ID list comes back
        # as an empty string instead of a list so we need an extra IF.
        my $refFound;
        if ($lineage) {
            while (! $refFound && (my $tax = pop @$lineage)) {
                $refFound = $refMap->{$tax};
            }
        }
        # If we found something and it's not the genome of interest, run with it.
        if ($refFound && $refFound ne $genome) {
            $retVal = $refFound;
        }
    }
    return $retVal;
}


1;