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

=item sleep

The sleep interval in seconds while waiting for RAST to complete. The default is C<60>.

=back

=item RETURN

Returns an unblessed L<GenomeTypeObject> for the annotated genome.

=back

=cut

sub Annotate {
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
    # Get the options.
    my $user = $options{user};
    my $pass = $options{password};
    my $domain = $options{domain} // 'B';
    my $geneticCode = $options{geneticCode} // 11;
    my $sleepInterval = $options{sleep} || 60;
    # This will contain the return value.
    my $retVal;
    # Create the contig string.
    my $contigString = join("", map { ">$_->[0] $_->[1]\n$_->[2]\n" } @$contigs );
    # Fix up the name.
    unless ($name =~ /^\S+\s+\S+/) {
        $name = "Unknown sp. $name";
    }
    # Now we create an HTTP request to submit the job to RAST.
    my $url = URI->new(RAST_URL . '/submit/GenomeAnnotation');
    $url->query_form(
        scientific_name => $name,
        taxonomy_id => $taxonID,
        genetic_code => $geneticCode,
        domain => $domain
    );
    my $header = HTTP::Headers->new(Content_Type => 'text/plain');
    if (! $user || ! $pass) {
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
    my $userURI = "$user\@patricbrc.org";
    $header->authorization_basic($userURI, $pass);
    my $request = HTTP::Request->new(POST => "$url", $header, $contigString);
    # Submit the request.
    my $ua = LWP::UserAgent->new();
    my $response = $ua->request($request);
    if ($response->code ne 200) {
        die "Error response for RAST submisssion: " . $response->message;
    } else {
        # Get the job ID.
        my $jobID = $response->content;
        warn "Rast job ID is $jobID.\n";
        # Form a request for retreiving the job status.
        $url = join("/", RAST_URL, $jobID, 'status');
        $request = HTTP::Request->new(GET => $url, $header);
        # Begin spinning for a completion status.
        my $done;
        while (! $done) {
            sleep $sleepInterval;
            $response = $ua->request($request);
            if ($response->code ne 200) {
                die "Error response for RAST status: " . $response->message;
            } else {
                 my $status = $response->content;
                 if ($status eq 'completed') {
                     $done = 1;
                 } elsif ($status ne 'in-progress' && $status ne 'queued') {
                     die "Error status for RAST: $status.";
                 }
            }
        }
        # Get the results.
        $url = join("/", RAST_URL, $jobID, 'retrieve');
        $request = HTTP::Request->new(GET => $url, $header);
        $response = $ua->request($request);
        if ($response->code ne 200) {
            die "Error response for RAST retrieval: " . $response->message;
        }
        my $json = $response->content;
        $retVal = SeedUtils::read_encoded_object(\$json);
        # Add the RAST information to the GTO.
        $retVal->{rast_specs} = { id => $jobID, user => $user }
    }
    # Return the GTO built.
    return $retVal;
}

=head3 check

    my $completed = RASTlib::check($jobID, $user, $pass);

Return TRUE if the specified RAST job has completed, else FALSE. An error will be thrown if the job has failed.

=over 4

=item jobID

ID of the job to check.

=item user

The RAST user name.

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
         if ($status eq 'completed') {
             $retVal = 1;
         } elsif ($status ne 'in-progress' && $status ne 'queued') {
             die "Error status for RAST: $status.";
         }
    }
    # Return the status.
    return $retVal;
}

1;
