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
use LWP::Simple;
use SeedUtils;
use SeedURLs;
use ScriptUtils;
use MapToRef;
use GenomeTypeObject;
use gjoseqlib;
use Time::HiRes qw(gettimeofday);
use File::Slurp;

=head1 Project Features from a Reference Genome to a Close Strain

    fast_project -r RererenceGenomeId [-k kmer-sz] < genome [ options ]

This script compares the DNA in a reference genome to a new genome (the I<target>) and uses
the features in the reference genome to call features in the new one. The correspondence
between the DNA in the two genomes is computed using 2-of-3 kmers, that is, kmers that
use the first two of every three base pairs to form a sequence.

The first phase of the script computes the unique kmers for both genomes and then
constructs a table of correspondences (called I<pins>). Two locations are considered
pinned if we are confident they represent the same DNA. A location in this case is
defined by a contig ID, a strand, and a position. Thus, it is possible for a location
on the B<+> strand of one genome to be pinned to a location on the B<-> strand of the other.

Once we have computed the pins, we run through the features of the reference genome
looking for instances where a significant majority of the locations in the feature are
pinned to contiguous locations on the target genome. If this is the case, we call the
region so defined on the target genome as a feature with the same function as the
reference feature.

=head2 Output

The output is a JSON-format L<GenomeTypeObject> containing the newly-called features.
These will be in addition to any original features that were present.

=head2 Parameters

The input file (either the standard input or specified via L<ScriptUtils/ih_options>)
contains the target genome. It can either be a L<GenomeTypeObject> in JSON format or
a FASTA file. The command-line options are as follows.

=over 4

=item seed

The name of the SEED containing the reference genome. The default is the core SEED (C<core>).

=item reference

The ID of the reference genome that. This genome must exist in the named SEED.

=item refFile

The name of a file containing the reference genome as a L<GenomeTypeObject> in JSON
format. This parameter will override C<reference>.

=item kmersize

The kmer size to use when computing the pins. The default is C<30>.

=item format

The format of the target genome, either C<fasta> for a FASTA file, or C<gto> for
a L<GenomeTypeObject> in JSON format. The default is C<gto>.

=item annotator (optional)

The name of the annotator to use when describing the creation of new features in the
target genome.

=item idprefix (optional)

The prefix to use when assigning new feature IDs in the target genome.

=item gid (optional)

The ID of the target genome. This is only necessary if the target genome is in FASTA format.

=back

=cut

# Get the names of the SEEDs we support.
my $seeds = SeedURLs::names();
# Get the command-line parameters.
my $opt = ScriptUtils::Opts(
        '',
        ScriptUtils::ih_options(),
        [ 'seed|s=s',      "name of a SEED ($seeds), or a SEED URL", { default => 'core' } ],
        [ 'reference|r=s', 'Id of the Reference Genome'],
        [ 'refFile|f=s',   'file containing the reference genome'],
        [ 'kmersize|k=i',  'Number of base pairs per kmer', { default => 30 }],
        [ 'annotator|a=s', 'string to use for the annotator name in new features'],
        [ 'idprefix=s',    'prefix to use for new IDs, including genome ID or other identifying information'],
        [ 'format|fmt=s',  'format of the input file-- "gto" or "fasta"', { default => 'gto' }],
        [ 'gid|g=s',       'ID of the target genome', { default => 'new_genome' }],
);
my $ref_text;
if ($opt->reffile) {
    $ref_text = File::Slurp::read_file($opt->reffile);
} else {
    my $seed    = $opt->seed;

    my $where = SeedURLs::url( $seed );
    if ( ! $where )
    {
        die "Specified seed $seed not found.";
    } else {

        my $refId    = $opt->reference;
        if (! $refId) {
            die "No reference genome specified.";
        } else {
            $ref_text = LWP::Simple::get( "$where/genome_object.cgi?genome=$refId" );
        }
    }
}
my $json  = JSON::XS->new;
my $ref_gto = $json->decode($ref_text);

$ref_gto = GenomeTypeObject->initialize($ref_gto);


my $k        = $opt->kmersize;

my $genetic_code = $ref_gto->{genetic_code};
my $ih       = ScriptUtils::IH($opt->input);
my $g_gto;
if ($opt->format eq 'gto') {
    # Create the GTO from a JSON input file.
    $g_gto = GenomeTypeObject->create_from_file($ih);
    $g_gto->setup_id_allocation();
} elsif ($opt->format eq 'fasta') {
    # Create a new, blank GTO.
    $g_gto = GenomeTypeObject->new();
    $g_gto->set_metadata({id => $opt->gid, genetic_code => $genetic_code});
    # Read the contigs from a FASTA file.
    my @contigs = map { {id => $_->[0], dna => $_->[2]} } read_fasta($ih);
    $g_gto->add_contigs(\@contigs);
}
$genetic_code = $g_gto->{genetic_code};
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



=head2 Internal Subroutines

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
                            -analysis_event_id => $event_id,
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


