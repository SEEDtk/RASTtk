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
use FIG_Config;
use ScriptUtils;
use SeedUtils;
use BasicLocation;
use GenomeTypeObject;
use crispr;

=head1 Report on CRISPRs in a GTO

    gto_crisprs.pl [ options ]

This script reads a L<GenomeTypeObject> from the standard input and produces a report on the CRISPR arrays
found within it. For each such array, it will list the overall array location, the spacers, the repeat regions,
and the associated proteins.

An exact match is used for the roles of the associated proteins, so punctuation and capitalization differences
may cause a role to be missed if the GTO was not annotated by RAST.

Status messages are displayed on the standard error output, so this should be kept separate.

=head2 Parameters

There are no positional parameters

The command-line options are those found in L<ScriptUtils/ih_options> (to specify the standard input containing the GTO
in JSON format) plus the following.

=over 4

=item roles

If specified, a tab-delimited file containing the names (descriptions) of the associated-protein roles in its last column.
If no file is specified, a default list will be used.

=item gap

Longest permissible gap between a CRISPR array and a feature for the feature to be considered associated.

=back

=cut

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('', ScriptUtils::ih_options(),
        ['roles=s', 'CAS role file'],
        ['gap=i', 'longest allowable gap between a CRISPR and an associated CAS feature', { default => 30000 }],
        );
# Get the gap size.
my $gap = $opt->gap;
print STDERR "Specified neighborhood gap is $gap.\n";
# Get the role list.
my %casRoles;
if ($opt->roles) {
    open(my $rh, '<', $opt->roles) || die "Could not open role file: $!";
    while (! eof $rh) {
        my $line = <$rh>;
        if ($line =~ /.+([^\t])+$/) {
            $casRoles{$1} = 1;
        }
    }
} else {
    %casRoles = map { $_ => 1 } role_list();
}
print STDERR scalar(keys %casRoles) . " roles found in CAS list.\n";
# Open the input file.
my $ih = ScriptUtils::IH($opt->input);
# Read in the GTO. The create_from_file method blesses the object and indexes it.
my $gto = GenomeTypeObject->create_from_file($ih);
# Run through the features.
my $featureList = $gto->{features};
my @foundProteins;
for my $feature (@$featureList) {
    my $func = $feature->{function};
    my @roles = grep { $casRoles{$_} } SeedUtils::roles_of_function($func);
    if (scalar @roles) {
        push @foundProteins, $feature;
    }
}
print STDERR scalar(@foundProteins) . " CAS features found in genome.\n";
# Now loop through the contigs.
my @contigList = map { [$_->{id}, '', $_->{dna}] } @{$gto->{contigs}};
print STDERR scalar(@contigList) . " contigs found in genome.\n";
my $crisprList = crispr::find_crisprs(\@contigList);
#  @crisprs = ( [ $loc, $consensus, \@repeats, \@spacers ], ...)
#  @repeats = ( [ $loc, $repseq ], ... )
#  @spacers = ( [ $loc, $spcseq ], ... )
#  $loc     = [ [ $contig, $beg, $dir, $len ], ... ]
print STDERR scalar(@$crisprList) . " CRISPR arrays found in genome.\n\n\n";
my $idx = 0;
for my $crispr (@$crisprList) {
    # Compute the CRISPR array locus.
    my ($locData, $consensus, $repeats, $spacers) = @$crispr;
    my $loc = BasicLocation->new(@$locData);
    ++$idx;
    print "$idx. " . join(', ', $loc->String, "consensus $consensus",
        scalar(@$spacers) . " spacers") . ".\n\n";
    # Display the repeats.
    print "* REPEATS\n------------\n";
    show_dna_list($repeats);
    # Display the spacers.
    print "* SPACERS\n------------\n";
    show_dna_list($spacers);
    # Now get the features in the neighborhood.
    my $header = "* CAS PROTEINS\n------------\n";
    for my $feature (@foundProteins) {
        my @locs = @{$feature->{location}};
        my $locItem = pop @locs;
        while ($locItem) {
            my $floc = BasicLocation->new($locItem);
            my $fGap = $loc->Distance($floc);
            if (defined $fGap && $fGap <= $gap) {
                # This is a neighborhood CAS protein. Print it.
                if ($header) {
                    print $header;
                    undef $header;
                }
                print "$feature->{id} " . $floc->String . ": $feature->{function}\n";
                # Stop the loop.
                undef $locItem;
            } else {
                # Not a neighboring protein. Keep looking.
                $locItem = pop @locs;
            }
        }
    }
    # No nearby features? Print a message.
    if ($header) {
        print "No nearby CAS proteins found.\n";
    }
    # Space before the next CRISPR.
    print "\n\n";
}

