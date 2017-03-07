use gjonewicklib;
use Carp;
use Data::Dumper;
use strict;

=head1 Select a set a subtree of a tree. Input is two genome ids, these are used to select the subtree.

    select-from-subtree genomeid1 genome-d2 < tree > GenomeSet


=head2 Parameters 
This tool takes 2 command line arguments, genomeID1 and genomeID2. These are used to select a subtree from the input tree. The output is the tips (genome ids) of the subtree.

=cut


my $usage = "usage: GenomeId1 GenomeId2 < Tree > GenomeSet\n";
my($g1,$g2);
(
 ($g1 = shift @ARGV) &&
 ($g2 = shift @ARGV)
) 
    || die $usage;

print "genome.genome_id\n";         #Add a header for subsequent P3 commands

my @tree = <STDIN>;
( my $tree = &gjonewicklib::parse_newick_tree_str(join("",@tree)))
    || die "could not parse the tree";
if (&gjonewicklib::newick_is_unrooted($tree))
{
    $tree = &gjonewicklib::reroot_newick_to_midpoint_w( $tree );
    print STDERR "rerooted to midpoint\n";
}
&gjonewicklib::newick_is_valid($tree) || die "invalid newick tree";

my $leaves = {};
&leaves_in_subtree($tree,$g1,$g2,$leaves);
my @labels = sort keys(%$leaves);
foreach my $label (@labels)
{
    if ($leaves->{$label} != 1)
    {
	die "$label occurs more than once";
    }
    else
    {
	if ($label =~ /\b(\d+\.\d+)$/)
	{
	    print "$1\n";
	}
    }
}

sub leaves_in_subtree {
    my($tree,$g1,$g2,$leaves) = @_;

    my $desc = gjonewicklib::newick_desc_ref($tree);
    if (defined($desc) && (@$desc > 0))
    {
	foreach my $node (@$desc)
	{
	    my $in1 = &in($g1,$node);
	    my $in2 = &in($g2,$node);
	    if ($in1 && $in2)
	    {
		&leaves_in_subtree($node,$g1,$g2,$leaves);
	    }
	    elsif ($in1 || $in2)
	    {
		&gather_leaves($node,$leaves);
	    }
	}
    }
 }

sub gather_leaves {
    my($node,$leaves) = @_;

    my $desc = gjonewicklib::newick_desc_ref($node);
    if ((! $desc) || (@$desc == 0))
    {
	my $label = &gjonewicklib::newick_lbl($node);
	if ($label)
	{
	    $leaves->{$label}++;
	}
    }
    else
    {
	foreach my $desc1 (@$desc)
	{
	    &gather_leaves($desc1,$leaves);
	}
    }
}


sub match {
    my($g,$node) = @_;

    my $label = &gjonewicklib::newick_lbl($node);
    return ($label && ($label =~ /(\d+\.\d+)$/) && ($g eq $1));
}

sub in {
    my($g,$node) = @_;

    my $label = &gjonewicklib::newick_lbl($node);
    if (&match($g,$node))
    {
	return 1;
    }
    
    my $desc = gjonewicklib::newick_desc_ref($node);
    if (defined($desc) && (@$desc > 0))
    {
	my $i;
	for ($i=0; ($i < @$desc) && (! &in($g,$desc->[$i])); $i++) {}

	if ($i < @$desc)
	{
	    return 1;
	}
    }
    return 0;
}

