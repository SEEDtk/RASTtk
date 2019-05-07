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


package SRAlib;

    use strict;
    use warnings;
    use LWP::UserAgent;
    use HTTP::Response;
    use Stats;
    use File::Copy::Recursive;
    use FastQ;
    use SeedAware;
    use IO::Compress::Gzip;

=head1 Library for Downloading SRA Entries

This package contains methods for downloading SRA samples. The SRA sample is formatted into two FASTQ files suitable for submission to the PATRIC
metagenome service. A single object can be used to download multiple successive samples.

This object present a synchronous interface: that is, you ask for a download and it will not return until the download is complete; however, if
L<File::Download> is installed, progress messages will be displayed on a specified log file handle.

The fields in this object are as follows.

=over 4

=item userAgent

An L<LWP::UserAgent> for communicating with the web.

=item logH

An open file handle for status messages. If C<undef>, then no status messages are displayed.

=item stats

A L<Stats> object for run statistics.

=item gzip

If TRUE, then the output files should be in gzip format.

=back

=head2 Special Methods

=head3 new

    my $sraLib = SRAlib->new(%options);

Create a new SRA download object.

=over 4

=item options

A hash containing zero or more of the following options.

=over 8

=item ua

An L<LWP::UserAgent> to use for web communication. If omitted, an internal object will be created.

=item logH

An open file handle for status message output. If omitted, no status messages are written.

=item stats

A L<Stats> object to use for run statistics. If omitted, statistics are generated internally.

=item gzip

If TRUE, then the output files should be in gzip format.

=back

=back

=cut

sub new {
    my ($class, %options) = @_;
    # Get the user agent.
    my $ua = $options{ua} // LWP::UserAgent->new();
    # Get the other options.
    my $stats = $options{stats} // Stats->new();
    my $log = $options{logH};
    my $gzip = $options{gzip} // 0;
    # Create the object.
    my $retVal = {
        ua => $ua,
        logH => $log,
        stats => $stats,
        gzip => $gzip
    };
    # Bless and return it.
    bless $retVal, $class;
    return $retVal;
}


=head2 Public Manipulation Methods

=head3 get_runs

    my $runList = $sraLib->get_runs($id);

Get the list of runs for a specified sample.

=over 4

=item id

The SRS ID for the sample (e.g. C<SRS015383>) or an individual run (e.g. C<SRR2657613>).

=item RETURN

Returns reference to a list of the run IDs, or C<undef> if no runs were found.

=back

=cut

sub get_runs {
    my ($self, $id) = @_;
    # Get the stats object.
    my $stats = $self->{stats};
    # This will be the return value.
    my $retVal;
    $stats->Add(runRequests => 1);
    # Is this a run ID?
    $id = uc $id;
    if ($id =~ /^[SDE]RR/) {
        # Yes, return it as a list.
        $retVal = [$id];
    } else {
        # Retrieve the web page for this sample.
        $self->_log("Fetching runs for $id.\n");
        my $url = "http://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?save=efetch&db=sra&rettype=runinfo&term=$id";
        my $response = $self->{ua}->get($url);
        if (! $response->is_success) {
            $self->_log_error($response);
            $stats->Add(runRequestErrors => 1);
        } else {
            # Here we have a valid web page to scrape.
            my $content = $response->decoded_content;
            $stats->Add(runRequestPages => 1);
            $retVal = [];
            my @lines = split /\n/, $content;
            for my $line (@lines) {
                if ($line =~ /^(.RR\d+),/) {
                    push @$retVal, $1;
                    $stats->Add(runFound => 1);
                }
            }
            if (! scalar @$retVal) {
                # Chances are this is an invalid SRS ID, so it's an error.
                $self->_log("No runs found for $id.\n");
                undef $retVal;
            } else {
                $self->_log(scalar(@$retVal) . " runs found for $id.\n");
            }
        }
    }
    # Return the results.
    return $retVal;
}

=head3 get_stats

    my ($spots, $bases) = $sraLib->get_stats($srs_id);

Extract the the number of spots and base pairs for a specified sample.

=over 4

=item id

The SRS ID for the sample (e.g. C<SRS015383>).

=item RETURN

Returns a list containing the number of spots and the number of base pairs. Note that not all the spots may be usable, but this is a good
rule of thumb.

=back

=cut

sub get_stats {
    my ($self, $id) = @_;
    # This will be the return value.
    my ($spots, $bases) = (0, 0);
    # Normalize the ID to upper case.
    $id = uc $id;
    # Retrieve the web page for this sample.
    $self->_log("Fetching run data for $id.\n");
    my $url = "http://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?save=efetch&db=sra&rettype=runinfo&term=$id";
    my $response = $self->{ua}->get($url);
    if (! $response->is_success) {
        $self->_log_error($response);
    } else {
        # Here we have a valid web page to scrape.
        my $content = $response->decoded_content;
        my @lines = split /\n/, $content;
        for my $line (@lines) {
            my ($run, undef, undef, $spot0, $base0) = split /,/, $line;
            if ($run && $run =~ /^.RR/) {
                $spots += $spot0;
                $bases += $base0;
            }
        }
    }
    # Return the results.
    return ($spots, $bases);
}


