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
    # Get the basic genome data.
    my ($g) = $self->query("genome", ["eq", "genome_id", $genomeID],
                    ["select", "genome_id", "genome_name", "genome_status", "taxon_id",  "taxon_lineage_names"],
                    );
    # Compute the domain.
    my $domain = $g->{taxon_lineage_names}[1];
    if (! grep { $_ eq $domain} qw(Bacteria Archaea Eukaryota)) {
        $domain = $g->{taxon_lineage_names}[0];
    }
    # Compute the genetic code.
    my $genetic_code = 11; # Some day we need to fix this.
    # Create the initial GTO.
    my $retVal = GenomeTypeObject->new();
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
        if (! $fids{$fid}) {
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
    # Return the GTO.
    return $retVal;
}

