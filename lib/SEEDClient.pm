package SEEDClient;

use JSON::RPC::Legacy::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};


# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

SEEDClient

=head1 DESCRIPTION





=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => SEEDClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 compare_regions

  $return = $obj->compare_regions($opts)

=over 4

=item Parameter and return types

=begin html

<pre>
$opts is a compare_options
$return is a compared_regions
compare_options is a reference to a hash where the following keys are defined:
	pin has a value which is a reference to a list where each element is a string
	n_genomes has a value which is an int
	width has a value which is an int
	pin_alignment has a value which is a string
	pin_compute_method has a value which is a string
	sim_cutoff has a value which is a float
	limit_to_genomes has a value which is a reference to a list where each element is a string
	close_genome_collapse has a value which is a string
	coloring_method has a value which is a string
	color_sim_cutoff has a value which is a float
	genome_sort_method has a value which is a string
	features_for_cdd has a value which is a reference to a list where each element is a string
compared_regions is a reference to a list where each element is a genome_compare_info
genome_compare_info is a reference to a hash where the following keys are defined:
	beg has a value which is an int
	end has a value which is an int
	mid has a value which is an int
	org_name has a value which is a string
	pinned_peg_strand has a value which is a string
	genome_id has a value which is a string
	pinned_peg has a value which is a string
	features has a value which is a reference to a list where each element is a feature_compare_info
feature_compare_info is a reference to a hash where the following keys are defined:
	fid has a value which is a string
	beg has a value which is an int
	end has a value which is an int
	size has a value which is an int
	strand has a value which is a string
	contig has a value which is a string
	location has a value which is a string
	function has a value which is a string
	type has a value which is a string
	set_number has a value which is an int
	offset_beg has a value which is an int
	offset_end has a value which is an int
	offset has a value which is an int
	attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (key) a string
	1: (value) a string


</pre>

=end html

=begin text

$opts is a compare_options
$return is a compared_regions
compare_options is a reference to a hash where the following keys are defined:
	pin has a value which is a reference to a list where each element is a string
	n_genomes has a value which is an int
	width has a value which is an int
	pin_alignment has a value which is a string
	pin_compute_method has a value which is a string
	sim_cutoff has a value which is a float
	limit_to_genomes has a value which is a reference to a list where each element is a string
	close_genome_collapse has a value which is a string
	coloring_method has a value which is a string
	color_sim_cutoff has a value which is a float
	genome_sort_method has a value which is a string
	features_for_cdd has a value which is a reference to a list where each element is a string
compared_regions is a reference to a list where each element is a genome_compare_info
genome_compare_info is a reference to a hash where the following keys are defined:
	beg has a value which is an int
	end has a value which is an int
	mid has a value which is an int
	org_name has a value which is a string
	pinned_peg_strand has a value which is a string
	genome_id has a value which is a string
	pinned_peg has a value which is a string
	features has a value which is a reference to a list where each element is a feature_compare_info
feature_compare_info is a reference to a hash where the following keys are defined:
	fid has a value which is a string
	beg has a value which is an int
	end has a value which is an int
	size has a value which is an int
	strand has a value which is a string
	contig has a value which is a string
	location has a value which is a string
	function has a value which is a string
	type has a value which is a string
	set_number has a value which is an int
	offset_beg has a value which is an int
	offset_end has a value which is an int
	offset has a value which is an int
	attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (key) a string
	1: (value) a string



=end text

=item Description



=back

=cut

sub compare_regions
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_regions (received $n, expecting 1)");
    }
    {
	my($opts) = @args;

	my @_bad_arguments;
        (ref($opts) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"opts\" (value was \"$opts\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_regions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_regions');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.compare_regions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_regions',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_regions",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_regions',
				       );
    }
}



=head2 compare_regions_for_peg

  $return = $obj->compare_regions_for_peg($peg, $width, $n_genomes, $coloring_method)

=over 4

=item Parameter and return types

=begin html

<pre>
$peg is a string
$width is an int
$n_genomes is an int
$coloring_method is a string
$return is a compared_regions
compared_regions is a reference to a list where each element is a genome_compare_info
genome_compare_info is a reference to a hash where the following keys are defined:
	beg has a value which is an int
	end has a value which is an int
	mid has a value which is an int
	org_name has a value which is a string
	pinned_peg_strand has a value which is a string
	genome_id has a value which is a string
	pinned_peg has a value which is a string
	features has a value which is a reference to a list where each element is a feature_compare_info
