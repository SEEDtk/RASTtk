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


package BadLetters;

    use strict;
    use warnings;
    use ScriptUtils;
    use SeedUtils;

=head1 Search for Runs in a Sequence

This object provides utilities that help to search for single-nucleotide or single-amino-acid runs in a sequence.  The
fields of this object are as follows.

=over 4

=item gc

Genetic code table to use for translation.

=item prots

Reference to a list of protein runs.  Each should consist of the target letter repeated the minimum number of times.

=item bases

Reference to a list of DNA runs.  Each should consist of the target letter repeated the minimum number of times.

=back

=head2 Special Methods

=head3 new

    my $badLetters = BadLetters->new(%options);

Create a new, blank bad-letters object.  The target letter and length of each run is specified, along with any tuning options.

=over 4

=item options

A hash containing zero or more of the following keys.

=over 8

=item prots

Specifies the target protein runs.  The value is a reference to a hash that maps each protein letter to the minimum run size.

=item bases

Specifies the target DNA runs.  The value is a reference to a hash that maps each DNA letter to the minimum run size.

=item gc

The genetic code to use for protein translation.  The default is 11.

=back

=back

=cut

sub new {
    my ($class, %options) = @_;
    # Create the initial hashes.
    my (@prots, @bases);
    my %items = (prots => \@prots, bases => \@bases);
    # Loop through the incoming options, filling the hashes.
    for my $item (keys %items) {
        my $sourceH = $options{$item};
        if ($sourceH) {
            my $targetL = $items{$item};
            for my $letter (keys %$sourceH) {
                my $minString = $letter x $sourceH->{$letter};
                push @$targetL, $minString;
            }
        }
    }
    # Get the genetic code.
    my $codeTable = SeedUtils::genetic_code($options{gc} || 11);
    # Create the object.
    my $retVal = { prots => \@prots, bases => \@bases, gc => $codeTable };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}


=head2 Public Manipulation Methods

=head3 AddRule

    $badLetters->AddRule($type => $letter, $length);

Add a new run to the list of runs to find.

=over 4

=item type

The type of run-- C<prots> for an amino acid, C<bases> for a nucleic acid.

=item letter

The letter comprising the run.

=item length

The minimum length of the run.

=back

=cut

sub AddRule {
    my ($self, $type, $letter, $length) = @_;
    my $targetL = $self->{$type};
    push @$targetL, $letter x $length;
}


=head3 Scan

    my ($count, $longest) = $badLetters->Scan($fseq);

Scan the specified sequence for single-letter runs and return the number of runs found and the length of the longest one.

=over 4

=item fseq

The DNA sequence to scan.

=item RETURN

Returns a two-element list consisting of (0) the number of runs found and (1) the length of the longest run found.

=back

=cut

sub Scan {
    my ($self, $fseq) = @_;
    # Get the reverse sequence.
    my $rseq = SeedUtils::reverse_comp($fseq);
    # Get the translation table.
    my $codeTable = $self->{gc};
    # These will be the return values.
    my ($count, $longest) = (0, 0);
    for my $seq ($fseq, $rseq) {
        # Scan for proteins.
        my $prots = $self->{prots};
        if (scalar @$prots) {
            for my $frame (0, 1, 2) {
                my $aaString = SeedUtils::translate(\$seq, $frame, $codeTable);
                for my $run (@$prots) {
                    $count += sub_scan($aaString, $run, \$longest);
                }
            }
        }
        # Scan for DNA.
        my $bases = $self->{bases};
        for my $run (@$bases) {
            $count += sub_scan($seq, $run, \$longest);
        }
    }
    return ($count, $longest);
}

=head2 Private Utilities

=head3 sub_scan

    my $count = BadLetters::sub_scan($seq, $run, \$pLongest);

Count the number of occurrences of the specified run in the specified sequence and update the longest-run value.

=over 4

=item seq

The sequence to scan.

=item run

The minimum run sequence for which to scan.

=item pLongest

A reference to a scalar containing the length of the longest run found so far.

=item RETURN

Returns the number of runs found.

=back

=cut

sub sub_scan {
    my ($seq, $run, $pLongest) = @_;
    # So far we have not found any runs.
    my $retVal = 0;
    # Get the letter value.
    my $letter = substr($run, 0, 1);
    # Start at the first position.
    my $pos = index($seq, $run);
    while ($pos >= 0) {
        # Determine the run length.
        my $pos0 = $pos++;
        while (substr($seq, $pos, 1) eq $letter) { $pos++; }
        my $runLen = $pos - $pos0;
        if ($runLen > $$pLongest) {
            $$pLongest = $runLen;
        }
        $retVal++;
        $pos = index($seq, $run, $pos);
    }
    return $retVal;
}


1;