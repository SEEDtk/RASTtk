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


package BinningReports;

    use strict;
    use warnings;
    use URI::Escape;
    use File::Basename;
    use Template;
    use Data::Dumper;
    use RoleParse;
    use SeedUtils;
    use GEO;
    use Math::Round;

=head1 Produce Binning Reports

This package produces binning reports from the output JSON objects. The methods can be tested in a batch environment and then plugged into
the real PATRIC environment.

=head2 Data Structures

The following data structures are input to these methods.

=head3 params

This should be a hash reference with the following keys. All are optional; however, at least
one of C<contigs> and C<paired_end_libs> must be present.

=over 4

=item contigs

Name of the contigs input file.

=item paired_end_libs

Reference to a list containing the two paired-end read input files.

=item genome_group

Name of the genome group into which output genomes are to be placed.

=back

=head3 bins_json

Reference to a list of hash references, one per bin, with the following keys.

=over 4

=item binFastaFile

The name of the file containing the contigs for the bin.

=item binFastaPath

The directory path of the file containing the contigs for the bin.

=item binIndex

The index number of the bin (1-based).

=item contigs

Reference to a list of the IDs of the contigs in the bin.

=item coverage

The mean coverage for the bin.

=item domain

The domain of the bin's genome.

=item geneticCode

The majority genetic code used for the bin.

=item len

The number of DNA base pairs in the bin.

=item name

The name assigned to the bin's genome.

=item refGenomes

A reference to a list of the IDs for the bin's reference genomes.

=item taxonID

The estimated taxonomic ID for the bin.

=item uniProts

Reference to an empty hash.

=back

=cut

# URL helpers
use constant URL_BASE => 'https://www.patricbrc.org/view/Genome';

=head2 Public Methods

=head3 Summary

    my $summary = BinningReports::Summary($jobID, $params, $bins_json, $summary_tt, $genome_group_path, \@geos, \%report_url_map);

Produce the summary report.

=over 4

=item jobID

The PATRIC job identifier for the binning run. If this is C<undef>, then the report is assumed to be a genome report, not a binning report.
The language is changed somewhat and there is no coverage column.

=item params

The L</params> structure used to invoke the binning.

=item bins_json

The L</bins_json> structure produced by the binning. If undefined, then it will be assumed this is not a binning job. If a hash reference
is specified, it is presumed to be the output of L</parse_bins_json>.

=item summary_tt

The template to be used for the summary report. This template expects the following variables.

=over 8

=item job_id

The PATRIC job identifier, or C<undef> if no PATRIC job was involved.

=item min_checkm

The minimum CheckM completeness score required for a good bin.

=item min_scikit

The minimum SciKit completeness score required for a good bin.

=item max_contam

The maximum CheckM contamination score allowed for a good bin.

=item params

The I<params> structure described above.

=item found

Reference to a hash with the following keys.

=over 12

=item total

Total number of bins.

=item good

Number of good bins.

=item bad

Number of bad bins.

=back

=item good

Reference to a list of bin descriptors for good bins. Each descriptor contains the following members.

=over 12

=item genome_id

The ID of the bin's genome.

=item genome_url

The URL of the PATRIC page for the bin's genome.

=item genome_name

The name of the bin.

=item scikit_coarse

The coarse consistency score.

=item scikit_fine

The fine consistency score.

=item scikit_color

A style tag for the background color of the fine consistency score, or a null string.

=item checkg_completeness

The EvalG completeness score.

=item completeness_color

A style tag for the background color of the checkm completeness score, or a null string.

=item checkg_contamination

The EvalG contamination score.

=item contamination_color

A style tag for the background color of the checkm contamination score, or a null string.

=item contigs

The number of contigs in the bin.

=item dna_bp

The total number of DNA base pairs in the bin.

=item n50

The N50 statistical measure of contig lengths.

=item l50

The L50 statistical measure of the number of contigs.

=item ppr

A count of the problematic roles.

=item refs

A list of reference genome descriptors, each a hash reference containing the genome name in C<genome> and the URL in C<url>.

=item coverage

The mean coverage for the bin.

=item report_url

URL for the bin's report page.

=item good_seed

C<Y> if the bin has a good PheS protein, else a hard space.

=item seed_color

A style tag for the good-seed cell, or a null string.

=item qscore

The quality score for the bin.

=item tot_funs

The total number of protein-encoding genes in the bin's genome with functional assignments.

=item tot_hypos

The total number of protein-encoding genes in the bin's genome without functional assignments.

=item tot_roles

