=head1 Create Representative Genome Server Directory

    p3-rep-prots.pl [options] outDir

This script processes a list of genome IDs to create a directory suitable for use by the L<RepresentativeGenomes> server.
It will extract all the instances of the specified seed protein (Phenylanyl synthetase alpha chain) and only
keep genomes with a single instance of reasonable length. The list of genome IDs and names will go in the output file
C<complete.genomes> and a FASTA of the seed proteins in C<6.1.1.20.fasta>.

=head2 Parameters

The positional parameter is the name of the output directory. If it does not exist, it will be created.

The standard input can be overriddn using the options in L<P3Utils/ih_options>.

Additional command-line options are those given in L<P3Utils/col_options> plus the following
options.

=over 4

=item minlen

The minimum acceptable length for the protein. The default is 209.

=item maxlen

The maximum acceptable length for the protein. The default is 485.

=item clear

Clear the output directory if it already exists. The default is to leave existing files in place.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use Stats;
use File::Copy::Recursive;
use RoleParse;

$| = 1;
# Get the command-line options.
my $opt = P3Utils::script_opts('outDir', P3Utils::col_options(), P3Utils::ih_options(),
        ['minlen=i', 'minimum protein length', { default => 209 }],
        ['maxlen=i', 'maximum protein length', { default => 485 }],
        ['clear', 'clear the output directory if it exists']
        );
# Get the output directory name.
my ($outDir) = @ARGV;
if (! $outDir) {
    die "No output directory specified.";
} elsif (! -d $outDir) {
    print "Creating directory $outDir.\n";
    File::Copy::Recursive::pathmk($outDir) || die "Could not create $outDir: $!";
} elsif ($opt->clear) {
    print "Erasing directory $outDir.\n";
    File::Copy::Recursive::pathempty($outDir) || die "Error clearing $outDir: $!";
}
# Create the statistics object.
my $stats = Stats->new();
# Create a filter from the protein name.
my @filter = (['eq', 'product', 'Phenylalanyl tRNA-synthetase alpha chain']);
# Save the checksum for the seed role.
my $roleCheck = "WCzieTC/aZ6262l19bwqgw";
# Create a list of the columns we want.
my @cols = qw(genome_name patric_id aa_sequence product);
# Get the length options.
my $minlen = $opt->minlen;
my $maxlen = $opt->maxlen;
# Open the output files.
print "Setting up files.\n";
open(my $gh, '>', "$outDir/complete.genomes") || die "Could not open genome output file: $!";
open(my $fh, '>', "$outDir/6.1.1.20.fasta") || die "Could not open FASTA output file: $!";
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Open the input file.
my $ih = P3Utils::ih($opt);
# Read the incoming headers.
my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);
# Count the batches of input.
my $batches = 0;
# Loop through the input.
while (! eof $ih) {
    $batches++;
    print "Processing batch $batches.\n";
    my $couplets = P3Utils::get_couplets($ih, $keyCol, $opt);
    # Convert the couplets to contain only genome IDs.
    my @couples = map { [$_->[0], [$_->[0]]] } @$couplets;
    $stats->Add(genomeRead => scalar @couples);
    # Get the features of interest for these genomes.
    my $protList = P3Utils::get_data($p3, feature => \@filter, \@cols, genome_id => \@couples);
    # Collate them by genome ID, discarding the nulls.
    my %proteins;
    for my $prot (@$protList) {
        my ($genome, $name, $fid, $sequence, $product) = @$prot;
        if ($fid) {
            # We have a real feature, check the function.
            my $check = RoleParse::Checksum($product // '');
            if ($check ne $roleCheck) {
                $stats->Add(funnyProt => 1);
            } else {
                push @{$proteins{$genome}}, [$name, $sequence];
                $stats->Add(protFound => 1);
            }
        }
    }
    # Process the genomes one at a time.
    for my $genome (keys %proteins) {
        my @prots = @{$proteins{$genome}};
        $stats->Add(genomeFound => 1);
        if (scalar @prots > 1) {
            # Skip if we have multiple proteins.
            $stats->Add(multiProt => 1);
        } else {
            # Get the genome name and sequence, then check the length of the sequence.
            my ($name, $seq) = @{$prots[0]};
            my $len = length($seq);
            if ($len < $minlen) {
                $stats->Add(protTooShort => 1);
            } elsif ($len > $maxlen) {
                $stats->Add(protTooLong => 1);
            } else {
                # Here we have a good genome.
                print $gh "$genome\t$name\n";
                print $fh ">$genome\n$seq\n";
                $stats->Add(genomeOut => 1);
            }
        }
    }
}
print "All done.\n" . $stats->Show();