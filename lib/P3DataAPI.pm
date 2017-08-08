package P3DataAPI;

# This is a SAS Component

use File::Temp;
use LWP::UserAgent;
use strict;
use JSON::XS;
use Data::Dumper;
use gjoseqlib;
use URI::Escape;
use Digest::MD5 'md5_hex';
use Time::HiRes 'gettimeofday';
use DBI;
use HTTP::Request::Common;
our $have_async;
eval {
    require Net::HTTPS::NB;
    require HTTP::Async;
    $have_async = 1;
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
  || "https://www.patricbrc.org/api";

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
    $token_path = "$dir/.patric_token";
} else {
    $token_path = "$ENV{HOME}/.patric_token";
}

use warnings 'once';

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(qw(benchmark chunk_size url ua reference_genome_cache family_db_dsn family_db_user debug) );

sub new {
    my ( $class, $url, $token ) = @_;

    if (!$token)
    {
        if (open(my $fh, "<", $token_path))
        {
            $token = <$fh>;
            chomp $token;
            close($fh);
        }
    }

    $url ||= $default_url;
    my $self = {
        url        => $url,
        chunk_size => 50000,
        ua         => LWP::UserAgent->new(),
        token      => $token,
        benchmark  => 0,
        reference_genome_cache => undef,
        family_db_dsn => "DBI:mysql:database=fams_2016_0819;host=fir.mcs.anl.gov",
        family_db_user => 'p3',
    };

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

    my @q;
    for my $ent (@query) {
        my ( $k, @vals ) = @$ent;
        if ( @vals == 1 && ref( $vals[0] ) ) {
            @vals = @{ $vals[0] };
        }
        my $qe = "$k(" . join( ",", @vals ) . ")";
        push( @q, $qe );
    }
    $qstr = join( "&", @q );

    my $url   = $self->{url} . "/$core";
    my $ua    = $self->{ua};
    my $done  = 0;
    my $chunk = $self->{chunk_size};
    my $start = 0;

    my @result;
    while ( !$done ) {
        my $lim = "limit($chunk,$start)";
        my $q   = "$qstr&$lim";

        #       print STDERR "Qry $url '$q'\n";
        #	my $resp = $ua->post($url,
        #			     Accept => "application/json",
        #			     Content => $q);
        my $end;
        $start = gettimeofday if $self->{benchmark};
        # print STDERR "$url?$q\n";
        my $resp = $ua->get( "$url?$q", Accept => "application/json" , $self->auth_header);
        # print STDERR Dumper($resp);
        $end = gettimeofday if $self->{benchmark};
        if ( !$resp->is_success ) {
            my $content = $resp->content || $q;
            die "Failed: " . $resp->code . " $content";
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

            last if ( $next >= $count );
            $start = $next;
        }
    }
    return @result;
}

sub query_cb {
    my ( $self, $core, $cb_add, @query ) = @_;

    my $qstr;

    my @q;
    for my $ent (@query) {
        my ( $k, @vals ) = @$ent;
        if ( @vals == 1 && ref( $vals[0] ) ) {
            @vals = @{ $vals[0] };
        }
        my $qe = "$k(" . join( ",", @vals ) . ")";
        push( @q, $qe );
    }
    $qstr = join( "&", @q );

    my $url   = $self->{url} . "/$core";
    my $ua    = $self->{ua};
    my $done  = 0;
    my $chunk = $self->{chunk_size};
    my $start = 0;

    my @result;
    while ( !$done ) {
        my $lim = "limit($chunk,$start)";
        my $q   = "$qstr&$lim";

        #	print "Qry $url '$q'\n";
        #	my $resp = $ua->post($url,
        #			     Accept => "application/json",
        #			     Content => $q);
        my $qurl = "$url?$q";

        # print STDERR "'$url?$q'\n";

        # 	my $req = HTTP::Request::Common::GET($qurl,
        # 					     Accept => "application/json",
        # 					     #			    $self->auth_header,
        # 					    );
        # 	print Dumper($req);

        my $resp = $ua->get($qurl,
                            Accept => "application/json",
                            $self->auth_header,
                           );
        if ( !$resp->is_success ) {
            die "Failed: " . $resp->code . "\n" . $resp->content;
        }

        my $data = decode_json( $resp->content );
        $cb_add->($data);

        my $r = $resp->header('content-range');

        #	print "r=$r\n";
        if ( $r =~ m,items\s+(\d+)-(\d+)/(\d+), ) {
            my $this_start = $1;
            my $next       = $2;
            my $count      = $3;

            last if ( $next >= $count );
            $start = $next;
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
            },
            [ "eq", "genome_id", $gid ]
        );

        close($gid_fh);
    }

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
            },
            [ "eq", "genome_id", $gid ]
        );

    }
    return $out;
}

