#!/usr/bin/env perl

=head1 GTO to GenBank Converter

This script converts a GTO file to an NCBI GENBANK file.  Both file names are specified on the command line
as positional parameters.

    p3x-gto-to-genbank genome1.gto genome1.gff

=cut

use strict;
use warnings;
no warnings 'uninitialized';
use Data::Dumper;
use File::Copy;
use SeedUtils;
use gjoseqlib;
use Date::Parse;
use POSIX;
use DB_File;

use JSON::XS;
use Digest::MD5 'md5_hex';

use GenomeTypeObject;
use URI::Escape;
use Bio::SeqIO;
use Bio::Seq;
use Bio::Seq::RichSeq;
use Bio::Species;
use Bio::Location::Split;
use Bio::Location::Simple;
use Bio::SeqFeature::Generic;
use Getopt::Long::Descriptive;
use File::Temp;

my $temp_dir;
my ($inFile, $outFile) = @ARGV;
my $genomeTO = GenomeTypeObject->create_from_file($inFile);
open(my $out_fh, '>', $outFile) || die "Could not open output: $!";
#
# For each protein, if the function is blank, make it hypothetical protein.
for my $f (@{$genomeTO->{features}})
{
    if (!defined($f->{function}) || $f->{function} eq '')
    {
        $f->{function} = "hypothetical protein";
    }
}


my $bio = {};
my $bio_list = [];

my $gs = $genomeTO->{scientific_name};
my $genome = $genomeTO->{id};

my $offset = 0;
my %contig_offset;

my $species;
my @tax = @{$genomeTO->{taxonomy}};
if (@tax)
{
    $species = Bio::Species->new(-classification => [reverse @tax]);
}
my $gc = $genomeTO->{genetic_code} || 11;

my $tax_id = $genomeTO->{ncbi_taxonomy_id};
if (!$tax_id)
{
    ($tax_id) = $genome =~ /^(\d+)\.\d+/;
}
my @taxon = defined($tax_id) ? (db_xref => "taxon:$tax_id") : ();

for my $c (@{$genomeTO->{contigs}})
{
    my $contig = $c->{id};
    $bio->{$contig} = Bio::Seq::RichSeq->new(-id => $contig,
                         -display_name => $gs,
                         -accession_number => $contig,
                         (defined($species) ? (-species => $species) : ()),
                         -seq => $c->{dna});
    $bio->{$contig}->desc($gs);
    push(@$bio_list, $bio->{$contig});

    # print "Set div for $bio->{$contig}\n";
    # $bio->{$contig}->division("PHG");

    my $contig_start = $offset + 1;
    my $contig_end   = $offset + length($c->{dna});

    $contig_offset{$contig} = $offset;

    my $feature = Bio::SeqFeature::Generic->new(-start => $contig_start,
                            -end => $contig_end,
                            -tag => {
                              @taxon,
                            organism => $gs,
                            mol_type => "genomic DNA",
                            note => $genome,
                            },
                            -primary => 'source');
    $bio->{$contig}->add_SeqFeature($feature);

    my $fa_record = Bio::SeqFeature::Generic->new(-start => $contig_start,
                              -end => $contig_end,
                              -tag => {
                              @taxon,
                              label => $contig,
                              note => $contig,
                              },
                              -primary => 'fasta_record');
    $bio->{$contig}->add_SeqFeature($fa_record);
}

my %protein_type = (CDS => 1, peg => 1);
my $strip_ec;
my $gff_export = [];

