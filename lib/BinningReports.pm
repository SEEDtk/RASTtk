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

=item tetra

A reference to a vector of tetranucleotide counts for the bin's DNA.

=item tetraLen

The length of the tetranucleotide vector for the bin, used to normalize it.

=item uniProts

Reference to an empty hash.

=back

=head3 bin_gto

This is a L<GenomeTypeObject> with the special element C<genome_quality_measure> that contains the following keys.

=over 4

=item checkg_data

Reference to a hash with the following keys.

=over 8

=item Group

The taxonomic estimate used to check the genome.

=item Completeness

The completeness percentage.

=item Contamination

The contamination percentage.

=back

=item consis_data

Reference to a hash with the following keys.

=over 8

=item Fine_consistency

The fine consistency percentage.

=item Coarse_consistency

The coarse consistency percentage.

=back

=item genome_metrics

Reference to a hash with the following keys.

=over 8

=item totlen

The total length of the genome in base pairs.

=item N50

The N50 statistical estimate of contig lengths. At least half the base pairs are in contigs this length or greater.

=back

=item problematic_roles_report

Reference to a hash with the following keys.

=over 8

=item role_fids

Reference to a hash that maps each role ID to a list of feature IDs for features possessing that role.

=item role_ppr

Reference to a hash that maps each role ID to a 2-tuple consisting of (0) the number of expected occurrences and (1) the number of actual occurrences.

=back

=item contigs

Reference to a hash mapping each contig ID to its length.

=item contig_data

Reference to a hash mapping each contig ID to a list consisting of the number of features containing good roles followed by
the IDs of all the features containing bad roles.

=back

=cut

# Good/Bad criteria
use constant MIN_CHECKM => 80;
use constant MIN_SCIKIT => 87;
use constant MAX_CONTAM => 10;

# URL helpers
use constant URL_BASE => 'https://www.patricbrc.org/view/Genome';

=head2 Public Methods

=head3 Summary

    my $summary = BinningReports::Summary($jobID, $params, $bins_json, $summary_tt, $genome_group_path, \@gtos, \%report_url_map);

Produce the summary report.

=over 4

=item jobID

The PATRIC job identifier for the binning run.

=item params

The L</params> structure used to invoke the binning.

=item bins_json

The L</bins_json> structure produced by the binning.

=item summary_tt

The template to be used for the summary report. This template expects the following variables.

=over 8

=item job_id

The PATRIC job identifier.

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

=item checkm_completeness

The CheckM completeness score.

=item completeness_color

A style tag for the background color of the checkm completeness score, or a null string.

=item checkm_contamination

The CheckM contamination score.

=item contamination_color

A style tag for the background color of the checkm contamination score, or a null string.

=item contigs

The number of contigs in the bin.

=item dna_bp

The total number of DNA base pairs in the bin.

=item n50

The N50 statistical measure of contig lengths.

=item ppr

A count of the problematic roles.

=item refs

A list of reference genome descriptors, each a hash reference containing the genome name in C<genome> and the URL in C<url>.

=item coverage

The mean coverage for the bin.

=item report_url

URL for the bin's report page.

=back

=item bad

Reference to a list of bin descriptors for bad bins. The descriptors are identical in format to the ones for the good bins.

=back

=item genome_group_path

The path to the output genome group (if any).

=item gtos

A reference to a list of L</bin_gto> objects for the bins produced.

=item report_url_map

A reference to a hash mapping each bin's genome ID to the URL for its report page.

=item RETURN

Returns the HTML string for the summary report.

=back

=cut

use constant WARN_COLOR => q(style="background-color: gold");