sub retrieve_protein_features_in_genomes {
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
                    if ( !exists( $map{ $ent->{aa_sequence_md5} } ) ) {
                        $map{ $ent->{aa_sequence_md5} } =
                          [ $ent->{feature_id} ];
                        print_alignment_as_fasta(
                            $fasta_fh,
                            [
                                $ent->{aa_sequence_md5}, undef,
                                $ent->{aa_sequence}
                            ]
                        );
                    } else {
                        push(
                            @{ $map{ $ent->{aa_sequence_md5} } },
                            $ent->{feature_id}
                        );
                    }
                }
            },
            [ "eq",     "feature_type", "CDS" ],
            [ "eq",     "genome_id",    $gid ],
            [ "select", "feature_id,aa_sequence,aa_sequence_md5" ],
        );
    }
    close($fasta_fh);
    while ( my ( $k, $v ) = each %map ) {
        print $id_map_fh join( "\t", $k, @$v ), "\n";
    }
    close($id_map_fh);
}

sub retrieve_protein_features_in_genome_in_export_format {
    my ( $self, $genome_id, $fasta_fh ) = @_;

    $self->query_cb("genome_feature",
		    sub {
			my ($data) = @_;
			for my $ent (@$data) {
			    my $def = "  $ent->{product} [$ent->{genome_name} | $genome_id]";
			    print_alignment_as_fasta($fasta_fh,
						     [
						      $ent->{patric_id},
						      $def,
						      $ent->{aa_sequence}
						      ]
						    );
			}
                    },
		    [ "eq",     "feature_type", "CDS" ],
		    [ "eq",     "genome_id",    $genome_id ],
		    [ "select", "patric_id,aa_sequence,genome_name,product" ],
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
                for my $ent (@$data) {
                    print_alignment_as_fasta($temp,
                                             [
                                              $ent->{patric_id}, $ent->{product},
                                              $ent->{aa_sequence}
                                              ]
                                            );
                    push(@$ret_list, [@$ent{qw(patric_id product plfam_id pgfam_id)}]) if $ret_list;
                }
            },
            [ "eq",     "feature_type", "CDS" ],
             [ "eq", "annotation", "PATRIC"],
            [ "eq",     "genome_id",    $gid ],
            [ "select", "patric_id,product,aa_sequence,plfam_id,pgfam_id" ],
        );
    }
    close($temp);
    return wantarray ? ($temp, $ret_list) : $temp;
}

sub retrieve_protein_features_with_role {
    my ( $self, $role ) = @_;

    my @out;

    $role =~ s/\s*\([ET]C.*\)\s*$//;

    my $esc_role = uri_escape( $role, " " );
    $esc_role =~ s/\(.*$/*/;

    my %misses;
    $self->query_cb(
        "genome_feature",
        sub {
            my ($data) = @_;
            for my $ent (@$data) {
                my $fn = $ent->{product};
                $fn =~ s/\s*\(EC.*\)\s*$//;

                $fn =~ s/^\s*//;
                $fn =~ s/\s*$//;

                if ( $fn eq $role ) {
                    push( @out, [ $ent->{genome_id}, $ent->{aa_sequence} ] );

                    # print "$ent->{patric_id} $fn\n";
                } else {
                    $misses{$fn}++;
                }
            }
        },
        [ "eq",     "feature_type", "CDS" ],
        [ "eq",     "annotation",   "PATRIC" ],
        [ "eq",     "product",      $esc_role ],
        [ "select", "genome_id,aa_sequence,product,patric_id" ],
    );

    if (%misses) {
        print STDERR "Misses for $role:\n";
        for my $f ( sort keys %misses ) {
            print STDERR "$f\t$misses{$f}\n";
        }
    }

    return @out;
}

