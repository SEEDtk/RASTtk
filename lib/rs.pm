package rs;

use strict;
use warnings;
use Data::Dumper;
# use Proc::ParallelLoop;

# Compute similarity score for two hashes of k-mers
sub sim{
    my ($hash1, $hash2) = @_;
    my @keys1 = keys %$hash1;

    my $retVal = 0;

    # Check hash2 for entries matching keys of hash1
    for my $key (@keys1){
        if (defined $hash2->{$key}){
            $retVal++;
        }
    }

    # Only interested in number of kmers in common
    return $retVal;
}

# Given a path to a table of inputs, return a data structure
# representing the rows of the table;
sub read_in{
    # Process input table
    my $path = shift;
    open my $fh, '<', $path;

    my %rows;
    my $line_num = 0;
    while (my $line = <$fh>){
        if ($line =~ m/genome/i){ next }
        chomp $line;
        my ($gen, $score, $seq) = split "\t", $line;

        # Generate hash from all lines
        $rows{$gen} = {	'score' => $score,
                        'seq' 	=> $seq,
                        'line' 	=> $line_num++};
    }

    return \%rows;
}

# Given a sequence, get a hash table of kmers
sub kmers{
    my $seq = shift;
    my $n	= shift // 8; # default 8-mers
    my $len	= length $seq;
    my $kmers;

    # Pull out all substrings into hash
    for my $i (0..$len-$n){
        $kmers->{substr $seq, $i, $n} = 1;
    }

    return $kmers;
}

# Given a path to a table of inputs and a cutoff, return the
# representative set.
sub rep_set{
    my $path 	= shift;
    my $cutoff 	= shift // 100;
    my $print	= shift // 1; # Default is to print

    # Pare down to representatives
    my $rows = read_in $path;
    my @gens = keys %$rows;

    # Sort by order they appeared
    @gens = sort {$rows->{$a}->{'line'} <=> $rows->{$b}->{'line'}} @gens;
    my $reps;
    GENOME: for my $gen (@gens){
        # Part 1: generate hash table of k-mers
        my $kmers 	= kmers $rows->{$gen}->{'seq'};

        # Part 2: check for representatives
        for my $key (keys %$reps){
            my $key_kmers 	= $reps->{$key};
            my $sim			= sim($kmers, $reps->{$key}->{'kmers'});
            # print "sim between $gen, $key is $sim\n";

            if ($sim >= $cutoff){ next GENOME }
        }
        $reps->{$gen} = {	'kmers' => $kmers,
                            'seq'	=> $rows->{$gen}->{'seq'},
                            'score'	=> $rows->{$gen}->{'score'}};
        if ($print){
            my $seq		= $reps->{$gen}->{'seq'};
            my $score	= $reps->{$gen}->{'score'};
            print "$gen\t$score\t$seq\n";
        }
    }

    return $reps;
}

# Given a (sequence, n, representatives object, print) tuple,
# return a set of representatives
sub n_closest{
    my ($seq, $n, $reps, $print) = @_;

    my $kmers = kmers $seq;

    my %scores;
    for my $rep (keys %$reps){
        $scores{$rep} = sim $kmers, $reps->{$rep}->{'kmers'};
    }

    my @rank = sort { $scores{$b} <=> $scores{$a} } keys %scores;

    # Trim only if necessary
    if (scalar @rank > $n){
        @rank = @rank[0..$n-1]
    }

    my %out = map {($_, $scores{$_})} @rank;

    if ($print){
        for my $id (@rank){
            my $seq = $reps->{$id}->{'seq'};
            print "$id\t$scores{$id}\t$seq\n";
        }
    }

    return \%out;
}

sub closest{
    my ($seq, $reps) = @_;

    my $kmers = kmers $seq;

    my $best_score = 0;
    my $closest;

    for my $rep (keys %$reps){
        my $n = sim $kmers, $reps->{$rep}->{'kmers'};
        if ($n > $best_score){
            $best_score = $n;
            $closest = $rep;
        }
    }
    return [$closest, $best_score];
}

# Given a (sequence, n, reps, print) tuple, estimate the family, genus, and species of
# that sequence based on the taxonomy of the n closest neighbors.
sub estimate_taxon{
    my $knn = shift;
    my $print = shift // 0;

    my %fam;
    my %gen;
    my %spe;
    for my $id (keys %$knn){
        # Set p3 pipeline commands
        my $command = "p3-echo '$id' | p3-get-genome-data --attr family --attr genus --attr species";
        my $out = `$command`;

        # Extract the row and column of interest: index (1,1:3) in the outputs
        my ($fam, $gen, $spe) = (split "\t", ( split "\n", $out )[1])[1..3];

        if (! defined $fam{$fam}){	$fam{$fam} 	= $knn->{$id} 	}
        else {						$fam{$fam} += $knn->{$id}	}

        if (! defined $gen{$gen}){	$gen{$gen} 	= $knn->{$id}	}
        else {						$gen{$gen} += $knn->{$id}	}

        if (! defined $spe{$spe}){	$spe{$spe} 	= $knn->{$id}	}
        else {						$spe{$spe} += $knn->{$id}	}

    }

    # Resolve votes
    my $best_fam =  (sort { $fam{$b} <=> $fam{$a} } keys %fam)[0];
    my $best_gen =  (sort { $gen{$b} <=> $gen{$a} } keys %gen)[0];
    my $best_spe =  (sort { $spe{$b} <=> $spe{$a} } keys %spe)[0];

    # Print output if desired
    if ($print){ print "$best_fam	$best_gen	$best_spe\n" }

    return [$best_fam, $best_gen, $best_spe];
}

# Given a path to a table of representatives, get kmers for them.
# This is a modification of rep_set which does not check for representatives;
# it simply computes kmers for each row.
sub load_rep_set{
    my $path 	= shift;
    my $print	= shift // 1; # Default is to print

    # Pare down to representatives
    my $rows = read_in $path;
    my @gens = keys %$rows;

    # Sort by order they appeared
    @gens = sort {$rows->{$a}->{'line'} <=> $rows->{$b}->{'line'}} @gens;
    my $reps;
    GENOME: for my $gen (@gens){
        # Part 1: generate hash table of k-mers
        my $kmers 	= kmers $rows->{$gen}->{'seq'};

        $reps->{$gen} = {	'kmers' => $kmers,
                            'seq'	=> $rows->{$gen}->{'seq'},
                            'score'	=> $rows->{$gen}->{'score'}};
        if ($print){
            my $seq		= $reps->{$gen}->{'seq'};
            my $score	= $reps->{$gen}->{'score'};
            print "$gen\t$score\t$seq\n";
        }
    }
    return $reps;
}

# Assign representatives to each genome
sub assign_reps{
    my ($voters_path, $reps_path) = @_;

    my $voters 	= read_in($voters_path);
    my $reps 	= load_rep_set($reps_path, 0);

    my @keys = keys %$voters;
    my $l	= scalar @keys;

    print "GENOME	REPRESENTATIVE	SCORE\n";
    for my $key (@keys){
        my $seq 			= $voters->{$key}->{'seq'};
        my ($rep, $score)	= @{closest($seq, $reps)};
        print "$key	$rep	$score\n";
    }
}


1;
