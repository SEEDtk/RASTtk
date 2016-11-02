#!/usr/bin/env perl
#
# Copyright (c) 2003-2015 University of Chicago and Fellowship
# for Interpretations of Genomes. All Rights Reserved.
#
# This file is part of the SEED Toolkit.
#
# The SEED Toolkit is free software. You can redistribute
# it and/or modify it under the terms of the SEED Toolkit
# Public License.
#
# You should have received a copy of the SEED Toolkit Public License
# along with this program; if not write to the University of Chicago
# at info@ci.uchicago.edu or the Fellowship for Interpretation of
# Genomes at veronika@thefig.info or download a copy from
# http://www.theseed.org/LICENSE.TXT.
#


use strict;
use warnings;
use Shrub;
use ScriptUtils;
use Data::Dumper;
use GenomeTypeObject;

=head1 show pegs on contigs

    ˜show_pegs_on_contigs --gto GTO < contigs > report

This tool is used to display PEGs that occur on a set of desgnated
contigs.

=head2 Parameters

## describe positional parameters

The command-line options are those found in L<Shrub/script_options> and
L<ScriptUtils/ih_options> plus the following.

=over 4

=i --GTO  a genome type object representing the bin

=back

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('', Shrub::script_options(),
			    ['gto=s',   'GenomeTypeObjet', { required => 1 }]);
my $gtoF   = $opt->gto;

my $gto = GenomeTypeObject->new({ file => $gtoF });
my $contigs = $gto->contigs;
my $features = $gto->features;

my %feature_locations;
my %functions;
my %contig_to_features;

foreach my $feature (@$features)
{
    my $locationL = $feature->{location};
    my $id = $feature->{id};

    my($contig,$beg) = @{$locationL->[0]};
    $functions{$id} = $feature->{function};
    push(@{$contig_to_features{$contig}},[$id,$functions{$id},$beg]);
}

while (defined($_ = <STDIN>))
{
    my $contig;
    if (($_ =~ /^(\S+)\t(\d+)/) && ($contig = $1) && $contig_to_features{$contig})
    {
	print $contig,"\t",$2,"\n";
	my $features = $contig_to_features{$contig};
	foreach my $feature (sort { ($a->[2] <=> $b->[2]) } @$features)
	{
	    print "\t",join("\t",@$feature),"\n";
	}
	print "\n";
    }
}

