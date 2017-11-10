=head1 Fix Up a Package Directory Containing Binning Files

    package_fix.pl [options] targetDir

This script fixes up genome packages created from bins using files downloaded from a PATRIC binning run. The L<package_genome.pl>
script should already have been run on the genomes. For each package directory I<XXXXXX.X>, there should be three files in the
target directory.

=over 4

=item 1

I<XXXXXX.X>C<.scikit.eval.txt> becomes I<XXXXXX.X>C</EvalBySciKit/evaluate.out>

=item 2

I<XXXXXX.X>C<.scikit.txt> becomes I<XXXXXX.X>C</EvalBySciKit/evaluate.log>

=item 3

I<XXXXXX.X>C<.checkm.txt> becomes I<XXXXXX.X>C</EvalByCheckM/evaluate.log>

=back



=head2 Parameters

The sole positional parameter is the name of the target directory.

=cut

use strict;
use P3DataAPI;
use P3Utils;
use File::Copy::Recursive;

# Get the command-line options.
my $opt = P3Utils::script_opts('targetDir');
my ($targetDir) = @ARGV;
if (! $targetDir) {
    die "No target directory specified.";
} elsif (! -d $targetDir) {
    die "Target directory not found or invalid.";
}
# Read the files and directories in the target dir.
opendir(my $dh, $targetDir) || die "Could not open $targetDir: $!";
my (@packages, %outFiles);
while (my $member = readdir $dh) {
    if ($member =~ /^\d+\.\d+$/) {
        push @packages, $member;
    } elsif ($member =~ /\.txt$/) {
        $outFiles{$member} = 1;
    }
}
closedir $dh;
print scalar(@packages) . " package directories found.\n";
# Loop through the packages.
for my $pkg (@packages) {
    print "Checking package $pkg.\n";
    if ($outFiles{"$pkg.scikit.eval.txt"} && $outFiles{"$pkg.scikit.txt"} && $outFiles{"$pkg.checkm.txt"}) {
        print "Eval files found for $pkg.\n";
        # We have the files. Move them.
        File::Copy::Recursive::fmove("$targetDir/$pkg.scikit.eval.txt", "$targetDir/$pkg/EvalBySciKit/evaluate.out") || die "Could not move scikit.eval.txt: $!";
        File::Copy::Recursive::fmove("$targetDir/$pkg.scikit.txt", "$targetDir/$pkg/EvalBySciKit/evaluate.log") || die "Could not move scikit.txt: $!";
        File::Copy::Recursive::fmove("$targetDir/$pkg.checkm.txt", "$targetDir/$pkg/EvalByCheckm/evaluate.log") || die "Could not move checkm.txt: $!";
        print "Files moved.\n";
    }
}