sub Summary {
    my ($jobID, $params, $bins_json, $summary_tt, $genome_group_path, $gtos, $report_url_map) = @_;
    # Here are the storage places for found, good, and bad. The bin's descriptor goes in the
    # lists.
    my %found = (total => 0, good => 0, bad => 0);
    my (@good, @bad);
    # First we are going to read through the bins and create a map of bin names to reference genome descriptors and coverages.
    # Each reference genome descriptor is a hash-ref with members "genome" and "url".
    my $refGmap = parse_bins_json($bins_json);
    # Now we loop through the gtos and create the genome descriptors for the good and bad lists.
    my @bins = sort { quality_score($b) <=> quality_score($a) } @$gtos;
    for my $bin (@bins) {
        # Copy the quality entry. This copy will be made into the main object used to describe bins in the output reports.
        my %gThing = copy_gto($bin);
        # Get the matching ppr and refGmap entries.
        my $genomeID = $bin->{id};
        $gThing{report_url} = $report_url_map->{$bin->{id}};
        my $genomeName = $bin->{scientific_name};
        my $genomeURL = join('/', URL_BASE, uri_escape($genomeID));
        my $ppr = $bin->{genome_quality_measure}{problematic_roles_report};
        my $refData = $refGmap->{$genomeName};
        # Only proceed if we connected the pieces. We need a fall-back in case of errors.
        if ($ppr && $refData) {
            # Connect the coverage and reference genome data.
            $gThing{refs} = $refData->{refs};
            $gThing{coverage} = $refData->{coverage};
            $gThing{genome_url} = $genomeURL;
            # Compute the ppr count.
            my $pprs = 0;
            my $pprRoleData = $ppr->{role_problematic};
            my @pprList;
            for my $role (keys %$pprRoleData) {
                my $pa = $pprRoleData->{$role} // [0,0];
                my ($predicted, $actual) = @$pa;
                if ($predicted != $actual) {
                    $pprs++;
                }
            }
            # Store the PPR count in the main descriptor.
            $gThing{ppr} = $pprs;
            # Is this bin good or bad?
            my $good = 1;
            $gThing{scikit_color} = "";
            $gThing{completeness_color} = "";
            $gThing{contamination_color} = "";
            if ($gThing{checkm_completeness} < MIN_CHECKM) {
                $gThing{completeness_color} = WARN_COLOR;
                $good = 0;
            }
            if ($gThing{scikit_fine} < MIN_SCIKIT) {
                $gThing{scikit_color} = WARN_COLOR;
                $good = 0;
            }
            if ($gThing{checkm_contamination} > MAX_CONTAM) {
                $gThing{contamination_color} = WARN_COLOR;
                $good = 0;
            }
            # Now we know.
            if ($good) {
                push @good, \%gThing;
                $found{good}++;
            } else {
                push @bad, \%gThing;
                $found{bad}++;
            }
            # Update the total-bin count.
            $found{total}++;
        }
    }
    # We have now compiled the information we need for the report. Create the template engine.
    my $templateEngine = Template->new(ABSOLUTE => 1);
    # Allocate the result variable.
    my $retVal;
    # Create the summary report parm structure.
    my $vars = { job_id => $jobID, params => $params, found => \%found, good => \@good, bad => \@bad, group_path => $genome_group_path,
                 min_checkm => MIN_CHECKM, min_scikit => MIN_SCIKIT, max_contam => MAX_CONTAM };
    # print STDERR Dumper($vars);
    # Create the summary report.
    $templateEngine->process($summary_tt, $vars, \$retVal);
    # Return the report.
    return $retVal;
}

=head3 Detail

    my $detail = BinningReports::Detail($params, $bins_json, $detail_tt, $gto, $roleMap, $editFlag);

Produce the detail report for a single bin.

=over 4

=item params

The L</params> structure used to invoke the binning. This is for future use only, and currently may be an empty hash.

=item bins_json (optional)

The L</bins_json> structure produced by the binning. If this is omitted, then coverage and reference-genome data will
be left off the output page.

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

=item gto

