=head1 Count KMER Hits in Genomes

    p3-genome-kmer-hits.pl [options] kmerDB

This script takes as input a list of genome IDs and outputs a table of the number of kmer hits by group in each genome.  The output
file will be tab-delimited, with the genome ID, the genome name, and then one column per kmer group.

=head2 Parameters

The positional parameter is the file name of the kmer database.  This is a json-format L<KmerDb> object.

The standard input can be overridden using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/col_options> (to choose the genome ID column) plus the following
options.

=over 4

=item names

If specified, the output column headers for the kmer counts will be group names.  The default is to use group IDs.

=item prot

If specified, the kmers are assumed to be protein kmers.

=item verbose

If specified, progress messages will be written to STDERR.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use KmerDb;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('kmerDB', P3Utils::col_options(), P3Utils::ih_options(),
        ['names|N', 'use group names for column headers'],
        ['prot', 'kmer database contains proteins'],
        ['verbose|debug|v', 'print progress to STDERR']
        );
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Open the input file.
my $ih = P3Utils::ih($opt);
# Get the options.
my $names = $opt->names;
my $geneticCode = ($opt->prot ? 11 : undef);
my $debug = $opt->verbose;
# Get the kmer database.
my ($kmerDBfile) = @ARGV;
print STDERR "Loading kmers from $kmerDBfile.\n" if $debug;
my $kmerDB = KmerDb->new(json => $kmerDBfile);
my $groupList = $kmerDB->all_groups();
my $groupCount = scalar @$groupList;
print STDERR "$groupCount kmer groups found.\n";
# This will be  a hash mapping each group ID to an output column number.
my %groups;
# Format the output headers and fill in the group hash.
my @headers = qw(genome_id genome_name);
for my $group (@$groupList) {
    $groups{$group} = scalar @headers;
    push @headers, ($names ? $kmerDB->name($group) : $group);
}
P3Utils::print_cols(\@headers);
# Read the incoming headers and get the genome ID key column.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Read in the genome IDs.
my $genomes = P3Utils::get_col($ih, $keyCol);
print STDERR scalar(@$genomes) . " genomes found.\n" if $debug;
# Loop through the input.
for my $genome (@$genomes) {
    print STDERR "Processing $genome.\n" if $debug;
    # Get the contigs for this genome.
    my $contigList = P3Utils::get_data($p3, contig => [['eq','genome_id',$genome]], ['genome_id', 'genome_name', 'sequence']);
    print STDERR scalar(@$contigList) . " contigs found in genome.\n" if $debug;
    # The genome name will be put in here.
    my $gName;
    # The group counts will be put in here.
    my %counts;
    # Loop through the contigs.
    for my $contig (@$contigList) {
        $gName = $contig->[1];
        $kmerDB->count_hits($contig->[2], \%counts, $geneticCode);
    }
    # Write the genome's output line.
    if (! $gName) {
        print STDERR "No data found for $genome.\n" if $debug;
    } else {
        my @line = ($genome, $gName, map { 0 } @$groupList);
        for my $group (keys %counts) {
            $line[$groups{$group}] = $counts{$group};
        }
        P3Utils::print_cols(\@line);
    }
}