feature_compare_info is a reference to a hash where the following keys are defined:
	fid has a value which is a string
	beg has a value which is an int
	end has a value which is an int
	size has a value which is an int
	strand has a value which is a string
	contig has a value which is a string
	location has a value which is a string
	function has a value which is a string
	type has a value which is a string
	set_number has a value which is an int
	offset_beg has a value which is an int
	offset_end has a value which is an int
	offset has a value which is an int
	attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (key) a string
	1: (value) a string


</pre>

=end html

=begin text

$peg is a string
$width is an int
$n_genomes is an int
$coloring_method is a string
$return is a compared_regions
compared_regions is a reference to a list where each element is a genome_compare_info
genome_compare_info is a reference to a hash where the following keys are defined:
	beg has a value which is an int
	end has a value which is an int
	mid has a value which is an int
	org_name has a value which is a string
	pinned_peg_strand has a value which is a string
	genome_id has a value which is a string
	pinned_peg has a value which is a string
	features has a value which is a reference to a list where each element is a feature_compare_info
feature_compare_info is a reference to a hash where the following keys are defined:
	fid has a value which is a string
	beg has a value which is an int
	end has a value which is an int
	size has a value which is an int
	strand has a value which is a string
	contig has a value which is a string
	location has a value which is a string
	function has a value which is a string
	type has a value which is a string
	set_number has a value which is an int
	offset_beg has a value which is an int
	offset_end has a value which is an int
	offset has a value which is an int
	attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (key) a string
	1: (value) a string



=end text

=item Description



=back

=cut

sub compare_regions_for_peg
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 4)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_regions_for_peg (received $n, expecting 4)");
    }
    {
	my($peg, $width, $n_genomes, $coloring_method) = @args;

	my @_bad_arguments;
        (!ref($peg)) or push(@_bad_arguments, "Invalid type for argument 1 \"peg\" (value was \"$peg\")");
        (!ref($width)) or push(@_bad_arguments, "Invalid type for argument 2 \"width\" (value was \"$width\")");
        (!ref($n_genomes)) or push(@_bad_arguments, "Invalid type for argument 3 \"n_genomes\" (value was \"$n_genomes\")");
        (!ref($coloring_method)) or push(@_bad_arguments, "Invalid type for argument 4 \"coloring_method\" (value was \"$coloring_method\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_regions_for_peg:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_regions_for_peg');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.compare_regions_for_peg",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_regions_for_peg',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_regions_for_peg",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_regions_for_peg',
				       );
    }
}



=head2 get_ncbi_cdd_url

  $url = $obj->get_ncbi_cdd_url($feature)

=over 4

=item Parameter and return types

=begin html

<pre>
$feature is a string
$url is a string

</pre>

=end html

=begin text

$feature is a string
$url is a string


=end text

=item Description



=back

=cut

sub get_ncbi_cdd_url
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_ncbi_cdd_url (received $n, expecting 1)");
    }
    {
	my($feature) = @args;

	my @_bad_arguments;
        (!ref($feature)) or push(@_bad_arguments, "Invalid type for argument 1 \"feature\" (value was \"$feature\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_ncbi_cdd_url:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_ncbi_cdd_url');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.get_ncbi_cdd_url",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_ncbi_cdd_url',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_ncbi_cdd_url",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_ncbi_cdd_url',
				       );
    }
}



=head2 compute_cdd_for_row

  $cdds = $obj->compute_cdd_for_row($pegs)

=over 4

=item Parameter and return types

=begin html

<pre>
$pegs is a genome_compare_info
$cdds is a reference to a list where each element is a feature_compare_info
genome_compare_info is a reference to a hash where the following keys are defined:
	beg has a value which is an int
	end has a value which is an int
	mid has a value which is an int
	org_name has a value which is a string
	pinned_peg_strand has a value which is a string
	genome_id has a value which is a string
	pinned_peg has a value which is a string
	features has a value which is a reference to a list where each element is a feature_compare_info
feature_compare_info is a reference to a hash where the following keys are defined:
	fid has a value which is a string
	beg has a value which is an int
	end has a value which is an int
	size has a value which is an int
	strand has a value which is a string
	contig has a value which is a string
	location has a value which is a string
	function has a value which is a string
	type has a value which is a string
	set_number has a value which is an int
	offset_beg has a value which is an int
	offset_end has a value which is an int
	offset has a value which is an int
	attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (key) a string
	1: (value) a string


</pre>

=end html

=begin text

$pegs is a genome_compare_info
$cdds is a reference to a list where each element is a feature_compare_info
genome_compare_info is a reference to a hash where the following keys are defined:
	beg has a value which is an int
	end has a value which is an int
	mid has a value which is an int
	org_name has a value which is a string
	pinned_peg_strand has a value which is a string
	genome_id has a value which is a string
	pinned_peg has a value which is a string
	features has a value which is a reference to a list where each element is a feature_compare_info
