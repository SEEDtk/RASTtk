package P3DataAPI;

# This is a SAS Component

# Updated for new PATRIC.

use File::Temp;
use LWP::UserAgent;
use strict;
use JSON::XS;
use gjoseqlib;
use URI::Escape;
use Digest::MD5 'md5_hex';
use Time::HiRes 'gettimeofday';
use DBI;
use HTTP::Request::Common;
use Data::Dumper;
eval {
    require IPC::Run;
};
use SeedUtils;
our $have_redis;

our $have_async;
eval {
    require Net::HTTPS::NB;
    require HTTP::Async;
    $have_async = 1;
};

our $have_p3auth;
eval {
    require P3AuthToken;
    $have_p3auth = 1;
};

use IO::Socket::SSL;

$IO::Socket::SSL::DEBUG = 0;

IO::Socket::SSL::set_ctx_defaults(
                                       SSL_verifycn_scheme => 'www',
                                       SSL_verify_mode => 0,
                                  );

no warnings 'once';

eval { require FIG_Config; };

our $default_url = $FIG_Config::p3_data_api_url
  || "https://p3.theseed.org/services/data_api";

our %family_field_of_type = (plfam => "plfam_id",
                             pgfam => "pgfam_id",
                             figfam => "figfam_id",
                             fig => "figfam_id",
                             );

our %sql_fam_to_family_type = (L => "plfam",
                               G => "pgfam");
our %family_type_to_sql = (plfam => "L",
                           pgfam => "G");

our %typemap = (CDS => 'peg');

our $token_path;
if ($^O eq 'MSWin32')
{
    my $dir = $ENV{HOME} || $ENV{HOMEPATH};
    if (! $dir) {
        require FIG_Config;
        $dir = $FIG_Config::userHome;
    }
    $token_path = "$dir/.patric_token";
} else {
    $token_path = "$ENV{HOME}/.patric_token";
}

use warnings 'once';

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(qw(benchmark chunk_size url ua reference_genome_cache
                             family_db_dsn family_db_user
                             feature_db_dsn feature_db_user
                             debug redis
                            ));

our %EncodeMap = ('<' => '%60', '=' => '%61', '>' => '%62', '"' => '%34', '#' => '%35', '%' => '%37',
                  '+' => '%43', '/' => '%47', ':' => '%58', '{' => '%7B', '|' => '%7C', '}' => '%7D',
                  '^' => '%94', '`' => '%96',);

sub new {
    my ( $class, $url, $token, $params ) = @_;

    if ($token)
    {
        if (ref($token) eq 'P3AuthToken')
        {
            $token = $token->token();
        }
    }
    else
    {
        if ($have_p3auth)
        {
            my $token_obj = P3AuthToken->new();
            if ($token_obj)
            {
                $token = $token_obj->token;
            }
        }
        else
        {
            if (open(my $fh, "<", $token_path))
            {
                $token = <$fh>;
                chomp $token;
                close($fh);
            }
        }
    }

    $url ||= $default_url;
    my $self = {
        url        => $url,
        chunk_size => 25000,
        ua         => LWP::UserAgent->new(),
        token      => $token,
        benchmark  => 0,
        reference_genome_cache => undef,
        family_db_dsn => "DBI:mysql:database=fams_2016_0819;host=fir.mcs.anl.gov",
        family_db_user => 'p3',
        feature_db_dsn => "DBI:mysql:database=patric_features;host=fir.mcs.anl.gov",
        feature_db_user => 'olson',
        # redis_expiry_time => 86400,
        redis_expiry_time => 600,
        (ref($params) eq 'HASH' ? %$params : ()),
    };

    if ($params->{redis_host} && $params->{redis_port})
    {
        eval {
            require Redis::Client;
            require Redis::Client::List;
            $have_redis = 1;
        };
        if ($have_redis)
        {
            $self->{redis} = Redis::Client->new(host => $params->{redis_host}, port => $params->{redis_port});
        }
        else
        {
            warn "Redis requested but Redis::Client not available in this perl environment";
        }
    }

    return bless $self, $class;
}

sub auth_header {
    my ($self) = @_;
    if ( $self->{token} ) {
        return ( "Authorization", $self->{token} );
    } else {
        return ();
    }
}

=head3 query

    my @rows = $d->query($core, @query);

Run a query against the PATRIC database. Automatic flow control is used to reduce the possibility of timeout or overrun
errors.

=over 4

=item core

The name of the PATRIC object to be queried.

=item query

A list of query specifications, consisting of zero or more tuples. The first element of each tuple is a specification type,
which must be one of the following.

=over 8

=item select

Specifies a list of the names for the fields to be returned. There should only be one C<select> tuple. If none is present,
all the fields will be returned.

=item eq

Specifies a field name and matching value. This forms a constraint on the query. If the field is a string field, the
constraint will be satisfied if the value matches a substring of the field value. If the field is a numeric field, the
constraint will be satisfied if the value exactly matches the field value. In the string case, an interior asterisk can
be used as a wild card.

=item in

Specifies a field name and a string containing a comma-delimited list of matching values enclosed in parentheses. This forms
a constraint on the query. It works much like C<eq>, except the constraint is satisfied if the field value matches any one of
the specified values. This is the only way to introduce OR-like functionality into the query.

=item sort

Specifies a list of field names, each prefixed by a C<+> or C<->. The output will be sorted in the fashion indicated by
the field names, ascending for C<+>, descending for C<->.

=back

Note that parentheses must be manually removed from field values and special characters in the database are frequently
ignored during string matches.

=item RETURN

Returns a list of tuples for the records matched, with one value per field.

=back

=cut