=head3 download_runs

    my $okFlag = $sraLib->download_runs(\@runList, $outDir, $name);

This method downloads the runs in a run list to a specified directory. The output files will be given the indicated name, with a suffix of C<_1.fastq> for the
left reads and C<_2.fastq> for the right reads. This is a very long process, so without a log the application will appear to hang for up to an hour.
All of the runs will be concatenated into a single file.

=over 4

=item runList

Reference to a list of run IDs.

=item outDir

The output directory into which the intermediate work files and FASTQ output files will be placed.

=item name

The name to give the FASTQ output files.

=item RETURN

Returns TRUE if successful, else FALSE.

=back

=cut

sub download_runs {
    my ($self, $runList, $outDir, $name) = @_;
    # Get the statistics object.
    my $stats = $self->{stats};
    # This will be set to TRUE if we need to abort.
    my $error = 0;
    # This will be set to TRUE if we create a directory.
    my $created = 0;
    # Insure we have an output directory.
    if (! $outDir) {
        die "No output directory specified for run download.";
    } elsif (! -d $outDir) {
        $self->_log("Creating run output directory $outDir.\n");
        File::Copy::Recursive::pathmk($outDir);
        $created = 1;
    }
    # Find the FASTQ-DUMP command.
    my $cmdPath = SeedAware::executable_for('fastq-dump');
    # Create the FASTQ output files.
    my ($lh, $rh);
    my ($lfile, $rfile) = ("$outDir/${name}_1.fastq", "$outDir/${name}_2.fastq");
    if ($self->{gzip}) {
        $lh = new IO::Compress::Gzip("$lfile.gz");
        $rh = new IO::Compress::Gzip("$rfile.gz");
    } else {
        open($lh, '>', $lfile) || die "Could not open left FASTQ for $name: $!";
        open($rh, '>', $rfile) || die "Could not open right FASTQ for $name: $!";
    }
    # Loop through the runs.
    for my $run (@$runList) {
        $self->_log("Processing $run.\n");
        # Create a FastQ object to read the run from NCBI.
        open(my $ih, "$cmdPath --readids --stdout --split-spot --skip-technical --clip --read-filter pass $run |") || die "Could not start fastq dunmp for $run: $!";
        $stats->Add(runFiles => 1);
        my $lCount = 0;
        my @left;
        my $line = <$ih>;
        while (defined $line) {
            # Check for the left read.
            if ($line =~ /^\@(\S+)\.1\s/) {
                # Found it. Save the data and the quality for the left file.
                my $id = $1;
                push @left, $line;
                for my $idx (1,2,3) {
                    $line = <$ih>;
                    push @left, $line;
                }
                # Check for the right read.
                $line = <$ih>;
                if ($line && $line =~ /^\@(\S+)\.2\s/) {
                    my $idR = $1;
                    if ($idR ne $id) {
                        # Mismatched reads.
                        $self->_log("Bad run: right read does not match left read $id.\n");
                        $error++;
                    } else {
                        # Echo to the right file.
                        print $rh $line;
                        for my $idx (1,2,3) {
                            $line = <$ih>;
                            print $rh $line;
                        }
                        # Print to the left file.
                        while ($line = shift @left) {
                            print $lh $line;
                        }
                        $lCount++;
                        $self->_log("$lCount spots output.\n") if $lCount % 10000 == 0;
                    }
                } else {
                    # No valid right read.
                    $self->_log("Bad run: no right read following left read $id.\n");
                    $error++;
                }
            } else {
                # No valid left read.
                $self->_log("Bad run: left read not found when expected.\n");
                $error++;
            }
            while (defined $line && $line !~ /^\@\S+\.1\s/) {
                # Find the next left read.
                $line = <$ih>;
            }
        }
    }
    my $retVal = 1;
    # Clean up the files.
    close $lh; close $rh;
    if ($error > 10000 && $created) {
        # Here we must remove the created directory.
        $self->_log("Too many errors: cleaning up $outDir.\n");
        File::Copy::Recursive::pathempty($outDir);
        rmdir $outDir;
        $retVal = 0;
    }
    # Return the success flag.
    return $retVal;
}

=head2 Internal Methods

=head3 _log_error

    $sraLib->_log_error($response);

Process an error response from the web. A hopefully informative message will be written to the log.

=over 4

=item response

An L<Http::Response> object from a failed web request.

=back

=cut

sub _log_error {
    my ($self, $response) = @_;
    my $message = $response->code . ": " . $response->message . "\n";
    $self->_log($message);
}

=head3 _log

    $sraLib->_log($message);

Write the message to the log. If there is no log file, nothing will happen.

=over 4

=item message

The message to write.

=back

=cut

sub _log {
    my ($self, $message) = @_;
    my $lh = $self->{logH};
    if ($lh) {
        print $lh $message;
    }
}

1;