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
        ["nameSuffix=s", "suffix to give to the genome name"]
      );
my $stats = Stats->new();

# Get access to PATRIC.
my $p3 = P3DataAPI->new();

# Get the options.
my $oh    = P3Utils::oh($opt);
my $debug = $opt->verbose;

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

# At this point, we are doing a dummy process where we copy the taxonomy from the
# closest genome and leave the genome ID as 99.99.  Later we will do the real
# stuff.
my ($g) = $p3->query(
    "genome",
    [ "eq", "genome_id", $genomeID ],
    [ "select", "genome_id", "taxon_id", "taxon_lineage_names",
        "taxon_lineage_ids", "gc_content"
    ],
);

# Only proceed if we found a genome.

if ( !$g ) {
    die "Genome $genomeID not found.";
}
# Compute the genome name.
my $name = CloseAnno::genome_name($p3, $genomeID, $opt->namesuffix);
print STDERR "Genome name is $name.\n";
$gto->{scientific_name} = $name;
# Compute the domain.
my $domain = $g->{taxon_lineage_names}[1];
if ( !grep { $_ eq $domain } qw(Bacteria Archaea Eukaryota) ) {
    $domain = $g->{taxon_lineage_names}[0];
}

# Update the GTO metadata.
$gto->set_metadata(
    {
        source           => 'RASTng',
        ncbi_taxonomy_id => $g->{taxon_id},
        taxonomy         => $g->{taxon_lineage_names},
        domain           => $domain,
    }
);

# Get the taxonomic ranks.
my $lineage = $g->{taxon_lineage_ids};
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