sub query
{
    my ( $self, $core, @query ) = @_;

    my $qstr;
    my $started;
    my $limitFound;

    my @q;
    for my $ent (@query) {
        my ( $k, @vals ) = @$ent;
        if ( @vals == 1 && ref( $vals[0] ) ) {
            @vals = @{ $vals[0] };
        }
        if ($k eq 'limit') {
            $limitFound = $vals[0];
        } else {
            my $qe = "$k(" . join( ",", @vals ) . ")";
            push( @q, $qe );
        }
    }
    $qstr = join( "&", @q );

    my $url   = $self->{url} . "/$core";
    my $ua    = $self->{ua};
    my $done  = 0;
    my $chunk = $self->{chunk_size};
    my $start = 0;

    my @result;
    while ( !$done ) {
        my $lim;
        if (! $limitFound) {
            $lim = "limit($chunk,$start)";
        } else {
            $lim = "limit($limitFound,0)";
            $done = 1;
        }
        my $q   = "$qstr&$lim";

        #       print STDERR "Qry $url '$q'\n";
        #	my $resp = $ua->post($url,
        #			     Accept => "application/json",
        #			     Content => $q);
        my $end;
        $start = gettimeofday if $self->{benchmark};
        # Form url-encoding
        $q =~ s/([<>"#\%+\/{}\|\\\^\[\]:`])/$P3DataAPI::EncodeMap{$1}/gs;
        $q =~ tr/ /+/;
        # POST query
        $self->_log("$url?$q\n");
        my $resp = $ua->post($url,
                             Accept => "application/json",
                             $self->auth_header,
                             Content => $q,
                        );
        # print STDERR Dumper($resp);
        $end = gettimeofday if $self->{benchmark};
        if ( !$resp->is_success ) {
            my $content = $resp->content || $q;
            die "Failed: " . $resp->code . " $content\nURL = $core?$q";
        }
        if ( $self->{benchmark} ) {
            my $elap = $end - $start;
            print STDERR "$elap\n";
        }
        # print STDERR $resp->content;
        my $data = decode_json( $resp->content );
        push @result, @$data;

        #        print STDERR scalar(@$data) . " results found.\n";
        my $r = $resp->header('content-range');

        #	print "r=$r\n";
        if ( $r =~ m,items\s+(\d+)-(\d+)/(\d+), ) {
            my $this_start = $1;
            my $next       = $2;
            my $count      = $3;
            if (! $started) {
                $self->_log("$count results expected.\n");
                $started = 1;
            }
            last if ( $next >= $count );
            $start = $next;
        }
    }
    return @result;
}

=head3 query_cb

    $d->query($core, $callback, @query);

Run a query against the PATRIC database. Automatic flow control is used to reduce the possibility of timeout or overrun
errors.

The callback provided is invoked for each chunk of data returned from the database.

=over 4

=item core

The name of the PATRIC object to be queried.

=item callback

A code reference which will be invoked for each chunk of data returned from the database.

The callback is invoked with two parameters: an array reference containing the data returned, and a
hash reference containing the following metadata about the lookup:

=over 4

=item start

The starting index in the overall result set of the first item returned.

=item next

The starting index for the next result set at the server.

=item count

The number of items in the entire result set.

=item last_call

A value which will be true if this invocation of the callback is the final one.

=back

The return value of the callback is used to determine if the query will continue to be executed.
A true value will cause the next page of results to be requested; a false value will
terminate the query, resulting in the query_cb call to return.

=item query

A list of query specifications, consisting of zero or more tuples. The first element of each tuple is a specification type,
which must be one of the following.

=over 8

=item select

Specifies a list of the names for the fields to be returned. There should only be one C<select> tuple. If none is present,
all the fields will be returned.

=item eq

Specifies a field name and matching value. This forms a constraint on the query. If the field is a string field, the
constraint will be satisfied if the value matches a substring of the field value. If the field is a numeric field, the
constraint will be satisfied if the value exactly matches the field value. In the string case, an interior asterisk can
be used as a wild card.

=item in

Specifies a field name and a string containing a comma-delimited list of matching values enclosed in parentheses. This forms
a constraint on the query. It works much like C<eq>, except the constraint is satisfied if the field value matches any one of
the specified values. This is the only way to introduce OR-like functionality into the query.

=item sort

Specifies a list of field names, each prefixed by a C<+> or C<->. The output will be sorted in the fashion indicated by
the field names, ascending for C<+>, descending for C<->.

=back

Note that parentheses must be manually removed from field values and special characters in the database are frequently
ignored during string matches.

=back

=cut

sub query_cb {
    my ( $self, $core, $cb_add, @query ) = @_;

    my $qstr;

    my @q;
    for my $ent (@query)
    {
        my ($k, @vals) = @$ent;

        if (@vals == 1 && ref( $vals[0]))
        {
            @vals = @{ $vals[0] };
        }
        my $qe = "$k(" . join(",", @vals) . ")";
        push(@q, $qe);
    }
    $qstr = join("&", @q);

    my $url   = $self->{url} . "/$core";
    my $ua    = $self->{ua};
    my $done  = 0;
    my $chunk = $self->{chunk_size};
    my $start = 0;

    my @result;
    while (!$done)
    {
        my $lim = "limit($chunk,$start)";
        my $q   = "$qstr&$lim";
        my $qurl = "$url?$q";

        my $resp = $ua->post($url,
                             Accept => "application/json",
                             $self->auth_header,
                             Content => $q,
                           );
        if (!$resp->is_success)
        {
            die "Failed: " . $resp->code . "\n" . $resp->content . "\n    for query '$q'\n";
        }

        my $data = eval { decode_json( $resp->content ); };
        if ($@)
        {
            die "Error parsing response content:  $@";
        }

        my $r = $resp->header('content-range');

        if ($r =~ m,items\s+(\d+)-(\d+)/(\d+),)
        {
            my $this_start = $1;
            my $next       = $2;
            my $count      = $3;

            my $last_call = $next >= $count;

            my $continue = $cb_add->($data,
                         {
                             start => $this_start,
                             next => $next,
                             count => $count,
                             last_call => ($last_call ? 1 : 0),
                         });

            last if (!$continue || $last_call);
            $start = $next;
        }
        else
        {
            die "Could not parse content-range header '$r'\n";
        }
    }
}

#
# Perform a solr-encoded query.
#

sub solr_query_raw
{
    my($self, $core, $params) = @_;

    my $uri = URI->new($self->url . "/$core");

    my %params;
    while (my($k, $v) = each %$params)
    {
        if (ref($v) eq 'ARRAY')
        {
            $v = join(",", @$v);
        }
        $params{$k} = $v;
    }
    # $uri->query_form(\%params);

    my($s, $e);
    if ($self->debug)
    {
        $s = gettimeofday;
        print STDERR "SQ: $uri " . join(" ", map { "$_ = '$params{$_}'" } sort keys %params), "\n";
    }
    # print STDERR "Query url: $uri\n";
    my $res = $self->ua->post($uri,
                              \%params,
                             "Content-type" => "application/solrquery+x-www-form-urlencoded",
                             "Accept", "application/solr+json",
                             $self->auth_header,
                            );
    if ($self->debug)
    {
        my $e = gettimeofday;
        my $elap = $e - $s;
        print STDERR "Done elap=$elap\n";
    }
    if ($res->is_success)
    {
        my $out = decode_json($res->content);
        return $out;
    }
    else
    {
        die "Query failed: " . $res->code . " " . $res->content;
    }
}

sub solr_query_raw_multi
{
    my($self, $queries) = @_;

    $have_async or die "HTTP::Async not available";

    my $async = HTTP::Async->new();
    my %resmap;
    for my $i (0..$#$queries)
    {
        my $qry = $queries->[$i];
        my($core, $params) = @$qry;

        my $uri = URI->new($self->url . "/$core");

        my %params = (start => 0, rows => 25000);
        while (my($k, $v) = each %$params)
        {
            if (ref($v) eq 'ARRAY')
            {
                $v = join(",", @$v);
            }
            $params{$k} = $v;
        }

        $uri->query_form(\%params);

        # print STDERR "Query url: $uri\n";

        my $req = GET($uri,
                      "Content-type" => "application/solrquery+x-www-form-urlencoded",
                      "Accept", "application/solr+json",
                      $self->auth_header);

        my $id = $async->add($req);
        $resmap{$id} = $i;

        # my $res = $self->ua->get($uri,
        # 			 "Content-type" => "application/solrquery+x-www-form-urlencoded",
        # 			 "Accept", "application/solr+json",
        # 			 $self->auth_header,
        # 			);
    }

    my @out;
    while ($async->not_empty)
    {
        my($res,$id) = $async->wait_for_next_response();

        my $n = $resmap{$id};
        # print STDERR "Response $id (orig $n) returns\n";

        if ($res->is_success)
        {
            my $doc = decode_json($res->content);
            # print Dumper($res,$doc);

            if (ref($doc) eq 'HASH')
            {
                my $resp = $doc->{response};
                my $ndocs = @{$resp->{docs}};

                $out[$n] = $resp->{docs};
            }
            else
            {
                $out[$n] = [];
                print STDERR "Empty response for $n: " . Dumper($doc) . "\n";
            }
        }
        else
        {
            no warnings 'once';
            warn "Query failed: " . $res->code . " " . $res->content . "\n" . "error=$Net::HTTPS::NB::HTTPS_ERROR\n";
        }
    }
    return @out;
}

#
# Invoke solr_query_raw repeatedly to get all values.
#

sub solr_query
{
    my($self, $core, $params, $max_count) = @_;

    my $start = 0;
    my $block_size = 25000;
    my $count = (!defined($max_count) || $max_count > $block_size) ? $block_size : $max_count;

    my $n = 0;
    my @out;
    while (1)
    {
        my $doc = $self->solr_query_raw($core, { %$params, start => $start, rows => $count });
        ref($doc) eq 'HASH' or die "solr query failed: " . Dumper($doc, $params);
        my $resp = $doc->{response};
        my $ndocs = @{$resp->{docs}};
        $n += $ndocs;

        # print STDERR "ndocs=$ndocs $n=$n nfound=$resp->{numFound}\n";
        push(@out, @{$resp->{docs}});

        $start += $ndocs;
        last if (defined($max_count) && $n >= $max_count) || $n >= $resp->{numFound};
    }
    return \@out;
}

sub retrieve_contigs_in_genomes {
    my ( $self, $genome_ids, $target_dir, $path_format ) = @_;

    for my $gid (@$genome_ids) {
        my $gid_fh;

        $self->query_cb(
            "genome_sequence",
            sub {
                my ($data) = @_;
                if ( !$gid_fh ) {
                    my $fname = "$target_dir/" . sprintf( $path_format, $gid );
                    open( $gid_fh, ">", $fname )
                      or die "cannot open $fname: $!";
                }
                for my $ent (@$data) {
                    print_alignment_as_fasta(
                        $gid_fh,
                        [
                            "accn|$ent->{sequence_id}",
"$ent->{description} [ $ent->{genome_name} | $ent->{genome_id} ]",
                            $ent->{sequence}
                        ]
                    );
                }
                return 1;
            },
            [ "eq", "genome_id", $gid ]
        );

        close($gid_fh);
    }

}

=head3 B<lookup_sequence_data>

Given a list of MD5s, retrieve the corresponding sequence data.
Invoke the callback for each one.

=cut

sub lookup_sequence_data
{
    my($self, $ids, $cb) = @_;

    my $batchsize = 500;
    my @goodIds = grep { $_ } @$ids;
    my $n = @goodIds;
    my $end;
    for (my $i = 0; $i < $n; $i = $end + 1)
    {
        $end = ($i + $batchsize) > $n ? ($n - 1) : ($i + $batchsize - 1);
        $self->_log("Processing $i to $end.\n");
        $self->query_cb('feature_sequence',
                        sub {
                            my($data) = @_;
                            for my $ent (@$data)
                            {
                                $cb->($ent);
                            }
                        },
                        ['select', 'sequence,md5,sequence_type'],
                        ['in', 'md5', '(' . join(",", @goodIds[$i .. $end]) . ')']);
    }
}

=head3 B<lookup_sequence_data_hash>

Like L<lookup_sequence_data> but return a hash mapping md5 => sequence data.

=cut

sub lookup_sequence_data_hash
{
    my($self, $ids) = @_;

    my %by_md5;
    $self->lookup_sequence_data($ids, sub {
        my $ent = shift;
        $by_md5{$ent->{md5}} = $ent->{sequence};
    });
    return \%by_md5;
}

sub retrieve_contigs_in_genome_to_temp {
    my ($self, $genome_id) = @_;

    my $temp = File::Temp->new();

    $self->query_cb("genome_sequence",
                    sub {
                        my ($data) = @_;
                        for my $ent (@$data) {
                            print_alignment_as_fasta($temp,
                                                     ["accn|$ent->{sequence_id}",
                                                      "$ent->{description} [ $ent->{genome_name} | $ent->{genome_id} ]",
                                                      $ent->{sequence}]);
                        }
                        return 1;
                    },
                    [ "eq", "genome_id", $genome_id ]
                   );
    close($temp);
    return($temp);
}

sub compute_contig_md5s_in_genomes {
    my ( $self, $genome_ids ) = @_;

    my $out = {};

    for my $gid (@$genome_ids) {
        my $gid_fh;

        $self->query_cb(
            "genome_sequence",
            sub {
                my ($data) = @_;
                for my $ent (@$data) {
                    my $md5 = md5_hex( lc( $ent->{sequence} ) );
                    $out->{$gid}->{ $ent->{sequence_id} } = $md5;
                }
                return 1;
            },
            [ "eq", "genome_id", $gid ]
        );

    }
    return $out;
}

=head3 B<retrieve_protein_features_in_genomes>

Looks up and returns all protein features from the genome.

Unique proteins by MD5 checksum are written to C<$fasta_file> and a mapping from
MD5 checksum to list of feature IDs is written to C<$id_map_file>.

=cut

sub retrieve_protein_features_in_genomes {
    my ( $self, $genome_ids, $fasta_file, $id_map_file ) = @_;

    my ( $fasta_fh, $id_map_fh );
    open( $fasta_fh, ">", $fasta_file ) or die "Cannot write $fasta_file: $!";
    open( $id_map_fh, ">", $id_map_file )
      or die "Cannot write $id_map_file: $!";

    my %map;

    #
    # Query for features.
    #

    for my $gid (@$genome_ids) {
        $self->query_cb(
            "genome_feature",
            sub {
                my ($data) = @_;
                for my $ent (@$data) {
                    push(@{ $map{ $ent->{aa_sequence_md5} } },
                         $ent->{patric_id});
                }
                return 1;
            },
            [ "eq",     "feature_type", "CDS" ],
            [ "eq",     "genome_id",    $gid ],
            [ "select", "patric_id,aa_sequence_md5" ],
        );
    }

    #
    # Query for sequences.
    #
    $self->lookup_sequence_data([keys %map], sub {
        my($ent) = @_;
        print_alignment_as_fasta($fasta_fh, [$ent->{md5}, undef, $ent->{sequence}]);
    });

    close($fasta_fh);

    while ( my ( $k, $v ) = each %map ) {

        print $id_map_fh join( "\t", $k, @$v ), "\n";
    }
    close($id_map_fh);
}

sub retrieve_protein_feature_sequence {
    my ( $self, $fids) = @_;

    my %map;

    #
    # Query for features.
    #

    $self->query_cb("genome_feature",
                    sub {
                        my ($data) = @_;
                        for my $ent (@$data) {
                            push(@{ $map{ $ent->{aa_sequence_md5} } },
                                 $ent->{patric_id});
                        }
                        return 1;
                    },
                    [ "eq",     "feature_type", "CDS" ],
                    [ "in",     "patric_id", "(" . join(",", map { uri_escape($_) } @$fids) . ")"],
                    [ "select", "patric_id,aa_sequence_md5" ],
                   );

    #
    # Query for sequences.
    #

    my $seqs = $self->lookup_sequence_data_hash([keys %map]);

    my %out;
    while ( my ( $k, $v ) = each %map )
    {
        $out{$_} = $seqs->{$k} foreach @$v;
    }
    return \%out;
}

sub retrieve_protein_features_in_genome_in_export_format {
    my ( $self, $genome_id, $fasta_fh ) = @_;

    my $on_feature =  sub {
        my ($data) = @_;

        my %by_md5;

        $self->lookup_sequence_data([map { $_->{aa_sequence_md5} } @$data ], sub {
            my $ent = shift;
            $by_md5{$ent->{md5}} = $ent;
        });

        for my $ent (@$data) {
            my $def = "  $ent->{product} [$ent->{genome_name} | $genome_id]";
            print_alignment_as_fasta($fasta_fh,
                                     [
                                      $ent->{patric_id},
                                      $def,
                                      $by_md5{$ent->{aa_sequence_md5}}->{sequence}
                                      ]
                                    );
        }
        return 1;
    };

    $self->query_cb("genome_feature",
                    $on_feature,
                    [ "eq",     "feature_type", "CDS" ],
                    [ "eq",     "genome_id",    $genome_id ],
                    [ "select", "patric_id,aa_sequence_md5,genome_name,product" ],
                   );
}

#
# Side effect, returns list of features and family/function data.
#
sub retrieve_protein_features_in_genomes_to_temp {
    my ( $self, $genome_ids ) = @_;

    my $temp = File::Temp->new();

    my %map;

    my $ret_list;
    $ret_list = [] if wantarray;

    for my $gid (@$genome_ids) {
        $self->query_cb(
            "genome_feature",
            sub {
                my ($data) = @_;

                my %by_md5;

                $self->lookup_sequence_data([map { $_->{aa_sequence_md5} } @$data ], sub {
                    my $ent = shift;
                    $by_md5{$ent->{md5}} = $ent->{sequence};
                });

                for my $ent (@$data) {
                    print_alignment_as_fasta($temp,
                                             [
                                              $ent->{patric_id}, $ent->{product},
                                              $by_md5{$ent->{aa_sequence_md5}}
                                              ]
                                            );
                    push(@$ret_list, [@$ent{qw(patric_id product plfam_id pgfam_id)}]) if $ret_list;
                }
                return 1;
            },
            [ "eq",     "feature_type", "CDS" ],
             [ "eq", "annotation", "PATRIC"],
            [ "eq",     "genome_id",    $gid ],
            [ "select", "patric_id,product,aa_sequence_md5,plfam_id,pgfam_id" ],
        );
    }
    close($temp);
    return wantarray ? ($temp, $ret_list) : $temp;
}

sub _escape_role_for_search
{
    my($self, $role) = @_;

    $role =~ s/\s*\([ET]C.*\)\s*$//;
    $role =~ s/^\s+//;
    $role =~ s/\s+$//;

    my $esc_role = uri_escape( $role, " " );
    $esc_role =~ s/\(.*$/*/;

    return($role, $esc_role);
}

sub retrieve_protein_features_with_role {

    my ( $self, $role ) = @_;

    return $self->retrieve_features_of_type_with_role('CDS', $role);
}

sub retrieve_features_of_type_with_role {
    my ( $self, $type, $role ) = @_;

    my @out;

    ($role, my $esc_role) = $self->_escape_role_for_search($role);

    my $md5_field = ($type eq "CDS") ? 'aa_sequence_md5' : 'na_sequence_md5';

    my %misses;
    $self->query_cb(
        "genome_feature",
        sub {
            my ($data) = @_;
            my @lout;
            my %ids;
            for my $ent (@$data) {
                my $fn = $ent->{product};
                $fn =~ s/\s*\(EC.*\)\s*$//;

                $fn =~ s/\s*#.*$//;

                $fn =~ s/^\s*//;
                $fn =~ s/\s*$//;

                if ( $fn eq $role ) {
                    push( @lout, [ $ent->{genome_id}, $ent->{$md5_field} ] );
                    $ids{$ent->{$md5_field}} = 1;
                    # print "$ent->{patric_id} $fn\n";
                } else {
                    $misses{$fn}++;
                }
            }
            my $seqs = $self->lookup_sequence_data_hash([keys %ids]);
            push(@out, [$_->[0], $seqs->{$_->[1]}]) foreach @lout;
            return 1;
        },
        [ "eq", "feature_type", $type ],
        [ "eq", "patric_id", "*"],
        [ "eq", "annotation",   "PATRIC" ],
        [ "eq", "product",      $esc_role ],
        [ "select", "genome_id,$md5_field,product,patric_id" ],
    );

    if (%misses) {
        print STDERR "Misses for $role:\n";
        for my $f ( sort keys %misses ) {
            print STDERR "$f\t$misses{$f}\n";
        }
    }

    return @out;
}

sub retrieve_ssu_rnas {
    my ( $self, $genome ) = @_;

    my @out;

    my $qry;
    if ( ref($genome) ) {
        my $q = join( ",", @$genome );
        $qry = [ "in", "genome_id", "($q)" ];
    } else {
        $qry = [ "eq", "genome_id", $genome ];
    }

    $self->query_cb(
        "genome_feature",
        sub {
            my ($data) = @_;
            my %ids;
            my @lout;
            for my $ent (@$data) {
                my $fn = $ent->{product};
                if ( $fn =~
/(SSU\s+rRNA|Small\s+Subunit\s+(Ribosomal\s+r)?RNA|ssuRNA|16S\s+(r(ibosomal\s+)?)?RNA)/io
                  )
                {
                    push( @lout, $ent );
                    $ids{$ent->{na_sequence_md5}} = 1;
                }
            }
            my $seqs = $self->lookup_sequence_data_hash([keys %ids]);
            for my $ent (@lout)
            {
                $ent->{na_sequence} = $seqs->{$ent->{na_sequence_md5}};
                push(@out, $ent);
            }
            return 1;
        },
        [ "eq", "feature_type", "rrna" ],
        [ "eq", "annotation",   "PATRIC" ],
        $qry,
        [ "select", "genome_id,na_sequence_md5,product,patric_id" ],
    );
    return @out;
}

sub retrieve_genome_metadata {
    my ( $self, $genomes, $keys ) = @_;

    my @out;

    my $qry;
    if ( ref($genomes) ) {
        my $q = join( ",", @$genomes );
        $qry = [ "in", "genome_id", "($q)" ];
    } else {
        $qry = [ "eq", "genome_id", $genomes ];
    }

    $self->query_cb(
        "genome",
        sub {
            my ($data) = @_;
            push( @out, @$data );
            return 1;
        },
        $qry,
        [ "select", @$keys ]
    );
    return @out;
}

sub retrieve_protein_features_in_genomes_with_role {
    my ( $self, $genome_ids, $role ) = @_;

    my @out;

    for my $gid (@$genome_ids) {
        $self->query_cb(
            "genome_feature",
            sub {
                my ($data) = @_;
                my @lout;
                my %ids;
                for my $ent (@$data) {
                    push( @lout, [ $gid, $ent->{aa_sequence_md5} ] );
                    $ids{$ent->{aa_sequence_md5}} = 1;
                    # print "$ent->{patric_id} $ent->{product}\n";
                }
                my $seqs = $self->lookup_sequence_data_hash([keys %ids]);
                push(@out, [$_->[0], $seqs->{$_->[1]}]) foreach @lout;

                return 1;
            },
            [ "eq", "feature_type", "CDS" ],
            [ "eq", "annotation",   "PATRIC" ],
            [ "eq", "genome_id",    $gid ],
            [ "eq", "product",      $role ],
            [
                "select",
                "feature_id,aa_sequence_md5,product,patric_id"
            ],
        );
    }
    return @out;
}

sub retrieve_dna_features_in_genomes {
    my ( $self, $genome_ids, $fasta_file, $id_map_file ) = @_;

    my ( $fasta_fh, $id_map_fh );
    open( $fasta_fh, ">", $fasta_file ) or die "Cannot write $fasta_file: $!";
    open( $id_map_fh, ">", $id_map_file )
      or die "Cannot write $id_map_file: $!";

    my %map;

    for my $gid (@$genome_ids) {
        $self->query_cb(
            "genome_feature",
            sub {
                my ($data) = @_;
                for my $ent (@$data) {
                    push( @{ $map{$ent->{na_sequence_md5}} }, $ent->{patric_id} );
                }
                return 1;
            },
                        [ "eq",     "genome_id", $gid ],
                        [ "eq", "patric_id", "*"],
                        [ "select", "patric_id,na_sequence_md5" ],
        );
    }
    #
    # Query for sequences.
    #
    $self->lookup_sequence_data([keys %map], sub {
        my($ent) = @_;
        print_alignment_as_fasta($fasta_fh, [$ent->{md5}, undef, $ent->{sequence}]);
    });
    close($fasta_fh);
    while ( my ( $k, $v ) = each %map ) {
        print $id_map_fh join( "\t", $k, @$v ), "\n";
    }
    close($id_map_fh);
}

#
# context is used to pick the set of genomes we compare to.
# If blank, we use all that are returned from the service that maps
# our peg to groups.
# If it is a tuple ['group', 'group-name'] we use
# group-name as the context. Further, we make use of the precomputed
# families to both find the pin and (optionally) to color the regions. Regions
# may still be colored by pgfam/plfam.
#

sub compare_regions_for_peg_new
{
    my($self, $peg, $width, $n_genomes, $coloring_method, $context) = @_;

    $coloring_method = 'pgfam' unless $family_field_of_type{$coloring_method};
    my $coloring_field = $family_field_of_type{$coloring_method};

    my $fids;
    print STDERR "compare_regions_for_peg: context=$context\n";

    if (!$context)
    {
#	$context = ['group', 'pheS.3.0-1.1'];
#	$coloring_field = 'group_family';
    }

    my $group_data;
    if (ref($context) eq 'ARRAY')
    {
        if ($context->[0] eq 'group')
        {
            my $group = $context->[1];
            $fids = $self->compute_pin_features_for_group($group, $peg, $n_genomes);

            #
            # Hack - side effect of compute_pin_features_for_group is to fill the cache
            #
            $group_data = $self->{_group_cache}->{$group};
        }
        else
        {
            die "Unknown context type '$context->[0]'\n";
        }
    }
    else
    {
        $fids = $self->compute_pin_features_by_family_lookup($peg, $n_genomes);
    }

    my $colored;
    eval {

    my @p = $self->expand_fids_to_pin($fids, [$coloring_field]);

    my @q = $self->compute_pin_alignment(\@p, $n_genomes);
    # print Dumper(\@q);
    my($regions, $all_features) = $self->expand_pin_to_regions(\@q, $width, $group_data);
    # print Dumper($regions, $all_features);

    my($key_feature) = grep { $_->{fid} eq $peg } @{$regions->[0]->{features}};
    my $key_coloring_val = $key_feature->{$coloring_field};

     $colored = $self->color_regions_by_field($regions, $all_features, $coloring_field, $key_coloring_val);
};
  if ($@)
  {
      die "FAILURE: $@\n";
  }
    return $colored;
}

sub compute_pin_features_for_group
{
    my($self, $group, $peg, $n_genomes) = @_;

    #
    # Cache group data if not yet loaded.
    #
    if (!$self->{_group_cache}->{$group})
    {
        my $fid_to_fam = {};
        my $fam_to_fid = {};
        open(F, "<", "/scratch/olson/$group/families.all") or die "cannot load belarus: $!";
        while (<F>)
        {
            chomp;
            my($fam, $fun, $subfam, $fid) = split(/\t/);
            push @{$fam_to_fid->{$fam}}, $fid;
            $fid_to_fam->{$fid} = $fam;
        }
        $self->{_group_cache}->{$group} = { fid_to_fam => $fid_to_fam, fam_to_fid => $fam_to_fid };
    }

    my($fid_to_fam, $fam_to_fid) = @{$self->{_group_cache}->{$group}}{qw(fid_to_fam fam_to_fid)};

    my $fam = $fid_to_fam->{$peg};
    my $fids = $fam_to_fid->{$fam};
    return [$peg, grep { $_ ne $peg } @$fids];
}

## FIX - defer, not used currently. New functionality to be resumed.
sub compute_pin_features_by_family_lookup
{
    my($self, $peg, $n_genomes) = @_;

    #
    # Get AA sequence of protein
    #

    my($fid_sequence) = $self->retrieve_protein_feature_sequence([$peg]);
    my $peg_trans = $fid_sequence->{$peg};

    # print Dumper($fid_data);

    #
    # Perform a kmer / fam lookup
    #

    my $ua = LWP::UserAgent->new();
    my $url = "http://spruce:6100/lookup";
    # my $url = "http://pear:6900/lookup?find_reps=1";
    my $res = $ua->post($url, "Content" => ">$peg\n$peg_trans\n");
    if (!$res->is_success)
    {
        die "lookup failed: " . $res->content;
    }
    my $txt = $res->content;
    open(S, "<", \$txt) or die;
    my $x = <S>;
    chomp $x;
    if ($x ne $peg)
    {
        die "Unexpected fid $x\n";
    }
    my @sets;
    while (<S>)
    {
        chomp;
        last if $_ eq '//';
        my($score, undef, $scaled, $pgf, $plf, $sz, $sz2, $sz3, $fn) = split(/\t/);
        my $set = [];
        while (<S>)
        {
            chomp;
            last if $_ eq '///';
            # fig|96345.64.peg.772	96345.64.con.0001	4142224	898080	899369	+
            my($fid, $contig, $start, $end, $contig_length, $strand) = split(/\t/);

            my $len = abs($start - $end);
            push(@$set, [$fid, $len]);
        }
        push(@sets, [sort { $b->[1] <=> $a->[1] } @$set]);
    }

    my @fids = ($peg);
    my $added = 1;
    while (@fids < $n_genomes + 1 && $added)
    {
        $added = 0;
        for my $set (@sets)
        {
            if (@$set)
            {
                my $ent = shift @$set;
                my($xfid, $xlen) = @$ent;
                $added++;
                push(@fids, $xfid);
                last if @fids >= $n_genomes + 1;
            }
        }
    }

    # print Dumper(FIDS => \@fids);

    return \@fids;
}

sub color_regions_by_field
{
    my($self, $regions, $all_features, $coloring_field, $set_1_fam) = @_;
    #
    # Postprocess to assign color sets.
    #
    # We sort features by distance from center and from top.
    #
    my $next_set = 1;
    my %set;

    $set{$set_1_fam} = $next_set++ if $set_1_fam;
    print STDERR "Set1 fam = $set_1_fam\n";

    my @sorted_all  = sort { $a->[2] <=> $b->[2] or $a->[3] <=> $b->[3] } @$all_features;
    print STDERR join("\t", @{$_->[1]}{qw(fid beg end strand offset)}, $_->[3], $_->[2], @{$_->[0]}{$coloring_field}), "\n" foreach @sorted_all;
    for my $ent (@sorted_all)
    {
        my $fam = $ent->[0]->{$coloring_field};
        # my $fam = $all_families->{$ent->[0]->{patric_id}}->{$coloring_field}->[0];
        if ($fam)
        {
            my $set = $set{$fam};
            if (!$set)
            {
                $set{$fam} = $set = $next_set++;
            }
            $ent->[1]->{set_number} = $set;
        }
    }

    return $regions;
}

sub compare_regions_for_peg
{
    my($self, $peg, $width, $n_genomes, $coloring_method, $genome_filter_str) = @_;

    $coloring_method = 'pgfam' unless $family_field_of_type{$coloring_method};
    my $coloring_field = $family_field_of_type{$coloring_method};

    print STDERR "compare: $peg, $width, $n_genomes, $coloring_method, $genome_filter_str\n";

    $genome_filter_str //= 'representative';
    my $genome_filter = sub { 1 };
    my $solr_filter;
    if ($genome_filter_str eq 'all')
    {
        print STDERR "$peg all filter\n";
        $genome_filter = sub {1};
    }
    elsif ($genome_filter_str eq 'representative')
    {
        print STDERR "$peg rep filter\n";
        $genome_filter = sub { $self->is_reference_genome($_[0]) eq 'Representative' };
        $solr_filter = $self->representative_genome_filter();
    }
    elsif ($genome_filter_str eq 'reference')
    {
        print STDERR "$peg ref filter\n";
        $genome_filter = sub { $self->is_reference_genome($_[0]) eq 'Reference' };
        $solr_filter = $self->reference_genome_filter();
    }
    elsif ($genome_filter_str eq 'representative+reference')
    {
        print STDERR "$peg repref filter\n";
        $genome_filter = sub { $self->is_reference_genome($_[0]) ne '' };
        $solr_filter = $self->representative_reference_genome_filter();
    }

    my %seqs;
    my @pin = $self->get_pin($peg, $coloring_method, $n_genomes, $genome_filter, $solr_filter, \%seqs);
    print STDERR "got pin size=" . scalar(@pin) . "\n";
    # print STDERR Dumper(\@pin);
    my $half_width = int($width / 2);

    my @out;
    my @all_features;

    my $set_1_fam;

    my @genes_in_region_request;
    my @length_queries;

    for my $pin_row (0..$#pin)
    {
        my $elt = $pin[$pin_row];

#	my ($left, $right);
#	($left, $right) = $elt->{strand} eq '+' ? ($elt->{start}, $elt->{end}) : ($elt->{end}, $elt->{start});
#	my $mid = int(($left + $right) / 2);

        my($ref_b,$ref_e, $ref_sz);
        if ($elt->{strand} eq '+')
        {
            $ref_b = $elt->{start} + $elt->{match_beg} * 3;
            $ref_e = $elt->{start} + $elt->{match_end} * 3;
            $ref_sz = $ref_e - $ref_b;
        }
        else
        {
            $ref_b = $elt->{start} - $elt->{match_beg} * 3;
            $ref_e = $elt->{start} - $elt->{match_end} * 3;
            $ref_sz = $ref_b - $ref_e;
        }
        my $mid = $ref_e;

        push(@genes_in_region_request, [$elt->{genome_id}, $elt->{accession}, $mid - $half_width, $mid + $half_width]);
        push(@length_queries, "(genome_id:\"$elt->{genome_id}\" AND accession:\"$elt->{accession}\")");
    }
    my $lengths = $self->solr_query("genome_sequence", { q => join(" OR ", @length_queries), fl => "genome_id,sequence_id,accession,length" });
    my %contig_lengths;
    $contig_lengths{$_->{genome_id}, $_->{accession}} = $_->{length} foreach @$lengths;
    # $contig_lengths{$_->{genome_id}, $_->{sequence_id}} = $_->{length} foreach @$lengths;
    # print STDERR Dumper(GIR => \@length_queries, $lengths, \%contig_lengths, \@genes_in_region_request);

    my @genes_in_region_response = $self->genes_in_region_bulk(\@genes_in_region_request);
    # print STDERR Dumper(GIR_ANSWER => \@genes_in_region_response);
    my $all_families = {};

    if (0)
    {
        # mysql families
        my @all_fids;
        for my $gir (@genes_in_region_response)
        {
            my($reg) = @$gir;
            for my $fent (@$reg)
            {
                push(@all_fids, $fent->{patric_id});
            }
        }
        $all_families = $self->family_of_bulk_mysql(\@all_fids);
    }
    else
    {
        # p3 families

        for my $gir (@genes_in_region_response)
        {
            my($reg) = @$gir;
            for my $fent (@$reg)
            {
                if (my $i = $fent->{pgfam_id})
                {
                    $all_families->{$fent->{patric_id}}->{pgfam} = [$i, ''];
                }
                if (my $i = $fent->{plfam_id})
                {
                    $all_families->{$fent->{patric_id}}->{plfam} = [$i, ''];
                }
            }
        }
    }

    for my $pin_row (0..$#pin)
    {
        my $elt = $pin[$pin_row];

#	my ($left, $right);
#	($left, $right) = $elt->{strand} eq '+' ? ($elt->{start}, $elt->{end}) : ($elt->{end}, $elt->{start});
#	my $mid = int(($left + $right) / 2);

        my($ref_b,$ref_e, $ref_sz);
        if ($elt->{strand} eq '+')
        {
            $ref_b = $elt->{start} + $elt->{match_beg} * 3;
            $ref_e = $elt->{start} + $elt->{match_end} * 3;
            $ref_sz = $ref_e - $ref_b;
        }
        else
        {
            $ref_b = $elt->{start} - $elt->{match_beg} * 3;
            $ref_e = $elt->{start} - $elt->{match_end} * 3;
            $ref_sz = $ref_b - $ref_e;
        }
        my $mid = $ref_e;

        # my($reg, $leftmost, $rightmost) = $self->genes_in_region($elt->{genome_id}, $elt->{accession}, $mid - $half_width, $mid + $half_width);
        my($reg, $leftmost, $rightmost) = @{$genes_in_region_response[$pin_row]};
        my $features = [];

#	my $region_mid = int(($leftmost + $rightmost) / 2) ;

        print STDERR "Shift: $elt->{patric_id} $elt->{blast_shift}\n";

        my $bfeature = {
            fid => "$elt->{patric_id}.BLAST",
            type => "blast",
            contig => $elt->{accession},
            beg => $ref_b,
            end => $ref_e,
            reference_point => $ref_e,
            blast_identity => $elt->{match_iden},
            size => $ref_sz,
            offset => int(($ref_b + $ref_e) / 2) - $mid,
            offset_beg => $ref_b - $mid,
            offset_end => $ref_e - $mid,
            function => "blast hit for pin",
            attributes => [ [ "BLAST identity" => $elt->{match_iden} ] ],
        };


        for my $fent (@$reg)
        {
            my $size = $fent->{right} - $fent->{left} + 1;
            my $offset = $fent->{mid} - $mid;
            my $offset_beg = $fent->{start} - $mid;
            my $offset_end = $fent->{end} - $mid;

            my $mapped_type = $typemap{$fent->{feature_type}} // $fent->{feature_type};

            my $fid = $fent->{patric_id};


            my $attrs = [];
            for my $fname (sort keys %{$all_families->{$fid}})
            {
                my($fam, $fun) = @{$all_families->{$fid}->{$fname}};
                my($ital_start, $ital_end) = ("","");
                my $funstr = '';
                if ($fun)
                {
                    if ($fun ne $fent->{product})
                    {
                        $ital_start = "<i>";
                        $ital_end = "</i>";
                    }
                    $funstr = "$fam: $ital_start$fun$ital_end";
                }
                else
                {
                    $funstr = $fam;
                }
                push(@$attrs, [$fname, $funstr]);
            }

            my $coloring_val = $all_families->{$fid}->{$coloring_method}->[0];

            my $feature = {
                fid => $fid,
                type => $mapped_type,
                contig => $elt->{accession},
                beg => $fent->{start},
                end => $fent->{end},
                reference_point => $ref_e,
                size => $size,
                strand => $fent->{strand},
                offset => $offset,
                offset_beg => $offset_beg,
                offset_end => $offset_end,
                function   => $fent->{product},
                location   => $elt->{accession}."_".$fent->{start}."_".$fent->{end},
                attributes => $attrs,
            };


            if ($fid eq $elt->{patric_id})
            {
                #
                # this is the pinned peg. Do any special processing here.
                #

                $set_1_fam = $coloring_val if $pin_row == 0;
                #$set_1_fam = $fent->{$coloring_field} if $pin_row == 0;
                $feature->{blast_identity} = $elt->{match_iden};
            }

            push(@$features, $feature);
            push(@all_features, [$fent, $feature, $pin_row, abs($fent->{mid} - $mid)]);
        }
        push(@$features, $bfeature);

        my $out_ent = {
            # beg => $leftmost,
            # end => $rightmost,
            beg => $mid - $half_width,
            end => $mid + $half_width,
            mid => $mid,
            org_name => "($pin_row) $elt->{genome_name}",
            pinned_peg_strand => $elt->{strand},
            genome_id => $elt->{genome_id},
            pinned_peg => $elt->{patric_id},
            features => $features,
            contig_length => $contig_lengths{$elt->{genome_id}, $elt->{accession}},
        };
        push(@out, $out_ent);
    }

    #
    # Postprocess to assign color sets.
    #
    # We sort features by distance from center and from top.
    #
    my $next_set = 1;
    my %set;

    $set{$set_1_fam} = $next_set++ if $set_1_fam;
    print STDERR "Set1 fam = $set_1_fam\n";

    my @sorted_all  = sort { $a->[2] <=> $b->[2] or $a->[3] <=> $b->[3] } @all_features;
    print STDERR join("\t", @{$_->[1]}{qw(fid beg end strand offset)}, $_->[3], $_->[2], @{$_->[0]}{qw(pgfam_id)}), "\n" foreach @sorted_all;
    for my $ent (@sorted_all)
    {
        # my $fam = $ent->[0]->{$coloring_field};
        my $fam = $all_families->{$ent->[0]->{patric_id}}->{$coloring_method}->[0];
        if ($fam)
        {
            my $set = $set{$fam};
            if (!$set)
            {
                $set{$fam} = $set = $next_set++;
            }
            $ent->[1]->{set_number} = $set;
        }
    }

    return \@out;
}

=head3 compute_reference_pin

    my @fids = $api->compute_reference_pin($focus_peg, $n_genomes, $distance_class)

Compute a pin for the given C<$focus_peg> from the PATRIC reference database.

=over 4

=item focus_peg

The feature ID to pin from.

=item pin_size

Number of features to return in the pin.

=item distribution_mode

A string denoting the distribution of returned genomes based on their
computed similarity. Values are "top", "spread_unique", "spread_proportional".

=back

=cut

sub compute_reference_pin
{
    my($self, $focus_peg, $n_genomes, $distribution_mode) = @_;

    #
    # Start by looking up family memberships and function of this feature.
    # We may treat hypothetical proteins differently due to the potentially
    # huge size of the global family they are contained in.
    #

    my @res = $self->query("genome_feature",
                           ["eq", "patric_id", $focus_peg],
                           ["select", "pgfam_id,plfam_id,product,genome_id"]);
    if (@res == 0)
    {
        die "$focus_peg: feature not found";
    }
    # print Dumper(\@res);
    my $focus_genome = genome_of($focus_peg);

    my @genomes = $self->compute_reference_genomes($focus_genome, $n_genomes, $distribution_mode);

    my $pgfam = $self->family_of($focus_peg, 'pgfam');
    print "pgfam=$pgfam genomes=@genomes\n";

    #
    # Given this set of reference genomes, query the database
    # of
}

sub compute_reference_genomes
{
    my($self, $focus_genome, $n_genomes, $distribution_mode) = @_;

    #
    # Begin by finding the pheS gene in our focus genome.
    #
    my $pheS_annotation = 'Phenylalanyl-tRNA synthetase alpha chain (EC 6.1.1.20)';

    my($phe_fa) = $self->find_protein_in_genome_by_product($focus_genome, $pheS_annotation);

    if (!$phe_fa)
    {
        die "Couldn't find pheS in $focus_genome";
    }

    my $phe_url = "http://holly.mcs.anl.gov:6101";

    #
    # Look up the related genomes.
    #

    $n_genomes = 10 unless $n_genomes =~ /^\d+$/;

    my $qry = "raw=1&min_hits=3&distribution_mode=$distribution_mode&max_results=$n_genomes";
    my $key = "p3api:ref_genomes:$qry";
    if ($self->redis)
    {

        my @res = $self->redis->lrange($key, 0, -1);
        print "redis $key returned " . scalar(@res) . "\n";
        return @res if @res;
    }

    my $url = "$phe_url/distance?$qry";

    my $out;
    my $ok = IPC::Run::run(["curl", "--data-binary", '@-', "-s", $url],
                           "<", \$phe_fa,
                           ">", \$out);
    $ok or die "couldn't get raw distances\n";

    my @res;
    open(my $fh, '<', \$out);
    while (<$fh>)
    {
        chomp;
        last if $_ eq '//';
        my($undef, $fid, $score) = split(/\t/);
        my $genome = genome_of($fid);
        push(@res, "$genome:$score");
    }
    if (@res && $self->redis)
    {
        $self->redis->del($key);
        $self->redis->rpush($key, @res);
        my $x = $self->redis->expire($key, $self->{redis_expiry_time});
    }
    return @res;
}

=head3 find_protein_in_genome_by_product

    my $aa_seq = $d->find_protein_in_genome_by_product($genome_id, $product_name)

Look for a protein with the given product in the given genome.

=cut

## FIX - defer, not used currently.
sub find_protein_in_genome_by_product
{
    my($self, $genome_id, $product_name) = @_;

    my $key ="p3api:protein_product:$genome_id:$product_name";

    if ($self->redis)
    {
        my @res = $self->redis->lrange($key, 0, -1);
        print "redis $key returned " . scalar(@res) . "\n";
        return @res if @res;
    }

    my $xprod = $product_name;
    $xprod =~ s/[()]//g;

    my @res = $self->query("genome_feature",
                            ["eq", "product", qq("$xprod")],
                            ["eq", "genome_id", $genome_id],
                            ["select", "patric_id,aa_sequence,product"]);

    if (@res == 0)
    {
        return;
    }
    my @prots;
    for my $ent (@res)
    {
        next unless $ent->{product} eq $product_name;
        push(@prots, ">$ent->{patric_id} $ent->{product}\n$ent->{aa_sequence}\n");
    }
    if (@prots && $self->redis)
    {
        $self->redis->del($key);
        $self->redis->rpush($key, @prots);
        $self->redis->expire($key, $self->{redis_expiry_time});
    }
    return @prots;
}

sub genome_name
{
    my($self, $gid_list) = @_;

    my %out;
    my @list = @$gid_list;
    while (@list)
    {
        my @chunk = splice(@list, 0, 500);

        my $q = join(" OR ", map { "genome_id:\"$_\"" } @chunk);
        my $res = $self->solr_query("genome", { q => $q, fl => "genome_id,genome_name,reference_genome" });
        for my $ent (@$res)
        {
            $out{$ent->{genome_id}} = [$ent->{genome_name}, $ent->{reference_genome}];
        }
    }
    return \%out;
}

## FIX - returns sequence md5s not sequence. If user wants sequence data needs to
## pull separately.
sub genes_in_region
{
    my($self, $genome, $contig, $beg, $end) = @_;

    #
    # We need to query with some slop because the solr schema currently does
    # not have left/right coordinates, rather start/end.
    #

    my $slop = 5000;
    my $begx = ($beg > $slop + 1) ? $beg - $slop : 1;
    my $endx = $end + $slop;

    my $res = $self->solr_query("genome_feature", { q => "genome_id:$genome AND accession:$contig AND (start:[$begx TO $endx] OR end:[$begx TO $endx]) AND annotation:PATRIC AND NOT feature_type:source",
                                                        fl => 'start,end,feature_id,product,figfam_id,strand,patric_id,pgfam_id,plfam_id,aa_sequence_md5,genome_name,feature_type',
                                                    });

    my @out;
    my $leftmost = 1e12;
    my $rightmost = 0;
    my %md5s;
    for my $ent (@$res)
    {
        #
        # PATRIC stores start/end as left/right. Change to the SEED meaning.aa
        #
        $md5s{$ent->{aa_sequence_md5}} = 1;
        my ($left, $right) = @$ent{'start', 'end'};
        if ($ent->{strand} eq '-')
        {
            $ent->{start} = $right;
            $ent->{end} = $left;
        }
        my $mid = int(($left + $right) / 2);
        if ($left <= $end && $right >= $beg)
        {
            $leftmost = $left if $left < $leftmost;
            $rightmost = $right if $right > $rightmost;
            push(@out, { %$ent, left => $left, right => $right, mid => $mid });
        }
    }

    # print Dumper(\@out);
    return [ sort { $a->{mid} <=> $b->{mid} } @out ], $leftmost, $rightmost;
}

sub genes_in_region_bulk_mysql
{
    my($self, $reqlist) = @_;

    my @where_parts;
    my $pad = 100_000;
    my @params;

    my $dbh = DBI->connect_cached($self->feature_db_dsn, $self->feature_db_user);

    my %ctg_order;
    my $i = 0;

    for my $req (@$reqlist)
    {
        my($genome, $contig, $beg, $end) = @$req;
        $ctg_order{$contig} = $i++;
        my $minV = $beg - $pad;
        push(@where_parts, "(contig = ? AND start <= ? AND start > ? AND end >= ? AND fid LIKE ?)");
        push(@params, $contig, $end, $minV, $beg, "fig|$genome.%");
    }

    my $where = join("\n OR ", @where_parts);
    my $qry = qq(SELECT fid, contig, start, end, strand, func
                 FROM feature
                 WHERE $where
                 ORDER BY contig
                 );
    # print $qry;
    # print Dumper(\@params);

    my $res = $dbh->selectall_arrayref($qry, undef, @params);

    my @out;
    my $leftmost = 1e12;
    my $rightmost = 0;

    my $cur_contig;
    my @result;

    for my $dbent (@$res)
    {
        my($fid, $contig, $start, $end, $strand, $func) = @$dbent;

        if ($contig ne $cur_contig)
        {
            if ($cur_contig)
            {
                my $this_row = [[ sort { $a->{mod} <=> $b->{mid} } @out ], $leftmost, $rightmost, $cur_contig];
                push(@result, $this_row);
            }
            @out = ();
            $leftmost = 1e12;
            $rightmost = 0;
            $cur_contig = $contig;
        }

        my($type) = $fid =~ /^fig\|\d+\.\d+\.([^.]+)/;
        my $ent = {
            start => 0 + $start,
            end => 0 + $end,
            product => $func,
            strand => $strand,
            patric_id => $fid,
            feature_type => $type,
        };

        my ($left, $right) = ($start, $end);
        if ($strand eq '-')
        {
            $ent->{start} = $right;
            $ent->{end} = $left;
        }
        my $mid = int(($left + $right) / 2);
        if ($left <= $end && $right >= $start)
        {
            $leftmost = $left if $left < $leftmost;
            $rightmost = $right if $right > $rightmost;
            push(@out, { %$ent, left => $left, right => $right, mid => $mid });
        }
    }
    my $this_row = [[ sort { $a->{mod} <=> $b->{mid} } @out ], $leftmost, $rightmost, $cur_contig];
    push(@result, $this_row);
    # print STDERR Dumper(ctg_order => \%ctg_order);
    my @sorted = sort { $ctg_order{$a->[3]} <=> $ctg_order{$b->[3]} } @result;
    return @sorted;
}

sub genes_in_region_bulk
{
    my($self, $reqlist) = @_;

    my @queries;

    for my $req (@$reqlist)
    {
        my($genome, $contig, $beg, $end) = @$req;

        #
        # We need to query with some slop because the solr schema currently does
        # not have left/right coordinates, rather start/end.
        #

        my $slop = 5000;
        my $begx = ($beg > $slop + 1) ? $beg - $slop : 1;
        my $endx = $end + $slop;

        $begx = 1 if $begx < 1;

        push(@queries, ["genome_feature", { q => "genome_id:$genome AND (sequence_id:$contig OR accession:$contig) AND (start:[$begx TO $endx] OR end:[$begx TO $endx]) AND annotation:PATRIC AND NOT feature_type:source",
                                                        fl => 'start,end,feature_id,product,figfam_id,strand,patric_id,pgfam_id,plfam_id,aa_sequence_md5,genome_name,feature_type',
                                                    }]);
    }

    my @replies = $self->solr_query_raw_multi(\@queries);
    my @return;

    for my $i (0..$#$reqlist)
    {
        my $req = $reqlist->[$i];
        my $res = $replies[$i];
        my($genome, $contig, $beg, $end) = @$req;

        #
        # We need to query with some slop because the solr schema currently does
        # not have left/right coordinates, rather start/end.
        #

        my $slop = 5000;
        my $begx = ($beg > $slop + 1) ? $beg - $slop : 1;
        my $endx = $end + $slop;

        my @out;
        my $leftmost = 1e12;
        my $rightmost = 0;
        for my $ent (@$res)
        {
            #
            # PATRIC stores start/end as left/right. Change to the SEED meaning.
            #

            my ($left, $right) = @$ent{'start', 'end'};
            if ($ent->{strand} eq '-')
            {
                $ent->{start} = $right;
                $ent->{end} = $left;
            }
            my $mid = int(($left + $right) / 2);
            if ($left <= $end && $right >= $beg)
            {
                $leftmost = $left if $left < $leftmost;
                $rightmost = $right if $right > $rightmost;
                push(@out, { %$ent, left => $left, right => $right, mid => $mid });
            }
        }
        my $this_ret = [[ sort { $a->{mid} <=> $b->{mid} } @out ], $leftmost, $rightmost];
        push(@return, $this_ret);
    }
    return @return;
}

=head3 get_pin

    my $pin = $d->get_pin($fid, $family_type, $max_size, $genome_filter);

=cut

sub get_pin_mysql
{
    my($self, $fid, $family_type, $max_size, $genome_filter) = @_;

    my $type;
    if ($family_type eq 'plfam')
    {
        $type = 'L';
    }
    elsif ($family_type eq 'pgfam')
    {
        $type = 'G';
    }
    else
    {
        die "Invalid family type $family_type in get_pin_mysql";
    }

    my $dbh = DBI->connect_cached($self->family_db_dsn, $self->family_db_user);
    my $res = $dbh->selectcol_arrayref(qq(SELECT f2.fid
                                          FROM family_membership f1 JOIN family_membership f2
                                                  ON f1.family_id = f2.family_id
                                          WHERE f1.fid = ? AND f1.type = ? AND f2.type = ?), undef, $fid, $type, $type);

    #
    # Cut list based on genome.
    #

    my @cut_pin = grep { my($g) = /^fig\|(\d+\.\d+)/; $genome_filter->($g) || ($_ eq $fid )} @$res;

    if (@cut_pin == 0)
    {
        #
        # No matches for family. Need to reinsert my peg.
        #
        push(@cut_pin, $fid);
    }

    # my $nb = @$res;
    # my $na = @cut_pin;
    # die "nb=$nb na=$na\n";

    #
    # Expand with feature info.
    #

    my $sres = [];

    my @to_query = @cut_pin;

    my($me, @out);

    while (@to_query)
    {
        my @q = splice(@to_query, 0, 500);

        my $fidq = join(" OR ", map { "\"$_\"" } @q);
        $sres = $self->solr_query("genome_feature",
                              { q => "patric_id:($fidq)",
                                    fl => "patric_id,aa_sequence,accession,start,end,genome_id,genome_name,strand" });
        #
        # PATRIC stores start/end as left/right. Change to the SEED meaning.
        #
        # die Dumper($sres);

        for my $ent (@$sres)
        {
            if ($ent->{patric_id} eq $fid)
            {
                $me = $ent;
            }
            else
            {
                push(@out, $ent);
            }
            my ($left, $right) = @$ent{'start', 'end'};
            if ($ent->{strand} eq '-')
            {
                $ent->{start} = $right;
                $ent->{end} = $left;
            }
        }
    }

    return ($me, @out);
}

## Now does not return sequence data.
sub get_pin_p3
{
    my($self, $fid, $family_type, $max_size, $genome_filter, $solr_filter) = @_;

    my $fam = $self->family_of($fid, $family_type);

    if (!$fam)
    {
        #
        # Need to look up stats of this peg for future analysis. Otherwise members_of_family
        # would do it.
        #

        my $q = "patric_id:$fid";
        my $res = $self->solr_query("genome_feature",
                                { q => $q, fl => "patric_id,aa_sequence_md5,accession,start,end,genome_id,genome_name,strand" });
        #
        # need to rewrite start/end for neg strand
        #
        for my $ent (@$res)
        {
            if ($ent->{strand} eq '-')
            {
                ($ent->{start}, $ent->{end}) = ($ent->{end}, $ent->{start});
            }
        }
        return ($res->[0]);
    }

    my $pin = $self->members_of_family($fam, $family_type, $solr_filter, $fid, $max_size * 10000);

    my $me;
    my @cut_pin;
    for my $r (@$pin)
    {
        if ($r->{patric_id} eq $fid)
        {
            $me = $r;
        }
        elsif (!ref($genome_filter) || $genome_filter->($r->{genome_id}))
        {
            push(@cut_pin, $r);
        }
    }
    return($me, @cut_pin)
}

=head3 expand_fids_to_pin

    my $pin = $d->expand_fids_to_pin($fid_list);

Given a list of fids, expand with data from the API.

=cut

sub expand_fids_to_pin
{
    my($self, $fids, $additional_fields) = @_;

    my @out;

    my @todo = @$fids;

    my @fields = qw(patric_id aa_sequence_md5 start end strand sequence_id accession genome_id genome_name);
    my $fields = join(",", @fields, $additional_fields ? @$additional_fields : ());

    while (@todo)
    {
        my @batch = splice(@todo, 0, 50);

        #
        # Need to reorder by our original order since the query scrambles.
        #
        my $i = 0;
        my %order = map { $_, $i++ } @batch;
        my @res = $self->query("genome_feature",
                               ["in", "patric_id", "(" . join(",", @batch) . ")"],
                               ["select", $fields]);
        for my $ent (@res)
        {
            if ($ent->{strand} eq '-')
            {
                ($ent->{start}, $ent->{end}) = ($ent->{end}, $ent->{start});
            }
        }

        push(@out, sort { $order{$a->{patric_id}} <=> $order{$b->{patric_id}} } @res);
    }
    return @out;
}


=head3 compute_pin_alignment

    my $enhanced_pin = $d->compute_pin_alignment($pin, $n_genomes, $truncation_mechanism)

Given a basic pin, compute the BLAST similarities between the
first member and the rest, order the pin by the similarities, and
truncate to the desired size. The truncation mechanism may either be
'best_match' in which case the best N matches are kept, or 'stratify' in which
case N matches stratified through the list are kept.

Each element in $pin is a hash with the following keys:
    patric_id		Feature ID
    aa_sequence 	Amino acid sequence for the protein

=cut

## FIX - defer, not yet in use
sub compute_pin_alignment
{
    my($self, $pin, $n_genomes, $truncation_mechanism) = @_;

    my %cut_pin = map { $_->{patric_id} => $_ } @$pin;

    my($me, @rest) = @$pin;
    my @out;

    if (@rest)
    {
        my $tmpdir = File::Temp->newdir(CLEANUP => 1);
        my $tmp_db = "$tmpdir/db";
        my $tmp_qry = "$tmpdir/qry";
        # print Dumper(COMPUTE => $pin, "$tmpdir", $me, \@rest);

        open(my $tmp_fh, ">", $tmp_qry) or die "Cannot write $tmp_qry: $!";
        print $tmp_fh ">$me->{patric_id}\n$me->{aa_sequence}\n";
        close($tmp_fh);
        undef $tmp_fh;

        open($tmp_fh, ">", $tmp_db) or die "Cannot write $tmp_db: $!";
        print $tmp_fh ">$_->{patric_id}\n$_->{aa_sequence}\n" foreach @rest;
        close($tmp_fh);

        my $rc = system("formatdb", "-p", "t", "-i", "$tmp_db");
        $rc == 0 or die "formatdb failed with $rc\n";

        my $evalue = "1e-5";

        open(my $blast, "-|", "blastall", "-p", "blastp", "-i", "$tmp_qry", "-d", "$tmp_db", "-m", 8, "-e", $evalue,
             ($n_genomes ? ("-b", $n_genomes) : ()))
            or die "cannot run blastall: $!";
        my %seen;
        while (<$blast>)
        {
            print STDERR $_;
            chomp;
            my($id1, $id2, $iden, undef, undef, undef, $b1, $e1, $b2, $e2) = split(/\t/);
            next if $seen{$id1, $id2}++;

            if (!defined($me->{blast_shift}))
            {
                my $shift = 0;
                my $match = $cut_pin{$id1};
                $me->{blast_shift} = $shift;
                $me->{match_beg} = $b1;
                $me->{match_end} = $e1;
                $me->{match_iden} = 100;
            }
            my $shift = ($e1 - $e2) * 3;
            my $match = $cut_pin{$id2};
            $match->{blast_shift} = $shift;
            $match->{match_beg} = $b2;
            $match->{match_end} = $e2;
            $match->{match_iden} = $iden;
            push(@out, $match);
        }
        #    $#out = $max_size - 1 if $max_size;
    }
    return ($me, @out);
}

sub get_pin
{
    my($self, $fid, $family_type, $max_size, $genome_filter, $solr_filter, $seqs) = @_;

    my($me, @pin) = $self->get_pin_p3($fid, $family_type, $max_size, $genome_filter, $solr_filter);
    #my($me, @pin) = $self->get_pin_mysql($fid, $family_type, $max_size, $genome_filter);

    # print "me:$me\n";
    #  print "\t$_->{genome_id}\n" foreach @pin;

    #
    # Only if we have other pegs..
    #

    my @out;

    if (@pin)
    {
        my %cut_pin = map { $_->{patric_id} => $_ } @pin;

        my %md5_to_id;
        push(@{$md5_to_id{$_->{aa_sequence_md5}}}, $_->{patric_id}) foreach $me, @pin;

        $seqs //= {};

        $self->lookup_sequence_data([ keys %md5_to_id ], sub {
            my $ent = shift;
            $seqs->{$ent->{md5}} = $ent->{sequence};
        });

        my $me_md5 = $me->{aa_sequence_md5};
        my $me_seq = $seqs->{$me->{aa_sequence_md5}};

        my $tmpdir = File::Temp->newdir();
        my $tmp = "$tmpdir/pin";
        my $tmp2 = "$tmpdir/qry";

        open(my $tmp_fh, ">", $tmp2) or die "Cannot write $tmp2: $!";
        print $tmp_fh ">$me_md5\n$me_seq\n";
        close($tmp_fh); undef $tmp_fh;

        open($tmp_fh, ">", $tmp) or die "Cannot write $tmp: $!";
        while (my($md5, $seq) = each(%$seqs))
        {
            print $tmp_fh ">$md5\n$seq\n";
        }
        close($tmp_fh);
        my $rc = system("formatdb", "-p", "t", "-i", $tmp);
        $rc == 0 or die "formatdb failed with $rc\n";

        my $evalue = "1e-5";

        my $blast;
        open($blast, "-|", "blastall", "-p", "blastp", "-i", "$tmp2", "-d", "$tmp", "-m", 8, "-e", $evalue,
             ($max_size ? ("-b", $max_size) : ()))
            or die "cannot run blastall: $!";
        my %seen;
        #
        # We are blasting against the unique sequences. For now,
        # just remap the blast output. We may be able to be more
        # clever moving forward.
        #
        my @hits;
        while (<$blast>)
        {
            chomp;
            my($id1, $id2, $iden, undef, undef, undef, $b1, $e1, $b2, $e2) = split(/\t/);

            if ($id1 ne $me_md5)
            {
                die "Invalid BLAST output: $id1 ne $me_md5";
            }
            push(@hits, [$me->{patric_id}, $_, $iden, $b1, $e1, $b2, $e2])
                foreach @{$md5_to_id{$id2}};
        }
        for my $hit (@hits)
        {
            my($id1, $id2, $iden, $b1, $e1, $b2, $e2) = @$hit;
            next if $seen{$id1, $id2}++;

            if ($id2 eq $fid)
            {
                my $shift = 0;
                my $match = $cut_pin{$id1};
                $me->{blast_shift} = $shift;
                $me->{match_beg} = $b1;
                $me->{match_end} = $e1;
                $me->{match_iden} = 100;
                next;
            }
            my $shift = ($e1 - $e2) * 3;
            my $match = $cut_pin{$id2};
            $match->{blast_shift} = $shift;
            $match->{match_beg} = $b2;
            $match->{match_end} = $e2;
            $match->{match_iden} = $iden;

            push(@out, $match);
        }
        close ($blast);
#    $#out = $max_size - 1 if $max_size;
    }
    else
    {

    }
    return ($me, @out);
}

sub expand_pin_to_regions
{
    my($self, $pin, $width, $group_data) = @_;

    print STDERR "got pin size=" . scalar(@$pin) . "\n";
    # print STDERR Dumper(\@pin);
    my $half_width = int($width / 2);

    my @out;
    my @all_features;

    my $set_1_fam;

    my @genes_in_region_request;
    my @length_queries;

    for my $pin_row (0..$#$pin)
    {
        my $elt = $pin->[$pin_row];

        my($ref_b,$ref_e, $ref_sz);
        if ($elt->{strand} eq '+')
        {
            $ref_b = $elt->{start} + $elt->{match_beg} * 3;
            $ref_e = $elt->{start} + $elt->{match_end} * 3;
            $ref_sz = $ref_e - $ref_b;
        }
        else
        {
            $ref_b = $elt->{start} - $elt->{match_beg} * 3;
            $ref_e = $elt->{start} - $elt->{match_end} * 3;
            $ref_sz = $ref_b - $ref_e;
        }
        my $mid = $ref_e;

        push(@genes_in_region_request,
             [$elt->{genome_id}, $elt->{accession}, $mid - $half_width, $mid + $half_width]);

        push(@length_queries,
             "(genome_id:\"$elt->{genome_id}\" AND sequence_id:\"$elt->{sequence_id}\")");
    }

    my $lengths = $self->solr_query("genome_sequence",
                                { q => join(" OR ", @length_queries),
                                      fl => "genome_id,sequence_id,sequence_id,length" });
    my %contig_lengths;
    $contig_lengths{$_->{genome_id}, $_->{sequence_id}} = $_->{length} foreach @$lengths;
    # print STDERR Dumper(GIR => \@length_queries, $lengths, \%contig_lengths, \@genes_in_region_request);

    my @genes_in_region_response = $self->genes_in_region_bulk_mysql(\@genes_in_region_request);
    # print STDERR Dumper(GIR_OUT => \@genes_in_region_response);

    # my $all_families = {};

    # for my $gir (@genes_in_region_response)
    # {
    # 	my($reg) = @$gir;
    # 	for my $fent (@$reg)
    # 	{
    # 	    if (my $i = $fent->{pgfam_id})
    # 	    {
    # 		$all_families->{$fent->{patric_id}}->{pgfam} = [$i, ''];
    # 	    }
    # 	    if (my $i = $fent->{plfam_id})
    # 	    {
    # 		$all_families->{$fent->{patric_id}}->{plfam} = [$i, ''];
    # 	    }
    # 	}
    # }

    for my $pin_row (0..$#$pin)
    {
        my $elt = $pin->[$pin_row];

        my($ref_b,$ref_e, $ref_sz);
        if ($elt->{strand} eq '+')
        {
            $ref_b = $elt->{start} + $elt->{match_beg} * 3;
            $ref_e = $elt->{start} + $elt->{match_end} * 3;
            $ref_sz = $ref_e - $ref_b;
        }
        else
        {
            $ref_b = $elt->{start} - $elt->{match_beg} * 3;
            $ref_e = $elt->{start} - $elt->{match_end} * 3;
            $ref_sz = $ref_b - $ref_e;
        }
        my $mid = $ref_e;

        my $row = $genes_in_region_response[$pin_row];
        if (!$row)
        {
            die "Error retriving row $pin_row\n" . Dumper(@genes_in_region_response);
        }
        my($reg, $leftmost, $rightmost) = @{$genes_in_region_response[$pin_row]};
        my $features = [];

        print STDERR "Shift: $elt->{patric_id} $elt->{blast_shift}\n";

        my $bfeature = {
            fid => "$elt->{patric_id}.BLAST",
            type => "blast",
            contig => $elt->{sequence_id},
            beg => $ref_b,
            end => $ref_e,
            reference_point => $ref_e,
            blast_identity => $elt->{match_iden},
            size => $ref_sz,
            offset => int(($ref_b + $ref_e) / 2) - $mid,
            offset_beg => $ref_b - $mid,
            offset_end => $ref_e - $mid,
            function => "blast hit for pin",
            attributes => [ [ "BLAST identity" => $elt->{match_iden} ] ],
        };


        my $fid_to_fam = {};
        if ($group_data)
        {
            $fid_to_fam = $group_data->{fid_to_fam};
        }

        for my $fent (@$reg)
        {
            my $size = $fent->{right} - $fent->{left} + 1;
            my $offset = $fent->{mid} - $mid;
            my $offset_beg = $fent->{start} - $mid;
            my $offset_end = $fent->{end} - $mid;

            my $mapped_type = $typemap{$fent->{feature_type}} // $fent->{feature_type};

            my $fid = $fent->{patric_id};

            my $attrs = [];
            my @fams;
            #
            # process plfam/pgfam ids for inclusion in attributes list
            #
            if (my $fam = $fid_to_fam->{$fid})
            {
                $fent->{group_family} = $fam;
            }
            for my $fam_key (qw(plfam_id pgfam_id group_family))
            {
                my $fam = $fent->{$fam_key};
                if ($fam)
                {
                    my $fname = $fam_key;
                    $fname =~ s/_id$//;

                    push(@$attrs, [$fname, $fam]);
                    push(@fams, $fam_key, $fam);
                }
            }

            my $feature = {
                fid => $fid,
                type => $mapped_type,
                contig => $elt->{sequence_id},
                beg => $fent->{start},
                end => $fent->{end},
                reference_point => $ref_e,
                size => $size,
                strand => $fent->{strand},
                offset => $offset,
                offset_beg => $offset_beg,
                offset_end => $offset_end,
                function   => $fent->{product},
                location   => $elt->{sequence_id}."_".$fent->{start}."_".$fent->{end},
                attributes => $attrs,
                @fams,
            };


            if ($fid eq $elt->{patric_id})
            {
                $feature->{blast_identity} = $elt->{match_iden};
            }

            push(@$features, $feature);
            push(@all_features, [$fent, $feature, $pin_row, abs($fent->{mid} - $mid)]);
        }
        push(@$features, $bfeature);

        my $out_ent = {
            # beg => $leftmost,
            # end => $rightmost,
            beg => $mid - $half_width,
            end => $mid + $half_width,
            mid => $mid,
            org_name => "($pin_row) $elt->{genome_name}",
            pinned_peg_strand => $elt->{strand},
            genome_id => $elt->{genome_id},
            pinned_peg => $elt->{patric_id},
            features => $features,
            contig_length => $contig_lengths{$elt->{genome_id}, $elt->{sequence_id}},
        };
        push(@out, $out_ent);
    }
    # print STDERR Dumper(expand_out => \@out);
    return(\@out, \@all_features);
}

sub family_of
{
    my($self, $fid, $family_type) = @_;

    my $fam_field = $family_field_of_type{lc($family_type)};
    $fam_field or die "Unknown family type '$family_type'\n";
    my $res = $self->solr_query("genome_feature", { q => "patric_id:$fid", fl => $fam_field });
    if (@$res)
    {
        return $res->[0]->{$fam_field};
    }
    else
    {
        return undef;
    }
}

sub family_of_bulk
{
    my($self, $fid_list, $family_type) = @_;

    my $fam_field = $family_field_of_type{lc($family_type)};
    $fam_field or die "Unknown family type '$family_type'\n";

    my @fids = @$fid_list;

    my $out = {};
    while (@fids)
    {
        my @batch = splice(@fids, 0, 1000);

        my $fidq = join(" OR ", map { "\"$_\"" } @batch);

        my $res = $self->solr_query("genome_feature",
                                {
                                    q => "patric_id:($fidq)",
                                    fl => "patric_id,$fam_field",
                                });
        if (@$res)
        {
            for my $r (@$res)
            {
                $out->{$r->{patric_id}} = $r->{$fam_field};
            }
        }
    }

    return $out;
}

sub family_of_bulk_mysql
{
    my($self, $fids, $family_types) = @_;

    return {} unless @$fids;

    my @ftypes = grep { defined $_ } map { $family_type_to_sql{$_} } ($family_types ? @$family_types : ());

    my $dbh = DBI->connect_cached($self->family_db_dsn, $self->family_db_user);
    my $qs = join(", ", map { "?" } @$fids);
    my $ftype_qs = join(", ", map { "?" } @ftypes);
    my $ftype_where = @ftypes ? " AND type IN ($ftype_qs)" : "";
    my $res = $dbh->selectall_arrayref(qq(SELECT fm.fid, fm.type, fm.family_id, f.function
                                          FROM family_membership fm JOIN family f ON fm.family_id = f.id AND fm.type = f.type
                                          WHERE fid IN ($qs) $ftype_where), undef, @$fids, @ftypes);
    my $out = {};
    $out->{$_->[0]}->{$sql_fam_to_family_type{$_->[1]}} = [$_->[2], $_->[3]] foreach @$res;
    return $out;
}

sub search_families
{
    my($self, $term, $exact) = @_;

    my $dbh = DBI->connect_cached($self->family_db_dsn, $self->family_db_user);


    my @queries = ("f.function = " . $dbh->quote($term));
    if (!$exact)
    {
        push(@queries,
             "f.function LIKE " . $dbh->quote("$term%"),
             "f.function LIKE " . $dbh->quote("%$term%"),
            );
    }

    for my $q (@queries)
    {
        my $res = $dbh->selectall_arrayref(qq(SELECT f.function, f.id, count(fm.fid)
                                              FROM family f JOIN family_membership fm ON fm.family_id = f.id AND fm.type = f.type
                                              WHERE $q
                                              GROUP BY f.id
                                              ORDER BY count(fm.fid) DESC, f.function, f.type, f.id));
        if (@$res)
        {
            return $res;
        }
    }
    return undef;
}

sub family_function
{
    my($self, $fams) = @_;

    my $dbh = DBI->connect_cached($self->family_db_dsn, $self->family_db_user);

    $fams = [$fams] unless ref($fams);

    my $qs = join(", ", map { "?" } @$fams);

    my $res = $dbh->selectall_arrayref(qq(SELECT id, function
                                          FROM family
                                          WHERE id IN ($qs)),  undef, @$fams);
    return { map { @$_ } @$res };
}

sub members_of_family_mysql
{
    my($self, $fam) = @_;

    my $dbh = DBI->connect_cached($self->family_db_dsn, $self->family_db_user);

    my $res = $dbh->selectcol_arrayref(qq(SELECT fid
                                          FROM family_membership
                                          WHERE family_id = ?
                                          ORDER BY fid), undef, $fam);
    my @out;
    my %genomes;
    for my $fid (@$res)
    {
        my($g) = $fid =~ /^fig\|(\d+\.\d+)/;
        $genomes{$g}++;
        push @out, { fid => $fid, gid => $g };
    }

    my $names = $self->genome_name([keys %genomes]);

    for my $ent (@out)
    {
        my $n = $names->{$ent->{gid}};
        $ent->{genome_name} = $n->[0];
        $ent->{reference_genome} = $n->[1];
    }
    return \@out;
}

#
# This routine doesn't return the sequence data; rather the md5s.
#
sub members_of_family
{
    my($self, $fam, $family_type, $solr_filter, $fid, $max_count) = @_;

    my $fam_field = $family_field_of_type{lc($family_type)};
    $fam_field or die "Unknown family type '$family_type'\n";

    my $q = join(" AND ", "$fam_field:$fam", $solr_filter ? "($solr_filter OR patric_id:$fid)" : ());
    my $res = $self->solr_query("genome_feature", { q => $q, fl => "patric_id,aa_sequence_md5,accession,start,end,genome_id,genome_name,strand" }, $max_count);
    #
    # need to rewrite start/end for neg strand
    #
    for my $ent (@$res)
    {
        if ($ent->{strand} eq '-')
        {
            ($ent->{start}, $ent->{end}) = ($ent->{end}, $ent->{start});
        }
    }
    return $res;
}

sub genetic_code_bulk
{
    my($self, @gids) = @_;
    my %tax_of;
    my %to_find;

    for my $g (@gids)
    {
        my($tax) = $g =~ /^(\d+)/;
        $tax_of{$g} = $tax;
        $to_find{$tax} = 1;
    }
    my @to_find = keys %to_find;
    undef %to_find;
    my %code_for;
    while (@to_find)
    {
        my @b = splice(@to_find, 0, 100);
        my $q = join(",", @b);

        print "q=$q\n";
        my @code = $self->query("taxonomy",
                                [ "in",   "taxon_id",  "($q)" ],
                                [ "select", "taxon_id,genetic_code" ]
                               );
        for my $ent (@code)
        {
            $code_for{$ent->{taxon_id}} = $ent->{genetic_code};
        }
    }

    my $ret = {};
    for my $g (@gids)
    {
        $ret->{$g} = $code_for{$tax_of{$g}} // 11;
    }
    return $ret;
}

sub function_of
{
    my($self, $fids) = @_;

    my %out;

    my @list= @$fids;
    while (@list)
    {
        my @chunk = splice(@list, 0, 500);

        my $fidq = join(" OR ", map { "\"$_\"" } @chunk);
        # print "$fidq\n";
        my $sres = $self->solr_query("genome_feature",
                             { q => "patric_id:($fidq)",
                               fl => "patric_id,product" });
        $out{$_->{patric_id}} = $_->{product} foreach @$sres;
    }
    return \%out;
}

=head3 gto_of

    my $gto = $d->gto_of($genomeID);

Return a L<GenomeTypeObject> for the specified genome.

=over 4

=item genomeID

ID of the source genome.

=item RETURN

Returns a blessed L<GenomeTypeObject> for the genome, or C<undef> if the genome was not found.

=back

=cut

## FIX
sub gto_of {
    my ( $self, $genomeID ) = @_;
    require GenomeTypeObject;
    my $retVal;

    # Get the basic genome data.
    my ($g) = $self->query(
        "genome",
        [ "eq", "genome_id", $genomeID ],
        [
            "select",      "genome_id",
            "genome_name", "genome_status",
            "taxon_id",    "taxon_lineage_names",
            "taxon_lineage_ids"
        ],
    );

    # Only proceed if we found a genome.

    if (!$g) {
        return $retVal;
    }

    # Compute the domain.
    my $domain = $g->{taxon_lineage_names}[1];
    if ( !grep { $_ eq $domain } qw(Bacteria Archaea Eukaryota) ) {
        $domain = $g->{taxon_lineage_names}[0];
    }

    # Compute the genetic code.

    my @code = $self->query(
                            "taxonomy",
                            [ "eq",     "taxon_id", $g->{taxon_id} ],
                            [ "select", "genetic_code" ]
                           );
    my $genetic_code = 11;
    $genetic_code = $code[0]->{genetic_code} if (@code);

    # Create the initial GTO.
    $retVal = GenomeTypeObject->new();
    $retVal->set_metadata(
                      {
                          id               => $g->{genome_id},
                          scientific_name  => $g->{genome_name},
                          source           => 'PATRIC',
                          source_id        => $g->{genome_id},
                          ncbi_taxonomy_id => $g->{taxon_id},
                          taxonomy         => $g->{taxon_lineage_names},
                          domain           => $domain,
                          genetic_code     => $genetic_code
                          }
                         );

    # Get the taxonomic ranks.
    my $lineage = $g->{taxon_lineage_ids};
    if ($lineage) {
        my %taxMap = map { $_->{taxon_id} => [$_->{taxon_name}, $_->{taxon_id}, $_->{taxon_rank}] } $self->query(
                            "taxonomy",
                            [ "in", "taxon_id", '(' . join(',', @$lineage) . ')'],
                            ["select", "taxon_id", "taxon_name", "taxon_rank"]);
        $retVal->{ncbi_lineage} = [map { $taxMap{$_} } @$lineage];
    }

    # Get the contigs.
    my @contigs = $self->query(
                               "genome_sequence",
                               [ "eq",     "genome_id",   $genomeID ],
                               [ "select", "sequence_id", "sequence" ]
                              );
    my @gto_contigs;
    for my $contig (@contigs) {
        push @gto_contigs,
    {
        id           => $contig->{sequence_id},
        dna          => $contig->{sequence},
        genetic_code => $genetic_code
        };
    }
    $retVal->add_contigs( \@gto_contigs );
    undef @contigs;
    undef @gto_contigs;


    # Get the features.
    my @f = $self->query(
                         "genome_feature",
                         [ "eq", "genome_id", $genomeID ],
                         [
                          "select",        "patric_id",
                          "sequence_id",   "strand",
                          "segments",      "feature_type",
                          "product",       "aa_sequence_md5",
                          "alt_locus_tag", "refseq_locus_tag",
                          "protein_id",    "gene_id",
                          "gi",            "gene",
                          "uniprotkb_accession", "genome_id"
                          ]
                        );

    my %md5s = map { $_->{aa_sequence_md5} => 1 } grep { $_ } @f;
    my $sequences = $self->lookup_sequence_data_hash([ keys %md5s ]);

    # This prevents duplicates.
    my %fids;
    for my $f (@f) {
        # Skip duplicates and nonstandard genome IDs.
        my $fid = $f->{patric_id};
        if ($fid && ! $fids{$fid} && $fid =~ /fig\|(\d+\.\d+)/ && $1 eq $genomeID) {
            my $prefix = $f->{sequence_id} . "_";
            my $strand = $f->{strand};
            my @locs;
            for my $s ( @{ $f->{segments} } ) {
                my ( $s1, $s2 ) = split /\.\./, $s;
                my $len = $s2 + 1 - $s1;
                my $start = ( $strand eq '-' ? $s2 : $s1 );

                # push @locs, "$prefix$start$strand$len";
                push @locs,
                [
                 $f->{sequence_id}, ( $strand eq '-' ? $s2 : $s1 ),
                 $strand, $len
                 ];
            }
            my @aliases;
            push( @aliases, "gi|$f->{gi}" )          if $f->{gi};
            push( @aliases, $f->{gene} )             if $f->{gene};
            push( @aliases, "GeneID:$f->{gene_id}" ) if $f->{gene_id};
            push( @aliases, $f->{refseq_locus_tag} ) if $f->{refseq_locus_tag};
            if ( ref( $f->{uniprotkb_accession} ) ) {
                push( @aliases, @{ $f->{uniprotkb_accession} } );
            }
            my @familyList;
            if ($f->{pgfam_id}) {
                @familyList = (['PGF', $f->{pgfam_id}]);
            }
            $retVal->add_feature(
                             {
                                 -annotator           => "PATRIC",
                                 -annotation          => "Add feature from PATRIC",
                                 -id                  => $fid,
                                 -location            => \@locs,
                                 -type                => $f->{feature_type},
                                 -function            => $f->{product},
                                 -protein_translation => $sequences->{$f->{aa_sequence_md5}},
                                 -aliases             => \@aliases,
                                 -family_assignments => \@familyList
                                 }
                                );
            $fids{$fid} = 1;
        }
    }

    #
    # Fill in subsystem data.
    #
    # Since the data we're pulling from has been denormalized, we need to
    # collapse both the subsystem and role-binding information back into
    # key/list data sets. We do this with the intermediate data structures
    # %subs hash for subsystems and the $sub->{rbhash} hash for role bindings.
    #
    my @ss = $self->query("subsystem",
                         [ "eq", "genome_id", $genomeID ],
                         [ "select", qw(subsystem_id subsystem_name
                                        superclass class subclass
                                        active patric_id role_id role_name) ]);

    my %subs;
    for my $ent (@ss)
    {
        my $sub = $subs{$ent->{subsystem_id}};
        if (!$sub)
        {
            $sub = {
                name => $ent->{subsystem_name},
                classification => [@$ent{qw(superclass class subclass)}],
                variant_code => $ent->{active},
                rbhash => {},
            };
            $subs{$ent->{subsystem_id}} = $sub;
        }
        push @{$sub->{rbhash}->{$ent->{role_name}}}, $ent->{patric_id};
    }
    #
    # Massage the hash-based datastructure back into lists for return.
    #

    my $slist = $retVal->{subsystems} = [];
    for my $sub (sort { $a->{classification}->[0] cmp $b->{classification}->[0] or
                            $a->{classification}->[1] cmp $b->{classification}->[1] or
                                $a->{classification}->[2] cmp $b->{classification}->[2] or
                                    $a->{subsystem_name} cmp $b->{subsystem_name} } values %subs)
    {
        my $h = delete $sub->{rbhash};
        my $rlist = $sub->{role_bindings} = [];
        for my $r (sort { $a cmp $b } keys %$h)
        {
            push @$rlist, { role_id => $r, features => $h->{$r}};
        }
        push(@$slist, $sub);
    }

    # Return the GTO.
    return $retVal;
}

=head3 fasta_of

    my $triples = $d->fasta_of($genomeID);

Return a set of contig triples for the specified genome. Each triple is [id, comment, sequence].

=over 4

=item genomeID

ID of the source genome.

=item RETURN

Returns a reference to a list of 3-tuples, one per contig in the genome. Each tuple consists of (0) an ID, (1)
an empty string (comment), and (2) the contig DNA sequence.

=back

=cut

sub fasta_of {
    my ( $self, $genomeID ) = @_;
    my $retVal;

    # Get the contigs.
    my @contigs = $self->query(
        "genome_sequence",
        [ "eq",     "genome_id",   $genomeID ],
        [ "select", "sequence_id", "sequence" ]
    );
    # Create the triples.
    my @retVal = map { [$_->{sequence_id}, '', $_->{sequence}] } @contigs;
    # Return the list of triples.
    return \@retVal;
}

sub is_reference_genome
{
    my($self, $genome) = @_;

    my $cache = $self->reference_genome_cache;
    if (!$cache)
    {
        $cache = $self->fill_reference_genome_cache();
    }

    return $cache->{$genome}->{reference_genome};
}

sub representative_reference_genome_filter
{
    my($self) = @_;

    my $cache = $self->reference_genome_cache;
    if (!$cache)
    {
        $cache = $self->fill_reference_genome_cache();
    }
    my @list = grep { $cache->{$_} ne '' } keys %$cache;
    return "genome_id:(" . join(" OR ", @list) . ")";
}

sub representative_genome_filter
{
    my($self) = @_;

    my $cache = $self->reference_genome_cache;
    if (!$cache)
    {
        $cache = $self->fill_reference_genome_cache();
    }
    my @list = grep { $cache->{$_}->{reference_genome} eq 'Representative' } keys %$cache;
    return "genome_id:(" . join(" OR ", @list) . ")";
}

sub reference_genome_filter
{
    my($self) = @_;

    my $cache = $self->reference_genome_cache;
    if (!$cache)
    {
        $cache = $self->fill_reference_genome_cache();
    }
    my @list = grep { $cache->{$_}->{reference_genome} eq 'Reference' } keys %$cache;
    return "genome_id:(" . join(" OR ", @list) . ")";
}

sub fill_reference_genome_cache
{
    my($self) = @_;

    print STDERR "$$ fill reference genome cache\n";
    my $cache = {};
    my $refs = $self->solr_query("genome", { q => "reference_genome:*", fl => "genome_id,reference_genome,genome_name"});
    $cache->{$_->{genome_id}} = $_ foreach @$refs;
    $self->reference_genome_cache($cache);
    return $cache;
}

=head3 debug_on

    $p3->debug_on($logH);

Turn on debugging to the specified log file.

=over 4

=item logH

Open file handle for debug messages.

=back

=cut

sub debug_on {
    my ($self, $logH) = @_;
    $self->{logH} = $logH;
}

=head3 _log

    $p3->_log($message);

Write the specified message to the log file (if any). If there has been no prior call to L<debug_on> nothing will happen.

=cut

sub _log {
    my ($self, $message) = @_;
    my $lh = $self->{logH};
    if ($lh) {
        print $lh $message;
    }
}

1;
