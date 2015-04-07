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

package MapToRef;

use strict;
use warnings;
use FIG_Config;
use Data::Dumper;
use SeedUtils;
use ScriptUtils;
use gjoseqlib;

=head1 project reference genome to a close strain

This library provides utility methods used for projecting features from a
reference genome to a closely-related genome.

=cut

sub build_mapping {
    my ( $k, $r_tuples, $g_tuples ) = @_;

    #print STDERR "Calling build_hash for reference\n";
    my $r_hash = &build_hash( $r_tuples, $k );

    #print STDERR "Calling build_hash for new\n";
    my $g_hash = &build_hash( $g_tuples, $k );

    my $pins = &build_pins( $r_tuples, $k, $g_hash, $r_hash );
    my @map = &fill_pins( $pins, $r_tuples, $g_tuples );

    return \@map;
}

# a hash has a 0-base for each kmer (kmer is a key to a 0-based location)
sub build_hash {
    my ( $contigs, $k ) = @_;

    my $k1   = int( $k * 1.5 );
    my $hash = {};
    my %seen;
    foreach my $tuple (@$contigs) {
        my ( $contig_id, $comment, $seq ) = @$tuple;
        my $last = length($seq) - $k1;
        for ( my $i = 0 ; ( $i <= $last ) ; $i++ ) {
            my $kmer = get_kmer( \$seq, $i, $k );
            if ($kmer) {
                my $kmer2 = get_kmer( \$seq, $i, $k, 1 );
                if ( $hash->{$kmer} ) {
                    $seen{$kmer}  = 1;
                    $seen{$kmer2} = 1;
                } else {
                    $hash->{$kmer}  = [ $contig_id, "+", $i ];
                    $hash->{$kmer2} = [ $contig_id, "-", $i + $k1 - 1 ];
                }
            }
        }
    }

    foreach my $kmer ( keys(%seen) ) {
        delete $hash->{$kmer};
    }

    #print STDERR &Dumper( 'hash', $hash );
    return $hash;
}

# Get a kmer at the current position of the sequence. We accept as input a reference to the sequence string (usually
# a contig), a position, the desired kmer length, and a flag indicatign whether or not we want the reverse complement.
# We will return a string consisting of the first two characters of each triplet in the sequence.
sub get_kmer {
    my ( $seqR, $pos, $k, $rev ) = @_;

    # Get the length we must extract to find a kmer of the desired length.
    my $k1 = int( $k * 1.5 );
    my $seq = uc substr( $$seqR, $pos, $k1 );
    my $retVal;
    if ( $seq =~ /^[AGCT]+$/ ) {
        if ($rev) {
            $seq = SeedUtils::rev_comp($seq);
        }

        # Get the first two of every three characters.
        $retVal = join( '', $seq =~ m/(..).?/g );
    }
    return $retVal;
}

# pins are 0-based 2-tuples.  It is an ugly fact that the simple pairing of unique
# kmers can lead to a situation in which 1 character in the reference genome is paired
# with more than one character in the new genome (and vice, versa).  We sort of handle that.
sub build_pins {
    my ( $r_contigs, $k, $g_hash, $r_hash ) = @_;

    my @pins;
    foreach my $tuple (@$r_contigs) {
        my ( $contig_id, $comment, $seq ) = @$tuple;
        my $k1    = 1.5 * $k;
        my $last  = length($seq) - $k1 + 1;
        my $found = 0;
        my $i     = 0;
        while ( $i <= $last ) {
            my $kmer = get_kmer( \$seq, $i, $k );
            if ( $kmer && $r_hash->{$kmer} ) {
                my $g_pos = $g_hash->{$kmer};
                if ($g_pos) {
                    my ( $g_contig, $g_strand, $g_off ) = @$g_pos;
                    for ( my $j = 0 ; $j < $k1 ; $j++ ) {
                        if ( $g_strand eq '+' ) {
                            push(
                                @pins,
                                [
                                    [ $contig_id, '+', $i + $j ],
                                    [ $g_contig,  '+', $g_off + $j ]
                                ]
                            );
                        } else {
                            push(
                                @pins,
                                [
                                    [ $contig_id, '+', $i + $j ],
                                    [ $g_contig,  '-', $g_off - $j ]
                                ]
                            );
                        }
                    }
                    $i = $i + $k1;
                } else {
                    $i++;
                }
            } else {
                $i++;
            }
        }
    }
    @pins = &remove_dups( 0, \@pins );
    @pins = &remove_dups( 1, \@pins );
    @pins = sort {
             ( $a->[0]->[0] cmp $b->[0]->[0] )
          or ( $a->[0]->[2] <=> $b->[0]->[2] )
    } @pins;
    #print STDERR &Dumper( [ '0-based pins', \@pins ] );
    return \@pins;
}

