use Data::Dumper;
use strict;
use warnings;
use P3Signatures;
use TraceObject;

=head1 Compute Family Signatures

     p3-signature-families --gs1=FileOfGenomeIds
                           --gs2=FileOfGenomeIds
                           [--min=MinGs1Frac]
                           [--max=MaxGs2Frac]
        > family.signatures

This script compares two genome groups-- group 1 contains genomes that are interesting for some reason,
group 2 contains genomes that are not. The output contains protein families that are common in the interesting
set but not in the other set. The output file will be tab-delimited, with four columns-- the number of
family occurrences in set 1, the number of family occurrences in set 2, the family ID, and the family's
assigned function.

=head2 Parameters

=over 4

=item col

Specifies the (1-based) column index or name of the genome ID column in the two
genome input files. The default is C<0>, indicating the last colummn.

=item gs1

A tab-delimited file of genomes.  These are thought of as the genomes that have a
given property (e.g. belong to a certain species, have resistance to a particular
antibiotic). If omitted, the standard input is used. The genome IDs must be in the
last column.

=item gs2

A tab-delimited file of genomes.  These are genomes that do not have the given property.
If omitted, the standard input is used. The genome IDs must be in the last column.
Any genomes present in the gs1 set will be automatically deleted from this list.

=item min

Minimum fraction of genomes in Gs1 that occur in a signature family

=item max

Maximum fraction of genomes in Gs2 that occur in a signature family

=item verbose

Write progress messages to STDERR.

=back

=cut

my $opt = P3Utils::script_opts('',
        ["gs1=s", "genomes with property"],
        ["gs2=s", "genomes without property"],
        ["min|m=f","minimum fraction of Gs1",{default => 0.8}],
        ["max|M=f","maximum fraction of Gs2",{default => 0.2}],
        ["verbose|v", "show progress on STDERR"]);

# Get the command-line options.
my $gs1 = $opt->gs1;
my $gs2 = $opt->gs2;
my $min_in = $opt->min;
my $max_out = $opt->max;
# Set up the progress object.
my $tracer;
if ($opt->verbose) {
    $tracer = TraceObject->new();
}
# Read in both sets of genomes.
my $gHash = read_genomes($gs1);
my @gs1 = sort keys %$gHash;
my $gHash2 = read_genomes($gs2);
my @gs2 = sort grep { ! $gHash->{$_} } keys %$gHash2;
undef $gHash;
undef $gHash2;
if (! @gs1) {
    die "No genomes found in group 1.";
} elsif (! @gs2) {
    die "No genomes found in group 2.";
}

# Compute the output hash.
my $dataH = P3Signatures::Process(\@gs1, \@gs2, $min_in, $max_out, $tracer);
# Print the header.
P3Utils::print_cols([qw(counts_in_set1 counts_in_set2 family.family_id family.product)]);
# Output the data.
foreach my $fam (sort keys %$dataH) {
    my ($x1, $x2, $role) = @{$dataH->{$fam}};
    P3Utils::print_cols([$x1,$x2,$fam, $role]);
}

sub read_genomes {
    my ($fileSpec) = @_;
    my %retVal;
    my $gh;
    if (! $fileSpec) {
        $gh = \*STDIN;
    } else {
        open($gh, '<', $fileSpec) || die "Could not open genome file $fileSpec: $!";
    }
    while (! eof $gh) {
        my $line = <$gh>;
        if ($line =~ /^(\d+\.\d+)/) {
            $retVal{$1} = 1;
        }
    }
    return \%retVal;
}