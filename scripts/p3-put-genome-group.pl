use strict;
use Getopt::Long::Descriptive;
use P3WorkspaceClient;
use Data::Dumper;
use JSON::XS;

my($opt, $usage) = describe_options("%c %o group-name",
                                    ["show-error|e" => "Show verbose error messages"],
                                    ["help|h" => "Show this help message."]);
print($usage->text), exit 0 if $opt->help;
die($usage->text) if @ARGV != 1;

my $group = shift;

my $ws = P3WorkspaceClientExt->new();

my $home = $ws->home_workspace;
my $group_path = "$home/Genome Groups/$group";

my $group_list = [];
my $lines = 0;
while (<STDIN>)
{
    if (/^\s*(\d+\.\d+)\s*$/)
    {
        push(@$group_list, $1);
    }
    elsif ($lines)
    {
        my $errLine = $lines + 1;
        die "Invalid genome ID at line $errLine.\n";
    }
    $lines++;
}
my $group_data = { id_list => { genome_id => $group_list } };
my $group_txt = encode_json($group_data);

my $res;

eval {
    $res = $ws->create({
        objects => [[$group_path, "genome_group", {}, $group_txt]],
        permission => "w",
        overwrite => 1,
    });
};
if (!$res)
{
    die "Error creating genome group" . ($opt->show_error ? ": $@" : ());
}


