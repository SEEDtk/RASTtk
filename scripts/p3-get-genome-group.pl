use strict;
use Getopt::Long::Descriptive;
use P3WorkspaceClient;
use Data::Dumper;
use JSON::XS;

my($opt, $usage) = describe_options("%c %o group-name",
				    ["help|h" => "Show this help message."]);
print($usage->text), exit 0 if $opt->help;
die($usage->text) if @ARGV != 1;

my $group = shift;

my $ws = P3WorkspaceClientExt->new();

my $home = $ws->home_workspace;
my $group_path = "$home/Genome Groups/$group";

my $raw_group = $ws->get({ objects => [$group_path] });
my($meta, $data_txt) = @{$raw_group->[0]};
my $data = decode_json($data_txt);
my @members = @{$data->{id_list}->{genome_id}};
print "$_\n" foreach @members;
