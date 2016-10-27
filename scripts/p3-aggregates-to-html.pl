#!/usr/bin/perl
use strict;

my $patric = "https://www.beta.patricbrc.org/";
my $hdg=1;
my $f1;
my $f2;
my $count;
my $genome;
my $html = "";

while (<>) {
    if ($_ =~ '////') {
        $hdg=1;
    } elsif ($_ =~ '//$') {
         next; 
    } elsif ($_ =~ '^###') {
        my ($hash, $genome) = split("\t", $_);
        #print  "<H3>$genome </H3>";
        print  "<table border=\"1\">\n";
        print "<th colspan=3><h3>$genome<h3></th>";
        print $html;
        print "</table><br><br><br>\n\n";
        $html="";
    }else {
        if ($hdg) {
              chomp($_);
              ($f1, $f2, $count) = split("\t",$_);
              print  "<H2> $f1 and $f2 <br>occur together $count times</H2>";
              print   "<H3>$genome </H3>";
              $hdg=0;
        } else {
            $html .=  "<tr>\n";
            chomp $_;
            my ($id, $fam, $func) = split("\t", $_);
            my $link = $patric."view/Feature/".$id;
            $html .=  "<td><A HREF=\"".$link."\" target=\_blank >".$id."</A></td>\n";
            my $color = "color:blue";
            if ($fam eq $f1 || $fam eq $f2) {$color="color:red";}
            my $famlink = $patric."view/FeatureList/?eq(plfam_id,$fam)#view_tab=features";
            $html .=  "<td><A HREF=\"".$famlink."\" target=\_blank style=\"$color\">".$fam."</A></td>\n";
            $html .=  "<td>$func</td>\n";
            $html .=  "</tr>\n";
        }
    }
}

