=head1 Return Data From Genomes in PATRIC

    p3-get-genome-data [options]

This script returns data about the genomes identified in the standard input. It supports standard filtering
parameters and the specification of additional columns if desired.

=head2 Parameters

There are no positional parameters.

The standard input can be overwritten using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/data_options> and L<P3Utils/col_options>.

=cut

use strict;
use P3DataAPI;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('', P3Utils::data_options(), P3Utils::col_options(), P3Utils::ih_options(),
    ['fields|f', 'Show available fields']);

my $fields = ($opt->fields ? 1 : 0);
if ($fields) {
    print_usage();
    exit();
}
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Compute the output columns.
my ($selectList, $newHeaders) = P3Utils::select_clause(genome => $opt);
# Compute the filter.
my $filterList = P3Utils::form_filter($opt);
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Form the full header set and write it out.
push @$outHeaders, @$newHeaders;
P3Utils::print_cols($outHeaders);
# Loop through the input.
while (! eof $ih) {
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    # Get the output rows for these input couplets.
    my $resultList = P3Utils::get_data_batch($p3, genome => $filterList, $selectList, $couplets);
    # Print them.
    for my $result (@$resultList) {
        P3Utils::print_cols($result);
    }
}

sub print_usage {
my $usage = <<"End_of_Usage";
genome_id
p2_genome_id
genome_name
common_name
organism_name
taxon_id
taxon_lineage_ids
taxon_lineage_names
kingdom
phylum
class
order
family
genus
species
genome_status
strain
serovar
biovar
pathovar
mlst
other_typing
culture_collection
type_strain
reference_genome
completion_date
publication
bioproject_accession
biosample_accession
assembly_accession
sra_accession
ncbi_project_id
refseq_project_id
genbank_accessions
refseq_accessions
sequencing_centers
sequencing_status
sequencing_platform
sequencing_depth
assembly_method
chromosomes
plasmids
contigs
sequences
genome_length
gc_content
patric_cds
brc1_cds
refseq_cds
isolation_site
isolation_source
isolation_comments
collection_date
collection_year
isolation_country
geographic_location
latitude
longitude
altitude
depth
other_environmental
host_name
host_gender
host_age
host_health
body_sample_site
body_sample_subsite
other_clinical
antimicrobial_resistance
antimicrobial_resistance_evidence
gram_stain
cell_shape
motility
sporulation
temperature_range
optimal_temperature
salinity
oxygen_requirement
habitat
disease
End_of_Usage
print $usage;
}
