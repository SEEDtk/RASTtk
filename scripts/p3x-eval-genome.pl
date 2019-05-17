=head1 Evaluate a Single Genome

    p3x-eval-genome.pl [options] genome outFile outHtml

This is an alternative to L<p3x-eval-genomes.pl> for the case where a single genome is being evaluated.
The input can be a PATRIC genome ID or a GTO.

The output is tab-delimited, containing the main scores in the order (0) coarse consistency, (1) fine
consistency, (2) completeness, (3) contamination, and (4) scoring group name.

=head2 Parameters

The positional parameters are the genome ID or the name of a L<GenomeTypeObject> file containing the genome,
the name of the output file for the evaluation tools, and the name of the output web page.

Additional command-line options are as follows:

=over 4

=item ref

The PATRIC ID of a reference genome to use for comparison.  If specified, the C<deep> option is implied.

=item deep

If specified, the genome is compared to a reference genome in order to provide more details on problematic roles.
If this option is specified and C<ref> is not specified, a reference genome will be computed.

=item checkDir

The name of the directory containing the reference genome table and the completeness data files. The default
is C<CheckG> in the SEEDtk global data directory.

=item predictors

The name of the directory containing the role definition files and the function predictors for the consistency
checking. The default is C<FunctionPredictors> in the SEEDtk global data directory.

=item template

The name of the template file. The default is C<p3_code/lib/BinningReports/webdetails.tt> in the SEEDtk module directory.

=item external

If specifed, the incoming genome is presumed to be external, and no contig links will be generated on the web page.

=item binned

If specified, the incoming genome is presumed to have external contig IDs which are stored in the description fields of
the sequences in PATRIC.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use EvalHelper;
use File::Copy::Recursive;

# Get the command-line options.
my $opt = P3Utils::script_opts('genome outFile outHtml',
        ['ref|r=s', 'reference genome ID (implies deep)'],
        ['deep', 'if specified, the genome is compared to a reference genome for more detailed analysis'],
        ['checkDir=s', 'completeness data directory', { default => "$FIG_Config::p3data/CheckG" }],
        ['predictors=s', 'function predictors directory', { default => "$FIG_Config::p3data/FunctionPredictors" }],
        ['template=s', 'template for web pages', { default => "$FIG_Config::mod_base/p3_code/lib/BinningReports/webdetails.tt" }],
        ['external', 'the genome is not currently installed in PATRIC'],
        ['binned', 'the genome contig IDs are user-suppled, not PATRIC-generated'],
        );
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# Get the input parameters.
my ($genome, $outFile, $outHtml) = @ARGV;
if (! $genome) {
    die "No input genome specified.";
} elsif (! $outFile) {
    die "No output data file specified.";
} elsif (($opt->ref || $opt->deep) && ! $outHtml) {
    die "No output web page file specified.";
}
# Call the main processor.
my $geo = EvalHelper::Process($genome, 'ref' => $opt->ref, deep => $opt->deep, checkDir => $opt->checkdir, predictors => $opt->predictors,
    p3 => $p3, outFile => $outFile, outHtml => $outHtml, template => $opt->template, external => $opt->external, binned => $opt->binned);
# Print the results.
print join("\t", $geo->scores) . "\n";