feature_compare_info is a reference to a hash where the following keys are defined:
	fid has a value which is a string
	beg has a value which is an int
	end has a value which is an int
	size has a value which is an int
	strand has a value which is a string
	contig has a value which is a string
	location has a value which is a string
	function has a value which is a string
	type has a value which is a string
	set_number has a value which is an int
	offset_beg has a value which is an int
	offset_end has a value which is an int
	offset has a value which is an int
	attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (key) a string
	1: (value) a string



=end text

=item Description



=back

=cut

sub compute_cdd_for_row
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compute_cdd_for_row (received $n, expecting 1)");
    }
    {
	my($pegs) = @args;

	my @_bad_arguments;
        (ref($pegs) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"pegs\" (value was \"$pegs\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compute_cdd_for_row:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compute_cdd_for_row');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.compute_cdd_for_row",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compute_cdd_for_row',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compute_cdd_for_row",
					    status_line => $self->{client}->status_line,
					    method_name => 'compute_cdd_for_row',
				       );
    }
}



=head2 compute_cdd_for_feature

  $cdds = $obj->compute_cdd_for_feature($feature)

=over 4

=item Parameter and return types

=begin html

<pre>
$feature is a feature_compare_info
$cdds is a reference to a list where each element is a feature_compare_info
feature_compare_info is a reference to a hash where the following keys are defined:
	fid has a value which is a string
	beg has a value which is an int
	end has a value which is an int
	size has a value which is an int
	strand has a value which is a string
	contig has a value which is a string
	location has a value which is a string
	function has a value which is a string
	type has a value which is a string
	set_number has a value which is an int
	offset_beg has a value which is an int
	offset_end has a value which is an int
	offset has a value which is an int
	attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (key) a string
	1: (value) a string


</pre>

=end html

=begin text

$feature is a feature_compare_info
$cdds is a reference to a list where each element is a feature_compare_info
feature_compare_info is a reference to a hash where the following keys are defined:
	fid has a value which is a string
	beg has a value which is an int
	end has a value which is an int
	size has a value which is an int
	strand has a value which is a string
	contig has a value which is a string
	location has a value which is a string
	function has a value which is a string
	type has a value which is a string
	set_number has a value which is an int
	offset_beg has a value which is an int
	offset_end has a value which is an int
	offset has a value which is an int
	attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (key) a string
	1: (value) a string



=end text

=item Description



=back

=cut

sub compute_cdd_for_feature
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compute_cdd_for_feature (received $n, expecting 1)");
    }
    {
	my($feature) = @args;

	my @_bad_arguments;
        (ref($feature) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"feature\" (value was \"$feature\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compute_cdd_for_feature:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compute_cdd_for_feature');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.compute_cdd_for_feature",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compute_cdd_for_feature',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compute_cdd_for_feature",
					    status_line => $self->{client}->status_line,
					    method_name => 'compute_cdd_for_feature',
				       );
    }
}



=head2 get_palette

  $colors = $obj->get_palette($palette_name)

=over 4

=item Parameter and return types

=begin html

<pre>
$palette_name is a string
$colors is a reference to a list where each element is a reference to a list containing 3 items:
	0: (r) an int
	1: (g) an int
	2: (b) an int

</pre>

=end html

=begin text

$palette_name is a string
$colors is a reference to a list where each element is a reference to a list containing 3 items:
	0: (r) an int
	1: (g) an int
	2: (b) an int


=end text

=item Description



=back

=cut

sub get_palette
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_palette (received $n, expecting 1)");
    }
    {
	my($palette_name) = @args;

	my @_bad_arguments;
        (!ref($palette_name)) or push(@_bad_arguments, "Invalid type for argument 1 \"palette_name\" (value was \"$palette_name\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_palette:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_palette');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.get_palette",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_palette',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_palette",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_palette',
				       );
    }
}



=head2 get_function

  $functions = $obj->get_function($fids)

=over 4

=item Parameter and return types

=begin html

<pre>
$fids is a reference to a list where each element is a feature_id
$functions is a reference to a hash where the key is a feature_id and the value is a string
feature_id is a string

</pre>

=end html

=begin text

$fids is a reference to a list where each element is a feature_id
$functions is a reference to a hash where the key is a feature_id and the value is a string
feature_id is a string


=end text

=item Description



=back

=cut