The L</bin_gto> for the bin.

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
    my ($params, $bins_json, $detail_tt, $gto, $roleMap, $editHash) = @_;
    # First we are going to read through the bins and create a map of bin names to reference genome descriptors and coverages.
    # Each reference genome descriptor is a hash-ref with members "genome" and "url".
    my $refGmap = parse_bins_json($bins_json);
    # Now we need to build the bin descriptor from the GTO.
    my %gThing = copy_gto($gto);
    # Get the matching ppr and refGmap entries. Note there may not be a refGmap entry if there was no bins_json.
    my $genomeID = $gto->{id};
    my $genomeName = $gto->{scientific_name};
    my $genomeURL = join('/', URL_BASE, uri_escape($genomeID));
    my $ppr = $gto->{genome_quality_measure}{problematic_roles_report};
    my $contigH = $gto->{genome_quality_measure}{contigs};
    my $contigCountH = $gto->{genome_quality_measure}{contig_data};
    my $refData = $refGmap->{$genomeName} // {};
    # Problematic roles are stashed here.
    my @pprList;
    # The contig structures are stashed here.
    my @contigs;
    # Only proceed if we connected the pieces. We need a fall-back in case of errors.
    if ($ppr && $refData) {
        # This will hold the IDs of all the funky features.
        my %pprFids;
        # Connect the coverage and reference genome data.
        $gThing{refs} = $refData->{refs};
        $gThing{coverage} = $refData->{coverage};
        $gThing{genome_url} = $genomeURL;
        # Create the ppr descriptor for the bin. This also nets us the ppr count.
        my $pprs = 0;
        my $pprRoleFids = $ppr->{role_fids};
        my $pprRoleData = $ppr->{role_ppr};
        for my $role (sort keys %$pprRoleData) {
            my $pa = $pprRoleData->{$role} // [0,0];
            my ($predicted, $actual, $comment) = @$pa;
            $pprs++;
            my $roleName = $roleMap->{$role} // $role;
            my $fidList = $pprRoleFids->{$role} // [];
            my $n_fids = scalar @$fidList;
            my %pprThing = (role => $roleName, predicted => $predicted, actual => $actual, n_fids => $n_fids, comment => $comment);
            $pprThing{fid_url} = fid_list_url($fidList);
            push @pprList, \%pprThing;
            # Save the feature IDs in the PPR fid hash.
            for my $fid (@$fidList) {
                $pprFids{$fid} = 1;
            }
        }
        # Store the PPR count in the main descriptor.
        $gThing{ppr} = $pprs;
        # Now we need to create the contigs structure.
        for my $contigID (sort keys %$contigCountH) {
            my ($good, @fids) = @{$contigCountH->{$contigID}};
            my $nFids = scalar @fids;
            if ($nFids) {
                my $url = fid_list_url(\@fids);
                my $contigDatum = { name => $contigID, len => $contigH->{$contigID},
                                    n_fids => $nFids, fid_url => $url, good => $good,
                                    fid_list => join(", ", @fids) };
                push @contigs, $contigDatum;
            }
        }
    }
    # Set up the editor variables.
    my ($editFlag, $gtoFile, $editScript);
    if ($editHash) {
        $editFlag = 1;
        $gtoFile = $editHash->{gto};
        $editScript = $editHash->{script};
    }
    # Create the template engine.
    my $templateEngine = Template->new(ABSOLUTE => 1);
    my $retVal;
    my $vars = { g => \%gThing, p => \@pprList, c => \@contigs, editform => $editFlag, gtoFile => $gtoFile, script => $editScript };
    # print STDERR Dumper($vars->{g});
    $templateEngine->process($detail_tt, $vars, \$retVal) || die "Error in HTML template: " . $templateEngine->error();
    # Return the report.
    return $retVal;
}

=head3 quality_score

    my $sortVal = BinningReports::quality_score($g);

Determine the quality score for a L</bin_gto>. A higher quality score means a better bin.

=over 4

=item g

The package object for the bin in question.

=item RETURN

Returns a score that is higher for better bins.

=back

=cut