my @features;
for my $f (@{$genomeTO->{features}})
{
    my $peg = $f->{id};
    my $note = {};
    my $contig;

    my $func = "";
    if (defined($f->{function}) && $f->{function} ne '')
    {
        $func = $f->{function};
    }
    elsif ($protein_type{$f->{type}})
    {
        $func = "hypothetical protein";
    }

    push @{$note->{db_xref}}, "PATRIC:$peg";

    my %ecs;
    if ($func)
    {
        foreach my $role (SeedUtils::roles_of_function($func))
        {
            my ($ec) = ($role =~ /\(EC (\d+\.\d+\.\d+\.\d+)\)/);
            $ecs{$ec} = 1 if ($ec);
        }

        # add ECs
        push @{$note->{"EC_number"}}, keys(%ecs);
    }

    my($creation_event, $annotation_event, $annotation_tool) = $genomeTO->get_creation_info($f);

    $annotation_tool ||= $annotation_event->{tool_name};
    push(@{$note->{note}}, "rasttk_feature_creation_tool=$creation_event->{tool_name}") if $creation_event;
    push(@{$note->{note}}, "rasttk_feature_annotation_tool=$annotation_tool") if $annotation_tool;

    my $loc;

    my @loc_obj;
    my @loc_info;
    for my $l (@{$f->{location}})
    {
        my($ctg, $start, $strand, $len) = @$l;
        $contig = $ctg;
        my $offset = $contig_offset{$contig};
        my $end = $strand eq '+' ? ($start + $len - 1) : ($start - $len + 1);

        my $bstrand = 0;
        if ($protein_type{$f->{type}})
        {
            $bstrand = ($strand eq '+') ? 1 : -1;
        }

        $start += $offset;
        $end += $offset;

        ($start, $end) = ($end, $start) if $strand eq '-';

        my $sloc = new Bio::Location::Simple(-start => $start, -end => $end, -strand => $strand);
        push(@loc_obj, $sloc);

        #
        # Compute loc_info for GFF stuff.
        #
        my $frame = $start % 3;
        push(@loc_info, [$ctg, $start, $end, (($len == 0) ? "." : $strand), $frame]);
    }

    if (@loc_obj == 1)
    {
        $loc = $loc_obj[0];
    }
    elsif (@loc_obj > 1)
    {
        $loc = new Bio::Location::Split();
        $loc->add_sub_Location($_) foreach @loc_obj;
    }

    my $feature;
    my $source = "patric_export";
    my $type = $f->{type};

    # strip EC from function
    my $func_ok = $func;

    if ($strip_ec) {
        $func_ok =~ s/\s+\(EC \d+\.(\d+|-)\.(\d+|-)\.(\d+|-)\)//g;
        $func_ok =~ s/\s+\(TC \d+\.(\d+|-)\.(\d+|-)\.(\d+|-)\)//g;
    }

    if ($protein_type{$f->{type}})
    {
        $feature = Bio::SeqFeature::Generic->new(-location => $loc,
                             -primary  => 'CDS',
                             -tag      => {
                                 product     => $func_ok,
                                 translation => $f->{protein_translation},
                             },
                            );
        push @{$note->{transl_table}}, $gc;

        foreach my $tagtype (keys %$note) {
            $feature->add_tag_value($tagtype, @{$note->{$tagtype}});
        }

        # work around to get annotations into gff
        # this is probably still wrong for split locations.
        $func_ok =~ s/ #.+//;
        $func_ok =~ s/;/%3B/g;
        $func_ok =~ s/,/%2C/g;
        $func_ok =~ s/=//g;
        for my $l (@loc_info)
        {
            my $ec = "";
            my @ecs = ($func =~ /[\(\[]*EC[\s:]?(\d+\.[\d-]+\.[\d-]+\.[\d-]+)[\)\]]*/ig);
            if (scalar(@ecs)) {
            $ec = ";Ontology_term=".join(',', map { "KEGG_ENZYME:" . $_ } @ecs);
            }
            my($contig, $start, $stop, $strand, $frame) = @$l;
            push @$gff_export, "$contig\t$source\tCDS\t$start\t$stop\t.\t$strand\t$frame\tID=".$peg.";Name=".$func_ok.$ec."\n";
        }
    } elsif ($type eq "rna") {
    my $primary;
    if ( $func =~ /tRNA/ ) {
        $primary = 'tRNA';
    } elsif ( $func =~ /(Ribosomal RNA|5S RNA|rRNA)/ ) {
        $primary = 'rRNA';
    } else {
        $primary = 'misc_RNA';
    }

    $feature = Bio::SeqFeature::Generic->new(-location => $loc,
                         -primary  => $primary,
                         -tag      => {
                             product => $func,
                         },

                        );
    $func_ok =~ s/ #.+//;
    $func_ok =~ s/;/%3B/g;
    $func_ok =~ s/,/%2C/g;
    $func_ok =~ s/=//g;
    foreach my $tagtype (keys %$note) {
        $feature->add_tag_value($tagtype, @{$note->{$tagtype}});
    }
    # work around to get annotations into gff
    for my $l (@loc_info)
    {
        my($contig, $start, $stop, $strand, $frame) = @$l;
        push @$gff_export, "$contig\t$source\t$primary\t$start\t$stop\t.\t$strand\t.\tID=$peg;Name=$func_ok\n";
    }

    } elsif ($type eq "crispr_repeat" || $type eq 'repeat') {
    my $primary = "repeat_region";
    $feature = Bio::SeqFeature::Generic->new(-location => $loc,
                         -primary  => $primary,
                         -tag      => {
                             product => $func,
                         },

                        );
    $feature->add_tag_value("rpt_type",
                ($type eq 'crispr_repeat' ? "direct" : "other"));
    $func_ok =~ s/ #.+//;
    $func_ok =~ s/;/%3B/g;
    $func_ok =~ s/,/%2C/g;
    $func_ok =~ s/=//g;
    foreach my $tagtype (keys %$note) {
        $feature->add_tag_value($tagtype, @{$note->{$tagtype}});
    }
    # work around to get annotations into gff
    for my $l (@loc_info)
    {
        my($contig, $start, $stop, $strand, $frame) = @$l;
        push @$gff_export, "$contig\t$source\t$primary\t$start\t$stop\t.\t$strand\t.\tID=$peg;Name=$func_ok\n";
    }

    } else {
    my $primary = "misc_feature";
    $feature = Bio::SeqFeature::Generic->new(-location => $loc,
                         -primary  => $primary,
                         -tag      => {
                             product => $func,
                             note => $type,
                         },

                        );
    $func_ok =~ s/ #.+//;
    $func_ok =~ s/;/%3B/g;
    $func_ok =~ s/,/%2C/g;
    $func_ok =~ s/=//g;
    foreach my $tagtype (keys %$note) {
        $feature->add_tag_value($tagtype, @{$note->{$tagtype}});
    }
    # work around to get annotations into gff
    for my $l (@loc_info)
    {
        my($contig, $start, $stop, $strand, $frame) = @$l;
        push @$gff_export, "$contig\t$source\t$primary\t$start\t$stop\t.\t$strand\t.\tID=$peg;Name=$func_ok\n";
    }


    }

    my $bc = $bio->{$contig};
    if (ref($bc))
    {
        $bc->add_SeqFeature($feature) if $feature;
    }
    else
    {
        print STDERR "No contig found for $contig on $feature\n";
    }
    # hack for gtf via bioperl push(@features, $feature) if $feature;
}


#
# bioperl writes lowercase dna. We want uppercase for biophython happiness.
#
my $sio = Bio::SeqIO->new(-fh => $out_fh, -format => 'genbank');

foreach my $seq (@$bio_list)
{
    $sio->write_seq($seq);
}


#