The total number of distinct roles in the bin's genome.

=item cds_pct

The percent of features that are protein-encoding genes.

=item hypo_pct

The percent of features that are hypothetical proteins.

=item plfam_pct

The percent of features that are in local protein families.

=back

=item bad

Reference to a list of bin descriptors for bad bins. The descriptors are identical in format to the ones for the good bins.

=back

=item genome_group_path

The path to the output genome group (if any).

=item geos

A reference to a list of L<GEO> objects for the bins produced.

=item report_url_map

A reference to a hash mapping each bin's genome ID to the URL for its report page.

=item RETURN

Returns the HTML string for the summary report.

=back

=cut

use constant WARN_COLOR => q(style="background-color: gold");

sub Summary {
    my ($jobID, $params, $bins_json, $summary_tt, $genome_group_path, $geos, $report_url_map) = @_;
    # Here are the storage places for found, good, and bad. The bin's descriptor goes in the
    # lists.
    my %found = (total => 0, good => 0, bad => 0);
    my (@good, @bad);
    # First we are going to read through the bins and create a map of bin names to reference genome descriptors and coverages.
    # Each reference genome descriptor is a hash-ref with members "genome" and "url".
    my ($refGmap) = parse_bins_json($bins_json);
    # Now we loop through the gtos and create the genome descriptors for the good and bad lists.
    my @bins = sort { $b->qscore <=> $a->qscore } @$geos;
    for my $bin (@bins) {
        # Copy the quality entry. This copy will be made into the main object used to describe bins in the output reports.
        my ($gThing, $good) = copy_geo($bin);
        # Compute the q-score.
        $gThing->{qscore} = int($bin->qscore * 10);
        # Get the matching ppr and refGmap entries.
        my $genomeID = $bin->id;
        $gThing->{report_url} = $report_url_map->{$bin->id};
        my $genomeName = $bin->name;
        my $genomeKey = $genomeName;
        if ($genomeName =~ /^(.+\sclonal population)/) {
            $genomeKey = $1;
        }
        my $genomeURL = join('/', URL_BASE, uri_escape($genomeID));
        my $pprRoleData = $bin->roleReport;
        my $refData = $refGmap->{$genomeKey};
        if (! $refData) {
            # No reference data. We have to build it from the GEO.
            $refData = BuildRefData($bin);
        }
        # Connect the coverage and reference genome data.
        $gThing->{refs} = $refData->{refs};
        $gThing->{coverage} = $refData->{coverage};
        $gThing->{genome_url} = $genomeURL;
        # Compute the ppr count.
        my $pprs = 0;
        for my $role (keys %$pprRoleData) {
            my $pa = $pprRoleData->{$role} // [0,0];
            my ($predicted, $actual) = @$pa;
            if ($predicted != $actual) {
                $pprs++;
            }
        }
        # Store the PPR count in the main descriptor.
        $gThing->{ppr} = $pprs;
        # Now we know.
        if ($good) {
            push @good, $gThing;
            $found{good}++;
        } else {
            push @bad, $gThing;
            $found{bad}++;
        }
        # Update the total-bin count.
        $found{total}++;
    }
    # We have now compiled the information we need for the report. Create the template engine.
    my $templateEngine = Template->new(ABSOLUTE => 1);
    # Allocate the result variable.
    my $retVal;
    # Create the summary report parm structure.
    my $vars = { job_id => $jobID, params => $params, found => \%found, good => \@good, bad => \@bad, group_path => $genome_group_path,
                 min_checkm => GEO::MIN_CHECKM, min_scikit => GEO::MIN_SCIKIT, max_contam => GEO::MAX_CONTAM };
    # print STDERR Dumper($vars);
    # Create the summary report.
    $templateEngine->process($summary_tt, $vars, \$retVal);
    # Return the report.
    return $retVal;
}

=head3 Detail

    my $detail = BinningReports::Detail($params, $bins_json, $detail_tt, $geo, $roleMap, $editHash);

Produce the detail report for a single bin.

=over 4

=item params

The L</params> structure used to invoke the binning. This is for future use only, and currently may be an empty hash.

=item bins_json (optional)

The L</bins_json> structure produced by the binning. If this is omitted, then coverage and reference-genome data will
be left off the output page. In addition, the output of L</parse_bins_json> can be passed in, instead.

=item details_tt

The template to be used for each bin's detail report. This template expects the following variables.

=over 8

=item g

A bin descriptor for the bin, as described in the list of good-bin descriptors above.

=item p