sub remove_dups {
    my ( $which, $pins ) = @_;

    my %bad;
    my %seen;
    for ( my $i = 0 ; ( $i < @$pins ) ; $i++ ) {
        my $keyL = $pins->[$i]->[$which];
        my $key = join( ",", @$keyL );
        if ( $seen{$key} ) {
            $bad{$i} = 1;
        }
        $seen{$key} = 1;
    }
    my @new_pins;
    for ( my $i = 0 ; ( $i < @$pins ) ; $i++ ) {
        if ( !$bad{$i} ) {
            push( @new_pins, $pins->[$i] );
        }
    }
    return @new_pins;
}

sub fill_pins {
    my ( $pins, $ref_tuples, $g_tuples ) = @_;

    my %ref_seqs = map { ( $_->[0] => $_->[2] ) } @$ref_tuples;
    my %g_seqs   = map { ( $_->[0] => $_->[2] ) } @$g_tuples;

    my @filled;
    for ( my $i = 0 ; ( $i < @$pins ) ; $i++ ) {
        if ( $i == ( @$pins - 1 ) ) {
            push( @filled, $pins->[$i] );
        } else {
            my @expanded = &fill_between( $pins->[$i], $pins->[ $i + 1 ],
                \%ref_seqs, \%g_seqs );
            push( @filled, @expanded );
        }
    }
    return @filled;
}

sub fill_between {
    my ( $pin1, $pin2, $ref_seqs, $g_seqs ) = @_;
    my ( $rp1, $gp1 ) = @$pin1;
    my ( $rp2, $gp2 ) = @$pin2;
    my ( $contig_r_1, $strand_r_1, $pos_r_1 ) = @$rp1;
    my ( $contig_r_2, $strand_r_2, $pos_r_2 ) = @$rp2;
    my ( $contig_g_1, $strand_g_1, $pos_g_1 ) = @$gp1;
    my ( $contig_g_2, $strand_g_2, $pos_g_2 ) = @$gp2;

    my @expanded;
    if (
           ( $contig_r_1 eq $contig_r_2 )
        && ( $contig_g_1 eq $contig_g_2 )
        && ( $strand_g_1 eq $strand_g_2 )
        && ( ( $pos_r_2 - $pos_r_1 ) == abs( $pos_g_2 - $pos_g_1 ) )
        && ( ( $pos_r_2 - $pos_r_1 ) > 1 )
        && &same(
            [ $contig_r_1,, $pos_r_1, $pos_r_2 - 1, $ref_seqs ],

            #[ $contig_r_1, '+', $pos_r_1, $pos_r_2 - 1, $ref_seqs ],
            [
                $contig_g_1,

                #$strand_g_1,
                ( $strand_g_1 eq '+' )
                ? ( $pos_g_1, $pos_g_2 - 1 )
                : ( $pos_g_1, $pos_g_2 + 1 ),
                $g_seqs
            ]
        )
      )
    {
        my $p_r = $pos_r_1;
        my $p_g = $pos_g_1;
        while ( $p_r < $pos_r_2 ) {
            push(
                @expanded,
                [
                    [ $contig_r_1, '+',         $p_r ],
                    [ $contig_g_1, $strand_g_1, $p_g ]
                ]
            );
            $p_r++;
            $p_g = ( $strand_g_1 eq "+" ) ? $p_g + 1 : $p_g - 1;
        }
    } else {
        push @expanded, $pin1;
    }
    return @expanded;
}

sub same {
    my ( $gap1, $gap2 ) = @_;
    my ( $c1, $b1, $e1, $seqs1 ) = @$gap1;
    my ( $c2, $b2, $e2, $seqs2 ) = @$gap2;

    my $seq1 = &seq_of( $c1, $b1, $e1, $seqs1 );
    my $seq2 = &seq_of( $c2, $b2, $e2, $seqs2 );
    if ( length($seq1) < 20 ) {
        return 1;
    } else {
        my $iden = 0;
        my $len  = length($seq1);
        for ( my $i = 0 ; ( $i < $len ) ; $i++ ) {
            if ( substr( $seq1, $i, 1 ) eq substr( $seq2, $i, 1 ) ) {
                $iden++;
            }
        }
        return ( ( $iden / $len ) >= 0.8 );
    }
}

sub seq_of {
    my ( $c, $b, $e, $seqs ) = @_;

    my $seq = $seqs->{$c};
    if ( $b <= $e ) {
        return uc substr( $seq, $b , ( $e - $b ) + 1 );
    } else {
        return uc &rev_comp( substr( $seq, $e , ( $b - $e ) + 1 ) );
    }
}

=head3 build_features

    my $featureList = MapToRef::build_features($map, \@gContigs, \@features, $gCode);

