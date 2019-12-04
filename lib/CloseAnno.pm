#
# Copyright (c) 2003-2019 University of Chicago and Fellowship
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


package CloseAnno;

    use strict;
    use warnings;
    use GenomeTypeObject;
    use BlastUtils;
    use Stats;
    use SeedUtils qw();
    use Hsp;
    use FIG_Config;
    use FastA;

=head1 Close-Genome Annotation Object

This object is used to manage close-genome annotation.  Close-genome annotation is
performed by BLASTing pegs from close genomes against a target.  Each target hit
is identified by its stop codon, and the longest hit with the same stop codon is
taken as the best one.  The start is then identified and the location is annotated
with the role of the best hit.

The fields in this object are as follows.

=over 4

=item workDir

The name of a working directory used for temporary files.

=item hits

Reference to a hash mapping each stop location found to a 2-tuple containing (0) the
start location and (1) the L<Hsp> of its best hit.

=item maxE

The maximum allowable e-value on a blast hit.

=item minlen

The minimum fraction of the query sequence length that must be found in the blast
hit.

=item maxHits

The maximum number of BLAST hits to return for each query sequence.

=item target

The blast database for the target.  This is a FASTA file name.  If the ancillary
blast files do not exist, they will be created in the same directory location.

=item stats

A L<Stats> object for tracking statistics.

=item log

An open file handle for progress message output, or C<undef> if no progress
message output is desired.

=item contigs

Reference to a hash that contains the DNA sequence of each contig in the target
FASTA, keyed by contig ID.

=item gcTable

A hash of translation tables for the genetic codes to use in output proteins.

=item pegCounts

Reference to a hash mapping each GTO name to the number of pegs inserted for it.

=item logFile

An open file handle for progress message output.  The default is to only send
progress message output to the standard error output.

=item verbose

If TRUE, progress messages will be set to the standard error output (and optionally
the log file).

=back

=head2 Special Methods

=head3 new

    my $closeAnno = CloseAnno->new($target, %options);

Create a new close-annotation object for a specified target FASTA file.

=over 4

=item target

The name of the FASTA file containing the target DNA contigs.

=item options

A hash containing zero or more of the following options.

=over 8

=item workDir

The name of a working directory used for temporary files.  The default is
the SEEDtk temporary directory..

=item maxE

The maximum allowable e-value on a blast hit.  The default is C<1e-40>.

=item minlen

The minimum fraction of the query sequence length that must be found in the blast
hit.  The default is C<0.90>.

=item maxHits

The maximum number of BLAST hits to return for each query sequence.  The default is C<5>.

=item stats

A L<Stats> object for tracking statistics.  The default is to create one internally.

=item logFile

The name of a file for copies of the progress message output.  The default is to
only send progress message output to the standard error output.

=item verbose

If TRUE, progress messages will be set to the standard error output (and optionally
the log file).

=back

=back

=cut