sub quality_score {
    my ($g) = @_;
    my $q = $g->{genome_quality_measure};
    my $retVal = $q->{checkg_data}{Completeness} + 1.1 * $q->{consis_data}{'Fine Consistency'} -
            5 * $q->{checkg_data}{Contamination};
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

=head3 add_comment

    add_comment($tuple, $fid, $predicate);

Add a comment to a problematic role tuple. The comment relates to a specific feature ID, which must be hyperlinked.
The predicate describes the feature.

=over 4

=item tuple

A problematic role tuple. The third element is the comment.

=item fid

The ID of the feature being described.

=item predicate

A sentence predicate of which the feature is the subject.

=back

=cut

sub add_comment {
    my ($tuple, $fid, $predicate) = @_;
    # Hyperlink the feature ID.
    my $url = fid_list_url([$fid]);
    my $comment = "<a href=\"$url\">$fid</a> $predicate";
    if ($tuple->[2]) {
        $comment = "  $comment";
    }
    $tuple->[2] .= $comment;
}

=head3 analyze_feature

    my $comment = BinningReport::analyze_feature($gto, $feature, $roleThing);

Analyze the feature to produce a comment on why it may be problematic. We currentl check for a short
protein, a protein near the edge of a contig, and a protein in a short contig.

=over 4

=item gto

The L<GenomeTypeObject> for the genome of interest.

=item feature

The feature descriptor for the feature of interest.

=item roleThing

A tuple containing (0) the number of predicted role occurrences, (1) the number of actual role occurrences, and
(2) the current comment.

=item RETURN

Returns the predicate for a sentence about the feature whose subject would be the feature ID.

=back

=cut

sub analyze_feature {
    my ($gto, $feature, $roleThing) = @_;
    # This will contain comments. We string them together at the end.
    my @comments;
    # Get the contig length hash.
    my $contigH = $gto->{genome_quality_measure}{contigs};
    # Check the protein length.
    my $aa = $feature->{protein_translation};
    if ($aa && length($aa) < 50) {
        push @comments, 'is a short protein';
    }
    # Check the feature location.
    my $loc = $feature->{location};
    if (scalar(@$loc) > 1) {
        push @comments, 'has multiple locations';
    } else {
        my $locTuple = $loc->[0];
        my ($contig, $begin, $strand, $length) = @$locTuple;
        my $contigLen = $contigH->{$contig};
        if ($strand eq '+') {
            if ($begin < 5) {
                push @comments, 'starts near the start of the contig';
            }
            if ($begin + $length + 5 > $contigLen) {
                push @comments, 'ends near the end of the contig';
            }
        } else {
            if ($contigLen - $begin < 5) {
                push @comments, 'starts near the end of the contig';
            }
            if ($begin - $length < 5) {
                push @comments, 'ends near the start of the contig';
            }
        }
        if ($contigLen < 500) {
            push @comments, 'is in a short contig';
        }
    }
    # String all the comments together,
    my $retVal;
    if (! @comments) {
        $retVal = '';
    } else {
        my $last = (pop @comments) . ".";
        if (@comments) {
            $retVal = join(", ", @comments, "and $last");
        } else {
            $retVal = $last;
        }
    }
    return $retVal;
}

=head3 parse_bins_json

    my $refGMap = BinningReports::parse_bins_json($bins_json);

Parse the L</bins_json> object and return a map of bin names to coverage and reference genome information.

=over 4

=item bins_json

The L</bins_json> object produced by the binning report. If this value is undefined, an empty hash will be returned.

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
    my %retVal;
    if ($bins_json) {
        for my $binThing (@$bins_json) {
            my $name = $binThing->{name};
            my $refs = $binThing->{refGenomes};
            my @refList = map { { genome => $_, url => join('/', URL_BASE , uri_escape($_)) } } @$refs;
            my ($cov, $count) = (0, 0);
            for my $covItem (@{$binThing->{coverage}}) {
                $cov += $covItem;
                $count++;
            }
            if ($count > 1) {
                $cov /= $count;
            }
            $cov = int($cov * 100) / 100;
            $retVal{$name} = { refs => \@refList, coverage => $cov };
        }
    }
    return \%retVal;
}

=head3 copy_gto

    my %gHash = BinningReports::copy_gto($gto);

Extract the quality data from a binning L<GenomeTypeObject>.

=over 4

=item gto

A L</bin_gto> object for the bin.

=item RETURN

Returns a hash containing the following keys.

=over 8

=item checkm_completeness

The percent CheckM completeness score for the bin.

=item checkm_contamination

The percent CheckM contamination score for the bin.

=item genome_id

The genome ID for the bin.

=item genome_name

The name of the bin.

=item contigs

The number of contigs in the bin.

=item dna_bp

The size of the bin in DNA base pairs.

=item n50

The N50 statistical score for the contig sizes.

=item scikit_coarse

The coarse consistency.

=item scikit_fine

The fine consistency.

=back

=back

=cut

sub copy_gto {
    my ($gto) = @_;
    my %retVal = (
        genome_id => $gto->{id},
        genome_name => $gto->{scientific_name},
    );
    my $qData = $gto->{genome_quality_measure};
    my $consis = $qData->{consis_data};
    # print STDERR Dumper($consis);
    $retVal{scikit_coarse} = $consis->{'Coarse Consistency'};
    $retVal{scikit_fine} = $consis->{'Fine Consistency'};
    my $metrics = $qData->{genome_metrics};
    $retVal{n50} = $metrics->{N50};
    $retVal{dna_bp} = $metrics->{totlen};
    $retVal{contigs} = scalar @{$gto->{contigs}};
    my $checkg = $qData->{checkg_data};
    $retVal{checkg_completeness} = $checkg->{Completeness};
    $retVal{checkg_contamination} = $checkg->{Contamination};
    $retVal{checkg_group} = $checkg->{Group};
    return %retVal;
}