# Display a list of location,DNA pairs.
sub show_dna_list {
    my ($list) = @_;
    for my $item (@$list) {
        my ($locData, $dna) = @$item;
        my $loc = BasicLocation->new(@$locData);
        print $loc->String . ": $dna\n";
    }
    print "\n";
}

# Return the default CAS role list.
sub role_list {
    my @retVal =   ("DEDDh 3'-5' exonuclease domain",
                    "CRISPR-associated endonuclease Cas9",
                    "CRISPR-associated protein Cas1",
                    "CRISPR-associated protein Cas2",
                    "CRISPR-associated helicase Cas3",
                    "CRISPR-associated helicase Cas3 HD",
                    "CRISPR-associated RecB family exonuclease Cas4a",
                    "CRISPR-associated RecB family exonuclease Cas4",
                    "CRISPR-associated protein Cas5",
                    "CRISPR-associated protein, Cas5a family",
                    "CRISPR-associated protein, Cas5d family",
                    "CRISPR-associated protein, Cas5e family",
                    "CRISPR-associated protein, Cas5h family",
                    "CRISPR-associated protein, Cas5t family",
                    "CRISPR-associated endoribonuclease Cas6",
                    "CRISPR-associated negative autoregulator Cas7/Cst2",
                    "CRISPR-associated protein Cas7",
                    "CRISPR-associated protein, Csa1 family",
                    "CRISPR-associated protein Csa2",
                    "CRISPR-associated protein, Csa2 family",
                    "CRISPR-associated protein Csa5",
                    "CRISPR-associated protein, Csa5 family",
                    "CRISPR-associated protein Csb1",
                    "CRISPR-associated protein Csb2",
                    "CRISPR-associated RAMP protein, Csb3 family",
                    "CRISPR-associated RAMP protein, Csb3a family",
                    "CRISPR-associated RAMP protein, Csb3b family",
                    "CRISPR-associated protein Csc1",
                    "CRISPR-associated protein Csc2",
                    "CRISPR-associated protein, Csd1 family",
                    "CRISPR-associated protein, Csd2/Csh2 family",
                    "CRISPR-associated protein, CT1972 family",
                    "CRISPR-associated protein, Cse1 family",
                    "CRISPR-associated protein, Cse2 family",
                    "CRISPR-associated protein, Cse3 family",
                    "CRISPR-associated protein, Cse4 family",
                    "CRISPR-associated protein Csf1",
                    "CRISPR-associated protein Csf2",
                    "CRISPR-associated protein Csf3",
                    "CRISPR-associated protein Csf4",
                    "CRISPR-associated protein, Csh1 family",
                    "CRISPR-associated protein, Csm1 family",
                    "CRISPR-associated protein, Csm2 family",
                    "CRISPR-associated RAMP Csm3",
                    "CRISPR-associated RAMP protein, Csm4 family",
                    "CRISPR-associated protein, Csm5 family",
                    "CRISPR-associated protein Csm6",
                    "CRISPR-associated protein, Csn2 family",
                    "CRISPR-associated protein, Csn2a family",
                    "CRISPR-associated protein, Cst1 family",
                    "CRISPR-associated protein Csx1",
                    "CRISPR-associated protein, Csx3 family",
                    "CRISPR-associated RAMP, Csx10 family",
                    "CRISPR-associated protein Csx15",
                    "CRISPR-associated protein Csx16",
                    "CRISPR-associated protein Csx17",
                    "CRISPR-associated protein CsaX",
                    "Retron-type RNA-directed DNA polymerase (EC 2.7.7.49)",
                    "CRISPR-associated RAMP Cmr1",
                    "CRISPR-associated RAMP Cmr2",
                    "CRISPR-associated RAMP Cmr3",
                    "CRISPR-associated RAMP Cmr4",
                    "CRISPR-associated RAMP Cmr5",
                    "CRISPR-associated RAMP Cmr6",
                    "CRISPR-associated protein APE2256",
                    "CRISPR-associated protein NE0113",
                    "CRISPR-associated protein TM1812",
                    "CRISPR-associated protein DxTHG",
                    "CRISPR-associated protein Cas02710"
                );
    return @retVal;
}