sub get_function
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_function (received $n, expecting 1)");
    }
    {
	my($fids) = @args;

	my @_bad_arguments;
        (ref($fids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"fids\" (value was \"$fids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_function:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_function');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.get_function",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_function',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_function",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_function',
				       );
    }
}



=head2 assign_function

  $result = $obj->assign_function($functions, $user, $token)

=over 4

=item Parameter and return types

=begin html

<pre>
$functions is a reference to a hash where the key is a feature_id and the value is a string
$user is a string
$token is a string
$result is a reference to a hash where the key is a feature_id and the value is an assignment_result
feature_id is a string
assignment_result is a reference to a hash where the following keys are defined:
	success has a value which is an int
	text has a value which is a string

</pre>

=end html

=begin text

$functions is a reference to a hash where the key is a feature_id and the value is a string
$user is a string
$token is a string
$result is a reference to a hash where the key is a feature_id and the value is an assignment_result
feature_id is a string
assignment_result is a reference to a hash where the following keys are defined:
	success has a value which is an int
	text has a value which is a string


=end text

=item Description



=back

=cut

sub assign_function
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function assign_function (received $n, expecting 3)");
    }
    {
	my($functions, $user, $token) = @args;

	my @_bad_arguments;
        (ref($functions) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"functions\" (value was \"$functions\")");
        (!ref($user)) or push(@_bad_arguments, "Invalid type for argument 2 \"user\" (value was \"$user\")");
        (!ref($token)) or push(@_bad_arguments, "Invalid type for argument 3 \"token\" (value was \"$token\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to assign_function:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'assign_function');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.assign_function",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'assign_function',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method assign_function",
					    status_line => $self->{client}->status_line,
					    method_name => 'assign_function',
				       );
    }
}



=head2 get_location

  $locations = $obj->get_location($fids)

=over 4

=item Parameter and return types

=begin html

<pre>
$fids is a reference to a list where each element is a feature_id
$locations is a reference to a hash where the key is a feature_id and the value is a location
feature_id is a string
location is a string

</pre>

=end html

=begin text

$fids is a reference to a list where each element is a feature_id
$locations is a reference to a hash where the key is a feature_id and the value is a location
feature_id is a string
location is a string


=end text

=item Description



=back

=cut

sub get_location
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_location (received $n, expecting 1)");
    }
    {
	my($fids) = @args;

	my @_bad_arguments;
        (ref($fids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"fids\" (value was \"$fids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_location:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_location');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.get_location",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_location',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_location",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_location',
				       );
    }
}



=head2 get_translation

  $translations = $obj->get_translation($fids)

=over 4

=item Parameter and return types

=begin html

<pre>
$fids is a reference to a list where each element is a feature_id
$translations is a reference to a hash where the key is a feature_id and the value is a translation
feature_id is a string
translation is a string

</pre>

=end html

=begin text

$fids is a reference to a list where each element is a feature_id
$translations is a reference to a hash where the key is a feature_id and the value is a translation
feature_id is a string
translation is a string


=end text

=item Description



=back

=cut

sub get_translation
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_translation (received $n, expecting 1)");
    }
    {
	my($fids) = @args;

	my @_bad_arguments;
        (ref($fids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"fids\" (value was \"$fids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_translation:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_translation');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.get_translation",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_translation',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_translation",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_translation',
				       );
    }
}



=head2 is_real_feature

  $results = $obj->is_real_feature($fids)

=over 4

=item Parameter and return types

=begin html

<pre>
$fids is a reference to a list where each element is a feature_id
$results is a reference to a hash where the key is a feature_id and the value is an int
feature_id is a string

</pre>

=end html

=begin text

$fids is a reference to a list where each element is a feature_id
$results is a reference to a hash where the key is a feature_id and the value is an int
feature_id is a string


=end text

=item Description



=back

=cut

sub is_real_feature
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function is_real_feature (received $n, expecting 1)");
    }
    {
	my($fids) = @args;

	my @_bad_arguments;
        (ref($fids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"fids\" (value was \"$fids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to is_real_feature:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'is_real_feature');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.is_real_feature",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'is_real_feature',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method is_real_feature",
					    status_line => $self->{client}->status_line,
					    method_name => 'is_real_feature',
				       );
    }
}



=head2 get_genome_features

  $features = $obj->get_genome_features($genomes, $type)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomes is a reference to a list where each element is a genome_id
$type is a string
$features is a reference to a hash where the key is a genome_id and the value is a reference to a list where each element is a feature_id
genome_id is a string
feature_id is a string

</pre>

=end html

=begin text

$genomes is a reference to a list where each element is a genome_id
$type is a string
$features is a reference to a hash where the key is a genome_id and the value is a reference to a list where each element is a feature_id
genome_id is a string
feature_id is a string