=head3 UpdateGTO

    BinningReports::UpdateGTO($gto, $qualityFile, \%roleMap);

Merge the quality measures into a L<GenomeTypeObject>. The C<genome_quality_measure> member will be created with all the
associated sub-members required by the binning detail report. The resultant GTO can be passed to the L</Detail> method
for creation of a binning report page.

=over 4

=item gto

A L<GenomeTypeObject> to be updated with quality information.

=item qualityFile

The name of the file containing the quality report output. This consists of a completeness report followed by a
consistency report. Each report begins with a set of labeled values and is followed by tab-delimited lines containing
(0) a role ID, (1) the predicted number of occurrences, and (2) the actual number of occurrences.

=item roleMap

Reference to a hash mapping each role checksum to an ID.

=back

=cut

sub UpdateGTO {
    my ($gto, $qualityFile, $roleMap) = @_;
    # This will be our quality measure object.
    my %q;
    $gto->{genome_quality_measure} = \%q;
    # The first thing is to create an index of contig lengths.
    my %contigs;
    for my $contig (@{$gto->{contigs}}) {
        $contigs{$contig->{id}} = length($contig->{dna});
    }
    $q{contigs} = \%contigs;
    # Start with the metrics.
    my $metricH = $gto->metrics();
    $q{genome_metrics} = $metricH;
    # This hash will contain the good roles. Good roles have a matching predicted and actual count.
    my %good;
    # This hash will contain the potentially problematic roles. Each role is mapped to its expected and
    # actual occurrences. Both the consistency and completeness checker have problematic roles. We read
    # completeness checker first, so if any roles overlap, the consistency checker overrides the completeness
    # result.
    my (%ppr, %checkGdata, %skData);
    if (open(my $ih, "<$qualityFile")) {
        # Start in completeness mode.
        my $hash = \%checkGdata;
        my $comment = 'Universal role.';
        my $mode = 0;
        while (! eof $ih) {
            my $line = <$ih>;
            if ($line =~ /^([^:]+):\s+(.+)/) {
                # Here we have a heading line.
                if ($mode) {
                    # We were processing data lines, so we need to rig for a new section.
                    $hash = \%skData;
                    $comment = '';
                    $mode = 0;
                }
                # Store the heading key/value pair in the appropriate hash.
                $hash->{$1} = $2;
            } elsif ($line =~ /^(\S+)\t(\d+)\t(\d+)/) {
                $mode = 1;
                # Here we have a data line.
                my ($role, $pred, $actual) = ($1, $2, $3);
                if ($pred == $actual) {
                    $good{$role} = 1;
                } else {
                    $ppr{$role} = [$pred, $actual, $comment];
                }
            }
        }
    }
    # Now we need to map the roles to feature IDs. This hash will map a role ID to a list of features.
    # We step through all the features, and if the checksum matches a role ID in the PPR, we put it in
    # that ID's list.
    my %fids;
    # This hash counts the number of good roles for the contig and lists the features containing bad roles.
    my %contigCount;
    # Loop through the features.
    for my $feature (@{$gto->{features}}) {
        my $fid = $feature->{id};
        my $function = $feature->{function} // '';
        my @roles = SeedUtils::roles_of_function($function);
        my ($good, $bad) = (0, 0);
        for my $role (@roles) {
            my $roleID = $roleMap->{RoleParse::Checksum($role)};
            if ($roleID) {
                if ($ppr{$roleID}) {
                    push @{$fids{$roleID}}, $fid;
                    my $comment = analyze_feature($gto, $feature, $ppr{$roleID});
                    if ($comment) {
                        add_comment($ppr{$roleID}, $fid, $comment);
                    }
                    $bad = 1;
                } elsif ($good{$roleID}) {
                    $good = 1;
                }
            }
        }
        if ($good || $bad) {
            # Here we need to count this feature for the contig.
            my $contig = $feature->{location}[0][0];
            $contigCount{$contig} //= [0];
            if ($good) {
                $contigCount{$contig}[0]++;
            }
            if ($bad) {
                push @{$contigCount{$contig}}, $fid;
            }
        }
    }
    # All of this must now be assembled into the GTO.
    $q{checkg_data} = \%checkGdata;
    $q{consis_data} = \%skData;
    $q{problematic_roles_report} = { role_fids => \%fids, role_ppr => \%ppr };
    $q{contig_data} = \%contigCount;
}


1;