A problematic-role descriptor for the bin, consisting of a list of structures, one per role. Each structure contains the following fields.

=over 12

=item role

The role description.

=item predicted

The number of roles predicted.

=item actual

The actual number of roles found.

=item n_fids

The number of features containing the problematic role.

=item fid_url

The URL to list the features.

=item comment

An optional comment about the role.

=back

=item c

A contig descriptor for the bin, consisting of a list of structures, one per problematic contig. Each structure contains the following fields.

=over 12

=item name

The contig name.

=item len

The contig length, in base pairs.

=item n_fids

The number of features containing problematic roles.

=item list_url

A hyperlink to list a contig's features.

=item fid_url

The URL to list the features.

=item fid_list

A comma-delimited list of the feature IDs.

=item good

The number of good features in the contig.

=back

=item editform

If TRUE, a form for editing contigs will be put into the page.

=item gtoFile

The name of the GTO file to be modified by the edit form.

=back

=item geo

The L<GEO> for the bin.

=item roleMap

Reference to a hash mapping each role ID to a role name.

=item editHash

If specified, a reference to a hash describing the editing environment for removing contigs from the GTO. The keys are

=over 8

=item gto

The name of the GTO file.

=item editScript

The URL of the edit script.

=back

=item RETURN

Returns the HTML string for the detail report.

=back

=cut

sub Detail {
    my ($params, $bins_json, $detail_tt, $geo, $roleMap, $editHash) = @_;
    # First we are going to read through the bins and create a map of bin names to reference genome descriptors and coverages.
    # Each reference genome descriptor is a hash-ref with members "genome" and "url".
    my $refGmap = parse_bins_json($bins_json);
    # Now we need to build the bin descriptor from the GTO.
    my ($gThing) = copy_geo($geo);
    # Get the matching ppr and refGmap entries. Note there may not be a refGmap entry if there was no bins_json.
    my $genomeID = $geo->id;
    my $genomeName = $geo->name;
    my $genomeURL = join('/', URL_BASE, uri_escape($genomeID));
    my $pprRoleData = $geo->roleReport;
    # Get the reference data.
    my $refData = $refGmap->{$genomeID};
    if (! $refData) {
        # Here we have to compute the reference genomes.
        $refData = BuildRefData($geo);
    }
    # Problematic roles are stashed here.
    my @pprList;
    # The contig structures are stashed here.
    my @contigs;
    # This will hold the IDs of all the funky features.
    my %pprFids;
    # Connect the coverage and reference genome data.
    $gThing->{refs} = $refData->{refs};
    $gThing->{coverage} = $refData->{coverage};
    $gThing->{genome_url} = $genomeURL;
    # Create the ppr descriptor for the bin. This also nets us the ppr count.
    my $pprs = 0;
    for my $role (sort keys %$pprRoleData) {
        my $pa = $pprRoleData->{$role} // [0,0, ''];
        my ($predicted, $actual, $comment) = @$pa;
        if ($predicted != $actual) {
            $pprs++;
            my $roleName = $roleMap->{$role} // $role;
            my $fidList = $geo->roleFids($role);
            my $n_fids = scalar @$fidList;
            my %pprThing = (role => $roleName, predicted => $predicted, actual => $actual, n_fids => $n_fids, comment => $comment);
            $pprThing{fid_url} = fid_list_url($fidList);
            push @pprList, \%pprThing;
            # Save the feature IDs in the PPR fid hash.
            for my $fid (@$fidList) {
                $pprFids{$fid} = 1;
            }
        }
    }
    # Store the PPR count in the main descriptor.
    $gThing->{ppr} = $pprs;
    # Now we need to create the contigs structure.
    my $contigCountH = $geo->contigReport;
    my @contigList = sort { $geo->contigLen($b) <=> $geo->contigLen($a) } keys %$contigCountH;
    for my $contigID (@contigList) {
        my ($good, @fids) = @{$contigCountH->{$contigID}};
        my $nFids = scalar @fids;
        if ($nFids) {
            my $url = fid_list_url(\@fids);
            my $contigDatum = { name => $contigID, len => $geo->contigLen($contigID),
                                n_fids => $nFids, fid_url => $url, good => $good, list_url => $geo->contig_link($contigID) };
            push @contigs, $contigDatum;
        }
    }
    # Set up the editor variables.
    my ($editFlag, $gtoFile, $editScript);
    if ($editHash) {
        $editFlag = 1;
        $gtoFile = $editHash->{gto};
        $editScript = $editHash->{editScript};
    }
    # Create the template engine.
    my $templateEngine = Template->new(ABSOLUTE => 1);
    my $retVal;
    my $vars = { g => $gThing, p => \@pprList, c => \@contigs, editform => $editFlag, gtoFile => $gtoFile, script => $editScript };
    # print STDERR Dumper($vars->{g});
    $templateEngine->process($detail_tt, $vars, \$retVal) || die "Error in HTML template: " . $templateEngine->error();
    # Return the report.
    return $retVal;
}