=end text

=item Description



=back

=cut

sub get_genome_features
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_genome_features (received $n, expecting 2)");
    }
    {
	my($genomes, $type) = @args;

	my @_bad_arguments;
        (ref($genomes) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"genomes\" (value was \"$genomes\")");
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 2 \"type\" (value was \"$type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_genome_features:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_genome_features');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.get_genome_features",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_genome_features',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_genome_features",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_genome_features',
				       );
    }
}



=head2 get_genomes

  $genomes = $obj->get_genomes()

=over 4

=item Parameter and return types

=begin html

<pre>
$genomes is a reference to a list where each element is a reference to a list containing 3 items:
	0: (genome_id) a genome_id
	1: (genome_name) a string
	2: (domain) a string
genome_id is a string

</pre>

=end html

=begin text

$genomes is a reference to a list where each element is a reference to a list containing 3 items:
	0: (genome_id) a genome_id
	1: (genome_name) a string
	2: (domain) a string
genome_id is a string


=end text

=item Description



=back

=cut

sub get_genomes
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_genomes (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "SEED.get_genomes",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_genomes',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_genomes",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_genomes',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "SEED.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'get_genomes',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method get_genomes",
            status_line => $self->{client}->status_line,
            method_name => 'get_genomes',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for SEEDClient\n";
    }
    if ($sMajor == 0) {
        warn "SEEDClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 feature_compare_info

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fid has a value which is a string
beg has a value which is an int
end has a value which is an int
size has a value which is an int
strand has a value which is a string
contig has a value which is a string
location has a value which is a string
function has a value which is a string
type has a value which is a string
set_number has a value which is an int
offset_beg has a value which is an int
offset_end has a value which is an int
offset has a value which is an int
attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
0: (key) a string
1: (value) a string


</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fid has a value which is a string
beg has a value which is an int
end has a value which is an int
size has a value which is an int
strand has a value which is a string
contig has a value which is a string
location has a value which is a string
function has a value which is a string
type has a value which is a string
set_number has a value which is an int
offset_beg has a value which is an int
offset_end has a value which is an int
offset has a value which is an int
attributes has a value which is a reference to a list where each element is a reference to a list containing 2 items:
0: (key) a string
1: (value) a string



=end text

=back



=head2 genome_compare_info

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
beg has a value which is an int
end has a value which is an int
mid has a value which is an int
org_name has a value which is a string
pinned_peg_strand has a value which is a string
genome_id has a value which is a string
pinned_peg has a value which is a string
features has a value which is a reference to a list where each element is a feature_compare_info

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
beg has a value which is an int
end has a value which is an int
mid has a value which is an int
org_name has a value which is a string
pinned_peg_strand has a value which is a string
genome_id has a value which is a string
pinned_peg has a value which is a string
features has a value which is a reference to a list where each element is a feature_compare_info


=end text

=back



=head2 compared_regions

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a genome_compare_info
</pre>

=end html

=begin text

a reference to a list where each element is a genome_compare_info

=end text

=back



=head2 compare_options

=over 4



=item Description

* How to sort the genomes.
* similarity - by similarity
* phylogenetic_distance - by phylogenetic distance to focus peg
* phylogeny - by phylogeny


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
pin has a value which is a reference to a list where each element is a string
n_genomes has a value which is an int
width has a value which is an int
pin_alignment has a value which is a string
pin_compute_method has a value which is a string
sim_cutoff has a value which is a float
limit_to_genomes has a value which is a reference to a list where each element is a string
close_genome_collapse has a value which is a string
coloring_method has a value which is a string
color_sim_cutoff has a value which is a float
genome_sort_method has a value which is a string
features_for_cdd has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
pin has a value which is a reference to a list where each element is a string
n_genomes has a value which is an int
width has a value which is an int
pin_alignment has a value which is a string
pin_compute_method has a value which is a string
sim_cutoff has a value which is a float
limit_to_genomes has a value which is a reference to a list where each element is a string
close_genome_collapse has a value which is a string
coloring_method has a value which is a string
color_sim_cutoff has a value which is a float
genome_sort_method has a value which is a string
features_for_cdd has a value which is a reference to a list where each element is a string


=end text

=back



=head2 genome_id

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 feature_id

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 assignment_result

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
success has a value which is an int
text has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
success has a value which is an int
text has a value which is a string


=end text

=back



=head2 location

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 translation

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=cut

package SEEDClient::RpcClient;
use base 'JSON::RPC::Legacy::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::Legacy::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::Legacy::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Legacy::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
