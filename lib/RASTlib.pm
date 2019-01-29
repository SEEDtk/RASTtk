#
# Copyright (c) 2003-2015 University of Chicago and Fellowship
# for Interpretations of Genomes. All Rights Reserved.
#
# This file is part of the SEED Toolkit.
#
# The SEED Toolkit is free software. You can redistribute
# it and/or modify it under the terms of the SEED Toolkit
# Public License.
#
# You should have received a copy of the SEED Toolkit Public License
# along with this program; if not write to the University of Chicago
# at info@ci.uchicago.edu or the Fellowship for Interpretation of
# Genomes at veronika@thefig.info or download a copy from
# http://www.theseed.org/LICENSE.TXT.
#
# This is a SAS Component
#


package RASTlib;

    use strict;
    use warnings;
    use LWP::UserAgent;
    use HTTP::Request;
    use SeedUtils;
    use URI;
    use P3DataAPI;
    use Crypt::RC4;

=head1 Annotate a Genome Using RAST

This package takes contig tuples as input and invokes the RAST service to produce an annotated
L<GenomeTypeObject>. The GTO produced is the true SEEDtk version.

=cut

# URL for RAST requests
use constant RAST_URL => 'https://p3.theseed.org/rast/quick';

=head2 Public Methods

=head3 Annotate

    my $gto = RASTlib::Annotate(\@contigs, $taxonID, $name, %options);

Annotate contigs using RAST.

=over 4

=item contigs

Reference to a list of 3-tuples containing the contigs. Each 3-tuple contains (0) a contig ID, (1) a comment,
and (2) the DNA sequence.

=item genomeID

The taxonomic ID for the genome.

=item name

The scientific name for the genome.

=item options

A hash containing zero or more of the following options.

=over 8

=item user

The RAST user name. If omitted, the C<RASTUSER> environment variable is interrogated.

=item password

The RAST password. If omitted, the C<RASTPASS> environment variable is interrogated.

=item domain

The domain for the genome (C<A>, C<B>, ...). The default is C<B>, for bacteria.

=item geneticCode

The genetic code for protein translation. The default is C<11>.

=item path

The name for the output folder in the user's workspace to contain the job.  If omitted, the default folder
C<QuickData> is used.  The path must be fully-formed, with a leading slash and the user name included.

=item sleep

The sleep interval in seconds while waiting for RAST to complete. The default is C<60>.

=back

=item RETURN

Returns an unblessed L<GenomeTypeObject> for the annotated genome.

=back

=cut

sub Annotate {
    my ($contigs, $taxonID, $name, %options) = @_;
    # Get the options.
    my $sleepInterval = $options{sleep} || 60;
    my $user = $options{user};
    # This will contain the return value.
    my $retVal;
    # Create the authorization header.
    my $header = auth_header($options{user}, $options{password});
    # Submit the job.
    my $jobID = Submit($contigs, $taxonID, $name, %options, header => $header);
    warn "Rast job ID is $jobID.\n";
    # Begin spinning for a completion status.
    while (! check($jobID, $header)) {
        sleep $sleepInterval;
    }
    # Get the results.
    $retVal = retrieve($jobID, $header);
    # Return the GTO built.
    return $retVal;
}

=head3 Submit

    my $jobID = RASTlib::Submit(\@contigs, $taxonID, $name, %options);

Submit an annotation to RAST and return the job ID.

=over 4

=item contigs

Reference to a list of 3-tuples containing the contigs. Each 3-tuple contains (0) a contig ID, (1) a comment,
and (2) the DNA sequence.

=item genomeID

The taxonomic ID for the genome.

=item name

The scientific name for the genome.

=item options

A hash containing zero or more of the following options.

=over 8

=item user

The RAST user name.  If omitted, a stored value is found in a configuration file.

=item password

The RAST password.  If omitted, a stored value is found in a configuration file.

=item domain

The domain for the genome (C<A>, C<B>, ...). The default is C<B>, for bacteria.

=item geneticCode

The genetic code for protein translation. The default is C<11>.

=item path

The name for the output folder in the user's workspace to contain the job.  If omitted, the default folder
C<QuickData> is used.  The path must be fully-formed, with a leading slash and the user name included.

=item header

If specified, an authorization header containing the user's credentials.  In this case, the B<user> and
B<password> options are ignored.

=back

=item RETURN

Returns an unblessed L<GenomeTypeObject> for the annotated genome.

=back

=cut