=head3 fid_list_url

    my $url = BinningReports::fid_list_url(\@fids);

Return a URL for viewing a list of PATRIC features.

=over 4

=item fids

Reference to a list of feature IDs.

=item RETURN

Returns a URL for viewing a single feature or a list of multiple features.

=back

=cut

sub fid_list_url {
    my ($fids) = @_;
    my $retVal;
    if (@$fids == 1) {
        $retVal = "https://www.patricbrc.org/view/Feature/" . uri_escape($fids->[0]);
    } elsif (@$fids > 1) {
        my $list = join(",", map { uri_escape(qq("$_")) } @$fids);
        $retVal = "https://www.patricbrc.org/view/FeatureList/?in(patric_id,($list))";
    }
    return $retVal;
}

=head3 parse_bins_json

    my $refGMap = BinningReports::parse_bins_json($bins_json);

Parse the L</bins_json> object and return a map of bin names to coverage and reference genome information.

=over 4

=item bins_json

The L</bins_json> object produced by the binning report. If this value is undefined, an empty hash will be returned.
If it is a hash reference, the hash reference will be returned unchanged.

=item RETURN

Returns a reference to a hash that maps each bin name to a sub-hash with the following keys.

=over 8

=item refs

Reference to a list of reference genome descriptors, each a hash reference with keys C<genome> (the genome ID) and
C<url> (the PATRIC URL for the genome page).

=item coverage

The mean coverage of the bin.

=back

=back

=cut

sub parse_bins_json {
    my ($bins_json) = @_;
    my $retVal = {};
    if ($bins_json) {
        if (ref $bins_json eq 'HASH') {
            $retVal = $bins_json;
        } else {
            for my $binThing (@$bins_json) {
                my $name = $binThing->{name};
                my $refs = $binThing->{refGenomes};
                my @refList = map { { genome => $_, url => join('/', URL_BASE , uri_escape($_)) } } @$refs;
                my ($cov, $count) = (0, 0);
                for my $covItem (@{$binThing->{contigs}}) {
                    $cov += $covItem->[2];
                    $count++;
                }
                if ($count > 1) {
                    $cov /= $count;
                }
                $cov = int($cov * 100) / 100;
                $retVal->{$name} = { refs => \@refList, coverage => $cov };
            }
        }
    }
    return $retVal;
}

=head3 BuildRefData

    my $refData = BuildRefData($geo);

Build the reference-data structure from a L<GEO> when it is not available from a bins_json object. In this case, the coverage will be 0,
and all the reference genomes attached to the GEO will be listed.

=cut

sub BuildRefData {
    my ($geo) = @_;
    my $refList = $geo->refList;
    my @refDataRefList = map { { genome => $_->id, url => join('/', URL_BASE , uri_escape($_->id)) } } @$refList;
    my $retVal = { refs => \@refDataRefList, coverage => 0 };
    return $retVal;
}

=head3 copy_geo

    my (\%gHash, $good) = BinningReports::copy_gto($geo);

Extract the quality data from a binning L<GEO>.

=over 4

=item gto

A L<GEO> object for the bin.

=item RETURN

Returns a reference to a hash containing the genome quality data for the templates and a TRUE/FALSE flag indicating whether
the genome is good.

=back

=cut

