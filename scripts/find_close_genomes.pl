#!/usr/bin/env perl
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


use strict;
use warnings;
use ScriptUtils;
use KmerRepGenomes;
my $have_shrub;
eval {
    require Shrub;
    $have_shrub = 1;
};

=head1 Find Close Genomes Using Kmers

    find_close_genomes.pl [ options ] <fastaFile

This script uses a kmer database to find the genomes closest to the contigs in a FASTA file. The kmer database
must be built from the Shrub. This script eschews that option so that it will compile and run in a SEED
environment as well as SEEDtk.

=head2 Parameters

The standard input is a FASTA file containing the contigs to process. The standard input can be specified as a
command-line option using L<ScriptUtils/ih_options>. The other command-line options include those from
L<Shrub::script_options> (if in the SEEDtk environment) as well as the following.

=over 4

=item kmerFile

Name of a json file containing the kmer database. This is a required parameter. If the file does not exist, and we
are running in the SEEDtk environment, the kmer database will be built on the fly. If it does not exist and we are
running in the SEED environment, it is an error.

=item kmerSize

The size of a protein kmer. The default is C<10>. This option is only used in the SEEDtk environment and only if no kmer
database file exists.

=item minHits

The minimum number of hits for a genome to be considered relevant. The default is C<400>. This option is only used
in the SEEDtk environment and only if no database file exists.

=item maxFound

The maximum number of genomes in which a kmer can be found before it is considered common. Common kmers are removed from
the hash. This option is only used in the SEEDtk environment and only if no database file exists.

=item priv

The privilege level at which the roles of a protein should be assessed. The default is C<1>.

=item output

The name of an output file. This will be a tab-delimited file, each record containing (0) a genome ID, and (1) a
count of the number of kmer hits. If this parameter is omitted, the information will be written to the standard
output, but will be mixed with status messages.

=back

=cut

# Decide which options make sense here.
my @opts = (ScriptUtils::ih_options(),
                ['minhits=i',    'minimum number of kmer hits for a genome to be considered useful', { default => 400 }],
                ['output|o=s',   'genome output file']);
if ($have_shrub) {
    push @opts, ['maxfound=i',   'maximum number of kmer occurrences before it is considered common', { default => 10 }],
                ['kmersize|k=i', 'kmer size (protein)', { default => 10 }],
                ['priv=i',       'privilege level for role associations', { default => 1 }],
                ['kmerFile|f=s', 'kmer database file name', { default => "$FIG_Config::global/reps_kmer.json" }],
                Shrub::script_options();
} else {
    push @opts, ['kmerFile|f=s', 'kmer database file name', { required => 1 }],
}

# Get the command-line parameters.
my $opt = ScriptUtils::Opts('', @opts);
# This will point to the shrub database if we need it.
my $shrub;
# This will contain our options for the call to the kmer facility.
my %options = (minHits => $opt->minhits);
# This will contain the representative roles for the call to the kmer facility.
my @repRoles;
# Check the kmer database file.
my $kmerFile = $opt->kmerfile;
if (! -f $kmerFile) {
    # Here we need to build a kmer database.
    if (! $have_shrub) {
        die "Kmer database must be pre-built in the SEED environment.";
    } else {
        # Set up to build the database.
        $shrub = Shrub->new_for_script($opt);
        $options{kmerSize} = $opt->kmersize;
        $options{priv} = $opt->priv;
        $options{maxFound} = $opt->maxfound;
        # Get the representative roles.
        require FIG_Config;
        open(my $rh, "<$FIG_Config::global/rep_roles.tbl") || die "Could not open representative roles file.";
        @repRoles = map { $_ =~ /^(\S+)/; $1 } <$rh>;
    }
}
# Create the kmer processing object.
my $kmerThing = KmerRepGenomes->new($shrub, $kmerFile, \@repRoles, %options);
# Open the input file.
my $ih = ScriptUtils::IH($opt->input);
# Find the close genomes.
my $genomeH = $kmerThing->FindGenomes($ih);
# Open the output file.
my $oh;
if ($opt->output) {
    open($oh, '>', $opt->output) || die "Could not open output file: $!";
} else {
    $oh = \*STDOUT;
}
# Write out the genomes found.
print "Writing genomes found.\n\n";
my @genomes = sort { $genomeH->{$b}[0] <=> $genomeH->{$a}[0] } keys %$genomeH;
for my $genome (@genomes) {
    print $oh join("\t", $genome, @{$genomeH->{$genome}}) . "\n";
}
