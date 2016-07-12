package P3DataAPI;

use LWP::UserAgent;
use strict;
use JSON::XS;
use Data::Dumper;
use gjoseqlib;
use URI::Escape;
use Digest::MD5 'md5_hex';

no warnings 'once';


eval {
    require FIG_Config;
};

our $default_url = $FIG_Config::p3_data_api_url || "https://www.patricbrc.org/api";

use warnings 'once';

sub new
{
    my($class, $url, $token) = @_;

    $url ||= $default_url;
    my $self = {
	url => $url,
	chunk_size => 50000,
	ua => LWP::UserAgent->new(),
	token => $token,
    };

    return bless $self, $class;
}

sub auth_header
{
    my($self) = @_;
    if ($self->{token})
    {
	return ("Authorization", $self->{token});
    }
    else
    {
	return ();
    }
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

sub query_cb
{
    my($self, $core, $cb_add, @query) = @_;

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
#			    $self->auth_header,
			   );
	if (!$resp->is_success)
	{
	    die "Failed: " . $resp->code . "\n" . $resp->content;
	}

	my $data = decode_json($resp->content);
	$cb_add->($data);

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
}

sub retrieve_contigs_in_genomes
{
    my($self, $genome_ids, $target_dir, $path_format) = @_;

    for my $gid (@$genome_ids)
    {
	my $gid_fh;
	
	$self->query_cb("genome_sequence",
			sub {
			    my($data) = @_;
			    if (!$gid_fh)
			    {
				my $fname = "$target_dir/" . sprintf($path_format, $gid);
				open($gid_fh, ">", $fname) or
				    die "cannot open $fname: $!";
			    }
			    for my $ent (@$data)
			    {
				print_alignment_as_fasta($gid_fh, ["accn|$ent->{sequence_id}",
								   "$ent->{description} [ $ent->{genome_name} | $ent->{genome_id} ]",
								   $ent->{sequence}]);
			    }
			},
			["eq", "genome_id", $gid]);

	close($gid_fh);
    }
	
}

sub compute_contig_md5s_in_genomes
{
    my($self, $genome_ids) = @_;

    my $out = {};
    
    for my $gid (@$genome_ids)
    {
	my $gid_fh;
	
	$self->query_cb("genome_sequence",
			sub {
			    my($data) = @_;
			    for my $ent (@$data)
			    {
				my $md5 = md5_hex(lc($ent->{sequence}));
				$out->{$gid}->{$ent->{sequence_id}} = $md5;
			    }
			},
			["eq", "genome_id", $gid]);

    }
    return $out;
}

sub retrieve_protein_features_in_genomes
{
    my($self, $genome_ids, $fasta_file, $id_map_file) = @_;

    my($fasta_fh, $id_map_fh);
    open($fasta_fh, ">", $fasta_file) or die "Cannot write $fasta_file: $!";
    open($id_map_fh, ">", $id_map_file) or die "Cannot write $id_map_file: $!";

    my %map;
    
    for my $gid (@$genome_ids)
    {
	$self->query_cb("genome_feature",
			sub {
			    my($data) = @_;
			    for my $ent (@$data)
			    {
				if (!exists($map{$ent->{aa_sequence_md5}}))
				{
				    $map{$ent->{aa_sequence_md5}} = [$ent->{feature_id}];
				    print_alignment_as_fasta($fasta_fh,
							     [$ent->{aa_sequence_md5}, undef, $ent->{aa_sequence}]);
				}
				else
				{
				    push(@{$map{$ent->{aa_sequence_md5}}}, $ent->{feature_id});
				}
			    }
			},
			["eq", "feature_type", "CDS"],
			["eq", "genome_id", $gid],
			["select", "feature_id,aa_sequence,aa_sequence_md5"],			
		       );
    }
    close($fasta_fh);
    while (my($k, $v) = each %map)
    {
	print $id_map_fh join("\t", $k, @$v), "\n";
    }
    close($id_map_fh);
}

sub retrieve_protein_features_with_role
{
    my($self, $role) = @_;

    my @out;

    $role =~ s/\s*\([ET]C.*\)\s*$//;

    my $esc_role = uri_escape($role, " ");
    $esc_role =~ s/\(.*$/*/;

    my %misses;
    $self->query_cb("genome_feature",
		    sub {
			my($data) = @_;
			for my $ent (@$data)
			{
			    my $fn = $ent->{product};
			    $fn =~ s/\s*\(EC.*\)\s*$//;

			    $fn =~ s/^\s*//;
			    $fn =~ s/\s*$//;
			    
			    if ($fn eq $role)
			    {
				push(@out, [$ent->{genome_id}, $ent->{aa_sequence}]);
				# print "$ent->{patric_id} $fn\n";
			    }
			    else
			    {
				$misses{$fn}++;
			    }
			}
		    },
		    ["eq", "feature_type", "CDS"],
		    ["eq", "annotation", "PATRIC"],
		    ["eq", "product", $esc_role],
		    ["select", "genome_id,aa_sequence,product,patric_id"],
		   );

    if (%misses)
    {
	print STDERR "Misses for $role:\n";
	for my $f (sort keys %misses)
	{
	    print STDERR "$f\t$misses{$f}\n";
	}
    }
    
    
    return @out;
}