sub Submit {
    my ($contigs, $taxonID, $name, %options) = @_;
    if (! $taxonID) {
        die "Missing taxon ID for RAST annotation.";
    } elsif ($taxonID =~ /^(\d+)\.\d+$/) {
        $taxonID = $1;
    } elsif ($taxonID !~ /^\d+$/) {
        die "Invalid taxon ID $taxonID for RAST annotation.";
    }
    if (! $name) {
        die "No genome name specified for RAST annotation.";
    }
    # This will be the return value.
    my $retVal;
    # Get the options.
    my $user = $options{user};
    my $pass = $options{password};
    my $domain = $options{domain} // 'B';
    my $geneticCode = $options{geneticCode} // 11;
    my $path = $options{path};
    # Create the contig string.
    my $contigString = join("", map { ">$_->[0] $_->[1]\n$_->[2]\n" } @$contigs );
    # Fix up the name.
    unless ($name =~ /^\S+\s+\S+/) {
        $name = "Unknown sp. $name";
    }
    # Now we create an HTTP request to submit the job to RAST.
    my %parms = (scientific_name => $name,
        taxonomy_id => $taxonID,
        genetic_code => $geneticCode,
        domain => $domain,
    );
    if ($path) {
        $parms{path} = $path;
    }
    my $url = URI->new(RAST_URL . '/submit/GenomeAnnotation');
    $url->query_form(%parms);
    # Create the authorization header.
    my $header = $options{header} // auth_header($user, $pass);
    # Submit the request.
    my $request = HTTP::Request->new(POST => "$url", $header, $contigString);
    my $ua = LWP::UserAgent->new();
    my $response = $ua->request($request);
    if ($response->code ne 200) {
        die "Error response for RAST submisssion: " . $response->message;
    } else {
        # Get the job ID.
        $retVal = $response->content;
    }
    # Return the job ID.
    return $retVal;
}


=head3 check

    my $completed = RASTlib::check($jobID, $user, $pass);

Return TRUE if the specified RAST job has completed, else FALSE. An error will be thrown if the job has failed.

=over 4

=item jobID

ID of the job to check.

=item user

The RAST user name, or alternatively, a pre-computed authorization header from L</auth_header>.

=item password

The RAST password.

=item RETURN

Returns TRUE if the job has completed, else FALSE.

=back

=cut

sub check {
    my ($jobID, $user, $pass) = @_;
    # This will be the return value.
    my $retVal = 0;
    # Check for an authorization header.
    my $header = $user;
    if (ref $header ne 'HTTP::Headers') {
        $header = HTTP::Headers->new(Content_Type => 'text/plain');
        my $userURI = "$user\@patricbrc.org";
        $header->authorization_basic($userURI, $pass);
    }
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
         if ($status eq 'completed') {
             $retVal = 1;
         } elsif ($status ne 'in-progress' && $status ne 'queued') {
             die "Error status for RAST: $status.";
         }
    }
    # Return the status.
    return $retVal;
}


=head3 retrieve

    my $gto = RASTlib::retrieve($jobID, $header);

Extract the GTO for an annotated genome from the RAST interface.

=over 4

=item jobID

The ID of the job that annotated the genome.

=item header

The authorization header returned by L</auth_header>.

=item RETURN

Returns an unblessed L<GenomeTypeObject> for the annotated genome.

=back

=cut

sub retrieve {
    my ($jobID, $header) = @_;
    # Ask for the GTO from PATRIC.
    my $ua = LWP::UserAgent->new();
    my $url = join("/", RAST_URL, $jobID, 'retrieve');
    my $request = HTTP::Request->new(GET => $url, $header);
    my $response = $ua->request($request);
    if ($response->code ne 200) {
        die "Error response for RAST retrieval: " . $response->message;
    }
    my $json = $response->content;
    my $retVal = SeedUtils::read_encoded_object(\$json);
    # Add the RAST information to the GTO.
    my ($userH) = $header->authorization_basic();
    if ($userH =~ /^(.+)\@patricbrc.org/) {
        $userH = $1;
    }
    $retVal->{rast_specs} = { id => $jobID, user => $userH };
    # Return it.
    return $retVal;
}


=head3 auth_header

    my $header = auth_header($user, $pass);

Create an authorization header for HTTP requests from the specified user ID and password.

=over 4

=item user

The RAST user name.  If omitted, a stored value is found in a configuration file.

=item password

The RAST password.  If omitted, a stored value is found in a configuration file.

=item RETURN

Returns an L<HTTP::Headers> object with the authorization credentials built in.

=back

=cut

sub auth_header {
    my ($user, $pass) = @_;
    my $retVal = HTTP::Headers->new(Content_Type => 'text/plain');
    if (! $user || ! $pass) {
        # If the user ID and password were not passed in, use the stored information.
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
        $pass = $ref->RC4($encrypted);
    }
    # Create the header.
    my $userURI = "$user\@patricbrc.org";
    $retVal->authorization_basic($userURI, $pass);
    # Return the header.
    return $retVal;
}

1;