sub retrieve_features_of_type_with_role {
    my ( $self, $type, $role ) = @_;

    my @out;

    $role =~ s/\s*\([ET]C.*\)\s*$//;

    my $esc_role = uri_escape( $role, " " );
    $esc_role =~ s/\(.*$/*/;

    my %misses;
    $self->query_cb(
        "genome_feature",
        sub {
            my ($data) = @_;
            for my $ent (@$data) {
                my $fn = $ent->{product};
                $fn =~ s/\s*\(EC.*\)\s*$//;

                $fn =~ s/\s*#.*$//;

                $fn =~ s/^\s*//;
                $fn =~ s/\s*$//;

                if ( $fn eq $role ) {
                    push( @out, [ $ent->{genome_id}, $ent->{aa_sequence} ] );

                    # print "$ent->{patric_id} $fn\n";
                } else {
                    $misses{$fn}++;
                }
            }
        },
        [ "eq", "feature_type", $type ],
        [ "eq", "annotation",   "PATRIC" ],
        [ "eq", "product",      $esc_role ],
        [ "select", "genome_id,aa_sequence,na_sequence,product,patric_id" ],
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
            for my $ent (@$data) {
                my $fn = $ent->{product};
                if ( $fn =~
/(SSU\s+rRNA|Small\s+Subunit\s+(Ribosomal\s+r)?RNA|ssuRNA|16S\s+(r(ibosomal\s+)?)?RNA)/io
                  )
                {
                    push( @out, $ent );
                }
            }
        },
        [ "eq", "feature_type", "rrna" ],
        [ "eq", "annotation",   "PATRIC" ],
        $qry,
        [ "select", "genome_id,na_sequence,product,patric_id" ],
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
                for my $ent (@$data) {
                    push( @out, [ $gid, $ent->{aa_sequence} ] );
                    # print "$ent->{patric_id} $ent->{product}\n";
                }
            },
            [ "eq", "feature_type", "CDS" ],
            [ "eq", "annotation",   "PATRIC" ],
            [ "eq", "genome_id",    $gid ],
            [ "eq", "product",      $role ],
            [
                "select",
                "feature_id,aa_sequence,aa_sequence_md5,product,patric_id"
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
                    my $seq = $ent->{na_sequence};
                    my $md5 = md5_hex( uc($seq) );
                    if ( !exists( $map{$md5} ) ) {
                        $map{$md5} = [ $ent->{feature_id} ];
                        print_alignment_as_fasta( $fasta_fh,
                            [ $md5, undef, $ent->{na_sequence} ] );
                    } else {
                        push( @{ $map{$md5} }, $ent->{feature_id} );
                    }
                }
            },
            [ "eq",     "genome_id", $gid ],
            [ "select", "feature_id,na_sequence" ],
        );
    }
    close($fasta_fh);
    while ( my ( $k, $v ) = each %map ) {
        print $id_map_fh join( "\t", $k, @$v ), "\n";
    }
    close($id_map_fh);
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

    my @pin = $self->get_pin($peg, $coloring_method, $n_genomes, $genome_filter, $solr_filter);
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
    print STDERR Dumper(GIR => \@length_queries, $lengths, \%contig_lengths, \@genes_in_region_request);

    my @genes_in_region_response = $self->genes_in_region_bulk(\@genes_in_region_request);

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
                                                        fl => 'start,end,feature_id,product,figfam_id,strand,patric_id,pgfam_id,plfam_id,aa_sequence,genome_name,feature_type',
                                                    });

    my @out;
    my $leftmost = 1e12;
    my $rightmost = 0;
    for my $ent (@$res)
    {
        #
        # PATRIC stores start/end as left/right. Change to the SEED meaning.aa
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

    # print Dumper(\@out);
    return [ sort { $a->{mid} <=> $b->{mid} } @out ], $leftmost, $rightmost;
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

        push(@queries, ["genome_feature", { q => "genome_id:$genome AND accession:$contig AND (start:[$begx TO $endx] OR end:[$begx TO $endx]) AND annotation:PATRIC AND NOT feature_type:source",
                                                        fl => 'start,end,feature_id,product,figfam_id,strand,patric_id,pgfam_id,plfam_id,aa_sequence,genome_name,feature_type',
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
            # PATRIC stores start/end as left/right. Change to the SEED meaning.aa
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

sub get_pin_p3
{
    my($self, $fid, $family_type, $max_size, $genome_filter, $solr_filter) = @_;

    my $fam = $self->family_of($fid, $family_type);

    return undef unless $fam;

    my $pin = $self->members_of_family($fam, $family_type, $solr_filter, $fid);

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

sub get_pin
{
    my($self, $fid, $family_type, $max_size, $genome_filter, $solr_filter) = @_;

    my($me, @pin) = $self->get_pin_p3($fid, $family_type, $max_size, $genome_filter, $solr_filter);
    #my($me, @pin) = $self->get_pin_mysql($fid, $family_type, $max_size, $genome_filter);

    # print "me:$me\n";
    #  print "\t$_->{genome_id}\n" foreach @pin;

    my %cut_pin = map { $_->{patric_id} => $_ } @pin;

    my $tmp = File::Temp->new();
    my $tmp2 = File::Temp->new();

    print $tmp2 ">$fid\n$me->{aa_sequence}\n";
    close($tmp2);

    print $tmp ">$_->{patric_id}\n$_->{aa_sequence}\n" foreach @pin;
    close($tmp);
    my $rc = system("formatdb", "-p", "t", "-i", "$tmp");
    $rc == 0 or die "formatdb failed with $rc\n";

    system("cp $tmp /tmp/db");
    system("cp $tmp2 /tmp/q");
    my $evalue = "1e-5";

    open(my $blast, "-|", "blastall", "-p", "blastp", "-i", "$tmp2", "-d", "$tmp", "-m", 8, "-e", $evalue,
         ($max_size ? ("-b", $max_size) : ()))
        or die "cannot run blastall: $!";
    my @out;
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
    return ($me, @out);
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

sub members_of_family
{
    my($self, $fam, $family_type, $solr_filter, $fid) = @_;

    my $fam_field = $family_field_of_type{lc($family_type)};
    $fam_field or die "Unknown family type '$family_type'\n";

    my $q = join(" AND ", "$fam_field:$fam", $solr_filter ? "($solr_filter OR patric_id:$fid)" : ());
    my $res = $self->solr_query("genome_feature", { q => $q, fl => "patric_id,aa_sequence,accession,start,end,genome_id,genome_name,strand" });
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
            "taxon_id",    "taxon_lineage_names"
        ],
    );

    # Only proceed if we found a genome.
    if ($g) {

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
                "product",       "aa_sequence",
                "alt_locus_tag", "refseq_locus_tag",
                "protein_id",    "gene_id",
                "gi",            "gene",
                "uniprotkb_accession", "genome_id"
            ]
        );

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
                        -protein_translation => $f->{aa_sequence},
                        -aliases             => \@aliases,
                        -family_assignments => \@familyList
                    }
                );
                $fids{$fid} = 1;
            }
        }
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
        $cache = $self->fill_reference_gene_cache();
    }

    return $cache->{$genome}->{reference_genome};
}

sub representative_reference_genome_filter
{
    my($self) = @_;

    my $cache = $self->reference_genome_cache;
    if (!$cache)
    {
        $cache = $self->fill_reference_gene_cache();
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
        $cache = $self->fill_reference_gene_cache();
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
        $cache = $self->fill_reference_gene_cache();
    }
    my @list = grep { $cache->{$_}->{reference_genome} eq 'Reference' } keys %$cache;
    return "genome_id:(" . join(" OR ", @list) . ")";
}

sub fill_reference_gene_cache
{
    my($self) = @_;

    my $cache = {};
    my $refs = $self->solr_query("genome", { q => "reference_genome:*", fl => "genome_id,reference_genome,genome_name"});
    $cache->{$_->{genome_id}} = $_ foreach @$refs;
    $self->reference_genome_cache($cache);
    return $cache;
}
1;
