package P3DataAPI;

use LWP::UserAgent;
use strict;
use JSON::XS;
use Data::Dumper;
no warnings 'once';

eval {
    require FIG_Config;
};

our $default_url = $FIG_Config::p3_data_api_url || "https://www.patricbrc.org/api";

use warnings 'once';

sub new
{
    my($class, $url) = @_;

    $url ||= $default_url;
    my $self = {
	url => $url,
	chunk_size => 50000,
	ua => LWP::UserAgent->new(),
    };

    return bless $self, $class;
}

sub query
{
    my($self, $core, @query) = @_;

    my $qstr;

    my @q;
    for my $ent (@query)
    {
	my($k, @vals) = @$ent;
	if (@vals == 1 && ref($vals[0]))
	{
	    @vals = @{$vals[0]};
	}
	my $qe = "$k(" . join(",", @vals) . ")";
	push(@q, $qe);
    }
    $qstr = join("&", @q);

    my $url = $self->{url} . "/$core";
    my $ua = $self->{ua};
    my $done = 0;
    my $chunk = $self->{chunk_size};
    my $start = 0;

    my @result;
    while (!$done)
    {
	my $lim = "limit($chunk,$start)";
	my $q = "$qstr&$lim";
#       print STDERR "Qry $url '$q'\n";
#	my $resp = $ua->post($url,
#			     Accept => "application/json",
#			     Content => $q);
	my $resp = $ua->get("$url?$q", Accept => "application/json");
	if (!$resp->is_success)
	{
	    die "Failed: " . $resp->code . "\n" . $resp->content;
	}
	my $data = decode_json($resp->content);
	push @result, @$data;
#        print STDERR scalar(@$data) . " results found.\n";
	my $r = $resp->header('content-range');
#	print "r=$r\n";
	if ($r =~ m,items\s+(\d+)-(\d+)/(\d+),)
	{
	    my $this_start = $1;
	    my $next = $2;
	    my $count = $3;

	    last if ($next >= $count);
	    $start = $next;
	}
    }
    return @result;
}

    
