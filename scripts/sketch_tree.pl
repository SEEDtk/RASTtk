#!/usr/bin/env perl -w
#
#  Make a printer plot of a newick tree file.
#

use strict;
use gjonewicklib;
use Data::Dumper;

my $usage = <<"End_of_Usage";
sketch_tree -

A program to make a printer plot of a Newick tree.

Usage:  sketch_tree  [options]  < tree  > ascii_sketch

    options:
        -a         Reorder taxa in aesthetic tree order
        -c         Collapse zero-length branches
        -f fasta   Relabel tips from descriptions in fasta sequence file
        -h         Use HTML encoded line drawing set
        -i         Omit identifiers (first word) when relabeling tips
        -k keep    Keep only the taxa listed (one per line) in the file keep
        -l table   Relabel tips from tab delimited from -> to table
        -m         Use midpoint rooting
        -o omit    Delete the taxa listed (one per line) in the file omit
        -t         Print tree comment as title
        -u         Use UTF8 encoded line drawing set
        -w width   Width of tree (without labels) (D=64)
        -x min_dx  Minimum horizontal space between consecutive nodes (D=2)
        -y dy      Vertical separation of consecutive tips (D=2)

End_of_Usage

my ( $width, $min_dx, $dy );

my $TREE;
my $aesthetic;
my $collapse;
my $midpoint;
my $relabel;
my $skip_id;
my $title;
my $utf8;
my $html;

my $fastafile = '';
my $tablefile = '';
my $treefile  = '';
my $keepfile  = '';
my $omitfile  = '';

while ( @ARGV && $ARGV[0] =~ /^-/ )
{
    my $flag = shift @ARGV;
    if ( $flag =~ m/^-[achimtu]+$/ )
    {
        $flag =~ /a/ and $aesthetic = 1;
        $flag =~ /c/ and $collapse  = 1;
        $flag =~ /h/ and $html      = 1;
        $flag =~ /i/ and $skip_id   = 1;
        $flag =~ /m/ and $midpoint  = 1;
        $flag =~ /t/ and $title     = 1;
        $flag =~ /u/ and $utf8      = 1;
    }
    elsif ( $flag =~ s/^-f *=? *// )
    {
        $fastafile = $flag || shift @ARGV or die "Missing value for -f\n$usage\n";
        $relabel = 1;
    }
    elsif ( $flag =~ s/^-k *=? *// )
    {
        $keepfile = $flag || shift @ARGV or die "Missing value for -k\n$usage\n";
    }
    elsif ( $flag =~ s/^-l *=? *// )
    {
        $tablefile = $flag || shift @ARGV or die "Missing value for -l\n$usage\n";
        $relabel = 1;
    }
    elsif ( $flag =~ s/^-o *=? *// )
    {
        $omitfile = $flag || shift @ARGV or die "Missing value for -o\n$usage\n";
    }
    elsif ( $flag =~ s/^-w *=? *// )
    {
        $width     = $flag || shift @ARGV or die "Missing value for -w\n$usage\n"
    }
    elsif ( $flag =~ s/^-x *=? *// )
    {
        $min_dx    = $flag || shift @ARGV or die "Missing value for -x\n$usage\n"
    }
    elsif ( $flag =~ s/^-y *=? *// )
    {
        $dy        = $flag || shift @ARGV or die "Missing value for -y\n$usage\n"
    }
    else
    {
        die "Bad flag: $flag\n$usage\n"
    }
}

$min_dx = ( $html || $utf8 ) ? 1 : 2 if ! defined( $min_dx );
$dy     = ( $html || $utf8 ) ? 1 : 2 if ! defined( $dy );
$width  = 64                         if ! $width;


my %label = ();
if ( $fastafile )
{
    -f $fastafile or die "Relabeling fasta file ($fastafile) not found\n";
    open( FASTA, "<$fastafile" ) || die "Could not open fasta relabeling file\n";
    while ( defined( $_ = <FASTA> ) )
    {
        s/^>\s*// or next;
        chomp;
        my ( $id, $def ) = m/^(\S+)\s+(\S.*)$/;
        if ( $id && $def )
        {
            ( my $id2 = $id ) =~ s/_/ /g;
            $label{ $id2 } = $skip_id ? $def : "$id $def";
        }
    }
    close( FASTA );
}

my @keep;
if ( $keepfile )
{
    -f $keepfile or die "Keep id file ($keepfile) not found\n";
    open KEEP, "<$keepfile" or print STDERR "Could not open file '$keepfile'\n" and exit;
    @keep = map { ( m/(\S+)/ ) } <KEEP>;
    close KEEP;
    @keep or print STDERR "No ids found in keep id file '$keepfile'." and exit;
}

my @omit;
if ( $omitfile )
{
    -f $omitfile or die "Omit id file ($omitfile) not found\n";
    open OMIT, "<$omitfile" or print STDERR "Could not open file '$omitfile'\n" and exit;
    @omit = map { ( m/(\S+)/ ) } <OMIT>;
    close OMIT;
}

if ( $tablefile )
{
    -f $tablefile or die "Relabeling table file ($tablefile) not found\n";
    open( TABLE, "<$tablefile" ) || die "Could not open relabeling table file\n";
    while ( defined( $_ = <TABLE> ) )
    {
        chomp;
        my ( $old, $new ) = split /\t/;
        if ( $old && $new )
        {
            $label{ $old } = $new;
            if ( $old =~ s/_/ /g ) { $label{ $old } = $new }
        }
    }
    close( TABLE );
}

foreach my $tree0 ( gjonewicklib::read_newick_trees( $ARGV[0] ) )
{
    $tree0 or die "Could not parse tree.\n\n$usage\n";

    $title = gjonewicklib::newick_c1( $tree0 ) if $title;
    $title = $title->[0] if defined $title && ref $title eq 'ARRAY';

    if ( @omit )
    {
        my %omit = map { $_ => 1 } @omit;
        @keep = grep { ! $omit{ $_ } } newick_tip_list( $tree0 );
    }

    my $tree1 = $midpoint  ? gjonewicklib::reroot_newick_to_midpoint_w( $tree0 )   : $tree0;
    my $tree2 = @keep      ? gjonewicklib::rooted_newick_subtree( $tree1, \@keep ) : $tree1;
    my $tree3 = $aesthetic ? gjonewicklib::aesthetic_newick_tree( $tree2 )         : $tree2;
    my $tree4 = $relabel   ? gjonewicklib::newick_relabel_tips( $tree3, \%label )  : $tree3;
    gjonewicklib::collapse_zero_length_branches( $tree4 ) if $collapse;

    my $opts = { dy     => $dy,
                 min_dx => $min_dx,
                 width  => $width,
               };
    $opts->{ chars } = 'html' if $html;
    $opts->{ chars } = 'utf8' if $utf8;

    print "\n";
    print $title, "\n" if defined $title;
    $title = $title->[0] if $title && ref $title eq 'ARRAY';
    gjonewicklib::printer_plot_newick( $tree4, \*STDOUT, $opts );
    print "\n";
}

exit;
