use strict;
use Getopt::Long::Descriptive;
use P3WorkspaceClient;
use Data::Dumper;
use JSON::XS;
use P3DataAPI;

my($opt, $usage) = describe_options("%c %o group-name",
				    ["help|h" => "Show this help message."]);
print($usage->text), exit 0 if $opt->help;
die($usage->text) if @ARGV != 1;

my $group = shift;

my $ws = P3WorkspaceClientExt->new();

my $home = $ws->home_workspace;
my $group_path = "$home/Feature Groups/$group";

my $raw_group = $ws->get({ objects => [$group_path] });
my($meta, $data_txt) = @{$raw_group->[0]};
my $data = decode_json($data_txt);
my @members = @{$data->{id_list}->{feature_id}};

my $api = P3DataAPI->new;
while (@members)
{
    my @chunk = splice(@members, 0, 500);
    my $qry = join(" OR ", map { "\"$_\"" } @chunk);
    my $res = $api->solr_query("genome_feature", { q => "feature_id:($qry)", fl => "feature_id,patric_id" });

    my %tmp;
    $tmp{$_->{feature_id}} = $_->{patric_id} foreach @$res;
    print "$tmp{$_}\n" foreach @chunk;
}
