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

=head1 Taxonomy Computation

    Tax_Comp.pl [options] workDir

Compute genome taxonomy and adjust name.

=head2 Parameters

The positional parameters are ##TODO positionals

The standard input can be overridden using the options in L<P3Utils/ih_options>.

The standard output can be overridden using the options in L<P3Utils/oh_options>.

Additional command-line options are the following.

=over 4

=item verbose

Display progress messages on STDERR.

=item nameSuffix

Suffix to add to the species name in order to form the genome name.

=item id

Genome ID to assign to the genome.  The default value of C<computed> means the genome ID will be computed.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use GenomeTypeObject;
use Stats;
use CloseAnno;

$| = 1;

# Get the command-line options.
my $opt = P3Utils::script_opts( 'workDir', P3Utils::ih_options(), P3Utils::oh_options(),
        [ 'verbose|v', 'Display progress messages on STDERR' ],
        ["nameSuffix=s", "suffix to give to the genome name"],
        ["id=s", "genome ID to use", { default => "computed" }]
      );
my $stats = Stats->new();

# Get access to PATRIC.
my $p3 = P3DataAPI->new();

# Get the options.
my $oh    = P3Utils::oh($opt);
my $debug = $opt->verbose;
my $idSpec = $opt->id;

# Process the positional parameters.
my ($workDir) = @ARGV;
if ( !$workDir ) {
    die "No working directory specified.";
}
elsif ( !-d $workDir ) {
    die "Invalid or missing working directory $workDir.";
}

# Read the input GTO.
print STDERR "Loading GTO for Taxonomy Computation.\n" if $debug;
my $ih  = P3Utils::ih($opt);
my $gto = GenomeTypeObject->create_from_file($ih);
# Get the close genome ID.
my $genomeID = $gto->{close_genomes}[0]{genome};

# Here we need to get the lineage, the genome ID, and the taxon ID.
my $lineageList;
my $newID;
my $taxonID;
my $lineage;

if ($idSpec ne "computed") {
    print STDERR "Using pre-specified genome ID $idSpec.\n" if $debug;
    # Here we have a specified genome ID.  This is useful for testing.
    ($taxonID) = split /\./, $idSpec;
    my ($t) = $p3->query("taxonomy",
        ["eq", "taxon_id", $taxonID],
        [ "select", "taxon_id", "lineage_names", "lineage_ids"]);
    # Only proceed if we found the taxonomic lineage.
    if (! $t) {
        die "Taxonomic ID $taxonID not found.";
    }
    $lineageList = $t->{lineage_names};
    $lineage = $t->{lineage_ids};
    $newID = $idSpec;
} else {
    # Here we need to compute the ID and the taxon.  We punt on the taxon for now,
    # and use the closest genome's values.
    print STDERR "Copying taxonomy from $genomeID.\n" if $debug;
    my ($g) = $p3->query(
        "genome",
        [ "eq", "genome_id", $genomeID ],
        [ "select", "genome_id", "taxon_id", "taxon_lineage_names", "taxon_lineage_ids"],
    );
    # Only proceed if we found a genome.
    if ( !$g ) {
        die "Genome $genomeID not found.";
    }
    $lineageList = $g->{taxon_lineage_names};
    $lineage = $g->{taxon_lineage_ids};
    $taxonID = $g->{taxon_id};
    # Get a genome ID for this taxon.
    print STDERR "Computing genome ID from server using $taxonID.\n" if $debug;
    $newID = CloseAnno::ComputeId($taxonID);
}
my $lastItem = scalar(@$lineageList) - 1;
if ($lastItem < 1) {
    die "Invalid taxonomic lineage found for $taxonID using $idSpec.";
}
my $taxonName = $lineageList->[$lastItem];
# Compute the genome name.
my $name = CloseAnno::genome_name($taxonName, $opt->namesuffix);
print STDERR "New genome is $newID $name.\n";
$gto->{scientific_name} = $name;
# Compute the domain.
my $domain = $lineageList->[1];
if ( !grep { $_ eq $domain } qw(Bacteria Archaea Eukaryota) ) {
    $domain = $lineageList->[0];
}

# Update the GTO metadata.
$gto->set_metadata(
    {
        id				 => $newID,
        source           => 'RASTng',
        ncbi_taxonomy_id => $taxonID,
        taxonomy         => $lineageList,
        domain           => $domain,
    }
);

# Get the taxonomic ranks.
if ($lineage) {
    my %taxMap = map {
        $_->{taxon_id} =>
          [ $_->{taxon_name}, $_->{taxon_id}, $_->{taxon_rank} ]
      } $p3->query(
        "taxonomy",
        [ "in",     "taxon_id", '(' . join( ',', @$lineage ) . ')' ],
        [ "select", "taxon_id", "taxon_name",    "taxon_rank" ]
      );
    $gto->{ncbi_lineage} = [ map { $taxMap{$_} } @$lineage ];
}

# Write the modified GTO.
print STDERR "Storing GTO from Taxonomy Computation.\n" if $debug;
$gto->destroy_to_file($oh);
print STDERR "All done.\n" . $stats->Show() if $debug;
