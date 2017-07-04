=head1 Generate Clusters From Pairs Using Transitive Closure

    p3-generate-clusters.pl [options] col1 col2

This script reads in a tab-delimited file representing pairs of objects and generates a transitive closure to
create clusters.

The clusters will be output one per line, with a specified delimiter between elements. The default delimiter is C<::>,
but you can specify a tab, a space, or any character sequence that doesn't appear in any element of the pair.

=head2 Parameters

The positional parameters are the names or 1-based indices of the two columns containing the object names. So, an invocation of

    p3-generate_clusters 1 2

would indicate the first two columns contain the paired object names. An invocation of

    p3-generate-clusters role1 role2

would process the output from L<p3-generate-close-roles.pl>.

The standard input can be overwritten using the options in L<P3Utils/ih_options>.

Additional command-line options are as follows.

=over 4

=item delim

The delimiter to use between object names. The default is C<::>. Specify C<tab> for tab-delimited output, C<space> for
space-delimited output, or C<comma> for comma-delimited output.

=item title

Title to give to the output column. The default is <cluster>.

=back

=cut

use constant DELIMS => { space => ' ', tab => "\t", comma => ',', '::' => '::' };
use strict;
use P3Utils;

# Get the command-line options.
my $opt = P3Utils::script_opts('col1 col2', P3Utils::ih_options(),
        ['delim=s', 'delimiter to place between object names', { default => '::' }],
        ['title|t=s', 'output column title', { default => 'cluster'} ]
        );
# Verify the positional parameters.
my ($col1, $col2) = @ARGV;
if (! $col1 || ! $col2) {
    die "Two column names/indices are required.";
}
# Compute the delimiter.
my $delim = DELIMS->{$opt->delim} // $opt->delim;
# Open the input file.
my $ih = P3Utils::ih($opt);
# Find the object name columns.
my ($headers, $cols) = P3Utils::find_headers($ih, pair => $col1, $col2);
# This hash will map each object name to its group number.
my %objectMap;
# This list contains the groups.
my @groupList;
# Loop through the input.
while (! eof $ih) {
    # Get the object names for this row.
    my ($obj1, $obj2) = P3Utils::get_cols($ih, $cols);
    # Make sure they are in the same group.
    my $group1 = $objectMap{$obj1};
    my $group2 = $objectMap{$obj2};
    if (defined $group1 && ! defined $group2) {
        # Object 2 is new, belongs in group 1.
        $objectMap{$obj2} = $group1;
        push @{$groupList[$group1]}, $obj2;
    } elsif (! defined $group1 && defined $group2) {
        # Object 1 is new, belongs in gorup 2.
        $objectMap{$obj1} = $group2;
        push @{$groupList[$group2]}, $obj1;
    } elsif (! defined $group1 && ! defined $group2) {
        # Both are new. Create a new group.
        $group1 = scalar @groupList;
        push @groupList, [$obj1, $obj2];
        $objectMap{$obj1} = $group1;
        $objectMap{$obj2} = $group1;
    } elsif ($group1 != $group2) {
        # Both are old. Merge group2 into group1.
        my $group2Objects = $groupList[$group2];
        for my $obj (@$group2Objects) {
            $objectMap{$obj} = $group1;
        }
        push @{$groupList[$group1]}, @$group2Objects;
        $groupList[$group2] = [];
    }
}
# Delete the empty groups and sort from largest to smallest.
my @sorted = sort { scalar(@$b) <=> scalar(@$a) } grep { scalar(@$_) } @groupList;
# Output the groups.
print $opt->title . "\n";
for my $group (@sorted) {
    print join($delim, @$group) . "\n";
}