Compute the projected features for a target set of contigs using a map of pinned correspondences.
For each feature in the reference genome, we use the map to determine if there is a corresponding
DNA sequence in the target genome. If we find one, we presume the found region in the target genome
is an instance of the reference feature, and we project a feature at the new location. The output
of this method is a list of those features.

=over 4

=item map

The map is a list of location correspondences in the two genomes (reference and target)
computed using kmers. Each entry in the list is a pair of 3-tuples. Each 3-tuple consists of
(0) a contig ID, (1) a strand, and (2) a 0-based position in the contig. The first 3-tuple
is for the reference genome and the second for the target genome. The existence of a pair
indicates a correspondence (pin) between the two positions.

=item g_tuples

A list of 3-tuples representing the contigs for the target genome. Each 3-tuple consists of
(0) a contig ID, (1) a comment (not used), and (2) the DNA sequence.

=item features

A list of features from the reference genome. For each feature, we have a 4-tuple consisting of
(0) the ID, (1) the type, (2) the location tuple, and (3) the functional assignment. Each location
tuple consists of (0) the contig ID, (1) the 1-based start position, (2) the strand, and (3) the
length.

=item genetic_code

The genetic code of the target genome.

=item RETURN

This method returns a list of proposed features for the target genome. Each feature is represented as
a 5-tuple containing (0) the type, (1) the location tuple, (2) the functional assignment, (3) the ID
of the source feature in the representative genome, and (4) the sequence. For a peg, the sequence will be
a protein sequence.

=back

=cut


sub build_features {
    my ( $map, $g_tuples, $features, $genetic_code ) = @_;

    my %g_seqs = map { ( $_->[0] => $_->[2] ) } @$g_tuples;

    my %refH;
    foreach my $pin (@$map) {
        my ( $ref_loc, $g_loc ) = @$pin;
        my ( $r_contig, $r_strand, $r_pos ) = @$ref_loc;
        $refH{ $r_contig . ",$r_pos" } = $g_loc;
    }

    my @new_features;

    foreach my $tuple (@$features) {
        my ( $fid,      $type,  $loc,      $assign ) = @$tuple;
        my ( $r_contig, $r_beg, $r_strand, $r_len )  = @$loc;
        # Convert 1-based to offset.
        $r_beg--;
        my $r_end =
          ( $r_strand eq '+' )
          ? $r_beg + ( $r_len - 1 )
          : $r_beg - ( $r_len - 1 );
        if (   ( my $g_locB = $refH{ $r_contig . ",$r_beg" } )
            && ( my $g_locE = $refH{ $r_contig . ",$r_end" } ) )
        {

            my ( $g_contig1, $g_strand1, $g_pos1 ) = @$g_locB;
            my ( $g_contig2, $g_strand2, $g_pos2 ) = @$g_locE;

            if ( ( $g_contig1 eq $g_contig2 ) && ( $g_strand1 eq $g_strand2 ) )
            {
                my $len1 = abs( $g_pos1 - $g_pos2 ) + 1;
                my $len2 = abs( $r_end - $r_beg ) + 1;
                if (   ( abs( $len1 - $len2 ) <= 12 )
                    && ( abs( $len2 - $len1 ) % 3 == 0 ) )
                {

                    my $g_len = $len1;
                    my $g_strand = ( $g_pos2 > $g_pos1 ) ? '+' : '-';
                    my $g_location =
                      [ $g_contig1, ( $g_pos1 + 1 ), $g_strand, $g_len ];
                    my $seq =
                      &seq_of_feature( $type, $genetic_code, $g_contig1,
                        $g_pos1, $g_pos2, \%g_seqs );

                    if ($seq) {
                        push @new_features,
                          [ $type, $g_location, $assign, $fid, $seq ];
                    }
                }
            }
        }
    }
    return \@new_features;
}

sub get_genetic_code {
    my ($dir) = @_;

    if ( !-s "$dir/GENETIC_CODE" ) { return 11 }
    open( my $ih, "<$dir/GENETIC_CODE" )
      || die "Could not open genetic code file in $dir: $!";
    my $tmp = <$ih>;
    chomp $tmp;
    return $tmp;
}


sub seq_of_feature {
    my ( $type, $genetic_code, $g_contig, $g_beg, $g_end, $g_seqs ) = @_;
    my $dna = &seq_of( $g_contig, $g_beg, $g_end, $g_seqs );
    if ( ( $type ne "peg" ) && ( $type ne "CDS" ) ) {
        return $dna;
    } else {
        my $code = &SeedUtils::standard_genetic_code;
        if ( $genetic_code == 4 ) {
            $code->{"TGA"} = "W";    # code 4 has TGA encoding tryptophan
        }
        my $tran = &SeedUtils::translate( $dna, $code, 1 );
        if ( $tran =~ s/\*$// && $tran =~ /^M/ ) {
            return ( $tran =~ /\*/ ) ? undef : $tran;
        } else {
            return undef;
        }
    }
}

1;
