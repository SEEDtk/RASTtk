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

=head1 Create Input File for RepGen-Based Completeness Computer

    p3x-merge-rep-files.pl [options] sim1 repFile1 sim2 repFile2 ... simN repFileN

This file will read in the role profiles of all the good genomes in PATRIC and then process it against representative-genome
analysis files to produce the input for the completeness process.  This input file (which is the output of this script)
is tab-delimited, and is divided into multiple groups.  Each group has the following format.

=over 4

=item 1

A header line containing a genome ID, a group name, a similarity threshold, and a seed protein sequence.

=item 2

One or more data lines, each consisting of a genome ID and a comma-delimited list of singly-occurring roles (the role profile).

=item 3

A double-slash delimiter.

=back

A genome will probably occur in multiple groups, since there will be repgen sets with different similarity thresholds and
all will involve the same genomes.

The memory footprint of this process is very high.

=head2 Parameters

The positional parameters are presented in pairs, each pair consisting of a similarity threshold followed by the name of a repgen
analysis file.  Each analysis file is tab-delimited with headers, and contains in each record (0) a genome ID, (1) a genome name,
(2) a representative genome ID, and (3) a score.  The score is ignored. A similarity threshold of 0
is used for a file based on taxonomic groupings rather than similarity.  These are required for the inevitable
genomes that are too far from the rest to produce a sufficiently large group.

The standard input should be a role profile file.  This is tab-delimited with headers, the first column containing a genome ID, the
second column the seed protein sequence, and the third and all subsequent columns (the number can vary from 150 to 2500) containing
the IDs of the singly-occurring roles.

The standard input can be overridden using the options in L<P3Utils/ih_options>.

Additional command-line options are the following.

=over 4

=item verbose

Display progress messages on STDERR.

=item min

The minimum acceptable size for an output group.  The default is C<20>.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use Stats;

$| = 1;

# Get the command-line options.
my $opt = P3Utils::script_opts(
    'sim1 repFile1 sim2 repFile2 ... simN repFileN',
    P3Utils::ih_options(),
    [ 'verbose|debug|v', 'show progress on STDERR' ],
    [ 'min|m=i', 'minimum number of genomes per group', { default => 20 } ]
);
my $stats = Stats->new();

# Get the options.
my $debug = $opt->verbose;
my $min   = $opt->min;

# Extract the positional parameters.
my @pairs;
for ( my $i = 0 ; $i < scalar @ARGV ; $i += 2 ) {
    my ( $sim, $file ) = @ARGV[ $i, $i + 1 ];
    if ( $sim =~ /\D/ ) {
        die "\"$sim\" does not appear to be a valid similarity threshold.";
    } elsif ( !$file ) {
        die "No file specified for similarity \"$sim\".";
    } elsif ( !-s $file ) {
        die "Repgen file $file is not found or invalid.";
    }
    push @pairs, [ $sim, $file ];
}

# Open the input file.
my $ih = P3Utils::ih($opt);

# Map of genomes to seed proteins.
my %prots;

# Map of group IDs to names.
my %names = ( 2 => 'Bacteria', 2157 => 'Archaea' );

# Map of genomes to role profiles.
my %roles;
print STDERR "Reading input file.\n";

# Skip the header line.
my $line   = <$ih>;
my $gCount = 0;
while ( !eof $ih ) {
    my $line = <$ih>;
    $line =~ s/[\r\n]+$//;

    # The "3" here insures all the roles are included in the third field.
    my ( $genome, $prot, $roles ) = split /\t/, $line, 3;
    $stats->Add( roleProfileIn => 1 );
    $gCount++;
    $prots{$genome} = $prot;
    $roles =~ tr/\t/,/;
    $roles{$genome} = $roles;
    print STDERR "$gCount role profiles read.\n"
      if $debug && $gCount % 1000 == 0;
}
print STDERR "$gCount total role profiles.\n" if $debug;

# Now we read through the repgen files.  Each file is represented by a sim,file pair.
for my $pair (@pairs) {
    my ( $sim, $file ) = @$pair;
    print STDERR "Processing RepGen-$sim set in file $file.\n" if $debug;

    # This hash will track the genomes in each repgen group.  Each group will map to a list of
    # genomes (we are guaranteed no duplicates in the input file).
    my %groups;
    open( my $gh, '<', $file ) || die "Could not open repgen file $file: $!";

    # Skip the header line.
    $line = <$gh>;

    # Process all the data lines.
    while ( !eof $gh ) {
        $line = <$gh>;
        my ( $genomeID, $name, $group ) = split /\t/, $line;
        if ( $sim > 0 && !$prots{$group} ) {
            print STDERR "WARNING: invalid group $group.\n" if $debug;
            $stats->Add( badGroupId => 1 );
        } elsif ( !$roles{$genomeID} ) {
            print STDERR "WARNING: invalid genome $genomeID.\n" if $debug;
            $stats->Add( badGenomeId => 1 );
        } else {
            if ( $genomeID eq $group ) {
                $stats->Add( groupNameStored => 1 );
                $names{$genomeID} = "R$sim ($name)";
            }
            push @{ $groups{$group} }, $genomeID;
            $stats->Add( "genome$sim-saved" => 1 );
        }
    }
    print STDERR scalar( keys %groups ) . " groups found in repgen file.\n"
      if $debug;

    # Now we loop through the groups, writing each group of 20 or more.
    for my $group ( keys %groups ) {
        my $genomes = $groups{$group};
        $stats->Add( "group$sim-found" => 1 );
        my $size = scalar @$genomes;
        if ( $size >= $min ) {
            $stats->Add( "group$sim-kept" => 1 );
            print STDERR "Writing $sim-group $group with $size genomes.\n"
              if $debug;

            # First the header, that identifies the group.
            my $name = $names{$group};
            if ( !$name ) {
                print STDERR "WARNING: Group $group is nameless.\n"
                  if $debug;
                $stats->Add( "namelessGroup" => 1 );
            }
            P3Utils::print_cols( [ $group, $name, $sim, $prots{$group} ] );

            # Now all the genomes.
            for my $genome (@$genomes) {
                $stats->Add( "genome$sim-out" => 1 );
                P3Utils::print_cols( [ $genome, $roles{$genome} ] );
            }

            # Finally the trailer.
            P3Utils::print_cols( ['//'] );
        }
    }
}
print STDERR "All done.\n" . $stats->Show() if $debug;