sub copy_geo {
    my ($geo) = @_;
    my %gThing = (
        genome_id => $geo->id,
        genome_name => $geo->name
    );
    ($gThing{scikit_coarse}, $gThing{scikit_fine}, $gThing{checkg_completeness},
     $gThing{checkg_contamination}, $gThing{checkg_group}) = $geo->scores;
    my $good = 1;
    $gThing{scikit_color} = "";
    $gThing{completeness_color} = "";
    $gThing{contamination_color} = "";
    $gThing{seed_color} = "";
    if (! $geo->is_complete) {
        $gThing{completeness_color} = WARN_COLOR;
        $good = 0;
    }
    if (! $geo->is_consistent) {
        $gThing{scikit_color} = WARN_COLOR;
        $good = 0;
    }
    if (! $geo->is_clean) {
        $gThing{contamination_color} = WARN_COLOR;
        $good = 0;
    }
    $gThing{good_seed} = 'Y';
    if (! $geo->good_seed) {
        $good = 0;
        $gThing{good_seed} = '&nbsp;';
        $gThing{seed_color} = WARN_COLOR;
    }
    my $metrics = $geo->metrics;
    $gThing{n50} = $metrics->{N50};
    $gThing{l50} = $metrics->{L50};
    $gThing{dna_bp} = $metrics->{totlen};
    $gThing{contigs} = $geo->contigCount;
    ($gThing{over_roles}, $gThing{under_roles}, $gThing{pred_roles}, $gThing{comp_roles}) = $geo->roleStats;
    # Store the role counts and ratios.
    $gThing{tot_funs} = $geo->pegCount;
    $gThing{tot_hypos} = $geo->hypoCount;
    $gThing{tot_roles} = $geo->roleCount;
    $gThing{cds_pct} = Math::Round::nearest(0.01, $geo->cdsPercent);
    $gThing{hypo_pct} = Math::Round::nearest(0.01, $geo->hypoPercent);
    $gThing{plfam_pct} = Math::Round::nearest(0.01, $geo->plfamPercent);
    # Set the colors for the non-critical quality numbers.
    $gThing{contig_color} = "";
    $gThing{length_color} = "";
    $gThing{n50_color} = "";
    $gThing{l50_color} = "";
    $gThing{cds_color} = "";
    $gThing{hypo_color} = "";
    if ($gThing{contigs} > 1000) {
        $gThing{contig_color} = WARN_COLOR;
    }
    if ($gThing{dna_bp} > 15000000 || $gThing{dna_bp} < 300000) {
        $gThing{length_color} = WARN_COLOR;
    }
    if ($gThing{n50} < 5000) {
        $gThing{n50_color} = WARN_COLOR;
    }
    if ($gThing{l50} > 500) {
        $gThing{l50_color} = WARN_COLOR;
    }
    if ($gThing{cds_pct} < 50 || $gThing{cds_pct} > 150) {
        $gThing{cds_color} = WARN_COLOR;
    }
    if ($gThing{hypo_pct} > 70) {
        $gThing{hypo_color} = WARN_COLOR;
    }
    # If the checkg_group contains a taxon ID, convert it to a link.
    if ($gThing{checkg_group} =~ /^(.+)\s+\((\d+)\)/) {
        $gThing{checkg_group} = qq(<a href="http://patricbrc.org/view/Taxonomy/$2">$1</a>);
    }
    return (\%gThing, $good);
}

=head3 template_options

This is a list of the command-line option specifiers used for the binning reports. The options are as follows.

=over 4

=item templates

Name of the directory containing the web page templates and style file. The default is C<RASTtk/lib/BinningReports> in the
SEEDtk code directory.

=back

=cut

sub template_options {
    return
        (['templates=s', 'name of the directory containing the binning templates',
                { default => "$FIG_Config::mod_base/RASTtk/lib/BinningReports" }]);
}

=head3 build_strings

    my ($prefix, $suffix, $detailTT) = BinningReports::build_strings($dir);

Return the HTML prefix, suffix, and detail template for building binning report web pages.

=over

=item dir

A L<Getopt::Long::Descriptive::Opts> object containing the C<templates> parameter for location the templates directory, or the
name of the templates directory itself.

=item RETURN

Returns a list consisting of the HTML web page prefix, the HTML web page suffix, and finally the detail template to be passed to the L</Detail> method.

=back

=cut

sub build_strings {
    my ($opt) = @_;
    my $templateDir = (ref $opt ? $opt->templates : $opt);
    my $detailTT = "$templateDir/details.tt";
    my ($prefix, $suffix);
    # Prepare the text strings for the web pages.
    if (! -s $detailTT) {
        die "Could not find web template in $templateDir.";
    } else {
        # Read the template file.
        open(my $th, "<$detailTT") || die "Could not open template file: $!";
        $detailTT = join("", <$th>);
        # Copy the style file.
        $prefix = "<html><head>\n<style type=\"text/css\">\n";
        close $th; undef $th;
        open($th, "<$templateDir/packages.css") || die "Could not open style file: $!";
        while (! eof $th) {
            $prefix .= <$th>;
        }
        close $th; undef $th;
        $prefix .= "</style>\n";
        $suffix = "\n</body></html>\n";
    }
    return($prefix, $suffix, $detailTT);
}


1;
