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
use Data::Dumper;
use SeedUtils;
use ScriptUtils;
use MapToRef;
use GenomeTypeObject;
use Time::HiRes qw(gettimeofday);

=head1 project reference genome to a close strain

    fast_project_ref_to_GTO -r RererenceGenomeId [-k kmer-sz] < gto [ options ]

project a reference genome to call features in a new genome (the gto)


=head2 Parameters

The command-line options are those found in L<Shrub/script_options> and
L<ScriptUtils/ih_options> plus the following.

=over 4

=item -r ReferenceGenomeId

a path to a SEED genome for the reference genome

=back

the gto must include the genome ID and the genetic code

=cut


# Get the command-line parameters.
my $opt = ScriptUtils::Opts(
	'',
        ScriptUtils::ih_options(),
        [ 'annotator|a=s', 'string to use for the annotator name in new features'],
	[ 'reference|r=s', 'Id of the Reference Genome', { required => 1 } ],
	[ 'kmersize|k=i',  'Number of base pairs per kmer', { default => 30 }],
	[ 'idprefix=s',    'prefix to use for new IDs, including genome ID or other identifying information'],
);
my $ih       = ScriptUtils::IH($opt->input);
my $g_gto    = GenomeTypeObject->create_from_file($ih);
$g_gto->setup_id_allocation();

my $refId    = $opt->reference;
use LWP::Simple;

my $ref_text = &LWP::Simple::get("http://core.theseed.org/FIG/genome_object.cgi?genome=$refId");
my $json  = JSON::XS->new;
my $ref_gto = $json->decode($ref_text);
$ref_gto = GenomeTypeObject->initialize($ref_gto);

my $k        = $opt->kmersize;

my $genetic_code = $g_gto->{genetic_code};

my @ref_tuples = map { [$_->{id},'',$_->{dna}] } $ref_gto->contigs;
my @g_tuples   = map { [$_->{id},'',$_->{dna}] } $g_gto->contigs;

my $map = &MapToRef::build_mapping($k, \@ref_tuples, \@g_tuples );
my @ref_features =  map { my $loc = $_->{location};
                            (@$loc == 1) ? [$_->{id}, $_->{type}, $loc->[0], $_->{function} ] : () }
                        $ref_gto->features;

my $gFeatures = &MapToRef::build_features($map, \@g_tuples, \@ref_features, $genetic_code);
# Add the features to the output genome.
my ($count,$num_pegs) = add_features_to_gto($g_gto, $gFeatures, $opt);
print STDERR "$count features added to genome.\n";
print STDERR "$num_pegs pegs added to genome.\n";
$g_gto->destroy_to_file(\*STDOUT);


=head3 add_features_to_gto

    my $count = add_features_to_gto($gto, \@newFeatures, $opt);

Add features from a list to a L<GenomeTypeObject>. This will have no
effect if the feature list is empty.

=over 4

=item gto

L<GenomeTypeObject> to which the features should be added.

=item newFeatures

Reference to a list of features. Each feature is a 5-tuple consisting of (0) the feature type, (1) the location
tuple [contig, begin, strand, length], (2) the functional assignment, (3) the feature ID from which it was
projected, and (4) the DNA or protein string.

=item opt

L<Getopt::Long::Descriptive::Opts> of the parameters to this invocation.

=item RETURN

Returns the number of features added.

=back

=cut

sub add_features_to_gto {
    # Get the parameters.
    my ($gto, $newFeatures, $opt) = @_;
    # This will be the return count.
    my $retVal = 0;
    my $num_pegs = 0;
    # Only proceed if we have features.
    if ($newFeatures && @$newFeatures) {
        # Compute the annotator.
        my $annotator = $opt->annotator || "unknown";
        # Get the ID prefix (if any).
        my $idprefix = $opt->idprefix;
        # Get the list of parameters.
        my @parms;
        if ($opt->_specified('reference')) {
            push @parms, "reference => " . $opt->reference;
        }
        if ($opt->_specified('kmersize')) {
            push @parms, "kmersize => " . $opt->kmersize;
        }
        if ($opt->_specified('annotator')) {
            push @parms, "annotator => " . $annotator;
        }
        if ($opt->_specified('idprefix')) {
            push @parms, "idprefix => " . $idprefix;
        }
        # Create the analysis event.
        my %eventDef = (tool_name => 'fast_project_ref_to_GTO', execution_time => scalar gettimeofday,
                        parameters => \@parms, hostname => $gto->hostname);
        my $event_id = $gto->add_analysis_event(\%eventDef);
        # Create the quality measure.
        my %quality_measure = (existence_confidence => 0.80, existence_priority => 100);
        # Loop through the incoming features, adding them.
        for my $newFeature (@$newFeatures) {
            my ($type, $loc, $function, $fromFid, $seq) = @$newFeature;
            # Create the feature object as expected by GTO.
            my %featureH = (-type => $type,
                            -location => [$loc],
                            -function => $function,
                            -annotator => $annotator,
                            -annotation => "fast_project from $fromFid",
                            -event_id => $event_id,
                            -quality_measure => \%quality_measure);
            # If we have an ID prefix, add it.
            if ($idprefix) {
                $featureH{-id_prefix} = $idprefix;
            }
            # If this is a peg, add the protein translation.
            if ($type eq 'peg' || $type eq 'CDS') {
                $featureH{-protein_translation} = $seq;
		$num_pegs++;
            }
            # Add the feature to the genome.
            $gto->add_feature(\%featureH);
            # Count this new feature.
            $retVal++;
        }
    }
    # Return the count of features added.
    return ($retVal,$num_pegs);
}