sub new {
    my ($class, $target, %options) = @_;
    # Compute the options.
    my $debug = $options{verbose};
    my $stats = $options{stats} // Stats->new();
    my $minlen = $options{minlen} // 0.90;
    my $maxE = $options{maxE} // 1e-40;
    my $workDir = $options{workDir} // $FIG_Config::temp;
    my $maxHits = $options{maxHits} // 5;
    my $genetic_code = $options{genetic_code} // 11;
    # Handle the logfile.
    my $lh;
    if ($options{logFile}) {
        open($lh, '>', $options{logFile}) || die "Could not open log file: $!";
    }
    # Now we read the target file and assemble the contigs.
    my %contigs;
    my $fastA = FastA->new($target);
    while ($fastA->next()) {
        $contigs{$fastA->id} = lc $fastA->left;
    }
    my %codes = map { $_ => SeedUtils::genetic_code($_) } qw(1 2 3 4 11);
    # Create the object.
    my $retVal = {
        hits => {},
        target => $target,
        workDir => $workDir,
        stats => $stats,
        minlen => $minlen,
        maxE => $maxE,
        contigs => \%contigs,
        maxHits => $maxHits,
        verbose => $debug,
        logFile => $lh,
        gcTable => \%codes,
        pegCounts => {},
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}

=head3 cmp_stop

    my $cmp = CloseAnno::cmp_stop($a, $b);

Compare two stop locations for sorting.  We sort by contig ID then by location offset and strand.

=over 4

=item a

First stop location.

=item b

Second stop location.

=item RETURN

Return a positive value if the first stop should sort last, a negative value if it should sort first, and 0 if the stops are equal.

=back

=cut

sub cmp_stop {
    my ($a, $b) = @_;
    my ($aContig, $aStrand, $aloc) = parse_stop($a);
    my ($bContig, $bStrand, $bloc) = parse_stop($b);
    return ($aContig cmp $bContig) || ($aloc <=> $bloc) || ($aStrand cmp $bStrand);
}

=head3 parse_stop

    my ($contig, $dir, $loc) = parse_stop($stop);

Parse a stop location into the contig ID, direction, and position.

=over 4

=item stop

A stop location.

=item RETURN

Returns a list containing the contig ID, direction, and position of the stop.

=back

=cut

sub parse_stop {
    my ($stop) = @_;
    my ($contig, $dir, $loc) = ($stop =~ /(.+)([+-])(\d+)/);
    return ($contig, $dir, $loc);
}


=head2 Public Manipulation Methods

=head3 readGto



=head3 findHits

    $closeAnno->findHits($qFile, $gc);

Find hits from the specified protein query file.  The hits will be stored in the
object, and can be retrieved late by query methods.

=over 4

=item qFile

Name of the FASTA file containing the query sequences.

=item gc

Genetic code to use for proten translations.

=back

=cut

sub findHits {
    my ($self, $qFile, $gc) = @_;
    # Get the log and the statistics objects.
    my $debug = $self->{verbose};
    my $stats = $self->{stats};
    # Extract the minimum-length fraction.
    my $minlen = $self->{minlen};
    # Get the hit hash.
    my $hitH = $self->{hits};
    # Blast the query file against the target.
    $self->log("Blasting against $qFile.\n") if $debug;
    $stats->Add(blastRuns => 1);
    my $matches = BlastUtils::blast($qFile, $self->{target},
            tblastn => { maxE => $self->{maxE}, outForm => 'hsp',
                maxHitsPerQuery => $self->{maxHits},
                dbGenCode => $gc, tmp_dir => $self->{workDir} });
    $self->log(scalar(@$matches) . " hits found.\n") if $debug;
    # Loop through the matches, keeping ones that qualify.
    my ($kept, $updated, $processed) = (0, 0, 0);
    for my $match (@$matches) {
        $stats->Add(matchFound => 1);
        # First, filter on the length.
        my $newLen = $match->n_mat - $match->n_gap;
        if ($newLen < $minlen * $match->qlen) {
            $stats->Add(matchTooShort => 1);
        } else {
            # Now, find the start and stop locations.
            my $start = $self->_find_start($match, $gc);
            my $stopLoc = $self->_find_stop($match, $gc);
            if ($stopLoc && $start) {
                # Check for a previous hit.  If we find one we have to compare lengths.
                my $oldMatchSpec = $hitH->{$stopLoc};
                if (! $oldMatchSpec) {
                    # This is the first match for this coding region.
                    $kept++;
                    $stats->Add(matchNew => 1);
                    $self->{hits}{$stopLoc} = [$start, $match];
                } else {
                    # Here we have to check the length.
                    my (undef, $oldMatch) = @$oldMatchSpec;
                    if ($newLen < $oldMatch->n_mat - $oldMatch->n_gap) {
                        # This match is shorter, so it is not as good as the old one.
                        $stats->Add(matchDuplicate => 1);
                    } else {
                        # Here we have a better match.
                        $self->{hits}{$stopLoc} = [$start, $match];
                        $stats->Add(matchBetter => 1);
                        $updated++;
                    }
                }
            }
        }
        $processed++;
    }
    $self->log("$kept new coding regions found of $processed, $updated updated.\n") if $debug;
}

=head2 Query Methods

=head3 stats

    my $stats = $closeAnno->stats;

Return the statistics object.

=cut

sub stats {
    my ($self) = @_;
    return $self->{stats};
}

=head3 all_stops

    my $stopList = $closeAnno->all_stops();

Return a reference to a list of all the stops found.

=cut

sub all_stops {
    my ($self) = @_;
    my $hitsH = $self->{hits};
    return [sort { cmp_stop($a, $b) } keys %$hitsH];
}

=head3 feature_at

    my ($contig, $start, $dir, $stop, $function) = $closeAnno->feature_at($stopLoc);

Return the description of the feature found at the specified stop location.

=over 4

=item stopLoc

The stop-location specifier for the feature in question.

=item RETURN

Returns a five-element list consisting of (0) the contig ID, (1) the start position, (2) the strand, (3) the stop
position, and (4) the functional assignment.  If the stop location is invalid, the start will be undefined.

=back

=cut

sub feature_at {
    my ($self, $stopLoc) = @_;
    # Initialize the stop information.
    my ($contig, $dir, $stop) = parse_stop($stopLoc);
    # Declare the start and function.
    my ($start, $function);
    # Check for a match.
    my $matchSpec = $self->{hits}{$stopLoc};
    if ($matchSpec) {
        ($start, $function) = ($matchSpec->[0], $matchSpec->[1]->qdef);
    }
    # Return the results.
    return ($contig, $start, $dir, $stop, $function);
}

=head3 add_feature_at

    $closeAnno->add_feature_at($gto, $stopLoc);

Add the feature at the specified stop location to the specified L<GenomeTypeObject>.

=over 4

=item gto

L<GenomeTypeObject> to receive the new feature.

=item stopLoc

The stop-location specifier for the feature in question.

=back

=cut

sub add_feature_at {
    my ($self, $gto, $stopLoc) = @_;
    # Get the genome ID.
    my $genomeID = $gto->{id};
    # Get the genetic code.
    my $gc = $self->{gcTable}{$gto->{genetic_code}};
    # Compute the feature ID.
    my $pegNum = $self->{pegCounts}{$genomeID};
    if (! $pegNum) {
        $self->{pegCounts}{$genomeID} = 2;
        $pegNum = 1;
    } else {
        $self->{pegCounts}{$genomeID}++;
    }
    my $fid = "fig|$genomeID.peg.$pegNum";
    # Get the data for the feature at this stop.
    my ($contig, $start, $dir, $stop, $function) = $self->feature_at($stopLoc);
    # Get the DNA and location for this feature.
    my $contigH = $self->{contigs};
    my ($seq, $len);
    if ($dir eq '+') {
        $len = $stop + 1 - $start;
        $seq = substr($contigH->{$contig}, $start - 1, $len);
    } else {
        $len = $start + 1 - $stop;
        $seq = SeedUtils::rev_comp(substr($contigH->{$contig}, $stop - 1, $len));
    }
    my @loc = ([$contig, $start, $dir, $len]);
    # Compute the resultant protein sequence.  Note we fix the start and chop off the stop.
    my $prot = SeedUtils::translate($seq, $gc, 1);
    if ($prot =~ /\*$/) {
        chop $prot;
    }
    # Add the feature to the GTO.
    $gto->add_feature({-id => $fid, -function => $function, -protein_translation => $prot,
        -annotator => 'CloseAnno', -location => \@loc, -type => 'CDS' });
}

=head3 log

    $closeAnno->log($msg);

Write a message to the standard error output and the log file (if any).

=over 4

=item msg

Message to write.

=back

=cut

sub log {
    my ($self, $msg) = @_;
    print STDERR $msg;
    if ($self->{logFile}) {
        my $lh = $self->{logFile};
        print $lh $msg;
    }
}


=head2 Internal Methods

=cut

use constant STARTS => {
        1 => { 'ttg' => 1, 'caa' => -1, 'ctg' => 1, 'cag' => -1, 'atg' => 1, 'cat' => -1},
        2 => { 'att' => 1, 'aat' => -1, 'atc' => 1, 'gat' => -1, 'ata' => 1, 'tat' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        3 => { 'ata' => 1, 'tat' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
#        4 => { 'ttg' => 1, 'caa' => -1, 'ctg' => 1, 'cag' => -1, 'gtg' => 1, 'cac' => -1},
        4 => { 'tta' => 1, 'taa' => -1, 'ttg' => 1, 'caa' => -1, 'ctg' => 1, 'cag' => -1, 'att' => 1, 'aat' => -1, 'atc' => 1, 'gat' => -1, 'ata' => 1, 'tat' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        5 => { 'ttg' => 1, 'caa' => -1, 'att' => 1, 'aat' => -1, 'atc' => 1, 'gat' => -1, 'ata' => 1, 'tat' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        6 => { 'atg' => 1, 'cat' => -1},
        9 => { 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        10 => { 'atg' => 1, 'cat' => -1},
        11 => { 'ttg' => 1, 'caa' => -1, 'ctg' => 1, 'cag' => -1, 'att' => 1, 'aat' => -1, 'atc' => 1, 'gat' => -1, 'ata' => 1, 'tat' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
#        11 => { 'ttg' => 1, 'caa' => -1, 'ctg' => 1, 'cag' => -1, 'gtg' => 1, 'cac' => -1},
        12 => { 'ctg' => 1, 'cag' => -1, 'atg' => 1, 'cat' => -1},
        13 => { 'ttg' => 1, 'caa' => -1, 'ata' => 1, 'tat' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        14 => { 'atg' => 1, 'cat' => -1},
        15 => { 'atg' => 1, 'cat' => -1},
        16 => { 'atg' => 1, 'cat' => -1},
        21 => { 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        22 => { 'atg' => 1, 'cat' => -1},
        23 => { 'att' => 1, 'aat' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        24 => { 'ttg' => 1, 'caa' => -1, 'ctg' => 1, 'cag' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        25 => { 'ttg' => 1, 'caa' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        26 => { 'ctg' => 1, 'cag' => -1, 'atg' => 1, 'cat' => -1},
        27 => { 'atg' => 1, 'cat' => -1},
        28 => { 'atg' => 1, 'cat' => -1},
        29 => { 'atg' => 1, 'cat' => -1},
        30 => { 'atg' => 1, 'cat' => -1},
        31 => { 'atg' => 1, 'cat' => -1},
        32 => { 'ttg' => 1, 'caa' => -1, 'ctg' => 1, 'cag' => -1, 'att' => 1, 'aat' => -1, 'atc' => 1, 'gat' => -1, 'ata' => 1, 'tat' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
        33 => { 'ttg' => 1, 'caa' => -1, 'ctg' => 1, 'cag' => -1, 'atg' => 1, 'cat' => -1, 'gtg' => 1, 'cac' => -1},
    };
use constant STOPS => {
        1 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1, 'tga' => 1, 'tca' => -1},
        2 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1, 'aga' => 1, 'tct' => -1, 'agg' => 1, 'cct' => -1},
        3 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        4 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        5 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        6 => { 'tga' => 1, 'tca' => -1},
        9 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        10 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        11 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1, 'tga' => 1, 'tca' => -1},
        12 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1, 'tga' => 1, 'tca' => -1},
        13 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        14 => { 'tag' => 1, 'cta' => -1},
        15 => { 'taa' => 1, 'tta' => -1, 'tga' => 1, 'tca' => -1},
        16 => { 'taa' => 1, 'tta' => -1, 'tga' => 1, 'tca' => -1},
        21 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        22 => { 'tca' => 1, 'tga' => -1, 'taa' => 1, 'tta' => -1, 'tga' => 1, 'tca' => -1},
        23 => { 'tta' => 1, 'taa' => -1, 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1, 'tga' => 1, 'tca' => -1},
        24 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        25 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        26 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1, 'tga' => 1, 'tca' => -1},
        27 => { 'tga' => 1, 'tca' => -1},
        28 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1, 'tga' => 1, 'tca' => -1},
        29 => { 'tga' => 1, 'tca' => -1},
        30 => { 'tga' => 1, 'tca' => -1},
        31 => { 'taa' => 1, 'tta' => -1, 'tag' => 1, 'cta' => -1},
        32 => { 'taa' => 1, 'tta' => -1, 'tga' => 1, 'tca' => -1},
        33 => { 'tag' => 1, 'cta' => -1},
    };


=head3 _find_stop

    my $stopLoc = $closeAnno->_find_stop($match, $gc);

Return the stop location in the target sequence for the specified match.

=over 4

=item match

The L<Hsp> object for the match in question.

=item gc

The genetic code relevant to the target sequences.

=item RETURN

Returns a stop location, coded as a string of the form I<seqID>I<dir>I<pos> where I<seqID> is the sequence ID of
the target sequence, I<dir> is the strand, and I<pos> is the 1-based location of the left edge of the stop.

=back

=cut

sub _find_stop {
    my ($self, $match, $gc) = @_;
    my $stats = $self->stats;
    # This will be the return value.
    my $retVal;
    # Get the stops for the genetic code.
    my $stopH = STOPS->{$gc};
    # Get the direction and the endpoint of the match.
    my $dir = $match->dir;
    my $pos = $match->s2;
    my $begin = $match->s1;
    my $slen = ($dir eq '+' ? $pos + 1 - $begin : $begin + 1 - $pos);
    if ($slen % 3 != 0) {
        $stats->Add(badMatchPhase => 1);
    } elsif ($match->sseq =~ /\*/) {
        $stats->Add(internalStop => 1);
    } else {
        # Get the sequence to search.
        my $seq = $self->{contigs}{$match->sid};
        my $done;
        # Search for the stop in the appropriate direction.
        if ($dir eq '+') {
            # The incoming location is a position, but this is the offset of the space
            # after the end, where we want to start searching.
            my $s1 = $pos;
            # Compute the offset past the last possible location for the stop in the contig
            # and search.
            my $s2 = length($seq) - 2;
            while (! $retVal && $s1 < $s2) {
                my $codon = substr($seq, $s1, 3);
                if (($stopH->{$codon} // 0) == 1) {
                    # The stop location is the position of the last base pair, which is 2
                    # forward of our current position, plus 1 to convert to a location.
                    $retVal = $match->sid . $dir . ($s1 + 3);
                } else {
                    $s1 += 3;
                }
            }
        } else {
            # The incoming location is a position, and we want to start at an offset three
            # base pairs before it.
            my $s1 = $pos - 4;
            # Search backward toward the beginning of the contig.
            while (! $retVal && $s1 >= 0) {
                my $codon = substr($seq, $s1, 3);
                if (($stopH->{$codon} // 0) == -1) {
                    # The stop location is the position of the first base pair, which must
                    # be converted to a location.
                    $retVal = $match->sid . $dir . ($s1 + 1);
                } else {
                    $s1 -= 3;
                }
            }
        }
        if (! $retVal) {
            $stats->Add(stopNotFound => 1);
        }
    }
    # Return the result.
    return $retVal;
}

=head3 _find_start

    my $start = $closeAnno->_find_start($match, $gc);

Find a start for the specified match.

=over 4

=item match

The L<Hsp> object for the match.

=item gc

The genetic code to use for finding the start.

=item RETURN

Returns TRUE if successful, FALSE if the match could not be stored.

=back

=cut

sub _find_start {
    my ($self, $match, $gc) = @_;
    # This will be set to the start if we find it.
    my $retVal;
    # This will be set to TRUE to abort the search loop early.
    my $done;
    # Get the starts for the specified genetic code.
    my $startH = STARTS->{$gc};
    my $stopH = STOPS->{$gc};
    # Get the direction and the startpoint of the match.
    my $dir = $match->dir;
    my $pos = $match->s1;
    # Get the sequence to search.
    my $seq = $self->{contigs}{$match->sid};
    if ($dir eq '+') {
        # Begin searching at the first position of the match, which we must
        # convert to an offset.
        my $s1 = $pos - 1;
        # Loop backward.  If we hit a stop first, we abort.
        while (! $done && $s1 >= 0) {
            my $codon = substr($seq, $s1, 3);
            if (($startH->{$codon} // 0) == 1) {
                $done = 1;
                # The start is here, so we convert back to a location.
                $retVal = $s1 + 1;
            } elsif (($stopH->{$codon} // 0) == 1) {
                # Abort.  We have found the start of the ORF, but no start.
                $done = 1;
            } else {
                $s1 -= 3;
            }
        }
    } else {
        # Begin searching at the last codon of the match.  This is location - 2,
        # Which we then convert to an offset.
        my $s1 = $pos - 3;
        # Compute the offset past the last possible position for a codon in this contig.
        my $s2 = length($seq) - 2;
        # Loop forward.  If we hit a stop first, we abort.
        while (! $done && $s1 < $s2) {
            my $codon = substr($seq, $s1, 3);
            if (($startH->{$codon} // 0) == -1) {
                $done = 1;
                # The start position is the rightmost base pair on the contig, which is
                # 2 forward of our current position.  We add 1 to convert to a location.
                $retVal = $s1 + 3;
            } elsif (($stopH->{$codon} // 0) == -1) {
                # Abort.  We've hit a stop before we found our start.
                $done = 1;
            } else {
                $s1 += 3;
            }
        }
    }
    if (! $retVal) {
        my $stats = $self->{stats};
        if (! $done) {
            $stats->Add(startNotFound => 1);
        } else {
            $stats->Add(startBlocked => 1);
        }
    }
    # Return the result.
    return $retVal;
}

1;