sub retrieve_protein_features_in_genomes_with_role
{
    my($self, $genome_ids, $role) = @_;

    my @out;
    
    for my $gid (@$genome_ids)
    {
	$self->query_cb("genome_feature",
			sub {
			    my($data) = @_;
			    for my $ent (@$data)
			    {
				push(@out, [$gid, $ent->{aa_sequence}]);
				print "$ent->{patric_id} $ent->{product}\n";
			    }
			},
			["eq", "feature_type", "CDS"],
			["eq", "annotation", "PATRIC"],
			["eq", "genome_id", $gid],
			["eq", "product", $role],
			["select", "feature_id,aa_sequence,aa_sequence_md5,product,patric_id"],
		       );
    }
    return @out;
}

sub retrieve_dna_features_in_genomes
{
    my($self, $genome_ids, $fasta_file, $id_map_file) = @_;

    my($fasta_fh, $id_map_fh);
    open($fasta_fh, ">", $fasta_file) or die "Cannot write $fasta_file: $!";
    open($id_map_fh, ">", $id_map_file) or die "Cannot write $id_map_file: $!";

    my %map;
    
    for my $gid (@$genome_ids)
    {
	$self->query_cb("genome_feature",
			sub {
			    my($data) = @_;
			    for my $ent (@$data)
			    {
				my $seq = $ent->{na_sequence};
				my $md5 = md5_hex(uc($seq));
				if (!exists($map{$md5}))
				{
				    $map{$md5} = [$ent->{feature_id}];
				    print_alignment_as_fasta($fasta_fh,
							     [$md5, undef, $ent->{na_sequence}]);
				}
				else
				{
				    push(@{$map{$md5}}, $ent->{feature_id});
				}
			    }
			},
			["eq", "genome_id", $gid],
			["select", "feature_id,na_sequence"],
		       );
    }
    close($fasta_fh);
    while (my($k, $v) = each %map)
    {
	print $id_map_fh join("\t", $k, @$v), "\n";
    }
    close($id_map_fh);
}

=head3 gto_of

    my $gto = $d->gto_of($genomeID);

Return a L<GenomeTypeObject> for the specified genome.

=over 4

=item genomeID

ID of the source genome.

=item RETURN

Returns a L<GenomeTypeObject> for the genome, or C<undef> if the genome was not found.

=back

=cut

sub gto_of {
    my ($self, $genomeID) = @_;
    require GenomeTypeObject;
    my $retVal;
    # Get the basic genome data.
    my ($g) = $self->query("genome", ["eq", "genome_id", $genomeID],
                    ["select", "genome_id", "genome_name", "genome_status", "taxon_id",  "taxon_lineage_names"],
                    );
    # Only proceed if we found a genome.
    if ($g) {
        # Compute the domain.
        my $domain = $g->{taxon_lineage_names}[1];
        if (! grep { $_ eq $domain} qw(Bacteria Archaea Eukaryota)) {
            $domain = $g->{taxon_lineage_names}[0];
        }
        # Compute the genetic code.
        my $genetic_code = 11; # Some day we need to fix this.
        # Create the initial GTO.
        $retVal = GenomeTypeObject->new();
        $retVal->set_metadata({ id => $g->{genome_id},
                                scientific_name => $g->{genome_name},
                                source => 'PATRIC',
                                source_id => $g->{genome_id},
                                ncbi_taxonomy_id => $g->{taxon_id},
                                taxonomy => $g->{taxon_lineage_names},
                                domain => $domain,
                                genetic_code => $genetic_code
        });
        # Get the contigs.
        my @contigs = $self->query("genome_sequence", ["eq", "genome_id", $genomeID],
                        ["select", "sequence_id", "sequence"]);
        my @gto_contigs;
        for my $contig (@contigs) {
            push @gto_contigs, { id => $contig->{sequence_id}, dna => $contig->{sequence},
                genetic_code => $genetic_code };
        }
        $retVal->add_contigs(\@gto_contigs);
        undef @contigs;
        undef @gto_contigs;
        # Get the features.
        my @f = $self->query("genome_feature", ["eq", "genome_id", $genomeID],
                        ["select", "patric_id", "sequence_id", "strand", "segments", "feature_type", "product", "aa_sequence"]);
        # This prevents duplicates.
        my %fids;
        for my $f (@f) {
            # Skip duplicates.
            my $fid = $f->{patric_id};
            if ($fid && ! $fids{$fid}) {
                my $prefix = $f->{sequence_id} . "_";
                my $strand = $f->{strand};
                my @locs;
                for my $s (@{$f->{segments}}) {
                    my ($s1, $s2) = split /\.\./, $s;
                    my $len = $s2 + 1 - $s1;
                    my $start = ($strand eq '-' ? $s2 : $s1);
                    push @locs, "$prefix$start$strand$len";
                }
                $retVal->add_feature({-id => $fid, -location => \@locs,
                        -type => $f->{feature_type}, -function => $f->{product},
                        -protein_translation => $f->{aa_sequence} });
                $fids{$fid} = 1;
            }
        }
    }
    # Return the GTO.
    return $retVal;
}

