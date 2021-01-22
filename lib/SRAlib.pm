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
    use SeedTkRun;
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

=head3 get_meta

    my $metaH = $sraLib->get_meta($srs_id);

Extract the the source metadata hash for a specified sample.

=over 4

=item id

The SRS ID for the sample (e.g. C<SRS015383>).

=item RETURN

Returns a reference to a hash containing the key and value for each metadata item attached to this sample.

=back

=cut

sub get_meta {
    my ($self, $id) = @_;
    # This will be the return value.
    my %retVal;
    # Normalize the ID to upper case.
    $id = uc $id;
    # Retrieve the web page for this sample.
    $self->_log("Fetching metadata for $id.\n");
    my $url = "https://www.ncbi.nlm.nih.gov/biosample/?term=($id)%20AND%20biosample_sra[filter]&report=full&format=text";
    my $response = $self->{ua}->get($url);
    if (! $response->is_success) {
        $self->_log_error($response);
    } else {
        # Here we have a valid web page to scrape.
        my $content = $response->decoded_content;
        my @lines = split /\n/, $content;
        for my $line (@lines) {
            if ($line =~ /\/([^=]+)="([^"]+)"/) {
                $retVal{$1} = $2;
            } elsif ($line =~ /^Organism:\s+(.+)/) {
                $retVal{Organism} = $1;
            }
        }
    }
    # Return the results.
    return \%retVal;
}

=head3 compute_site

    my ($project, $site) = $sraLib->compute_site($id);

Compute the project and site for a sample based on its meta-data.

=over 4

=item id

The SRS ID for the sample.

=item RETURN

Returns a list containing (0) the project code (usually C<NCBI>, but sometimes C<HMP>) and (1) the site name.

=back

=cut

