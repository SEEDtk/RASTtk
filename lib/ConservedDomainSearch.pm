#
# Simple client for retrieving data from CDD service.
#

package ConservedDomainSearch;

use FIG_Config;
use Data::Dumper;
use strict;
use JSON::XS;
use LWP::UserAgent;
use SeedUtils;
use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw(fig url ua));

our $idx = 1;

sub new
{
    my($class, $fig) = @_;

    my $self = {
        fig => $fig,
        url => $FIG_Config::ConservedDomainSearchURL,
        ua => LWP::UserAgent->new(),
    };
    $self->{ua}->timeout(3600);
    return bless $self, $class;
}

#
# Look up the given fid and create a set of new quasi-features with
# appropriately mapped locations.
#

sub create_cdd_features
{
    my($self, $fid, $options) = @_;

    my $cdd = $self->lookup($fid, $options);

    $cdd = $cdd->{$fid};

    print Dumper($cdd);

    my $loc = $self->fig->feature_location($fid);

    #
    # We are going to simplify this code by assuming contiguous locations.
    # It's just an approximation anyway.
    #

    my($contig, $left, $right, $strand) = SeedUtils::boundaries_of($loc);

    my $translation = $self->fig->get_translation($fid);

    my @out;
    my $subid = 1;

    my @ids;
    for my $what (qw(domain_hits site_annotations structural_motifs))
    {
        my $list = $cdd->{$what};
        for my $ent (@$list)
        {
            if ($what eq 'domain_hits')
            {
		push(@ids, $ent->[1]);
            }
            elsif ($what eq 'structural_motifs')
            {
		push(@ids, $ent->[3]);
            }
            else
            {
		push(@ids, $ent->[5]);
            }
	}
    }
    my $ids = $self->lookup_ids(\@ids);

    for my $what (qw(domain_hits site_annotations structural_motifs))
    {
        my $list = $cdd->{$what};
	my $pssmid;
        for my $ent (@$list)
        {
            my @locs;
	    my $cddid;
            my $anno;

            if ($what eq 'domain_hits')
            {
                @locs = ([$ent->[2], $ent->[3]]);
		$pssmid = $ent->[1];
                $anno = $ent->[7];
            }
            elsif ($what eq 'structural_motifs')
            {
                @locs = ([$ent->[1], $ent->[2]]);
                $anno = $ent->[0];
		$pssmid = $ent->[3];
            }
            else
            {
                $anno = $ent->[1];
		$pssmid = $ent->[5];
                my @x = split(/,/, $ent->[2]);
		for my $i (0..$#x)
		{
		    my($v) = $x[$i] =~ /(\d+)/;
		    push(@locs, [$v, $v, $i+1]);
		}
                # @locs = map { /(\d+)/ && [$1, $1] } @x;
            }
	    

            #
            # Now do the coordinate mapping & create features for each.
            #

            for my $loc (@locs)
            {
                my($pstart, $pend, $xidx) = @$loc;
                my($lbeg, $lend);
                if ($strand eq '+')
                {
		    $lbeg = $left + $pstart * 3;
		    $lend = $left + $pend * 3 - 1;
                }
                else
                {
		    $lbeg = $right - ($pstart - 1) *3;
		    $lend = $right - $pend * 3 + 1;
                }
		print STDERR "$anno $left $right $strand $pstart $pend $lbeg $lend\n";

                my $floc = join("_", $contig, $lbeg, $lend);
                my $trans = substr($translation, $pstart - 1, $pend - $pstart + 1);
                my $sfid = "$fid.$pstart-$pend.$what.$subid";
		my $info = $ids->{$pssmid};
		print Dumper($fid, $sfid, $pssmid, $info, $floc);
		if ($info)
		{
		    $sfid = $info->[0] . "-$fid-$subid";
		    $anno = $info->[1] . ": " . $info->[2];
		    $sfid .= "-$xidx" if (defined($xidx));
		}
		my $type = $what;
		$type =~ s/s$//;
                push(@out, [$sfid, $type, $anno, $floc, $trans]);
                $subid++;
            }
        }
    }
    return @out;
}

sub lookup
{
    my($self, $fid, $options) = @_;

    my $seq = $self->fig->get_translation($fid);
    my $md5 = $self->fig->md5_of_peg($fid);
    my $res = $self->lookup_seq($fid, $md5, $seq, $options);
    return $res;
}

sub lookup_seq
{
    my($self, $id, $md5, $seq, $options) = @_;

    $options = {} unless ref($options) eq 'HASH';

    my $req = {
        id => $idx++,
        method => 'ConservedDomainSearch.cdd_lookup',
        params => [[[ $id, $md5, $seq ]], $options],
    };
    my $res = $self->ua->post($self->url, Content => encode_json($req));
    if (!$res->is_success)
    {
        die "Failure invoking cdd_lookup: " . $res->status_line . "\n" .  $res->content;
    }
    my $data = decode_json($res->content);
    return $data->{result}->[0];
}

sub lookup_seqs
{
    my($self, $seqs, $options) = @_;

    $options = {} unless ref($options) eq 'HASH';

    my $req = {
        id => $idx++,
        method => 'ConservedDomainSearch.cdd_lookup',
        params => [$seqs, $options],
    };
    my $res = $self->ua->post($self->url, Content => encode_json($req));
    if (!$res->is_success)
    {
        die "Failure invoking cdd_lookup: " . $res->status_line . "\n" .  $res->content;
    }
    my $data = decode_json($res->content);
    return $data->{result}->[0];
}

sub lookup_ids
{
    my($self, $ids) = @_;

    my $req = {
        id => $idx++,
        method => 'ConservedDomainSearch.pssmid_lookup',
        params => [$ids]
    };
    my $res = $self->ua->post($self->url, Content => encode_json($req));
    if (!$res->is_success)
    {
        die "Failure invoking pssmid_lookup: " . $res->status_line . "\n" .  $res->content;
    }
    my $data = decode_json($res->content);
    return $data->{result}->[0];
}

=head3 domains_of

    my $fidHash = $cdd->domains_of(\@fids);

Compute the conserved domains for a list of features. For each feature, this method will return a list of the
IDs for the specific conserved domains found by the CDD server.

=over 4

=item fids

Reference to a list of feature IDs.

=item RETURN

Returns a reference to a hash keyed on feature ID that maps each one to a list of conserved domain IDs.

=back

=cut

sub domains_of {
    # Get the parameters.
    my ($self, $fids) = @_;
    # This will be the return hash.
    my %retVal;
    # Create the options hash.
    my %opts = (data_mode => 'rep');
    # Loop through the list of feature IDs.
    for my $fid (@$fids) {
        # Get this feature's CDD information.
        my $result = $self->lookup($fid, \%opts);
        # We'll put the domain IDs in here.
        my @doms;
        # Loop through the domain hits.
        my $hits = $result->{$fid}{domain_hits};
        for my $hit (@$hits) {
            # Get the accession information and type of this hit.
            if ($hit->[0] eq 'Specific') {
                push @doms, $hit->[6];
            }
        }
        # Return the hits.
        $retVal{$fid} = \@doms;
    }
    # Return the hash result.
    return \%retVal;
}

1;
