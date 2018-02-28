=head1 Produce a Matrix of Singly-Occurring Roles For Genomes

    p3-role-matrix.pl [options] roles.in.subsystems

Given an input list of genome IDs, this program produces a matrix of the roles that are singly-occurring. The output file will contain a genome
ID in the first column, a taxonomic ID in the second column, and will have one additional column for each role ID. If the role is singly-occurring
in the genome, the column will contain a C<1>. Otherwise it will contain C<0>. The roles are taken from a typical B<roles.in.subsystems> file, which
contains a role ID in the first column, a role checksum in the second, and a role name in the third.

Status is displayed on the standard error output.

=head2 Parameters

The positional parameter is the name of the role file. The role file must contain role IDs in the first column and role checksums in the second.
The file is tab-delimited and headerless.

The standard input can be overridden using the options in L<P3Utils/ih_options>. Use the options in L<P3Utils/col_options> to identify the
column containing genome IDs.

=cut

use strict;
use P3DataAPI;
use P3Utils;
use Stats;
use RoleParse;
use SeedUtils;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('roles.in.subsystems', P3Utils::col_options(), P3Utils::ih_options(),
        );
# Create the statistics object.
my $stats = Stats->new();
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# This hash maps a checksum to a role ID.
my %checksums;
# This is an initial role list used for output column headers.
my @roles;
# Verify that we have the role file.
my ($roleFile) = @ARGV;
if (! $roleFile) {
    print STDERR "Default role file used.\n";
    $roleFile = "$FIG_Config::global/roles.in.subsystems";
}
if (! -s $roleFile) {
    die "Role file $roleFile not found.";
} else {
    # Loop through the roles.
    print STDERR "Reading roles from $roleFile.\n";
    open(my $rh, "<$roleFile") || die "Could not open $roleFile: $!";
    while (! eof $rh) {
        my $line = <$rh>;
        my ($role, $checksum) = split /\t/, $line;
        $stats->Add(roleIn => 1);
        # Record this role.
        $checksums{$checksum} = $role;
        push @roles, $role;
    }
    print STDERR scalar(@roles) . " roles found in role file.\n";
}
# Remember the role count.
my $nRoles = scalar @roles;
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my (undef, $keyCol) = P3Utils::process_headers($ih, $opt);
# Form the full header set and write it out.
if (! $opt->nohead) {
    P3Utils::print_cols(['genome', 'taxon', @roles]);
}
# Extract all the genome IDs.
my $genomes = P3Utils::get_col($ih, $keyCol);
print STDERR scalar(@$genomes) . " genomes found in input.\n";
$stats->Add(genomesIn => scalar @$genomes);
# Now we create a hash mapping each genome ID to its name and taxon. The name is only for status output.
# The taxon will appear in the output file.
print STDERR "Reading genome data.\n";
my $gHash = get_genome_data($genomes);
$genomes = [sort keys %$gHash];
my $total = scalar @$genomes;
my $count = 0;
# Now we need to process the genomes one at a time. This is a slow process.
for my $genome (@$genomes) {
    my ($name, $taxon) = @{$gHash->{$genome}};
    $count++;
    print STDERR "Processing $genome ($count of $total): $name\n";
    # Read all the features. We will use them to fill the role hash.
    my %rCounts;
    my $features = P3Utils::get_data($p3, feature => [['eq', 'genome_id', $genome]], ['patric_id', 'product']);
    for my $feature (@$features) {
        $stats->Add(featureIn => 1);
        my ($id, $product) = @$feature;
        # Only process PATRIC features, as these have annotations we can parse.
        if ($id) {
            # Split the product into roles.
            my @roles = SeedUtils::roles_of_function($product);
            # Count the roles of interest.
            for my $role (@roles) {
                $stats->Add(roleIn => 1);
                my $checksum = RoleParse::Checksum($role);
                my $roleID = $checksums{$checksum};
                if (! $roleID) {
                    $stats->Add(roleUnknown => 1);
                } else {
                    $stats->Add(roleFound => 1);
                    $rCounts{$roleID}++;
                }
            }
        }
    }
    # Now %rCounts contains the number of occurrences of each role in this genome. We mark as found the roles that occur
    # exactly once.
    my @cols = map { (($rCounts{$_} && $rCounts{$_} == 1) ? 1 : 0) } @roles;
    P3Utils::print_cols([$genome, $taxon, @cols]);
    $stats->Add(genomesProcessed => 1);
}
print STDERR "All done.\n" . $stats->Show();

##
## Read the name and taxon ID of each genome and return a hash.
sub get_genome_data {
    my ($genomes) = @_;
    my $genomeData = P3Utils::get_data_keyed($p3, genome => [], ['genome_id', 'genome_name', 'taxon_id'], $genomes, 'genome_id');
    print STDERR scalar(@$genomeData) . " genomes found in PATRIC.\n";
    my %retVal = map { $_->[0] => [$_->[1], $_->[2]] } @$genomeData;
    return \%retVal;
}
