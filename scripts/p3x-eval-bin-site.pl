=head1 Create Master Web Site for Bin Evaluation Pages

    p3x-eval-bin-site.pl [options] binDir webDir

This will create a master web site in the specified location from all the completed bin evaluations in a specified binning sample directory.
It will look for an C<Eval> subdirectory under the sample directory itself, parse the C<index.tbl>, and move all the HTML files to a web
directory with the same name as the sample under the master web directory. In addition, a C<good.tbl> file will be created in the output
directory that lists all the good genomes.

=head2 Parameters

The positional parameters are the name of the directory containing the binned samples and the name of the output web directory.

The command-line options are those given in L<BinningReports/template_options> plus the following.

=over 4

=item clear

If specified, then the output directory can already exist, and will be cleared prior to building the site.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use File::Copy::Recursive;
use Template;
use BinningReports;

$| =1;
# Get the command-line options.
my $opt = P3Utils::script_opts('binDir webDir', BinningReports::template_options(),
        ['clear', 'clear output directory before starting']
        );
# Get the parameters.
my ($binDir, $webDir) = @ARGV;
if (! $binDir) {
    die "No input directory specified.";
} elsif (! -d $binDir) {
    die "$binDir is missing or invalid.";
} elsif (! $webDir) {
    die "No output directory specified.";
} elsif (! -d $webDir) {
    print "Creating $webDir.\n";
    File::Copy::Recursive::pathmk($webDir) || die "Could not create $webDir: $!";
} elsif ($opt->clear) {
    print "Erasing $webDir.\n";
    File::Copy::Recursive::pathempty($webDir) || die "Could not erase $webDir: $!";
} else {
    die "$webDir already exists.";
}
# Set up the templates.
my ($prefix, $suffix) = BinningReports::build_strings($opt);
# These structures will contain the data for the master index page.
my @s;
my %master = (bad_count => 0, good_count => 0, sample_count => 0);
# These will be the output files for the genome lists.
open(my $gh, ">$webDir/good.tbl") || die "Could not open good.tbl: $!";
open(my $ah, ">$webDir/all.tbl") || die "Could not open all.tbl: $!";
print $gh "genome_id\tgenome_name\n";
print $ah "genome_id\tgenome_name\n";
# Get all the completed samples in the input directory.
print "Searching $binDir.\n";
opendir(my $dh, $binDir) || die "Could not open $binDir: $!";
my @samples = sort grep { -s "$binDir/$_/Eval/index.html" } readdir $dh;
closedir $dh;
print scalar(@samples) . " completed samples found in $binDir.\n";
# Loop through the sample directories.
for my $sample (@samples) {
    print "Processing $sample.\n";
    # Compute the input and output directories for this sample.
    my $inDir = "$binDir/$sample/Eval";
    my $outDir = "$webDir/$sample";
    # Initialize the counters.
    my ($good, $bad, $total) = (0, 0, 0);
    open(my $ih, "<$inDir/index.tbl") || die "Could not open index file for $sample: $!";
    my (undef, $cols) = P3Utils::find_headers($ih, indexFile => 'Bin ID', 'Bin Name', 'Good');
    while (! eof $ih) {
        my ($binID, $binName, $goodFlag) = P3Utils::get_cols($ih, $cols);
        # Copy this bin's HTML file.
        File::Copy::Recursive::fcopy("$inDir/$binID.html", "$outDir/$binID.html") || die "Could not copy $binID for $sample: $!";
        # Count the bin.
        $total++;
        if ($goodFlag) {
            $good++;
            print $gh "$binID\t$binName\n";
        } else {
            $bad++;
        }
        print $ah "$binID\t$binName\n";
    }
    # Copy the index file.
    File::Copy::Recursive::fcopy("$inDir/index.html", "$outDir/index.html") || die "Could not copy index for $sample: $!";
    # Record the sample.
    push @s, { sample => $sample, good => $good, bad => $bad, total => $total };
    $master{good_count} += $good;
    $master{bad_count} += $bad;
    $master{sample_count}++;
}
# Create the master page from the template.
print "Creating master index.\n";
$master{samples} = [ sort { $b->{good} <=> $a->{good} or $b->{total} <=> $a->{total} or $a cmp $b } @s];
my $templateEngine = Template->new(ABSOLUTE => 1);
my $middle = '';
$templateEngine->process($opt->templates . "/master.tt", \%master, \$middle) || die "Error in HTML template: " . $templateEngine->error();
open(my $oh, ">$webDir/index.html") || die "Could not create master index: $!";
print $oh $prefix . "<title>Master Bin Job Index</title></head></body>" . $middle . $suffix;

