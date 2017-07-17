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
use ServicesUtils;
use gjoseqlib;
use BlastInterface;
use Data::Dumper;
use P3DataAPI;

=head1 Blast FASTA Data

    p3-blast.pl [ options ] type blastdb

Blast the input against a specified blast database. The input should be a FASTA file. The blast database
can also be a FASTA file, the input itself, or it can be a genome ID.

=head2 Parameters

See L<ServicesUtils> for more information about common command-line options.

The positional parameters are the name of the blast program (C<blastn>, C<blastp>, C<blastx>, or C<tblastn>)
followed by the file name of the blast database. If the blast database is not pre-built, it will be built in
place. If the database is not found, it is presumed to be a genome ID. If the database name is omitted, the
input will be blasted against itself.

The additional command-line options are as follows.

=over 4

=item hsp

If specified, then the output is in the form of HSP data (see L<Hsp>). This is the default, and is mutually exclusive with C<sim>.

=item sim

If specified, then the output is in the form of similarity data (see L<Sim>). This parameter is mutually exclusive with C<hsp>.

=item BLAST Parameters

The following may be specified as BLAST parameters

=over 8

=item maxE

Maximum E-value (default C<1e-10>).

=item maxHSP

Maximum number of returned results (before filtering). The default is to return all results.

=item minScr

Minimum required bit-score. The default is no minimum.

=item percIdentity

Minimum percent identity. The default is no minimum.

=item minLen

Minimum permissible match length (used to filter the results). The default is no filtering.

=back

=back

=cut

# map each blast tool name to the type of blast database required
use constant BLAST_TOOL => { blastp => 'prot', blastn => 'dna', blastx => 'prot', tblastn => 'dna' };

# Get the command-line parameters.
my ($opt, $helper) = ServicesUtils::get_options('type blastdb',
        ['output' => hidden => { one_of => [ [ 'hsp' => 'produce HSP output'], ['sim' => 'produce similarity output'] ]}],
        ['maxE|e=f', 'maximum e-value', { default => 1e-10 }],
        ['maxHSP|b', 'if specified, the maximum number of returned results (before filtering)'],
        ['minScr=f', 'if specified, the minimum permissible bit score'],
        ['percIdentity=f', 'if specified, the minimum permissible percent identity'],
        ['minLen|l=i', 'if specified, the minimum permissible match lengt (for filtering)'],
        { input => 'whole' });
# Open the input file.
my $ih = ServicesUtils::ih($opt);
# Get the positional parameters.
my ($blastProg, $blastdb) = @ARGV;
if (! $blastProg) {
    die "You must specify the blast tool.";
}
my $blastDbType = BLAST_TOOL->{$blastProg};
if (! $blastDbType) {
    die "Invalid blast tool specified.";
}
# This hash contains the BLAST parameters.
my %blast;
$blast{outForm} = $opt->output // 'hsp';
$blast{maxE} = $opt->maxe;
$blast{maxHSP} = $opt->maxhsp // 0;
$blast{minIden} = $opt->percidentity // 0;
$blast{minLen} = $opt->minlen // 0;
# Get the input triples. These are the query sequences.
my @query = gjoseqlib::read_fasta($ih);
# Now we need to determine the BLAST database.
my $blastDatabase;
if (! $blastdb) {
    # Use the query.
    $blastDatabase = \@query;
} elsif (-s $blastdb) {
    # Here the user specified a file name.
    $blastDatabase = $blastdb;
} else {
    # Not a file name, so we assume it is a genome.
    #my $gHash = $helper->genome_fasta([$blastdb], $blastDbType);
    p3_genome_fasta($blastdb, $blastDbType);
    $blastDatabase = $blastdb;
    if (! $blastDatabase) {
        die "$blastdb is not a file or a genome ID."
    }
}
# Now run the BLAST.
my $matches = BlastInterface::blast(\@query, $blastDatabase, $blastProg, \%blast);
# Format the output.
for my $match (@$matches) {
    print join("\t", @$match) . "\n";
}


sub p3_genome_fasta
{
    my ($genome_id, $blastDbType) = @_;
    my $d = P3DataAPI->new();

    my $gto = $d->gto_of($genome_id);
    if ($blastDbType eq "dna") {
        $gto->write_contigs_to_file("$genome_id");
      } else {
            $gto->write_protein_translations_to_file("$genome_id");
    }
}