sub compute_site {
    my ($self, $id) = @_;
    # Get the stats.
    my $stats = $self->{stats};
    # These will be the return values.
    my ($project, $site) = ('NCBI', 'unknown');
    # Get the metadata hash.
    my $metaH = $self->get_meta($id);
    # Get the most important elements.
    my $source = $metaH->{'isolation source'} // '';
    my $organism = $metaH->{Organism} // '';
    my $study = $metaH->{'study name'} // '';
    # Parse the metadata.
    if ($study =~ /^HMP\s/) {
        $project = 'HMP';
        if ($source =~ /^G_DNA_(.+)/) {
            $site = lc $1;
            $site =~ tr/ /_/;
        } else {
            $stats->Add('HMP-unknown' => 1);
        }
    } elsif ($organism =~ /^(human|gut|oral)\s+metagenome/) {
        my $type = $1;
        if ($source && $source ne 'missing') {
            $site = lc $source;
            $site =~ tr/ /_/;
        } elsif ($type eq 'gut') {
            $site = 'stool';
        } elsif ($type eq' oral') {
            $site = 'saliva';
        } else {
            $stats->Add('NCBI-missing' => 1);
        }
    } elsif ($organism eq 'human gut metagenome') {
        $site = 'stool';
    } elsif ($organism eq 'human skin metagenome') {
        $site = 'human_skin';
    } elsif ($organism =~ /^human (\S+) metagenome$/) {
        $site = $1;
    } elsif ($organism eq 'hot springs metagenome') {
        $site = 'hot_springs';
    } elsif ($organism =~ /sediment metagenome/) {
        $site = 'soil';
    } elsif ($organism =~ /^(\S+)\s+metagenome/) {
        $site = lc $1;
    } else {
        $stats->Add('NCBI-unknown' => 1);
        $project = 'N/A';
    }
    return ($project, $site);
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
    # This will be count the good lines and the bad lines.
    my $error = 0;
    my $good = 0;
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
    # Count singletons here.
    my $singles = 0;
    # Find the FASTQ-DUMP command.
    my $cmdPath = SeedTkRun::executable_for('fastq-dump');
    # Create the FASTQ output files.  Note the singleton file is not allowed in gzip mode.
    my ($lh, $rh, $sh);
    my ($lfile, $rfile, $sfile) = ("$outDir/${name}_1.fastq", "$outDir/${name}_2.fastq", "$outDir/${name}_s.fastq");
    if ($self->{gzip}) {
        $lh = new IO::Compress::Gzip("$lfile.gz");
        $rh = new IO::Compress::Gzip("$rfile.gz");
    } else {
        open($lh, '>', $lfile) || die "Could not open left FASTQ for $name: $!";
        open($rh, '>', $rfile) || die "Could not open right FASTQ for $name: $!";
        open($sh, '>', $sfile) || die "Could not open singleton FASTQ for $name: $!";
    }
    # Loop through the runs.
    for my $run (@$runList) {
        $self->_log("Processing $run.\n");
        # Create a FastQ object to read the run from NCBI.
        open(my $ih, "$cmdPath --readids --stdout --split-spot --skip-technical --clip --read-filter pass $run |") || die "Could not start fastq dunmp for $run: $!";
        $stats->Add(runFiles => 1);
        my $lCount = 0;
        my $line = <$ih>;
        while (defined $line) {
            $stats->Add(runLineIn => 1);
            # Check for the left read.
            if ($line =~ /^\@(\S+)\.1\s/) {
                # Found it. Save the data and the quality for the left file.
                my $id = $1;
                my @left = ($line);
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
                        $error++;
                        $stats->Add(rightMismatch => 1);
                        $singles += $self->_write_singleton($sh, \@left);
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
                        $self->_log("$lCount spots output.\n") if $lCount % 50000 == 0;
                        # Get the next left read.
                        $line = <$ih>;
                    }
                } else {
                    # No valid right read.
                    $stats->Add(noRightRead => 1);
                    $singles += $self->_write_singleton($sh, \@left);
                    $error++;
                }
            } else {
                # No valid left read.
                $stats->Add(noLeftRead => 1);
                $error++;
            }
            # Find the next left read.
            my @skip;
            while (defined $line && $line !~ /^\@\S+\.1\s/) {
                push @skip, $line;
                $line = <$ih>;
            }
            if (scalar @skip) {
                $singles += $self->_write_singleton($sh, \@skip);
            }
        }
        $good += $lCount;
    }
    my $retVal = 1;
    # Clean up the files.
    close $lh; close $rh;
    close $sh if $sh;
    if ($error > $good && $created) {
        # Here we must remove the created directory.
        $self->_log("Too many errors: cleaning up $outDir.\n");
        File::Copy::Recursive::pathempty($outDir);
        rmdir $outDir;
        $retVal = 0;
    } elsif (-z $sfile) {
        # Here we must delete an empty singleton file.
        unlink $sfile || die "Could not delete singleton file $sfile: $!";
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

=head3 _write_singleton

    my $count = $sraLib->_write_singleton($sh, \@lines);

Write one or more records to the singleton FASTQ file.  If the file handle does not exist, the singletons are discarded.

=over 4

=item sh

An open output file handle, or C<undef> to ignore the singletons.

=item lines

Reference to a list of the lines to write.

=item RETURN

Returns the number of records written.

=back

=cut

sub _write_singleton {
    my ($self, $sh, $lines) = @_;
    # Get the stats object.
    my $stats = $self->{stats};
    # This will be the return value.
    my $retVal = 0;
    # Pop off the records one at a time.
    my $n = scalar @$lines;
    for (my $i = 0; $i < $n; $i += 4) {
         my $header = $lines->[$i];
         if ($i + 3 >= $n) {
             # Partial record.
             $stats->Add(partialDiscarded => 1);
         } elsif ($sh && $header =~ /^\@/) {
             # Here we can write the singleton.
             $retVal++;
             $stats->Add(singletonOut => 1);
             print $sh $header;
             print $sh $lines->[$i+1];
             print $sh $lines->[$i+2];
             print $sh $lines->[$i+3];
         } else {
             $stats->Add(recordSkipped => 1);
         }
    }
    # Return the number of records written.
    return $retVal;
}

1;
