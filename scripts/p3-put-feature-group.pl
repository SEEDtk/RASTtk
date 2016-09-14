use strict;
use Getopt::Long::Descriptive;
use P3WorkspaceClient;
use Data::Dumper;
use P3DataAPI;
use JSON::XS;

my($opt, $usage) = describe_options("%c %o group-name",
				    ["show-error|e" => "Show verbose error messages"],
				    ["help|h" => "Show this help message."]);
print($usage->text), exit 0 if $opt->help;
die($usage->text) if @ARGV != 1;

my $group = shift;

my $ws = P3WorkspaceClientExt->new();

my $home = $ws->home_workspace;
my $group_path = "$home/Feature Groups/$group";

my @patric_ids;

while (<STDIN>)
{
    if (/^\s*(fig\|\d+\.\d+\S+)\s*$/)
    {
	push(@patric_ids, $1);
    }
    else
    {
	die "Invalid genome ID at line $.\n";
    }
}
my $feature_list;

my $api = P3DataAPI->new;
while (@patric_ids)
{
    my @chunk = splice(@patric_ids, 0, 500);
    my $qry = join(" OR ", map { "\"$_\"" } @chunk);
    my $res = $api->solr_query("genome_feature", { q => "patric_id:($qry)", fl => "feature_id,patric_id" });

    my %tmp;
    $tmp{$_->{patric_id}} = $_->{feature_id} foreach @$res;

    push(@$feature_list, $tmp{$_}) foreach @chunk;
}

my $group_data = { id_list => { feature_id => $feature_list } };
my $group_txt = encode_json($group_data);

my $res;

eval {
    $res = $ws->create({
	objects => [[$group_path, "feature_group", {}, $group_txt]],
	permission => "w",
	overwrite => 1,
    });
};
if (!$res)
{
    die "Error creating feature group" . ($opt->show_error ? ": $@" : ());
}


