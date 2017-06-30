    use strict;
    use warnings;
    use LWP::UserAgent;
    use HTTP::Request;
    use SeedUtils;
    use URI;
    use P3DataAPI;
    use Crypt::RC4;

use constant RAST_URL => 'https://p3.theseed.org/rast/quick';
my $user;
my $passfile = $P3DataAPI::token_path . "-code";
open(my $ph, "<$P3DataAPI::token_path") || die "User not logged in: $!";
my $token = <$ph>;
if ($token =~ /un=([^|]+)\@patricbrc\.org/) {
    $user = $1;
} else {
    die "Invalid format in login token.";
}
undef $ph;
open($ph, "<$passfile") || die "User not logged in: $!";
my $unpacked = <$ph>;
my $encrypted = pack('H*', $unpacked);
my $ref = Crypt::RC4->new($user);
my $pass = $ref->RC4($encrypted);
my ($jobID) = @ARGV;
# Create an authorization header.
my $header = HTTP::Headers->new(Content_Type => 'text/plain');
my $userURI = "$user\@patricbrc.org";
$header->authorization_basic($userURI, $pass);
# Form a request for retreiving the job status.
my $url = join("/", RAST_URL, $jobID, 'status');
my $request = HTTP::Request->new(GET => $url, $header);
# Check the status.
my $ua = LWP::UserAgent->new();
my $response = $ua->request($request);
if ($response->code ne 200) {
    die "Error response for RAST status: " . $response->message;
} else {
     my $status = $response->content;
     print STDERR "Status = $status.\n";
}