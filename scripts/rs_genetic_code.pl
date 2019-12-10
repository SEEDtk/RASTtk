use strict;
use warnings;
use FIG_Config;
use Data::Dumper;
use ScriptUtils;
use rs;

$| = 1;
# Get the command-line parameters.
my $opt = ScriptUtils::Opts('',
    ['input|i=s', 	"input pheS sequence", 		{required => 1}],
    ['output|o=s', 	"output file"],
    ['reps_path=s', 	"path to representatives",	{default => "$FIG_Config::global/200reps.code.tbl"}],
);

my $reps_path = $opt->{'reps_path'};

open my $fh, '<', $reps_path;
my %code;
while (<$fh>){
    chomp $_;
    my ($gen, $score, $seq, $code) = split "\t", $_;
    $code{$gen} = $code;
}
close $fh;

my $seq = $opt->{'input'};

my $reps = &rs::load_rep_set($reps_path, 0);
my $closest_genome = &rs::closest($seq, $reps)->[0];

if ($opt->{'output'}){
    open my $fh_out, '>', $opt->{'output'} or die "Can't write to file \'$opt->{'output'}\' [$!]\n" ;
    print $fh_out $code{$closest_genome};
}
else{
    print $code{$closest_genome}
}
