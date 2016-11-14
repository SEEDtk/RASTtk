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
use ScriptUtils;
use Data::Dumper;
use GenomeTypeObject;

=head1 find_bad_contigs in bin

    find_bad_contigs_in_bin --gto GTO -r RoleEvals

This tool is used to locate contigs that should probably be deleted from a bin.
It uses an evaluation by predictors to

    1. find the "good roles" (roles for which the predicted and actual agree)
    2. find the "good contigs" (contigs containing at least one good role)
    3. find "bad contigs" (those that are not good)
    4. print out the bad contigs ids and lengths

=head2 Parameters

## describe positional parameters

The command-line options are the following.

=over 4

=item GTO

a genome type object representing the bin

=item r

a 3-column table containing [RoleId,PredictedValue,ActualValue]

=item ids_to_use

a 2-column of [role-id,role] defining the set of accurate roles

=back

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('',
                            ['gto=s',   'GenomeTypeObjet', { required => 1 }],
                            ['r=s',     'Role Evaluation File'],
                            ['i=s',     'usable ids mapped to roles', { required => 1 }]
                           );
my $gtoF   = $opt->gto;
my $rolesF = $opt->r;
my $idF    = $opt->i;

open(IDS,"<$idF") || die "cannot open $idF";
my %role_to_role_id = map { ($_ =~ /^(\S+)\t(\S.*\S)/) ? ($2 => $1) : () } <IDS>;
close(IDS);

open(ROLES,"<$rolesF") || die "could not open $rolesF";
my %roles = map { ($_ =~ /^([^\t]+)\t(\S+)\t(\S+)/) ? ($1 => [$2,$3]) : () } <ROLES>;
close(ROLES);

my %good_roles = map { ($_ => 1) }  grep { $roles{$_}->[0] == $roles{$_}->[1] } keys(%roles);

my $gto = GenomeTypeObject->new({ file => $gtoF });
my $contigs = $gto->contigs;
my $features = $gto->features;
my %good_contigs;

foreach my $feature (@$features)
{
    my $locationL = $feature->{location};
    my $function = $feature->{function};
    foreach my $role (&SeedUtils::roles_of_function($function))
    {
        my $rid = $role_to_role_id{$role};
        if ($rid && $good_roles{$rid})
        {
            foreach my $loc (@$locationL)
            {
                my $contig = $loc->[0];
                $good_contigs{$contig} = 1;
            }
        }
    }
}

my %bad_contigs;
my $goodN = keys(%good_contigs);
print STDERR "good contigs = $goodN\n";
my @contigs = $gto->contigs;
print STDERR "all contigs = ",scalar @contigs,"\n";
my $badN;
my $good_sz;
my $bad_sz;

foreach my $tuple (@contigs)
{
    my $id = $tuple->{id};
    my $dna = $tuple->{dna};
    if (! $good_contigs{$id})
    {
        print join("\t",($id,length($dna))),"\n";
        $badN++;
        $bad_sz += length($dna);
    }
    else
    {
        $good_sz += length($dna);
    }
}
print STDERR "bad = $badN\n";
print STDERR "good size = $good_sz\n";
print STDERR "bad size = $bad_sz\n";
my $bad_frac = $bad_sz / $good_sz;
print STDERR "bad frac = $bad_frac\n";
