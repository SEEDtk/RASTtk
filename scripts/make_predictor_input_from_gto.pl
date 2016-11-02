use strict; 
use Data::Dumper;
use GenomeTypeObject;
use SeedUtils;

my %role_to_role_id = map { ($_ =~ /^(\S+)\t(\S.*\S)/) ? ($2 => $1) : () } <DATA>;
my $gto = GenomeTypeObject->new({ file => \*STDIN });
my $features = $gto->features;
my %counts;
foreach my $feature (@$features)
{
    my $function = $feature->{function};
    my @roles    = &SeedUtils::roles_of_function($function);
    foreach my $role (@roles)
    {
	my $role_id = $role_to_role_id{$role};
        if ($role_id)
	{
	    $counts{$role_id}++;
	}
    }
}

foreach my $role_id (sort keys(%counts))
{
    print $role_id,"\t",$counts{$role_id},"\n";
}

__DATA__
10KdaCultFiltAnti	10 kDa culture filtrate antigen CFP-10 (EsxB)
12Dihy3Keto5Meth	1,2-dihydroxy-3-keto-5-methylthiopentene dioxygenase (EC 1.13.11.54)
12EpoxCoaIsom	1,2-epoxyphenylacetyl-CoA isomerase (EC 5.3.3.18)
12PhenCoaEpoxSubu	1,2-phenylacetyl-CoA epoxidase, subunit A (EC 1.14.13.149)
12PhenCoaEpoxSubu2	1,2-phenylacetyl-CoA epoxidase, subunit B (EC 1.14.13.149)
12PhenCoaEpoxSubu3	1,2-phenylacetyl-CoA epoxidase, subunit C (EC 1.14.13.149)
12PhenCoaEpoxSubu4	1,2-phenylacetyl-CoA epoxidase, subunit D (EC 1.14.13.149)
12PhenCoaEpoxSubu5	1,2-phenylacetyl-CoA epoxidase, subunit E (EC 1.14.13.149)
13PropDehy	1,3-propanediol dehydrogenase (EC 1.1.1.202)
14AlphGlucBranEnzy	1,4-alpha-glucan (glycogen) branching enzyme, GH-13-type (EC 2.4.1.18)
14Dihy2NaphCoaHydr	1,4-dihydroxy-2-naphthoyl-CoA hydrolase in menaquinone biosynthesis (EC 3.1.2.28)
14Dihy2NaphCoaHydr3	1,4-dihydroxy-2-naphthoyl-CoA hydrolase in phylloquinone biosynthesis (EC 3.1.2.28)
14Dihy2NaphPoly	1,4-dihydroxy-2-naphthoate polyprenyltransferase (EC 2.5.1.74)
14Dihy6NaphSynt	1,4-dihydroxy-6-naphtoate synthase
14Dihy6NaphSyntLike	1,4-dihydroxy-6-naphtoate synthase-like protein SSO2229
14Lact	1,4-lactonase (EC 3.1.1.25)
16sRrna2OMeth	16S rRNA (cytidine(1409)-2'-O)-methyltransferase (EC 2.1.1.227)
16sRrna2OMeth2	16S rRNA (cytidine(1402)-2'-O)-methyltransferase (EC 2.1.1.198)
16sRrnaCMeth	16S rRNA (cytosine(967)-C(5))-methyltransferase (EC 2.1.1.176)
16sRrnaNMeth	16S rRNA (guanine(966)-N(2))-methyltransferase (EC 2.1.1.171)
16sRrnaNMeth2	16S rRNA (uracil(1498)-N(3))-methyltransferase (EC 2.1.1.193)
16sRrnaNMeth3	16S rRNA (guanine(527)-N(7))-methyltransferase (EC 2.1.1.170)
16sRrnaNMethEc21n1	16S rRNA (cytosine(1402)-N(4))-methyltransferase EC 2.1.1.199)
16sRrnaNMethSsuRrna	16S rRNA (guanine(966)-N(2))-methyltransferase ## SSU rRNA m(2)G966 (EC 2.1.1.171)
16sRrnaProcProtRimm	16S rRNA processing protein RimM
1Deox11BetaHydrDehy	1-deoxy-11-beta-hydroxypentalenate dehydrogenase (EC 1.1.1.340)
1DeoxAcid11BetaHydr	1-deoxypentalenic acid 11-beta-hydroxylase (EC 1.14.11.35)
1DeoxDXylu5PhosRedu	1-deoxy-D-xylulose 5-phosphate reductoisomerase (EC 1.1.1.267)
1DeoxDXylu5PhosSynt	1-deoxy-D-xylulose 5-phosphate synthase (EC 2.2.1.7)
1Hydr2Meth2Bute4n1	1-hydroxy-2-methyl-2-(E)-butenyl 4-diphosphate synthase (EC 1.17.7.1)
1PhenDehy	(S)-1-phenylethanol dehydrogenase (EC 1.1.1.311)
1Pyrr4Hydr2CarbDeam	1-pyrroline-4-hydroxy-2-carboxylate deaminase (EC 3.5.4.22)
1dMyoInos2Acet2Deox	1D-myo-inositol 2-acetamido-2-deoxy-alpha-D-glucopyranoside deacetylase (EC 3.5.1.103)
2345Tetr26DicaNAcet	2,3,4,5-tetrahydropyridine-2,6-dicarboxylate N-acetyltransferase (EC 2.3.1.89)
2345Tetr26DicaNSucc	2,3,4,5-tetrahydropyridine-2,6-dicarboxylate N-succinyltransferase (EC 2.3.1.117)
23BispIndePhosMuta	2,3-bisphosphoglycerate-independent phosphoglycerate mutase (EC 5.4.2.12)
23ButaDehyRAlcoForm	2,3-butanediol dehydrogenase, R-alcohol forming, (R)- and (S)-acetoin-specific (EC 1.1.1.4)
23ButaDehySAlcoForm	2,3-butanediol dehydrogenase, S-alcohol forming, (S)-acetoin-specific (EC 1.1.1.76)
23ButaDehySAlcoForm2	2,3-butanediol dehydrogenase, S-alcohol forming, (R)-acetoin-specific (EC 1.1.1.4)
23DehyCoaHydr	2,3-dehydroadipyl-CoA hydratase (EC 4.2.1.17)
23Dihy1SulfExpo	2,3-dihydroxypropane-1-sulfonate exporter
23Dihy23DihyDehy	2,3-dihydro-2,3-dihydroxybenzoate dehydrogenase [bacillibactin] siderophore (EC 1.3.1.28)
23Dihy23DihyDehy2	2,3-dihydro-2,3-dihydroxybenzoate dehydrogenase of siderophore biosynthesis (EC 1.3.1.28)
23Dihy23DihyDehy3	2,3-dihydro-2,3-dihydroxybenzoate dehydrogenase [enterobactin] siderophore (EC 1.3.1.28)
23Dihy23DihyDehy4	2,3-dihydro-2,3-dihydroxybenzoate dehydrogenase (EC 1.3.1.28)
23Dihy23DihyDehy7	2,3-dihydro-2,3-dihydroxybenzoate dehydrogenase [brucebactin] siderophore (EC 1.3.1.28)
23DihyAmpLiga	2,3-dihydroxybenzoate-AMP ligase (EC 2.7.7.58)
23DihyAmpLigaBaci	2,3-dihydroxybenzoate-AMP ligase [bacillibactin] siderophore (EC 2.7.7.58)
23DihyAmpLigaBruc	2,3-dihydroxybenzoate-AMP ligase [brucebactin] siderophore (EC 2.7.7.58)
23DihyAmpLigaEnan	2,3-dihydroxybenzoate-AMP ligase [enantio-pyochelin] siderophore (EC 2.7.7.58)
23DihyAmpLigaEnte	2,3-dihydroxybenzoate-AMP ligase [enterobactin] siderophore (EC 2.7.7.58)
23DihyAmpLigaPyoc	2,3-dihydroxybenzoate-AMP ligase [pyochelin] siderophore (EC 2.7.7.58)
23DihyAmpLigaSide	2,3-dihydroxybenzoate-AMP ligase of siderophore biosynthesis (EC 2.7.7.58)
23Dike5Meth1Phos	2,3-diketo-5-methylthiopentyl-1-phosphate enolase-phosphatase (EC 3.1.3.77)
23Dike5Meth1Phos2	2,3-diketo-5-methylthiopentyl-1-phosphate enolase (EC 5.3.2.5)
23Dike5Meth1Phos3	2,3-diketo-5-methylthiopentyl-1-phosphate enolase-phosphatase related protein
23Dime6Gera14Benz	2,3-dimethyl-6-geranylgeranyl-1,4-benzoquinone cyclase
23Dime6Phyt14Benz	2,3-dimethyl-6-phytyl-1,4-benzoquinone cyclase
23DimeLyas	2,3-dimethylmalate lyase (EC 4.1.3.32)
23sRrna2OMeth	23S rRNA (cytidine(1920)-2'-O)-methyltransferase (EC 2.1.1.226)
23sRrna2OMeth16s	23S rRNA (cytidine(1920)-2'-O)-methyltransferase @ 16S rRNA (cytidine(1409)-2'-O)-methyltransferase (EC 2.1.1.227) (EC 2.1.1.226)
23sRrnaCMeth	23S rRNA (uracil(1939)-C(5))-methyltransferase (EC 2.1.1.190)
23sRrnaCMethTrna	23S rRNA (adenine(2503)-C(2))-methyltransferase & tRNA (adenine(37)-C(2))-methyltransferase (EC 2.1.1.192)
23sRrnaMethRlmbLsu	23S rRNA (guanosine-2'-O-) -methyltransferase rlmB ## LSU rRNA Gm2251 (EC 2.1.1.-)
23sRrnaNMeth2	23S rRNA (pseudouridine(1915)-N(3))-methyltransferase (EC 2.1.1.177)
23sRrnaNMeth5	23S rRNA (adenine(2030)-N(6))-methyltransferase (EC 2.1.1.266)
24DiamDehy	2,4-diaminopentanoate dehydrogenase (EC 1.4.1.12)
24DienCoaReduNadp	2,4-dienoyl-CoA reductase [NADPH] (EC 1.3.1.34)
24Dike3DeoxLFuco	2,4-diketo-3-deoxy-L-fuconate hydrolase
25Diam6RibiPyri5n1	2,5-diamino-6-ribitylamino-pyrimidinone 5-phosphate deaminase, fungal (EC 3.5.4.-)
25Diam6RibiPyri5n2	2,5-diamino-6-ribitylamino-pyrimidinone 5-phosphate deaminase, archaeal (EC 3.5.4.-)
25Diam6RiboPyri5n1	2,5-diamino-6-ribosylamino-pyrimidinone 5-phosphate reductase, fungal/archaeal (EC 1.1.1.302)
25Diam6RiboPyri5n2	2,5-diamino-6-ribosylamino-pyrimidinone 5-phosphate reductase homolog (EC 1.1.1.302)
25DideRedu	2,5-didehydrogluconate reductase (2-dehydro-D-gluconate-forming) (EC 1.1.1.274)
25DideRedu2	2,5-didehydrogluconate reductase (2-dehydro-L-gulonate-forming) (EC 1.1.1.346)
25DioxDehy	2,5-dioxovalerate dehydrogenase (EC 1.2.1.26)
25RnaLiga	2'-5' RNA ligase (EC 6.5.1.-)
2Amin16DioxAlphSubu	2-aminophenol-1,6-dioxygenase, alpha subunit (EC 1.13.11.n1)
2Amin16DioxBetaSubu	2-aminophenol 1,6-dioxygenase, beta subunit (EC 1.13.11.n1)
2Amin2DeoxIsocHydr2	2-amino-2-deoxy-isochorismate hydrolase PhzD (EC 3.-.-.-)
2Amin2DeoxIsocSynt2	2-Amino-2-deoxy-isochorismate synthase PhzE (EC 2.6.1.86)
2Amin37DideDThre	2-amino-3,7-dideoxy-D-threo-hept-6-ulosonate synthase (EC 2.5.1.-)
2Amin4Hydr6HydrPyro	2-amino-4-hydroxy-6-hydroxymethyldihydropteridine pyrophosphokinase (EC 2.7.6.3)
2Amin4KetoThioAlph	2-amino-4-ketopentanoate thiolase, alpha subunit
2Amin4KetoThioBeta	2-amino-4-ketopentanoate thiolase, beta subunit
2Amin5Form6Ribo4n1	2-amino-5-formylamino-6-ribosylaminopyrimidin-4(3H)-one 5-monophosphate deformylase (EC 3.5.1.102)
2AminAbcTranAtpBind	2-aminoethylphosphonate ABC transporter ATP-binding protein (TC 3.A.1.9.1)
2AminAbcTranPeri	2-aminoethylphosphonate ABC transporter periplasmic binding component (TC 3.A.1.9.1)
2AminAbcTranPerm2	2-aminoethylphosphonate ABC transporter permease protein II (TC 3.A.1.9.1)
2AminAbcTranPerm3	2-aminoethylphosphonate ABC transporter permease protein I (TC 3.A.1.9.1)
2AminDeam	2-aminomuconate deaminase (EC 3.5.99.5)
2AminPyruAmin	2-aminoethylphosphonate:pyruvate aminotransferase (EC 2.6.1.37)
2AminSemiDehy	2-aminomuconate semialdehyde dehydrogenase (EC 1.2.1.32)
2AminUptaMetaRegu	2-aminoethylphosphonate uptake and metabolism regulator
2CMethDEryt24Cycl	2-C-methyl-D-erythritol 2,4-cyclodiphosphate synthase (EC 4.6.1.12)
2CMethDEryt4Phos	2-C-methyl-D-erythritol 4-phosphate cytidylyltransferase (EC 2.7.7.60)
2CarbDArab1Phos	2-carboxy-D-arabinitol-1-phosphatase (EC 3.1.3.63)
2Dehy2Redu	2-dehydropantoate 2-reductase (EC 1.1.1.169)
2Dehy3Deox	2-dehydro-3-deoxygluconokinase (EC 2.7.1.45)
2Dehy3DeoxAldo	2-dehydro-3-deoxyphosphogluconate aldolase (EC 4.1.2.14)
2Dehy3DeoxAldo3	2-dehydro-3-deoxygluconate aldolase (EC 4.1.2-)
2Dehy3DeoxAldoDGluc	2-dehydro-3-deoxyphosphogluconate aldolase in D-glucosaminate utilization operon (EC 4.1.2.14)
2Dehy3DeoxDArabDehy	2-dehydro-3-deoxy-D-arabinonate dehydratase (EC 4.2.1.141)
2Dehy3DeoxDGluc5n1	2-dehydro-3-deoxy-D-gluconate 5-dehydrogenase (EC 1.1.1.127)
2Deox6PhosHydrYnic	2-deoxyglucose-6-phosphate hydrolase YniC
2DeoxDGluc3Dehy	2-deoxy-D-gluconate 3-dehydrogenase (EC 1.1.1.125)
2Desa2HydrBactDehy	2-desacetyl-2-hydroxyethyl bacteriochlorophyllide A dehydrogenase BchC
2GlutDehy	(S)-2-(hydroxymethyl)glutarate dehydrogenase (EC 1.1.1.291)
2GlutDehy2	(S)-2-(hydroxymethyl)glutarate dehydratase
2Hept4QuinSyntPqsd	2-heptyl-4(1H)-quinolone synthase PqsD (EC 2.3.1.230)
2Hydr24DienHydr2	2-hydroxyhexa-2,4-dienoate hydratase (EC 4.2.1.132)
2Hydr2SulfDesu	2'-hydroxybiphenyl-2-sulfinate desulfinase (EC 3.13.1.3)
2Hydr3Keto5Meth1n1	2-hydroxy-3-keto-5-methylthiopentenyl-1-phosphate phosphatase (EC 3.1.3.87)
2Hydr3Keto5Meth1n2	2-hydroxy-3-keto-5-methylthiopentenyl-1-phosphate phosphatase related protein
2Hydr3OxopRedu	2-hydroxy-3-oxopropionate reductase (EC 1.1.1.60)
2HydrAcidOxid	(S)-2-hydroxy-acid oxidase (EC 1.1.3.15)
2HydrCoaDehy	2-hydroxycyclohexanecarboxyl-CoA dehydrogenase (EC 1.1.1.-)
2HydrCoaDehyActi	2-hydroxyglutaryl-CoA dehydratase activator, A-component
2HydrCoaDehyDComp	2-hydroxyglutaryl-CoA dehydratase, D-component HgdA
2HydrCoaDehyDComp2	2-hydroxyglutaryl-CoA dehydratase, D-component HgdB
2HydrComLyas	2-hydroxypropyl-CoM lyase (EC 4.4.1.23)
2HydrDehySimiLSulf	(R)-2-hydroxyacid dehydrogenase, similar to L-sulfolactate dehydrogenase (EC 1.1.1.272)
2HydrMethSuccCoa	2-[hydroxy(phenyl)methyl]-succinyl-CoA dehydrogenase beta subunit (EC 1.1.1.35)
2HydrMethSuccCoa2	2-[hydroxy(phenyl)methyl]-succinyl-CoA dehydrogenase alpha subunit (EC 1.1.1.35)
2IminSynt	2-iminoacetate synthase (ThiH) (EC 4.1.99.19)
2IsopSynt	2-isopropylmalate synthase (EC 2.3.3.13)
2Keto3DeoxDArabHept	2-keto-3-deoxy-D-arabino-heptulosonate-7-phosphate synthase I alpha (EC 2.5.1.54)
2Keto3DeoxDArabHept2	2-keto-3-deoxy-D-arabino-heptulosonate-7-phosphate synthase II (EC 2.5.1.54)
2Keto3DeoxDArabHept3	2-keto-3-deoxy-D-arabino-heptulosonate-7-phosphate synthase I beta (EC 2.5.1.54)
2Keto3DeoxDArabHept4	2-keto-3-deoxy-D-arabino-heptulosonate-7-phosphate synthase II PhzC (EC 2.5.1.54)
2Keto3DeoxDMannOctu	2-Keto-3-deoxy-D-manno-octulosonate-8-phosphate synthase (EC 2.5.1.55)
2Keto3DeoxLFucoDehy	2-keto-3-deoxy-L-fuconate dehydrogenase
2Keto3DeoxLRhamAldo	2-keto-3-deoxy-L-rhamnonate aldolase (EC 4.1.2.53)
2Keto3DeoxPerm	2-keto-3-deoxygluconate permease (KDG permease)
2Keto4PentHydr	2-keto-4-pentenoate hydratase (EC 4.2.1.80)
2KetoCoaHydr	2-ketocyclohexanecarboxyl-CoA hydrolase (EC 4.1.3.36)
2KetoDGlucDehyMemb2	2-Keto-D-gluconate dehydrogenase, membrane-bound, flavoprotein (EC 1.1.99.4)
2KetoDGlucDehyMemb3	2-Keto-D-gluconate dehydrogenase, membrane-bound, cytochrome c (EC 1.1.99.4)
2KetoDGlucDehyMemb4	2-Keto-D-gluconate dehydrogenase, membrane-bound, gamma subunit (EC 1.1.99.4)
2KetoFormLyas	2-ketobutyrate formate-lyase (EC 2.3.1.-)
2KetoKina	2-ketogluconate kinase (EC 2.7.1.13)
2KetoReduBroaSpec	2-ketoaldonate reductase, broad specificity (EC 1.1.1.-) (EC 1.1.1.215)
2Meth3Hydr5CarbAcid	2-methyl-3-hydroxypyridine-5-carboxylic acid oxygenase (EC 1.14.12.4)
2Meth6Gera14Benz	2-methyl-6-geranylgeranyl-1,4-benzoquinone cyclase
2Meth6Phyt14Benz	2-methyl-6-phytyl-1,4-benzoquinone cyclase
2Meth6Phyt14Benz2	2-methyl-6-phytyl-1,4-benzoquinone methyltransferase
2Meth6Phyt14Benz3	2-methyl-6-phytyl-1,4-benzoquinone methyltransferase, eukaryotic type
2Meth6Poly14Benz	2-methoxy-6-polyprenyl-1,4-benzoquinol methylase (EC 2.1.1.201)
2Meth6Sola14Benz	2-methyl-6-solanyl-1,4-benzoquinone methyltransferase
2Meth6Sola14Benz3	2-methyl-6-solanyl-1,4-benzoquinone methyltransferase, eukaryotic type
2MethCoaHydr	2-methylfumaryl-CoA hydratase (EC 4.2.1.148)
2MethDehy	2-methylisocitrate dehydratase (EC 4.2.1.99)
2MethDehy2	2-methylcitrate dehydratase (EC 4.2.1.79)
2MethDehy3	2-methylcitrate dehydratase (2-methyl-trans-aconitate forming) (EC 4.2.1.117)
2MethDehyLargSubu	(R)-2-methylmalate dehydratase large subunit (EC 4.2.1.35)
2MethDehySmalSubu	(R)-2-methylmalate dehydratase small subunit (EC 4.2.1.35)
2MethIsom	2-methylaconitate isomerase
2MethMuta	2-methyleneglutarate mutase (EC 5.4.99.4)
2MethSynt	2-methylcitrate synthase (EC 2.3.3.5)
2OctaHydr	2-octaprenylphenol hydroxylase
2Oxo4Hydr4Carb5Urei	2-oxo-4-hydroxy-4-carboxy-5-ureidoimidazoline (OHCU) decarboxylase (EC 4.1.1.97)
2Oxog2OxoaFerrOxid	2-oxoglutarate/2-oxoacid ferredoxin oxidoreductase, beta subunit (EC 1.2.7.-)
2Oxog2OxoaFerrOxid2	2-oxoglutarate/2-oxoacid ferredoxin oxidoreductase, gamma subunit (EC 1.2.7.-)
2Oxog2OxoaFerrOxid3	2-oxoglutarate/2-oxoacid ferredoxin oxidoreductase, alpha subunit (EC 1.2.7.-)
2Oxog2OxoaFerrOxid4	2-oxoglutarate/2-oxoacid ferredoxin oxidoreductase, delta subunit, ferredoxin-like 4Fe-4S binding protein (EC 1.2.7.-)
2OxogCarbLargSubu	2-oxoglutarate carboxylase, large subunit (EC 6.4.1.7)
2OxogCarbSmalSubu	2-oxoglutarate carboxylase, small subunit (EC 6.4.1.7)
2OxogDeca	2-oxoglutarate decarboxylase (EC 4.1.1.71)
2OxogDehyE1Comp	2-oxoglutarate dehydrogenase E1 component (EC 1.2.4.2)
2OxogMalaTran	2-oxoglutarate/malate translocator
2PhosPhos	2-phosphosulfolactate phosphatase (EC 3.1.3.71 )
2Poly3Meth6Meth1n1	2-polyprenyl-3-methyl-6-methoxy-1,4-benzoquinol hydroxylase
2Poly6HydrMeth	2-polyprenyl-6-hydroxyphenyl methylase (EC 2.1.1.222)
2Poly6MethHydr	2-polyprenyl-6-methoxyphenol hydroxylase
2Pyro46DicaAcidHydr2	2-pyrone-4,6-dicarboxylic acid hydrolase (EC 3.1.1.57)
2Succ5Enol6Hydr3n1	2-succinyl-5-enolpyruvyl-6-hydroxy-3-cyclohexene-1-carboxylic-acid synthase (EC 2.2.1.9)
2Succ6Hydr24Cycl	2-succinyl-6-hydroxy-2,4-cyclohexadiene-1-carboxylate synthase (EC 4.2.99.20)
2SuccHydr	2-(acetamidomethylene)succinate hydrolase (EC 3.5.1.29)
2VinyBactHydrBchf	2-vinyl bacteriochlorophyllide hydratase BchF (EC 4.2.1.-)
2fe2sFerrCbiwClus	2Fe-2S ferredoxin CbiW clustered with, but not required for, cobalamin synthesis
2hPhosSupeProtBc28n1	2H phosphoesterase superfamily protein BC2899
2hPhosSupeProtBsu1n1	2H phosphoesterase superfamily protein Bsu1186 (yjcG)
2tmDoma	2TM domain (pfam13239)
33KdaChap	33 kDa chaperonin (Heat shock protein 33) (HSP33)
34Dide4AminDArab	3,4-dideoxy-4-amino-D-arabino-seduheptulosonic acid 7-phosphate synthase
34Dihy2Buta4Phos	3,4-dihydroxy-2-butanone 4-phosphate synthase (EC 4.1.99.12)
35BispNucl	3'(2'),5'-bisphosphate nucleotidase (EC 3.1.3.7)
35DiamDehy2	3,5-diaminohexanoate dehydrogenase (EC 1.4.1.11)
35ExorBsuYham	3'->5' exoribonuclease Bsu YhaM
35ExorRnasR	3'-to-5' exoribonuclease RNase R
35Olig	3'-to-5' oligoribonuclease (orn)
35OligBBaciType	3'-to-5' oligoribonuclease B, Bacillus type
35OligBaciType	3'-to-5' oligoribonuclease A, Bacillus type
37DideDThreHept2n1	3,7-dideoxy-D-threo-hepto-2, 6-diulosonate synthase (EC 4.2.3.-)
3Amin5HydrSynt	3-amino-5-hydroxybenzoate synthase (EC 4.2.1.144)
3AminCoaAmmoLyas	3-aminobutyryl-CoA ammonia-lyase (EC 4.3.1.14)
3AminCoaAmmoLyas2	3-aminobutyrl-CoA ammonia lyase (EC 4.3.1.14)
3CarbCisCisMucoCycl	3-carboxy-cis,cis-muconate cycloisomerase (EC 5.5.1.2)
3DehyDehy2	3-dehydroshikimate dehydratase (EC 4.2.1.118)
3DehyDehyI	3-dehydroquinate dehydratase I (EC 4.2.1.10)
3DehyDehyIi	3-dehydroquinate dehydratase II (EC 4.2.1.10)
3DehyLGulo2Dehy	3-dehydro-L-gulonate 2-dehydrogenase (EC 1.1.1.130)
3DehySynt	3-dehydroquinate synthase (EC 4.2.3.4)
3Deme3OMeth	3-demethylubiquinol 3-O-methyltransferase (EC 2.1.1.64)
3DeoxDMannOctu8Phos	3-deoxy-D-manno-octulosonate 8-phosphate phosphatase (EC 3.1.3.45)
3DeoxDMannOctuAcid3	3-deoxy-D-manno-octulosonic acid transferase (EC 2.4.99.13) (EC 2.4.99.12)
3DeoxMannOctuCyti	3-deoxy-manno-octulosonate cytidylyltransferase (EC 2.7.7.38)
3Hydr2Meth45Dica	3-hydroxy-2-methylpyridine-4,5-dicarboxylate 4-decarboxylase (EC 4.1.1.51)
3Hydr34Diox	3-hydroxyanthranilate 3,4-dioxygenase (EC 1.13.11.6)
3Hydr3IsohCoaLyas	3-hydroxy-3-isohexenylglutaryl-CoA lyase (EC 4.1.3.26)
3HydrAcpCoaTranPhag	(R)-3-hydroxydecanoyl-ACP:CoA transacylase PhaG (3-hydroxyacyl-CoA-acyl carrier protein transferase) (EC 2.4.1.-)
3HydrAcpDehy	3-hydroxydecanoyl-[ACP] dehydratase (EC 4.2.1.59)
3HydrAcylCarrProt2	3-hydroxyacyl-[acyl-carrier-protein] dehydratase, FabZ form (EC 4.2.1.59)
3HydrAcylCarrProt3	3-hydroxyacyl-[acyl-carrier-protein] dehydratase, FabA form (EC 4.2.1.59)
3HydrCoaDehy	3-hydroxybutyryl-CoA dehydrogenase (EC 1.1.1.157)
3HydrCoaDehy2	3-hydroxyacyl-CoA dehydrogenase (EC 1.1.1.35)
3HydrCoaDehy3	3-hydroxybutyryl-CoA dehydratase (EC 4.2.1.55)
3HydrCoaDehy4	3-hydroxyadipyl-CoA dehydrogenase
3HydrCoaDehy7	3-hydroxypropionyl-CoA dehydratase (EC 4.2.1.116)
3HydrCoaDehyFabg	3-hydroxyacyl-CoA dehydrogenase, FabG4 (EC 1.1.1.35)
3HydrCoaDehyFadn	3-hydroxyacyl-CoA dehydrogenase [fadN-fadA-fadE operon] (EC 1.1.1.35)
3HydrCoaDehyIsol	3-hydroxyacyl-CoA dehydrogenase [isoleucine degradation] (EC 1.1.1.35)
3HydrCoaEpim	3-hydroxybutyryl-CoA epimerase (EC 5.1.2.3)
3HydrCoaHydr	3-hydroxyisobutyryl-CoA hydrolase (EC 3.1.2.4)
3HydrCoaLiga	3-hydroxybenzoate--CoA ligase (EC 6.2.1.37)
3HydrCoaSynt	3-hydroxypropionyl-CoA synthase (EC 6.2.1.36)
3HydrDehy	3-hydroxypropionate dehydrogenase (EC 1.1.1.298)
3HydrDehy2	3-hydroxyisobutyrate dehydrogenase (EC 1.1.1.31)
3HydrDehyDddaFlav	3-hydroxypropionate dehydrogenase DddA, flavin-containing (EC 1.1.1.59)
3IsopDehy	3-isopropylmalate dehydrogenase (EC 1.1.1.85)
3IsopDehyLargSubu	3-isopropylmalate dehydratase large subunit (EC 4.2.1.33)
3IsopDehySmalSubu	3-isopropylmalate dehydratase small subunit (EC 4.2.1.33)
3Keto5AminCleaEnzy	3-keto-5-aminohexanoate cleavage enzyme
3KetoCoaThio	3-ketoacyl-CoA thiolase (EC 2.3.1.16)
3KetoCoaThio2Fadn	3-ketoacyl-CoA thiolase 2 [fadN-fadA-fadE operon] (EC 2.3.1.16)
3KetoCoaThioFadn	3-ketoacyl-CoA thiolase [fadN-fadA-fadE operon] (EC 2.3.1.16)
3KetoCoaThioIsol	3-ketoacyl-CoA thiolase [isoleucine degradation] (EC 2.3.1.16)
3KetoLGulo6PhosDeca	3-keto-L-gulonate 6-phosphate decarboxylase (EC 4.1.1.85)
3KetoLGulo6PhosDeca3	3-keto-L-gulonate-6-phosphate decarboxylase UlaD (L-ascorbate utilization protein D) (EC 4.1.1.85)
3Meth2OxobHydr	3-methyl-2-oxobutanoate hydroxymethyltransferase (EC 2.1.2.11)
3MethCoaDehy	3-methylmercaptopropionyl-CoA dehydrogenase (DmdC)
3MethCoaHydr2	3-methylthioacryloyl-CoA hydratase (DmdD)
3MethCoaHydr2n1	3-methylthioacryloyl-CoA hydratase 2 (DmdD2)
3MethCoaLiga	3-methylmercaptopropionyl-CoA ligase (DmdB)
3MethCoaLigaDmdb	3-methylmercaptopropionyl-CoA ligase of DmdB2 type (EC 6.2.1.44)
3MethCoaLigaDmdb2	3-methylmercaptopropionyl-CoA ligase of DmdB1 type (EC 6.2.1.44)
3MethDeltIsom	3-methylitaconate Delta isomerase (EC 5.3.3.6)
3Oxo56DehyCoaSemi	3-oxo-5,6-dehydrosuberyl-CoA semialdehyde dehydrogenase (EC 1.2.1.91)
3OxoaAcpRedu	3-oxoacyl-[ACP] reductase (EC 1.1.1.100)
3OxoaAcpSynt	3-oxoacyl-[ACP] synthase (EC 2.3.1.41)
3OxoaAcpSyntFabv	3-oxoacyl-[ACP] synthase FabV like (EC 2.3.1.41)
3OxoaAcpSyntIiiAlka	3-oxoacyl-[ACP] synthase III in alkane synthesis cluster
3OxoaAcylCarrProt	3-oxoacyl-[acyl-carrier-protein] synthase, KASI (EC 2.3.1.41)
3OxoaAcylCarrProt16	3-oxoacyl-[acyl-carrier protein] reductase paralog in cluster with unspecified monosaccharide transporter (EC 1.1.1.100)
3OxoaAcylCarrProt2	3-oxoacyl-[acyl-carrier-protein] synthase, KASIII (EC 2.3.1.41)
3OxoaAcylCarrProt3	3-oxoacyl-[acyl-carrier protein] reductase (EC 1.1.1.100)
3OxoaAcylCarrProt33	3-oxoacyl-[acyl-carrier-protein] synthase, KASI, alternative (EC 2.3.1.41)
3OxoaAcylCarrProt4	3-oxoacyl-[acyl-carrier-protein] synthase, KASII (EC 2.3.1.179)
3OxoaCoaThio3Oxo	3-oxoadipyl-CoA thiolase @ 3-oxo-5,6-dehydrosuberyl-CoA thiolase (EC 2.3.1.223) (EC 2.3.1.174)
3OxoaCoaTran	3-oxoacid CoA-transferase (EC 2.8.3.5)
3OxoaCoaTranSubu	3-oxoadipate CoA-transferase subunit A (EC 2.8.3.6)
3OxoaCoaTranSubu2	3-oxoadipate CoA-transferase subunit B (EC 2.8.3.6)
3Poly4HydrCarbLyas	3-polyprenyl-4-hydroxybenzoate carboxy-lyase (EC 4.1.1.-)
3SulpRedu	3-sulpholactaldehyde reductase
4AlphGluc	4-alpha-glucanotransferase (amylomaltase) (EC 2.4.1.25)
4Amin4DeoxDehy	4-amino, 4-deoxyprephenate dehydrogenase (EC 1.3.1.-)
4Amin4DeoxMuta	4-amino, 4-deoxychorismate mutase (EC 5.4.99.-)
4AminDehy	4-aminobutyraldehyde dehydrogenase (EC 1.2.1.19)
4Carb2Hydr6SemiDehy	4-carboxy-2-hydroxymuconate-6-semialdehyde dehydrogenase
4Carb4Hydr2OxoaAldo	4-carboxy-4-hydroxy-2-oxoadipate aldolase (EC 4.1.3.17)
4CarbDeca	4-carboxymuconolactone decarboxylase (EC 4.1.1.44)
4CoumCoaLiga	4-coumarate--CoA ligase (EC 6.2.1.12)
4DemeSynt	4'-demethylrebeccamycin synthase (EC 4.3.3.5)
4Deox4FormLArabPhos	4-deoxy-4-formamido-L-arabinose-phosphoundecaprenol deformylase ArnD (EC 3.5.1.n3)
4DeoxLThre5HexoUron	4-deoxy-L-threo-5-hexosulose-uronate ketol-isomerase (EC 5.3.1.17)
4Diph2CMethDEryt	4-diphosphocytidyl-2-C-methyl-D-erythritol kinase (EC 2.7.1.148)
4Hydr2OxogAldo	4-hydroxy-2-oxoglutarate aldolase (EC 4.1.3.16)
4Hydr2OxovAldo	4-hydroxy-2-oxovalerate aldolase (EC 4.1.3.39)
4Hydr3Meth2EnylDiph	4-hydroxy-3-methylbut-2-enyl diphosphate reductase (EC 1.17.1.2)
4Hydr4PhosDehy	4-hydroxythreonine-4-phosphate dehydrogenase (EC 1.1.1.262)
4HydrCoaDehy	4-hydroxybutanoyl-CoA dehydratase (EC 4.2.1.-)
4HydrCoaLiga	4-hydroxybenzoate--CoA ligase (EC 6.2.1.27)
4HydrCoaReduAlph	4-hydroxybenzoyl-CoA reductase, alpha subunit (EC 1.3.99.20)
4HydrCoaReduBeta	4-hydroxybenzoyl-CoA reductase, beta subunit (EC 1.3.99.20)
4HydrCoaReduGamm	4-hydroxybenzoyl-CoA reductase, gamma subunit (EC 1.3.99.20)
4HydrDecaActiEnzy	4-hydroxyphenylacetate decarboxylase activating enzyme
4HydrDecaLargSubu	4-hydroxyphenylacetate decarboxylase, large subunit (EC 4.1.1.83)
4HydrDecaSmalSubu	4-hydroxyphenylacetate decarboxylase, small subunit (EC 4.1.1.83)
4HydrDiox	4-hydroxyphenylpyruvate dioxygenase (EC 1.13.11.27)
4HydrEpim	4-hydroxyproline epimerase (EC 5.1.1.8)
4HydrPoly	4-hydroxybenzoate polyprenyltransferase (EC 2.5.1.39)
4HydrSola	4-hydroxybenzoate solanesyltransferase (plastoquinone-9 biosynthesis in cyanobacteria)
4HydrTetrRedu	4-hydroxy-tetrahydrodipicolinate reductase (EC 1.17.1.8)
4HydrTetrSynt	4-hydroxy-tetrahydrodipicolinate synthase (EC 4.3.3.7)
4Nitr	4-nitrophenylphosphatase (EC 3.1.3.41)
4OxalDeca	4-oxalocrotonate decarboxylase (EC 4.1.1.77)
4OxalHydr	4-oxalomesaconate hydratase (EC 4.2.1.83)
4OxalHydr2	4-oxalmesaconate hydratase (EC 4.2.1.83)
4OxalTaut3	4-oxalomesaconate tautomerase (EC 5.3.2.8)
4PhosTran	4'-phosphopantetheinyl transferase (EC 2.7.8.-)
4PhosTranEnteSide	4'-phosphopantetheinyl transferase [enterobactin] siderophore (EC 2.7.8.-)
4PhosTranInfeFor	4'-phosphopantetheinyl transferase, inferred for PFA pathway (EC 2.7.8.-)
4PhosTranLikeDoma	4'-phosphopantetheinyl transferase-like domain PF01648
4Pyri	4-pyridoxolactonase (EC 3.1.1.27)
4PyriAcidDehy	4-pyridoxic acid dehydrogenase
4fe4sFerrIronSulf	4Fe-4S ferredoxin, iron-sulfur binding (EC 1.6.99.5 )
4fe4sFerrNitrAsso	4Fe-4S ferredoxin, nitrogenase-associated
50sRiboProtAcet	50S ribosomal protein acetyltransferase
50sRiboSubuMatuGtpa	50S ribosomal subunit maturation GTPase RbgA (B. subtilis YlqF)
510MethRedu	5,10-methylenetetrahydrofolate reductase (EC 1.5.1.20)
510MethReduElecTran	5,10-methylenetetrahydrofolate reductase, electron transport protein (EC 1.5.1.20)
510MethReduSmalSubu	5,10-methylenetetrahydrofolate reductase, small subunit (EC 1.5.1.20)
5678TetrHydrLyas	5,6,7,8-tetrahydromethanopterin hydro-lyase (EC 4.2.1.147)
5Amin6UracPhos	5-Amino-6-(5'-phosphoribitylamino)uracil phosphatase
5Amin6UracRedu	5-amino-6-(5-phosphoribosylamino)uracil reductase (EC 1.1.1.193)
5Amin6UracReduDive	5-amino-6-(5-phosphoribosylamino)uracil reductase, divergent (EC 1.1.1.193)
5AminSynt	5-aminolevulinate synthase (EC 2.3.1.37)
5CarbUrid5Carb2Thio	5-carboxymethyl uridine and 5-carboxymethyl 2-thiouridine methyltransferase
5Dehy4DeoxDehy	5-dehydro-4-deoxyglucarate dehydratase (EC 4.2.1.41)
5Deox5AminAcidDehy	5-deoxy-5-aminodehydroquinic acid dehydratase
5Deox5AminAcidSynt	5-deoxy-5-aminodehydroquinic acid synthase
5DeoxGlucIsom	5-deoxy-glucuronate isomerase (EC 5.3.1.-)
5Enol3PhosSynt	5-Enolpyruvylshikimate-3-phosphate synthase (EC 2.5.1.19)
5FclLikeProtButPred	5-FCL-like protein, but predicted not to be 5-formyltetrahydrofolate cyclo-ligase (5-FCL)
5FormCyclLiga	5-formyltetrahydrofolate cyclo-ligase (EC 6.3.3.2)
5FormCyclParaImpl	5-Formyltetrahydrofolate cycloligase paralog implicated in thiamin metabolism
5HydrHydr	5-hydroxyisourate hydrolase (EC 3.5.2.17)
5Keto2Deox	5-keto-2-deoxygluconokinase (EC 2.7.1.92)
5Keto2DeoxDGluc6n1	5-keto-2-deoxy-D-gluconate-6 phosphate aldolase [form 2] (EC 4.1.2.29)
5Keto2DeoxDGluc6n2	5-keto-2-deoxy-D-gluconate-6 phosphate aldolase (EC 4.1.2.29)
5KetoDGluc5Redu	5-keto-D-gluconate 5-reductase (EC 1.1.1.69)
5MethCorrIronSulf2	5-methyltetrahydrofolate:corrinoid/iron-sulfur protein Co-methyltransferase (EC 2.1.1.258)
5MethCorrIronSulf3	5-methyltetrahydrosarcinapterin:corrinoid/iron-sulfur protein Co-methyltransferase (EC 2.1.1.245)
5MethDctpPyro	5-methyl-dCTP pyrophosphohydrolase (EC 3.6.1.-)
5MethHomoMeth	5-methyltetrahydropteroyltriglutamate--homocysteine methyltransferase (EC 2.1.1.14)
5MethHomoMeth2	5-methyltetrahydrofolate--homocysteine methyltransferase (EC 2.1.1.13)
5MethKina	5-methylthioribose kinase (EC 2.7.1.100)
5MethNucl	5'-methylthioadenosine nucleosidase (EC 3.2.2.16)
5MethPhos	5'-methylthioadenosine phosphorylase (EC 2.4.2.28)
5MethSAdenNuclRela	5'-methylthioadenosine/S-adenosylhomocysteine nucleosidase related protein BCZK2595
5MethSAdenNuclRela2	5'-methylthioadenosine/S-adenosylhomocysteine nucleosidase related protein VF1653
5MethSAdenNuclRela3	5'-methylthioadenosine/S-adenosylhomocysteine nucleosidase related protein BA2564
5MethSAdenNuclRela5	5'-methylthioadenosine/S-adenosylhomocysteine nucleosidase related protein BT9727_1702
5NuclSure2	5'-nucleotidase SurE (EC 3.1.3.5)
5Oxop	5-oxoprolinase (EC 3.5.2.9)
5OxopHyuaLikeDoma	5-oxoprolinase, HyuA-like domain (EC 3.5.2.9)
5OxopHyubLikeDoma	5-oxoprolinase, HyuB-like domain (EC 3.5.2.9)
5PhosDiphDecaPhos	5-Phosphoribosyl diphosphate (PRPP): decaprenyl-phosphate 5-phosphoribosyltransferase (EC 2.4.2.45)
5TetrCorrIronSulf	5-tetrahydromethanopterin:corrinoid iron-sulfur protein methyltransferase
67Dime8RibiSynt	6,7-dimethyl-8-ribityllumazine synthase (EC 2.5.1.78)
67Dime8RibiSyntPara	6,7-dimethyl-8-ribityllumazine synthase paralog
6Carb5678TetrSynt	6-carboxy-5,6,7,8-tetrahydropterin synthase (EC 4.1.2.50)
6Deox6Sulp1PhosAldo	6-deoxy-6-sulphofructose-1-phosphate aldolase
6Deox6SulpIsom	6-deoxy-6-sulphoglucose isomerase
6Deox6SulpKina	6-deoxy-6-sulphofructose kinase
6Hydr1En1CarbCoa	6-hydroxycylohex-1-en-1-carbonyl-CoA dehydrogenase
6HydrRedu	6-hydroxynicotinate reductase (EC 1.3.7.1)
6KdaEarlSecrAnti	6 kDa early secretory antigenic target ESAT-6 (EsxA)
6Oxoc1Ene1CarbCoa	6-oxocyclohex-1-ene-1-carbonyl-CoA hydratase
6Phos	6-phosphofructokinase (EC 2.7.1.11)
6Phos2	6-phosphogluconolactonase (EC 3.1.1.31)
6Phos3Hexu	6-phospho-3-hexuloisomerase (EC 5.3.1.27)
6PhosBetaGala	6-phospho-beta-galactosidase (EC 3.2.1.85)
6PhosBetaGluc	6-phospho-beta-glucosidase (EC 3.2.1.86)
6PhosClasIi	6-phosphofructokinase class II (EC 2.7.1.11)
6PhosDehyDeca	6-phosphogluconate dehydrogenase, decarboxylating (EC 1.1.1.44)
6PhosEukaType	6-phosphogluconolactonase, eukaryotic type (EC 3.1.1.31)
6PhosFungAnimType	6-phosphofructokinase, fungal/animal type (EC 2.7.1.11)
6PyruTetrSynt	6-pyruvoyl tetrahydrobiopterin synthase (EC 4.2.3.12)
78Dide8Hydr5Deaz	7,8-didemethyl-8-hydroxy-5-deazariboflavin synthase subunit 1
78Dide8Hydr5Deaz2	7,8-didemethyl-8-hydroxy-5-deazariboflavin synthase subunit 2
7Carb7DeazSynt	7-carboxy-7-deazaguanine synthase (EC 4.3.99.3)
7Cyan7DeazSynt	7-cyano-7-deazaguanine synthase (EC 6.3.4.20)
7HydrChloRedu	7-hydroxymethyl chlorophyll a reductase (EC 1.17.7.2)
8Amin7OxonSynt	8-amino-7-oxononanoate synthase (EC 2.3.1.47)
AaaFamiProtAtpaEcca	AAA+ family protein ATPase EccA1, component of Type VII secretion system ESX-1
AaaFamiProtAtpaEcca2	AAA+ family protein ATPase EccA3, component of Type VII secretion system ESX-3
AaaFamiProtAtpaEcca3	AAA+ family protein ATPase EccA5, component of Type VII secretion system ESX-5
AaaFamiProtAtpaEcca4	AAA+ family protein ATPase EccA2, component of Type VII secretion system ESX-2
AbcEfflPumpFuseInne	ABC efflux pump, fused inner membrane and ATPase subunits in pyochelin gene cluster
AbcExpoAtpBindSubu	ABC exporter, ATP-binding subunit of DevA family
AbcExpoForHemoHasa	ABC exporter for hemopore HasA, membrane fusion protein (MFP) family component HasE
AbcExpoForHemoHasa2	ABC exporter for hemopore HasA, ATP-binding component HasD
AbcExpoForHemoHasa3	ABC exporter for hemopore HasA, outer membrane component HasF
AbcExpoMembFusiComp	ABC exporter membrane fusion component of DevB family
AbcExpoPermSubuDevc	ABC exporter permease subunit of DevC family
AbcFe3SideTranInne	ABC Fe3+ siderophore transporter, inner membrane subunit
AbcTranAtpBindComp	ABC transporter (iron.B12.siderophore.hemin), ATP-binding component
AbcTranAtpBindProt11	ABC transporter, ATP-binding protein YnjD
AbcTranAtpBindProt13	ABC transporter, ATP-binding protein YejF
AbcTranAtpBindProt2	ABC transporter ATP-binding protein SCO2422
AbcTranAtpBindProt4	ABC transporter, ATP-binding protein EcsA
AbcTranAtpBindProt53	ABC transporter, ATP-binding protein in BtlB locus
AbcTranAtpBindProt76	ABC transporter ATP-binding protein, associated with thiamin (pyrophosphate?) binding lipoprotein p37
AbcTranInvoCytoC	ABC transporter involved in cytochrome c biogenesis, CcmB subunit
AbcTranInvoCytoC2	ABC transporter involved in cytochrome c biogenesis, ATPase component CcmA
AbcTranPeriSubsBind	ABC transporter (iron.B12.siderophore.hemin), periplasmic substrate-binding component
AbcTranPermComp	ABC transporter (iron.B12.siderophore.hemin), permease component
AbcTranPermProtBtlb	ABC transporter, permease protein in BtlB locus
AbcTranPermProtEscb	ABC transporter, permease protein EscB
AbcTranPermProtYejb	ABC transporter, permease protein YejB
AbcTranPermProtYeje	ABC transporter, permease protein YejE
AbcTranPermProtYnjc	ABC transporter, permease protein YnjC
AbcTranPredExpoYydf	ABC transporter predicted to export YydF, permease protein
AbcTranPredExpoYydf2	ABC transporter predicted to export YydF, ATP-binding protein
AbcTranProtIroc	ABC transporter protein IroC
AbcTranPyovGeneClus	ABC transporter in pyoverdin gene cluster, periplasmic component
AbcTranPyovGeneClus2	ABC transporter in pyoverdin gene cluster, permease component
AbcTranPyovGeneClus3	ABC transporter in pyoverdin gene cluster, ATP-binding component
AbcTranSperPutrBind	ABC transporter spermidine/putrescine-binding protein
AbcTranSubsBindProt2	ABC transporter, substrate-binding protein YnjB
AbcTranSubsBindProt4	ABC transporter, substrate-binding protein YejA
AbcTypeBranChaiAmin	ABC-type branched-chain amino acid transport systems, periplasmic component
AbcTypeEfflPumpDupl	ABC-type efflux pump, duplicated ATPase component YbhF
AbcTypeEfflPumpMemb	ABC-type efflux pump membrane fusion component YbhG
AbcTypeEfflPumpPerm	ABC-type efflux pump permease component YbhR
AbcTypeEfflPumpPerm2	ABC-type efflux pump permease component YbhS
AbcTypeFe3SideTran	ABC-type Fe3+-siderophore transport system, ATPase component
AbcTypeFe3SideTran2	ABC-type Fe3+-siderophore transport system, permease 2 component
AbcTypeFe3SideTran3	ABC-type Fe3+-siderophore transport system, permease component
AbcTypeFe3SideTran4	ABC-type Fe3+-siderophore transport system, periplasmic iron-binding component
AbcTypeFe3TranSyst	ABC-type Fe3+ transport system, periplasmic component
AbcTypeHemiTranSyst	ABC-type hemin transport system, ATPase component
AbcTypeProtExpoAtp	ABC-type protease exporter, ATP-binding component PrtD/AprD
AbcTypeProtExpoMemb	ABC-type protease exporter, membrane fusion protein (MFP) family component PrtE/AprE
AbcTypeProtExpoOute	ABC-type protease exporter, outer membrane component PrtF/AprF
AbcTypeSideExpoSyst	ABC-type siderophore export system, fused ATPase and permease components
AbcTypeSperPutrTran	ABC-type spermidine/putrescine transport system, permease component II
AbcTypeSperPutrTran2	ABC-type spermidine/putrescine transport system, permease component I
AbcTypeSperPutrTran3	ABC-type spermidine/putrescine transport systems, ATPase components
AcceCholEnte	Accessory cholera enterotoxin
AcceColoFactAcfa	Accessory colonization factor AcfA
AcceColoFactAcfb	Accessory colonization factor AcfB
AcceColoFactAcfc	Accessory colonization factor AcfC
AcceColoFactAcfd	Accessory colonization factor AcfD precursor
AcceGeneRegu	Accessory gene regulator A (response regulator)
AcceGeneReguB	Accessory gene regulator B
AcceGeneReguC	Accessory gene regulator C (sensor histidine kinase)
AcceGeneReguD	Accessory gene regulator D (pheromone precursor, type II)
AcceGeneReguD2	Accessory gene regulator D (pheromone precursor, type III)
AcceGeneReguD3	Accessory gene regulator D (pheromone precursor, type I)
AcceProtYqecSele	Accessory protein YqeC in selenium-dependent molybdenum hydroxylase maturation
AcceSecrProtAsp1n1	Accessory secretory protein Asp1
AcceSecrProtAsp2n1	Accessory secretory protein Asp2
AcceSecrProtAsp3n1	Accessory secretory protein Asp3
AccuAssoProtAap	Accumulation-associated protein AAP
AcetAcidSynt	Acetohydroxy acid synthase
AcetAcuaAcetCoaSynt	Acetyltransferase AcuA, acetyl-CoA synthetase inhibitor
AcetAmin	Acetylornithine aminotransferase (EC 2.6.1.11)
AcetCarbAlphSubu	Acetone carboxylase, alpha subunit (EC 6.4.1.6)
AcetCarbBetaSubu	Acetone carboxylase, beta subunit (EC 6.4.1.6)
AcetCarbGammSubu	Acetone carboxylase, gamma subunit (EC 6.4.1.6)
AcetCarbSubuApc1n1	Acetophenone carboxylase subunit Apc1 (EC 6.4.1.8)
AcetCarbSubuApc2n1	Acetophenone carboxylase subunit Apc2 (EC 6.4.1.8)
AcetCarbSubuApc3n1	Acetophenone carboxylase subunit Apc3 (EC 6.4.1.8)
AcetCarbSubuApc4n1	Acetophenone carboxylase subunit Apc4 (EC 6.4.1.8)
AcetCarbSubuApc5n1	Acetophenone carboxylase subunit Apc5 (EC 6.4.1.8)
AcetCataProtXPoss	Acetoin catabolism protein X, possible NAD kinase
AcetCoaAcet	Acetyl-CoA acetyltransferase (EC 2.3.1.9)
AcetCoaAcetEthyCoa	Acetyl-CoA acetyltransferase of ethylmalonyl-CoA pathway (EC 2.3.1.9)
AcetCoaAcetFada	Acetyl-CoA acetyltransferase, FadA2 (EC 2.3.1.9)
AcetCoaAcetLikeProt	acetyl-CoA acetyltransferase-like protein
AcetCoaCAcyl	Acetyl-CoA C-acyltransferase (EC 2.3.1.16)
AcetCoaCysGlcnIns	Acetyl-CoA:Cys-GlcN-Ins acetyltransferase, mycothiol synthase MshD (EC 2.3.1.189)
AcetCoaRedu	Acetoacetyl-CoA reductase (EC 1.1.1.36)
AcetCoaReduEthyCoa	Acetoacetyl-CoA reductase of ethylmalonyl-CoA pathway (EC 1.1.1.36)
AcetCoaSensPanmRequ	Acetyl-CoA sensor PanM, required for maturation of L-aspartate decarboxylase
AcetCoaSynt	Acetoacetyl-CoA synthetase (EC 6.2.1.16)
AcetCoaSynt2	Acetyl-CoA synthetase (EC 6.2.1.1)
AcetCoaSynt3	Acetyl CoA synthase (Acetyl-CoA c-acetyltransferase) (EC 2.3.1.9)
AcetCoaSyntAlphBeta	Acetyl-CoA synthetase (ADP-forming) alpha and beta chains, putative
AcetCoaSyntAlphChai	Acetyl-CoA synthetase (ADP-forming) alpha chain (EC 6.2.1.13)
AcetCoaSyntBetaChai	Acetyl-CoA synthetase (ADP-forming) beta chain (EC 6.2.1.13)
AcetCoaSyntCorrActi	Acetyl-CoA synthase corrinoid activation protein
AcetCoaSyntCorrIron	Acetyl-CoA synthase corrinoid iron-sulfur protein, small subunit
AcetCoaSyntCorrIron2	Acetyl-CoA synthase corrinoid iron-sulfur protein, large subunit
AcetCoaSyntLeuc	Acetoacetyl-CoA synthetase [leucine] (EC 6.2.1.16)
AcetCoenCarbTran	Acetyl-coenzyme A carboxyl transferase alpha chain (EC 6.4.1.2)
AcetCoenCarbTran2	Acetyl-coenzyme A carboxyl transferase beta chain (EC 6.4.1.2)
AcetCoenCarbTran5	Acetyl-coenzyme A carboxyl transferase (EC 6.4.1.2)
AcetCoenCarbTran6	Acetyl-coenzyme A carboxyl transferase alpha chain / Acetyl-coenzyme A carboxyl transferase beta chain (EC 6.4.1.2); Propionyl-CoA carboxylase beta chain (EC 6.4.1.3) (EC 6.4.1.2)
AcetDeac	Acetylornithine deacetylase (EC 3.5.1.16)
AcetDeca	Acetoacetate decarboxylase (EC 4.1.1.4)
AcetDehy	Acetaldehyde dehydrogenase (EC 1.2.1.10)
AcetDehy2ClusWith	Acetaldehyde dehydrogenase 2, clustered with pyruvate formate-lyase (EC 1.2.1.10)
AcetDehyAcetGene	Acetaldehyde dehydrogenase, acetylating, in gene cluster for degradation of phenols, cresols, catechol (EC 1.2.1.10)
AcetDehyClusWith	Acetaldehyde dehydrogenase, clustered with pyruvate formate-lyase (EC 1.2.1.10)
AcetDehyE1CompAlph	Acetoin dehydrogenase E1 component alpha-subunit (EC 2.3.1.190)
AcetDehyE1CompBeta	Acetoin dehydrogenase E1 component beta-subunit (EC 2.3.1.190)
AcetDehyEthaUtil	Acetaldehyde dehydrogenase, ethanolamine utilization cluster (EC 1.2.1.10)
AcetHydrMbtj	Acetyl hydrolase MbtJ
AcetKina	Acetylglutamate kinase (EC 2.7.2.8)
AcetKina2	Acetate kinase (EC 2.7.2.1)
AcetKina3	Acetylaminoadipate kinase (EC 2.7.2.-)
AcetMetaReguProt	Acetoacetate metabolism regulatory protein AtoC
AcetPermActp	Acetate permease ActP (cation/acetate symporter)
AcetPermActpPaal	Acetate permease ActP (cation/acetate symporter) PaaL
AcetRedu	Acetoin (diacetyl) reductase (EC 1.1.1.304)
AcetSyntCata	Acetolactate synthase, catabolic (EC 2.2.1.6)
AcetSyntLargSubu	Acetolactate synthase large subunit (EC 2.2.1.6)
AcetSyntSmalSubu	Acetolactate synthase small subunit (EC 2.2.1.6)
AcetSyntSmalSubu4	Acetolactate synthase small subunit, predicted (EC 2.2.1.6)
AcetSyntSmalSubu5	Acetolactate synthase small subunit, predicted, Archaeal type (EC 2.2.1.6)
AcetSyntSmalSubu6	Acetolactate synthase small subunit, predicted, Archaeal type 2 (EC 2.2.1.6)
AcetYpea	Acetyltransferase YpeA
AchrBiosProtAcsa	Achromobactin biosynthesis protein AcsA
AchrBiosProtAcsb	Achromobactin biosynthesis protein AcsB, HpcH/HpaI aldolase family
AchrBiosProtAcsc	Achromobactin biosynthesis protein AcsC
AchrBiosProtAcsd	Achromobactin biosynthesis protein AcsD
AchrBiosProtAcse	Achromobactin biosynthesis protein AcsE, Orn/DAP/Arg decarboxylase family
AchrBiosProtAcsf	Achromobactin biosynthesis protein AcsF
AcidPhagReguProt	Acid and phagosome regulated protein AprA
AcidPhagReguProt2	Acid and phagosome regulated protein AprB
AconDeca	Aconitate decarboxylase (EC 4.1.1.6)
AconFamiProtYbhj	Aconitase family protein YbhJ
AconHydr	Aconitate hydratase (EC 4.2.1.3)
AconHydr2n1	Aconitate hydratase 2 (EC 4.2.1.3)
AconHydrLargSubu	Aconitate hydratase large subunit (EC 4.2.1.3)
AconHydrSmalSubu	Aconitate hydratase small subunit (EC 4.2.1.3)
AconHydrXPred	Aconitate hydratase X, predicted
AcryCoaReduAcuiYhdh	Acryloyl-CoA reductase AcuI/YhdH (EC 1.3.1.84)
AcrzMembProtAsso	AcrZ membrane protein associated with AcrAB-TolC multidrug efflux pump
ActDomaContProtPred	ACT-domain-containing protein, predicted allosteric regulator of homoserine dehydrogenase
ActDomaProt	ACT domain protein
ActiAdpRiboToxiSpvb	Actin-ADP-ribosyltransferase, toxin SpvB
ActiAsseInduProt	Actin-assembly inducing protein ActA precursor
ActiPhosIsom	Acting phosphoribosylanthranilate isomerase (EC 5.3.1.24)
AcycCaro12Hydr	Acyclic carotenoid 1,2-hydratase (EC 4.2.1.131)
AcycTerpUtilRegu	Acyclic terpenes utilization regulator AtuR, TetR family
AcycTerpUtilRegu2	Acyclic terpenes utilization regulator AtuR, AraC family
AcylAcidReleEnzy	Acylamino-acid-releasing enzyme (EC 3.4.19.1)
AcylAcpGlyc3Phos	Acyl-ACP:glycerol-3-phosphate O-acyltransferase (EC 2.3.1.n5)
AcylAcpRedu	Acyl-ACP reductase
AcylAcylCarrProt	Acyl-[acyl-carrier-protein]--UDP-N-acetylglucosamine O-acyltransferase (EC 2.3.1.129)
AcylAcylCarrProt2	Acyl-[acyl-carrier-protein] synthetase (EC 6.2.1.20)
AcylCarrProt	Acyl carrier protein
AcylCarrProt2	Acyl carrier protein (ACP1)
AcylCarrProt3	Acyl carrier protein (ACP2)
AcylCarrProtAsso	Acyl carrier protein associated with anthrachelin biosynthesis
AcylCarrProtAsso2	Acyl carrier protein associated with serine palmitoyltransferase
AcylCarrProtPhos	acyl carrier protein phosphodiesterase (EC 3.1.4.14 )
AcylCoa1AcylSnGlyc	Acyl-CoA:1-acyl-sn-glycerol-3-phosphate acyltransferase (EC 2.3.1.51)
AcylCoaDehy2Fadn	Acyl-CoA dehydrogenase 2 [fadN-fadA-fadE operon] (EC 1.3.8.7)
AcylCoaDehyIgrb	Acyl-CoA dehydrogenase IgrB
AcylCoaDehyIgrc	Acyl-CoA dehydrogenase IgrC
AcylCoaDehyIsobCoa	Acyl-CoA dehydrogenase => Isobutyryl-CoA specific (EC 1.3.8.1)
AcylCoaDehyLongChai	Acyl-CoA dehydrogenase, long-chain specific (EC 1.3.8.8)
AcylCoaDehyMediChai	acyl-CoA dehydrogenase, medium-chain specific (EC 1.3.99.3 )
AcylCoaDehyMycoSubg	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE12 in terpen utilization operon (EC 1.3.8.-)
AcylCoaDehyMycoSubg10	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE30 (EC 1.3.8.1)
AcylCoaDehyMycoSubg11	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE27 (EC 1.3.8.1)
AcylCoaDehyMycoSubg12	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE26 (EC 1.3.8.1)
AcylCoaDehyMycoSubg13	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE25 (EC 1.3.8.1)
AcylCoaDehyMycoSubg14	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE21 (EC 1.3.8.1)
AcylCoaDehyMycoSubg15	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE5 (EC 1.3.8.1)
AcylCoaDehyMycoSubg16	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE19 (EC 1.3.8.1)
AcylCoaDehyMycoSubg17	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE23 (EC 1.3.8.1)
AcylCoaDehyMycoSubg18	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE24 (EC 1.3.8.1)
AcylCoaDehyMycoSubg19	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE20 (EC 1.3.8.1)
AcylCoaDehyMycoSubg2	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE9 (EC 1.3.8.1)
AcylCoaDehyMycoSubg20	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE16 (EC 1.3.8.1)
AcylCoaDehyMycoSubg21	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE14 (EC 1.3.8.1)
AcylCoaDehyMycoSubg22	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE2 (EC 1.3.8.1)
AcylCoaDehyMycoSubg23	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE8 (EC 1.3.8.1)
AcylCoaDehyMycoSubg24	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE34 (EC 1.3.8.1)
AcylCoaDehyMycoSubg25	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE6 (EC 1.3.8.1)
AcylCoaDehyMycoSubg26	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE36 (EC 1.3.8.1)
AcylCoaDehyMycoSubg27	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE17 (EC 1.3.8.1)
AcylCoaDehyMycoSubg28	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE22 (EC 1.3.8.1)
AcylCoaDehyMycoSubg29	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE15 (EC 1.3.8.1)
AcylCoaDehyMycoSubg3	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE13 (EC 1.3.8.-)
AcylCoaDehyMycoSubg30	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE18 (EC 1.3.8.1)
AcylCoaDehyMycoSubg31	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE4 (EC 1.3.8.1)
AcylCoaDehyMycoSubg32	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE7 (EC 1.3.8.1)
AcylCoaDehyMycoSubg33	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE10 (EC 1.3.8.1)
AcylCoaDehyMycoSubg34	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE1 (EC 1.3.8.1)
AcylCoaDehyMycoSubg35	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE35 (EC 1.3.8.-)
AcylCoaDehyMycoSubg4	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE3 (EC 1.3.8.1)
AcylCoaDehyMycoSubg5	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE28 (EC 1.3.8.-)
AcylCoaDehyMycoSubg6	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE29 (EC 1.3.8.-)
AcylCoaDehyMycoSubg7	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE33 (EC 1.3.8.1)
AcylCoaDehyMycoSubg8	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE32 (EC 1.3.8.1)
AcylCoaDehyMycoSubg9	Acyl-CoA dehydrogenase, Mycobacterial subgroup FadE31 (EC 1.3.8.1)
AcylCoaDehyPa49n1	Acyl-CoA dehydrogenase PA4979
AcylCoaDehyShorChai	Acyl-CoA dehydrogenase, short-chain specific (EC 1.3.8.1)
AcylCoaDehyVeryLong	Acyl-CoA dehydrogenase, very-long-chain specific (EC 1.3.8.9)
AcylCoaDepeCeraSynt	Acyl-CoA-dependent ceramide synthase (EC 2.3.1.24)
AcylCoaSyntClusWith	Acyl-CoA synthetase clustered with carnitinyl-CoA dehydratase
AcylCoaThioIi	Acyl-CoA thioesterase II (EC 3.1.2.-)
AcylCoenThioPaad	Acyl-coenzyme A thioesterase PaaD (Pse.pu.) (E. coli PaaI)
AcylFamiProtAsso	Acyltransferase family protein associated with ethylmalonyl-CoA pathway
AcylHomoLactAcyl	Acyl-homoserine lactone acylase PvdQ, quorum-quenching (EC 3.5.1.-)
AcylHomoLactSynt	Acyl-homoserine-lactone synthase LuxI (EC 2.3.1.184)
AcylHomoLactSynt3	Acyl-homoserine-lactone synthase YpeI (EC 2.3.1.184)
AcylPhosGlyc3Phos	Acyl-phosphate:glycerol-3-phosphate O-acyltransferase PlsY (EC 2.3.1.n3)
AcylPhosPuta	Acylphosphate phosphohydrolase, putative (EC 3.6.1.7)
AdaReguProt	ADA regulatory protein (EC 2.1.1.63 )
Aden	Adenosylhomocysteinase (EC 3.3.1.1)
Aden8Amin7OxonAmin	Adenosylmethionine-8-amino-7-oxononanoate aminotransferase (EC 2.6.1.62)
AdenCompNrps	adenylation component of NRPS
AdenCycl	Adenylate cyclase (EC 4.6.1.1)
AdenDeam	Adenosine deaminase (EC 3.5.4.4)
AdenKina2	Adenosylcobinamide kinase (EC 2.7.1.156)
AdenKina3	Adenylylsulfate kinase (EC 2.7.1.25)
AdenKinaIsoe6Homo	Adenylate kinase isoenzyme 6 homolog FAP7, plays role in rRNA maturation
AdenLyas	Adenylosuccinate lyase (EC 4.3.2.2)
AdenPentAdenPyro	Adenosine (5')-pentaphospho-(5'')-adenosine pyrophosphohydrolase (EC 3.6.1.-)
AdenPhos	Adenine phosphoribosyltransferase (EC 2.4.2.7)
AdenPhosGuan	Adenosylcobinamide-phosphate guanylyltransferase (EC 2.7.7.62)
AdenPhosSynt	Adenosylcobinamide-phosphate synthase (EC 6.3.1.10)
AdenReduAlphSubu	Adenylylsulfate reductase alpha-subunit (EC 1.8.99.2)
AdenReduBetaSubu	Adenylylsulfate reductase beta-subunit (EC 1.8.99.2)
AdenReduMembAnch	Adenylylsulfate reductase membrane anchor
AdenSulfReduThio	Adenylyl-sulfate reductase [thioredoxin] (EC 1.8.4.10)
AdenSynt	Adenylosuccinate synthetase (EC 6.3.4.4)
AdenThiaTripHydr	Adenosine thiamine-triphosphate hydrolase (postulated)
AdheUnknSpecSdrc	Adhesin of unknown specificity SdrC
AdheUnknSpecSdrd	Adhesin of unknown specificity SdrD
AdheUnknSpecSdre	Adhesin of unknown specificity SdrE, similar to bone sialoprotein-binding protein Bbp
AdpCompHydrNude	ADP compounds hydrolase NudE (EC 3.6.1.-)
AdpDepeGluc	ADP-dependent glucokinase (EC 2.7.1.147)
AdpDepeNadHHydrDehy	ADP-dependent (S)-NAD(P)H-hydrate dehydratase (EC 4.2.1.136)
AdpDepePhos	ADP-dependent phosphofructokinase (EC 2.7.1.146)
AdpHeptLipoHeptIi	ADP-heptose--lipooligosaccharide heptosyltransferase II (EC 2.4.1.-)
AdpHeptSynt	ADP-heptose synthase (EC 2.7.-.-)
AdpLGlycDMannHept	ADP-L-glycero-D-manno-heptose-6-epimerase (EC 5.1.3.20)
AdpRibo1PhosPhop2	ADP-ribose 1"-phosphate phophatase
AdpRiboPyro	ADP-ribose pyrophosphatase (EC 3.6.1.13)
AdpRiboPyroCog1Fami	ADP-ribose pyrophosphatase of COG1058 family (EC 3.6.1.13)
AdpRiboPyroMitoPrec	ADP-ribose pyrophosphatase, mitochondrial precursor (EC 3.6.1.13)
AeroC4DicaTranFor	Aerobic C4-dicarboxylate transporter for fumarate, L-malate, D-malate, succunate
AeroCobaCobnSubu	Aerobic cobaltochelatase CobN subunit (EC 6.6.1.2)
AeroCobaCobsSubu	Aerobic cobaltochelatase CobS subunit (EC 6.6.1.2)
AeroCobaCobtSubu	Aerobic cobaltochelatase CobT subunit (EC 6.6.1.2)
AeroGlyc3PhosDehy	Aerobic glycerol-3-phosphate dehydrogenase (EC 1.1.5.3)
AeroRespContProt	Aerobic respiration control protein arcA
AeroRespContSens	Aerobic respiration control sensor protein arcB (EC 2.7.3.-)
AeroSideReceIuta	Aerobactin siderophore receptor IutA
AeroSyntAeroBios	Aerobactin synthase, aerobactin biosynthesis protein IucC (EC 6.3.2.39)
AggrSubsAsa1Prgb	Aggregation substance Asa1/PrgB
Agma	Agmatinase (EC 3.5.3.11)
AgmaDeim	Agmatine deiminase (EC 3.5.3.12)
AgmaPutrAntiAsso	Agmatine/putrescine antiporter, associated with agmatine catabolism
AisProt	Ais protein
AlanDehy	Alanine dehydrogenase (EC 1.4.1.1)
AlanHydrPeri	Alanylphosphatidylglycerol hydrolase, periplasmic
AlanRace	Alanine racemase (EC 5.1.1.1)
AlanSynt	Alanylphosphatidylglycerol synthase (EC 2.3.2.11)
AlanTrnaSynt	Alanyl-tRNA synthetase (EC 6.1.1.7)
AlanTrnaSyntAmin	Alanyl-tRNA synthetase, amino-terminal half (EC 6.1.1.7)
AlanTrnaSyntCarb	Alanyl-tRNA synthetase, carboxy-terminal half (EC 6.1.1.7)
AlanTrnaSyntChlo	Alanyl-tRNA synthetase, chloroplast (EC 6.1.1.7)
AlanTrnaSyntDoma	Alanyl-tRNA synthetase domain protein
AlanTrnaSyntFami	Alanyl-tRNA synthetase family protein
AlanTrnaSyntMito	Alanyl-tRNA synthetase, mitochondrial (EC 6.1.1.7)
AlcoDehy	Alcohol dehydrogenase (EC 1.1.1.1)
AlcoDehyGbsbEsse	Alcohol dehydrogenase GbsB (type III ), essential for the utilization of choline (EC 1.1.1.1)
AlcoDehyZincCont2	alcohol dehydrogenase, zinc-containing (EC 1.1.1.1 )
AldeDeca	Aldehyde decarbonylase (EC 4.1.99.5)
AldeDehy	Aldehyde dehydrogenase (EC 1.2.1.3)
AldeDehy2	Aldehyde dehydrogenase A (EC 1.2.1.22)
AldeDehy4HydrCata	Aldehyde dehydrogenase in 4-hydroxyproline catabolic gene cluster (EC 1.2.1.3)
AldeDehyB	Aldehyde dehydrogenase B (EC 1.2.1.22)
AldeDehyHypoActi	Aldehyde dehydrogenase in hypothetical Actinobacterial gene cluster
AldeDehyPaaz	Aldehyde dehydrogenase, PaaZ (EC 1.2.1.3)
Aldo1Epim	Aldose 1-epimerase (EC 5.1.3.3)
AlgiBiosTwoCompSyst	Alginate biosynthesis two-component system sensor histidine kinase KinB
AlgiBiosTwoCompSyst2	Alginate biosynthesis two-component system response regulator AlgB
AlgiBiosTwoCompSyst3	Alginate biosynthesis two-component system response regulator AlgR
AlgiBiosTwoCompSyst4	Alginate biosynthesis two-component system sensor histidine kinase AlgZ/FimS
AlgiExpoSystAlgk	Alginate export system Algk/AlgE, outer membrane porin AlgE
AlgiExpoSystAlgk2	Alginate export system AlgK/AlgE, periplasmic component AlgK
AlgiLyasAlgl	Alginate lyase AlgL (EC 4.2.2.3)
AlgiOAcetAlgfPeri	Alginate O-acetyltransferase AlgF, periplasmic
AlgiOAcetAlgjInne	Alginate O-acetyltransferase AlgJ, inner membrane
AlgiOAcetAlgxPeri	Alginate O-acetyltransferase AlgX, periplasmic
AlgiPolyGlycAlg8n1	Alginate polymerase/glycosyltransferase Alg8
AlgiPolyProtAlg4n1	Alginate polymerisation protein Alg44, membrane fusion protein
AlgiReguProtAlgp2	Alginate regulatory protein AlgP, positive transcriptional regulator of AlgD
AlgiReguProtAlgq2	Alginate regulatory protein AlgQ, positive transcriptional regulator of AlgD
AlipAmidAmie	Aliphatic amidase AmiE (EC 3.5.1.4)
Alka1OlDehyPqqDepe	Alkan-1-ol dehydrogenase, PQQ-dependent (EC 1.1.99.20)
AlkaPhos	Alkaline phosphatase (EC 3.1.3.1)
AlkaPhosSyntTran	Alkaline phosphatase synthesis transcriptional regulatory protein PhoP
AlkaProtInhiPrec	Alkaline proteinase inhibitor precursor
AlkyDnaRepaProtAlkb	Alkylated DNA repair protein AlkB
AlkyHydrReduProt	Alkyl hydroperoxide reductase protein C (EC 1.11.1.15)
AlkyHydrReduProt2	Alkyl hydroperoxide reductase protein F (EC 1.6.4.-)
AlkyProtD	Alkylhydroperoxidase protein D
Alla	Allantoinase (EC 3.5.2.5)
Alla2	Allantoicase (EC 3.5.3.4)
AllaAmid	Allantoate amidohydrolase (EC 3.5.3.9)
AllaPerm	Allantoin permease
AllaRace	Allantoin racemase (EC 5.1.99.3)
AlloHydr	Allophanate hydrolase (EC 3.5.1.54)
AlloHydr2Subu1n1	Allophanate hydrolase 2 subunit 1 (EC 3.5.1.54)
AlloHydr2Subu2n1	Allophanate hydrolase 2 subunit 2 (EC 3.5.1.54)
Alph14DigaAbcTran	Alpha-1,4-digalacturonate ABC transporter, permease protein 2
Alph14DigaAbcTran2	Alpha-1,4-digalacturonate ABC transporter, substrate-binding protein
Alph14DigaAbcTran3	Alpha-1,4-digalacturonate ABC transporter, permease protein 1
AlphAcetDeca	Alpha-acetolactate decarboxylase (EC 4.1.1.5)
AlphAminAmin	Alpha-aminoadipate aminotransferase (EC 2.6.1.39)
AlphAminLyswLiga	Alpha-aminoadipate--LysW ligase (EC 6.3.2.n4)
AlphAmyl	Alpha-amylase (EC 3.2.1.1)
AlphAspaDipePept	Alpha-aspartyl dipeptidase Peptidase E (EC 3.4.13.21)
AlphDRibo1Meth5Phos	Alpha-D-ribose 1-methylphosphonate 5-phosphate C-P lyase (EC 4.7.1.1)
AlphGala	Alpha-galactosidase (EC 3.2.1.22)
AlphGluc	Alpha-glucosidase (EC 3.2.1.20)
AlphGluc2	Alpha-glucuronidase (EC 3.2.1.139)
AlphGlucFami31Glyc	Alpha-glucosidase, family 31 of glycosyl hydrolases, COG1501
AlphGlycOxid	Alpha-glycerophosphate oxidase (EC 1.1.3.21)
AlphKetoDepeTaur	Alpha-ketoglutarate-dependent taurine dioxygenase (EC 1.14.11.17)
AlphLFuco	Alpha-L-fucosidase (EC 3.2.1.51)
AlphMann	Alpha-mannosidase (EC 3.2.1.24)
AlphRiba5PhosPhos	Alpha-ribazole-5'-phosphate phosphatase (EC 3.1.3.73)
AlphRiba5PhosPhos4	alpha-ribazole-5'-phosphate phosphatase CobZ (EC 3.1.3.73)
AlteCytoCOxidPoly	Alternative cytochrome c oxidase polypeptide CoxP (EC 1.9.3.1)
AlteCytoCOxidPoly2	Alternative cytochrome c oxidase polypeptide CoxN (EC 1.9.3.1)
AlteCytoCOxidPoly3	Alternative cytochrome c oxidase polypeptide CoxM (EC 1.9.3.1)
AlteCytoCOxidPoly4	Alternative cytochrome c oxidase polypeptide CoxO (EC 1.9.3.1)
AlteDihyRedu2n1	Alternative dihydrofolate reductase 2
AlteDihyRedu3n1	Alternative dihydrofolate reductase 3
AlteFolySynt	Alternative Folylglutamate Synthase
AltePhotIReacCent	alternative photosystem I reaction center subunit X (PsaK2)
AlteRnaPolySigmFact	Alternative RNA polymerase sigma factor SigE
AltrDehy	Altronate dehydratase (EC 4.2.1.7)
AltrOxid	Altronate oxidoreductase (EC 1.1.1.58)
Amid2	Amidophosphoribosyltransferase (EC 2.4.2.14)
AmidClusWithPyru	Amidohydrolase clustered with pyruvate formate-lyase
AmidClusWithUrea	Amidase clustered with urea ABC transporter and nitrile hydratase functions
AmidEgtc	Amidohydrolase EgtC (hercynylcysteine sulfoxide synthase)
AmidRelaNico	Amidases related to nicotinamidase
AmidSyntCompBruc	Amide synthase component of [brucebactin] siderophore synthetase
AmidSyntCompSide	Amide synthase component of siderophore synthetase
AmidYlmbInvoSalv	Amidohydrolase YlmB, involved in salvage of thiamin pyrimidine moiety
Amin	Aminomethyltransferase (glycine cleavage system T protein) (EC 2.1.2.10)
Amin3Phos	Aminoglycoside 3'-phosphotransferase (EC 2.7.1.95)
Amin3Phos2n1	Aminoglycoside 3'-phosphotransferase 2 (EC 2.7.1.95)
Amin6Aden	Aminoglycoside 6-adenylyltransferase (EC 2.7.7.-)
AminAcidBindAct	Amino acid-binding ACT
AminAcidKinaLike	Amino acid kinase-like protein, possibly delta 1-pyrroline-5-carboxylate synthetase
AminAcidMetaPerm	Amino acid/metabolite permease in hypothetical Actinobacterial gene cluster
AminAcidPerm	Amino acid permease
AminAcidPermHypo	Amino acid permease in hypothetical Actinobacterial gene cluster
AminAcidRaceRacx	Amino acid racemase RacX
AminAnthBios	Aminotransferase, anthrose biosynthesis
AminB	Aminopeptidase B (Arg) (EC 3.4.11.6)
AminC	Aminopeptidase C (EC 3.4.22.40)
AminClasIv	aminotransferase, class IV (EC 4.1.3.38 )
AminDeam	Aminodeoxyfutalosine deaminase (EC 3.5.4.40)
AminDehy2	Aminoquinoate dehydrogenase
AminEfflSystAcra	Aminoglycosides efflux system AcrAD-TolC, inner-membrane proton/drug antiporter AcrD (RND type)
AminGlutTranProt	Aminobenzoyl-glutamate transport protein
AminInvoDmspBrea	Aminotransferase involved in DMSP breakdown
AminLyas	Aminodeoxychorismate lyase (EC 4.1.3.38)
AminN6Acet	Aminoglycoside N6'-acetyltransferase (EC 2.3.1.82)
AminNucl	Aminodeoxyfutalosine nucleosidase (EC 3.2.2.30)
AminS	Aminopeptidase S (Leu, Val, Phe, Tyr preference) (EC 3.4.11.24)
AminSynt	Aminodeoxyfutalosine synthase (EC 2.5.1.120)
AminTermInteMedi	Amino-terminal intein-mediated trans-splice
AminTrnaEditEnzy	Aminoacyl-tRNA editing enzyme ProX
AminY	Aminopeptidase Y (Arg, Lys, Leu preference) (EC 3.4.11.15)
AminYpdf	Aminopeptidase YpdF (MP-, MA-, MS-, AP-, NP- specific)
AmmoMono	ammonia monooxygenase (EC 1.14.99.39)
AmpBindEnzyAssoWith	AMP-binding enzyme, associated with serine palmitoyltransferase
AmpDepeSyntLigaAlka	AMP-dependent synthetase/ligase in alkane synthesis cluster
AmpNucl	AMP nucleosidase (EC 3.2.2.4)
AmpPhos2	AMP phosphorylase (EC 2.4.2.57)
AnaeDehyTypiSele	Anaerobic dehydrogenases, typically selenocysteine-containing
AnaeDimeSulfRedu2	Anaerobic dimethyl sulfoxide reductase chain B, iron-sulfur binding subunit (EC 1.8.5.3)
AnaeDimeSulfRedu3	Anaerobic dimethyl sulfoxide reductase chain A, molybdopterin-binding domain (EC 1.8.5.3)
AnaeGlyc3PhosDehy	Anaerobic glycerol-3-phosphate dehydrogenase subunit A (EC 1.1.5.3)
AnaeGlyc3PhosDehy2	Anaerobic glycerol-3-phosphate dehydrogenase subunit B (EC 1.1.5.3)
AnaeGlyc3PhosDehy3	Anaerobic glycerol-3-phosphate dehydrogenase subunit C (EC 1.1.5.3)
AnaeRespCompProt	Anaerobic respiratory complex protein QmoC
AnaeRespCompProt2	Anaerobic respiratory complex protein QmoB
AnaeRespCompProt3	Anaerobic respiratory complex protein QmoA
AnfoProtRequForMo	AnfO protein, required for Mo- and V-independent nitrogenase
AnfrProtRequForMo	AnfR protein, required for Mo- and V-independent nitrogenase
AnioPermArsbNhad	Anion permease ArsB/NhaD-like
AnthBiosProtAsba	Anthrachelin biosynthesis protein AsbA
AnthBiosProtAsbb	Anthrachelin biosynthesis protein AsbB
AnthLethFactEndo	Anthrax lethal factor endopeptidase (EC 3.4.24.83)
AnthPhos	Anthranilate phosphoribosyltransferase (EC 2.4.2.18)
AnthPhosLike	Anthranilate phosphoribosyltransferase like (EC 2.4.2.18)
AnthSyntAmidComp	Anthranilate synthase, amidotransferase component (EC 4.1.3.27)
AnthSyntAmidComp2	Anthranilate synthase, amidotransferase component [PQS biosynthesis] (EC 4.1.3.27)
AnthSyntAminComp	Anthranilate synthase, aminase component (EC 4.1.3.27)
AnthSyntAminComp2	Anthranilate synthase, aminase component [PQS biosynthesis] (EC 4.1.3.27)
Anti1a	Antitoxin 1a
Anti1n1	Antitoxin 1
AntiBactA118n1	Antirepressor [Bacteriophage A118]
AntiBiosMonoDoma	Antibiotic biosynthesis monooxygenase domain-containing protein
AntiDinj	Antitoxin DinJ (binds YafQ toxin)
AntiHiga	Antitoxin HigA
AntiLikeProtLrga	Antiholin-like protein LrgA
AntiPlsBindSquaNasa	Antiadhesin Pls, binding to squamous nasal epithelial cells
AntiReleLikeTran	Antitoxin to RelE-like translational repressor toxin
AntiRna	antisense RNA
AntiSaBact11Mu50n1	Antirepressor [SA bacteriophages 11, Mu50B]
AntiSigmBFactAnta	Anti-sigma B factor antagonist RsbV
AntiSigmBFactRsbt	Anti-sigma B factor RsbT
AntiSigmFFact	Anti-sigma F factor (EC 2.7.11.1)
AntiSigmFFactAnta	Anti-sigma F factor antagonist
AntiSigmFactRsea	Anti-sigma factor RseA
AntiTranSensFpvr	Antisigma transmembrane sensor FpvR
ApagProt	ApaG protein
ApoArylCarrDomaEntb	Apo-aryl carrier domain of EntB
ApolNAcyl	Apolipoprotein N-acyltransferase (EC 2.3.1.-)
ApolNAcylLipiLink	Apolipoprotein N-acyltransferase in lipid-linked oligosaccharide synthesis cluster (EC 2.3.1.-)
AquaZ	Aquaporin Z
ArabAfta	Arabinofuranosyltransferase AftA (EC 2.4.2.46)
ArabSensProt	Arabinose sensor protein
Arch	Archease
ArchKae1ProtHomo	archaeal Kae1 protein homolog
ArchPhosSynt	Archaetidylinositol phosphate synthase (EC 2.7.8.39)
ArchSeryTrnaSynt	Archaeal seryl-tRNA synthetase-related sequence
ArchSuccCoaLigaAdp	Archaeal succinyl-CoA ligase [ADP-forming] beta chain (EC 6.2.1.5)
ArchSuccCoaLigaAdp2	Archaeal succinyl-CoA ligase [ADP-forming] alpha chain (EC 6.2.1.5)
ArchSynt2	Archaeosine synthase (EC 2.6.1.97)
ArchSyntGlutAmid	Archaeosine synthase, glutamine amidotransferases type
ArchSyntPreqRedu	Archaeosine synthase, preQ0 reductase-like
ArchSyntShor	Archaeosine synthase, short (EC 2.6.1.97)
ArchTranFactE	Archaeal transcription factor E
ArchTypeHAtpaSubu	Archaeal-type H+-ATPase subunit H
ArchVacuTypeHAtpa	Archaeal/vacuolar-type H+-ATPase subunit H
Argi	Arginase (EC 3.5.3.1)
ArgiAgmaAnti	Arginine/agmatine antiporter
ArgiBetaLactSynt	(Carboxyethyl)arginine beta-lactam-synthase (EC 6.3.3.4)
ArgiDeca	Arginine decarboxylase (EC 4.1.1.19)
ArgiDecaCata	Arginine decarboxylase, catabolic (EC 4.1.1.19)
ArgiLyas	Argininosuccinate lyase (EC 4.3.2.1)
ArgiOrniAnti	Arginine/ornithine antiporter
ArgiOrniAntiArcd	Arginine/ornithine antiporter ArcD
ArgiRace	Arginine racemase (EC 5.1.1.9)
ArgiSynt	Argininosuccinate synthase (EC 6.3.4.5)
ArgiTrnaProtTran	Arginyl-tRNA--protein transferase (EC 2.3.2.8)
ArgiTrnaSynt	Arginyl-tRNA synthetase (EC 6.1.1.19)
ArgiTrnaSyntChlo	Arginyl-tRNA synthetase, chloroplast (EC 6.1.1.19)
ArgiTrnaSyntMito	Arginyl-tRNA synthetase, mitochondrial (EC 6.1.1.19)
ArgiTrnaSyntRela	Arginyl-tRNA synthetase-related protein
ArgiTrnaSyntRela2	Arginyl-tRNA synthetase related protein 1
ArgiTrnaSyntRela3	Arginyl-tRNA synthetase related protein 2
ArogDehy	Arogenate dehydrogenase (EC 1.3.1.43)
ArogDehy2	Arogenate dehydratase (EC 4.2.1.91)
AromAminAcidAmin2	Aromatic amino acid aminotransferase gamma (EC 2.6.1.57)
AromAminOxidFlav	Aromatic amine oxidase, flavin-containing
AromPren1UbiaFami	Aromatic prenyltransferase 1, UbiA family
AromProt	AroM protein
ArseDepeTranRepr	Arsenite-dependent transcriptional repressor
ArseEfflPumpProt	Arsenic efflux pump protein
ArsePumpDrivAtpa	Arsenical pump-driving ATPase (EC 3.6.3.16)
ArseRedu	Arsenate reductase (EC 1.20.4.1)
ArseResiOperRepr	Arsenical resistance operon repressor
ArseResiOperTran	Arsenical resistance operon trans-acting repressor ArsD
ArseResiProtAcr3n1	Arsenical-resistance protein ACR3
ArseResiProtArsh	Arsenic resistance protein ArsH
Aryl	Arylsulfatase (EC 3.1.6.1)
AscoSpecPtsSystEiia	Ascorbate-specific PTS system, EIIA component (EC 2.7.1.-)
AscoSpecPtsSystEiib	Ascorbate-specific PTS system, EIIB component (EC 2.7.1.69)
AscoSpecPtsSystEiic	Ascorbate-specific PTS system, EIIC component
AscoUtilTranRegu	Ascorbate utilization transcriptional regulator UlaR, HTH-type
AspTrnaGluTrnaAmid	Asp-tRNAAsn/Glu-tRNAGln amidotransferase A subunit and related amidases
AspXDipe	Asp-X dipeptidase
Aspa	Aspartokinase (EC 2.7.2.4)
Aspa1Deca	Aspartate 1-decarboxylase (EC 4.1.1.11)
AspaAmin	Aspartate aminotransferase (EC 2.6.1.1)
AspaAmmoLiga	Aspartate--ammonia ligase (EC 6.3.1.1)
AspaAmmoLyas	Aspartate ammonia-lyase (EC 4.3.1.1)
AspaAssoWithEcto	Aspartokinase associated with ectoine biosynthesis (EC 2.7.2.4)
AspaCarb	Aspartate carbamoyltransferase (EC 2.1.3.2)
AspaCarbReguChai	Aspartate carbamoyltransferase regulatory chain (PyrI)
AspaOrniCarbFami	Aspartate/ornithine carbamoyltransferase family protein protein YgeW
AspaProtSymp	Aspartate-proton symporter
AspaRace	Aspartate racemase (EC 5.1.1.13)
AspaSemiDehy	Aspartate-semialdehyde dehydrogenase (EC 1.2.1.11)
AspaSemiDehyDoec	Aspartate-semialdehyde dehydrogenase DoeC in ectoine degradation (EC 1.2.1.-)
AspaSyntGlutHydr	Asparagine synthetase [glutamine-hydrolyzing] (EC 6.3.5.4)
AspaSyntGlutHydr2	Asparagine synthetase [glutamine-hydrolyzing] AsnB (EC 6.3.5.4)
AspaSyntGlutHydr3	Asparagine synthetase [glutamine-hydrolyzing] AsnH (EC 6.3.5.4)
AspaSyntGlutHydr5	Asparagine synthetase [glutamine-hydrolyzing] YisO (EC 6.3.5.4)
AspaTrnaAmidSubu	Aspartyl-tRNA(Asn) amidotransferase subunit C (EC 6.3.5.6)
AspaTrnaAmidSubu2	Aspartyl-tRNA(Asn) amidotransferase subunit A (EC 6.3.5.6)
AspaTrnaAmidSubu3	Aspartyl-tRNA(Asn) amidotransferase subunit B (EC 6.3.5.6)
AspaTrnaSynt	Aspartyl-tRNA synthetase (EC 6.1.1.12)
AspaTrnaSynt2	Asparaginyl-tRNA synthetase (EC 6.1.1.22)
AspaTrnaSynt3	Aspartyl-tRNA(Asn) synthetase (EC 6.1.1.23)
AspaTrnaSyntChlo	Asparaginyl-tRNA synthetase, chloroplast (EC 6.1.1.22)
AspaTrnaSyntChol	Aspartyl-tRNA synthetase, choloroplast (EC 6.1.1.12)
AspaTrnaSyntMito	Asparaginyl-tRNA synthetase, mitochondrial (EC 6.1.1.22)
AspaTrnaSyntMito2	Aspartyl-tRNA synthetase, mitochondrial (EC 6.1.1.12)
AspaTyroAromAmin	Aspartate/tyrosine/aromatic aminotransferase (EC 2.6.1.1 )
AtpBindProtManx	ATP-binding protein ManX
AtpBindProtP271n1	ATP-binding protein p271
AtpCitrLyas	ATP-citrate (pro-S-) -lyase (EC 2.3.3.8)
AtpCitrLyas2	ATP-citrate (pro-S-)-lyase (EC 2.3.3.8)
AtpCitrLyasSubu2n1	ATP-citrate (pro-S-)-lyase, subunit 2 (EC 2.3.3.8)
AtpCobAlamAden	ATP:Cob(I)alamin adenosyltransferase (EC 2.5.1.17)
AtpCobAlamAdenClus	ATP:Cob(I)alamin adenosyltransferase, clustered with pyruvate formate-lyase (EC 2.5.1.17)
AtpCobAlamAdenCoba	ATP:Cob(I)alamin adenosyltransferase, cobalamin synthesis (EC 2.5.1.17)
AtpCobAlamAdenEtha	ATP:Cob(I)alamin adenosyltransferase, ethanolamine utilization (EC 2.5.1.17)
AtpCobAlamAdenGlyc	ATP:Cob(I)alamin adenosyltransferase, glycolate utilization (EC 2.5.1.17)
AtpCobAlamAdenGlyc2	ATP:Cob(I)alamin adenosyltransferase, glycerol fermentation (EC 2.5.1.17)
AtpCobAlamAdenProp	ATP:Cob(I)alamin adenosyltransferase, propanediol utilization (EC 2.5.1.17)
AtpDepe35DnaHeli	ATP-dependent, 3'-5' DNA helicase with strand annealing activity
AtpDepeCarbAminLiga5	ATP-dependent carboxylate-amine ligase, similarity to cyanophycin synthetase
AtpDepeClpProtAdap	ATP-dependent Clp protease adaptor protein ClpS
AtpDepeClpProtAdap2	ATP-dependent Clp protease adaptor protein ClpS Cyano2
AtpDepeClpProtAtp	ATP-dependent Clp protease ATP-binding subunit ClpX
AtpDepeClpProtAtp3	ATP-dependent Clp protease ATP-binding subunit ClpA
AtpDepeClpProtProt	ATP-dependent Clp protease proteolytic subunit (EC 3.4.21.92)
AtpDepeDnaHeliPcra	ATP-dependent DNA helicase pcrA (EC 3.6.1.-)
AtpDepeDnaHeliRecg	ATP-dependent DNA helicase RecG (EC 3.6.1.-)
AtpDepeDnaHeliRecq	ATP-dependent DNA helicase recQ (EC 3.6.1.- )
AtpDepeDnaHeliRecq2	ATP-dependent DNA helicase, RecQ family
AtpDepeDnaHeliRep	ATP-dependent DNA helicase rep (EC 3.6.1.-)
AtpDepeDnaHeliSco5n1	ATP-dependent DNA helicase SCO5183
AtpDepeDnaHeliSco5n2	ATP-dependent DNA helicase SCO5184
AtpDepeDnaHeliUvrd	ATP-dependent DNA helicase UvrD/PcrA (EC 3.6.4.12)
AtpDepeDnaHeliUvrd10	ATP-dependent DNA helicase UvrD/PcrA/Rep, epsilon proteobacterial type 1
AtpDepeDnaHeliUvrd11	ATP-dependent DNA helicase UvrD/PcrA/Rep
AtpDepeDnaHeliUvrd13	ATP-dependent DNA helicase UvrD/PcrA/Rep family, Francisella type
AtpDepeDnaHeliUvrd2	ATP-dependent DNA helicase UvrD/PcrA, actinomycete paralog
AtpDepeDnaHeliUvrd3	ATP-dependent DNA helicase UvrD/PcrA/Rep, cyanobacterial paralog
AtpDepeDnaHeliUvrd4	ATP-dependent DNA helicase UvrD/PcrA, clostridial paralog
AtpDepeDnaHeliUvrd5	ATP-dependent DNA helicase UvrD/PcrA, clostridial paralog 2
AtpDepeDnaHeliUvrd7	ATP-dependent DNA helicase UvrD/PcrA, proteobacterial paralog
AtpDepeDnaHeliUvrd8	ATP-dependent DNA helicase UvrD/PcrA-like protein
AtpDepeDnaHeliUvrd9	ATP-dependent DNA helicase UvrD/PcrA/Rep, epsilon proteobacterial type 2
AtpDepeDnaLiga	ATP-dependent DNA ligase (EC 6.5.1.1)
AtpDepeDnaLigaClus	ATP-dependent DNA ligase clustered with Ku protein, LigD (EC 6.5.1.1)
AtpDepeDnaLigaHomo	ATP-dependent DNA ligase, homolog of eukaryotic ligase III
AtpDepeDnaLigaLigc	ATP-dependent DNA ligase LigC (EC 6.5.1.1)
AtpDepeEfflPumpEsse	ATP-dependent efflux pump essential for phthiocerol dimycocerosates translocation, integral membrane protein DrrC-like
AtpDepeEfflPumpEsse2	ATP-dependent efflux pump essential for phthiocerol dimycocerosates translocation, integral membrane protein DrrB-like
AtpDepeEfflPumpEsse3	ATP-dependent efflux pump essential for phthiocerol dimycocerosates translocation, ATP-binding protein DrrA-like
AtpDepeHeliDeadDeah	ATP-dependent helicase, DEAD/DEAH box family, associated with Flp pilus assembly
AtpDepeHeliDingRad3n1	ATP-dependent helicase DinG/Rad3
AtpDepeHslProtAtp	ATP-dependent hsl protease ATP-binding subunit HslU
AtpDepeNadHHydrDehy	ATP-dependent (S)-NAD(P)H-hydrate dehydratase (EC 4.2.1.93)
AtpDepeNuclSubu	ATP-dependent nuclease, subunit A
AtpDepeNuclSubuB	ATP-dependent nuclease, subunit B
AtpDepeProtLaLonb	ATP-dependent protease La LonB Type I (EC 3.4.21.53)
AtpDepeProtLaType	ATP-dependent protease La Type II (EC 3.4.21.53)
AtpDepeProtLaType2	ATP-dependent protease La Type I (EC 3.4.21.53)
AtpDepeProtLonbLike	ATP-dependent protease LonB-like Type I
AtpDepeProtLonbType	ATP-dependent protease LonB Type II
AtpDepeProtSubuHslv	ATP-dependent protease subunit HslV (EC 3.4.25.2)
AtpDepeRnaHeliAtu1n1	ATP-dependent RNA helicase Atu1833
AtpDepeRnaHeliBa24n1	ATP-dependent RNA helicase BA2475
AtpDepeRnaHeliBcep	ATP-dependent RNA helicase Bcep18194_A5658
AtpDepeRnaHeliDbpa	ATP-dependent RNA helicase DbpA
AtpDepeRnaHeliNgo0n1	ATP-dependent RNA helicase NGO0650
AtpDepeRnaHeliPa39n1	ATP-dependent RNA helicase PA3950
AtpDepeRnaHeliRhlb	ATP-dependent RNA helicase rhlB (EC 3.6.1.-)
AtpDepeRnaHeliRhle	ATP-dependent RNA helicase RhlE
AtpDepeRnaHeliSo15n1	ATP-dependent RNA helicase SO1501
AtpDepeRnaHeliSrmb	ATP-dependent RNA helicase SrmB
AtpDepeRnaHeliVc14n1	ATP-dependent RNA helicase VC1407
AtpDepeRnaHeliVca0n1	ATP-dependent RNA helicase VCA0061
AtpDepeRnaHeliVca0n2	ATP-dependent RNA helicase VCA0768
AtpDepeRnaHeliVca0n3	ATP-dependent RNA helicase VCA0990
AtpDepeRnaHeliVf14n1	ATP-dependent RNA helicase VF1437
AtpDepeRnaHeliVva0n1	ATP-dependent RNA helicase VVA0939
AtpDepeRnaHeliYejh	ATP-dependent RNA helicase YejH
AtpDepeRnaHeliYfml	ATP-dependent RNA helicase YfmL
AtpDepeRnaHeliYxin	ATP-dependent RNA helicase YxiN
AtpGrasLigaFormMyco	ATP-grasp ligase forming mycosporine-glycine, MysC
AtpGtpBindSiteMoti	ATP/GTP-binding site motif A
AtpPhos	ATP phosphoribosyltransferase (EC 2.4.2.17)
AtpPhosHisg	ATP phosphoribosyltransferase => HisGl (EC 2.4.2.17)
AtpPhosHisg2	ATP phosphoribosyltransferase => HisGs (EC 2.4.2.17)
AtpPhosReguSubu	ATP phosphoribosyltransferase regulatory subunit (EC 2.4.2.17)
AtpPhosReguSubuDive	ATP phosphoribosyltransferase regulatory subunit, divergent variant (EC 2.4.2.17)
AtpSyntAlphChai	ATP synthase alpha chain (EC 3.6.3.14)
AtpSyntAlphChaiLike	ATP synthase alpha chain-like protein (EC 3.6.3.14)
AtpSyntBetaChai	ATP synthase beta chain (EC 3.6.3.14)
AtpSyntBetaChaiLike	ATP synthase beta chain-like protein (EC 3.6.3.14)
AtpSyntDeltChai	ATP synthase delta chain (EC 3.6.3.14)
AtpSyntEpsiChai	ATP synthase epsilon chain (EC 3.6.3.14)
AtpSyntF0SectSubu	ATP synthase F0 sector subunit a (EC 3.6.3.14)
AtpSyntF0SectSubu2	ATP synthase F0 sector subunit c (EC 3.6.3.14)
AtpSyntF0SectSubu3	ATP synthase F0 sector subunit b (EC 3.6.3.14)
AtpSyntF0SectSubu4	ATP synthase F0 sector subunit b' (EC 3.6.3.14)
AtpSyntGammChai	ATP synthase gamma chain (EC 3.6.3.14)
AtpSyntProtI	ATP synthase protein I (EC 3.6.3.14 )
AtpaAaaSupeRv38n1	ATPase of AAA+ superfamily Rv3888c
AtpaCompAbcTranWith	ATPase components of ABC transporters with duplicated ATPase domains
AtpaCompBiomEner	ATPase component BioM of energizing module of biotin ECF transporter
AtpaCompGeneEner	ATPase component of general energizing module of ECF transporters
AtpaInvoDnaRepaPhag	ATPase involved in DNA repair, phage associated
AtpaRequForBothAsse	ATPase required for both assembly of type IV secretion complex and secretion of T-DNA complex, VirB4
AtpaRequForBothAsse2	ATPase required for both assembly of type IV secretion complex and secretion of T-DNA complex, VirB11
AtpaWithChapActi3	ATPase with chaperone activity, associated with Flp pilus assembly
AtteCompAtteAbcTran	AttE component of AttEFGH ABC transport system
AttfCompAtteAbcTran	AttF component of AttEFGH ABC transport system
AttgCompAtteAbcTran	AttG component of AttEFGH ABC transport system
AtthCompAtteAbcTran	AttH component of AttEFGH ABC transport system
Auto1SensKinaPhos	Autoinducer 1 sensor kinase/phosphatase LuxN (EC 3.1.3.-) (EC 2.7.3.-)
Auto2AbcTranSyst	Autoinducer 2 (AI-2) ABC transport system, periplasmic AI-2 binding protein LsrB
Auto2AbcTranSyst2	Autoinducer 2 (AI-2) ABC transport system, membrane channel protein LsrD
Auto2AbcTranSyst3	Autoinducer 2 (AI-2) ABC transport system, membrane channel protein LsrC
Auto2AbcTranSyst4	Autoinducer 2 (AI-2) ABC transport system, fused AI2 transporter subunits and ATP-binding component
Auto2AldoLsrf	Autoinducer 2 (AI-2) aldolase LsrF (EC 4.2.1.-)
Auto2BindPeriProt	Autoinducer 2-binding periplasmic protein LuxP precursor
Auto2KinaLsrk	Autoinducer 2 (AI-2) kinase LsrK (EC 2.7.1.-)
Auto2ModiProtLsrg	Autoinducer 2 (AI-2) modifying protein LsrG
Auto2ProdProtLuxs	Autoinducer-2 production protein LuxS
Auto2SensKinaPhos	Autoinducer 2 sensor kinase/phosphatase LuxQ (EC 3.1.3.-) (EC 2.7.3.-)
AutoAmid	Autolysin, amidase
AutoHistKinaLyts	Autolysis histidine kinase LytS
AutoRespReguLytr	Autolysis response regulater LytR
AutoSaBact11Mu50n1	Autolysin [SA bacteriophages 11, Mu50B]
Azur	Azurin
B12BindDomaMethCoa	B12 binding domain of Methylmalonyl-CoA mutase (EC 5.4.99.2)
BaciExtrNeutMeta	Bacillolysin, extracellular neutral metalloprotease (EC 3.4.24.28)
BaciSyntCompF	Bacillibactin synthetase component F (EC 2.7.7.-)
Bact	Bacterioferritin (EC 1.16.3.1)
BactAbcTranAtpBind2	Bacteriocin ABC-transporter, ATP-binding and permease component
BactAbcTranAuxiProt	Bacteriocin ABC-transporter, auxillary protein
BactAbcTranPutaComp	Bacteriocin ABC-transporter, putative component
BactAbp118AlphPept	Bacteriocin ABP-118, alpha peptide precursor
BactAbp118BetaPept	Bacteriocin ABP-118, beta peptide precursor
BactAssoFerr	Bacterioferritin-associated ferredoxin
BactCC12MethBchr	Bacteriochlorophyllide c C12 methyltransefase BchR
BactCC8MethBchq	Bacteriochlorophyllide c C8 methyltransefase BchQ
BactChecContDisa	Bacterial checkpoint controller DisA with nucleotide-binding domain
BactGassK7B	Bacteriocin gassericin K7 B
BactGassK7BCompFact	Bacteriocin gassericin K7 B complemental factor, putative
BactGassK7BImmuProt	Bacteriocin gassericin K7 B immunity protein, putative
BactImmuProt	bacteriocin immunity protein
BactImmuProtMemb	Bacteriocin immunity protein (putative), membrane-bound protease CAAX family
BactPrecPeptPlne	bacteriocin precursor peptide PlnE (putative)
BactPrecPeptPlnf	bacteriocin precursor peptide PlnF (putative)
BactPrecPeptPlnj	bacteriocin precursor peptide PlnJ (putative)
BactPrecPeptPlnk	bacteriocin precursor peptide PlnK (putative)
BactPrecPeptPlnn	bacteriocin precursor peptide PlnN (putative)
BactPrepInduFact	Bacteriocin prepeptide or inducing factor for bacteriocin synthesis
BactProdProt	Bacteriocin production protein
BactProtActiAaaAtpa	Bacterial proteasome-activating AAA-ATPase (PAN)
BactResiProt	Bacteriocin resistance protein
BactRiboSsuMatuProt	Bacterial ribosome SSU maturation protein RimP
BaraAssoRespRegu	BarA-associated response regulator UvrY (= GacA = SirA)
BarsRiboInhi	Barstar, ribonuclease (Barnase) inhibitor
Bata2	BatA (Bacteroides aerotolerance operon)
Batb	BatB
Batc	BatC
Batd	BatD
Bate	BatE
BclaProt	BclA protein
BenzCoaDehy	(R)-benzylsuccinyl-CoA dehydrogenase (EC 1.3.99.21)
BenzCoaLiga2	Benzoate--CoA ligase (EC 6.2.1.25)
BenzCoaLiga3	Benzoylacetate CoA-ligase
BenzCoaReduSubu2	Benzoyl-CoA reductase subunit A (EC 1.3.7.8)
BenzCoaReduSubuB	Benzoyl-CoA reductase subunit B (EC 1.3.7.8)
BenzCoaReduSubuC	Benzoyl-CoA reductase subunit C (EC 1.3.7.8)
BenzCoaReduSubuD	Benzoyl-CoA reductase subunit D (EC 1.3.7.8)
BenzCoaThioAlphSubu	Benzoylsuccinyl-CoA thiolase alpha subunit (EC 2.3.1.-)
BenzCoaThioBetaSubu	Benzoylsuccinyl-CoA thiolase beta subunit (EC 2.3.1.-)
BenzDeca	Benzoylformate decarboxylase (EC 4.1.1.7)
BenzSyntActiEnzy	Benzylsuccinate synthase activating enzyme (EC 1.97.1.4)
BenzSyntAlphSubu	Benzylsuccinate synthase alpha subunit (EC 4.1.99.11)
BenzSyntBetaSubu	Benzylsuccinate synthase beta subunit (EC 4.1.99.11)
BenzSyntGammSubu	Benzylsuccinate synthase gamma subunit (EC 4.1.99.11)
BetaAldeDehy	Betaine aldehyde dehydrogenase (EC 1.2.1.8)
BetaCaroKeto	Beta-carotene ketolase (EC 1.14.-.-)
BetaGala	Beta-galactosidase (EC 3.2.1.23)
BetaGalaLargSubu	Beta-galactosidase large subunit (EC 3.2.1.23)
BetaGalaSmalSubu	Beta-galactosidase small subunit (EC 3.2.1.23)
BetaGluc3	Beta-glucuronidase (EC 3.2.1.31)
BetaKetoEnolLact	Beta-ketoadipate enol-lactone hydrolase (EC 3.1.1.24)
BetaLact	Beta-lactamase (EC 3.5.2.6)
BetaLactReguSens	Beta-lactamase regulatory sensor-transducer BlaR1
BetaLactReprBlai	Beta-lactamase repressor BlaI
BetaLytiMeta	Beta-lytic metalloendopeptidase (EC 3.4.24.32)
BetaMethCoaLyas	Beta-methylmalyl-CoA lyase (EC 4.1.3.-)
BetaPeptAmin	beta-peptidyl aminopeptidase (EC 3.4.11.25)
BetaReduCompBAlph	Betaine reductase component B alpha subunit (EC 1.21.4.4)
BetaReduCompBBeta	Betaine reductase component B beta subunit (EC 1.21.4.4)
BetaUrei	Beta-ureidopropionase (EC 3.5.1.6)
BifuAutoAtl	Bifunctional autolysin Atl
BifuBeta1516Gala	Bifunctional beta-1,5/1,6-galactofuranosyltransferase GlfT2 in cell wall galactan polymerization (EC 2.4.1.288)
BifuFefeHydrAlph	Bifurcating [FeFe] hydrogenase, alpha subunit (EC 1.12.1.4)
BifuFefeHydrBeta	Bifurcating [FeFe] hydrogenase, beta subunit (EC 1.12.1.4)
BifuFefeHydrGamm	Bifurcating [FeFe] hydrogenase, gamma subunit (EC 1.12.1.4)
BifuSaliAmpLigaSali2	Bifunctional salicyl-AMP ligase/salicyl-S-MbtB synthetase MbtA
BileAcid7AlphDehy	Bile acid 7-alpha dehydratase BaiE (EC 4.2.1.106)
BileAcylCoaSynt	Bile acyl-CoA synthetase (EC 6.2.1.7)
BiofOperIcaaHthType	Biofilm operon icaABCD HTH-type negative transcriptional regulator IcaR
BiofPgaOuteMembSecr	Biofilm PGA outer membrane secretin PgaA
BiofPgaSyntAuxiProt	Biofilm PGA synthesis auxiliary protein PgaD
BiofPgaSyntAuxiProt2	Biofilm PGA synthesis auxiliary protein, putative
BiofPgaSyntDeacPgab	Biofilm PGA synthesis deacetylase PgaB (EC 3.-)
BiofPgaSyntNGlyc	Biofilm PGA synthesis N-glycosyltransferase PgaC (EC 2.4.-.-)
BiopTranProtExbd	Biopolymer transport protein ExbD/TolR
BiosArgiDeca	Biosynthetic arginine decarboxylase (EC 4.1.1.19)
BiosAromAminAcid	Biosynthetic Aromatic amino acid aminotransferase beta (EC 2.6.1.57)
BiosAromAminAcid2	Biosynthetic Aromatic amino acid aminotransferase alpha (EC 2.6.1.57)
BiotBiosCytoP450n1	biotin biosynthesis cytochrome P450 (EC 1.4.-.-)
BiotCarb	Biotin carboxylase (EC 6.3.4.14)
BiotCarbAcetCoaCarb	Biotin carboxylase of acetyl-CoA carboxylase (EC 6.3.4.14)
BiotCarbCarrProt	Biotin carboxyl carrier protein of acetyl-CoA carboxylase
BiotCarbCarrProt11	biotin carboxyl carrier protein of glutaconyl-CoA decarboxylase (EC 4.1.1.70 )
BiotCarbCarrProt2	Biotin carboxyl carrier protein of methylcrotonyl-CoA carboxylase
BiotCarbCarrProt3	Biotin carboxyl carrier protein
BiotCarbCarrProt4	Biotin carboxyl carrier protein of methylmalonyl-CoA decarboxylase
BiotCarbCarrProt5	Biotin carboxyl carrier protein of methylmalonyl-CoA:Pyruvate transcarboxylase
BiotCarbCarrProt6	Biotin carboxyl carrier protein of oxaloacetate decarboxylase
BiotCarbCarrProt8	Biotin carboxyl carrier protein of Propionyl-CoA carboxylase
BiotCarbMethCoaCarb	Biotin carboxylase of methylcrotonyl-CoA carboxylase (EC 6.3.4.14)
BiotCarbPropCoaCarb	Biotin carboxylase of propionyl-CoA carboxylase (EC 6.3.4.14)
BiotOperRepr	Biotin operon repressor
BiotProtLiga2	Biotin--protein ligase (EC 6.3.4.10)(EC 6.3.4.11)(EC 6.3.4.15) (EC 6.3.4.9)
BiotSynt	Biotin synthase (EC 2.8.1.6)
BiotSyntProtBiok	Biotin synthesis protein bioK
BiotSyntProtBioz	Biotin synthesis protein bioZ
BiotSyntRelaProt	Biotin synthase-related protein, radical SAM superfamily
BipoDnaHeliHera	Bipolar DNA helicase HerA
BisTetr	Bis(5'-nucleosyl)-tetraphosphatase (asymmetrical) (EC 3.6.1.17)
BisTetr2	Bis(5'-nucleosyl)-tetraphosphatase (Ap4A) (Asymmetrical) (EC 3.6.1.17)
BisTetrSymm	Bis(5'-nucleosyl)-tetraphosphatase, symmetrical (EC 3.6.1.41)
BlueLighTempRegu	Blue light- and temperature-regulated antirepressor BluF
BotuNeurTypePrec	Botulinum neurotoxin type A precursor (EC 3.4.24.69)
BoxCDRnaGuidRnaMeth	Box C/D RNA-guided RNA methyltransferase subunit fibrillarin
BoxCDRnaGuidRnaMeth2	Box C/D RNA-guided RNA methyltransferase subunit Nop5
BoxElem	BOX elements
BoxElemTypeAbbc	box element type ABBC
BoxElemTypeAbc	box element type ABC
BoxElemTypeAc	box element type AC
BoxElemTypeCba	box element type CBA
BranChaiAcylCoaDehy	Branched-chain acyl-CoA dehydrogenase (EC 1.3.99.12)
BranChaiAcylKina	Branched-chain acyl kinase (EC 2.7.2.-)
BranChaiAlphKeto	Branched-chain alpha-keto acid dehydrogenase, E1 component, beta subunit (EC 1.2.4.4)
BranChaiAlphKeto2	Branched-chain alpha-keto acid dehydrogenase, E1 component, alpha subunit (EC 1.2.4.4)
BranChaiAminAcid5	Branched-chain amino acid aminotransferase (EC 2.6.1.42)
BranChaiAminAcid9	Branched-chain amino acid dehydrogenase [deaminating] (EC 1.4.1.23) (EC 1.4.1.9)
BranChaiPhos	Branched-chain phosphotransacylase (EC 2.3.1.- )
BroaSpecGlycDehy	Broad-specificity glycerol dehydrogenase, subunit SldA (EC 1.1.99.22)
BroaSpecGlycDehy2	Broad-specificity glycerol dehydrogenase, subunit SldB (EC 1.1.99.22)
BroaSpecMultEffl	Broad-specificity multidrug efflux pump YkkC
BroaSpecMultEffl2	Broad-specificity multidrug efflux pump YkkD
BroaSubsRangPhos	Broad-substrate range phospholipase C (EC 3.1.4.3)
ButyAcetCoaTranSubu	Butyrate-acetoacetate CoA-transferase subunit B (EC 2.8.3.9)
ButyAcetCoaTranSubu2	Butyrate-acetoacetate CoA-transferase subunit A (EC 2.8.3.9)
ButyCoaDehy	Butyryl-CoA dehydrogenase (EC 1.3.8.1)
ButyKina	Butyrate kinase (EC 2.7.2.7)
C3SimiVaniODemeOxyg	C3: similar to Vanillate O-demethylase oxygenase
CDiGmpPhos2	c-di-GMP phosphodiesterase (EC 3.1.4.52)
CDiGmpPhosHemeRegu	c-di-GMP phosphodiesterase => Heme-regulated, oxygen sensor PdeO (EC 3.1.4.52)
CDiGmpPhosMaltBind	c-di-GMP phosphodiesterase => Maltose-binding (PAS-GGDEF-EAL)-containing protein PdeB (EC 3.1.4.52)
CDiGmpPhosMbaaRepr	C-di-GMP phosphodiesterase MbaA, repressor of biofilm formation
CDiGmpPhosPdea	c-di-GMP phosphodiesterase => PdeA (EC 3.1.4.52)
CDiGmpPhosPdeb	c-di-GMP phosphodiesterase => PdeB (EC 3.1.4.52)
CDiGmpPhosPdec	c-di-GMP phosphodiesterase => PdeC (EC 3.1.4.52)
CDiGmpPhosPded	c-di-GMP phosphodiesterase => PdeD (EC 3.1.4.52)
CDiGmpPhosPdef	c-di-GMP phosphodiesterase => PdeF (EC 3.1.4.52)
CDiGmpPhosPdeg	c-di-GMP phosphodiesterase => PdeG (EC 3.1.4.52)
CDiGmpPhosPdeh	c-di-GMP phosphodiesterase => PdeH (EC 3.1.4.52)
CDiGmpPhosPdei	c-di-GMP phosphodiesterase => PdeI (EC 3.1.4.52)
CDiGmpPhosPdel	c-di-GMP phosphodiesterase => PdeL (EC 3.1.4.52)
CDiGmpPhosPden	c-di-GMP phosphodiesterase => PdeN (EC 3.1.4.52)
CDiGmpPhosPder	c-di-GMP phosphodiesterase => PdeR (EC 3.1.4.52)
CTermExteSpecFor	C-terminal extension specific for cyanobacteria
CadmEfflSystAcce	Cadmium efflux system accessory protein
CadmResiProt	Cadmium resistance protein
CadmTranAtpa	Cadmium-transporting ATPase (EC 3.6.3.3)
CalmBindDoma	Calmodulin-binding domain
Cand1DienHydr	Candidate 1: dienelactone hydrolase
CandGeneForHypoPhos2	Candidate gene for the hypothesized phosphomevalonate decarboxylase; COG1355, Predicted dioxygenase
CapsPolyTranAnti	Capsular polysaccharide transcription antitermination protein, UpxY family
CapsPolyTranAnti2	Capsular polysaccharide transcription antitermination protein UpaY
CapsPolyTranAnti3	Capsular polysaccharide transcription antitermination protein UpfY
CapsPolyTranAnti4	Capsular polysaccharide transcription antitermination protein UpbY
CapsPolyTranAnti5	Capsular polysaccharide transcription antitermination protein UpeY
CapsPolyTranAnti6	Capsular polysaccharide transcription antitermination protein UpdY
CapsPolyTranAnti7	Capsular polysaccharide transcription antitermination protein UphY
CapsPolyTranAnti8	Capsular polysaccharide transcription antitermination protein UpgY
CapsPolyTranAnti9	Capsular polysaccharide transcription antitermination protein UpcY
CapsSyntPosiRegu	Capsule synthesis positive regulator AcpA
CapsSyntPosiRegu2	Capsule synthesis positive regulator AcpB
Carb3CarbSynt	Carbapenam-3-carboxylate synthase (EC 6.3.3.6)
CarbAnhy	Carbonic anhydrase (EC 4.2.1.1)
CarbAnhyAlphClas	Carbonic anhydrase, alpha class (EC 4.2.1.1)
CarbAnhyBetaClas	Carbonic anhydrase, beta class (EC 4.2.1.1)
CarbAnhyGammClas	Carbonic anhydrase, gamma class (EC 4.2.1.1)
CarbBindCencDoma2	Carbohydrate-binding, CenC domain protein
CarbBtlbLocu	Carboxylesterase in BtlB locus (EC 3.1.1.1)
CarbDeca	Carboxynorspermidine decarboxylase (EC 4.1.1.96)
CarbDecaPuta	Carboxynorspermidine decarboxylase, putative (EC 4.1.1.-)
CarbDehyPuta	Carboxynorspermidine dehydrogenase, putative (EC 1.1.1.-)
CarbDisuLyas	Carbon disulfide lyase (EC 4.4.1.27)
CarbKina	Carbamate kinase (EC 2.7.2.2)
CarbMonoDehyCoos	Carbon monoxide dehydrogenase CooS subunit (EC 1.2.99.2)
CarbMonoInduHydr	Carbon monoxide-induced hydrogenase proton translocating subunit CooK
CarbMonoInduHydr2	Carbon monoxide-induced hydrogenase membrane protein CooM
CarbMonoInduHydr3	Carbon monoxide-induced hydrogenase small subunit CooL
CarbMonoInduHydr4	Carbon monoxide-induced hydrogenase iron-sulfur protein CooX
CarbMonoInduHydr5	Carbon monoxide-induced hydrogenase large subunit CooH
CarbMonoInduHydr6	Carbon monoxide-induced hydrogenase NuoC-like protein CooU
CarbMonoRespTran	Carbon monoxide-responsive transcriptional activator CooA
CarbPhosSyntLarg	Carbamoyl-phosphate synthase large chain (EC 6.3.5.5)
CarbPhosSyntLarg2	Carbamoyl-phosphate synthase large chain B (EC 6.3.5.5)
CarbPhosSyntLarg3	Carbamoyl-phosphate synthase large chain A (EC 6.3.5.5)
CarbPhosSyntSmal	Carbamoyl-phosphate synthase small chain (EC 6.3.5.5)
CarbSelePoriOprb	Carbohydrate-selective porin OprB
CarbStarProt	Carbon starvation protein A
CarbStorRegu	Carbon storage regulator
CarbSynt	Carboxynorspermidine synthase (EC 1.5.1.43)
CarbTermInteMedi	Carboxy-terminal intein-mediated trans-splice
CarbTermProt	Carboxyl-terminal protease (EC 3.4.21.102)
CardSynt	Cardiolipin synthetase (EC 2.7.8.-)
Carn3Dehy	Carnitine 3-dehydrogenase (EC 1.1.1.108)
CarnCoaDehy	Carnitinyl-CoA dehydratase (EC 4.2.1.-)
CarnCoaLiga	Carnitine--CoA ligase
CarnOperProtCaie	Carnitine operon protein CaiE
CarnOperTranRegu	Carnitine operon transcriptional regulator
CarnUtilAssoThio	Carnitine utilization associated thioesterase
Cary1OlSynt	(+)-caryolan-1-ol synthase (EC 4.2.1.138)
Cata	Catalase (EC 1.11.1.6)
CataCleaPAminGlut	Catalyzes the cleavage of p-aminobenzoyl-glutamate to p-aminobenzoate and glutamate, subunit A
CataCleaPAminGlut2	Catalyzes the cleavage of p-aminobenzoyl-glutamate to p-aminobenzoate and glutamate, subunit B
CataHpii	Catalase HPII (EC 1.11.1.6)
CataKate	Catalase KatE (EC 1.11.1.6)
CataLikeHemeBind	Catalase-like heme-binding protein
CataPeroKatg	Catalase-peroxidase KatG (EC 1.11.1.21)
CateSideAbcTranAtp	Catechol siderophore ABC transporter, ATP-binding component
CateSideAbcTranPerm	Catechol siderophore ABC transporter, permease component
CateSideAbcTranSubs	Catechol siderophore ABC transporter, substrate-binding protein
CatiTranAtpaE1E2n1	Cation-transporting ATPase, E1-E2 family
CblyNonOrthDispFor	CblY, a non-orthologous displacement for alpha-ribazole-5'-phosphate phosphatase
CbsDoma	CBS domain (EC 1.1.1.205)
CbsDomaProtAcub	CBS domain protein AcuB
CbsDomaProtSomeClus	CBS domain protein sometimes clustered with YjeE
Cbss27293Peg263Hypo	CBSS-272943.3.peg.263: hypothetical protein
Cbss27293Peg263Thio	CBSS-272943.3.peg.263: thioredoxin
Cbss29241Peg69Nlp	CBSS-292414.1.peg.69: NLP/P60 family protein
Cbss34503Peg1627n1	CBSS-345074.3.peg.1627: Cysteine desulfurase (EC 2.8.1.7)
CcaTrnaNucl	CCA tRNA nucleotidyltransferase (EC 2.7.7.72)
CcaTrnaNuclArchType	CCA tRNA nucleotidyltransferase, archaeal type (EC 2.7.7.72)
Ccs1ResbRelaPuta	Ccs1/ResB-related putative cytochrome C-type biogenesis protein
Cdp4Dehy6DeoxDGluc	CDP-4-dehydro-6-deoxy-D-glucose 3-dehydratase (EC 4.2.1.-)
CdpDiacGlyc3Phos	CDP-diacylglycerol--glycerol-3-phosphate 3-phosphatidyltransferase (EC 2.7.8.5)
CdpDiacPyro	CDP-diacylglycerol pyrophosphatase (EC 3.6.1.26)
CdpDiacSeriOPhos	CDP-diacylglycerol--serine O-phosphatidyltransferase (EC 2.7.8.8)
CdpGluc46Dehy	CDP-glucose 4,6-dehydratase (EC 4.2.1.45)
CellDiviInhi	Cell division inhibitor
CellDiviInitProt	Cell division initiation protein DivIVA
CellDiviInteMemb	Cell division integral membrane protein, YggT and half-length relatives
CellDiviProtBola	Cell division protein BolA
CellDiviProtDivi	Cell division protein DivIC (FtsB), stabilizes FtsL against RasP cleavage
CellDiviProtFtsa	Cell division protein FtsA
CellDiviProtFtsh	Cell division protein FtsH (EC 3.4.24.-)
CellDiviProtFtsi	Cell division protein FtsI [Peptidoglycan synthetase] (EC 2.4.1.129)
CellDiviProtFtsl	Cell division protein FtsL
CellDiviProtFtsq	Cell division protein FtsQ
CellDiviProtFtsw	Cell division protein FtsW
CellDiviProtFtsx	Cell division protein FtsX
CellDiviProtFtsz	Cell division protein FtsZ (EC 3.4.24.-)
CellDiviProtGpsb	Cell division protein GpsB, coordinates the switch between cylindrical and septal cell wall synthesis by re-localization of PBP1
CellDiviProtMraz	Cell division protein MraZ
CellDiviProtZapd	Cell division protein ZapD
CellDiviTopoSpec	Cell division topological specificity factor MinE
CellDiviTranAtpBind	Cell division transporter, ATP-binding protein FtsE (TC 3.A.5.1.1)
CellDiviTrigFact	Cell division trigger factor (EC 5.2.1.8)
CellEnveAssoTran	Cell envelope-associated transcriptional attenuator LytR-CpsA-Psr, subfamily A1 (as in PMID19099556)
CellEnveAssoTran2	Cell envelope-associated transcriptional attenuator LytR-CpsA-Psr, subfamily F2 (as in PMID19099556)
CellEnveAssoTran3	Cell envelope-associated transcriptional attenuator LytR-CpsA-Psr, subfamily F1 (as in PMID19099556)
CellEnveAssoTran4	Cell envelope-associated transcriptional attenuator LytR-CpsA-Psr, subfamily M (as in PMID19099556)
CellEnveAssoTran5	Cell envelope-associated transcriptional attenuator LytR-CpsA-Psr, subfamily S (as in PMID19099556)
CellEnveAssoTran6	Cell envelope-associated transcriptional attenuator LytR-CpsA-Psr, subfamily F4 (as in PMID19099556)
CellEnveBounMeta	Cell envelope-bound metalloprotease, Camelysin (EC 3.4.24.-)
CellInvaProtSipb	Cell invasion protein SipB
CellInvaProtSipd	Cell invasion protein SipD (Salmonella invasion protein D)
CellSurfProtIsda	Cell surface protein IsdA, transfers heme from hemoglobin to apo-IsdC
CellSurfProtIsda2	Cell surface protein IsdA1
CellSurfProtShpTran	Cell surface protein Shp, transfers heme from hemoglobin to apo-SiaA/HtsA
CellSurfReceIsdb	Cell surface receptor IsdB for hemoglobin and hemoglobin-haptoglobin complexes
CellSurfReceIsdh	Cell surface receptor IsdH for hemoglobin-haptoglobin complexes
CellWallActiAnti	Cell wall-active antibiotics response protein LiaF
CellWallActiAnti2	Cell wall-active antibiotics response protein VraT
CellWallAnchDoma	cell wall anchor domain-containing protein
CellWallAssoHydr	Cell wall-associated hydrolases (invasion-associated proteins)
Cesa6SecrWxg1Doma	cESAT-6-secreted WXG100 domain protein, contains Colicin-DNase domain (B.anthracis)
Cesa6SecrWxg1Doma2	cESAT-6-secreted WXG100 domain protein, contains EndoU nuclease domain (B.anthracis)
ChanFormTranCyto	Channel-forming transporter/cytolysins activator of TpsB family
Chap2	Chaperonin (heat shock protein 33)
ChapModuProtCbpm	Chaperone-modulator protein CbpM
ChapProtDnaj	Chaperone protein DnaJ
ChapProtDnak	Chaperone protein DnaK
ChapProtHsca	Chaperone protein HscA
ChapProtHscb	Chaperone protein HscB
ChapProtHscc	Chaperone protein HscC
ChapProtHtpg	Chaperone protein HtpG
ChapProtYscy	Chaperone protein YscY (Yop proteins translocation protein Y)
ChldCompCobaChel	ChlD component of cobalt chelatase involved in B12 biosynthesis
ChliCompCobaChel	ChlI component of cobalt chelatase involved in B12 biosynthesis
ChloBRedu	Chlorophyll b reductase (EC 1.1.1.294)
ChloBindProtPhot	Chlorophyll a(b) binding protein, photosystem II CP43 protein (PsbC) homolog
ChloDism	Chlorite dismutase (EC 1.13.11.49)
ChloOxyg	Chlorophyllide a oxygenase (EC 1.14.13.122)
ChloProt	Chlorosome protein A
ChloProtB	Chlorosome protein B
ChloProtC	Chlorosome protein C
ChloProtD	Chlorosome protein D
ChloProtE	Chlorosome protein E
ChloProtF	Chlorosome protein F
ChloProtG	Chlorosome protein G
ChloProtH	Chlorosome protein H
ChloProtI2fe2sFerr	Chlorosome protein I, 2Fe-2S ferredoxin
ChloProtJ2fe2sFerr	Chlorosome protein J, 2Fe-2S ferredoxin
ChloProtX	Chlorosome protein X
ChloReduSubuBchx	Chlorophyllide reductase subunit BchX (EC 1.18.-.-)
ChloReduSubuBchy	Chlorophyllide reductase subunit BchY (EC 1.18.-.-)
ChloReduSubuBchz	Chlorophyllide reductase subunit BchZ (EC 1.18.-.-)
ChloSyntChlg	Chlorophyll a synthase ChlG (EC 2.5.1.62)
ChloSyntChlgClus	Chlorophyll a synthase ChlG clustering with phytol kinase (EC 2.5.1.62)
CholDehy	Choline dehydrogenase (EC 1.1.99.1)
CholHydr	Choloylglycine hydrolase (EC 3.5.1.24)
CholKina	Choline kinase (EC 2.7.1.32)
CholPermLicb	Choline permease LicB
CholSulf	Choline-sulfatase (EC 3.1.6.6)
CholTranBettShor	Choline transporter BetT, short form
CholTwoCompRespRegu	Choline two-component response regulator Dred_3262
CholTwoCompSensHist	Choline two-component sensor histidine kinase Dred_3263
CholUtilTranRegu	Choline utilization transcriptional regulator Dde_3291
ChorDehy	Chorismate dehydratase (EC 4.2.1.151)
ChorMutaI	Chorismate mutase I (EC 5.4.99.5)
ChorMutaIi	Chorismate mutase II (EC 5.4.99.5)
ChorMutaIii	Chorismate mutase III (EC 5.4.99.5)
ChorPyruLyas	Chorismate--pyruvate lyase (EC 4.1.3.40)
ChorSynt	Chorismate synthase (EC 4.2.3.5)
ChroPartAtpaPfgi	Chromosome partitioning ATPase in PFGI-1-like cluster, ParA-like
ChroPartProtMukb	Chromosome partition protein MukB
ChroPartProtMuke	Chromosome partition protein MukE
ChroPartProtMukf	Chromosome partition protein MukF
ChroPartProtPara	Chromosome (plasmid) partitioning protein ParA
ChroPartProtParb	Chromosome (plasmid) partitioning protein ParB
ChroPartProtParb4	Chromosome (plasmid) partitioning protein ParB-2
ChroPartProtSmc	Chromosome partition protein smc
ChroReplInitProt	Chromosomal replication initiator protein DnaA
ChroReplInitProt2	Chromosome replication initiation protein DnaD
ChroResiProtChrb	Chromate resistance protein ChrB
ChroResiProtChri	Chromate resistance protein ChrI
ChroTranProtChra	Chromate transport protein ChrA
CiLikeReprSaBact	CI-like repressor [SA bacteriophages 11, Mu50B]
CiLikeReprSupeEnco	CI-like repressor, superantigen-encoding pathogenicity islands SaPI
CidaAssoMembProt	CidA-associated membrane protein CidB
CinaLikeProt	CinA-like protein
CitrCoaDehy	Citronellyl-CoA dehydrogenase
CitrCoaLigaAlphChai	Citrate--CoA ligase alpha chain (EC 6.2.1.18)
CitrCoaLigaBetaChai	Citrate--CoA ligase beta chain (EC 6.2.1.18)
CitrCoaLyas	Citramalyl-CoA lyase (EC 4.1.3.-)
CitrCoaSynt	Citronellyl-CoA synthetase
CitrDehy	Citronellol dehydrogenase
CitrDehy2	Citronellal dehydrogenase
CitrDehy2n1	Citronellol dehydrogenase 2
CitrDehy2n2	Citronellal dehydrogenase 2
CitrHSympCitmFami	Citrate/H+ symporter of CitMHS family
CitrLyasAlphChai	Citrate lyase alpha chain (EC 4.1.3.6)
CitrLyasBetaChai	Citrate lyase beta chain (EC 4.1.3.6)
CitrLyasGammChai	Citrate lyase gamma chain, acyl carrier protein (EC 4.1.3.6)
CitrLyasHoloAcyl	Citrate lyase holo-[acyl-carrier-protein] synthase (EC 2.7.7.61)
CitrLyasSubu1n2	Citrate lyase, subunit 1 (EC 2.3.3.8)
CitrPro3sLyasLiga	[Citrate [pro-3S]-lyase] ligase (EC 6.2.1.22)
CitrSynt	Citrate synthase (si) (EC 2.3.3.1)
CitrSynt2	(R)-citramalate synthase (EC 2.3.1.182)
CitrSyntMitoPrec	Citrate synthase, mitochondrial precursor (EC 2.3.3.1)
ClasIiLysyTrnaSynt	Class-II lysyl-tRNA synthetase domain protein
ClosMutsRelaProt	Clostridial MutS2-related protein
ClpbProt	ClpB protein
ClumFactClfaFibr	Clumping factor ClfA, fibrinogen-binding protein
ClumFactClfbFibr	Clumping factor ClfB, fibrinogen binding protein
CmpNNDiacAcidSynt	CMP-N,N'-diacetyllegionaminic acid synthase (EC 2.7.7.82)
Co2TranContCbsDoma	Co2 transporter containing CBS domains
CoActiPropGeneExpr	Co-activator of prophage gene expression IbrA
CoActiPropGeneExpr2	Co-activator of prophage gene expression IbrB
CoDehyAcceProtCooc	CO dehydrogenase accessory protein CooC (nickel insertion)
CoDehyAcceProtCooj	CO dehydrogenase accessory protein CooJ (nickel insertion)
CoDehyAcceProtCoot	CO dehydrogenase accessory protein CooT (nickel insertion)
CoDehyAcetCoaSynt	CO dehydrogenase/acetyl-CoA synthase, acetyl-CoA synthase subunit (EC 2.3.1.169)
CoDehyAcetCoaSynt3	CO dehydrogenase/acetyl-CoA synthase subunit beta, acetyl-CoA synthase (EC 2.3.1.169)
CoDehyAcetCoaSynt4	CO dehydrogenase/acetyl-CoA synthase subunit epsilon, CO dehydrogenase subcomplex (EC 1.2.99.2)
CoDehyAcetCoaSynt5	CO dehydrogenase/acetyl-CoA synthase subunit alpha, CO dehydrogenase subcomplex (EC 1.2.99.2)
CoDehyAcetCoaSynt6	CO dehydrogenase/acetyl-CoA synthase subunit delta, corrinoid iron-sulfur subcomplex small subunit
CoDehyAcetCoaSynt8	CO dehydrogenase/acetyl-CoA synthase, CO dehydrogenase subunit (EC 1.2.99.2)
CoDehyAcetCoaSynt9	CO dehydrogenase (ferredoxin)/acetyl-CoA synthase, CO dehydrogenase subunit (EC 1.2.7.4)
CoDehyIronSulfProt	CO dehydrogenase iron-sulfur protein CooF (EC 1.2.99.2)
CoaAcylPropDehy	CoA-acylating propionaldehyde dehydrogenase
CoaDisuRedu	CoA-disulfide reductase (EC 1.8.1.14)
CobAlamAden	Cob(I)alamin adenosyltransferase (EC 2.5.1.17)
CobAlamAdenClusWith	Cob(I)alamin adenosyltransferase, clustered with cobalamin synthesis (EC 2.5.1.17)
CobAlamRedu	Cob(III)alamin reductase
CobAlamRedu2	cob(II)alamin reductase (EC 1.16.1.4)
CobComHeteReduSubu	CoB--CoM heterodisulfide reductase subunit C (EC 1.8.98.1)
CobComHeteReduSubu2	CoB--CoM heterodisulfide reductase subunit B (EC 1.8.98.1)
CobComHeteReduSubu3	CoB--CoM heterodisulfide reductase subunit A (EC 1.8.98.1)
CobComHeteReduSubu4	CoB--CoM heterodisulfide reductase subunit D (EC 1.8.98.1)
CobComReduHydrAlph	CoB--CoM-reducing hydrogenase (Cys) alpha subunit
CobComReduHydrAlph2	CoB--CoM-reducing hydrogenase (Sec) alpha subunit
CobComReduHydrAlph3	CoB--CoM-reducing hydrogenase (Sec) alpha' subunit
CobComReduHydrBeta	CoB--CoM-reducing hydrogenase (Sec) beta subunit
CobComReduHydrBeta2	CoB--CoM-reducing hydrogenase (Cys) beta subunit
CobComReduHydrDelt	CoB--CoM-reducing hydrogenase (Sec) delta subunit
CobComReduHydrDelt2	CoB--CoM-reducing hydrogenase (Cys) delta subunit
CobComReduHydrGamm	CoB--CoM-reducing hydrogenase (Sec) gamma subunit
CobComReduHydrGamm2	CoB--CoM-reducing hydrogenase (Cys) gamma subunit
CobaBiosProtBlub	Cobalamin biosynthesis protein BluB
CobaBiosProtCobe	Cobalamin biosynthesis protein CobE
CobaContNitrHydr	Cobalt-containing nitrile hydratase subunit beta (EC 4.2.1.84)
CobaContNitrHydr2	Cobalt-containing nitrile hydratase subunit alpha (EC 4.2.1.84)
CobaPrec2CMeth	Cobalt-precorrin-2 C(20)-methyltransferase (EC 2.1.1.151)
CobaPrec3CMeth	Cobalt-precorrin-3 C(17)-methyltransferase (EC 2.1.1.272)
CobaPrec4CMeth	Cobalt-precorrin-4 C(11)-methyltransferase (EC 2.1.1.271)
CobaPrec5aHydr	Cobalt-precorrin 5A hydrolase (EC 3.7.1.12)
CobaPrec5bMeth	Cobalt-precorrin-5B (C1)-methyltransferase (EC 2.1.1.195)
CobaPrec6aRedu	Cobalt-precorrin-6A reductase (EC 1.3.1.54)
CobaPrec6bC15Meth	Cobalt-precorrin-6B C15-methyltransferase [decarboxylating] (EC 2.1.1.196)
CobaPrec7Meth	Cobalt-precorrin-7 (C5)-methyltransferase (EC 2.1.1.289)
CobaPrec8Meth	Cobalt-precorrin-8 methylmutase (EC 5.4.99.60)
CobaSynt	Cobalamin synthase (EC 2.7.8.26)
CobaZincCadmResi	Cobalt-zinc-cadmium resistance protein CzcD
CobnLikeChelBtus	CobN-like chelatase BtuS for metalloporphyrine salvage
CobwGtpaInvoCoba	CobW GTPase involved in cobalt insertion for B12 biosynthesis
CobyAcidCDiamSynt	Cobyrinic acid a,c-diamide synthetase (EC 6.3.5.11)
CobyAcidSynt	Cobyric acid synthase (EC 6.3.5.10)
Cocc	Coccolysin (EC 3.4.24.30)
CoenBSyntFrom2Oxog2	Coenzyme B synthesis from 2-oxoglutarate: steps 5, 9, and 13
CoenBSyntFrom2Oxog3	Coenzyme B synthesis from 2-oxoglutarate: steps 1, 6, and 10
CoenF4200LGlutLiga	Coenzyme F420-0:L-glutamate ligase (EC 6.3.2.31)
CoenF420HydrAlph	Coenzyme F420 hydrogenase alpha subunit (FrcA) (EC 1.12.98.1)
CoenF420HydrAlph2	Coenzyme F420 hydrogenase alpha subunit (FruA) (EC 1.12.98.1)
CoenF420HydrBeta	Coenzyme F420 hydrogenase beta subunit (FrcB) (EC 1.12.98.1)
CoenF420HydrBeta2	Coenzyme F420 hydrogenase beta subunit (FruB) (EC 1.12.98.1)
CoenF420HydrGamm	Coenzyme F420 hydrogenase gamma subunit (FrcG) (EC 1.12.98.1)
CoenF420HydrGamm2	Coenzyme F420 hydrogenase gamma subunit (FruG) (EC 1.12.98.1)
CoenF420HydrMatu	Coenzyme F420 hydrogenase maturation protease (EC 3.4.24.-)
CoenF420ReduHydr	coenzyme F420-reducing hydrogenase, beta subunit homolog
CoenFHDehySubuFpoa	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoA
CoenFHDehySubuFpob	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoB
CoenFHDehySubuFpoc	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoC
CoenFHDehySubuFpod	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoD
CoenFHDehySubuFpoe	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoE
CoenFHDehySubuFpof	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoF
CoenFHDehySubuFpog	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoG
CoenFHDehySubuFpoh	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoH
CoenFHDehySubuFpoi	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoI
CoenFHDehySubuFpoj	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoJ2
CoenFHDehySubuFpoj2	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoJ
CoenFHDehySubuFpok	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoK
CoenFHDehySubuFpol	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoL
CoenFHDehySubuFpom	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoM
CoenFHDehySubuFpon	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoN
CoenFHDehySubuFpoo	Coenzyme F(420)H(2) dehydrogenase (methanophenazine) subunit FpoO
CoenGammF4202LGlut	Coenzyme gamma-F420-2:L-glutamate ligase (EC 6.3.2.32)
CoenMSynt	Coenzyme M synthase
CoenPqqSyntProt	Coenzyme PQQ synthesis protein A
CoenPqqSyntProtB	Coenzyme PQQ synthesis protein B
CoenPqqSyntProtD	Coenzyme PQQ synthesis protein D
CoenPqqSyntProtE	Coenzyme PQQ synthesis protein E
CoenPqqSyntProtF	Coenzyme PQQ synthesis protein F (EC 3.4.99.-)
CofProtHdSupeHydr	Cof protein, HD superfamily hydrolase
Cog0UnchMembProt	COG0398: uncharacterized membrane protein
Cog1UnchConsProt3	COG1565: Uncharacterized conserved protein
Cog2AminOxidFlav	COG2907: Amine oxidase, flavin-containing
Cog2PredGlutAmid	COG2071: predicted glutamine amidotransferases in hypothetical Actinobacterial gene cluster
Cog2PredNuclAcid	COG2740: Predicted nucleic-acid-binding protein implicated in transcription termination
Cog2SulfOxidRela	COG2041: Sulfite oxidase and related enzymes
Cog3AminOxidFlav	COG3380: Amine oxidase, flavin-containing
Cog4PredOMeth	COG4123: Predicted O-methyltransferase
ColaAcidBiosAcet	Colanic acid biosynthesis acetyltransferase WcaF (EC 2.3.1.-)
ColaAcidBiosAcet2	Colanic acid biosynthesis acetyltransferase WcaB (EC 2.3.1.-)
ColaAcidBiosGlyc	Colanic acid biosysnthesis glycosyl transferase WcaI
ColaAcidBiosGlyc2	Colanic acid biosynthesis glycosyl transferase WcaE
ColaAcidBiosGlyc3	Colanic acid biosynthesis glycosyl transferase WcaA
ColaAcidBiosGlyc4	Colanic acid biosynthesis glycosyl transferase WcaL
ColaAcidBiosGlyc5	Colanic acid biosynthesis glycosyl transferase WcaC
ColaAcidBiosProt2	Colanic acid biosysnthesis protein WcaK
ColaAcidBiosProt3	Colanic acid biosynthesis protein wcaM
ColaAcidCapsBios	Colanic acid capsular biosynthesis activation accesory protein RcsA, co-regulator with RcsB
ColaAcidPolyWcad	Colanic acid polymerase WcaD
ColdShocProtCspFami	Cold shock protein of CSP family
ColdShocProtCspFami10	Cold shock protein of CSP family => tetramer
ColdShocProtCspFami11	Cold shock protein of CSP family => CspB (naming convention as in B.subtlis)
ColdShocProtCspFami12	Cold shock protein of CSP family => CspA (naming convention as in S.aureus)
ColdShocProtCspFami13	Cold shock protein of CSP family => CspC (naming convention as in B.subtlis)
ColdShocProtCspFami14	Cold shock protein of CSP family => CspD (naming convention as in B.subtlis)
ColdShocProtCspFami15	Cold shock protein of CSP family => trimer
ColdShocProtCspFami16	Cold shock protein of CSP family => CspG (naming convention as in E.coli)
ColdShocProtCspFami2	Cold shock protein of CSP family => SCO4325
ColdShocProtCspFami3	Cold shock protein of CSP family => CspD (naming convention as in E.coli)
ColdShocProtCspFami4	Cold shock protein of CSP family => CspA (naming convention as in E.coli)
ColdShocProtCspFami5	Cold shock protein of CSP family => CspE (naming convention as in E.coli)
ColdShocProtCspFami6	Cold shock protein of CSP family => CspB/CspG/CspI (naming convention as in E.coli)
ColdShocProtCspFami7	Cold shock protein of CSP family => CspF/CspH (naming convention as in E.coli)
ColdShocProtCspFami8	Cold shock protein of CSP family => CspC (naming convention as in E.coli)
ColdShocProtCspFami9	Cold shock protein of CSP family => dimer
ColiE2ToleProtCbrc2	Colicin E2 tolerance protein CbrC
ColiVProdProt	Colicin V production protein
CollBindProtCna	Collagen binding protein Cna
ComfOperProtC	ComF operon protein C
ComfOperProtDnaTran	ComF operon protein A, DNA transporter ATPase
CompProt	Competence protein A
CompProtB	Competence protein B
CompProtC	Competence protein C
CompProtD	Competence protein D
CompProtE	Competence protein E
CompProtFHomoPhos	Competence protein F homolog, phosphoribosyltransferase domain
CompProtFPhos	Competence protein F, phosphoribosyltransferase
CompProtPiln	Competence protein PilN
CompProtPilo	Competence protein PilO
CompProtPilw	Competence protein PilW
CompStimPeptAbcTran	Competence-stimulating peptide ABC transporter ATP-binding protein ComA
CompStimPeptAbcTran2	Competence-stimulating peptide ABC transporter permease protein ComB
ConjBileSaltTran	Conjugated Bile Salt Transporter
ConjSignPeptTrhf	Conjugative signal peptidase TrhF
ConjTranAtpBindProt	Conjugative transfer ATP binding protein
ConjTranProt123n1	Conjugative transfer protein 123
ConjTranProt234n1	Conjugative transfer protein 234
ConjTranProt345n1	Conjugative transfer protein 345
ConjTranProtEli_	Conjugative transfer protein ELI_00880
ConjTranProtEli_2	Conjugative transfer protein ELI_04330
ConjTranProtPslt	Conjugative transfer protein PSLT087
ConjTranProtPslt2	Conjugative transfer protein PSLT093
ConjTranProtS043n1	Conjugative transfer protein s043
ConjTranProtTraa	Conjugative transposon protein TraA
ConjTranProtTraa3	Conjugative transfer protein TraA
ConjTranProtTrab	Conjugative transposon protein TraB
ConjTranProtTrac2	Conjugative transposon protein TraC
ConjTranProtTrad2	Conjugative transposon protein TraD
ConjTranProtTrae	Conjugative transposon protein TraE
ConjTranProtTraf	Conjugative transposon protein TraF
ConjTranProtTrag	Conjugative transposon protein TraG
ConjTranProtTrah2	Conjugative transposon protein TraH
ConjTranProtTrai	Conjugative transfer protein TraI, relaxase
ConjTranProtTrai2	Conjugative transposon protein TraI
ConjTranProtTraj	Conjugative transposon protein TraJ
ConjTranProtTrak	Conjugative transposon protein TraK
ConjTranProtTral	Conjugative transposon protein TraL
ConjTranProtTram	Conjugative transposon protein TraM
ConjTranProtTran	Conjugative transposon protein TraN
ConjTranProtTrao	Conjugative transposon protein TraO
ConjTranProtTrap	Conjugative transposon protein TraP
ConjTranProtTraq	Conjugative transposon protein TraQ
ConjTranProtTrav	Conjugative transfer protein TraV
ConjTranProtTrba	Conjugative transfer protein TrbA
ConjTranProtTrbb	Conjugative transfer protein TrbB
ConjTranProtTrbc	Conjugative transfer protein TrbC
ConjTranProtTrbd	Conjugative transfer protein TrbD
ConjTranProtTrbe	Conjugative transfer protein TrbE
ConjTranProtTrbf	Conjugative transfer protein TrbF
ConjTranProtTrbg	Conjugative transfer protein TrbG
ConjTranProtTrbh	Conjugative transfer protein TrbH
ConjTranProtTrbi	Conjugative transfer protein TrbI
ConjTranProtTrbj	Conjugative transfer protein TrbJ
ConjTranProtTrbk	Conjugative transfer protein TrbK
ConjTranProtTrbl	Conjugative transfer protein TrbL
ConjTranProtTrbn	Conjugative transfer protein TrbN
ConjTranProtTrbo	Conjugative transfer protein TrbO
ConjTranProtTrbp	Conjugative transfer protein TrbP (IncF TraX homolog)
ConjTranTran	Conjugative transfer transglycosylase
ConjTranTranDnaHeli	Conjugative transposon transfer DNA helicase
ConsHypoInteMemb	Conserved hypothetical integral membrane protein YrbEb
ConsHypoInteMemb2	Conserved hypothetical integral membrane protein YrbEa
ConsHypoProtGene	Conserved hypothetical protein, gene in Ubiquinol-cytochrome C chaperone locus
ConsMembProtCopp	Conserved membrane protein in copper uptake, YcnI
ConsProtAssoWith	conserved protein associated with acetyl-CoA C-acyltransferase
ConsProtAssoWith2	conserved protein associated with acetyl-CoA C-acyltransferase and HMGCo
ConsProtWithPred	conserved protein with predicted RNA binding PUA domain
ConsUnchProtCrea	Conserved uncharacterized protein CreA
CopgDomaContProt	CopG domain-containing protein
CoppAbcTranAtpBind	Copper ABC transporter, ATP-binding component
CoppAbcTranPeriSubs	Copper ABC transporter, periplasmic substrate-binding component
CoppAbcTranPermComp	Copper ABC transporter, permease component
CoppBindProtPlas	Copper binding protein, plastocyanin/azurin family
CoppChapCopz	Copper(I) chaperone CopZ
CoppContNitrRedu	Copper-containing nitrite reductase (EC 1.7.2.1)
CoppHomeProtCute	Copper homeostasis protein CutE
CoppHomeProtCutf	Copper homeostasis protein CutF precursor
CoppMetaPcuCInse	Copper metallochaperone PCu(A)C, inserts Cu(I) into cytochrome oxidase subunit II
CoppResiProtCopc	Copper resistance protein CopC
CoppResiProtCopd	Copper resistance protein CopD
CoppSensHistKina	Copper sensory histidine kinase CpxA
CoppSensHistKina2	Copper sensory histidine kinase CusS
CoppSensTwoCompSyst	Copper-sensing two-component system response regulator CpxR
CoppSensTwoCompSyst2	Copper-sensing two-component system response regulator CusR
CoppToleProt	Copper tolerance protein
CoppTranPTypeAtpa	Copper-translocating P-type ATPase (EC 3.6.3.4)
CoprDecaHemq	Coproheme decarboxylase HemQ (no EC)
CoprFerr	Coproporphyrin ferrochelatase (EC 4.99.1.-)
CoprIiiOxidAero	Coproporphyrinogen III oxidase, aerobic (EC 1.3.3.3)
CoprIiiOxidOxygInde	Coproporphyrinogen III oxidase, oxygen-independent (EC 1.3.99.22)
CoupProtVirdAtpa	Coupling protein VirD4, ATPase required for T-DNA transfer
CroLikeReprSaBact	Cro-like repressor [SA bacteriophages 11, Mu50B]
CroLikeReprSupeEnco	Cro-like repressor, superantigen-encoding pathogenicity islands SaPI
CrosJuncEndoRuvc	Crossover junction endodeoxyribonuclease RuvC (EC 3.1.22.4)
CrotCoaCarbReduEthy	Crotonyl-CoA carboxylase/reductase, ethylmalonyl-CoA producing
CrotCoaCarnCoaTran	Crotonobetainyl-CoA:carnitine CoA-transferase (EC 2.8.3.-)
CrotCoaDehy	Crotonobetainyl-CoA dehydrogenase (EC 1.3.99.-)
CrotCoaLiga	Crotonobetaine--CoA ligase
CrotCoaRedu	crotonyl-CoA reductase (EC 1.3.1.86)
Cryp	Cryptochrome
CrypAlanRace	Cryptic alanine racemase
CsbbStreRespProt	CsbB stress response protein
CsdlProtHesaMoeb	CsdL (EC-YgdL) protein of the HesA/MoeB/ThiF family, part of the CsdA-E-L sulfur transfer pathway
CtpDepeArchRiboKina	CTP-dependent archaeal riboflavin kinase (EC 2.7.1.161)
CtpSynt	CTP synthase (EC 6.3.4.2)
CupiDomaProtAuto	Cupin domain protein in Autoinducer 2 (AI-2) related operon
CupiDomaProtClus	Cupin domain protein clustered with Rubisco-like protein
CurlGeneTranActi	Curlin genes transcriptional activator
Cyan2	Cyanophycinase (EC 3.4.15.6)
Cyan2n1	Cyanophycinase 2 (EC 3.4.15.6)
CyanAbcTranAtpBind	Cyanate ABC transporter, ATP-binding protein
CyanAbcTranPermProt	Cyanate ABC transporter, permease protein
CyanAbcTranSubsBind	Cyanate ABC transporter, substrate binding protein
CyanDime	Cyanophycinase dimer (EC 3.4.15.6)
CyanHydr	Cyanate hydratase (EC 4.2.1.104)
CyanHydr2	Cyanide hydratase (EC 4.2.1.66)
CyanHydr3	Cyanamide hydratase (EC 4.2.1.69)
CyanNitr	Cyanoalanine nitrilase (EC 3.5.5.4)
CyanProtSlr0n1	Cyanobacterial protein slr0575
CyanSpecRpodLike	Cyanobacteria-specific RpoD-like sigma factor, type-1
CyanSpecRpodLike10	Cyanobacteria-specific RpoD-like sigma factor, type-6
CyanSpecRpodLike11	Cyanobacteria-specific RpoD-like sigma factor, type-14
CyanSpecRpodLike12	Cyanobacteria-specific RpoD-like sigma factor, type-11
CyanSpecRpodLike2	Cyanobacteria-specific RpoD-like sigma factor, type-2
CyanSpecRpodLike3	Cyanobacteria-specific RpoD-like sigma factor, type-7
CyanSpecRpodLike4	Cyanobacteria-specific RpoD-like sigma factor, type-3
CyanSpecRpodLike5	Cyanobacteria-specific RpoD-like sigma factor, type-5
CyanSpecRpodLike6	Cyanobacteria-specific RpoD-like sigma factor, type-4
CyanSpecRpodLike7	Cyanobacteria-specific RpoD-like sigma factor, type-9
CyanSpecRpodLike8	Cyanobacteria-specific RpoD-like sigma factor, type-12
CyanSpecRpodLike9	Cyanobacteria-specific RpoD-like sigma factor, type-13
CyanSynt	Cyanophycin synthase (EC 6.3.2.30) (EC 6.3.2.29)
CyanTranProtCynx	Cyanate transport protein CynX
Cycl15Dien1CarbCoa	Cyclohexa-1,5-diene-1-carbonyl-CoA hydratase (EC 4.2.1.100)
Cycl1Ene1CarbCoa	Cyclohex-1-ene-1-carboxyl-CoA hydratase (EC 4.2.1.17)
CyclAmidHydrMyco	Cyclic amid hydrolase in mycofactocin cluster
CyclAmpReceProt	Cyclic AMP receptor protein
CyclCoaDehy	Cyclohexanecarboxyl-CoA dehydrogenase
CyclCoaLiga2	Cyclohexanecarboxylate--CoA ligase
CyclDehy	Cyclohexadienyl dehydrogenase (EC 1.3.1.43) (EC 1.3.1.12)
CyclDehy2	Cyclohexadienyl dehydratase (EC 4.2.1.91) (EC 4.2.1.51)
CyclDehyFutaSynt	Cyclic dehypoxanthine futalosine synthase (EC 1.21.98.1)
CyclDiAmpPhosGdpp	Cyclic-di-AMP phosphodiesterase GdpP
CyclFattAcylPhos	Cyclopropane-fatty-acyl-phospholipid synthase (EC 2.1.1.79)
CyclFattAcylPhos2	Cyclopropane-fatty-acyl-phospholipid synthase, plant type (EC 2.1.1.79)
CyclFattAcylPhos3	Cyclopropane-fatty-acyl-phospholipid synthase-like protein, clusters with FIG005069
CyclPyraMonoSynt	Cyclic pyranopterin monophosphate synthase accessory protein
CyclPyraPhosSynt	Cyclic pyranopterin phosphate synthase (MoaA) (EC 4.1.99.18)
CyclSecrProt	cyclolysin secretion protein
CydOperProtYbge	Cyd operon protein YbgE
CynOperTranActi	Cyn operon transcriptional activator
CysReguTranActiCysb	Cys regulon transcriptional activator CysB
CysTrnaDeacYbak	Cys-tRNA(Pro) deacylase YbaK
CysoCystPept	CysO-cysteine peptidase
CystBetaLyasMaly	Cystathionine beta-lyase MalY (EC 4.4.1.8)
CystBetaSynt	Cystathionine beta-synthase (EC 4.2.1.22)
CystDesu	Cysteine desulfurase (EC 2.8.1.7)
CystDesuCsdaCsde	Cysteine desulfurase CsdA-CsdE, sulfur acceptor protein CsdE
CystDesuCsdaCsde2	Cysteine desulfurase CsdA-CsdE, main protein CsdA (EC 2.8.1.7)
CystDesuIscsSubf	Cysteine desulfurase, IscS subfamily (EC 2.8.1.7)
CystDesuNifsSubf	Cysteine desulfurase, NifS subfamily (EC 2.8.1.7)
CystDesuSufsSubf	Cysteine desulfurase, SufS subfamily (EC 2.8.1.7)
CystDiox	Cysteine dioxygenase (EC 1.13.11.20)
CystGammLyas	Cystathionine gamma-lyase (EC 4.4.1.1)
CystGammSynt	Cystathionine gamma-synthase (EC 2.5.1.48)
CystSulfAcidDeca	Cysteine sulfinic acid decarboxylase (EC 4.1.1.29)
CystSynt	Cysteine synthase (EC 2.5.1.47)
CystSyntAdenSulf	Cysteine synthesis adenylyltransferase/sulfurtransferase
CystSyntB	Cysteine synthase B (EC 2.5.1.47)
CystSyntCysoDepe	Cysteine synthase, CysO-dependent
CystTrnaSynt	Cysteinyl-tRNA synthetase (EC 6.1.1.16)
CystTrnaSyntChlo	Cysteinyl-tRNA synthetase, chloroplast (EC 6.1.1.16)
CystTrnaSyntMito	Cysteinyl-tRNA synthetase, mitochondrial (EC 6.1.1.16)
CystTrnaSyntPara	Cysteinyl-tRNA synthetase paralog 2
CystTrnaSyntPara2	Cysteinyl-tRNA synthetase paralog 1
CystTrnaSyntRela	Cysteinyl-tRNA synthetase related protein
CytiDeam	Cytidine deaminase (EC 3.5.4.5)
CytiDeoxDeamFami	cytidine/deoxycytidylate deaminase family protein (EC 3.5.4.3 )
CytiKina	Cytidylate kinase (EC 2.7.4.25)
CytoAa3600MenaOxid	Cytochrome aa3-600 menaquinol oxidase subunit II
CytoAa3600MenaOxid2	Cytochrome aa3-600 menaquinol oxidase subunit I
CytoAa3600MenaOxid3	Cytochrome aa3-600 menaquinol oxidase subunit III
CytoAa3600MenaOxid4	Cytochrome aa3-600 menaquinol oxidase subunit IV
CytoAlphAmyl	Cytoplasmic alpha-amylase (EC 3.2.1.1)
CytoAminPepa	Cytosol aminopeptidase PepA (EC 3.4.11.1)
CytoB559AlphChai	Cytochrome b559 alpha chain (PsbE)
CytoB559BetaChai	Cytochrome b559 beta chain (PsbF)
CytoB6FCompAlteRies	Cytochrome b6-f complex alternative Rieske iron sulfur protein PetC2
CytoB6FCompAlteRies2	Cytochrome b6-f complex alternative Rieske iron sulfur protein PetC3
CytoB6FCompIronSulf2	Cytochrome b6-f complex iron-sulfur subunit PetC1 (Rieske iron sulfur protein EC 1.10.9.1)
CytoB6FCompSubuApoc	Cytochrome b6-f complex subunit, apocytochrome f
CytoB6FCompSubuCyto	Cytochrome b6-f complex subunit, cytochrome b6
CytoB6FCompSubuCyto2	Cytochrome b6-f complex subunit, cytochrome b6, putative
CytoB6FCompSubuIv	Cytochrome b6-f complex subunit IV (PetD)
CytoB6FCompSubuV	Cytochrome b6-f complex subunit V (PetG)
CytoB6FCompSubuVi	Cytochrome b6-f complex subunit VI (PetL)
CytoB6FCompSubuVii	Cytochrome b6-f complex subunit VII (PetM)
CytoB6FCompSubuViii	Cytochrome b6-f complex subunit VIII (PetN)
CytoC3n1	Cytochrome c3
CytoC551Nirm	Cytochrome c551 NirM
CytoC551Pero	Cytochrome c551 peroxidase (EC 1.11.1.5)
CytoC552NitrRedu	Cytochrome c552 nitrite reductase, NrfA
CytoC553n1	Cytochrome C553 (soluble cytochrome f)
CytoC55xPrecNirc	Cytochrome c55X precursor NirC
CytoC6n2	cytochrome c6
CytoCHemeLyasCchl	Cytochrome C heme lyase CCHL (EC 4.4.1.17)
CytoCHemeLyasSubu	Cytochrome c heme lyase subunit CcmH
CytoCHemeLyasSubu2	Cytochrome c heme lyase subunit CcmL
CytoCHemeLyasSubu3	Cytochrome c heme lyase subunit CcmF
CytoCOxidAssoMemb	Cytochrome c oxidase associated membrane protein
CytoCOxidCaa3Type	Cytochrome c oxidase caa3-type assembly factor CtaG_BS (unrelated to Cox11-CtaG family)
CytoCOxidPolyI	Cytochrome c oxidase polypeptide I (EC 1.9.3.1)
CytoCOxidPolyIi	Cytochrome c oxidase polypeptide II (EC 1.9.3.1)
CytoCOxidPolyIii	Cytochrome c oxidase polypeptide III (EC 1.9.3.1)
CytoCOxidPolyIv	Cytochrome c oxidase polypeptide IV (EC 1.9.3.1)
CytoCOxidSubuCcon	Cytochrome c oxidase (cbb3-type) subunit CcoN (EC 1.9.3.1)
CytoCOxidSubuCcon2	Cytochrome c oxidase subunit CcoN (EC 1.9.3.1)
CytoCOxidSubuCcoo	Cytochrome c oxidase (cbb3-type) subunit CcoO (EC 1.9.3.1)
CytoCOxidSubuCcoo2	Cytochrome c oxidase subunit CcoO (EC 1.9.3.1)
CytoCOxidSubuCcop	Cytochrome c oxidase (cbb3-type) subunit CcoP (EC 1.9.3.1)
CytoCOxidSubuCcoq2	Cytochrome c oxidase (cbb3-type) subunit CcoQ (EC 1.9.3.1)
CytoCTypeBiogProt	Cytochrome c-type biogenesis protein DsbD, protein-disulfide reductase (EC 1.8.1.8)
CytoCTypeBiogProt11	Cytochrome c-type biogenesis protein CcdA homolog, associated with MetSO reductase
CytoCTypeBiogProt15	Cytochrome c-type biogenesis protein, archaeal, distantly related to heme lyase subunit CcmF
CytoCTypeBiogProt2	Cytochrome c-type biogenesis protein CcmG/DsbE, thiol:disulfide oxidoreductase
CytoCTypeBiogProt3	Cytochrome c-type biogenesis protein CcmE, heme chaperone
CytoCTypeBiogProt4	Cytochrome c-type biogenesis protein CcmD, interacts with CcmCE
CytoCTypeBiogProt5	Cytochrome c-type biogenesis protein CcmC, putative heme lyase for CcmE
CytoCTypeBiogProt6	Cytochrome c-type biogenesis protein CcdA (DsbD analog)
CytoCTypeBiogProt7	Cytochrome c-type biogenesis protein CcsA/ResC
CytoCTypeBiogProt8	Cytochrome c-type biogenesis protein ResA
CytoCTypeBiogProt9	Cytochrome c-type biogenesis protein Ccs1/ResB
CytoCTypeProtNapc	Cytochrome c-type protein NapC
CytoCbb3OxidMatu	cytochrome cbb3 oxidase maturation protein CcoH
CytoCoppHomeProt	Cytoplasmic copper homeostasis protein CutC
CytoDUbiqOxidSubu	Cytochrome d ubiquinol oxidase subunit II (EC 1.10.3.-)
CytoDUbiqOxidSubu2	Cytochrome d ubiquinol oxidase subunit I (EC 1.10.3.-)
CytoDUbiqOxidSubu3	Cytochrome d ubiquinol oxidase subunit X (EC 1.10.3.-)
CytoDUbiqOxidSubu5	cytochrome d ubiquinol oxidase, subunit II-related protein
CytoDistToxiSubu	Cytolethal distending toxin subunit A
CytoDistToxiSubu3	Cytolethal distending toxin subunit C
CytoDistToxiSubu4	Cytolethal distending toxin subunit B, DNase I-like
CytoHemoHlyaPore	Cytolysin and hemolysin, HlyA, Pore-forming toxin
CytoMembProtFsxa	Cytoplasmic membrane protein FsxA
CytoNonHemeIronSulp	cytoplasmic non-heme iron-sulphur protein, NapF
CytoNonsDipe	Cytosol nonspecific dipeptidase (EC 3.4.13.18)
CytoOUbiqOxidSubu	Cytochrome O ubiquinol oxidase subunit IV (EC 1.10.3.-)
CytoOUbiqOxidSubu2	Cytochrome O ubiquinol oxidase subunit III (EC 1.10.3.-)
CytoOUbiqOxidSubu3	Cytochrome O ubiquinol oxidase subunit I (EC 1.10.3.-)
CytoOUbiqOxidSubu4	Cytochrome O ubiquinol oxidase subunit II (EC 1.10.3.-)
CytoOxidBiogProt	Cytochrome oxidase biogenesis protein Surf1, facilitates heme A insertion
CytoOxidBiogProt2	Cytochrome oxidase biogenesis protein Sco1/SenC/PrrC, thiol-disulfide reductase involved in Cu(I) insertion into CoxII Cu(A) center
CytoOxidBiogProt3	Cytochrome oxidase biogenesis protein Cox11-CtaG, copper delivery to Cox1
CytoP450143n1	Cytochrome P450 143
CytoPoreFormProt	Cytolytic pore-forming protein => Alpha-hemolysin
CytoPoreFormProt10	Cytolytic pore-forming protein => Cytotoxin K
CytoPoreFormProt11	Cytolytic pore-forming protein F component => Leukocidin LukF-G
CytoPoreFormProt12	Cytolytic pore-forming protein S component => Leukocidin LukS-H
CytoPoreFormProt2	Cytolytic pore-forming protein F component => Leukotoxin LukD
CytoPoreFormProt3	Cytolytic pore-forming protein S component => Leukotoxin LukE
CytoPoreFormProt4	Cytolytic pore-forming protein F component => Leukocidin LukF-PV
CytoPoreFormProt5	Cytolytic pore-forming protein S component => Leukocidin LukS-PV
CytoPoreFormProt6	Cytolytic pore-forming protein S component => Gamma-hemolysin HlgA
CytoPoreFormProt7	Cytolytic pore-forming protein S component => Gamma-hemolysin HlgC
CytoPoreFormProt8	Cytolytic pore-forming protein F component => Gamma-hemolysin HlgB
CytoPoreFormProt9	Cytolytic pore-forming protein => Hemolysin II
CytoProtYaie	Cytoplasmic protein YaiE
CytoPuriUracThia	Cytosine/purine/uracil/thiamine/allantoin permease family protein
CytoThiaBindComp	Cytoplasmic thiamin-binding component of thiamin ABC transporter, COG0011 family
D3PhosDehy	D-3-phosphoglycerate dehydrogenase (EC 1.1.1.95)
DAlanAmin	D-alanine aminotransferase (EC 2.6.1.21)
DAlanDAlanCarb	D-alanyl-D-alanine carboxypeptidase (EC 3.4.16.4)
DAlanDAlanDipe	D-alanyl-D-alanine dipeptidase (EC 3.4.13.22)
DAlanDAlanLiga	D-alanine--D-alanine ligase (EC 6.3.2.4)
DAlanDAlanLiga3	D-alanine--D-alanine ligase A (EC 6.3.2.4)
DAlanDAlanLigaB	D-alanine--D-alanine ligase B (EC 6.3.2.4)
DAlanDAlanLigaMysd	D-alanine--D-alanine ligase MysD (EC 6.3.2.4)
DAlanDLactLiga	D-alanine--D-lactate ligase (EC 6.1.2.1)
DAlanDSeriLiga	D-alanine--D-serine ligase (EC 6.3.2.35)
DAlanPolyLigaSubu	D-alanine--poly(phosphoribitol) ligase subunit 2 (EC 6.1.1.13)
DAlanPolyLigaSubu2	D-alanine--poly(phosphoribitol) ligase subunit 1 (EC 6.1.1.13)
DAlanTranProtDltb	D-alanyl transfer protein DltB
DAllo6PhosIsom	D-allose-6-phosphate isomerase (EC 5.3.1.-)
DAlloAbcTranAtpBind	D-allose ABC transporter, ATP-binding protein
DAlloAbcTranPerm	D-allose ABC transporter, permease protein
DAlloAbcTranSubs	D-allose ABC transporter, substrate-binding protein
DAlloKina	D-allose kinase (EC 2.7.1.55)
DAllu6Phos3Epim	D-allulose-6-phosphate 3-epimerase (EC 5.1.3.-)
DAmin	D-aminopeptidase (EC 3.4.11.19)
DAminAcidDehy	D-amino acid dehydrogenase (EC 1.4.99.1)
DAminAcidDehyFami	D-amino acid dehydrogenase family protein in hydroxy-L-proline catabolic cluster (EC 1.4.99.1)
DAminAcidOxid	D-amino-acid oxidase (EC 1.4.3.3)
DAminDipeBindProt	D-aminopeptidase dipeptide-binding protein DppA (EC 3.4.11.-)
DAminTrnaDeac	D-aminoacyl-tRNA deacylase (EC 3.1.1.96)
DAminTrnaDeacArch	D-aminoacyl-tRNA deacylase, archaeal type (EC 3.1.1.96)
DArab3Hexu6PhosForm2	D-arabino-3-hexulose 6-phosphate formaldehyde-lyase (EC 4.1.2.43)
DArab5PhosIsom	D-arabinose 5-phosphate isomerase (EC 5.3.1.13)
DCystDesu	D-cysteine desulfhydrase (EC 4.4.1.15)
DDDipeBindPeriProt	D,D-dipeptide-binding periplasmic protein DdpA
DDDipeTranAtpBind	D,D-dipeptide transport ATP-binding protein DdpD
DDDipeTranAtpBind2	D,D-dipeptide transport ATP-binding protein DdpF
DDDipeTranSystPerm	D,D-dipeptide transport system permease protein DdpB
DDDipeTranSystPerm2	D,D-dipeptide transport system permease protein DdpC
DDopaDeca	D-dopachrome decarboxylase (EC 4.1.1.84)
DEryt4PhosDehy	D-erythrose-4-phosphate dehydrogenase (EC 1.2.1.72)
DEryt78DihyTripEpim	D-erythro-7,8-dihydroneopterin triphosphate epimerase
DFucoDehy	D-fuconate dehydratase (EC 4.2.1.67)
DGalaDehy	D-galactarate dehydratase (EC 4.2.1.42)
DGluc6PhosAmmoLyas	D-Glucosaminate-6-phosphate ammonia-lyase (EC 4.3.1.-)
DGlutLMDpmPeptLmo1n1	D-glutamyl-L-m-Dpm peptidase lmo1104 homolog
DGlyc23Pent15Bisp	D-glycero-2,3-pentodiulose-1,5-bisphosphate phosphatase (EC 3.1.3.-)
DGlyc2Kina	D-glycerate 2-kinase (EC 2.7.1.165)
DGlyc3KinaPlanType	D-glycerate 3-kinase, plant type (EC 2.7.1.31)
DGlycBetaDMannHept	D-glycero-beta-D-manno-heptose 7-phosphate kinase
DGlycBetaDMannHept2	D-glycero-beta-D-manno-heptose-1,7-bisphosphate 7-phosphatase (EC 3.1.3.82)
DInos3PhosGlyc	D-inositol-3-phosphate glycosyltransferase (EC 2.4.1.250)
DLactDehy	D-lactate dehydrogenase (EC 1.1.1.28)
DLactDehy2	D-lactate dehydratase (EC 4.2.1.130)
DLactDehyCytoCDepe	D-Lactate dehydrogenase, cytochrome c-dependent (EC 1.1.2.4)
DMalaDehyDeca	D-malate dehydrogenase [decarboxylating] (EC 1.1.1.83)
DMannOxid	D-mannonate oxidoreductase (EC 1.1.1.57)
DNopaCataOperProt	D-nopaline catabolic operon protein 2
DNopaDehy	D-nopaline dehydrogenase (EC 1.5.1.19)
DNopaOctoOxidSubu	D-nopaline/octopine oxidase subunit B
DNopaOctoOxidSubu2	D-nopaline/octopine oxidase subunit A
DOctoDehy	D-octopine dehydrogenase (EC 1.5.1.11)
DOrni45AminESubu	D-Ornithine 4,5-aminomutase E subunit (EC 5.4.3.5)
DOrni45AminSSubu	D-Ornithine 4,5-aminomutase S subunit (EC 5.4.3.5)
DProlRedu23KdaSubu	D-proline reductase, 23 kDa subunit (EC 1.21.4.1)
DProlRedu26KdaSubu	D-proline reductase, 26 kDa subunit (EC 1.21.4.1)
DProlRedu45KdaSubu	D-proline reductase, 45 kDa subunit (EC 1.21.4.1)
DRibo15Phos	D-Ribose 1,5-phosphomutase (EC 5.4.2.7)
DSeriAmmoLyas	D-serine ammonia-lyase (EC 4.3.1.18)
DSeriDAlanGlycTran	D-serine/D-alanine/glycine transporter
DTartDehy	D(-)-tartrate dehydratase (EC 4.2.1.81)
DXylo1Dehy2	D-xylose 1-dehydrogenase (NADP(+)) (EC 1.1.1.179)
DXyloDehy	D-xylonate dehydratase (EC 4.2.1.82)
DXyloTranAtpBind	D-xylose transport ATP-binding protein XylG
DatpPyroNudb	dATP pyrophosphohydrolase NudB (EC 3.6.1.-)
DcmpDeam	dCMP deaminase (EC 3.5.4.12)
DeadBoxAtpDepeRna	DEAD-box ATP-dependent RNA helicase CshB (EC 3.6.4.13)
DeadBoxAtpDepeRna2	DEAD-box ATP-dependent RNA helicase CshA (EC 3.6.4.13)
DeatCuriProtDocToxi	Death on curing protein, Doc toxin
DeblAmin	Deblocking aminopeptidase (EC 3.4.11.-)
DecaMonoBetaDArab	Decaprenyl-monophosphoryl-beta-D-arabinose (DPA) translocase to periplasm
DedaFamiInneMemb4	DedA family inner membrane protein YdjX
DedaFamiProtPuta	DedA family protein, putative
DedaProt	DedA protein
DegeInteSupeEnco	Degenerate integrase, superantigen-encoding pathogenicity islands SaPI
DegvFamiProt	DegV family protein
DegvFamiProtClus	DegV family protein in cluster with TrmH family tRNA/rRNA methyltransferase YacO
DehyClusWithLFuco	dehydrogenase clustered with L-fuconate utilization genes
DehyFlavLodb	Dehydrogenase flavoprotein LodB
DehyMycoClus	Dehydrogenase in mycofactocin cluster
Delt1Pyrr2CarbRedu	Delta 1-pyrroline-2-carboxylate reductase (EC 1.5.1.1)
Delt1Pyrr5CarbDehy	Delta-1-pyrroline-5-carboxylate dehydrogenase (EC 1.5.1.12)
Delt1Pyrr5CarbDehy2	Delta 1-pyrroline-5-carboxylate dehydrogenase domain protein
DeltTocoMeth	delta-tocopherol methyltransferase (EC 2.1.1.95)
Deme4DeoxSyntMysa	Demethyl 4-deoxygadusol synthase MysA
DemeMeth	Demethylmenaquinone methyltransferase (EC 2.1.1.163)
DeorTypeTranRegu2	DeoR-type transcriptional regulator YihW
Deox5TripNucl	Deoxyuridine 5'-triphosphate nucleotidohydrolase (EC 3.6.1.23)
Deox5TripNuclSaBact	Deoxyuridine 5'-triphosphate nucleotidohydrolase [SA bacteriophages 11, Mu50B] (EC 3.6.1.23)
DeoxHydr	Deoxyhypusine hydroxylase (EC 1.14.99.29)
DeoxPhosAldo	Deoxyribose-phosphate aldolase (EC 4.1.2.4)
DeoxPhot2	Deoxyribodipyrimidine photolyase (EC 4.1.99.3)
DeoxPhotSingStra	Deoxyribodipyrimidine photolyase, single-strand-specific
DeoxPhotTypeIi	Deoxyribodipyrimidine photolyase, type II (EC 4.1.99.3)
DeoxSynt	Deoxyhypusine synthase (EC 2.5.1.46)
DeoxTatd	Deoxyribonuclease TatD
DephCoaKina	Dephospho-CoA kinase (EC 2.7.1.24)
DephCoaKinaArchPred	Dephospho-CoA kinase archaeal, predicted (EC 2.7.1.24)
DesfEBiosProtDesa	Desferrioxamine E biosynthesis protein DesA
DesfEBiosProtDesb	Desferrioxamine E biosynthesis protein DesB
DesfEBiosProtDesc	Desferrioxamine E biosynthesis protein DesC
DesfEBiosProtDesd	Desferrioxamine E biosynthesis protein DesD
DethSynt	Dethiobiotin synthetase (EC 6.3.3.3)
DeubProtElad	Deubiquitinating protease ElaD
DhaSpecEiComp	DHA-specific EI component
DhaSpecIiaComp	DHA-specific IIA component
DhaSpecPhosProtHpr	DHA-specific phosphocarrier protein HPr
DiTripPermYbgh	Di/tripeptide permease YbgH
DiacKina	Diacylglycerol kinase (EC 2.7.1.107)
DiadCyclSpyd	Diadenylate cyclase spyDAC
DiadHexaHydr	Diadenosine hexaphosphate (Ap6A) hydrolase
Diam2OxogAmin	Diaminobutyrate--2-oxoglutarate aminotransferase (EC 2.6.1.76)
Diam2OxogTran	Diaminobutyrate--2-oxoglutarate transaminase (EC 2.6.1.76)
DiamAmmoLyas	Diaminopropionate ammonia-lyase (EC 4.3.1.15)
DiamDeam	Diaminohydroxyphosphoribosylaminopyrimidine deaminase (EC 3.5.4.26)
DiamDeca	Diaminopimelate decarboxylase (EC 4.1.1.20)
DiamDecaDiamEpim	Diaminopimelate decarboxylase and/or diaminopimelate epimerase leader peptide
DiamDipe	Diaminobutyrate dipeptidase
DiamEpim	Diaminopimelate epimerase (EC 5.1.1.7)
DiamEpimAlteForm	Diaminopimelate epimerase alternative form predicted for S.aureus (EC 5.1.1.7)
DiguCycl	Diguanylate cyclase (EC 2.7.7.65)
DiguCyclDgcc	Diguanylate cyclase => DgcC (EC 2.7.7.65)
DiguCyclDgce	Diguanylate cyclase => DgcE (EC 2.7.7.65)
DiguCyclDgcf	Diguanylate cyclase => DgcF (EC 2.7.7.65)
DiguCyclDgci	Diguanylate cyclase => DgcI (EC 2.7.7.65)
DiguCyclDgcj	Diguanylate cyclase => DgcJ (EC 2.7.7.65)
DiguCyclDgcm	Diguanylate cyclase => DgcM (EC 2.7.7.65)
DiguCyclDgcn	Diguanylate cyclase => DgcN (EC 2.7.7.65)
DiguCyclDgcp	Diguanylate cyclase => DgcP (EC 2.7.7.65)
DiguCyclDgcq	Diguanylate cyclase => DgcQ (EC 2.7.7.65)
DiguCyclDgct	Diguanylate cyclase => DgcT (EC 2.7.7.65)
DiguCyclDgcx	Diguanylate cyclase => DgcX (EC 2.7.7.65)
DiguCyclDgcy	Diguanylate cyclase => DgcY (EC 2.7.7.65)
DiguCyclGlobCoup	Diguanylate cyclase => Globin-coupled heme-based oxygen sensor DgcO (EC 2.7.7.65)
DiguCyclWithPasPac	diguanylate cyclase (GGDEF domain) with PAS/PAC sensor
DiguCyclZincRegu	Diguanylate cyclase => Zinc-regulated DgcZ (EC 2.7.7.65)
Dihy	Dihydroorotase (EC 3.5.2.3)
Dihy2	Dihydropyrimidinase (EC 3.5.2.2)
DihyAbcTranSystAtp	Dihydroxyacetone ABC transport system, ATP-binding protein
DihyAbcTranSystPerm	Dihydroxyacetone ABC transport system, permease protein 2
DihyAbcTranSystPerm2	Dihydroxyacetone ABC transport system, permease protein
DihyAbcTranSystSubs	Dihydroxyacetone ABC transport system, substrate-binding protein
DihyAcetCompAcet	Dihydrolipoamide acetyltransferase component (E2) of acetoin dehydrogenase complex (EC 2.3.1.12)
DihyAcetCompPyru	Dihydrolipoamide acetyltransferase component of pyruvate dehydrogenase complex (EC 2.3.1.12)
DihyAcidDehy	Dihydroxy-acid dehydratase (EC 4.2.1.9)
DihyAcylCompBran	Dihydrolipoamide acyltransferase component of branched-chain alpha-keto acid dehydrogenase complex (EC 2.3.1.168)
DihyAldo	Dihydroneopterin aldolase (EC 4.1.2.25)
DihyDehy2	Dihydroorotate dehydrogenase (quinone) (EC 1.3.5.2)
DihyDehy2OxogDehy	Dihydrolipoamide dehydrogenase of 2-oxoglutarate dehydrogenase (EC 1.8.1.4)
DihyDehy3	Dihydrolipoamide dehydrogenase (EC 1.8.1.4)
DihyDehyAcetDehy	Dihydrolipoamide dehydrogenase of acetoin dehydrogenase (EC 1.8.1.4)
DihyDehyBranChai	Dihydrolipoamide dehydrogenase of branched-chain alpha-keto acid dehydrogenase (EC 1.8.1.4)
DihyDehyCataSubu2	Dihydroorotate dehydrogenase, catalytic subunit (EC 1.3.3.1)
DihyDehyElecTran	Dihydroorotate dehydrogenase (NAD(+)), electron transfer subunit (EC 1.3.1.14)
DihyDehyPyruDehy	Dihydrolipoamide dehydrogenase of pyruvate dehydrogenase complex (EC 1.8.1.4)
DihyKinaAtpDepe	Dihydroxyacetone kinase, ATP-dependent (EC 2.7.1.29)
DihyKinaFamiProt	Dihydroxyacetone kinase family protein
DihyKinaLikeProt	Dihydroxyacetone kinase-like protein, phosphatase domain
DihyKinaLikeProt2	Dihydroxyacetone kinase-like protein, kinase domain
DihyPhosPhos	Dihydroneopterin phosphate phosphatase (EC 3.6.1.-)
DihyRedu2	Dihydrofolate reductase (EC 1.5.1.3)
DihySuccComp2Oxog	Dihydrolipoamide succinyltransferase component (E2) of 2-oxoglutarate dehydrogenase complex (EC 2.3.1.61)
DihySynt	Dihydrofolate synthase (EC 6.3.2.12)
DihySynt2	Dihydropteroate synthase (EC 2.5.1.15)
DihySyntPcheNonRibo	Dihydroaeruginoate synthetase PchE, non-ribosomal peptide synthetase modules
DihySyntType2n1	Dihydropteroate synthase type-2 (EC 2.5.1.15)
DihyTripPyro	Dihydroneopterin triphosphate pyrophosphohydolase
DihyTripPyroPuta	Dihydroneopterin triphosphate pyrophosphohydolase, putative, Actinobacterial type, NudB-like
DihyTripPyroType	Dihydroneopterin triphosphate pyrophosphohydolase type 2
DihyTripPyroType3	Dihydroneopterin triphosphate pyrophosphohydrolase type 2
DimeCoaTranLyasDddd	Dimethylsulfoniopropionate CoA transferase/lyase DddD, 3-hydroxypropionate generating
DimeCorrProtCoMeth	[Dimethylamine--corrinoid protein] Co-methyltransferase (EC 2.1.1.249)
DimeDeme	Dimethylsulfoniopropionate demethylase (EC 2.1.1.269)
DimeDutp	Dimeric dUTPase (EC 3.6.1.23)
DimeHydrLargSubu	Dimethylmaleate hydratase, large subunit (EC 4.2.1.85)
DimeHydrSmalSubu	Dimethylmaleate hydratase, small subunit (EC 4.2.1.85)
DimeLyasDddl	Dimethylsulfoniopropionate (DSMP) lyase DddL (EC 4.4.1.3)
DimeLyasDddp	Dimethylsulfoniopropionate (DSMP) lyase DddP
DimeLyasDddq	Dimethylsulfoniopropionate (DSMP) lyase DddQ
DimeLyasDddw	Dimethylsulfoniopropionate (DSMP) lyase DddW
DimeMethCorrProt	Dimethylamine methyltransferase corrinoid protein
DimeNMeth2	Dimethylglycine N-methyltransferase (EC 2.1.1.161)
DimePerm	Dimethylamine permease
DimeTran3	Dimethylsulfoniopropionate transporter
DingFamiAtpDepeHeli	DinG family ATP-dependent helicase YoaA
DingFamiAtpDepeHeli2	DinG family ATP-dependent helicase YpvA
DingFamiAtpDepeHeli3	DinG family ATP-dependent helicase CPE1197
DipeBindAbcTranPeri	Dipeptide-binding ABC transporter, periplasmic substrate-binding component (TC 3.A.1.5.2)
DipeCarbDcp	Dipeptidyl carboxypeptidase Dcp (EC 3.4.15.5)
DipePeptIv4HydrCata	Dipeptidyl peptidase IV in 4-hydroxyproline catabolic gene cluster
DipeTranAtpBindProt	Dipeptide transport ATP-binding protein DppF (TC 3.A.1.5.2)
DipeTranAtpBindProt2	Dipeptide transport ATP-binding protein DppD (TC 3.A.1.5.2)
DipeTranSystPerm	Dipeptide transport system permease protein DppB (TC 3.A.1.5.2)
DipeTranSystPerm2	Dipeptide transport system permease protein DppC (TC 3.A.1.5.2)
DiphAmmoLiga	Diphthine--ammonia ligase (EC 6.3.1.14)
DiphBiosProt1n1	Diphthamide biosynthesis protein 1
DiphBiosProt2n1	Diphthamide biosynthesis protein 2
DiphBiosProt3n1	Diphthamide biosynthesis protein 3
DiphBiosProt4n1	Diphthamide biosynthesis protein 4
DiphDeca	Diphosphomevalonate decarboxylase (EC 4.1.1.33)
DiphMeth	Diphthine methyltransferase (EC 3.1.1.97)
DiphMethEsteSynt	Diphthine methyl ester synthase (EC 2.1.1.314)
DiphSynt	Diphthine synthase (EC 2.1.1.98)
DiphToxiDiphAdpRibo	Diphtheria toxin (NAD(+)--diphthamide ADP- ribosyltransferase) (EC 2.4.2.36)
DiphToxiRepr	diphtheria toxin repressor
DipiSyntSubu	Dipicolinate synthase subunit A (EC 4.2.1.52)
DipiSyntSubuB	Dipicolinate synthase subunit B
DissSulfReduAlph3	Dissimilatory sulfite reductase, alpha subunit (EC 1.8.99.3)
DissSulfReduBeta	Dissimilatory sulfite reductase, beta subunit (EC 1.8.99.3)
DissSulfReduClus	Dissimilatory sulfite reductase clustered protein DsrD
DistHomoEColiHemx	Distant homolog of E. coli HemX protein in Xanthomonadaceae
DistHomoHypoProt	Distant homolog of hypothetical protein SA_21
DistRelaMembProt	Distantly related to membrane protein YedZ
DistSimiWithLeuk	Distant similarity with leukotriene C4 synthase (microsomal glutathione S-transferase)
DistSimiWithPhos	Distant similarity with phosphate transport system regulator
DistSimiWithVira	Distant similarity with viral glycoprotein gp160 of HIV type 1
DisuBondRegu	Disulfide bond regulator
DiviChlo8VinyRedu	Divinyl (proto)chlorophyllide a 8-vinyl-reductase (EC 1.3.1.75)
DiviChlo8VinyRedu2	Divinyl (proto)chlorophyllide a 8-vinyl-reductase, cyanobacterial type (EC 1.3.1.75)
Dj1YajlPfpiSupeIncl	DJ-1/YajL/PfpI superfamily, includes chaperone protein YajL (former ThiJ), parkinsonism-associated protein DJ-1, peptidases PfpI, Hsp31
DmspDemeTranRegu	DMSP demethylase transcriptional regulator
Dna3MethGlyc	DNA-3-methyladenine glycosylase (EC 3.2.2.20)
Dna3MethGlycIi	DNA-3-methyladenine glycosylase II (EC 3.2.2.21)
DnaBindCapsSyntResp	DNA-binding capsular synthesis response regulator RcsB
DnaBindDomaMode	DNA-binding domain of ModE
DnaBindHthDomaRibo	DNA-binding HTH domain in riboflavin kinase
DnaBindProtDoexEcto	DNA-binding protein DoeX, ectoine utilization regulator
DnaBindProtFig0n1	DNA binding protein, FIG046916
DnaBindProtHbsu	DNA-binding protein HBsu
DnaBindProtHpkr	DNA binding protein HpkR
DnaBindProtHuAlph	DNA-binding protein HU-alpha
DnaBindProtSaBact	DNA binding protein [SA bacteriophages 11, Mu50B]
DnaBindProtSpov	DNA-binding protein SpoVG
DnaBindRespReguChvi	DNA-binding response regulator ChvI
DnaBindRespReguKdpe	DNA-binding response regulator KdpE
DnaBindRespReguLuxr	DNA-binding response regulator, LuxR family, near polyamine transporter
DnaBindRespReguMg	DNA-binding response regulator in Mg(2+) transport ATPase cluster
DnaBindTranDualRegu	DNA-binding transcriptional dual regulator SoxS
DnaBindTranDualRegu2	DNA-binding transcriptional dual regulator Rob
DnaDamaInduProtI	DNA-damage-inducible protein I
DnaDireRnaPolyAlph	DNA-directed RNA polymerase alpha subunit (EC 2.7.7.6)
DnaDireRnaPolyAlph2	DNA-directed RNA polymerase alpha subunit domain
DnaDireRnaPolyBeta	DNA-directed RNA polymerase beta' subunit (EC 2.7.7.6)
DnaDireRnaPolyBeta2	DNA-directed RNA polymerase beta subunit (EC 2.7.7.6)
DnaDireRnaPolyBeta4	DNA-directed RNA polymerase beta' subunit, cyanobacterial form (EC 2.7.7.6)
DnaDireRnaPolyDelt	DNA-directed RNA polymerase delta subunit (EC 2.7.7.6)
DnaDireRnaPolyGamm	DNA-directed RNA polymerase gamma subunit (EC 2.7.7.6)
DnaDireRnaPolyI13n1	DNA-directed RNA polymerase I 13.7 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyI34n1	DNA-directed RNA polymerase I 34 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyI36n1	DNA-directed RNA polymerase I 36 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyI49n1	DNA-directed RNA polymerase I 49 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIIi	DNA-directed RNA polymerases I, II, and III 14.5 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIIi2	DNA-directed RNA polymerases I, II, and III 8.3 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIIi3	DNA-directed RNA polymerases I, II, and III 15 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIIi4	DNA-directed RNA polymerases I, II, and III 27 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIIi5	DNA-directed RNA polymerases I, II, and III 7.7 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIIii	DNA-directed RNA polymerases I and III 16 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIIii2	DNA-directed RNA polymerases I and III 40 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyILarg	DNA-directed RNA polymerase I largest subunit (EC 2.7.7.6)
DnaDireRnaPolyISeco	DNA-directed RNA polymerase I second largest subunit (EC 2.7.7.6)
DnaDireRnaPolyIi2	DNA-directed RNA polymerase II 13.3 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIi3	DNA-directed RNA polymerase II 32 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIi4	DNA-directed RNA polymerase II 45 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIi5	DNA-directed RNA polymerase II largest subunit (EC 2.7.7.6)
DnaDireRnaPolyIi6	DNA-directed RNA polymerase II 13.2 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIi7	DNA-directed RNA polymerase II 19 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIi8	DNA-directed RNA polymerase II second largest subunit (EC 2.7.7.6)
DnaDireRnaPolyIii	DNA-directed RNA polymerase III 25 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIii10	DNA-directed RNA polymerase III 17 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIii2	DNA-directed RNA polymerase III second largest subunit (EC 2.7.7.6)
DnaDireRnaPolyIii3	DNA-directed RNA polymerase III 47 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIii4	DNA-directed RNA polymerase III 74 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIii5	DNA-directed RNA polymerase III 36 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIii6	DNA-directed RNA polymerase III largest subunit (EC 2.7.7.6)
DnaDireRnaPolyIii7	DNA-directed RNA polymerase III 31 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIii8	DNA-directed RNA polymerase III 37/80 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyIii9	DNA-directed RNA polymerase III 12.5 kDa polypeptide (EC 2.7.7.6)
DnaDireRnaPolyOmeg	DNA-directed RNA polymerase omega subunit (EC 2.7.7.6)
DnaDireRnaPolyPuta	DNA-directed RNA polymerase, putative subunit M (RpoM-like) (EC 2.7.7.6)
DnaDireRnaPolySubu	DNA-directed RNA polymerase subunit D (EC 2.7.7.6)
DnaDireRnaPolySubu10	DNA-directed RNA polymerase subunit Rpo13 (EC 2.7.7.6)
DnaDireRnaPolySubu11	DNA-directed RNA polymerase subunit K (EC 2.7.7.6)
DnaDireRnaPolySubu12	DNA-directed RNA polymerase subunit E' (EC 2.7.7.6)
DnaDireRnaPolySubu13	DNA-directed RNA polymerase subunit E''
DnaDireRnaPolySubu14	DNA-directed RNA polymerase subunit P (EC 2.7.7.6)
DnaDireRnaPolySubu15	DNA-directed RNA polymerase subunit B'' (EC 2.7.7.6)
DnaDireRnaPolySubu16	DNA-directed RNA polymerase subunit B' (EC 2.7.7.6)
DnaDireRnaPolySubu2	DNA-directed RNA polymerase subunit N (EC 2.7.7.6)
DnaDireRnaPolySubu20	DNA-directed RNA polymerase subunit A (EC 2.7.7.6)
DnaDireRnaPolySubu26	DNA-directed RNA polymerase subunit M (EC 2.7.7.6)
DnaDireRnaPolySubu3	DNA-directed RNA polymerase subunit F (EC 2.7.7.6)
DnaDireRnaPolySubu4	DNA-directed RNA polymerase subunit G (EC 2.7.7.6)
DnaDireRnaPolySubu5	DNA-directed RNA polymerase subunit H (EC 2.7.7.6)
DnaDireRnaPolySubu6	DNA-directed RNA polymerase subunit B (EC 2.7.7.6)
DnaDireRnaPolySubu7	DNA-directed RNA polymerase subunit A' (EC 2.7.7.6)
DnaDireRnaPolySubu8	DNA-directed RNA polymerase subunit A'' (EC 2.7.7.6)
DnaDireRnaPolySubu9	DNA-directed RNA polymerase subunit L (EC 2.7.7.6)
DnaDoubStraBreaRepa	DNA double-strand break repair Rad50 ATPase
DnaDoubStraBreaRepa2	DNA double-strand break repair protein Mre11
DnaGyraInhiYacg	DNA gyrase inhibitor YacG
DnaGyraSubu	DNA gyrase subunit A (EC 5.99.1.3)
DnaGyraSubuB	DNA gyrase subunit B (EC 5.99.1.3)
DnaHeli2	DNA helicase (Rad25 homolog)
DnaHeliIv	DNA helicase IV (EC 3.6.4.12)
DnaHeliSaBact11Mu50n1	DNA helicase [SA bacteriophages 11, Mu50B]
DnaInteRelaCompProt	DNA internalization-related competence protein ComEC/Rec2
DnaLiga2	DNA ligase (NAD(+)) (EC 6.5.1.2)
DnaMismRepaEndoMuth	DNA mismatch repair endonuclease MutH
DnaMismRepaProtMutl	DNA mismatch repair protein MutL
DnaMismRepaProtMuts	DNA mismatch repair protein MutS
DnaPolyI	DNA polymerase I (EC 2.7.7.7)
DnaPolyIi	DNA polymerase II (EC 2.7.7.7)
DnaPolyIiiAlphSubu	DNA polymerase III alpha subunit (EC 2.7.7.7)
DnaPolyIiiBetaSubu	DNA polymerase III beta subunit (EC 2.7.7.7)
DnaPolyIiiChiSubu	DNA polymerase III chi subunit (EC 2.7.7.7)
DnaPolyIiiDeltPrim	DNA polymerase III delta prime subunit (EC 2.7.7.7)
DnaPolyIiiDeltSubu	DNA polymerase III delta subunit (EC 2.7.7.7)
DnaPolyIiiEpsiSubu	DNA polymerase III epsilon subunit (EC 2.7.7.7)
DnaPolyIiiSubuGamm	DNA polymerase III subunits gamma and tau (EC 2.7.7.7)
DnaPolyIv	DNA polymerase IV (EC 2.7.7.7)
DnaPolyLikeProtMt31n1	DNA polymerase-like protein MT3142
DnaPolyLikeProtPa06n1	DNA polymerase-like protein PA0670
DnaPolySlidClamProt	DNA polymerase sliding clamp protein PCNA
DnaPrim	DNA primase (EC 2.7.7.-)
DnaPrimPhagP4Asso	DNA primase, Phage P4-associated (EC 2.7.7.-)
DnaPrimSmalSubu	DNA primase small subunit (EC 2.7.7.-)
DnaProtDuriStarProt	DNA protection during starvation protein
DnaRecoDepeGrowFact	DNA recombination-dependent growth factor C
DnaRecoProtRmuc	DNA recombination protein RmuC
DnaRecoRepaProtRecf	DNA recombination and repair protein RecF
DnaRecoRepaProtReco	DNA recombination and repair protein RecO
DnaRepaExonFamiProt	DNA repair exonuclease family protein YhaO
DnaRepaProtRad5Homo	DNA repair protein RAD51 homolog 2
DnaRepaProtRad5Homo2	DNA repair protein RAD51 homolog 3
DnaRepaProtRad5Homo3	DNA repair protein RAD51 homolog 4
DnaRepaProtRad5n1	DNA repair protein RAD51
DnaRepaProtRad5n2	DNA repair protein RAD57
DnaRepaProtRada	DNA repair protein RadA
DnaRepaProtRadc	DNA repair protein RadC
DnaRepaProtRecn	DNA repair protein RecN
DnaRepaRecoProtRada	DNA repair and recombination protein RadA
DnaRepaRecoProtRadb	DNA repair and recombination protein RadB
DnaReplIntiContProt	DNA replication intiation control protein YabA
DnaReveGyra2	DNA reverse gyrase (EC 5.99.1.3) (EC 3.6.4.12)
DnaTopoI	DNA topoisomerase I (EC 5.99.1.2)
DnaTopoIi	DNA topoisomerase II (EC 5.99.1.3)
DnaTopoIii	DNA topoisomerase III (EC 5.99.1.2)
DnaTopoIiiPfgi1Like	DNA topoisomerase III in PFGI-1-like cluster (EC 5.99.1.2)
DnaTopoViSubu	DNA topoisomerase VI subunit A (EC 5.99.1.3)
DnaTopoViSubuB	DNA topoisomerase VI subunit B (EC 5.99.1.3)
DnaTranFtsk	DNA translocase FtsK
DnaTranProtTfox	DNA transformation protein TfoX
DnajClasMoleChap	DnaJ-class molecular chaperone CbpA
DnajLikeProtDjla	DnaJ-like protein DjlA
DnakLikeChapProt	DnaK-like chaperone protein slr0086
DntpTripBroaSubs	dNTP triphosphohydrolase, broad substrate specificity
DoliPhosMann	Dolichol-phosphate mannosyltransferase (EC 2.4.1.83)
DoliPhosMannLipi	Dolichol-phosphate mannosyltransferase in lipid-linked oligosaccharide synthesis cluster (EC 2.4.1.83)
DomaSimiCystTrna	domain similar to cysteinyl-tRNA synthetase and MshC
DomaUnknFuncDuf1n7	Domain of unknown function DUF1537
DsdnMimiProtHigh	dsDNA mimic protein, highly acidic
Dtdp3Amin36DideAlph2	dTDP-3-amino-3,6-dideoxy-alpha-D-galactopyranose 3-N-acetyltransferase (EC 2.3.1.197)
Dtdp3Amin36DideAlph3	dTDP-3-amino-3,6-dideoxy-alpha-D-galactopyranose transaminase (EC 2.6.1.90)
Dtdp4Amin46DideTran	dTDP-4-amino-4,6-dideoxygalactose transaminase (EC 2.6.1.59)
Dtdp4Dehy35Epim	dTDP-4-dehydrorhamnose 3,5-epimerase (EC 5.1.3.13)
Dtdp4DehyRedu	dTDP-4-dehydrorhamnose reductase (EC 1.1.1.133)
Dtdp6Deox34KetoHexu	dTDP-6-deoxy-3,4-keto-hexulose isomerase (EC 5.3.2.3)
DtdpFucoAcet	dTDP-fucosamine acetyltransferase (EC 2.3.1.210)
DtdpGluc46Dehy	dTDP-glucose 4,6-dehydratase (EC 4.2.1.46)
DtdpRhaDGlcnDiph	dTDP-Rha:A-D-GlcNAc-diphosphoryl polyprenol, A-3-L-rhamnosyl transferase WbbL
DtdpRhamTranRfbf	dTDP-rhamnosyl transferase RfbF (EC 2.-.-.-)
Duf1Doma	DUF1294 domain
Duf1DomaContProt2	DUF1022 domain-containing protein
Duf1SupeProt	DUF1450 superfamily protein
Duf1SupeProt2	DUF1054 superfamily protein
Duf3FamiProtYaar	DUF327 family protein YaaR
Duf7ProtCompGProt	DUF742 protein, component of G-protein-coupled receptor (GPCR) system
Duf8Doma	DUF88 domain
DuplAtpaCompYkod	Duplicated ATPase component YkoD of energizing module of thiamin-regulated ECF transporter for HydroxyMethylPyrimidine
DuplAtpaCompYkod2	Duplicated ATPase component YkoD of energizing module of thiamin-regulated ECF transporter for Thiamin
DyeDecoPero	Dye-decolorizing peroxidase (EC 1.11.1.7)
EcscProt	EcsC protein
EctoHydr	Ectoine hydroxylase (EC 1.17.-.-)
EctoHydr2	Ectoine hydrolase
EctoHydrAbcTranAtp	Ectoine/hydroxyectoine ABC transporter ATP-binding protein, EhuA
EctoHydrAbcTranPerm	Ectoine/hydroxyectoine ABC transporter permease protein, EhuC
EctoHydrAbcTranPerm2	Ectoine/hydroxyectoine ABC transporter permease protein, EhuD
EctoHydrAbcTranSolu	Ectoine/hydroxyectoine ABC transporter solute-binding protein, EhuB
EctoHydrTrapTran	Ectoine/hydroxyectoine TRAP transporter large permease protein TeaC
EctoHydrTrapTran2	Ectoine/hydroxyectoine TRAP transporter small permease protein TeaB
EctoHydrTrapTran3	Ectoine/hydroxyectoine TRAP transporter substrate-binding periplasmic protein TeaA
EctoSynt	Ectoine synthase (EC 4.2.1.108)
EctoUtilProtEuta	Ectoine utilization protein EutA, probable arylmalonate decarboxylase
EctoUtilProtEutb	Ectoine utilization protein EutB, threonine dehydratase-like
EctoUtilProtEutc	Ectoine utilization protein EutC, similar to ornithine cyclodeaminase
EffeProtPrecPept	Effector protein precursor peptide YydF
EfflAbcTranForGlut	Efflux ABC transporter for glutathione/L-cysteine, essential for assembly of bd-type respiratory oxidases => CydD subunit
EfflAbcTranForGlut2	Efflux ABC transporter for glutathione/L-cysteine, essential for assembly of bd-type respiratory oxidases => CydC subunit
EfflPumpTranTrip	Efflux pump transporter (MSF type) of tripartite multidrug efflux system in Aquificae
EfflSystAssoWith	Efflux system associated with Geranylgeranyl-PP synthase, outer membrane factor (OMF) lipoprotein
EfflSystAssoWith2	Efflux system associated with Geranylgeranyl-PP synthase, membrane fusion component
EfflSystAssoWith3	Efflux system associated with Geranylgeranyl-PP synthase, inner membrane transporter (RND type)
EfflTranSystOute	Efflux transport system, outer membrane factor (OMF) lipoprotein
EfflTranSystOute2	Efflux transport system, outer membrane factor (OMF) in Bacteroidetes/Chlorobi
EfflTranSystOute3	Efflux transport system, outer membrane factor (OMF) in Aquificae
EighTranProtEpsh	Eight transmembrane protein EpsH
ElasBindProtEbps	Elastin binding protein EbpS
ElecBifuButyCoaDehy	Electron bifurcating butyryl-CoA dehydrogenase, electron transfer flavoprotein alpha
ElecBifuButyCoaDehy2	Electron bifurcating butyryl-CoA dehydrogenase, electron transfer flavoprotein beta
ElecBifuButyCoaDehy3	Electron bifurcating butyryl-CoA dehydrogenase (NAD+, ferredoxin)
ElecBifuCaffCoaRedu	Electron-bifurcating caffeyl-CoA reductase-Etf complex, electron transfer flavoprotein subunit alpha
ElecBifuCaffCoaRedu2	Electron-bifurcating caffeyl-CoA reductase-Etf complex, electron transfer flavoprotein subunit beta
ElecBifuCaffCoaRedu3	Electron-bifurcating caffeyl-CoA reductase-Etf complex, caffeyl-CoA reductase subunit
ElecBifuCaffCoaRedu4	Electron-bifurcating caffeyl-CoA reductase associated protein CarB
ElecBifuCaffCoaRedu5	Electron-bifurcating caffeyl-CoA reductase associated protein CarA
ElecBifuFefeHydr	Electron-bifurcating [FeFe]-hydrogenase subunit A (hydrogenase)
ElecBifuFefeHydr2	Electron-bifurcating [FeFe]-hydrogenase subunit B (NAD+ reductase, ferredoxin reductase)
ElecBifuFefeHydr3	Electron-bifurcating [FeFe]-hydrogenase subunit C (2Fe2S protein)
ElecBifuFefeHydr4	Electron-bifurcating [FeFe]-hydrogenase subunit D
ElecTranCompProt	Electron transport complex protein RnfA
ElecTranCompProt2	Electron transport complex protein RnfB
ElecTranCompProt3	Electron transport complex protein RnfC
ElecTranCompProt4	Electron transport complex protein RnfD
ElecTranCompProt5	Electron transport complex protein RnfG
ElecTranCompProt6	Electron transport complex protein RnfE
ElecTranFlavAlph	Electron transfer flavoprotein, alpha subunit
ElecTranFlavAlph9	Electron transfer flavoprotein, alpha subunit => Mycofactocin system
ElecTranFlavBeta	Electron transfer flavoprotein, beta subunit
ElecTranFlavBeta9	Electron transfer flavoprotein, beta subunit => Mycofactocin system
ElecTranFlavQuin8	Electron transfer flavoprotein-quinone oxidoreductase ecFixC => Mycofactocin system
ElonFactGLikeProt	Elongation factor G-like protein TM_1651
ElonFactPLikeProt	Elongation factor P-like protein
Enam	Enamidase (EC 3.5.2.18)
EnanPyocBiosProt	Enantio-pyochelin biosynthetic protein PchC, predicted thioesterase
EnanPyocBiosProt2	Enantio-pyochelin biosynthetic protein PchK, putative reductoisomerase
EnanPyocSyntPchf	Enantio-pyochelin synthetase PchF, non-ribosomal peptide synthetase module
EncaProtForDypType	Encapsulating protein for a DyP-type peroxidase or ferritin-like protein oligomers
Endo14BetaXylaPrec	Endo-1,4-beta-xylanase A precursor (EC 3.2.1.8)
EndoIii	Endonuclease III (EC 4.2.99.18)
EndoIv	Endonuclease IV (EC 3.1.21.2)
EndoLAlanDGlutPept	Endolysin, L-alanyl-D-glutamate peptidase [Bacteriophage A118] (EC 3.4.-.-)
EndoQClea5DamaDna	Endonuclease Q, cleaves 5' to damaged DNA bases
EndoV	Endonuclease V (EC 3.1.21.7)
EndoViii	Endonuclease VIII
EnerConsHydrEhaAsso	Energy conserving hydrogenase Eha associated protein (protein R)
EnerConsHydrEhaAsso2	Energy conserving hydrogenase Eha associated gene 2
EnerConsHydrEhaAsso3	Energy conserving hydrogenase Eha associated polyferredoxin
EnerConsHydrEhaAsso4	Energy conserving hydrogenase Eha-associated regulator
EnerConsHydrEhaAsso5	Energy conserving hydrogenase Eha associated protein, ribokinase homolog (protein T)
EnerConsHydrEhaAsso6	Energy conserving hydrogenase Eha associated protein (protein S)
EnerConsHydrEhaFerr	Energy conserving hydrogenase Eha ferredoxin (protein P2)
EnerConsHydrEhaLarg	Energy conserving hydrogenase Eha large subunit homolog (protein O)
EnerConsHydrEhaPoly	Energy conserving hydrogenase Eha polyferredoxin (protein P3)
EnerConsHydrEhaPoly2	Energy conserving hydrogenase Eha polyferredoxin (protein P)
EnerConsHydrEhaPoly3	Energy conserving hydrogenase Eha polyferredoxin (protein P4)
EnerConsHydrEhaPoly4	Energy conserving hydrogenase Eha polyferredoxin domain (protein P')
EnerConsHydrEhaProt	Energy conserving hydrogenase Eha protein T
EnerConsHydrEhaProt2	Energy conserving hydrogenase Eha protein M
EnerConsHydrEhaProt3	Energy conserving hydrogenase Eha proton-sodium antiporter homolog protein H
EnerConsHydrEhaProt4	Energy conserving hydrogenase Eha protein M2
EnerConsHydrEhaSmal	Energy conserving hydrogenase Eha small subunit homolog (protein N)
EnerConsHydrEhaTran	Energy conserving hydrogenase Eha transmembrane protein L
EnerConsHydrEhaTran10	Energy conserving hydrogenase Eha transmembrane protein J
EnerConsHydrEhaTran11	Energy conserving hydrogenase Eha transmembrane protein K
EnerConsHydrEhaTran12	Energy conserving hydrogenase Eha transmembrane protein K2
EnerConsHydrEhaTran13	Energy conserving hydrogenase Eha transmembrane protein I2
EnerConsHydrEhaTran14	Energy conserving hydrogenase Eha transmembrane protein I3
EnerConsHydrEhaTran15	Energy conserving hydrogenase Eha transmembrane protein K3
EnerConsHydrEhaTran2	Energy conserving hydrogenase Eha transmembrane protein A
EnerConsHydrEhaTran3	Energy conserving hydrogenase Eha transmembrane protein B
EnerConsHydrEhaTran4	Energy conserving hydrogenase Eha transmembrane protein C
EnerConsHydrEhaTran5	Energy conserving hydrogenase Eha transmembrane protein D
EnerConsHydrEhaTran6	Energy conserving hydrogenase Eha transmembrane protein E
EnerConsHydrEhaTran7	Energy conserving hydrogenase Eha transmembrane protein F
EnerConsHydrEhaTran8	Energy conserving hydrogenase Eha transmembrane protein G
EnerConsHydrEhaTran9	Energy conserving hydrogenase Eha transmembrane protein I
EnerConsHydrEhbAnch	Energy conserving hydrogenase Ehb anchor subunit F
EnerConsHydrEhbFerr	Energy conserving hydrogenase Ehb ferredoxin-containing protein L
EnerConsHydrEhbInte	Energy conserving hydrogenase Ehb integral membrane protein O
EnerConsHydrEhbLarg	Energy conserving hydrogenase Ehb large subunit (protein N)
EnerConsHydrEhbPoly	Energy conserving hydrogenase Ehb polyferredoxin (protein K)
EnerConsHydrEhbProt	Energy conserving hydrogenase Ehb protein H
EnerConsHydrEhbProt10	Energy conserving hydrogenase Ehb protein G
EnerConsHydrEhbProt2	Energy conserving hydrogenase Ehb protein I
EnerConsHydrEhbProt3	Energy conserving hydrogenase Ehb protein Q
EnerConsHydrEhbProt4	Energy conserving hydrogenase Ehb protein J
EnerConsHydrEhbProt5	Energy conserving hydrogenase Ehb protein B
EnerConsHydrEhbProt6	Energy conserving hydrogenase Ehb protein A
EnerConsHydrEhbProt7	Energy conserving hydrogenase Ehb protein D
EnerConsHydrEhbProt8	Energy conserving hydrogenase Ehb protein P
EnerConsHydrEhbProt9	Energy conserving hydrogenase Ehb protein C
EnerConsHydrEhbSmal	Energy conserving hydrogenase Ehb small subunit (protein M)
EnerConsHydrEhbTran	Energy conserving hydrogenase Ehb transmembrane protein E
EnerConsHydrSubu	Energy-conserving hydrogenase (ferredoxin), subunit F
EnerConsHydrSubu2	Energy-conserving hydrogenase (ferredoxin), subunit E
EnerConsHydrSubu3	Energy-conserving hydrogenase (ferredoxin), subunit D
EnerConsHydrSubu4	Energy-conserving hydrogenase (ferredoxin), subunit C
EnerConsHydrSubu5	Energy-conserving hydrogenase (ferredoxin), subunit B
EnerConsHydrSubu6	Energy-conserving hydrogenase (ferredoxin), subunit A
EnerDepeTranThro	Energy-dependent translational throttle protein EttA
Enol	Enolase (EC 4.2.1.11)
EnoyAcylCarrProt	Enoyl-[acyl-carrier-protein] reductase [NADH] (EC 1.3.1.9)
EnoyAcylCarrProt2	Enoyl-[acyl-carrier-protein] reductase [FMN], inferred for PFA pathway (EC 1.3.1.9)
EnoyAcylCarrProt3	Enoyl-[acyl-carrier-protein] reductase [FMN] (EC 1.3.1.9)
EnoyAcylCarrProt4	Enoyl-[acyl-carrier-protein] reductase [NADPH] (EC 1.3.1.10)
EnoyCoaHydr	Enoyl-CoA hydratase (EC 4.2.1.17)
EnoyCoaHydrAnthBios	Enoyl-CoA hydratase, anthrose biosynthesis (EC 4.2.1.17)
EnoyCoaHydrDegrBran	Enoyl-CoA hydratase => degradation of branched-chain amino acids and alpha-keto acids (EC 4.2.1.17)
EnoyCoaHydrFadnFada	Enoyl-CoA hydratase [fadN-fadA-fadE operon] (EC 4.2.1.17)
EnoyCoaHydrIsolDegr	Enoyl-CoA hydratase [isoleucine degradation] (EC 4.2.1.17)
EnoyCoaHydrValiDegr	Enoyl-CoA hydratase [valine degradation] (EC 4.2.1.17)
EnteBSubu	Enterotoxin, B subunit
EnteEste	Enterobactin esterase
EnteExpoEnts	enterobactin exporter EntS
EnteReceIrga	Enterobactin receptor IrgA
EnteReceVcta	Enterobactin receptor VctA
EnteSubuDiphAdpRibo	Enterotoxin, A subunit (NAD(+)--diphthamide ADP- ribosyltransferase) (EC 2.4.2.36)
EnteSyntCompFSeri	Enterobactin synthetase component F, serine activating enzyme (EC 2.7.7.-)
EpiInosHydr	Epi-inositol hydrolase (EC 3.7.1.-)
EpoxRedu	Epoxyqueuosine reductase (EC 1.17.99.6)
EpsiProt	EpsI protein
ErroPronLesiBypa	Error-prone, lesion bypass DNA polymerase V (UmuC)
ErroPronRepaProt	Error-prone repair protein UmuD (EC 3.4.21.-)
Eryt4PhosDehy	Erythronate-4-phosphate dehydrogenase (EC 1.1.1.290)
EsacProtWithEsat	EsaC protein within ESAT-6 gene cluster (S.aureus type)
Esat6LikeProtEsxc2	ESAT-6-like protein EsxC
Esat6LikeProtEsxd2	ESAT-6-like protein EsxD
Esat6LikeProtEsxg	ESAT-6-like protein EsxG
Esat6LikeProtEsxh	ESAT-6-like protein EsxH, 10 kDa antigen CFP7
Esat6LikeProtEsxm	ESAT-6-like protein EsxM
Esat6LikeProtEsxn	ESAT-6-like protein EsxN
Esat6LikeProtEsxs	ESAT-6 like protein EsxS
Esat6LikeProtEsxt	ESAT-6-like protein EsxT
Esat6LikeProtEsxu	ESAT-6-like protein EsxU
Esat6SecrWxg1Doma	ESAT-6-secreted WXG100 domain protein EsxV (B.anthracis)
Esat6SecrWxg1Doma2	ESAT-6-secreted WXG100 domain protein EsxW (B.anthracis)
Esat6SecrWxg1Doma3	ESAT-6-secreted WXG100 domain protein EsxL, contain toxin-deaminase domain (B.anthracis)
Esat6SecrWxg1Doma4	ESAT-6-secreted WXG100 domain protein, contains COG5444 domain (B.anthracis)
Esat6SecrWxg1Doma6	ESAT-6-secreted WXG100 domain protein
EsteLipaSideClus	Esterase/lipase in siderophore cluster
EsteYbff	Esterase ybfF (EC 3.1.-.-)
EthaAmmoLyasHeav	Ethanolamine ammonia-lyase heavy chain (EC 4.3.1.7)
EthaAmmoLyasLigh	Ethanolamine ammonia-lyase light chain (EC 4.3.1.7)
EthaOperReguProt	Ethanolamine operon regulatory protein
EthaPerm	Ethanolamine permease
EthaSensTranHist	Ethanolamine sensory transduction histidine kinase
EthaTwoCompRespRegu	Ethanolamine two-component response regulator
EthaUtilPolyBody	Ethanolamine utilization polyhedral-body-like protein EutM
EthaUtilPolyBody2	Ethanolamine utilization polyhedral-body-like protein EutK
EthaUtilPolyBody3	Ethanolamine utilization polyhedral-body-like protein EutL
EthaUtilPolyBody4	Ethanolamine utilization polyhedral-body-like protein EutN
EthaUtilPolyBody5	Ethanolamine utilization polyhedral-body-like protein EutS
EthaUtilProtEuta	Ethanolamine utilization protein EutA
EthaUtilProtEutg	Ethanolamine utilization protein EutG
EthaUtilProtEutj	Ethanolamine utilization protein EutJ
EthaUtilProtEutp	Ethanolamine utilization protein EutP
EthaUtilProtEutq	Ethanolamine utilization protein EutQ
EthaUtilProtSimi	Ethanolamine utilization protein similar to PduL
EthaUtilProtSimi2	Ethanolamine utilization protein similar to PduA/PduJ
EthaUtilProtSimi3	Ethanolamine utilization protein similar to PduV
EthaUtilProtSimi4	Ethanolamine utilization protein similar to PduU
EthaUtilProtSimi5	Ethanolamine utilization protein similar to PduT
EthyCoaDeca	Ethylmalonyl-CoA decarboxylase (EC 4.1.1.94)
EthyCoaMutaMethCoa	Ethylmalonyl-CoA mutase, methylsuccinyl-CoA-forming
EthyDehyAlphSubu	Ethylbenzene dehydrogenase alpha subunit (EC 1.17.99.2)
EthyDehyBetaSubu	Ethylbenzene dehydrogenase beta subunit (EC 1.17.99.2)
EthyDehyDeltSubu	Ethylbenzene dehydrogenase delta subunit (EC 1.17.99.2)
EthyDehyGammSubu	Ethylbenzene dehydrogenase gamma subunit (EC 1.17.99.2)
EukaPeptChaiRele	Eukaryotic peptide chain release factor subunit 1
EukaPeptChaiRele2	Eukaryotic peptide chain release factor GTP-binding subunit
EukaTranInitFact	Eukaryotic translation initiation factor 2 beta subunit
EukaTranInitFact2	Eukaryotic translation initiation factor 2 alpha subunit
EukaTranInitFact3	Eukaryotic translation initiation factor 5A
EukaTranInitFact4	Eukaryotic translation initiation factor 6
EukaTranInitFact5	Eukaryotic translation initiation factor 2 gamma subunit
EutjLikeProtClus	EutJ-like protein clustered with pyruvate formate-lyase
EutmPduaPdujLike	EutM/PduA/PduJ-like protein 3 clustered with pyruvate formate-lyase
EutmPduaPdujLike2	EutM/PduA/PduJ-like protein clustered with pyruvate formate-lyase
EutmPduaPdujLike3	EutM/PduA/PduJ-like protein 2 clustered with pyruvate formate-lyase
EutnLikeProtClus	EutN-like protein clustered with pyruvate formate-lyase
EutqLikeProtClus	EutQ-like protein clustered with pyruvate formate-lyase
EvolBetaDGalaAlph	Evolved beta-D-galactosidase, alpha subunit
EvolBetaDGalaBeta	Evolved beta-D-galactosidase, beta subunit
EvolBetaDGalaTran	Evolved beta-D-galactosidase transcriptional repressor
ExcaCalcBindDoma	Excalibur calcium-binding domain
ExciAbcCSubuLike	Excinuclease ABC, C subunit-like
ExciAbcSubu	Excinuclease ABC subunit A
ExciAbcSubuB	Excinuclease ABC subunit B
ExciAbcSubuC	Excinuclease ABC subunit C
ExciAbcSubuCDoma	Excinuclease ABC subunit C domain protein
ExciAbcSubuDimeForm	Excinuclease ABC subunit A, dimeric form
ExciAbcSubuDomaProt	Excinuclease ABC subunit A domain protein
ExciAbcSubuParaGrea	Excinuclease ABC subunit A paralog in greater Bacteroides group
ExciAbcSubuParaUnkn	Excinuclease ABC subunit A paralog of unknown function
ExciCho	Excinuclease cho (excinuclease ABC alternative C subunit)
ExciSaBact11Mu50n1	Excisionase [SA bacteriophages 11, Mu50B]
ExodI	Exodeoxyribonuclease I (EC 3.1.11.1)
ExodIii	Exodeoxyribonuclease III (EC 3.1.11.2)
ExodVAlphChai	Exodeoxyribonuclease V alpha chain (EC 3.1.11.5)
ExodVBetaChai	Exodeoxyribonuclease V beta chain (EC 3.1.11.5)
ExodVGammChai	Exodeoxyribonuclease V gamma chain (EC 3.1.11.5)
ExodViiLargSubu	Exodeoxyribonuclease VII large subunit (EC 3.1.11.6)
ExodViiSmalSubu	Exodeoxyribonuclease VII small subunit (EC 3.1.11.6)
ExoeReguProtAepa	Exoenzymes regulatory protein AepA in lipid-linked oligosaccharide synthesis cluster
ExonSbcc	Exonuclease sbcC (EC 3.1.11.-)
ExonSbcd	Exonuclease SbcD
Exop	Exopolyphosphatase (EC 3.6.1.11)
ExopBiosTranActi	Exopolysaccharide biosynthesis transcriptional activator EpsA
ExopBiosTranAnti	Exopolysaccharide biosynthesis transcription antiterminator, LytR family
ExopLyas	Exopolygalacturonate lyase (EC 4.2.2.9)
ExorIi	Exoribonuclease II (EC 3.1.13.1)
ExosCompExonDis3n1	Exosome complex exonuclease DIS3
ExosCompExonMtr3n1	Exosome complex exonuclease MTR3 (EC 3.1.13.-)
ExosCompExonRrp4n1	Exosome complex exonuclease RRP45 (EC 3.1.13.-)
ExosCompExonRrp4n2	Exosome complex exonuclease RRP41 (EC 3.1.13.-)
ExosCompExonRrp4n3	Exosome complex exonuclease RRP4
ExosCompExonRrp4n4	Exosome complex exonuclease RRP42 (EC 3.1.13.-)
ExosCompExonRrp4n5	Exosome complex exonuclease RRP46 (EC 3.1.13.-)
ExosCompExonRrp4n6	Exosome complex exonuclease RRP43 (EC 3.1.13.-)
ExosCompExonRrp6n1	Exosome complex exonuclease RRP6 (EC 3.1.13.-)
ExosCompRnaBindCsl4n1	Exosome complex RNA binding Csl4
ExosCompRnaBindRrp4n1	Exosome complex RNA binding RRP40
ExosProt	Exosporium protein A
ExosProtB	Exosporium protein B
ExosProtC	Exosporium protein C
ExosProtD	Exosporium protein D
ExosProtDLikeProt	Exosporium protein D-like protein
ExosProtE	Exosporium protein E
ExosProtF	Exosporium protein F
ExosProtG	Exosporium protein G
ExosProtJ	Exosporium protein J
ExosProtK	Exosporium protein K
ExosSod	Exosporium SOD
ExotPhagAsso	Exotoxin, phage associated
ExprProtPossInvo	Expressed protein possibly involved in photorespiration
ExtrAdheProtBroa	Extracellular adherence protein of broad specificity Eap/Map
ExtrEcmPlasBindProt	Extracellular ECM and plasma binding protein Emp
ExtrFibrBindProt	Extracellular fibrinogen-binding protein Efb
ExtrFuncSigmFact	Extracytoplasmic function (ECF) sigma factor VreI
ExtrThiaBindLipo	Extracytoplasmic thiamin (pyrophosphate?) binding lipoprotein p37, specific for Mycoplasma
F4201LGlutLiga	F420-1:L-glutamate ligase (EC 6.3.2.34)
F420DepeMethDehy	F420-dependent methylenetetrahydromethanopterin dehydrogenase (EC 1.5.99.9)
F420DepeNNMethRedu	F420-dependent N(5),N(10)-methylenetetrahydromethanopterin reductase (EC 1.5.99.11)
F420QuinOxid112Kda	F420H2:quinone oxidoreductase, 11.2 kDa subunit, putative
F420QuinOxid39Kda	F420H2:quinone oxidoreductase, 39 kDa subunit, putative
FadDepeCmnmSU34Oxid	FAD-dependent cmnm(5)s(2)U34 oxidoreductase
FadDepeMonoPhzs	FAD-dependent monooxygenase PhzS
FadDepePyriNuclDisu	FAD-dependent pyridine nucleotide-disulphide oxidoreductase (EC 1.18.1.3 )
FadDepePyriNuclDisu6	FAD-dependent pyridine nucleotide-disulphide oxidoreductase, GBAA2537 homolog
FarnDiphSynt	(2E,6E)-farnesyl diphosphate synthase (EC 2.5.1.10)
FarnDiphSyntPtlb	Farnesyl diphosphate synthase PtlB in pentalenolactone biosynthesis (EC 2.5.1.10)
FattAcidDesa	Fatty acid desaturase (EC 1.14.19.1)
FattAcylCoaOxidRela	Fatty-acyl-CoA oxidase, related to yeast fatty acid beta-oxidation enzyme POX1 (EC 1.3.3.6)
Fe2AbcTranAtpBind	Fe2+ ABC transporter, ATP-binding subunit
Fe2AbcTranPermProt	Fe2+ ABC transporter, permease protein 2
Fe2AbcTranPermProt2	Fe2+ ABC transporter, permease protein 1
Fe2AbcTranSubsBind	Fe2+ ABC transporter, substrate binding protein
FeBaciUptaSystFeua	Fe-bacillibactin uptake system FeuA, Fe-bacillibactin binding
FeBaciUptaSystFeua2	Fe-bacillibactin uptake system FeuA, regulatory component
FeBaciUptaSystFeub	Fe-bacillibactin uptake system FeuB
FeBaciUptaSystFeuc	Fe-bacillibactin uptake system FeuC
FeBaciUptaSystFeud	Fe-bacillibactin uptake system FeuD
FeContAlcoDehy	Fe-containing alcohol dehydrogenase
FemaFactEsseForMeth	FemA, factor essential for methicillin resistance
FembFactInvoMeth	FemB, factor involved in methicillin resistance
FemcFactInvoMeth	FemC, factor involved in methicillin resistance
FemdFactInvoMeth	FemD, factor involved in methicillin resistance
FermRespSwitProt	Fermentation/respiration switch protein
Ferr2fe2s	Ferredoxin, 2Fe-2S
FerrAbcTranPeriIron	Ferrichrome ABC transporter, periplasmic iron-binding protein PvuB
FerrAbcTranPvuc	Ferrichrome ABC transporter (permease) PvuC
FerrAbcTranPvud	Ferrichrome ABC transporter (permease) PvuD
FerrAbcTranPvue	Ferrichrome ABC transporter (ATP binding subunit) PvuE
FerrAeroAbcTranAtpa	Ferric aerobactin ABC transporter, ATPase component
FerrAeroAbcTranPeri	Ferric aerobactin ABC transporter, periplasmic substrate binding protein
FerrAeroAbcTranPerm	Ferric aerobactin ABC transporter, permease component
FerrBindPeriProt2	Ferrichrome-binding periplasmic protein precursor (TC 3.A.1.14.3)
FerrBindPeriProt4	Ferrichrome-binding periplasmic protein precursor in superantigen-encoding pathogenicity islands SaPI
FerrDepeGlutSynt	Ferredoxin-dependent glutamate synthase (EC 1.4.7.1)
FerrEnanPyocTran	Ferric enantio-pyochelin transport system permease protein
FerrEnanPyocTran2	Ferric enantio-pyochelin transport system ATP-binding protein
FerrEnanPyocTran3	Ferric enantio-pyochelin transport system periplasmic substrate-binding protein
FerrEnteBindPeri	Ferric enterobactin-binding periplasmic protein FepB (TC 3.A.1.14.2)
FerrEnteTranAtpBind	Ferric enterobactin transport ATP-binding protein FepC (TC 3.A.1.14.2)
FerrEnteTranSyst	Ferric enterobactin transport system permease protein FepG (TC 3.A.1.14.2)
FerrEnteTranSyst2	Ferric enterobactin transport system permease protein FepD (TC 3.A.1.14.2)
FerrEnteUptaProt	Ferric enterobactin uptake protein FepE
FerrHydrAbcTranAtp	Ferric hydroxamate ABC transporter, ATP-binding protein FhuC (TC 3.A.1.14.3)
FerrHydrAbcTranPeri	Ferric hydroxamate ABC transporter, periplasmic substrate binding protein FhuD (TC 3.A.1.14.3)
FerrHydrAbcTranPerm	Ferric hydroxamate ABC transporter, permease component FhuB (TC 3.A.1.14.3)
FerrHydrOuteMemb	Ferric hydroxamate outer membrane receptor FhuA
FerrIronAbcTranAtp	Ferric iron ABC transporter, ATP-binding protein
FerrIronAbcTranIron	Ferric iron ABC transporter, iron-binding protein
FerrIronAbcTranPerm	Ferric iron ABC transporter, permease protein
FerrIronRece	Ferrichrome-iron receptor
FerrIronTranPeri	Ferrous iron transport periplasmic protein EfeO, contains peptidase-M75 domain and (frequently) cupredoxin-like domain
FerrIronTranPerm	Ferrous iron transport permease EfeU
FerrIronTranPerm2	Ferrous iron transport permease EfeU, N-terminal extended
FerrIronTranPero	Ferrous iron transport peroxidase EfeB
FerrIronTranProt	Ferrous iron transport protein A
FerrIronTranProt2	Ferrous iron transport protein B
FerrIronTranProt5	Ferrous iron transport protein C
FerrLikeProtFixx3	Ferredoxin-like protein, FixX family => Mycofactocin system
FerrNadpRedu	Ferredoxin--NADP(+) reductase (EC 1.18.1.2)
FerrProtFerrLyas	Ferrochelatase, protoheme ferro-lyase (EC 4.99.1.1)
FerrRedu2	Ferric reductase (1.6.99.14)
FerrRiboReduLike	Ferritin/ribonucleotide reductase-like protein
FerrRv17n1	Ferredoxin Rv1786
FerrSideRecePsua	Ferric siderophore receptor PsuA
FerrSideReceTonb	Ferric siderophore receptor, TonB dependent
FerrSideTranSyst	Ferric siderophore transport system, periplasmic binding protein TonB
FerrSulfRedu	Ferredoxin--sulfite reductase (EC 1.8.7.1)
FerrTranAtpBindProt	Ferrichrome transport ATP-binding protein FhuC (TC 3.A.1.14.3)
FerrTranSystPerm	Ferrichrome transport system permease protein fhuB (TC 3.A.1.14.3)
FerrTypeProtNapf	Ferredoxin-type protein NapF (periplasmic nitrate reductase)
FerrTypeProtNapg	Ferredoxin-type protein NapG (periplasmic nitrate reductase)
FerrUptaRegu2	ferric uptake regulator
FerrUptaReguProt	Ferric uptake regulation protein FUR
FerrVibrEnteTran	Ferric vibriobactin, enterobactin transport system, substrate-binding protein ViuP (TC 3.A.1.14.6)
FerrVibrEnteTran2	Ferric vibriobactin, enterobactin transport system, permease protein ViuD (TC 3.A.1.14.6)
FerrVibrEnteTran3	Ferric vibriobactin, enterobactin transport system, permease protein ViuG (TC 3.A.1.14.6)
FerrVibrEnteTran4	Ferric vibriobactin, enterobactin transport system, ATP-binding protein (TC 3.A.1.14.6)
FerrVibrEnteTran5	Ferric vibriobactin, enterobactin transport system, permease protein VctD (TC 3.A.1.14.6)
FerrVibrEnteTran6	Ferric vibriobactin, enterobactin transport system, substrate-binding protein VctP (TC 3.A.1.14.6)
FerrVibrEnteTran7	Ferric vibriobactin, enterobactin transport system, permease protein VctG (TC 3.A.1.14.6)
FerrVibrEnteTran8	Ferric vibriobactin, enterobactin transport system, ATP-binding protein ViuC (TC 3.A.1.14.6)
FerrVibrReceViua	Ferric vibriobactin receptor ViuA
FerrVulnReceVuua	Ferric vulnibactin receptor VuuA
FibrBindProtFnba	Fibronectin binding protein FnbA
FibrBindProtFnbb	Fibronectin binding protein FnbB
Fig01AcylSnGlyc3n1	FIG018329: 1-acyl-sn-glycerol-3-phosphate acyltransferase
Fig04HydrCoaThio	FIG002571: 4-hydroxybenzoyl-CoA thioesterase domain protein
Fig0AaaAtpa	FIG022606: AAA ATPase
Fig0Acet2	FIG002208: Acetyltransferase (EC 2.3.1.-)
Fig0AcetGnatFami	FIG009148: Acetyltransferase, GNAT family
Fig0AntiProtType	FIG00450637: Antifreeze protein, type I
Fig0AtpDepeNuclSubu	FIG061771: ATP-dependent nuclease subunit A
Fig0AtpDepeNuclSubu2	FIG041266: ATP-dependent nuclease subunit B
Fig0AtpaMoxrFami	FIG017823: ATPase, MoxR family
Fig0BetaOperTran	FIG009707: Betaine operon transcriptional regulator
Fig0CatiAbcTranPeri	FIG014801: Cation ABC transporter, periplasmic cation-binding protein
Fig0CatiHydrAnti	FIG064705: cation/hydrogen antiporter
Fig0CbsDomaContProt2	FIG049181: CBS-domain-containing protein
Fig0CbsDomaProt	FIG038974: CBS domain protein
Fig0CbsDomaProt2	FIG041141: CBS domain protein
Fig0CbsDomaProt3	FIG040948: CBS domain protein
Fig0CbsDomaProt4	FIG046540: CBS domain protein
Fig0CholTranRela	FIG023769: Choline transport related protein
Fig0ChroSegrProt	FIG007317: Chromosome segregation protein SMC-like
Fig0ConjTranOute	FIG003465: Conjugative transfer outer membrane protein
Fig0ConsMceAssoTran	FIG033285: Conserved MCE associated transmembrane protein
Fig0ConsMembProt	FIG005773: conserved membrane protein ML1361
Fig0CytoCFamiProt	FIG002261: Cytochrome c family protein
Fig0CytoHypoProt	FIG001886: Cytoplasmic hypothetical protein
Fig0CytoProtCont	FIG009439: Cytosolic protein containing multiple CBS domains
Fig0DDCarbFamiProt	FIG009095: D,D-carboxypeptidase family protein
Fig0DegvFamiProt	FIG005590: DegV family protein
Fig0DehyWithDiff	FIG062860: Dehydrogenases with different specificities (related to short-chain alcohol dehydrogenases)
Fig0DiacHydrLike	FIG053235: Diacylglucosamine hydrolase like
Fig0DiguCyclWith	FIG066100: Diguanylate cyclase (GGDEF domain) with PAS/PAC sensor
Fig0DnaReplProtPhag	FIG018226: DNA replication protein, phage-associated
Fig0FadBindProt	FIG022199: FAD-binding protein
Fig0FadDepePyriNucl	FIG002984: FAD-dependent pyridine nucleotide-disulphide oxidoreductase
Fig0FeSOxid2	FIG057251: Fe-S oxidoreductase
Fig0ForeShelProt	FIG007421: forespore shell protein
Fig0ForkDomaProt	FIG016943: Forkhead domain protein
Fig0FtszInteProt	FIG001960: FtsZ-interacting protein related to cell division
Fig0GlycTran	FIG040338: Glycosyl transferase
Fig0HdFamiHydr	FIG005986: HD family hydrolase
Fig0HitFamiProt	FIG049476: HIT family protein
Fig0HomoEColiHemy	FIG000868: Homolog of E. coli HemY protein
Fig0HydrAlphBeta2	FIG084569: hydrolase, alpha/beta fold family
Fig0HydrHadSubfIiia	FIG001553: Hydrolase, HAD subfamily IIIA
Fig0Hypo2CoocWith	FIG065159: hypothetical 2 cooccurring with ATP synthase chains
Fig0HypoAnti	FIG052618: hypothetical antitoxin ( to FIG131131: hypothetical toxin)
Fig0HypoAnti2	FIG045511: hypothetical antitoxin (to FIG022160: hypothetical toxin)
Fig0HypoClusWith	FIG059958: hypothetical in cluster with ATP synthase chains
Fig0HypoCoocWith	FIG057547: hypothetical cooccurring with ATP synthase chains
Fig0HypoMembAsso	FIG015389: hypothetical membrane associated protein
Fig0HypoPeriProt	FIG026291: Hypothetical periplasmic protein
Fig0HypoProt10838	FIG095838: hypothetical protein
Fig0HypoProt10843	FIG00440100: hypothetical protein
Fig0HypoProt10881	FIG094713: hypothetical protein
Fig0HypoProt1115	FIG00810015: hypothetical protein
Fig0HypoProt1116	FIG025412: hypothetical protein
Fig0HypoProt1126	FIG007481: hypothetical protein
Fig0HypoProt12038	FIG062788: hypothetical protein
Fig0HypoProt1413	FIG010505: hypothetical protein
Fig0HypoProt1464	FIG024285: Hypothetical protein
Fig0HypoProt16048	FIG00845751: hypothetical protein
Fig0HypoProt1610	FIG018229: hypothetical protein
Fig0HypoProt1750	FIG003573: hypothetical protein
Fig0HypoProt17903	FIG024317: hypothetical protein
Fig0HypoProt17907	FIG00821131: hypothetical protein
Fig0HypoProt17908	FIG00822329: hypothetical protein
Fig0HypoProt1812	FIG003846: hypothetical protein
Fig0HypoProt1822	FIG007697: hypothetical protein
Fig0HypoProt1869	FIG059250: hypothetical protein
Fig0HypoProt1905	FIG00515841: hypothetical protein
Fig0HypoProt1906	FIG00515214: hypothetical protein
Fig0HypoProt1911	FIG013354: hypothetical protein
Fig0HypoProt19675	FIG01108049: hypothetical protein
Fig0HypoProt1971	FIG038982: hypothetical protein
Fig0HypoProt1997	FIG011684: hypothetical protein
Fig0HypoProt2259	FIG015094: hypothetical protein
Fig0HypoProt250	FIG005429: hypothetical protein
Fig0HypoProt252	FIG039767: hypothetical protein
Fig0HypoProt25731	FIG00821242: hypothetical protein
Fig0HypoProt25933	FIG00820914: hypothetical protein
Fig0HypoProt26250	FIG00909789: hypothetical protein
Fig0HypoProt2757	FIG00557681: hypothetical protein
Fig0HypoProt2n1	FIG002343: hypothetical protein-2
Fig0HypoProt30035	FIG002657: hypothetical protein
Fig0HypoProt3077	FIG006581: hypothetical protein
Fig0HypoProt3092	FIG026765: hypothetical protein
Fig0HypoProt313	FIG002776: hypothetical protein
Fig0HypoProt3174	FIG036446: hypothetical protein
Fig0HypoProt3208	FIG005495: hypothetical protein
Fig0HypoProt3214	FIG00450475: hypothetical protein
Fig0HypoProt34703	FIG01108210: hypothetical protein
Fig0HypoProt39964	FIG00615979: hypothetical protein
Fig0HypoProt427	FIG042796: Hypothetical protein
Fig0HypoProt4638	FIG018429: hypothetical protein
Fig0HypoProt4743	FIG004599: Hypothetical protein
Fig0HypoProt483	FIG017861: hypothetical protein
Fig0HypoProt4869	FIG010427: hypothetical protein
Fig0HypoProt48777	FIG01058720: hypothetical protein
Fig0HypoProt50165	FIG008220: hypothetical protein
Fig0HypoProt51130	FIG00820004: hypothetical protein
Fig0HypoProt549	FIG002076: hypothetical protein
Fig0HypoProt5799	FIG00936810: hypothetical protein
Fig0HypoProt5877	FIG00450379: hypothetical protein
Fig0HypoProt5956	FIG070318: hypothetical protein
Fig0HypoProt60	FIG01131824: hypothetical protein
Fig0HypoProt604	FIG014356: hypothetical protein
Fig0HypoProt61	FIG00820327: hypothetical protein
Fig0HypoProt612	FIG035331: hypothetical protein
Fig0HypoProt64	FIG059443: hypothetical protein
Fig0HypoProt65	FIG00820006: hypothetical protein
Fig0HypoProt6773	FIG00740931: hypothetical protein
Fig0HypoProt69	FIG002343: hypothetical protein
Fig0HypoProt6933	FIG00652825: hypothetical protein
Fig0HypoProt71	FIG024795: hypothetical protein
Fig0HypoProt74	FIG01270651: hypothetical protein
Fig0HypoProt75	FIG00822885: hypothetical protein
Fig0HypoProt815	FIG068086: hypothetical protein
Fig0HypoProt842	FIG005069: Hypothetical protein
Fig0HypoProt93	FIG004851: hypothetical protein
Fig0HypoProt9623	FIG081201: hypothetical protein
Fig0HypoProtAmmo	FIG025881: hypothetical protein in Ammonia conversion cluster
Fig0HypoProtBiot	FIG016608: hypothetical protein in biotin operon
Fig0HypoProtCarn	FIG004891: hypothetical protein in carnitine cluster
Fig0HypoProtClus2	FIG023365: hypothetical protein in cluster with pertussis-like toxin
Fig0HypoProtClus3	FIG048677: hypothetical protein in cluster with cytolethal distending toxin
Fig0HypoProtCoOccu3	FIG028220: hypothetical protein co-occurring with HEAT repeat protein
Fig0HypoProtCoOccu6	FIG007350: hypothetical protein co-occurring with bile hydrolase
Fig0HypoProtCoOccu7	FIG019766: hypothetical protein co-occurring with bile hydrolase
Fig0HypoProtCooc	FIG066432: hypothetical protein cooccurring with ATP synthase chains
Fig0HypoProtCupi	FIG018171: hypothetical protein of Cupin superfamily
Fig0HypoProtIron	FIG078613: hypothetical protein in iron scavenging cluster
Fig0HypoProtMgTran	FIG088476: hypothetical protein in Mg(2+) transport ATPase cluster
Fig0HypoProtMgTran2	FIG065852: hypothetical protein in Mg(2+) transport ATPase cluster
Fig0HypoProtPerh	FIG040666: hypothetical protein perhaps implicated in de Novo purine biosynthesis
Fig0HypoProtPfgi	FIG004780: hypothetical protein in PFGI-1-like cluster
Fig0HypoProtPfgi2	FIG034647: hypothetical protein in PFGI-1-like cluster
Fig0HypoProtPfgi3	FIG041388: hypothetical protein in PFGI-1-like cluster
Fig0HypoProtPhag	FIG048677: hypothetical protein, phage tail fiber-like
Fig0HypoProtPpeGene	FIG023076: hypothetical protein in PPE gene cluster
Fig0HypoProtPyov	FIG049111: Hypothetical protein in pyoverdin gene cluster
Fig0HypoProtRv02n1	FIG00820733: hypothetical protein, Rv0207c
Fig0HypoProtRv19n1	FIG00820120: hypothetical protein Rv1974
Fig0HypoProtRv19n2	FIG00821319: hypothetical protein Rv1975
Fig0HypoProtWith	FIG00645039: hypothetical protein with HTH-domain
Fig0HypoProtYebc	FIG000859: hypothetical protein YebC
Fig0HypoProtYeen	FIG007491: hypothetical protein YeeN
Fig0HypoSignPept	FIG00858545: hypothetical signal peptide protein adjacent to bacteriocin resistance protein
Fig0HypoToxi	FIG022160: hypothetical toxin
Fig0HypoWithDnaj	FIG003437: hypothetical with DnaJ-like domain
Fig0IccLikeProtPhos	FIG006285: ICC-like protein phosphoesterase
Fig0InosMonoFami	FIG043197: Inositol monophosphatase family protein
Fig0InteMembProt2	FIG04612: Integral membrane protein (putative)
Fig0LargCoilCoil	FIG01127234: large coiled-coil domains containing protein, actin-like
Fig0Lipo	FIG085779: Lipoprotein
Fig0LongChaiFatt	FIG022758: Long-chain-fatty-acid--CoA ligase (EC 6.2.1.3)
Fig0LppgFo2PhosL	FIG002813: LPPG:FO 2-phospho-L-lactate transferase like, CofD-like
Fig0LysiBiosHypo	FIG087682: Lysine Biosynthetic hypothetical OrfE
Fig0MceAssoMembProt	FIG00820195: MCE associated membrane protein
Fig0MceAssoMembProt2	FIG00821219: MCE associated membrane protein
Fig0MembBounLyti	FIG004335: Membrane-bound lytic murein transglycosylase B precursor (EC 3.2.1.-)
Fig0MembDoma	FIG019327: membrane domain
Fig0MembProt5	FIG005935: membrane protein
Fig0MembProt9	FIG020554: membrane protein
Fig0MembProtExpo	FIG021862: membrane protein, exporter
Fig0MembProtPuta	FIG003603: membrane protein, putative
Fig0MetaDepeHydr2	FIG002379: metal-dependent hydrolase
Fig0MoadThisFami	FIG038648: MoaD and/or ThiS families
Fig0MoleChap	FIG00821990: molecular chaperone
Fig0MoscDomaProt	FIG060329: MOSC domain protein
Fig0MoxrLikeAtpa	FIG022979: MoxR-like ATPases
Fig0MultPolyOxid	FIG00003370: Multicopper polyphenol oxidase
Fig0MuttNudiFami	FIG012576: mutT/nudix family protein
Fig0NAcet	FIG007808: N-acetyltransferase
Fig0NAcetLAlanAmid	FIG001385: N-acetylmuramoyl-L-alanine amidase (EC 3.5.1.28)
Fig0NadDepeEpimDehy	FIG010773: NAD-dependent epimerase/dehydratase
Fig0Nucl	FIG006611: nucleotidyltransferase
Fig0PeFamiProt	FIG018298: PE family protein
Fig0PeptM16Fami	FIG007959: peptidase, M16 family
Fig0PeptM16Fami2	FIG009210: peptidase, M16 family
Fig0PhagCapsScaf	FIG070121: Phage capsid and scaffold protein
Fig0PhagDnaBindProt	FIG033266: Phage DNA binding protein
Fig0PhagPolaSupp	FIG054316: Phage polarity suppression protein
Fig0PhagProt5	FIG032397: Phage protein
Fig0Phos3	FIG009886: phosphoesterase
Fig0PhosGlycAcyl	FIG005243: Phospholipid--glycerol acyltransferase
Fig0PhosNuclPyro	FIG00907047: phosphodiesterase/nucleotide pyrophosphatase
Fig0PhosTran	FIG062957: phosphoribosyl transferase
Fig0PolyDeac	FIG004655: Polysaccharide deacetylase
Fig0PolyDeacPuta	FIG007013: polysaccharide deacetylase, putative
Fig0PoriGramNega	FIG005478: Porin, Gram-negative type
Fig0PossChap	FIG00814129: Possible chaperone
Fig0PossDnaBindProt	FIG019733: possible DNA-binding protein
Fig0PossExpoProt	FIG005080: Possible exported protein
Fig0PossMembProt	FIG021574: Possible membrane protein related to de Novo purine biosynthesis
Fig0PossMembProt2	FIG01121868: Possible membrane protein, Rv0205
Fig0PossMembProt26	FIG01121868: Possible membrane protein, Rv0204c
Fig0PossSecrProt	FIG00995371: possibly secreted protein
Fig0PossToxiDivi	FIG004853: possible toxin to DivIC
Fig0PredAmid	FIG003879: Predicted amidohydrolase
Fig0PredMetaDepe	FIG00031715: Predicted metal-dependent phosphoesterases (PHP family)
Fig0PredN6AdenSpec	FIG001721: Predicted N6-adenine-specific DNA methylase
Fig0ProbConsMceAsso	FIG033430: Probable conserved MCE associated membrane protein
Fig0ProbFeTrafProt	FIG001341: Probable Fe(2+)-trafficking protein YggX
Fig0ProbLipo	FIG00679528: probable lipoprotein
Fig0ProtClusWith	FIG01269488: protein, clustered with ribosomal protein L32p
Fig0ProtCoOccuWith	FIG000605: protein co-occurring with transport systems (COG1739)
Fig0ProtInvoDmsp	FIG098787: protein involved in DMSP breakdown
Fig0ProtPrec	FIG003620: Proteophosphoglycan precursor (Fragment)
Fig0ProtSirb	FIG002708: Protein SirB1
Fig0ProtSirb2	FIG002082: Protein sirB2
Fig0ProtUnknFunc2	FIG016027: protein of unknown function YeaO
Fig0ProtYcarKdo2n1	FIG002473: Protein YcaR in KDO2-Lipid A biosynthesis cluster
Fig0ProtYcegLike	FIG004453: protein YceG like
Fig0ProtYdja	FIG002003: Protein YdjA
Fig0PutaAlkaShoc	FIG001802: Putative alkaline-shock protein
Fig0PutaCytoProt	FIG004798: Putative cytoplasmic protein
Fig0PutaDeorFami	FIG005453: Putative DeoR-family transcriptional regulator
Fig0PutaHeli	FIG005666: putative helicase
Fig0PutaLipoPrec	FIG002577: Putative lipoprotein precursor
Fig0PutaMembProt2	FIG01124767: putative membrane protein
Fig0PutaMembProt3	FIG00547529: putative membrane protein
Fig0PutaMembProt4	FIG00816212: Putative membrane protein
Fig0PutaSecrProt2	FIG01967133: Putative secreted protein
Fig0PutaTranProt	FIG027190: Putative transmembrane protein
Fig0PutaTranRegu	FIG002994: Putative transcriptional regulator
Fig0RhodRelaSulf	FIG00432062: Rhodanese-related sulfurtransferase
Fig0RhomFamiSeri	FIG056164: rhomboid family serine protease
Fig0RiboLargSubu	FIG000124: Ribosomal large subunit pseudouridine synthase D (EC 4.2.1.70)
Fig0RiboReduLike	FIG00519347: Ribonucleotide reductase-like protein
Fig0RnaBindProt	FIG004454: RNA binding protein
Fig0RrnaMeth	FIG011178: rRNA methylase
Fig0SamDepeMeth	FIG005121: SAM-dependent methyltransferase (EC 2.1.1.-)
Fig0SamDepeMeth2	FIG025233: SAM-dependent methyltransferases
Fig0SecrProt	FIG027937: secreted protein
Fig0SecrZnDepeProt	FIG048170: Secreted Zn-dependent protease involved in posttranslational modification
Fig0Sens	FIG056333: sensor
Fig0SensHistKina	FIG001393: Sensor histidine kinase PrrB (RegB) (EC 2.7.3.-)
Fig0SigmFactEcfSubf	FIG006045: Sigma factor, ECF subfamily
Fig0SigmFactLike	FIG017431: Sigma factor-like phosphatase with CBS pair domains
Fig0SimiAminTrna	FIG042921: similarity to aminoacyl-tRNA editing enzymes YbaK, ProX
Fig0SoluLytiMure	FIG016425: Soluble lytic murein transglycosylase and related regulatory proteins (some contain LysM/invasin domains)
Fig0SpovLikeProt	FIG004684: SpoVR-like protein
Fig0StagVSporProt	FIG006789: Stage V sporulation protein
Fig0SugaTran	FIG071646: Sugar transferase
Fig0SugaTran2	FIG097052: Sugar transporter
Fig0SulfTran	FIG00988482: Sulfur transporter
Fig0TatdRelaDnas	FIG00567468: TatD-related DNase
Fig0Thio	FIG009688: Thioredoxin
Fig0ThioDomaCont	FIG000875: Thioredoxin domain-containing protein EC-YbbN
Fig0ThioFoldProt	FIG00002411: Thioredoxin-fold protein
Fig0ThioInvoNonRibo	FIG057993:Thioesterase involved in non-ribosomal peptide biosynthesis
Fig0ThreDehyRela	FIG003492: Threonine dehydrogenase and related Zn-dependent dehydrogenases
Fig0TolaLikeMemb	FIG00973752: TolA-like membrane protein
Fig0TprRepeContProt	FIG009300: TPR-repeat-containing protein
Fig0Tran	FIG040954: Transporter
Fig0TranActiLmo0n1	FIG011400: transcriptional activator of Lmo0327 homolog
Fig0TranLikeEnzy	FIG001454: Transglutaminase-like enzymes, putative cysteine proteases
Fig0TranLyseFami	FIG059814: Transporter, LysE family
Fig0TranProt	FIG017342: transmembrane protein
Fig0TranProt3	FIG035962: transmembrane protein
Fig0TranReguArsr	FIG004131: Transcriptional regulator, ArsR family
Fig0TranReguPadr	FIG014387: Transcriptional regulator, PadR family
Fig0TypeIiiSecr	FIG042683: Type III secretion
Fig0TypeIiiSecr2	FIG016943: Type III secretion
Fig0TypeIiiSecrProt	FIG016921: Type III secretion protein
Fig0TypeIiiSecrProt2	FIG016647: Type III secretion protein
Fig0TypeIiiSecrProt3	FIG016940: Type III secretion protein
Fig0TypeIiiSecrProt4	FIG046930: Type III secretion protein
Fig0TypeIiiSecrS	FIG047302: Type III secretion S/T Protein Kinase
Fig0UnchPept	FIG00672241: Uncharacterized peptidase
Fig0UnchProt	FIG007303: uncharacterized protein
Fig0Upf0ProtFami	FIG007079: UPF0348 protein family
Fig0VariSizeProt	FIG01326805: variable size protein family
Fig0WdRepeProt	FIG045915: WD-repeat protein
Fig0YebcParaBeta	FIG033889: YebC paralog in Betaproteobacteria
Fig0YebcParaClos	FIG033889: YebC paralog in Clostridia
Fig0ZincBindProt2	FIG00450264: zinc-binding protein
Fig0ZincCarbRela	FIG011155: Zinc carboxypeptidase-related protein
Fig0ZincProt	FIG001621: Zinc protease
Fig0ZincProt2	FIG015287: Zinc protease
Fig135OligBaciType2	FIG146085: 3-to-5 oligoribonuclease A, Bacillus type
Fig13OxoaAcpSynt	FIG138576: 3-oxoacyl-[ACP] synthase (EC 2.3.1.41)
Fig1CarbNitrHydr	FIG147869: Carbon-nitrogen hydrolase
Fig1CytoC4n1	FIG135464: Cytochrome c4
Fig1EnoyCoaHydr	FIG146212: Enoyl-CoA hydratase (EC 4.2.1.17)
Fig1GlutDepeThio	FIG138056: a glutathione-dependent thiol reductase
Fig1Glyc	FIG137776: Glycosyltransferase
Fig1GlycTran	FIG143263: Glycosyl transferase
Fig1HypoProt10	FIG110192: hypothetical protein
Fig1HypoProt12	FIG137884: hypothetical protein
Fig1HypoProt13	FIG149030: hypothetical protein
Fig1HypoProt16	FIG113347: hypothetical protein
Fig1HypoProt2	FIG137478: Hypothetical protein
Fig1HypoProt25	FIG167255: hypothetical protein
Fig1HypoProt3	FIG187021: hypothetical protein
Fig1HypoProt30	FIG104146: hypothetical protein
Fig1HypoProt32	FIG115103: hypothetical protein
Fig1HypoProtClus	FIG187434: hypothetical protein in cluster with ATP synthase chains
Fig1HypoProtPfgi	FIG141694: hypothetical protein in PFGI-1-like cluster
Fig1HypoProtPfgi2	FIG141751: hypothetical protein in PFGI-1-like cluster
Fig1HypoProtPyov	FIG137877: Hypothetical protein in pyoverdin gene cluster
Fig1HypoProtYbga	FIG143828: Hypothetical protein YbgA
Fig1HypoToxi	FIG131131: hypothetical toxin
Fig1LipoB	FIG139438: lipoprotein B
Fig1MafYcefYhdeFami	FIG146278: Maf/YceF/YhdE family protein
Fig1MembProtRela	FIG137887: membrane protein related to purine degradation
Fig1Meth	FIG145533: Methyltransferase (EC 2.1.1.-)
Fig1PeptM16Fami	FIG146458: peptidase, M16 family
Fig1PeptM16Fami2	FIG146397: peptidase, M16 family
Fig1PhagImmuRepr	FIG118045: Phage immunity repressor protein
Fig1PhagLateGene	FIG107037: Phage late gene regulator
Fig1PolyExpoProt	FIG123464: Polysaccharide export protein
Fig1PossConsMemb	FIG139612: Possible conserved membrane protein
Fig1PoteRiboProt	FIG139598: Potential ribosomal protein
Fig1PutaIronRegu	FIG137594: Putative iron-regulated membrane protein
Fig1PutaLipiCarr	FIG138517: Putative lipid carrier protein
Fig1PutaThiaPyro	FIG139991: Putative thiamine pyrophosphate-requiring enzyme
Fig1ThioLikeProt	FIG143042: Thioesterase-like protein
Fig1TprDomaProt	FIG140336: TPR domain protein
Fig1TrnaBindProt	FIG107367: tRNA-binding protein
Fig1ZincProt	FIG146452: Zinc protease
Fig2HypoProt2	FIG213968: hypothetical protein
FigfAcylCoaSyntAmp	FIGfam138462: Acyl-CoA synthetase, AMP-(fatty) acid ligase
FilaHaemFamiOute	Filamentous haemagglutinin family outer membrane protein associated with VreARI signalling system
FimbAdhe	fimbrial adhesin
FimbAsseProtFimb	Fimbrial assembly protein FimB
FinRequForSwitFrom	Fin: required for the switch from sigmaF to sigmaG during sporulation
FkbpTypePeptProl	FKBP-type peptidyl-prolyl cis-trans isomerase FkpA precursor (EC 5.2.1.8)
FkbpTypePeptProl2	FKBP-type peptidyl-prolyl cis-trans isomerase SlyD (EC 5.2.1.8)
FkbpTypePeptProl3	FKBP-type peptidyl-prolyl cis-trans isomerase FklB (EC 5.2.1.8)
FkbpTypePeptProl5	FKBP-type peptidyl-prolyl cis-trans isomerase SlpA (EC 5.2.1.8)
Flag	Flagellin (FliC)
FlagAsseFactFliw	Flagellar assembly factor FliW
FlagAsseProtFlih	Flagellar assembly protein FliH
FlagBasaBodyAsso	Flagellar basal body-associated protein FliL
FlagBasaBodyPRing	Flagellar basal-body P-ring formation protein FlgA
FlagBasaBodyRodModi	Flagellar basal-body rod modification protein FlgD
FlagBasaBodyRodProt	Flagellar basal-body rod protein FlgC
FlagBasaBodyRodProt2	Flagellar basal-body rod protein FlgB
FlagBasaBodyRodProt3	Flagellar basal-body rod protein FlgG
FlagBasaBodyRodProt4	Flagellar basal-body rod protein FlgF
FlagBiosProtFlgn	Flagellar biosynthesis protein FlgN
FlagBiosProtFlha	Flagellar biosynthesis protein FlhA
FlagBiosProtFlhb	Flagellar biosynthesis protein FlhB
FlagBiosProtFlio	Flagellar biosynthesis protein FliO
FlagBiosProtFlip	Flagellar biosynthesis protein FliP
FlagBiosProtFliq	Flagellar biosynthesis protein FliQ
FlagBiosProtFlir	Flagellar biosynthesis protein FliR
FlagBiosProtFlis	Flagellar biosynthesis protein FliS
FlagBiosProtFlit	Flagellar biosynthesis protein FliT
FlagBrakProtYcgr	Flagellar brake protein YcgR
FlagCapProtFlid	Flagellar cap protein FliD
FlagHookAssoProt	Flagellar hook-associated protein FlgL
FlagHookAssoProt2	Flagellar hook-associated protein FlgK
FlagHookBasaBody	Flagellar hook-basal body complex protein FliE
FlagHookLengCont	Flagellar hook-length control protein FliK
FlagHookProtFlge	Flagellar hook protein FlgE
FlagLRingProtFlgh	Flagellar L-ring protein FlgH
FlagMRingProtFlif	Flagellar M-ring protein FliF
FlagMotoRotaProt	Flagellar motor rotation protein MotA
FlagMotoRotaProt2	Flagellar motor rotation protein MotB
FlagMotoSwitProt	Flagellar motor switch protein FliN
FlagMotoSwitProt2	Flagellar motor switch protein FliM
FlagMotoSwitProt3	Flagellar motor switch protein FliG
FlagOperProtCa_c	Flagellar operon protein CA_C2155
FlagPRingProtFlgi	Flagellar P-ring protein FlgI
FlagProtFlaa	Flagellin protein FlaA
FlagProtFlag	Flagellar protein FlaG
FlagProtFlbd	Flagellar protein FlbD
FlagProtFlgjPept	Flagellar protein FlgJ [peptidoglycan hydrolase] (EC 3.2.1.-)
FlagProtFlhe	Flagellar protein FlhE
FlagProtFlij	Flagellar protein FliJ
FlagReguFlk	Flagellar regulator flk
FlagReguProtFleq	Flagellar regulatory protein FleQ
FlagReguReprRtsb	Flagellar regulon repressor RtsB
FlagSensHistKina	Flagellar sensor histidine kinase FleS
FlagSpecAtpSyntFlii	Flagellum-specific ATP synthase FliI
FlagTranActiFlhc	Flagellar transcriptional activator FlhC
FlagTranActiFlhd	Flagellar transcriptional activator FlhD
FlagTwoCompRespRegu	Flagellar two-component response regulator FleR
FlapStruSpecEndo	Flap structure-specific endonuclease (EC 3.-.-.-)
Flav1n1	Flavodoxin 1
Flav2n1	Flavodoxin 2
Flav4	flavodoxin
FlavCFlavSubu	Flavocytochrome c flavin subunit
FlavCHemeSubu	Flavocytochrome c heme subunit
FlavDepeMonoPren	Flavin-dependent monooxygenase in a prenylated indole derivative biosynthesis cluster
FlavMioc	Flavoprotein MioC
FlavPrenUbix	Flavin prenyltransferase UbiX
FlavReduLikeDoma2	Flavin reductase like domain protein in BltB locus
FlavSubuRelaSucc	flavoprotein subunit related to the succinate dehydrogenases and fumarate reductases
FlpPiluAsseMembProt	Flp pilus assembly membrane protein TadE
FlpPiluAsseProtCpad	Flp pilus assembly protein CpaD
FlpPiluAsseProtPili	Flp pilus assembly protein, pilin Flp
FlpPiluAsseProtRcpb	Flp pilus assembly protein RcpB
FlpPiluAsseProtRcpc	Flp pilus assembly protein RcpC/CpaB
FlpPiluAsseProtTadb	Flp pilus assembly protein TadB
FlpPiluAsseProtTadd2	Flp pilus assembly protein TadD, contains TPR repeat
FlpPiluAsseSurfProt	Flp pilus assembly surface protein TadF, ATP/GTP-binding motif
FmhaProtFemaFami	FmhA protein of FemAB family
FmhcProtFemaFami	FmhC protein of FemAB family
FmnAden	FMN adenylyltransferase (EC 2.7.7.2)
FmnAdenType2Euka	FMN adenylyltransferase, type 2 eukaryotic (EC 2.7.7.2)
FmnAdenType3Arch	FMN adenylyltransferase, type 3 archaeal (EC 2.7.7.2)
FmnReduRutf	FMN reductase (NADH) RutF (EC 1.5.1.42)
FmoProt2	FMO protein
FmtaProtInvoMeth	FmtA protein involved in methicillin resistance
FmtbProtInvoMeth	FmtB (Mrp) protein involved in methicillin resistance and cell wall biosynthesis
FmtcProtInvoMeth	FmtC (MrpF) protein involved in methicillin resistance
FolaBiosProtPtps	Folate biosynthesis protein PTPS-III, catalyzes a reaction that bypasses dihydroneopterin aldolase (FolB)
FolaTran3n1	Folate transporter 3
FoldProtPrsaPrec	Foldase protein PrsA precursor (EC 5.2.1.8)
FolmAlteDihyRedu	FolM Alternative dihydrofolate reductase 1
FolySynt	Folylpolyglutamate synthase (EC 6.3.2.17)
Form	Formiminoglutamase (EC 3.5.3.8)
Form2	Formamidase (EC 3.5.1.49)
FormActiEnzy	Formaldehyde activating enzyme
FormCoenTran	Formyl-coenzyme A transferase (EC 2.8.3.16)
FormCycl	Formiminotetrahydrofolate cyclodeaminase (EC 4.3.1.4)
FormDefo	Formyltetrahydrofolate deformylase (EC 3.5.1.10)
FormDehyAlphSubu	Formate dehydrogenase alpha subunit (EC 1.2.1.2)
FormDehyBetaSubu	Formate dehydrogenase beta subunit (EC 1.2.1.2)
FormDehyH	Formate dehydrogenase H (EC 1.2.1.2)
FormDehyMscrNadMyco	Formaldehyde dehydrogenase MscR, NAD/mycothiol-dependent (EC 1.2.1.66)
FormDehyNAlphSubu	Formate dehydrogenase N alpha subunit (EC 1.2.1.2)
FormDehyNBetaSubu	Formate dehydrogenase N beta subunit (EC 1.2.1.2)
FormDehyNGammSubu	Formate dehydrogenase N gamma subunit (EC 1.2.1.2)
FormDehyOAlphSubu	Formate dehydrogenase O alpha subunit (EC 1.2.1.2)
FormDehyOBetaSubu	Formate dehydrogenase O beta subunit (EC 1.2.1.2)
FormDehyOGammSubu2	Formate dehydrogenase O gamma subunit (EC 1.2.1.2)
FormDehyOperGene	Formylmethanofuran dehydrogenase (molybdenum) operon gene E
FormDehyOperGene2	Formylmethanofuran dehydrogenase (tungsten) operon gene F (polyferredoxin) (EC 1.2.99.5)
FormDehyOperGene3	Formylmethanofuran dehydrogenase (tungsten) operon gene G
FormDehyOperGene4	Formylmethanofuran dehydrogenase (tungsten) operon gene H
FormDehyOperGene5	Formylmethanofuran dehydrogenase (molybdenum) operon gene G
FormDehyOperGene6	Formylmethanofuran dehydrogenase (molybdenum) operon gene F (polyferredoxin) (EC 1.2.99.5)
FormDehySubu	Formylmethanofuran dehydrogenase subunit A (EC 1.2.99.5)
FormDehySubuB	Formylmethanofuran dehydrogenase subunit B (EC 1.2.99.5)
FormDehySubuB2	Formylmethanofuran dehydrogenase (molybdenum) subunit B (EC 1.2.99.5)
FormDehySubuB3	Formylmethanofuran dehydrogenase (tungsten) subunit B (EC 1.2.99.5)
FormDehySubuC	Formylmethanofuran dehydrogenase subunit C (EC 1.2.99.5)
FormDehySubuC2	Formylmethanofuran dehydrogenase (molybdenum) subunit C (EC 1.2.99.5)
FormDehySubuC3	Formylmethanofuran dehydrogenase (tungsten) subunit C (EC 1.2.99.5)
FormDehySubuD	Formylmethanofuran dehydrogenase (molybdenum) subunit D (EC 1.2.99.5)
FormDehySubuD2	Formylmethanofuran dehydrogenase subunit D (EC 1.2.99.5)
FormDehySubuD3	Formylmethanofuran dehydrogenase (tungsten) subunit D (EC 1.2.99.5)
FormDnaGlyc	Formamidopyrimidine-DNA glycosylase (EC 3.2.2.23)
FormEfflTran	Formate efflux transporter (TC 2.A.44 family)
FormImin	Formiminoglutamic iminohydrolase (EC 3.5.3.13)
FormPhosLiga	Formate--phosphoribosylaminoimidazolecarboxamide ligase (EC 6.3.4.23)
FormTetrLiga	Formate--tetrahydrofolate ligase (EC 6.3.4.3)
FormTetrNForm	Formylmethanofuran--tetrahydromethanopterin N-formyltransferase (EC 2.3.1.101)
FosfResiProtFosa	Fosfomycin resistance protein FosA
FosfResiProtFosb	Fosfomycin resistance protein FosB
FosfResiProtFosx	Fosfomycin resistance protein FosX
Four4fe4sClusProt	Four [4Fe-4S] cluster protein DVU_0535
Frag2	Fragilysin (EC 3.4.24.74)
FratHomoCyayFaci2	Frataxin homolog CyaY, facilitates Fe-S cluster assembly, interacts with IscS
FreeMethSulfRedu	Free methionine-(R)-sulfoxide reductase, contains GAF domain
FreeMethSulfRedu2	Free methionine-(S)-sulfoxide reductase
FrmrNegaTranRegu	FrmR: Negative transcriptional regulator of formaldehyde detoxification operon
Fruc	Fructokinase (EC 2.7.1.4)
Fruc16BispBaciType	Fructose-1,6-bisphosphatase, Bacillus type (EC 3.1.3.11)
Fruc16BispGlpxType	Fructose-1,6-bisphosphatase, GlpX type (EC 3.1.3.11)
Fruc16BispTypeI	Fructose-1,6-bisphosphatase, type I (EC 3.1.3.11)
Fruc3Epim	Fructoselysine 3-epimerase
Fruc6Kina	Fructoselysine 6-kinase
Fruc6PhosDegl	Fructoselysine-6-phosphate deglycase
Fruc6PhosPhos	Fructose-6-phosphate phosphoketolase (EC 4.1.2.22)
FrucBispAldoArch	Fructose-bisphosphate aldolase, archaeal class I (EC 4.1.2.13)
FrucBispAldoBisp	Fructose-bisphosphate aldolase/bisphosphatase ancestral bifunctional (EC 3.1.3.11) (EC 4.1.2.13)
FrucBispAldoClas	Fructose-bisphosphate aldolase class II (EC 4.1.2.13)
FrucBispAldoClas2	Fructose-bisphosphate aldolase class I (EC 4.1.2.13)
FrucPsicTranFrla	Fructoselysine/psicoselysine transporter FrlA
FrucTranGntp	Fructuronate transporter GntP
FtskSpoiFamiProt	ftsK/spoIIIE family protein
FtskSpoiFamiProt10	FtsK/SpoIIIE family protein EccC3, component of Type VII secretion system ESX-3
FtskSpoiFamiProt11	FtsK/SpoIIIE family protein EccC5, component of Type VII secretion system ESX-5
FtskSpoiFamiProt15	FtsK/SpoIIIE family protein EccC2, component of Type VII secretion system ESX-2
FtskSpoiFamiProt2	FtsK/SpoIIIE family protein, putative EssC/YukB component of Type VII secretion system
FtskSpoiFamiProt7	FtsK/SpoIIIE family protein EccC4, component of Type VII secretion system ESX-4
FtskSpoiFamiProt8	FtsK/SpoIIIE family protein EccCa1, component of Type VII secretion system ESX-1
FtskSpoiFamiProt9	FtsK/SpoIIIE family protein EccCb1, component of Type VII secretion system ESX-1
FucoPerm	Fucose permease
FumaHydrClasI	Fumarate hydratase class I (EC 4.2.1.2)
FumaHydrClasIAero	Fumarate hydratase class I, aerobic (EC 4.2.1.2)
FumaHydrClasIAlph	Fumarate hydratase class I, alpha region (EC 4.2.1.2)
FumaHydrClasIAnae	Fumarate hydratase class I, anaerobic (EC 4.2.1.2)
FumaHydrClasIBeta	Fumarate hydratase class I, beta region (EC 4.2.1.2)
FumaHydrClasIi	Fumarate hydratase class II (EC 4.2.1.2)
FumaNitrReduRegu3	fumarate/nitrate reduction regulatory protein
FumaReduCytoB556n1	Fumarate reductase cytochrome b-556 subunit
FumaReduCytoBSubu	Fumarate reductase cytochrome b subunit
FumaReduFlavSubu	Fumarate reductase flavoprotein subunit (EC 1.3.99.1)
FumaReduIronSulf	Fumarate reductase iron-sulfur protein (EC 1.3.5.4)
FumaReduMembAnch	Fumarate reductase membrane anchor subunit FrdC
FumaReduSubuC	Fumarate reductase subunit C
FumaReduSubuD	Fumarate reductase subunit D
FumaReduSubuTfra	Fumarate reductase (CoM/CoB), subunit TfrA (EC 1.3.4.1)
FumaReduSubuTfrb	Fumarate reductase (CoM/CoB), subunit TfrB (EC 1.3.4.1)
FumaReduTetrCyto	Fumarate reductase tetraheme cytochrome-c, FccA
FutaHydr	Futalosine hydrolase (EC 3.2.2.26)
GSpecAdenGlyc	A/G-specific adenine glycosylase (EC 3.2.2.-)
GTUMismSpecUracThym	G:T/U mismatch-specific uracil/thymine DNA-glycosylase
Gala	Galactokinase (EC 2.7.1.6)
Gala14AlphGala	Galacturan 1,4-alpha-galacturonidase (EC 3.2.1.67)
Gala1PhosUrid	Galactose-1-phosphate uridylyltransferase (EC 2.7.7.10)
Gala6PhosIsomLaca	Galactose-6-phosphate isomerase, LacA subunit (EC 5.3.1.26)
Gala6PhosIsomLacb	Galactose-6-phosphate isomerase, LacB subunit (EC 5.3.1.26)
GalaDehy	Galactonate dehydratase (EC 4.2.1.6)
GalaMethGalaAbcTran	Galactose/methyl galactoside ABC transport system, D-galactose-binding periplasmic protein MglB (TC 3.A.1.2.3)
GalaMethGalaAbcTran2	Galactose/methyl galactoside ABC transport system, ATP-binding protein MglA (EC 3.6.3.17)
GalaMethGalaAbcTran3	Galactose/methyl galactoside ABC transport system, permease protein MglC (TC 3.A.1.2.3)
GalaOAcet	Galactoside O-acetyltransferase (EC 2.3.1.18)
GalaOperReprGalr	Galactose operon repressor, GalR-LacI family of transcriptional regulators
GalaPerm	Galactose permease
GallAcidUtilTran	Gallic acid utilization transcriptional regulator, LysR family
GallDiox	Gallate dioxygenase (EC 1.13.11.57)
GallPerm	Gallate permease
GalnAlphGalnAlph	GalNAc-alpha-(1->4)-GalNAc-alpha-(1->3)-diNAcBac-PP-undecaprenol alpha- 1,4-N-acetyl-D-galactosaminyltransferase (EC 2.4.1.292)
GalnDinaPpUndeBeta	GalNAc(5)-diNAcBac-PP-undecaprenol beta-1,3-glucosyltransferase (EC 2.4.1.293)
GammAminAlphKeto	Gamma-aminobutyrate:alpha-ketoglutarate aminotransferase (EC 2.6.1.19)
GammButyDiox	Gamma-butyrobetaine dioxygenase (EC 1.14.11.1)
GammDGlutMesoDiam	Gamma-D-Glutamyl-meso-Diaminopimelate Amidase
GammDGlutMesoDiam2	Gamma-D-glutamyl-meso-diaminopimelate peptidase (EC 3.4.19.11)
GammDlGlutHydrPgss	Gamma-DL-glutamyl hydrolase PgsS, catalyzes PGA release (EC 3.4.19.-)
GammGlut	Gamma-glutamyltranspeptidase (EC 2.3.2.2)
GammGlutAminDehy	Gamma-glutamyl-aminobutyraldehyde dehydrogenase (EC 1.2.1.-)
GammGlutCarb	Gamma-glutamyl carboxylase (EC 4.1.1.90)
GammGlutGabaHydr	Gamma-glutamyl-GABA hydrolase (EC 3.5.1.94)
GammGlutPgsdCapd	Gamma-glutamyltranspeptidase PgsD/CapD, catalyses PGA anchorage to peptidoglycan (EC 2.3.2.2)
GammGlutPhosRedu	Gamma-glutamyl phosphate reductase (EC 1.2.1.41)
GammGlutPhosRedu2	Gamma-glutamyl phosphate reductase, cyanobacterial subgroup (EC 1.2.1.41)
GammGlutPutrOxid	Gamma-glutamyl-putrescine oxidase (EC1.4.3.-)
GammGlutPutrSynt	Gamma-glutamyl-putrescine synthetase (EC 6.3.1.11)
GammTocoMeth	gamma-tocopherol methyltransferase (EC 2.1.1.95)
GasVesiProtGvpa	Gas vesicle protein GvpA
GasVesiProtGvpb	Gas vesicle protein GvpB
GasVesiProtGvpc	Gas vesicle protein GvpC
GasVesiProtGvpd	Gas vesicle protein GvpD
GasVesiProtGvpe	Gas vesicle protein GvpE
GasVesiProtGvpf	Gas vesicle protein GvpF
GasVesiProtGvpg	Gas vesicle protein GvpG
GasVesiProtGvphHeat	Gas vesicle protein GvpH, heat shock protein Hsp20
GasVesiProtGvpi	Gas vesicle protein GvpI
GasVesiProtGvpj	Gas vesicle protein GvpJ
GasVesiProtGvpk	Gas vesicle protein GvpK
GasVesiProtGvpl	Gas vesicle protein GvpL
GasVesiProtGvpm	Gas vesicle protein GvpM
GasVesiProtGvpn	gas vesicle protein GvpN
GasVesiProtGvpo	Gas vesicle protein GvpO
GasVesiProtGvpp	Gas vesicle protein GvpP
GasVesiProtGvpq	Gas vesicle protein GvpQ
GasVesiProtGvpt	gas vesicle protein GvpT
GasVesiProtGvpu	gas vesicle protein GvpU
GatiProtPpe6Comp	Gating protein PPE68, component of Type VII secretion system ESX-1
Gdp24Diac246Trid	GDP-2,4-diacetamido-2,4,6-trideoxy-alpha-D-glucopyranose 2-epimerase (hydrolyzing)
Gdp2Acet26DideAlph	GDP-2-acetamido-2,6-dideoxy-alpha-D-xylo-hexos-4-ulose aminotransferase [PLP]
Gdp4Amin46DideAlph	GDP-4-amino-4,6-dideoxy-alpha-D-acetylglucosamine N-acetyltransferase
GdpGlucNAcet	GDP-glucosamine N-acetyltransferase
GdpLFucoSynt	GDP-L-fucose synthetase (EC 1.1.1.271)
GdpMann46Dehy	GDP-mannose 4,6-dehydratase (EC 4.2.1.47)
GdpMann6Dehy	GDP-mannose 6-dehydrogenase (EC 1.1.1.132)
GdpMannMannHydr	GDP-mannose mannosyl hydrolase (EC 3.6.1.-)
GdpMannPyroNudk	GDP-mannose pyrophosphatase NudK
GdpNAcet46DehyNad	GDP-N-acetylglucosamine 4,6-dehydratase [NAD+]
GeneSecrPathProt	General secretion pathway protein F
GeneSecrPathProt10	general secretion pathway protein H
GeneSecrPathProt11	General secretion pathway protein J
GeneSecrPathProt12	General secretion pathway protein C
GeneSecrPathProt13	General secretion pathway protein B
GeneSecrPathProt15	General secretion pathway protein A
GeneSecrPathProt2	general secretion pathway protein G
GeneSecrPathProt24	General secretion pathway protein O
GeneSecrPathProt3	General secretion pathway protein E
GeneSecrPathProt4	General secretion pathway protein D
GeneSecrPathProt5	General secretion pathway protein N
GeneSecrPathProt6	general secretion pathway protein M
GeneSecrPathProt7	general secretion pathway protein L
GeneSecrPathProt8	General secretion pathway protein K
GeneSecrPathProt9	general secretion pathway protein I
GeneStreProtOxir	General stress protein, oxireductase
GeneTranAgenCaps	Gene Transfer Agent capsid protein
GeneTranAgenFadFmn	Gene Transfer Agent FAD/FMN-containing dehydrogenase
GeneTranAgenHead	Gene Transfer Agent head-tail adaptor protein
GeneTranAgenHost	Gene Transfer Agent host specificity protein
GeneTranAgenNlpc	Gene Transfer Agent NlpC/P60 family peptidase
GeneTranAgenOrfg	Gene Transfer Agent (GTA) ORFG06
GeneTranAgenOrfg3	Gene Transfer Agent (GTA) ORFG08
GeneTranAgenOrfg4	Gene Transfer Agent (GTA) ORFG10
GeneTranAgenOrfg5	Gene Transfer Agent (GTA) ORFG10b
GeneTranAgenOrfg6	Gene Transfer Agent (GTA) ORFG12
GeneTranAgenOrfg8	Gene Transfer Agent (GTA) ORFG01
GeneTranAgenPort	Gene Transfer Agent portal protein
GeneTranAgenProh	Gene Transfer Agent prohead protease
GeneTranAgenTail	Gene Transfer Agent tail protein
GeneTranAgenTail2	Gene Transfer Agent tail tape measure
GeneTranAgenTerm	Gene Transfer Agent terminase protein
GeraCoaCarbBiotCont	Geranyl-CoA carboxylase biotin-containing subunit (EC 6.4.1.5)
GeraCoaCarbCarbTran	Geranyl-CoA carboxylase carboxyl transferase subunit (EC 6.4.1.5)
GeraDiphRedu	Geranylgeranyl diphosphate reductase (EC 1.3.1.83)
GeraDiphSynt	Geranylgeranyl diphosphate synthase (EC 2.5.1.29)
GermSpecNAcetLAlan	Germination-specific N-acetylmuramoyl-L-alanine amidase, cell wall hydrolase CwlD (EC 3.5.1.28)
GernGertProtFami	GerN/GerT protein family, Na+/H+ antiporter required for inosine-dependent spore germination and outgrowth
GerpGerpProtFami	GerPF/GerPA protein family, required for proper assembly of spore coat, mutations lead to super-dormant spore
GftbGlycTranFami	GftB: Glycosyl transferase, family 8
GlobNitrReguProt	Global nitrogen regulatory protein, CRP family of transcriptional regulators
GlpfImplLactRace	GlpF1: implicated in lactate racemization
Gluc	Gluconokinase (EC 2.7.1.12)
Gluc1Dehy	Glucose 1-dehydrogenase (EC 1.1.1.47)
Gluc1Phos	Glucose-1-phosphatase (EC 3.1.3.10)
Gluc1PhosAden	Glucose-1-phosphate adenylyltransferase (EC 2.7.7.27)
Gluc1PhosCyti	Glucose-1-phosphate cytidylyltransferase (EC 2.7.7.33)
Gluc1PhosGuan	Glucosamine-1-phosphate guanylyltransferase
Gluc1PhosNAcet	Glucosamine-1-phosphate N-acetyltransferase (EC 2.3.1.157)
Gluc1PhosThym	Glucose-1-phosphate thymidylyltransferase (EC 2.7.7.24)
Gluc2DehyMembBoun	Gluconate 2-dehydrogenase, membrane-bound, gamma subunit (EC 1.1.99.3)
Gluc2DehyMembBoun2	Gluconate 2-dehydrogenase, membrane-bound, flavoprotein (EC 1.1.99.3)
Gluc2DehyMembBoun3	Gluconate 2-dehydrogenase, membrane-bound, cytochrome c (EC 1.1.99.3)
Gluc3	Glucokinase (EC 2.7.1.2)
Gluc3PhosSynt	Glucosyl-3-phosphoglycerate synthase (EC 2.4.1.266)
Gluc4	Gluconolactonase (EC 3.1.1.17)
Gluc6Phos1Dehy	Glucose-6-phosphate 1-dehydrogenase (EC 1.1.1.49)
Gluc6PhosDeam	Glucosamine-6-phosphate deaminase (EC 3.5.99.6)
Gluc6PhosDeamIsom	Glucosamine-6-phosphate deaminase [isomerizing], alternative (EC 3.5.99.6)
Gluc6PhosDegl	Glucoselysine-6-phosphate deglycase
Gluc6PhosIsom	Glucose-6-phosphate isomerase (EC 5.3.1.9)
Gluc6PhosIsomArch	Glucose-6-phosphate isomerase, archaeal II (EC 5.3.1.9)
Gluc6PhosIsomArch2	Glucose-6-phosphate isomerase, archaeal (EC 5.3.1.9)
GlucDehy	Gluconate dehydratase (EC 4.2.1.39)
GlucDehy2	Glucarate dehydratase (EC 4.2.1.40)
GlucDehyMembBoun	Glucose dehydrogenase, membrane-bound, gamma subunit (EC 1.1.5.9)
GlucDehyMembBoun2	Glucose dehydrogenase, membrane-bound, flavoprotein (EC 1.1.99.10)
GlucDehyMembBoun3	Glucose dehydrogenase, membrane-bound, cytochrome c (EC 1.1.99.10)
GlucDehyPqqDepe	Glucose dehydrogenase, PQQ-dependent (EC 1.1.5.2)
GlucFruc6PhosAmin	Glucosamine--fructose-6-phosphate aminotransferase [isomerizing] (EC 2.6.1.16)
GlucGalaDehy	Gluconate/galactonate dehydratase (EC 4.2.1.140)
GlucMalaCystLiga	Glucosaminyl-malate:cysteine ligase
GlucOperTranRepr	Gluconate operon transcriptional repressor
GlucPerm	Gluconate permease
GlucPerm2	Glucuronide permease
GlucPermBsu4Homo	Gluconate permease, Bsu4004 homolog
GlucSynt	Glucosylglycerate synthase (EC 2.4.1.268)
GlucTranFaciUidc	Glucuronide transport facilitator UidC
GlucTranFamiProt	Gluconate transporter family protein
GlucTranUidb	Glucuronide transporter UidB
GlucUtilSystGntI	Gluconate utilization system Gnt-I transcriptional repressor
Glut1Semi21Amin	Glutamate-1-semialdehyde 2,1-aminomutase (EC 5.4.3.8)
Glut1n1	Glutaredoxin 1
Glut2	Glutaredoxin
Glut2n1	Glutaredoxin 2
Glut3n1	glutaredoxin 3
Glut3n2	Glutaredoxin 3 (Grx3)
Glut3n3	Glutaredoxin 3 (Grx1)
Glut3n4	Glutaredoxin 3 (Grx2)
Glut5Kina	Glutamate 5-kinase (EC 2.7.2.11)
GlutAbcTranAtpBind	Glutathione ABC transporter ATP-binding protein GsiA
GlutAbcTranPermProt2	Glutathione ABC transporter permease protein GsiD
GlutAbcTranPermProt3	Glutathione ABC transporter permease protein GsiC
GlutAbcTranSubsBind2	Glutathione ABC transporter substrate-binding protein GsiB
GlutAmid	glutamine amidotransferase (EC 4.1.3.27 )
GlutAmid2	Glutathionylspermidine amidohydrolase (EC 3.5.1.78)
GlutAmidChaiNadSynt	Glutamine amidotransferase chain of NAD synthetase
GlutAmidClasI	Glutamine amidotransferase, class I (EC 6.3.5.2)
GlutAmidProtGlxb	Glutamine amidotransferase protein GlxB (EC 2.4.2.-)
GlutAmin	Glutamyl aminopeptidase (EC 3.4.11.7)
GlutAmmoLigaAden	Glutamate-ammonia-ligase adenylyltransferase (EC 2.7.7.42)
GlutBiosBifuProt	Glutathione biosynthesis bifunctional protein gshF (EC 6.3.2.3) (EC 6.3.2.2)
GlutCoaDecaAlphChai	Glutaconyl-CoA decarboxylase alpha chain (EC 4.1.1.70)
GlutCoaDecaBetaChai	Glutaconyl-CoA decarboxylase beta chain (EC 4.1.1.70)
GlutCoaDecaDeltChai	Glutaconyl-CoA decarboxylase delta chain (EC 4.1.1.70)
GlutCoaDecaGammChai	Glutaconyl-CoA decarboxylase gamma chain
GlutCoaTranSubu	Glutaconate CoA-transferase subunit A (EC 2.8.3.12)
GlutCoaTranSubuB	Glutaconate CoA-transferase subunit B (EC 2.8.3.12)
GlutCystLiga	Glutamate--cysteine ligase (EC 6.3.2.2)
GlutCystLigaArch	Glutamate--cysteine ligase archaeal (EC 6.3.2.2)
GlutCystLigaDive	Glutamate--cysteine ligase, divergent, of Alpha- and Beta-proteobacteria type (EC 6.3.2.2)
GlutDeca	Glutamate decarboxylase (EC 4.1.1.15)
GlutDepe2Keto4Meth	Glutamine-dependent 2-keto-4-methylthiobutyrate transaminase
GlutDepeFormActi	Glutathione-dependent formaldehyde-activating enzyme (EC 4.4.1.22)
GlutEndoPrecBlas	Glutamyl endopeptidase precursor, blaSE (EC 3.4.21.19)
GlutEndoPrecSeri	Glutamyl endopeptidase precursor, serine proteinase SspA (EC 3.4.21.19)
GlutForm	Glutamate formiminotransferase (EC 2.1.2.5)
GlutFruc6PhosTran2	Glutamine--fructose-6-phosphate transaminase (isomerizing), isomerase subunit (EC 2.6.1.16)
GlutFruc6PhosTran3	Glutamine--fructose-6-phosphate transaminase (isomerizing), glutaminase subunit (EC 2.6.1.16)
GlutHydr	Glutathione hydrolase (EC 3.4.19.13)
GlutLikeProtNrdh	glutaredoxin-like protein NrdH, required for reduction of Ribonucleotide reductase class Ib
GlutLyswLigaArgx	Glutamate--LysW ligase ArgX
GlutPero	Glutathione peroxidase (EC 1.11.1.9)
GlutPeroFamiProt	Glutathione peroxidase family protein
GlutRace	Glutamate racemase (EC 5.1.1.3)
GlutRedu	Glutathione reductase (EC 1.8.1.7)
GlutRelaProt	Glutaredoxin-related protein
GlutSTran	Glutathione S-transferase (EC 2.5.1.18)
GlutSTranAlph	Glutathione S-transferase, alpha (EC 2.5.1.18)
GlutSTranDelt	Glutathione S-transferase, delta (EC 2.5.1.18)
GlutSTranFamiProt	Glutathione S-transferase family protein
GlutSTranOmeg	Glutathione S-transferase, omega (EC 2.5.1.18)
GlutSTranPhi	Glutathione S-transferase, phi (EC 2.5.1.18)
GlutSTranStreType	Glutathione S-transferase, Streptococcal type (EC 2.5.1.18)
GlutSTranThet	Glutathione S-transferase, theta (EC 2.5.1.18)
GlutSTranUnnaSubg	Glutathione S-transferase, unnamed subgroup (EC 2.5.1.18)
GlutSTranUnnaSubg2	Glutathione S-transferase, unnamed subgroup 2 (EC 2.5.1.18)
GlutSTranZeta	Glutathione S-transferase, zeta (EC 2.5.1.18)
GlutSynt	Glutathione synthetase (EC 6.3.2.3)
GlutSynt2	Glutathionylspermidine synthase (EC 6.3.1.8)
GlutSynt3	Glutamine synthetase (EC 6.3.1.2)
GlutSyntClosType	Glutamine synthetase, clostridia type (EC 6.3.1.2)
GlutSyntFamiProt	Glutamine synthetase family protein in hypothetical Actinobacterial gene cluster
GlutSyntFamiProt2	glutamine synthetase family protein
GlutSyntNadpLarg	Glutamate synthase [NADPH] large chain (EC 1.4.1.13)
GlutSyntNadpPuta	Glutamate synthase [NADPH] putative GlxC chain (EC 1.4.1.13)
GlutSyntNadpSmal	Glutamate synthase [NADPH] small chain (EC 1.4.1.13)
GlutSyntPuta	Glutamine synthetase, putative (EC 6.3.1.2)
GlutSyntTypeI	Glutamine synthetase type I (EC 6.3.1.2)
GlutSyntTypeIiEuka	Glutamine synthetase type II, eukaryotic (EC 6.3.1.2)
GlutSyntTypeIiiGlnn	Glutamine synthetase type III, GlnN (EC 6.3.1.2)
GlutTrnaAmidAspa	Glutamyl-tRNA(Gln) amidotransferase asparaginase subunit (EC 6.3.5.7)
GlutTrnaAmidSubu	Glutamyl-tRNA(Gln) amidotransferase subunit C (EC 6.3.5.7)
GlutTrnaAmidSubu2	Glutamyl-tRNA(Gln) amidotransferase subunit A (EC 6.3.5.7)
GlutTrnaAmidSubu3	Glutamyl-tRNA(Gln) amidotransferase subunit B (EC 6.3.5.7)
GlutTrnaAmidSubu4	Glutamyl-tRNA(Gln) amidotransferase subunit A-like protein
GlutTrnaAmidSubu8	Glutamyl-tRNA(Gln) amidotransferase subunit F (EC 6.3.5.7)
GlutTrnaAmidTran	Glutamyl-tRNA(Gln) amidotransferase transferase subunit (EC 6.3.5.7)
GlutTrnaRedu	Glutamyl-tRNA reductase (EC 1.2.1.70)
GlutTrnaSynt	Glutaminyl-tRNA synthetase (EC 6.1.1.18)
GlutTrnaSynt2	Glutamyl-tRNA synthetase (EC 6.1.1.17)
GlutTrnaSynt3	Glutamyl-tRNA(Gln) synthetase (EC 6.1.1.24)
GlutTrnaSyntChlo	Glutaminyl-tRNA synthetase, chloroplast (EC 6.1.1.18)
GlutTrnaSyntChlo2	Glutamyl-tRNA synthetase, chloroplast (EC 6.1.1.17)
GlutTrnaSyntDoma	Glutamyl-tRNA synthetase domain protein
GlutTrnaSyntMito	Glutamyl-tRNA synthetase, mitochondrial (EC 6.1.1.17)
GlutTrnaSyntMito2	Glutaminyl-tRNA synthetase, mitochondrial (EC 6.1.1.18)
GlutUdp2Acet2Deox	Glutamate--UDP-2-acetamido-2-deoxy-D-ribohex-3-uluronic acid aminotransferase (PLP cofactor) (EC 2.6.1.98)
GlyTrnaDeac	Gly-tRNA(Ala) deacylase
Glyc	Glycosyltransferase (EC 2.4.1.-)
Glyc1PhosDehyNad	Glycerol-1-phosphate dehydrogenase [NAD(P)] (EC 1.1.1.261)
Glyc3PhosAbcTran10	Glycerol-3-phosphate ABC transporter, ATP-binding protein GlpT
Glyc3PhosAbcTran5	Glycerol-3-phosphate ABC transporter, ATP-binding protein GlpS
Glyc3PhosAbcTran7	Glycerol-3-phosphate ABC transporter, substrate-binding protein GlpV
Glyc3PhosAbcTran8	Glycerol-3-phosphate ABC transporter, permease protein GlpQ
Glyc3PhosAbcTran9	Glycerol-3-phosphate ABC transporter, permease protein GlpP
Glyc3PhosAcyl	Glycerol-3-phosphate acyltransferase (EC 2.3.1.15)
Glyc3PhosDehy	Glycerol-3-phosphate dehydrogenase (EC 1.1.5.3)
Glyc3PhosDehy4	Glyceraldehyde-3-phosphate dehydrogenase (NADP(+)) (EC 1.2.1.9)
Glyc3PhosDehyNad	Glycerol-3-phosphate dehydrogenase [NAD(P)+] (EC 1.1.1.94)
Glyc3PhosFerrOxid	Glyceraldehyde-3-phosphate: ferredoxin oxidoreductase (EC 1.2.7.6)
Glyc3PhosKetoIsom	Glyceraldehyde-3-phosphate ketol-isomerase (EC 5.3.1.1)
Glyc3PhosReguRepr2	Glycerol-3-phosphate regulon repressor GlpR
Glyc3PhosTranRela	Glycerol-3-phosphate transport-related protein GlpU
GlycBetaAbcTranSyst3	Glycine betaine ABC transport system, ATP-binding protein OpuAA (EC 3.6.3.32)
GlycBetaAbcTranSyst4	Glycine betaine ABC transport system, glycine betaine-binding protein OpuAC
GlycBetaAbcTranSyst5	Glycine betaine ABC transport system, substrate binding protein OpuAC
GlycBetaAbcTranSyst6	Glycine betaine ABC transport system, permease protein OpuAB
GlycBiosProtGlgd	Glycogen biosynthesis protein GlgD, glucose-1-phosphate adenylyltransferase family
GlycBranEnzyGh57n1	Glycogen branching enzyme, GH-57-type, archaeal (EC 2.4.1.18)
GlycCleaSystHProt	Glycine cleavage system H protein
GlycCleaSystTran	Glycine cleavage system transcriptional activator GcvA
GlycCleaSystTran2	Glycine cleavage system transcriptional antiactivator GcvR
GlycCleaSystTran3	Glycine cleavage system transcriptional activator
GlycDebrEnzy	Glycogen debranching enzyme (EC 3.2.1.-)
GlycDebrEnzyRela	glycogen debranching enzyme-related protein
GlycDehy	Glycerol dehydrogenase (EC 1.1.1.6)
GlycDehy2	Glycolaldehyde dehydrogenase (EC 1.2.1.21)
GlycDehyDeca	Glycine dehydrogenase [decarboxylating] (glycine cleavage system P protein) (EC 1.4.4.2)
GlycDehyDeca2	Glycine dehydrogenase [decarboxylating] (glycine cleavage system P1 protein) (EC 1.4.4.2)
GlycDehyDeca3	Glycine dehydrogenase [decarboxylating] (glycine cleavage system P2 protein) (EC 1.4.4.2)
GlycDehyFadBindSubu	Glycolate dehydrogenase, FAD-binding subunit GlcE (EC 1.1.99.14)
GlycDehyIronSulf	Glycolate dehydrogenase, iron-sulfur subunit GlcF (EC 1.1.99.14)
GlycDehyLargSubu	Glycerol dehydratase large subunit (EC 4.2.1.30)
GlycDehyMediSubu	Glycerol dehydratase medium subunit (EC 4.2.1.30)
GlycDehyReacFact	Glycerol dehydratase reactivation factor small subunit
GlycDehyReacFact2	Glycerol dehydratase reactivation factor large subunit
GlycDehySmalSubu	Glycerol dehydratase small subunit (EC 4.2.1.30)
GlycDehySubuGlcd	Glycolate dehydrogenase, subunit GlcD (EC 1.1.99.14)
GlycDiesPhos	Glycerophosphoryl diester phosphodiesterase (EC 3.1.4.46)
GlycGlycEndoLytm	Glycyl-glycine endopeptidase LytM precursor (EC 3.4.24.75)
GlycIrob	Glycosyltransferase IroB
GlycKina	Glycerol kinase (EC 2.7.1.30)
GlycKina2	Glycerate kinase (EC 2.7.1.31)
GlycLprgAntiP27Modu	Glycolipoprotein LprG, antigen P27 modulating immune response against mycobacteria in favour of bacterial persistence
GlycLpriLysoInhi	Glycolipoprotein LprI, lysozyme inhibitor
GlycNMeth	Glycine N-methyltransferase (EC 2.1.1.20)
GlycOxid2	Glycolate oxidase (EC 1.1.3.15)
GlycOxidThio	Glycine oxidase ThiO (EC 1.4.3.19)
GlycPerm	Glycolate permease
GlycPhos	Glycogen phosphorylase (EC 2.4.1.1)
GlycReduCompBAlph	Glycine reductase component B alpha subunit (EC 1.21.4.2)
GlycReduCompBBeta	Glycine reductase component B beta subunit (EC 1.21.4.2)
GlycReduCompBGamm	Glycine reductase component B gamma subunit (EC 1.21.4.2)
GlycRibo	Glycine riboswitch
GlycRichCellWall	Glycine-rich cell wall structural protein precursor
GlycSarcBetaRedu	Glycine/sarcosine/betaine reductase protein A
GlycSarcBetaRedu2	Glycine/sarcosine/betaine reductase component C chain 1
GlycSarcBetaRedu3	Glycine/sarcosine/betaine reductase component C chain 2
GlycSyntAdpGlucTran	Glycogen synthase, ADP-glucose transglucosylase (EC 2.4.1.21)
GlycSyntProtGlgs	Glycogen synthesis protein GlgS
GlycTranChloClus	Glycosyl transferase in Chlorophyll a cluster
GlycTranFami2n1	Glycosyl transferase, family 2 (EC 2.4.1.83)
GlycTranGrou1Fami5	Glycosyl transferase, group 1 family, anthrose biosynthesis
GlycTranGrou2Fami6	Glycosyl transferase ,group 2 family, anthrose biosynthesis
GlycTrnaSynt	Glycyl-tRNA synthetase (EC 6.1.1.14)
GlycTrnaSyntAlph	Glycyl-tRNA synthetase alpha chain (EC 6.1.1.14)
GlycTrnaSyntAlph3	Glycyl-tRNA synthetase alpha chain, mitochondrial (EC 6.1.1.14)
GlycTrnaSyntAlph4	Glycyl-tRNA synthetase alpha chain, chloroplast (EC 6.1.1.14)
GlycTrnaSyntBeta	Glycyl-tRNA synthetase beta chain (EC 6.1.1.14)
GlycTrnaSyntBeta4	Glycyl-tRNA synthetase beta chain, mitochondrial (EC 6.1.1.14)
GlycTrnaSyntBeta5	Glycyl-tRNA synthetase beta chain, chloroplast (EC 6.1.1.14)
GlycTrnaSyntCarb	Glycyl-tRNA synthetase, carboxy-terminal 114 amino acids (EC 6.1.1.14)
GlycTrnaSyntChlo	Glycyl-tRNA synthetase, chloroplast (EC 6.1.1.14)
GlycTrnaSyntMito	Glycyl-tRNA synthetase, mitochondrial (EC 6.1.1.14)
GlycUptaFaciProt	Glycerol uptake facilitator protein
GlycUtilOperTran	Glycolate utilization operon transcriptional activator GlcC
GlyoBtlbLocu	Glyoxalase in BtlB locus
GlyoCarb	Glyoxylate carboligase (EC 4.1.1.47)
GlyoDioxFamiDoma	glyoxalase/dioxygenase family domain
GlyoFamiProt2	Glyoxylase family protein
GlyoPtllPentBios	Glyoxalase PtlL in pentalenolactone biosynthesis
GlyoRedu	Glyoxylate reductase (EC 1.1.1.79)
GmpImpNuclYrfg	GMP/IMP nucleotidase YrfG
GmpRedu	GMP reductase (EC 1.7.1.7)
GmpSynt	GMP synthase (EC 6.3.5.2)
GmpSyntGlutHydr	GMP synthase [glutamine-hydrolyzing] (EC 6.3.5.2)
GmpSyntGlutHydrAmid	GMP synthase [glutamine-hydrolyzing], amidotransferase subunit (EC 6.3.5.2)
GmpSyntGlutHydrAtp	GMP synthase [glutamine-hydrolyzing], ATP pyrophosphatase subunit (EC 6.3.5.2)
GtpBindNuclAcidBind	GTP-binding and nucleic acid-binding protein YchF
GtpBindProt	GTP-binding protein
GtpBindProtEnga	GTP-binding protein EngA
GtpBindProtEngb	GTP-binding protein EngB
GtpBindProtEra	GTP-binding protein Era
GtpBindProtObg	GTP-binding protein Obg
GtpBindProtRelaHflx	GTP-binding protein related to HflX
GtpBindProtTypaBipa	GTP-binding protein TypA/BipA
GtpBindProtYqehRequ	GTP-binding protein YqeH, required for biogenesis of 30S ribosome subunit
GtpCycl1Type2Homo	GTP cyclohydrolase 1 type 2 homolog YbgI
GtpCyclIType1n1	GTP cyclohydrolase I type 1 (EC 3.5.4.16)
GtpCyclIType2n1	GTP cyclohydrolase I type 2 (EC 3.5.4.16)
GtpCyclIi	GTP cyclohydrolase II (EC 3.5.4.25)
GtpCyclIiHomo	GTP cyclohydrolase II homolog
GtpCyclIii	GTP cyclohydrolase III (EC 3.5.4.29)
GtpPyro	GTP pyrophosphokinase (EC 2.7.6.5)
GtpPyroPpgpSyntI	GTP pyrophosphokinase, (p)ppGpp synthetase I (EC 2.7.6.5)
GtpPyroPpgpSyntIi	GTP pyrophosphokinase, (p)ppGpp synthetase II (EC 2.7.6.5)
GtpSensTranPleiRepr	GTP-sensing transcriptional pleiotropic repressor codY
Guan35Bis3Pyro	Guanosine-3',5'-bis(diphosphate) 3'-pyrophosphohydrolase (EC 3.1.7.2)
Guan5Trip3DiphPyro	Guanosine-5'-triphosphate,3'-diphosphate pyrophosphatase (EC 3.6.1.40)
GuanDeam	Guanine deaminase (EC 3.5.4.3)
GuanKina	Guanylate kinase (EC 2.7.4.8)
GuanSpecRibo	Guanyl-specific ribonuclease (EC 3.1.27.3)
HAcaRiboCompSubu	H/ACA ribonucleoprotein complex subunit CBF5
HAcaRiboCompSubu3	H/ACA ribonucleoprotein complex subunit Gar1
HAcaRiboCompSubu4	H/ACA ribonucleoprotein complex subunit Nop10
HAcaRiboCompSubu5	H/ACA ribonucleoprotein complex subunit Nhp2
HadSupeSubfIaDoma	HAD-superfamily subfamily IA domain, fused with riboflavin kinase
Halo2	Halocyanin
HaloDehaLikeProt	Haloalkane dehalogenase-like protein
HaloDehaLikeProt3	Haloalkane dehalogenase-like protein, At1g52510/AT4G12830 homolog
Hbs1Prot	HBS1 protein
HdSupeHydrCa_c	HD superfamily hydrolase CA_C3562
HeatInduTranRepr	Heat-inducible transcription repressor HrcA
HeatRepeContProt	HEAT repeat-containing protein
HeatShocProt60Fami	Heat shock protein 60 family chaperone GroEL
HeatShocProt60Fami2	Heat shock protein 60 family co-chaperone GroES
HeatShocProtGrpe	Heat shock protein GrpE
HeatShocProtYcim	Heat shock (predicted periplasmic) protein YciM, precursor
HeavMetaAssoDoma	Heavy-metal-associated domain (N-terminus) and membrane-bounded cytochrome biogenesis cycZ-like domain, possible membrane copper tolerance protein
HeliPriaEsseForOric	Helicase PriA essential for oriC/DnaA-independent DNA replication
HeliTurnHeliDoma6	Helix-turn-helix domain COG3177
HeliTurnHeliDoma7	Helix-turn-helix domain in RibA/RibB fusion protein
HemeAbcTranAtpBind	Heme ABC transporter (Streptococcus), ATP-binding protein
HemeAbcTranAtpaComp	Heme ABC transporter, ATPase component HmuV
HemeAbcTranCellSurf	Heme ABC transporter, cell surface heme and hemoprotein receptor HmuT
HemeAbcTranHemeHemo	Heme ABC transporter (Streptococcus), heme and hemoglobin-binding protein SiaA/HtsA
HemeAbcTranPermProt	Heme ABC transporter, permease protein HmuU
HemeAbcTranPermProt2	Heme ABC transporter (Streptococcus), permease protein
HemeAbcTypeTranHtsa	Heme ABC type transporter HtsABC, permease protein HtsC
HemeAbcTypeTranHtsa2	Heme ABC type transporter HtsABC, permease protein HtsB
HemeAbcTypeTranHtsa3	Heme ABC type transporter HtsABC, heme-binding protein
HemeBBindProtPcro	Heme b-binding protein PcrO
HemeBiosProtRela	Heme biosynthesis protein related to NirD and NirG
HemeBiosProtRela2	Heme biosynthesis protein related to NirL and NirH
HemeBiosProtRela3	Heme biosynthesis protein related to NirG
HemeBiosProtRela4	Heme biosynthesis protein related to NirH
HemeBiosProtRela5	Heme biosynthesis protein related to NirD
HemeBiosProtRela6	Heme biosynthesis protein related to NirL
HemeD1BiosProtNird	Heme d1 biosynthesis protein NirD
HemeD1BiosProtNirf	Heme d1 biosynthesis protein NirF
HemeD1BiosProtNirg	Heme d1 biosynthesis protein NirG
HemeD1BiosProtNirh	Heme d1 biosynthesis protein NirH
HemeD1BiosProtNirj	Heme d1 biosynthesis protein NirJ
HemeD1BiosProtNirl	Heme d1 biosynthesis protein NirL
HemeDegrCytoOxyg	Heme-degrading cytoplasmic oxygenase IsdG
HemeDegrCytoOxyg2	Heme-degrading cytoplasmic oxygenase IsdI
HemeDegrMono	Heme-degrading monooxygenase (EC 1.14.99.3)
HemeEfflSystAtpa	Heme efflux system ATPase HrtA
HemeEfflSystPerm	Heme efflux system permease HrtB
HemeHheCatiBindDoma	Hemerythrin HHE cation binding domain-containing protein
HemeInseFactCbax	Heme A insertion factor CbaX (alternative to Surf1)
HemeOSyntProtIxFarn	Heme O synthase, protoheme IX farnesyltransferase COX10-CtaB (EC 2.5.1.-)
HemeOxyg	Heme oxygenase (EC 1.14.99.3)
HemeOxygHemoAsso	heme oxygenase HemO, associated with heme uptake
HemeSyntCytoOxid	Heme A synthase, cytochrome oxidase biogenesis protein Cox15-CtaA
HemeTranAnalIsdd	Heme transporter analogous to IsdDEF, ATP-binding protein
HemeTranIsddLipo	Heme transporter IsdDEF, lipoprotein IsdE
HemeTranIsddMemb	Heme transporter IsdDEF, membrane component IsdD
HemeTranIsddPerm	Heme transporter IsdDEF, permease component IsdF
HemiAbcTranPermProt	Hemin ABC transporter, permease protein
HemiTranProtHmus	Hemin transport protein HmuS
HemoActiSecrProt	Hemolysin activation/secretion protein associated with VreARI signalling system
HemoDepeTwoCompSyst	Hemoglobin-dependent two component system response regulator HrrA
HemoDepeTwoCompSyst2	Hemoglobin-dependent two component system, sensory histidine kinase HrrS
HemoHasa	Hemophore HasA
HemoHasaOuteMemb	Hemophore HasA outer membrane receptor HasR
HemoHemeDepeTwoComp	Hemoglobin, heme-dependent two component system sensory histidine kinase ChrS
HemoHemeDepeTwoComp2	Hemoglobin, heme-dependent two component system response regulator ChrA
HemoHmuyRecrHeme	Hemophore HmuY, recruits heme from host protein carriers
HemoLikeProtHbn	Hemoglobin-like protein HbN
HemoLikeProtHbo	Hemoglobin-like protein HbO
HemxProtNegaEffe	HemX protein, negative effector of steady-state concentration of glutamyl-tRNA reductase
HepnDomaContNucl	HEPN domain-containing nucleotidyltransferase
HeptDiphSyntComp	Heptaprenyl diphosphate synthase component II (EC 2.5.1.30)
HeptDiphSyntComp2	Heptaprenyl diphosphate synthase component I (EC 2.5.1.30)
HeptPhosSynt	Heptaprenylglyceryl phosphate synthase (EC 2.5.1.n9)
HesaMoebThifFami3	HesA/MoeB/ThiF family protein, possibly E1-enzyme activating SAMPs for protein conjugation
HeteDecaBetaDRibo	Heteromeric decaprenylphosphoryl-beta-D-ribose 2'-epimerase subunit DprE2 (EC 1.1.1.333)
HeteDecaBetaDRibo2	Heteromeric decaprenylphosphoryl-beta-D-ribose 2'-epimerase subunit DprE1 (EC 1.1.98.3)
HeteDiffProtHetc	Heterocyst differentiation protein HetC
HeteDiffProtHetp	Heterocyst differentiation protein HetP
HeteEfflAbcTranMult	Heterodimeric efflux ABC transporter, multidrug resistance => BmrD subunit of BmrCD
HeteEfflAbcTranMult2	Heterodimeric efflux ABC transporter, multidrug resistance => BmrC subunit of BmrCD
HeteEfflAbcTranMult3	Heterodimeric efflux ABC transporter, multidrug resistance => LmrD subunit of LmrCD
HeteEfflAbcTranMult4	Heterodimeric efflux ABC transporter, multidrug resistance => LmrC subunit of LmrCD
HeteFormInhiSign	Heterocyst formation inhibiting signaling peptide PatS
Hexo	Hexokinase (EC 2.7.1.1)
HexuTran	Hexuronate transporter
HexuUtilOperTran	Hexuronate utilization operon transcriptional repressor ExuR
HflcProt	HflC protein
HflkProt	HflK protein
HighAffiCholUpta	High-affinity choline uptake protein BetT
HighAffiFe2Pb2Perm2	High-affinity Fe2+/Pb2+ permease precursor
HighAffiGlucTran	High-affinity gluconate transporter GntT
HighAffiProtThia	High-affinity proton/thiamine symporter Thi9
HighChloFluoFact	High chlorophyll fluorescence factor 244 (HCF244), required for translational initiation of psbA mRNA
HighChloFluoFact2	High chlorophyll fluorescence factor 173 (HCF173), required for translational initiation of psbA mRNA
HighFreqLysoProt	High frequency lysogenization protein HflD
HighMoleWeigCyto3	high-molecular-weight cytochrome c
HipbProt	HipB protein
HistAcetHpa2Rela	Histone acetyltransferase HPA2 and related acetyltransferases
HistAmmoLyas	Histidine ammonia-lyase (EC 4.3.1.3)
HistDeca	Histidine decarboxylase (EC 4.1.1.22)
HistDecaPyruType2	Histidine decarboxylase, pyruvoyl type, proenzyme precursor (EC 4.1.1.22)
HistDehy	Histidinol dehydrogenase (EC 1.1.1.23)
HistKinaArabSens	Histidine kinase in an arabinose sensing sensor
HistPhos	Histidinol-phosphatase (EC 3.1.3.15)
HistPhosAlteForm	Histidinol-phosphatase [alternative form] (EC 3.1.3.15)
HistPhosAmin	Histidinol-phosphate aminotransferase (EC 2.6.1.9)
HistTranProt	Histidine transport protein (permease)
HistTrnaSynt	Histidyl-tRNA synthetase (EC 6.1.1.21)
HistTrnaSyntBaci	Histidyl-tRNA synthetase, bacillus-type paralog (EC 6.1.1.21)
HistTrnaSyntChlo	Histidyl-tRNA synthetase, chloroplast (EC 6.1.1.21)
HistTrnaSyntMito	Histidyl-tRNA synthetase, mitochondrial (EC 6.1.1.21)
HistTrnaSyntRela	Histidyl-tRNA synthetase related protein in Streptococcus pneumoniae
HistTrnaSyntRela2	Histidyl-tRNA synthetase related protein 3
HistTrnaSyntWith	Histidyl-tRNA synthetase with highly diverged anticodon binding domain
HistUtilRepr	Histidine utilization repressor
HmpPpHydrCofDete	HMP-PP hydrolase (pyridoxal phosphatase) Cof, detected in genetic screen for thiamin metabolic genes
HmraProtInvoMeth	HmrA protein involved in methicillin resistance
HmrbProtInvoMeth	HmrB protein involved in methicillin resistance
HoliAssoHypoProt	Holin associated hypothetical protein
HoliAssoMembProt	Holin associated membrane protein 2
HoliAssoMembProt2	Holin associated membrane protein 1
HoliBactA118n1	Holin [Bacteriophage A118]
HoliLikeProt1n1	Holin-like protein 1
HoliLikeProt2n1	Holin-like protein 2
HoliLikeProtCida	Holin-like protein CidA
HoliSaBact11Mu50n1	Holin [SA bacteriophages 11, Mu50B]
HollJuncDnaHeliRuva	Holliday junction DNA helicase RuvA
HollJuncDnaHeliRuvb	Holliday junction DNA helicase RuvB (EC 3.1.22.4 )
HoloAcylCarrProt	Holo-[acyl-carrier-protein] synthase (EC 2.7.8.7)
HoloAcylCarrProt3	Holo-[acyl-carrier protein] synthase, alternative (EC 2.7.8.7)
Homo	Homoaconitase (EC 4.2.1.36)
HomoDehy	Homoserine dehydrogenase (EC 1.1.1.3)
HomoDehy2	Homoisocitrate dehydrogenase (EC 1.1.1.87)
HomoDesu	Homocysteine desulfhydrase (EC 4.4.1.2)
HomoGera	Homogentisate geranylgeranyltransferase (EC 2.5.1.-)
HomoKina	Homoserine kinase (EC 2.7.1.39)
HomoLargSubu	Homoaconitase large subunit (EC 4.2.1.36)
HomoOAcet	Homoserine O-acetyltransferase (EC 2.3.1.31)
HomoPhyt	Homogentisate phytyltransferase (EC 2.5.1.n8)
HomoSMeth	Homocysteine S-methyltransferase (EC 2.1.1.10)
HomoSmalSubu	Homoaconitase small subunit (EC 4.2.1.36)
HomoSynt	Homocitrate synthase (EC 2.3.3.14)
HomoSyntAlphSubu	Homocitrate synthase alpha subunit (EC 2.3.3.14)
HomoSyntOmegSubu	Homocitrate synthase omega subunit (EC 2.3.3.14)
HpaaProt	HpaA protein
HpapProt	HpaP protein
HprKinaPhos	HPr kinase/phosphorylase (EC 2.7.4.-) (EC 2.7.1.-)
HrpbProt2	HrpB4 protein
HrpdProt2	HrpD6 protein
HsprTranReprDnak	HspR, transcriptional repressor of DnaK operon
HthDomaProtSa16Bind	HTH domain protein SA1665, binds to mecA promoter region
HthTypeTranReguBeti	HTH-type transcriptional regulator BetI
HthTypeTranReguRv00n1	HTH-type transcriptional regulator Rv0023
HutOperPosiReguProt	Hut operon positive regulatory protein
HyalLyasPrec	Hyaluronate lyase precursor (EC 4.2.2.1)
HyalSynt	Hyaluronan synthase (EC 2.4.1.212)
HybrSensHistKina	Hybrid sensory histidine kinase in two-component regulatory system with EvgA
HydaRace	Hydantoin racemase (EC 5.1.99.5)
HydeProtClusWith	HydE protein clustered with electron-bifurcating [FeFe]-hydrogenase (possible two-component regulator histidine kinase)
HydrAbcTranAtpaComp2	Hydroxymethylpyrimidine ABC transporter, ATPase component ThiZ
HydrAbcTranSubsBind2	Hydroxymethylpyrimidine ABC transporter, substrate-binding component ThiY
HydrAbcTranTranComp3	Hydroxymethylpyrimidine ABC transporter, transmembrane component ThiX
HydrAcidCDiamSynt	Hydrogenobyrinic acid a,c-diamide synthase (glutamine-hydrolyzing) (EC 6.3.5.9)
HydrAcpDehy	(3R)-hydroxymyristoyl-[ACP] dehydratase (EC 4.2.1.-)
HydrAcpDehySubuHada	(3R)-hydroxyacyl-ACP dehydratase subunit HadA
HydrAcpDehySubuHadb	(3R)-hydroxyacyl-ACP dehydratase subunit HadB
HydrAcpDehySubuHadc	(3R)-hydroxyacyl-ACP dehydratase subunit HadC
HydrAcylBltbLocu	Hydrolase/acyltransferase in BltB locus
HydrClusWithDuf1n1	Hydrolase (HAD superfamily) in cluster with DUF1447
HydrCoaLyas	Hydroxymethylglutaryl-CoA lyase (EC 4.1.3.4)
HydrCoaRedu	Hydroxymethylglutaryl-CoA reductase (EC 1.1.1.34)
HydrCoaSynt	Hydroxymethylglutaryl-CoA synthase (EC 2.3.3.10)
HydrHaloDehaLike3	hydrolase, haloacid dehalogenase-like family protein BCZK2594
HydrHydr	Hydroxyacylglutathione hydrolase (EC 3.1.2.6)
HydrKina	Hydroxyethylthiazole kinase (EC 2.7.1.50)
HydrKina2	Hydroxymethylpyrimidine kinase (EC 2.7.1.49)
HydrNonOxidDecaProt	Hydroxyaromatic non-oxidative decarboxylase protein D (EC 4.1.1.-)
HydrNonOxidDecaProt2	Hydroxyaromatic non-oxidative decarboxylase protein C (EC 4.1.1.-)
HydrNonOxidDecaProt3	Hydroxyaromatic non-oxidative decarboxylase protein B (EC 4.1.1.-)
HydrPeroInduGene	Hydrogen peroxide-inducible genes activator
HydrPhosKinaThid	Hydroxymethylpyrimidine phosphate kinase ThiD (EC 2.7.4.7)
HydrPhosSyntThic	Hydroxymethylpyrimidine phosphate synthase ThiC (EC 4.1.99.17)
HydrRedu	Hydroxypyruvate reductase (EC 1.1.1.81)
HydrSyntProtThi5n1	Hydroxymethylpyrimidine synthesis protein THI5
HydrYqek	Hydrolase (HAD superfamily), YqeK
HypoAlteHydrPhos	Hypothetical alternative hydroxymethylpyrimidine phosphate kinase ThiD (EC 2.7.4.7)
HypoDistRelaThio	Hypothetical distantly related to thiol:disulfide interchange protein DsbA
HypoDistSimiWith	Hypothetical, distant similarity with heme-degrading oxygenase IsdG
HypoFlavYqca	Hypothetical flavoprotein YqcA (clustered with tRNA pseudouridine synthase C)
HypoGuanPhos	Hypoxanthine-guanine phosphoribosyltransferase (EC 2.4.2.8)
HypoHydrYgez	Hypothetical hydrolase YgeZ (EC 3.-.-.-)
HypoLipoYajgPrec	Hypothetical lipoprotein YajG precursor
HypoMembProtRv21n1	Hypothetical membrane protein Rv2120c
HypoMetaBindEnzy	Hypothetical metal-binding enzyme, YcbL homolog
HypoMw07HomoSupe	Hypothetical MW0753 homolog in superantigen-encoding pathogenicity islands SaPI
HypoMw07HomoSupe2	Hypothetical MW0754 homolog in superantigen-encoding pathogenicity islands SaPI
HypoOxidYqhd	Hypothetical oxidoreductase YqhD (EC 1.1.-.-)
HypoProtAcubNotInvo	Hypothetical protein AcuB, not involved in acetoin utilization
HypoProtAeroUpta	Hypothetical protein in aerobactin uptake cluster
HypoProtAhqBiosOper	Hypothetical protein in AHQ biosynthetic operon
HypoProtAromClus	Hypothetical protein in aromatic cluster
HypoProtAssoWith	Hypothetical protein associated with desferrioxamine E biosynthesis
HypoProtAssoWith3	Hypothetical protein associated with Serine palmitoyltransferase
HypoProtAssoWith4	Hypothetical protein associated with short form of CcmH
HypoProtAssoWith5	Hypothetical protein associated with DUF420, no CDD domain
HypoProtBa28n1	Hypothetical protein BA2833 (in 4-hydroxyproline catabolic gene cluster)
HypoProtBcepComm	hypothetical protein Bcep3774, commonly clustered with carotenoid biosynthesis
HypoProtCbby	Hypothetical protein CbbY
HypoProtCj15n1	Hypothetical protein Cj1505c
HypoProtClusWith	Hypothetical protein in cluster with Ecs transporter (in Streptococci)
HypoProtClusWith12	Hypothetical protein in cluster with penicillin-binding protein PBP1, Staphylococcal type
HypoProtClusWith14	Hypothetical protein in cluster with penicillin-binding protein PBP1, Listerial type
HypoProtClusWith15	Hypothetical protein in cluster with Ecs transporter (in Lactococci)
HypoProtClusWith16	Hypothetical protein in cluster with SinR and SinI
HypoProtClusWith17	hypothetical protein in cluster with VreARI signaling system
HypoProtClusWith3	hypothetical protein clusted with conjugative transposons, BF0131
HypoProtClusWith4	hypothetical protein clustered with lysine fermentation genes
HypoProtClusWith5	Hypothetical protein in cluster with dihydroxyacetone kinase in Rhizobia
HypoProtClusWith6	Hypothetical protein in cluster with HutR, VCA0066 homolog
HypoProtClusWith7	Hypothetical protein in cluster with HutR, VCA0067 homolog
HypoProtClusWith9	Hypothetical protein in cluster with Mesaconyl-CoA hydratase
HypoProtCoOccuWith	Hypothetical protein co-occurring with PspA-like suppressor
HypoProtCoexWith	Hypothertical protein, coexpressed with pyoverdine biosynthesis regulon
HypoProtCog3n1	Hypothetical protein COG3496
HypoProtColoWith	Hypothetical protein colocalized with Enterobactin receptor VctA
HypoProtCytoOxid	Hypotehtical protein in Cytochrome oxidase biogenesis cluster
HypoProtDistRela	Hypothetical protein distantly related to putative heme lyase CcmC
HypoProtDistRela3	Hypothetical protein distantly related to cytochrome C-type biogenesis protein CcdA
HypoProtDuf2n1	Hypothetical protein DUF2999
HypoProtDuf3n1	Hypothetical protein DUF334
HypoProtDuf4n4	Hypothetical protein DUF420
HypoProtFtpbPyoc	Hypothetical protein FtpB in pyochelin gene cluster
HypoProtFtpbSide	Hypothetical protein FtpB in siderophore gene cluster
HypoProtGbaaAsso	Hypothetical protein GBAA1985 associated with anthrachelin biosynthesis, unique
HypoProtGbaaHomo	Hypothetical protein, GBAA2540 homolog
HypoProtGlcgGlyc	Hypothetical protein GlcG in glycolate utilization operon
HypoProtLAspaType	Hypothetical protein of L-Asparaginase type 2-like superfamily
HypoProtLin0Homo	Hypothetical protein, Lin0079 homolog [Bacteriophage A118]
HypoProtLmo2Homo	Hypothetical protein, Lmo2306 homolog [Bacteriophage A118]
HypoProtLmo2Homo2	Hypothetical protein, Lmo2313 homolog [Bacteriophage A118]
HypoProtLmo2Homo3	Hypothetical protein, Lmo2276 homolog
HypoProtLmo2Homo4	Hypothetical protein, Lmo2305 homolog [Bacteriophage A118]
HypoProtLmo2Homo5	Hypothetical protein, Lmo2307 homolog [Bacteriophage A118]
HypoProtPa13n1	Hypothetical protein PA1329
HypoProtPa30n1	hypothetical protein PA3071
HypoProtPhiEtaOrf1n1	Hypothetical protein, phi-ETA orf16 homolog [SA bacteriophages 11, Mu50B]
HypoProtPhiEtaOrf1n2	Hypothetical protein, phi-ETA orf17 homolog [SA bacteriophages 11, Mu50B]
HypoProtPhiEtaOrf2n1	Hypothetical protein, phi-ETA orf24 homolog [SA bacteriophages 11, Mu50B]
HypoProtPhiEtaOrf3n1	Hypothetical protein, phi-ETA orf33 homolog [SA bacteriophages 11, Mu50B]
HypoProtPhiEtaOrf4n1	Hypothetical protein, phi-ETA orf42 homolog [SA bacteriophages 11, Mu50B]
HypoProtPhiEtaOrf5n1	Hypothetical protein, phi-ETA orf58 homolog [SA bacteriophages 11, Mu50B]
HypoProtPhiEtaOrf5n2	Hypothetical protein, phi-ETA orf55 homolog [SA bacteriophages 11, Mu50B]
HypoProtPhiEtaOrf6n1	Hypothetical protein, phi-ETA orf63 homolog [SA bacteriophages 11, Mu50B]
HypoProtPredPoly	Hypothetical protein in predicted poly-gamma-glutamate synthase operon
HypoProtPv83Orf1n1	Hypothetical protein, PV83 orf19 homolog [SA bacteriophages 11, Mu50B]
HypoProtPv83Orf1n2	Hypothetical protein, PV83 orf12 homolog [SA bacteriophages 11, Mu50B]
HypoProtPv83Orf1n3	Hypothetical protein, PV83 orf10 homolog [SA bacteriophages 11, Mu50B]
HypoProtPv83Orf20n1	Hypothetical protein, PV83 orf 20 homolog [SA bacteriophages 11, Mu50B]
HypoProtPv83Orf2n1	Hypothetical protein, PV83 orf22 homolog [SA bacteriophages 11, Mu50B]
HypoProtPv83Orf2n2	Hypothetical protein, PV83 orf23 homolog [SA bacteriophages 11, Mu50B]
HypoProtPv83Orf3n1	Hypothetical protein, PV83 orf3 homolog [SA bacteriophages 11, Mu50B]
HypoProtPv83Orf4n1	Hypothetical protein, PV83 orf4 homolog [SA bacteriophages 11, Mu50B]
HypoProtPvdx	Hypothetical protein PvdX
HypoProtPvdy	Hypothetical protein PvdY
HypoProtPvlOrf3Homo	Hypothetical protein, PVL orf39 homolog [SA bacteriophages 11, Mu50B]
HypoProtPvlOrf5Homo	Hypothetical protein, PVL orf50 homolog [SA bacteriophages 11, Mu50B]
HypoProtPvlOrf5Homo2	Hypothetical protein, PVL orf51 homolog [SA bacteriophages 11, Mu50B]
HypoProtPvlOrf5Homo3	Hypothetical protein, PVL orf52 homolog [SA bacteriophages 11, Mu50B]
HypoProtPyovGene2	Hypothetical protein in pyoverdin gene cluster
HypoProtRv00n2	hypothetical protein Rv0098
HypoProtRv36Comp	Hypothetical protein Rv3612c, component of Type VII secretion system ESX-1
HypoProtRv36Comp2	Hypothetical protein Rv3613c, component of Type VII secretion system ESX-1
HypoProtSaBact11n1	Hypothetical protein [SA bacteriophages 11, Mu50B]
HypoProtSab1Homo	Hypothetical protein, SAB1742c homolog [SA bacteriophages 11, Mu50B]
HypoProtSab1Homo2	Hypothetical protein, SAB1734c homolog [SA bacteriophages 11, Mu50B]
HypoProtSav0Homo	Hypothetical protein, SAV0849 homolog [SA bacteriophages 11, Mu50B]
HypoProtSav0Homo2	Hypothetical protein, SAV0860 homolog [SA bacteriophages 11, Mu50B]
HypoProtSav0Homo3	Hypothetical protein, SAV0877 homolog [SA bacteriophages 11, Mu50B]
HypoProtSav0Homo4	Hypothetical protein, SAV0878 homolog [SA bacteriophages 11, Mu50B]
HypoProtSav0Homo5	Hypothetical protein, SAV0879 homolog [SA bacteriophages 11, Mu50B]
HypoProtSav0Homo6	Hypothetical protein, SAV0880 homolog [SA bacteriophages 11, Mu50B]
HypoProtSav0Homo7	Hypothetical protein, SAV0881 homolog [SA bacteriophages 11, Mu50B]
HypoProtSav0Homo8	Hypothetical protein, SAV0852 homolog [SA bacteriophages 11, Mu50B]
HypoProtSav0Homo9	Hypothetical protein, SAV0876 homolog [SA bacteriophages 11, Mu50B]
HypoProtSav1n3	Hypothetical protein SAV1839
HypoProtSav2n14	Hypothetical protein SAV2173
HypoProtSimiWith	Hypothetical protein, similarity with fibrinogen-binding protein Efb
HypoProtSimiWith2	Hypothetical protein, similarity with von Willebrand factor-binding VWbp
HypoProtSlr0Homo	Hypothetical protein, Slr0957 homolog
HypoProtSltOrf8Homo	Hypothetical protein, SLT orf81b homolog [SA bacteriophages 11, Mu50B]
HypoProtSltOrf9Homo	Hypothetical protein, SLT orf99 homolog [SA bacteriophages 11, Mu50B]
HypoProtSpy1Homo	Hypothetical protein, Spy1939 homolog
HypoProtSpym2	Hypothetical protein spyM18_0155
HypoProtSsl1n1	hypothetical protein ssl1918
HypoProtSulfDoma	Hypothetical protein, sulfurtransferase domain
HypoProtTdcfClus	Hypothetical protein TdcF in cluster with anaerobic degradation of L-threonine to propionate
HypoProtThatOfte	hypothetical protein that often co-occurs with aconitase
HypoProtTherIron	hypothetical protein in Thermus iron scavenging cluster
HypoProtTm17n1	hypothetical protein TM1757
HypoProtVc02n1	Hypothetical protein VC0266 (sugar utilization related?)
HypoProtWithDist	Hypothetical protein with distant similarity to Ribonuclease E inhibitor RraA (former MenG)
HypoProtYaejWith	Hypothetical protein YaeJ with similarity to translation release factor
HypoProtYagq	Hypothetical protein YagQ
HypoProtYdjy	Hypothetical protein YdjY
HypoProtYhfz	Hypothetical protein YhfZ
HypoProtYnja	Hypothetical protein YnjA
HypoRadiSamFamiEnzy	Hypothetical radical SAM family enzyme, NOT coproporphyrinogen III oxidase, oxygen-independent
HypoRadiSamFamiEnzy3	Hypothetical radical SAM family enzyme in heat shock gene cluster, similarity with CPO of BS HemN-type
HypoRelaBroaSpec	Hypothetical, related to broad specificity phosphatases COG0406
HypoSar0HomoSupe	Hypothetical SAR0371 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSar0HomoSupe2	Hypothetical SAR0365 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSar0HomoSupe3	Hypothetical SAR0369 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSar0HomoSupe4	Hypothetical SAR0372 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSar0HomoSupe5	Hypothetical SAR0385 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoNear	Hypothetical SAV0808 homolog, near pathogenicity islands SaPI att-site
HypoSav0HomoSupe	Hypothetical SAV0801 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe10	Hypothetical SAV0788 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe11	Hypothetical SAV0787 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe12	Hypothetical SAV0799 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe13	Hypothetical SAV0786 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe14	Hypothetical SAV0791 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe15	Hypothetical SAV0793 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe2	Hypothetical SAV0792 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe3	Hypothetical SAV0798 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe4	Hypothetical SAV0797 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe5	Hypothetical SAV0796 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe6	Hypothetical SAV0795 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe7	Hypothetical SAV0794 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe8	Hypothetical SAV0790 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav0HomoSupe9	Hypothetical SAV0789 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav2HomoSupe	Hypothetical SAV2027 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSav2HomoSupe2	Hypothetical SAV2026 homolog in superantigen-encoding pathogenicity islands SaPI
HypoSimiCcmcPuta	Hypothetical similar to CcmC, putative heme lyase for CcmE
HypoSimiHemeLyas	Hypothetical similar to heme lyase subunit CcmH, colocalized with sarcosine oxidase
HypoSimiSarcOxid	Hypothetical, similar to sarcosine oxidase alpha subunit, 2Fe-2S domain
HypoTranPdutForVari	hypothetical transporter PduT for various metalloporphyrins
HypoTranProtCoup	Hypothetical transmembrane protein coupled to NADH-ubiquinone oxidoreductase chain 5 homolog
HypoTranReguYqhc	Hypothetical transcriptional regulator YqhC
HypoWithReguPDoma	Hypothetical with regulatory P domain of a subtilisin-like proprotein convertase
HypoWithSimiBche	Hypothetical with similarity to BchE, but NOT Mg-protoporphyrin monomethyl ester cyclase (anaerobic)
HypoYcioProtTsac	Hypothetical YciO protein, TsaC/YrdC paralog
HypoZincTypeAlco	Hypothetical zinc-type alcohol dehydrogenase-like protein YdjJ
IgaSpecMeta	IgA-specific metalloendopeptidase (EC 3.4.24.13)
IgaaMembProtThat	IgaA: a membrane protein that prevents overactivation of the Rcs regulatory system
IggBindProtSbi	IgG-binding protein SBI
Imid	Imidazolonepropionase (EC 3.5.2.7)
ImidGlycPhosSynt	Imidazole glycerol phosphate synthase cyclase subunit (EC 4.1.3.-)
ImidGlycPhosSynt2	Imidazole glycerol phosphate synthase amidotransferase subunit (EC 2.4.2.-)
ImidPhosDehy	Imidazoleglycerol-phosphate dehydratase (EC 4.2.1.19)
ImmuInhiMeta	Immune inhibitor A, metalloprotease (EC 3.4.24.-)
ImmuProtPlniMemb	immunity protein PlnI, membrane-bound protease CAAX family
ImmuProtPlnl	immunity protein PlnL
ImmuProtPlnm	immunity protein PlnM
ImmuProtPlnpMemb	Immunity protein PlnP, membrane-bound protease CAAX family
ImmuProtSdpi	Immunity protein SdpI
ImpCycl	IMP cyclohydrolase (EC 3.5.4.10)
ImpCyclAlteForm	IMP cyclohydrolase [alternate form] (EC 3.5.4.10)
InacBactTypeProl	Inactive bacterial type prolyl-tRNA synthetase
InacPpgp3PyroDoma	Inactive (p)ppGpp 3'-pyrophosphohydrolase domain
IncfPlasConjTran	IncF plasmid conjugative transfer protein TraG
IncfPlasConjTran10	IncF plasmid conjugative transfer pilus assembly protein TraK
IncfPlasConjTran11	IncF plasmid conjugative transfer pilus assembly protein TraE
IncfPlasConjTran12	IncF plasmid conjugative transfer pilus assembly protein TraL
IncfPlasConjTran13	IncF plasmid conjugative transfer pilus assembly protein TraB
IncfPlasConjTran14	IncF plasmid conjugative transfer surface exclusion protein TraT
IncfPlasConjTran15	IncF plasmid conjugative transfer protein TrbB
IncfPlasConjTran16	IncF plasmid conjugative transfer DNA-nicking and unwinding protein TraI
IncfPlasConjTran17	IncF plasmid conjugative transfer pilin protein TraA
IncfPlasConjTran18	IncF plasmid conjugative transfer pilus assembly protein TraV
IncfPlasConjTran19	IncF plasmid conjugative transfer protein TrbI
IncfPlasConjTran2	IncF plasmid conjugative transfer pilus assembly protein TraH
IncfPlasConjTran20	IncF plasmid conjugative transfer mating signal transduction protein TraM
IncfPlasConjTran21	IncF plasmid conjugative transfer protein TrbE
IncfPlasConjTran22	IncF plasmid conjugative transfer protein TraQ
IncfPlasConjTran23	IncF plasmid conjugative transfer pilin acetylase TraX
IncfPlasConjTran24	IncF plasmid conjugative transfer fertility inhibition protein FinO
IncfPlasConjTran25	IncF plasmid conjugative transfer regulator TraJ
IncfPlasConjTran26	IncF plasmid conjugative transfer protein TraP
IncfPlasConjTran27	IncF plasmid conjugative transfer protein TraR
IncfPlasConjTran28	IncF plasmid conjugative transfer protein TrbD
IncfPlasConjTran29	IncF plasmid conjugative transfer regulator TraY
IncfPlasConjTran3	IncF plasmid conjugative transfer pilus assembly protein TraF
IncfPlasConjTran30	IncF plasmid conjugative transfer surface exclusion protein TraS
IncfPlasConjTran31	IncF plasmid conjugative transfer protein TrbA
IncfPlasConjTran32	IncF plasmid conjugative transfer protein TrbF
IncfPlasConjTran33	IncF plasmid conjugative transfer protein TrbG
IncfPlasConjTran34	IncF plasmid conjugative transfer protein TrbH
IncfPlasConjTran35	IncF plasmid conjugative transfer protein TrbJ
IncfPlasConjTran4	IncF plasmid conjugative transfer protein TraD
IncfPlasConjTran5	IncF plasmid conjugative transfer pilus assembly protein TraC
IncfPlasConjTran6	IncF plasmid conjugative transfer pilus assembly protein TraW
IncfPlasConjTran7	IncF plasmid conjugative transfer pilus assembly protein TraU
IncfPlasConjTran8	IncF plasmid conjugative transfer protein TrbC
IncfPlasConjTran9	IncF plasmid conjugative transfer protein TraN
InciPlasConjTran	IncI1 plasmid conjugative transfer integral membrane protein TraY
InciPlasConjTran10	IncI1 plasmid conjugative transfer protein TraW
InciPlasConjTran11	IncI1 plasmid conjugative transfer protein TraN
InciPlasConjTran12	IncI1 plasmid conjugative transfer protein TraQ
InciPlasConjTran13	IncI1 plasmid conjugative transfer protein TraU
InciPlasConjTran14	IncI1 plasmid conjugative transfer protein TraJ, related to pilus biogenesis/retracton protein
InciPlasConjTran15	IncI1 plasmid conjugative transfer protein TraI
InciPlasConjTran16	IncI1 plasmid conjugative transfer protein TraX
InciPlasConjTran17	IncI1 plasmid conjugative transfer protein TraT
InciPlasConjTran18	IncI1 plasmid conjugative transfer protein TraS
InciPlasConjTran19	IncI1 plasmid conjugative transfer protein TraR
InciPlasConjTran2	IncI1 plasmid conjugative transfer protein PilL
InciPlasConjTran20	IncI1 plasmid conjugative transfer protein TraP
InciPlasConjTran21	IncI1 plasmid conjugative transfer protein TraO
InciPlasConjTran22	IncI1 plasmid conjugative transfer protein TraM
InciPlasConjTran23	IncI1 plasmid conjugative transfer protein TraL
InciPlasConjTran24	IncI1 plasmid conjugative transfer DNA primase
InciPlasConjTran25	IncI1 plasmid conjugative transfer protein TraH
InciPlasConjTran26	IncI1 plasmid conjugative transfer protein TraE
InciPlasConjTran27	IncI1 plasmid conjugative transfer protein TraA
InciPlasConjTran28	IncI1 plasmid conjugative transfer NusG-type transcription antiterminator TraB
InciPlasConjTran29	IncI1 plasmid conjugative transfer protein TraC
InciPlasConjTran3	IncI1 plasmid conjugative transfer lipoprotein PilN
InciPlasConjTran30	IncI1 plasmid conjugative transfer protein PilK
InciPlasConjTran31	IncI1 plasmid conjugative transfer protein PilM
InciPlasConjTran32	IncI1 plasmid conjugative transfer protein TraK
InciPlasConjTran33	IncI1 plasmid conjugative transfer protein PilI
InciPlasConjTran34	IncI1 plasmid conjugative transfer protein PilJ
InciPlasConjTran35	IncI1 plasmid conjugative transfer protein TraG
InciPlasConjTran36	IncI1 plasmid conjugative transfer protein TraV
InciPlasConjTran4	IncI1 plasmid conjugative transfer ATPase PilQ
InciPlasConjTran5	IncI1 plasmid conjugative transfer inner membrane protein PilR
InciPlasConjTran6	IncI1 plasmid conjugative transfer prepilin PilS
InciPlasConjTran7	IncI1 plasmid conjugative transfer putative membrane protein PilT
InciPlasConjTran8	IncI1 plasmid conjugative transfer pilus-tip adhesin protein PilV
InciPlasConjTran9	IncI1 plasmid conjugative transfer protein TraF
InciPlasPiluAsse	IncI1 plasmid pilus assembly protein PilP
InciPlasPiluAsse2	IncI1 plasmid pilus assembly protein PilO
InclMembProt10n1	Inclusion membrane protein-10
InclMembProt11n1	Inclusion membrane protein-11
InclMembProt12n1	Inclusion membrane protein-12
InclMembProt13n1	Inclusion membrane protein-13
InclMembProt14n1	Inclusion membrane protein-14
InclMembProt15n1	Inclusion membrane protein-15
InclMembProt16n1	Inclusion membrane protein-16
InclMembProt17n1	Inclusion membrane protein-17
InclMembProt18n1	Inclusion membrane protein-18
InclMembProt19n1	Inclusion membrane protein-19
InclMembProt1n1	Inclusion membrane protein-1
InclMembProt20n1	Inclusion membrane protein-20
InclMembProt21n1	Inclusion membrane protein-21
InclMembProt22n1	Inclusion membrane protein-22
InclMembProt23n1	Inclusion membrane protein-23
InclMembProt24n1	Inclusion membrane protein-24
InclMembProt25n1	Inclusion membrane protein-25
InclMembProt26n1	Inclusion membrane protein-26
InclMembProt27n1	Inclusion membrane protein-27
InclMembProt28n1	Inclusion membrane protein-28
InclMembProt29n1	Inclusion membrane protein-29
InclMembProt2n1	Inclusion membrane protein-2
InclMembProt30n1	Inclusion membrane protein-30
InclMembProt31n1	Inclusion membrane protein-31
InclMembProt32n1	Inclusion membrane protein-32
InclMembProt33n1	Inclusion membrane protein-33
InclMembProt34n1	Inclusion membrane protein-34
InclMembProt35n1	Inclusion membrane protein-35
InclMembProt36n1	Inclusion membrane protein-36
InclMembProt37n1	Inclusion membrane protein-37
InclMembProt38n1	Inclusion membrane protein-38
InclMembProt39n1	Inclusion membrane protein-39
InclMembProt3n1	Inclusion membrane protein-3
InclMembProt40n1	Inclusion membrane protein-40
InclMembProt41n1	Inclusion membrane protein-41
InclMembProt42n1	Inclusion membrane protein-42
InclMembProt43n1	Inclusion membrane protein-43
InclMembProt44n1	Inclusion membrane protein-44
InclMembProt45n1	Inclusion membrane protein-45
InclMembProt46n1	Inclusion membrane protein-46
InclMembProt47n1	Inclusion membrane protein-47
InclMembProt48n1	Inclusion membrane protein-48
InclMembProt49n1	Inclusion membrane protein-49
InclMembProt4n1	Inclusion membrane protein-4
InclMembProt50n1	Inclusion membrane protein-50
InclMembProt51n1	Inclusion membrane protein-51
InclMembProt52n1	Inclusion membrane protein-52
InclMembProt53n1	Inclusion membrane protein-53
InclMembProt54n1	Inclusion membrane protein-54
InclMembProt55n1	Inclusion membrane protein-55
InclMembProt56n1	Inclusion membrane protein-56
InclMembProt57n1	Inclusion membrane protein-57
InclMembProt58n1	Inclusion membrane protein-58
InclMembProt59n1	Inclusion membrane protein-59
InclMembProt5n1	Inclusion membrane protein-5
InclMembProt60n1	Inclusion membrane protein-60
InclMembProt61n1	Inclusion membrane protein-61
InclMembProt62n1	Inclusion membrane protein-62
InclMembProt63n1	Inclusion membrane protein-63
InclMembProt64n1	Inclusion membrane protein-64
InclMembProt65n1	Inclusion membrane protein-65
InclMembProt66n1	Inclusion membrane protein-66
InclMembProt67n1	Inclusion membrane protein-67
InclMembProt68n1	Inclusion membrane protein-68
InclMembProt69n1	Inclusion membrane protein-69
InclMembProt6n1	Inclusion membrane protein-6
InclMembProt70n1	Inclusion membrane protein-70
InclMembProt71n1	Inclusion membrane protein-71
InclMembProt72n1	Inclusion membrane protein-72
InclMembProt73n1	Inclusion membrane protein-73
InclMembProt7n1	Inclusion membrane protein-7
InclMembProt8n1	Inclusion membrane protein-8
InclMembProt9n1	Inclusion membrane protein-9
IncnPlasKikaProt	IncN plasmid KikA protein
IncqPlasConjTran	IncQ plasmid conjugative transfer protein TraG
IncqPlasConjTran2	IncQ plasmid conjugative transfer DNA nicking endonuclease TraR (pTi VirD2 homolog)
IncqPlasConjTran3	IncQ plasmid conjugative transfer protein TraQ (RP4 TrbM homolog)
IncqPlasConjTran4	IncQ plasmid conjugative transfer protein TraP
IncqPlasConjTran5	IncQ plasmid conjugative transfer DNA primase TraO (pTi TraA homolog)
IncqPlasConjTran6	IncQ plasmid conjugative transfer protein TraB
IncwPlasConjProt	IncW plasmid conjugative protein TrwB (TraD homolog)
IncwPlasConjRela	IncW plasmid conjugative relaxase protein TrwC (TraI homolog)
Indo23Diox	Indoleamine 2,3-dioxygenase (EC 1.13.11.52)
Indo3GlycPhosSynt	Indole-3-glycerol phosphate synthase (EC 4.1.1.48)
IndoFerrOxidAlph	Indolepyruvate ferredoxin oxidoreductase, alpha and beta subunits
IndoFerrOxidAlph2	Indolepyruvate ferredoxin oxidoreductase, alpha and beta subunits like
IndoHydr	Indoleacetamide hydrolase (EC 3.5.1.-)
IndoOxidSubuIora	Indolepyruvate oxidoreductase subunit IorA (EC 1.2.7.8)
IndoOxidSubuIora2	Indolepyruvate oxidoreductase subunit IorA-like (EC 1.2.7.8)
IndoOxidSubuIorb	Indolepyruvate oxidoreductase subunit IorB (EC 1.2.7.8)
IndoOxidSubuIorb2	Indolepyruvate oxidoreductase subunit IorB II (EC 1.2.7.8)
IndoPren	Indole prenyltransferase (EC 2.5.1.-)
InhiProSigmProcBofa	Inhibitor of pro-sigmaK processing BofA
InneMembCompTamTran	Inner membrane component of TAM transport system
InneMembCompTrip	Inner membrane component of tripartite multidrug resistance system
InneMembPentCType	inner membrane pentaheme c-type cytochrome, TorC
InneMembPermForFerr	Inner-membrane permease for ferric siderophore
InneMembPermFptx	Inner-membrane permease FptX, ferripyochelin
InneMembPermYgji	Inner membrane permease YgjI, clustered with evolved beta-galactosidase
InneMembProtCred	Inner membrane protein CreD
InneMembProtDrug	Inner-membrane proton/drug antiporter (MSF type) of tripartite multidrug efflux system
InneMembProtForm	Inner membrane protein forms channel for type IV secretion of T-DNA complex, VirB3
InneMembProtForm2	Inner membrane protein forms channel for type IV secretion of T-DNA complex, VirB8
InneMembProtTran	Inner membrane protein translocase component YidC, long form
InneMembProtTran2	Inner membrane protein translocase component YidC, short form OxaI-like
InneMembProtTran3	Inner membrane protein translocase component YidC, OxaA protein
InneMembProtType	Inner membrane protein of type IV secretion of T-DNA complex, VirB6
InneMembProtType2	Inner membrane protein of type IV secretion of T-DNA complex, TonB-like, VirB10
InneMembProtType3	Inner membrane protein of type IV secretion of T-DNA complex, VirB3
InneMembProtType4	Inner membrane protein of type IV secretion of T-DNA complex, VirB8
InneMembProtYban	Inner membrane protein YbaN
InneMembProtYfez	Inner membrane protein YfeZ
InneMembProtYghq	Inner membrane protein YghQ, probably involved in polysaccharide biosynthesis
InneMembProtYihy	Inner membrane protein YihY, formerly thought to be RNase BN
InneMembProtYjch	Inner membrane protein YjcH, clustering with ActP
InneMembProtYrbg	Inner membrane protein YrbG, predicted calcium/sodium:proton antiporter
InneMembThioDisu	Inner membrane thiol:disulfide oxidoreductase, DsbB-like
Inos1Mono	Inositol-1-monophosphatase (EC 3.1.3.25)
Inos1PhosSynt	Inositol-1-phosphate synthase (EC 5.5.1.4)
Inos5MonoDehy	Inosine-5'-monophosphate dehydrogenase (EC 1.1.1.205)
Inos5MonoDehyCata	Inosine-5'-monophosphate dehydrogenase, catalytic domain (EC 1.1.1.205)
InosDehy	Inosose dehydratase (EC 4.2.1.44)
InosIsom	Inosose isomerase (EC 5.3.99.11)
InosOxyg	Inositol oxygenase (EC 1.13.99.1)
InosTranSystAtpBind	Inositol transport system ATP-binding protein
InosTranSystPerm	Inositol transport system permease protein
InosTranSystSuga	Inositol transport system sugar-binding protein
InosUridPrefNucl	Inosine-uridine preferring nucleoside hydrolase (EC 3.2.2.1)
InosUridPrefNucl3	Inosine-uridine preferring nucleoside hydrolase in exosporium (EC 3.2.2.1)
InosXantTrip	Inosine/xanthosine triphosphatase (EC 3.6.1.-)
Inte3	Internalin A (LPXTG motif)
InteB	Internalin B (GW modules)
InteBactA118n1	Integrase [Bacteriophage A118]
InteC	Internalin C
InteC2n1	Internalin C2 (LPXTG motif)
InteCont	intein-containing
InteD2	Internalin D (LPXTG motif)
InteE	Internalin E (LPXTG motif)
InteG	Internalin G (LPXTG motif)
InteH	Internalin H (LPXTG motif)
InteHostFactBeta	integration host factor beta subunit
InteInte	Integron integrase
InteInteInti	Integron integrase IntIPac
InteInteInti2	integron integrase IntI4
InteInteInti3	Integron integrase IntI2
InteInteInti4	Integron integrase IntI1
InteLikeProtLin0n1	Internalin-like protein (LPXTG motif) Lin0372 homolog
InteLikeProtLin0n2	Internalin-like protein (LPXTG motif) Lin0661 homolog
InteLikeProtLin0n3	Internalin-like protein (LPXTG motif) Lin0290 homolog
InteLikeProtLin0n4	Internalin-like protein Lin0295 homolog
InteLikeProtLin0n5	Internalin-like protein (LPXTG motif) Lin0739 homolog
InteLikeProtLin0n6	Internalin-like protein (LPXTG motif) Lin0740 homolog
InteLikeProtLin1n1	Internalin-like protein (LPXTG motif) Lin1204 homolog
InteLikeProtLin2n1	Internalin-like protein Lin2537 homolog
InteLikeProtLmo0n1	Internalin-like protein (LPXTG motif) Lmo0331 homolog
InteLikeProtLmo0n10	Internalin-like protein (LPXTG motif) Lmo0732 homolog
InteLikeProtLmo0n11	Internalin-like protein (LPXTG motif) Lmo0327 homolog / murein-hydrolysing domain
InteLikeProtLmo0n2	Internalin-like protein (LPXTG motif) Lmo0333 homolog
InteLikeProtLmo0n3	Internalin-like protein (LPXTG motif) Lmo0409 homolog
InteLikeProtLmo0n4	Internalin-like protein (LPXTG motif) Lmo0801 homolog
InteLikeProtLmo0n5	Internalin-like protein (LPXTG motif) Lmo0514 homolog
InteLikeProtLmo0n6	Internalin-like protein (LPXTG motif) Lmo0171 homolog
InteLikeProtLmo0n7	Internalin-like protein (LPXTG motif) Lmo0327 homolog
InteLikeProtLmo0n8	Internalin-like protein Lmo0549 homolog
InteLikeProtLmo0n9	Internalin-like protein (LPXTG motif) Lmo0610 homolog
InteLikeProtLmo1n1	Internalin-like protein (LPXTG motif) Lmo1136 homolog
InteLikeProtLmo1n2	Internalin-like protein (LPXTG motif) Lmo1289 homolog
InteLikeProtLmo1n3	Internalin-like protein (LPXTG motif) Lmo1290 homolog
InteLikeProtLmo2n1	Internalin-like protein (LPXTG motif) Lmo2026 homolog
InteLikeProtLmo2n2	Internalin-like protein (LPXTG motif) Lmo2821 homolog
InteLikeProtLmo2n3	Internalin-like protein (LPXTG motif) Lmo2396 homolog
InteLikeProtLmo2n4	Internalin-like protein Lmo2027 homolog
InteLikeProtLmo2n5	Internalin-like protein Lmo2445 homolog
InteLikeProtLmo2n6	Internalin-like protein Lmo2470 homolog
InteLikeProtLmof	Internalin-like protein (LPXTG motif) Lmof0365 homolog
InteMembIndoArab	Integral membrane indolylacetylinositol arabinosyltransferase EmbA (EC 2.4.2.-)
InteMembIndoArab2	Integral membrane indolylacetylinositol arabinosyltransferase EmbB (EC 2.4.2.-)
InteMembIndoArab3	Integral membrane indolylacetylinositol arabinosyltransferase EmbC (EC 2.4.2.-)
InteMembIndoArab5	Integral membrane indolylacetylinositol arabinosyltransferase (EC 2.4.2.-)
InteMembProtDvu_	Integral membrane protein DVU_0532
InteMembProtDvu_2	Integral membrane protein DVU_0533
InteMembProtDvu_3	Integral membrane protein DVU_0534
InteMembProtEccd	Integral membrane protein EccD-like, component of Type VII secretion system in Actinobacteria
InteMembProtEccd2	Integral membrane protein EccD4, component of Type VII secretion system ESX-4
InteMembProtEccd3	Integral membrane protein EccD3, component of Type VII secretion system ESX-3
InteMembProtEccd4	Integral membrane protein EccD1, component of Type VII secretion system ESX-1
InteMembProtEccd5	Integral membrane protein EccD5, component of Type VII secretion system ESX-5
InteMembProtEccd6	Integral membrane protein EccD2, component of Type VII secretion system ESX-2
InteMembProtEccd7	Integral membrane protein EccD1, component of Type VII secretion system in Actinobacteria
InteMembProtPlnt	integral membrane protein PlnT, membrane-bound protease CAAX family
InteMembProtPlnu	integral membrane protein PlnU, membrane-bound protease CAAX family
InteMembProtPlnv	integral membrane protein plnV, membrane-bound protease CAAX family
InteMembProtPlnw	integral membrane protein PlnW, membrane-bound protease CAAX family
InteMembProtThey	Integral membrane protein THEYE_A1282
InteMembQuinOxid	integral membrane quinol-oxidizing protein, NrfC
IntePuta	internalin, putative (LPXTG motif)
IntePuta2	internalin, putative
InteReguR	Integrase regulator R
InteReguRinaSaBact	Integrase regulator RinA [SA bacteriophages 11, Mu50B]
InteReguRinbSaBact	Integrase regulator RinB [SA bacteriophages 11, Mu50B]
InteSaBact11Mu50n1	Integrase [SA bacteriophages 11, Mu50B]
InteSupeEncoPath	Integrase, superantigen-encoding pathogenicity islands SaPI
IntrAlphAmyl	Intracellular alpha-amylase (EC 3.2.1.1)
InvaProtIagbPrec	Invasion protein IagB precursor
InvaProtInva	Invasion protein InvA
InvaProtInvhPrec	Invasion protein invH precursor
IronAqui23DihyAmp	iron aquisition 2,3-dihydroxybenzoate-AMP ligase (EC 2.7.7.58,Irp5)
IronAquiOuteYers	iron aquisition outermembrane yersiniabactin receptor (FyuA,Psn,pesticin receptor)
IronAquiRegu	iron aquisition regulator (YbtA,AraC-like,required for transcription of FyuA/psn,Irp2)
IronAquiYersSynt	iron aquisition yersiniabactin synthesis enzyme (Irp2)
IronAquiYersSynt2	iron aquisition yersiniabactin synthesis enzyme (Irp1,polyketide synthetase)
IronAquiYersSynt3	Iron aquisition yersiniabactin synthesis enzyme YbtT
IronBindProtIsca	Iron binding protein IscA for iron-sulfur cluster assembly
IronBindProtSufa	Iron binding protein SufA for iron-sulfur cluster assembly
IronChelUtilProt	iron-chelator utilization protein
IronCompAbcUptaTran	Iron compound ABC uptake transporter permease protein
IronCompAbcUptaTran10	Iron compound ABC uptake transporter permease protein PiaB
IronCompAbcUptaTran11	Iron compound ABC uptake transporter permease protein PiaC
IronCompAbcUptaTran2	Iron compound ABC uptake transporter substrate-binding protein
IronCompAbcUptaTran3	Iron compound ABC uptake transporter ATP-binding protein
IronCompAbcUptaTran4	Iron compound ABC uptake transporter substrate-binding protein PiuA
IronCompAbcUptaTran5	Iron compound ABC uptake transporter ATP-binding protein PiaD
IronCompAbcUptaTran6	Iron compound ABC uptake transporter permease protein PiuC
IronCompAbcUptaTran7	Iron compound ABC uptake transporter permease protein PiuB
IronCompAbcUptaTran8	Iron compound ABC uptake transporter ATP-binding protein PiuD
IronCompAbcUptaTran9	Iron compound ABC uptake transporter substrate-binding protein PiaA
IronDepeOxidEgtb	Iron(II)-dependent oxidoreductase EgtB (hercynine sythase)
IronDepeReprIder	Iron-dependent repressor IdeR/DtxR
IronDiciTranAtpBind	Iron(III) dicitrate transport ATP-binding protein FecE (TC 3.A.1.14.1)
IronDiciTranProt	Iron(III) dicitrate transport protein FecA
IronDiciTranSens	Iron(III) dicitrate transmembrane sensor protein FecR
IronDiciTranSyst	Iron(III) dicitrate transport system permease protein FecD (TC 3.A.1.14.1)
IronDiciTranSyst2	Iron(III) dicitrate transport system permease protein FecC (TC 3.A.1.14.1)
IronDiciTranSyst3	Iron(III) dicitrate transport system, periplasmic iron-binding protein FecB (TC 3.A.1.14.1)
IronReguViruRegu	Iron-regulated virulence regulatory protein irgB
IronSideAlcaLike	Iron-siderophore [Alcaligin-like] transport system, substrate-binding component
IronSideAlcaLike2	Iron-siderophore [Alcaligin-like] transport system, permease component
IronSideAlcaLike3	Iron-siderophore [Alcaligin-like] transport system, transmembran component
IronSideAlcaLike4	Iron-siderophore [Alcaligin-like] ferric reductase (1.6.99.14)
IronSideAlcaLike5	Iron-siderophore [Alcaligin-like] transport system, ATP-binding component
IronSideAlcaLike6	Iron-siderophore [Alcaligin-like] receptor
IronSideAlcaRece	Iron-siderophore [Alcaligin] receptor
IronSideReceProt	Iron siderophore receptor protein
IronSideSensProt	Iron siderophore sensor protein
IronSideTranSyst	Iron-siderophore transport system, substrate-binding component
IronSideTranSyst2	Iron-siderophore transport system, permease component
IronSideTranSyst3	Iron-siderophore transport system, transmembran component
IronSideTranSyst4	Iron-siderophore transport system, ATP-binding component
IronSulfClusAsse	Iron-sulfur cluster assembly scaffold protein IscU
IronSulfClusAsse2	Iron-sulfur cluster assembly ATPase protein SufC
IronSulfClusAsse3	Iron-sulfur cluster assembly protein SufD
IronSulfClusAsse4	Iron-sulfur cluster assembly protein SufB
IronSulfClusAsse5	Iron-sulfur cluster assembly scaffold protein IscU/NifU-like
IronSulfClusAsse7	Iron-sulfur cluster assembly scaffold protein NifU
IronSulfClusAsse8	Iron-sulfur cluster assembly scaffold protein IscU/NifU-like for SUF system, SufE3
IronSulfClusRegu	Iron-sulfur cluster regulator IscR
IronSulfClusRegu2	Iron-sulfur cluster regulator SufR
IronSulfProtClus	Iron-sulfur protein clustered with CO dehydrogenase/acetyl-CoA synthase
IronSulfProtSide	Iron-sulfur protein in siderophore [Alcaligin] cluster
IsoaAmin	Isoaspartyl aminopeptidase (EC 3.4.19.5)
IsocBaciSide	Isochorismatase [bacillibactin] siderophore (EC 3.3.2.1)
IsocBrucSide	Isochorismatase [brucebactin] siderophore (EC 3.3.2.1)
IsocDehyNad	Isocitrate dehydrogenase [NAD] (EC 1.1.1.41)
IsocDehyNadp	Isocitrate dehydrogenase [NADP] (EC 1.1.1.42)
IsocDehyPhosKina	Isocitrate dehydrogenase phosphatase /kinase (EC 3.1.3.-) (EC 2.7.11.5)
IsocEnteSide	Isochorismatase [enterobactin] siderophore (EC 3.3.2.1)
IsocLyas	Isocitrate lyase (EC 4.1.3.1)
IsocLyasGrouIiiMyco	Isocitrate lyase, group III, Mycobacterial type ICL2 (EC 4.1.3.1)
IsocPyruLyasEnan	Isochorismate pyruvate-lyase [enantio-pyochelin] siderophore (EC 4.-.-.-)
IsocPyruLyasPyoc	Isochorismate pyruvate-lyase [pyochelin] siderophore (EC 4.-.-.-)
IsocPyruLyasSide	Isochorismate pyruvate-lyase of siderophore biosynthesis (EC 4.-.-.-)
IsocSideBios	Isochorismatase of siderophore biosynthesis (EC 3.3.2.1)
IsocSynt	Isochorismate synthase (EC 5.4.4.2)
IsocSyntBaciSide	Isochorismate synthase [bacillibactin] siderophore (EC 5.4.4.2)
IsocSyntBrucSide	Isochorismate synthase [brucebactin] siderophore (EC 5.4.4.2)
IsocSyntEnanPyoc	Isochorismate synthase [enantio-pyochelin] siderophore (EC 5.4.4.2)
IsocSyntEnteSide	Isochorismate synthase [enterobactin] siderophore (EC 5.4.4.2)
IsocSyntPyocSide	Isochorismate synthase [pyochelin] siderophore (EC 5.4.4.2)
IsocSyntSideBios	Isochorismate synthase of siderophore biosynthesis (EC 5.4.4.2)
IsohCoaHydr	Isohexenylglutaconyl-CoA hydratase (EC 4.2.1.57)
IsolTrnaSynt	Isoleucyl-tRNA synthetase (EC 6.1.1.5)
IsolTrnaSyntChlo	Isoleucyl-tRNA synthetase, chloroplast (EC 6.1.1.5)
IsolTrnaSyntMito	Isoleucyl-tRNA synthetase, mitochondrial (EC 6.1.1.5)
IsolTrnaSyntRela	Isoleucyl-tRNA synthetase related gene in Burkholderia
IsonHydr	Isonitrile hydratase (EC 4.2.1.103)
IsonInduProtInia	Isoniazid inductible protein IniA, dynamin-like protein
IsonInduProtInib	Isoniazid inductible protein IniB
IsonInduProtInic	Isoniazid inductible protein IniC, dynamin-like protein
IsopDiphDeltIsom	Isopentenyl-diphosphate Delta-isomerase (EC 5.3.3.2)
IsopDiphDeltIsom2	Isopentenyl-diphosphate delta-isomerase, FMN-dependent (EC 5.3.3.2)
IsopDiphSyntRela	Isopentenyl-diphosphate synthesis related conserved protein
IsopPhosKina	Isopentenyl phosphate kinase (EC 2.7.4.26)
Isoq1OxidBetaSubu	Isoquinoline 1-oxidoreductase beta subunit (EC 1.3.99.16)
IsovCoaDehy	Isovaleryl-CoA dehydrogenase (EC 1.3.8.4)
KUptaProtKtrbInte	K(+)-uptake protein KtrB, integral membrane subunit
KapbLipoRequForKinb	KapB, lipoprotein required for KinB pathway to sporulation
KapdInhiKinaPath	KapD, inhibitor of KinA pathway to sporulation
KetoAcidRedu	Ketol-acid reductoisomerase (EC 1.1.1.86)
KetoReduPang	Ketopantoate reductase PanG (EC 1.1.1.169)
KhDomaRnaBindProt	KH domain RNA binding protein YlqC
KinaRequForThreT	Kinase (Bud32/PRPK), required for threonylcarbamoyladenosine t(6)A37 formation in tRNA (p53-regulating)
KtraPotaUptaSyst	KtrAB potassium uptake system, peripheral membrane component KtrA
KtraPotaUptaSyst2	KtrAB potassium uptake system, integral membrane component KtrB
KtrcPotaUptaSyst	KtrCD potassium uptake system, peripheral membrane component KtrC
KtrcPotaUptaSyst2	KtrCD potassium uptake system, integral membrane component KtrD
KuDomaProt	Ku domain protein
Kynu	Kynureninase (EC 3.7.1.3)
Kynu3Mono	Kynurenine 3-monooxygenase (EC 1.14.13.9)
Kynu3MonoHomoVioc	Kynurenine 3-monooxygenase homolog VioC in violacein biosynthesis
KynuForm	Kynurenine formamidase (EC 3.5.1.9)
KynuFormBact	Kynurenine formamidase, bacterial (EC 3.5.1.9)
KynuFormYeasType	Kynurenine formamidase, yeast-type BNA7 (EC 3.5.1.9)
L24DiamAcidAcet	L-2,4-diaminobutyric acid acetyltransferase (EC 2.3.1.178)
L24DiamAcidTranDoed	L-2,4-diaminobutyric acid transaminase DoeD (EC 2.6.1.-)
L24DiamDeca	L-2,4-diaminobutyrate decarboxylase (EC 4.1.1.86)
L2Amin4MethTran3n1	L-2-amino-4-methoxy-trans-3-butenoic acid non-ribosomal peptide synthetase AmbE
L2Amin4MethTran3n2	L-2-amino-4-methoxy-trans-3-butenoic acid synthesis TauD-like protein AmbD
L2Amin4MethTran3n3	L-2-amino-4-methoxy-trans-3-butenoic acid synthesis TauD-like protein AmbC
L2Amin4MethTran3n4	L-2-amino-4-methoxy-trans-3-butenoic acid non-ribosomal peptide synthetase AmbB
L2Amin4MethTran3n5	L-2-amino-4-methoxy-trans-3-butenoic acid export protein AmbA, LysE family
L2AminRedu	L-2-aminoadipate reductase (EC 1.2.1.95) (EC 1.2.1.31)
L2HydrDehy2	L-2-hydroxyglutarate dehydrogenase (EC 1.1.99.2)
L2HydrOxid	L-2-hydroxyglutarate oxidase (EC 1.1.3.15)
L2Keto3DeoxDehy	L-2-keto-3-deoxyarabonate dehydratase (EC 4.2.1.43)
LAlanDlGlutEpim	L-alanine-DL-glutamate epimerase (EC 5.1.1.n1)
LAlanGlyoAmin	L-alanine:glyoxylate aminotransferase (EC 2.6.1.44)
LAminSemiDehyPhos	L-aminoadipate-semialdehyde dehydrogenase-phosphopantetheinyl transferase (EC 2.7.8.7)
LArab	L-arabinolactonase (EC 3.1.1.15)
LArabBindPeriProt	L-arabinose-binding periplasmic protein precursor AraF (TC 3.A.1.2.2)
LArabDehy	L-arabonate dehydratase (EC 4.2.1.25)
LArabTranAtpBind	L-arabinose transport ATP-binding protein AraG (TC 3.A.1.2.2)
LArabTranSystPerm2	L-arabinose transport system permease protein (TC 3.A.1.2.2)
LAspa	L-asparaginase (EC 3.5.1.1)
LAspaBetaDeca2	L-aspartate beta-decarboxylase (EC 4.1.1.12)
LAspaDehy	L-Aspartate dehydrogenase (EC 1.4.1.21)
LAspaICyto	L-asparaginase I, cytoplasmic (EC 3.5.1.1)
LAspaOxid	L-aspartate oxidase (EC 1.4.3.16)
LBetaLysi56AminAlph	L-beta-lysine 5,6-aminomutase alpha subunit (EC 5.4.3.3)
LBetaLysi56AminBeta	L-beta-lysine 5,6-aminomutase beta subunit (EC 5.4.3.3)
LCarnGammButyAnti	L-carnitine/gamma-butyrobetaine antiporter
LCarnTran	L-Carnitine transporter
LCyst1dMyoInos2Amin	L-cysteine:1D-myo-inosityl 2-amino-2-deoxy-alpha-D-glucopyranoside ligase MshC
LCystAbcTranAtpBind2	L-cystine ABC transporter (wide substrate range), ATP-binding protein YecC
LCystAbcTranPerm2	L-cystine ABC transporter (wide substrate range), permease protein YecS
LCystAbcTranSubs2	L-cystine ABC transporter (wide substrate range), substrate-binding protein FliY
LCystLyas	L-Cysteate Lyase (EC 4.4.1.25)
LEctoSynt	L-ectoine synthase (EC 4.2.1.108)
LFucoBetaPyraDehy	L-fuco-beta-pyranose dehydrogenase (EC 1.1.1.122)
LFucoBetaPyraDehy2	L-fuco-beta-pyranose dehydrogenase, type 2 (EC 1.1.1.122)
LFucoDehy	L-fuconate dehydratase (EC 4.2.1.68)
LFucoHydr	L-fuconolactone hydrolase
LFucoIsom	L-fucose isomerase (EC 5.3.1.25)
LFucoMuta	L-fucose mutarotase (EC 5.1.3.29)
LFucoMutaType2n1	L-fucose mutarotase, type 2 (EC 5.1.3.29)
LFucoOperActi	L-fucose operon activator
LFucu	L-fuculokinase (EC 2.7.1.51)
LFucuPhosAldo	L-fuculose phosphate aldolase (EC 4.1.2.17)
LGala5Dehy	L-galactonate-5-dehydrogenase
LGalaTran	L-galactonate transporter
LHistNMeth	L-histidine N(alpha)-methyltransferase (EC 2.1.1.44)
LIdon5Dehy	L-idonate 5-dehydrogenase (EC 1.1.1.264)
LIdonDGluc5KetoD	L-idonate, D-gluconate, 5-keto-D-gluconate transporter
LLDiamAmin	L,L-diaminopimelate aminotransferase (EC 2.6.1.83)
LLDiamAminDaplType	L,L-diaminopimelate aminotransferase, DapL2 type (EC 2.6.1.83)
LLDiamAminMeth	L,L-diaminopimelate aminotransferase, methanococcal (EC 2.6.1.83)
LLactDehy	L-lactate dehydrogenase (EC 1.1.1.27)
LLysi6MonoNadpAero	L-lysine 6-monooxygenase [NADPH], aerobactin biosynthesis protein IucD (EC 1.14.13.59)
LLysi6MonoSideBios	L-lysine 6-monooxygenase in siderophore biosynthesis => MbtG (EC 1.14.13.59)
LLysi6MonoSideBios2	L-lysine 6-monooxygenase in siderophore biosynthesis gene cluster (EC 1.14.13.59)
LLysiPerm	L-lysine permease
LMalyCoaBetaMeth	L-malyl-CoA/beta-methylmalyl-CoA lyase, actinobacterial type (EC 4.1.3.-)
LMalyCoaBetaMeth2	L-malyl-CoA/beta-methylmalyl-CoA lyase (EC 4.1.3.-)
LMalyCoaBetaMeth3	L-malyl-CoA/beta-methylmalyl-CoA lyase, chloroflexus type (EC 4.1.3.-)
LOLysySynt	L-O-lysylphosphatidylglycerol synthase (EC 2.3.2.3)
LOrni5MonoPvdaPyov	L-ornithine 5-monooxygenase, PvdA of pyoverdin biosynthesis (EC 1.13.12.-)
LProlGlycBetaTran	L-Proline/Glycine betaine transporter ProP
LRhamDehy	L-rhamnonate dehydratase (EC 4.2.1.90)
LRhamTran	L-rhamnonate transporter (predicted by genome context)
LRhamUtilTranRegu	L-rhamnonate utilization transcriptional regulator (predicted by genome context)
LRibu5Phos3EpimUlae	L-ribulose-5-phosphate 3-epimerase UlaE (EC 5.1.3.22)
LRibu5Phos4Epim	L-ribulose-5-phosphate 4-epimerase (EC 5.1.3.4)
LRibu5Phos4EpimSgbe	L-ribulose-5-phosphate 4-epimerase SgbE (EC 5.1.3.4)
LRibu5Phos4EpimUlaf	L-ribulose-5-phosphate 4-epimerase UlaF (L-ascorbate utilization protein F) (EC 5.1.3.4)
LSeriDehyAlphSubu	L-serine dehydratase, alpha subunit (EC 4.3.1.17)
LSeriDehyBetaSubu	L-serine dehydratase, beta subunit (EC 4.3.1.17)
LSeryTrnaKina	L-seryl-tRNA(Sec) kinase
LSeryTrnaSeleTran	L-seryl-tRNA(Sec) selenium transferase (EC 2.9.1.1)
LSeryTrnaSeleTran2	L-seryl-tRNA(Sec) selenium transferase-related protein
LSulfDehy	L-sulfolactate dehydrogenase (EC 1.1.1.272)
LTartDehyAlphSubu	L(+)-tartrate dehydratase alpha subunit (EC 4.2.1.32)
LTartDehyBetaSubu	L(+)-tartrate dehydratase beta subunit (EC 4.2.1.32)
LThre3OPhosDeca	L-threonine 3-O-phosphate decarboxylase (EC 4.1.1.81)
LThreKinaB12Bios	L-threonine kinase in B12 biosynthesis (EC 2.7.1.177)
LThreTranAnaeIndu	L-threonine transporter, anaerobically inducible
LTyroDeca	L-tyrosine decarboxylase (EC 4.1.1.25)
LXylu3KetoLGuloKina	L-xylulose/3-keto-L-gulonate kinase (EC 2.7.1.-)
LXylu5Phos3Epim	L-xylulose 5-phosphate 3-epimerase (EC 5.1.3.-)
Lact2Mono	Lactate 2-monooxygenase (EC 1.13.12.4)
LactCoaDehy	Lactoyl-CoA dehydratase (EC 4.2.1.54)
LactDelbPhagMv4Main	Lactobacillus delbrueckii phage mv4 main capsid protein Gp34 homolog lin2390
LactDiphGuan78Dide	Lactyl (2) diphospho-(5')guanosine:7,8-didemethyl-8-hydroxy-5-deazariboflavin 2-phospho-L-lactate transferase (EC 2.7.8.28)
LactGalaPermGphTran	Lactose and galactose permease, GPH translocator family
LactHydr	Lactoylbacillithiol hydrolase
LactLyas	Lactoylglutathione lyase (EC 4.4.1.5)
LactLyas4	Lactoylbacillithiol lyase
LactOxid	Lactate oxidase (EC 1.13.12.-)
LactPerm	Lactose permease
LactPhosSystRepr	Lactose phosphotransferase system repressor
LactRace	Lactate racemase (EC 5.1.2.1)
LactRedu	Lactaldehyde reductase (EC 1.1.1.77)
LactUtilProtLamb	Lactam utilization protein LamB
LaraImplLactRace	LarA: implicated in lactate racemization
LarbImplLactRace	LarB: implicated in lactate racemization
LarcImplLactRace	LarC1: implicated in lactate racemization
LarcImplLactRace2	LarC2: implicated in lactate racemization
LareImplLactRace	LarE: implicated in lactate racemization
LateCompProtComc	Late competence protein ComC, processing protease
LateCompProtCome	Late competence protein ComEA, DNA receptor
LateCompProtCome2	Late competence protein ComEB
LateCompProtCome4	Late competence protein ComER, proline oxidase (EC 1.5.1.2)
LateCompProtCome8	Late competence protein ComER, similarity with Pyrroline-5-carboxylate reductase
LateCompProtComg	Late competence protein ComGA, access of DNA to ComEA
LateCompProtComg10	Late competence protein ComGE, FIG015513
LateCompProtComg11	Late competence protein ComGG, FIG028917
LateCompProtComg12	Late competence protein ComGE, FIG015564
LateCompProtComg13	Late competence protein ComGG, FIG007920
LateCompProtComg14	Late competence protein ComGF, access of DNA to ComEA, FIG017774
LateCompProtComg15	Late competence protein ComGE, FIG018915
LateCompProtComg2	Late competence protein ComGB, access of DNA to ComEA
LateCompProtComg3	Late competence protein ComGG, FIG068335
LateCompProtComg4	Late competence protein ComGF, access of DNA to ComEA, FIG012620
LateCompProtComg5	Late competence protein ComGE, FIG075573
LateCompProtComg6	Late competence protein ComGD, access of DNA to ComEA, FIG038316
LateCompProtComg7	Late competence protein ComGC, access of DNA to ComEA, FIG007487
LateCompProtComg9	Late competence protein ComGD, access of DNA to ComEA, FIG012777
LaurMyriAcylInvo	Lauroyl/myristoyl acyltransferase involved in lipid A biosynthesis (Lauroyl/myristoyl acyltransferase)
LeadCadmZincMerc	Lead, cadmium, zinc and mercury transporting ATPase (EC 3.6.3.5) (EC 3.6.3.3)
LeadPept	Leader peptidase (Prepilin peptidase) (EC 3.4.23.43)
LeucPhenTrnaProt	Leucyl/phenylalanyl-tRNA--protein transferase (EC 2.3.2.6)
LeucRespReguProt	Leucine-responsive regulatory protein, regulator for leucine (or lrp) regulon and high-affinity branched-chain amino acid transport system
LeucTrnaSynt	Leucyl-tRNA synthetase (EC 6.1.1.4)
LeucTrnaSyntChlo	Leucyl-tRNA synthetase, chloroplast (EC 6.1.1.4)
LeucTrnaSyntLike	Leucyl-tRNA synthetase-like protein in Burkholderia mallei group
LeucTrnaSyntMito	Leucyl-tRNA synthetase, mitochondrial (EC 6.1.1.4)
Leva	Levansucrase (EC 2.4.1.10)
Leva2	Levanase (EC 3.2.1.65)
LighDepeProtRedu	Light-dependent protochlorophyllide reductase (EC 1.3.1.33)
LighHarvLhiAlphSubu	Light-harvesting LHI, alpha subunit
LighHarvLhiBetaSubu	Light-harvesting LHI, beta subunit
LighHarvLhiiAlph	Light-harvesting LHII, alpha subunit B
LighHarvLhiiAlph2	Light-harvesting LHII, alpha subunit E
LighHarvLhiiAlph3	Light-harvesting LHII, alpha subunit A
LighHarvLhiiAlph4	Light-harvesting LHII, alpha subunit D
LighHarvLhiiAlph5	Light-harvesting LHII, alpha subunit C
LighHarvLhiiAlph6	Light-harvesting LHII, alpha subunit F
LighHarvLhiiAlph7	Light-harvesting LHII, alpha subunit G
LighHarvLhiiBeta	Light-harvesting LHII, beta subunit A
LighHarvLhiiBeta2	Light-harvesting LHII, beta subunit E
LighHarvLhiiBeta3	Light-harvesting LHII, beta subunit C
LighHarvLhiiBeta4	Light-harvesting LHII, beta subunit D
LighHarvLhiiBeta5	Light-harvesting LHII, beta subunit B
LighHarvLhiiBeta6	Light-harvesting LHII, beta subunit F
LighHarvLhiiBeta7	Light-harvesting LHII, beta subunit G
LighIndeProtRedu	Light-independent protochlorophyllide reductase subunit B (EC 1.18.-.-)
LighIndeProtRedu2	Light-independent protochlorophyllide reductase iron-sulfur ATP-binding protein ChlL (EC 1.18.-.-)
LighIndeProtRedu3	Light-independent protochlorophyllide reductase subunit N (EC 1.18.-.-)
LipaActiProtLipa	Lipase activator protein, Lipase-specific foldase
LipaAcylWithGdsl2	Lipase/Acylhydrolase with GDSL-like motif in BtlB locus
LipaPrec	Lipase precursor (EC 3.1.1.3)
LipiBiosLaurAcyl	Lipid A biosynthesis lauroyl acyltransferase (EC 2.3.1.-)
LipiDisaSynt	Lipid-A-disaccharide synthase (EC 2.4.1.182)
LipiExpoPermAtpBind	Lipid A export permease/ATP-binding protein MsbA
LipiIiGlycGlyc	Lipid II:glycine glycyltransferase (EC 2.3.2.16)
LipiIiiFlip	Lipid III flippase
LipiLinkNAcetDepe	Lipid-linked-N-acetylgalactosamine-dependent galactosamine transferase, involved in arabinogalactan modification
Lipo12NAcet	Lipopolysaccharide 1,2-N-acetylglucosaminetransferase (EC 2.4.1.56)
Lipo13Gala	Lipopolysaccharide 1,3-galactosyltransferase (EC 2.4.1.44)
Lipo16Gala	Lipopolysaccharide 1,6-galactosyltransferase (EC 2.4.1.-)
Lipo3	Lipoamidase
LipoAbcTranAtpBind	Lipopolysaccharide ABC transporter, ATP-binding protein LptB
LipoBiosAssoProt	Lipopolysaccharide biosynthesis associated protein HtrL
LipoBiosChaiLeng	Lipopolysaccharide biosynthesis chain length determinant protein
LipoBiosProtWzxc	Lipopolysaccharide biosynthesis protein WzxC
LipoBiosProtWzze	lipopolysaccharide biosynthesis protein WzzE
LipoCarrProt	Lipoate carrier protein
LipoCoreBiosProt	Lipopolysaccharide core biosynthesis protein RfaZ
LipoCoreBiosProt4	Lipopolysaccharide core biosynthesis protein RfaS
LipoCoreHeptI	Lipopolysaccharide core heptosyltransferase I
LipoCoreHeptIii	Lipopolysaccharide core heptosyltransferase III
LipoCoreHeptKina	Lipopolysaccharide core heptose(I) kinase RfaP
LipoCoreHeptKina2	Lipopolysaccharide core heptose(II) kinase RfaY
LipoEnzy	Lipolytic enzyme (EC 3.1.1.3 )
LipoExpoSystPerm	Lipopolysaccharide export system permease protein LptG
LipoExpoSystPerm2	Lipopolysaccharide export system permease protein LptF
LipoExpoSystProt	Lipopolysaccharide export system protein LptC
LipoGcvhProtNLipo	Lipoyl-[GcvH]:protein N-lipoyltransferase (EC 2.3.1.200)
LipoLpqbModuActi	Lipoprotein LpqB, modulates activity of MtrAB two-component system
LipoLpqt	Lipoprotein LpqT
LipoLpraModuTlr2n1	Lipoprotein LprA, modulates TLR2-induced inflammatory response in mammalian host
LipoLprb	Lipoprotein LprB
LipoLprc	Lipoprotein LprC
LipoLprd	Lipoprotein LprD
LipoLpre	Lipoprotein LprE
LipoLprfInvoTran	Lipoprotein LprF, involved in translocation of lipoarabinomannan (LAM) to Mycobacterial outer membrane
LipoLprh	Lipoprotein LprH
LipoLprjModuKdpf	Lipoprotein LprJ, modulates kdpFABC expression via interacting with sensing domain of KdpD
LipoLpro	Lipoprotein LprO
LipoLprp	Lipoprotein LprP
LipoLprq	Lipoprotein LprQ
LipoNAcet	Lipopolysaccharide N-acetylmannosaminouronosyltransferase (EC 2.4.1.180)
LipoProtLiga	Lipoate-protein ligase A
LipoProtLigaCTerm2	Lipoate-protein ligase A, C-terminal 70 percent
LipoProtLigaNTerm2	Lipoate-protein ligase A, N-terminal 30 percent
LipoProtLigaType	Lipoate-protein ligase A type 2
LipoSignPept	Lipoprotein signal peptidase (EC 3.4.23.36)
LipoSynt2	Lipoyl synthase (EC 2.8.1.8)
LipoSyntCyanPara	Lipoate synthase, cyanobacterial paralog
LipoTypeIvSecrComp	Lipoprotein of type IV secretion complex that spans outer membrane and periplasm, VirB7
LipoVirbLike	Lipoprotein, VirB7-like
Lmo0HomoWithEsat2	Lmo0065 homolog within ESAT-6 gene cluster
LogFamiProt	LOG family protein
LonLikeProtWithPdz	Lon-like protease with PDZ domain
LonbLikeAtpAseNo	LonB like ATP-ase no protease domain
LongChaiAcylCoaDehy	Long chain acyl-CoA dehydrogenase [fadN-fadA-fadE operon] (EC 1.3.8.8)
LongChaiFattAcid	Long-chain-fatty-acid--CoA ligase (EC 6.2.1.3)
LongChaiFattAcid10	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD5 (EC 6.2.1.3)
LongChaiFattAcid11	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD4 (EC 6.2.1.3)
LongChaiFattAcid12	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD32
LongChaiFattAcid13	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD3 (EC 6.2.1.3)
LongChaiFattAcid14	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD19 (EC 6.2.1.3)
LongChaiFattAcid15	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD17 (EC 6.2.1.3)
LongChaiFattAcid16	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD8 (EC 6.2.1.3)
LongChaiFattAcid17	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD6 (EC 6.2.1.3)
LongChaiFattAcid18	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD11 (EC 6.2.1.3)
LongChaiFattAcid20	Long-chain-fatty-acid--CoA ligase associated with anthrachelin biosynthesis
LongChaiFattAcid25	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD2 (EC 6.2.1.3)
LongChaiFattAcid27	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD16 (EC 6.2.1.3)
LongChaiFattAcid3	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD36 (EC 6.2.1.3)
LongChaiFattAcid30	Long-chain-fatty-acid--CoA ligase of siderophore biosynthesis
LongChaiFattAcid31	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD29
LongChaiFattAcid36	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD33
LongChaiFattAcid37	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD9 (EC 6.2.1.3)
LongChaiFattAcid38	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD12 (EC 6.2.1.3)
LongChaiFattAcid39	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD31
LongChaiFattAcid40	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD21
LongChaiFattAcid41	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD1 (EC 6.2.1.3)
LongChaiFattAcid42	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD7 (EC 6.2.1.3)
LongChaiFattAcid43	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD22 (EC 6.2.1.3)
LongChaiFattAcid44	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD28
LongChaiFattAcid45	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD10 (EC 6.2.1.3)
LongChaiFattAcid46	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD26
LongChaiFattAcid50	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD13 (EC 6.2.1.3)
LongChaiFattAcid53	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD25
LongChaiFattAcid54	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD24
LongChaiFattAcid55	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD34
LongChaiFattAcid56	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD18 (EC 6.2.1.3)
LongChaiFattAcid57	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD23
LongChaiFattAcid58	Long-chain fatty-acid-AMP ligase, Mycobacterial subgroup FadD30
LongChaiFattAcid9	Long-chain fatty-acid-CoA ligase, Mycobacterial subgroup FadD15 (EC 6.2.1.3)
LongReguProtWith	Long regulatory protein with LuxR domain
LowAffiGlucHSymp	Low-affinity gluconate/H+ symporter GntU
LowCalcRespD	Low Calcium Response D (Type III secretion inner membrane protein SctV)
LowCalcRespE	Low Calcium Response E (CopN) (Type III secreted protein SctW)
LowGCGramPosiNudi	Low G+C gram positive nudix hydrolase YtkD (EC 3.6.-.-)
LowMoleWeigProtTyro5	Low molecular weight protein-tyrosine-phosphatase => Wzb (EC 3.1.3.48)
LowMoleWeigTCell2	Low molecular weight T-cell antigen TB8.4, predicted hemophore (see TIGR04529)
LpsAsseLipoRlpbPrec	LPS-assembly lipoprotein RlpB precursor (Rare lipoprotein B)
LpsExpoAbcTranPerm	LPS export ABC transporter permease LptG
LptaProtEsseForLps	LptA, protein essential for LPS transport across the periplasm
LpxtSpecSort	LPXTG specific sortase A
LrgaAssoMembProt	LrgA-associated membrane protein LrgB
Lrv4ClusDomaProt	LRV (FeS)4 cluster domain protein clustered with nitrogenase cofactor synthesis
LsrrTranReprLsrOper	LsrR, transcriptional repressor of lsr operon
LsuRiboProtL10a	LSU ribosomal protein L10Ae (L1p)
LsuRiboProtL10e	LSU ribosomal protein L10e (L16p)
LsuRiboProtL10p	LSU ribosomal protein L10p (P0)
LsuRiboProtL10pMito	LSU ribosomal protein L10p (P0), mitochondrial
LsuRiboProtL11e	LSU ribosomal protein L11e (L5p)
LsuRiboProtL11p	LSU ribosomal protein L11p (L12e)
LsuRiboProtL11pMito	LSU ribosomal protein L11p (L12e), mitochondrial
LsuRiboProtL12a	LSU ribosomal protein L12a (P1/P2)
LsuRiboProtL12e	LSU ribosomal protein L12e (L11p)
LsuRiboProtL13a	LSU ribosomal protein L13Ae (L13p)
LsuRiboProtL13e	LSU ribosomal protein L13e
LsuRiboProtL13p	LSU ribosomal protein L13p (L13Ae)
LsuRiboProtL13pMito	LSU ribosomal protein L13p (L13Ae), mitochondrial
LsuRiboProtL14e	LSU ribosomal protein L14e
LsuRiboProtL14p	LSU ribosomal protein L14p (L23e)
LsuRiboProtL14pMito	LSU ribosomal protein L14p (L23e), mitochondrial
LsuRiboProtL15e	LSU ribosomal protein L15e
LsuRiboProtL15p	LSU ribosomal protein L15p (L27Ae)
LsuRiboProtL15pMito	LSU ribosomal protein L15p (L27Ae), mitochondrial
LsuRiboProtL16p	LSU ribosomal protein L16p (L10e)
LsuRiboProtL16pMito	LSU ribosomal protein L16p (L10e), mitochondrial
LsuRiboProtL17e	LSU ribosomal protein L17e (L22p)
LsuRiboProtL17p	LSU ribosomal protein L17p
LsuRiboProtL17pMito	LSU ribosomal protein L17p, mitochondrial
LsuRiboProtL18a	LSU ribosomal protein L18Ae
LsuRiboProtL18e	LSU ribosomal protein L18e
LsuRiboProtL18p	LSU ribosomal protein L18p (L5e)
LsuRiboProtL18pMito	LSU ribosomal protein L18p (L5e), mitochondrial
LsuRiboProtL19e	LSU ribosomal protein L19e
LsuRiboProtL19p	LSU ribosomal protein L19p
LsuRiboProtL19pMito	LSU ribosomal protein L19p, mitochondrial
LsuRiboProtL1e	LSU ribosomal protein L1e (L4p)
LsuRiboProtL1p	LSU ribosomal protein L1p (L10Ae)
LsuRiboProtL1pMito	LSU ribosomal protein L1p (L10Ae), mitochondrial
LsuRiboProtL20p	LSU ribosomal protein L20p
LsuRiboProtL20pMito	LSU ribosomal protein L20p, mitochondrial
LsuRiboProtL21e	LSU ribosomal protein L21e
LsuRiboProtL21p	LSU ribosomal protein L21p
LsuRiboProtL21pMito	LSU ribosomal protein L21p, mitochondrial
LsuRiboProtL22p	LSU ribosomal protein L22p (L17e)
LsuRiboProtL22pMito	LSU ribosomal protein L22p (L17e), mitochondrial
LsuRiboProtL23a	LSU ribosomal protein L23Ae (L23p)
LsuRiboProtL23e	LSU ribosomal protein L23e (L14p)
LsuRiboProtL23p	LSU ribosomal protein L23p (L23Ae)
LsuRiboProtL23pMito	LSU ribosomal protein L23p (L23Ae), mitochondrial
LsuRiboProtL24e	LSU ribosomal protein L24e
LsuRiboProtL24p	LSU ribosomal protein L24p (L26e)
LsuRiboProtL24pMito	LSU ribosomal protein L24p (L26e), mitochondrial
LsuRiboProtL25p	LSU ribosomal protein L25p
LsuRiboProtL25pMito	LSU ribosomal protein L25p, mitochondrial
LsuRiboProtL26e	LSU ribosomal protein L26e (L24p)
LsuRiboProtL27a	LSU ribosomal protein L27Ae (L15p)
LsuRiboProtL27p	LSU ribosomal protein L27p
LsuRiboProtL27pMito	LSU ribosomal protein L27p, mitochondrial
LsuRiboProtL28e	LSU ribosomal protein L28e
LsuRiboProtL28p	LSU ribosomal protein L28p
LsuRiboProtL28pMito	LSU ribosomal protein L28p, mitochondrial
LsuRiboProtL28pZinc	LSU ribosomal protein L28p, zinc-independent
LsuRiboProtL28pZinc2	LSU ribosomal protein L28p, zinc-dependent
LsuRiboProtL29e	LSU ribosomal protein L29e
LsuRiboProtL29p	LSU ribosomal protein L29p (L35e)
LsuRiboProtL29pMito	LSU ribosomal protein L29p (L35e), mitochondrial
LsuRiboProtL2p	LSU ribosomal protein L2p (L8e)
LsuRiboProtL2pMito	LSU ribosomal protein L2p (L8e), mitochondrial
LsuRiboProtL30e	LSU ribosomal protein L30e
LsuRiboProtL30pMito	LSU ribosomal protein L30p (L7e), mitochondrial
LsuRiboProtL31e	LSU ribosomal protein L31e
LsuRiboProtL31p	LSU ribosomal protein L31p
LsuRiboProtL31pMito	LSU ribosomal protein L31p, mitochondrial
LsuRiboProtL31pZinc	LSU ribosomal protein L31p, zinc-dependent
LsuRiboProtL31pZinc2	LSU ribosomal protein L31p, zinc-independent
LsuRiboProtL32e	LSU ribosomal protein L32e
LsuRiboProtL32p	LSU ribosomal protein L32p
LsuRiboProtL32pMito	LSU ribosomal protein L32p, mitochondrial
LsuRiboProtL32pZinc	LSU ribosomal protein L32p, zinc-independent
LsuRiboProtL32pZinc2	LSU ribosomal protein L32p, zinc-dependent
LsuRiboProtL33p	LSU ribosomal protein L33p
LsuRiboProtL33pMito	LSU ribosomal protein L33p, mitochondrial
LsuRiboProtL33pZinc	LSU ribosomal protein L33p, zinc-independent
LsuRiboProtL33pZinc2	LSU ribosomal protein L33p, zinc-dependent
LsuRiboProtL34e	LSU ribosomal protein L34e
LsuRiboProtL34p	LSU ribosomal protein L34p
LsuRiboProtL34pMito	LSU ribosomal protein L34p, mitochondrial
LsuRiboProtL35a	LSU ribosomal protein L35Ae
LsuRiboProtL35e	LSU ribosomal protein L35e (L29p)
LsuRiboProtL35p	LSU ribosomal protein L35p
LsuRiboProtL35pMito	LSU ribosomal protein L35p, mitochondrial
LsuRiboProtL36e	LSU ribosomal protein L36e
LsuRiboProtL36p	LSU ribosomal protein L36p
LsuRiboProtL36pMito	LSU ribosomal protein L36p, mitochondrial
LsuRiboProtL36pZinc	LSU ribosomal protein L36p, zinc-dependent
LsuRiboProtL36pZinc2	LSU ribosomal protein L36p, zinc-independent
LsuRiboProtL37a	LSU ribosomal protein L37Ae
LsuRiboProtL37e	LSU ribosomal protein L37e
LsuRiboProtL37mMito	LSU ribosomal protein L37mt, mitochondrial
LsuRiboProtL38e	LSU ribosomal protein L38e
LsuRiboProtL38mMito	LSU ribosomal protein L38mt, mitochondrial
LsuRiboProtL39e	LSU ribosomal protein L39e
LsuRiboProtL39mMito	LSU ribosomal protein L39mt, mitochondrial
LsuRiboProtL3e	LSU ribosomal protein L3e (L3p)
LsuRiboProtL3p	LSU ribosomal protein L3p (L3e)
LsuRiboProtL3pMito	LSU ribosomal protein L3p (L3e), mitochondrial
LsuRiboProtL40e	LSU ribosomal protein L40e
LsuRiboProtL40mMito	LSU ribosomal protein L40mt, mitochondrial
LsuRiboProtL41e	LSU ribosomal protein L41e
LsuRiboProtL41mMito	LSU ribosomal protein L41mt, mitochondrial
LsuRiboProtL42mMito	LSU ribosomal protein L42mt, mitochondrial
LsuRiboProtL43mMito	LSU ribosomal protein L43mt, mitochondrial
LsuRiboProtL44e	LSU ribosomal protein L44e
LsuRiboProtL44mMito	LSU ribosomal protein L44mt, mitochondrial
LsuRiboProtL45a	LSU ribosomal protein L45a
LsuRiboProtL45mMito	LSU ribosomal protein L45mt, mitochondrial
LsuRiboProtL46a	LSU ribosomal protein L46a
LsuRiboProtL46mMito	LSU ribosomal protein L46mt, mitochondrial
LsuRiboProtL47a	LSU ribosomal protein L47a
LsuRiboProtL47mMito	LSU ribosomal protein L47mt, mitochondrial
LsuRiboProtL48mMito	LSU ribosomal protein L48mt, mitochondrial
LsuRiboProtL49mMito	LSU ribosomal protein L49mt, mitochondrial
LsuRiboProtL4p	LSU ribosomal protein L4p (L1e)
LsuRiboProtL4pMito	LSU ribosomal protein L4p (L1e), mitochondrial
LsuRiboProtL50mMito	LSU ribosomal protein L50mt, mitochondrial
LsuRiboProtL51mMito	LSU ribosomal protein L51mt, mitochondrial
LsuRiboProtL52mMito	LSU ribosomal protein L52mt, mitochondrial
LsuRiboProtL53mMito	LSU ribosomal protein L53mt, mitochondrial
LsuRiboProtL54mMito	LSU ribosomal protein L54mt, mitochondrial
LsuRiboProtL55mMito	LSU ribosomal protein L55mt, mitochondrial
LsuRiboProtL5e	LSU ribosomal protein L5e (L18p)
LsuRiboProtL5p	LSU ribosomal protein L5p (L11e)
LsuRiboProtL5pMito	LSU ribosomal protein L5p (L11e), mitochondrial
LsuRiboProtL6p	LSU ribosomal protein L6p (L9e)
LsuRiboProtL6pMito	LSU ribosomal protein L6p (L9e), mitochondrial
LsuRiboProtL7L12n1	LSU ribosomal protein L7/L12 (P1/P2)
LsuRiboProtL7L12n2	LSU ribosomal protein L7/L12 (L23e), mitochondrial
LsuRiboProtL7ae	LSU ribosomal protein L7Ae
LsuRiboProtL7e	LSU ribosomal protein L7e (L30p)
LsuRiboProtL8e	LSU ribosomal protein L8e (L2p)
LsuRiboProtL9e	LSU ribosomal protein L9e (L6p)
LsuRiboProtL9p	LSU ribosomal protein L9p
LsuRiboProtL9pMito	LSU ribosomal protein L9p, mitochondrial
LsuRiboProtMrp5Mito	LSU ribosomal protein MRP51, mitochondrial
LsuRiboProtMrplMito	LSU ribosomal protein MRPL15, mitochondrial
LsuRiboProtMrplMito2	LSU ribosomal protein MRPL20, mitochondrial
LsuRiboProtMrplMito3	LSU ribosomal protein MRPL13, mitochondrial
LsuRiboProtMrplMito4	LSU ribosomal protein MRPL25, mitochondrial
LsuRiboProtMrplMito5	LSU ribosomal protein MRPL31, mitochondrial
LsuRiboProtMrplMito6	LSU ribosomal protein MRPL35, mitochondrial
LsuRiboProtP0n1	LSU ribosomal protein P0 (L10p)
LsuRiboProtP1n1	LSU ribosomal protein P1 (L7/L12)
LsuRiboProtP2n1	LSU ribosomal protein P2 (L7/L12)
LsuRrna	LSU rRNA
LumaProtRiboSynt	Lumazine protein, riboflavin synthase homolog
LuxaLuciAlphChai	LuxA, luciferase alpha chain (EC 1.14.14.3)
LuxbLuciBetaChai	LuxB, luciferase beta chain (EC 1.14.14.3)
LuxcAcylCoaRedu	LuxC, acyl-CoA reductase (EC 1.2.1.50)
LuxdAcylTran	LuxD. acyl transferase (EC 2.3.1.-)
LuxeLongChaiFatt	LuxE, long-chain-fatty-acid ligase (EC 6.2.1.19)
LuxgNadHDepeFmnRedu	LuxG, NAD(P)H-dependent FMN reductase (EC 1.5.1.29)
LycoBetaCycl	Lycopene beta-cyclase (EC 5.5.1.19)
LycoCyclCruaType	Lycopene cyclase, CruA type
Lysi23Amin	Lysine 2,3-aminomutase (EC 5.4.3.2)
LysiBiosAminAcid	Lysine Biosynthetic Amino Acid Carrier Protein LysW
LysiDeca	Lysine decarboxylase (EC 4.1.1.18)
LysiDeca2Cons	Lysine decarboxylase 2, constitutive (EC 4.1.1.18)
LysiDecaIndu	Lysine decarboxylase, inducible (EC 4.1.1.18)
LysiEpsiOxidAnti	Lysine-epsilon oxidase antimicrobial protein LodA (EC 1.4.3.20)
LysiNAcylMbtk2	Lysine N-acyltransferase MbtK (EC 2.3.1.-)
LysiRace	Lysine racemase (EC 5.1.1.5)
LysiSpecPerm	Lysine-specific permease
Lyso	Lysophospholipase (EC 3.1.1.5)
LysoAcyl	Lysophospholipid acyltransferase
LysoFami	Lysozyme (N-acetylmuramidase) family, (EC 3.2.1.17)
LysrFamiReguProt	LysR family regulatory protein CidR
LysrFamiTranRegu15	LysR family transcriptional regulator HdfR
LysrFamiTranRegu21	LysR family transcriptional regulator DmlR
LysrFamiTranRegu31	LysR-family transcriptional regulator PtxE, associated with phosphonate utilization
LysrFamiTranRegu9	LysR-family transcriptional regulator clustered with PA0057
LysrTypeTranRegu4	LysR-type transcriptional regulator for nopaline catabolism NocR
LysyEndo	Lysyl endopeptidase (EC 3.4.21.50)
LysyTrnaSynt	Lysyl-tRNA synthetase (class II) (EC 6.1.1.6)
LysyTrnaSynt2	Lysyl-tRNA synthetase (class I) (EC 6.1.1.6)
LysyTrnaSyntChlo	Lysyl-tRNA synthetase (class II), chloroplast (EC 6.1.1.6)
LysyTrnaSyntLOLysy	Lysyl-tRNA synthetase (class II), L-O-lysylphosphatidylglycerol synthetase specific (EC 6.1.1.6)
LysyTrnaSyntMito	Lysyl-tRNA synthetase (class II), mitochondrial (EC 6.1.1.6)
LythProtInvoMeth	LytH protein involved in methicillin resistance
LytiEnzyAmidSaBact	Lytic enzyme, amidase [SA bacteriophages 11, Mu50B]
LytiTranClusWith	Lytic transglycosylase clustered with flagellum synthetic genes
LyzoM1n1	Lyzozyme M1 (1,4-beta-N-acetylmuramidase) (EC 3.2.1.17)
MagnCobaEfflProt	Magnesium and cobalt efflux protein CorC
MagnCobaTranProt	Magnesium and cobalt transport protein CorA
MagnProtMamaTpr_	Magnetosome protein MamA, TPR_2 repeat-containing
MagnProtMambCoZn	Magnetosome protein MamB, Co/Zn/Cd cation transporter
MagnProtMamc	Magnetosome protein MamC
MagnProtMamdHema	Magnetosome protein MamD, hemagglutinin motif-containing
MagnProtMameTryp	Magnetosome protein MamE, trypsin-like serine protease
MagnProtMamf	Magnetosome protein MamF
MagnProtMamg	Magnetosome protein MamG
MagnProtMamh	Magnetosome protein MamH
MagnProtMami	Magnetosome protein MamI
MagnProtMamj	Magnetosome protein MamJ
MagnProtMamkActi	Magnetosome protein MamK, Actin-like ATPase
MagnProtMamlProt	Magnetosome protein MamL protein
MagnProtMammCoZn	Magnetosome protein MamM, Co/Zn/Cd cation transporter
MagnProtMamnNaHAnti	Magnetosome protein MamN, Na+/H+ antiporter NhaD related
MagnProtMamoSeri	Magnetosome protein MamO, serine protease precursor MucD/AlgY-like
MagnProtMampSeri	Magnetosome protein MamP, serine protease
MagnProtMamqLema	Magnetosome protein MamQ, LemA family protein
MagnProtMamrDnaBind	Magnetosome protein MamR, DNA binding
MagnProtMams	Magnetosome protein MamS
MagnProtMamtCyto	Magnetosome protein MamT, cytochrome c mono- and diheme variants
MagnProtMamuDiac	Magnetosome protein MamU, diacylglycerol kinase-like
MagnProtMamvCoZn	Magnetosome protein MamV, Co/Zn/Cd cation transporter
MagnProtMamx	Magnetosome protein MamX
MagnProtMamy	Magnetosome protein MamY
MagnProtMamzPerm	Magnetosome protein MamZ, permease
MagnProtMms6n1	Magnetosome Protein Mms6
MainReguHeteDiff	Main regulator of heterocyst differentiation HetR
MajoCapsProtBact	Major capsid protein [Bacteriophage A118]
MajoColdShocProt3	Major cold shock protein CspA
MajoFaciSupeTran6	Major facilitator superfamily (MFS) transporter in predicted poly-gamma-glutamate synthase operon
MajoMyoInosTranIolt	Major myo-inositol transporter IolT
MajoPiluSubuType	Major pilus subunit of type IV secretion complex, VirB2
MajoTailShafProt	Major tail shaft protein [Bacteriophage A118]
MalaCoaLigaSubuAlph	Malate--CoA ligase subunit alpha (EC 6.2.1.9)
MalaCoaLigaSubuBeta	Malate--CoA ligase subunit beta (EC 6.2.1.9)
MalaDehy	Malate dehydrogenase (EC 1.1.1.37)
MalaNaSymp	Malate Na(+) symporter
MalaQuinOxid	Malate:quinone oxidoreductase (EC 1.1.5.4)
MalaSynt	Malate synthase (EC 2.3.3.9)
MalaSyntG	Malate synthase G (EC 2.3.3.9)
MaleHydrLargSubu	Maleate hydratase large subunit (EC 4.2.1.31)
MaleHydrSmalSubu	Maleate hydratase small subunit (EC 4.2.1.31)
MaleIsomMycoDepe	Maleylpyruvate isomerase, mycothiol-dependent (EC 5.2.1.4)
MaloAcylCarrProt	Malonyl-[acyl-carrier protein] O-methyltransferase (EC 2.1.1.197)
MaloCoaAcylCarrProt	Malonyl CoA-acyl carrier protein transacylase (EC 2.3.1.39)
MaloCoaDeca	Malonyl-CoA decarboxylase (EC 4.1.1.9)
MaloCoaDecaMitoPrec	Malonyl-CoA decarboxylase, mitochondrial precursor (EC 4.1.1.9)
MaloCoaLiga	Malonate--CoA ligase (EC 6.2.1.n3)
MaloDecaAlphSubu	Malonate decarboxylase alpha subunit
MaloDecaBetaSubu	Malonate decarboxylase beta subunit
MaloDecaDeltSubu	Malonate decarboxylase delta subunit
MaloDecaGammSubu	Malonate decarboxylase gamma subunit
MaloDecaHoloAcyl	Malonate decarboxylase holo-[acyl-carrier-protein] synthase (EC 2.7.7.66)
MaloEnzy	Malolactic enzyme (EC 1.-.-.-)
MaloRegu	Malolactic regulator
MaloSemiDehy	Malonate-semialdehyde dehydrogenase (EC 1.2.1.18)
MaloSemiDehyInos	Malonate-semialdehyde dehydrogenase [inositol] (EC 1.2.1.18)
MaloTranMadlSubu	Malonate transporter, MadL subunit
MaloTranMadmSubu	Malonate transporter, MadM subunit
MaloUtilTranRegu	Malonate utilization transcriptional regulator
MaltOligSynt	Malto-oligosyltrehalose synthase (EC 5.4.99.15)
MaltOperTranRepr	Maltose operon transcriptional repressor MalR, LacI family
MaltPhos	Maltodextrin phosphorylase (EC 2.4.1.1)
MalyCoaLyas	Malyl-CoA lyase (EC 4.1.3.24)
MandDehy	(S)-mandelate dehydrogenase (EC 1.1.99.31)
MandRace	Mandelate racemase (EC 5.1.2.2)
MangCata	Manganese catalase (EC 1.11.1.6)
MangDepeProtTyro	Manganese-dependent protein-tyrosine phosphatase (EC 3.1.3.48)
Mann1PhosGuan	Mannose-1-phosphate guanylyltransferase (GDP) (EC 2.7.7.22)
Mann1PhosGuan2	Mannose-1-phosphate guanylyltransferase (EC 2.7.7.13)
Mann1PhosGuanCola	Mannose-1-phosphate guanylyltransferase => Colanic acid (EC 2.7.7.13)
Mann3PhosPhos	Mannosyl-3-phosphoglycerate phosphatase (EC 3.1.3.70)
Mann3PhosPhos2	Mannosylglucosyl-3-phosphoglycerate phosphatase
Mann3PhosSynt	Mannosyl-3-phosphoglycerate synthase (EC 2.4.1.217)
Mann3PhosSynt2	Mannosylglucosyl-3-phosphoglycerate synthase (EC 2.4.1.270)
Mann6PhosIsom	Mannose-6-phosphate isomerase (EC 5.3.1.8)
Mann6PhosIsomCola	Mannose-6-phosphate isomerase => Colanic acid (EC 5.3.1.8)
MannDGlycUtilRepr	Mannosyl-D-glycerate utilization repressor MngR
MannDehy	Mannonate dehydratase (EC 4.2.1.8)
MannSynt	Mannosylglucosylglycerate synthase
MaocLikeDehyClus	MaoC-like dehydratase clustered with carnitine metabolism genes
MarcFamiInteMemb	MarC family integral membrane protein
MarrFamiTranRegu6	MarR family transcriptional regulator associated with MmpL5/MmpS5 efflux system
MazgProtDoma	MazG protein domain
MazgRelaProt	MazG-related protein
MbthLikeNrpsChap	MbtH-like NRPS chaperone
MbthLikeNrpsChap2	MbtH-like NRPS chaperone => YbdZ
MbthLikeNrpsChap4	MbtH-like NRPS chaperone => MbtH
MceFamiLipoMcee	MCE-family lipoprotein MceE
MceFamiProtMcea	MCE-family protein MceA
MceFamiProtMceb	MCE-family protein MceB
MceFamiProtMcec	MCE-family protein MceC
MceFamiProtMced	MCE-family protein MceD
MceFamiProtMcef	MCE-family protein MceF
MeioRecoProtDmc1n1	Meiotic recombination protein DMC1
MeliResiProtPqab	Melittin resistance protein PqaB
MembAlanAminN	Membrane alanine aminopeptidase N (EC 3.4.11.2)
MembAnchTetrCyto	Membrane anchored tetraheme cytochrome c, CymA
MembAssoProtCont	Membrane-associated protein containing RNA-binding TRAM domain and ribonuclease PIN-domain, YacL B.subtilis ortholog
MembAssoZincMeta	Membrane-associated zinc metalloprotease
MembBounCDiGmpRece	Membrane bound c-di-GMP receptor LapD
MembBounHydr4fe4s	Membrane bound hydrogenase, 4Fe-4S cluster-binding subunit MbhN
MembBounHydrMbha	Membrane bound hydrogenase, MbhA subunit
MembBounHydrMbhb	Membrane bound hydrogenase, MbhB subunit
MembBounHydrMbhc	Membrane bound hydrogenase, MbhC subunit
MembBounHydrMbhd	Membrane bound hydrogenase, MbhD subunit
MembBounHydrMbhe	Membrane bound hydrogenase, MbhE subunit
MembBounHydrMbhf	Membrane bound hydrogenase, MbhF subunit
MembBounHydrMbhg	Membrane bound hydrogenase, MbhG subunit
MembBounHydrMbhh	Membrane bound hydrogenase, MbhH subunit
MembBounHydrMbhi	Membrane bound hydrogenase, MbhI subunit
MembBounHydrMbhm	Membrane bound hydrogenase, MbhM subunit (EC 1.12.7.2)
MembBounHydrNife	Membrane bound hydrogenase, NiFe-hydrogenase small subunit MbJ
MembBounHydrNife2	Membrane bound hydrogenase, NiFe-hydrogenase MbhK
MembBounHydrNife4	Membrane bound hydrogenase, NiFe-hydrogenase large subunit (EC 1.12.7.2)
MembBounLytiMure4	Membrane-bound lytic murein transglycosylase D
MembBounLytiMure7	Membrane-bound lytic murein transglycosylase B (EC 3.2.1.-)
MembBounMetaDepe	Membrane-bound metal-dependent hydrolase YdjM, induced during SOS response
MembBounMethNife	Membrane-bound methanophenazine [NiFe] hydrogenase, cytochrome-b subunit (EC 1.12.98.3)
MembBounMethNife2	Membrane-bound methanophenazine [NiFe] hydrogenase, large subunit (EC 1.12.98.3)
MembBounMethNife3	Membrane-bound methanophenazine [NiFe] hydrogenase, small subunit (EC 1.12.98.3)
MembCompMultResi	Membrane component of multidrug resistance system
MembDockProt	membrane docking protein
MembEfflProtAsso	Membrane efflux protein associated with [Alcaligin] siderophore cluster
MembEmbeMetaPred	Membrane-embedded metalloprotease predicted to cleave YydF
MembFusiCompMsfType	Membrane fusion component of MSF-type tripartite multidrug efflux system
MembFusiCompTrip	Membrane fusion component of tripartite multidrug resistance system
MembProtAssoWith	Membrane protein associated with oxaloacetate decarboxylase
MembProtAssoWith2	Membrane protein associated with methylmalonyl-CoA decarboxylase
MembProtEccbComp	Membrane protein EccB4, component of Type VII secretion system ESX-4
MembProtEccbComp2	Membrane protein EccB1, component of Type VII secretion system ESX-1
MembProtEccbComp3	Membrane protein EccB3, component of Type VII secretion system ESX-3
MembProtEccbComp4	Membrane protein EccB5, component of Type VII secretion system ESX-5
MembProtEccbComp5	Membrane protein EccB2, component of Type VII secretion system ESX-2
MembProtEccbLike	Membrane protein EccB-like, component of Type VII secretion system in Actinobacteria
MembProtEcceComp	Membrane protein EccE3, component of Type VII secretion system ESX-3
MembProtEcceComp2	Membrane protein EccE1, component of Type VII secretion system ESX-1
MembProtEcceComp3	Membrane protein EccE5, component of Type VII secretion system ESX-5
MembProtEcceComp4	Membrane protein EccE2, component of Type VII secretion system ESX-2
MembProtFuncCoup	Membrane Protein Functionally coupled to the MukBEF Chromosome Partitioning Mechanism
MembProtMmps	Membrane protein MmpS5
MembProtMmps2	Membrane protein MmpS4
MembProtMmps3	Membrane protein MmpS3
MembProtMmps4	Membrane protein MmpS6
MembProtMmps5	Membrane protein MmpS1
MembProtMmps6	Membrane protein MmpS14
MembProtMmps7	Membrane protein MmpS2
MembProtMmpsFami	membrane protein, MmpS family
MembProtRv13n1	Membrane protein Rv1342c
MembProtRv34Comp	Membrane protein Rv3446c, component of Type VII secretion system ESX-4
MembProtRv36Comp	Membrane protein Rv3611, component of Type VII secretion system ESX-1
MembProtRv36Enha	Membrane protein Rv3632, enhances catalytic activity of PpgS
MembProtSuppForCopp	Membrane protein, suppressor for copper-sensitivity ScsD
MembProtSuppForCopp2	Membrane protein, suppressor for copper-sensitivity ScsB
MembProtTcaaAsso	Membrane protein TcaA associated with Teicoplanin resistance
MenaSpecIsocSynt	Menaquinone-specific isochorismate synthase (EC 5.4.4.2)
MenaViaFutaPoly	Menaquinone via futalosine polyprenyltransferase (MenA homolog)
MenaViaFutaStep4n2	Menaquinone via futalosine step 4, possible alternative
MercIonRedu	Mercuric ion reductase (EC 1.16.1.1)
MercTranProtMerc	Mercuric transport protein, MerC
MercTranProtMert	Mercuric transport protein, MerT
MesaC4CoaHydr	Mesaconyl-C4-CoA hydratase
MesaCoaC1C4CoaTran	Mesaconyl-CoA C1-C4 CoA transferase (EC 5.4.1.3)
MesoDiamDDehy	Meso-diaminopimelate D-dehydrogenase (EC 1.4.1.16)
MetaBetaLactFami2	Metallo-beta-lactamase family protein, RNA-specific
MetaBetaLactSupe3	Metallo-beta-lactamase superfamily protein PA0057
MetaBetaLactSupe5	Metallo-beta-lactamase superfamily domain protein in prophage
MetaDepeHydrCog0n1	Metal-dependent hydrolase COG0491 with rhodanese-homology domain (RHOD)
MetaDepeHydrSubg	Metallo-dependent hydrolases, subgroup B
MetaDepeHydrYbey	Metal-dependent hydrolase YbeY, involved in rRNA and/or ribosome maturation and assembly
MetaPutaZincBind	Metalloprotease, putative zinc-binding domain
MetaSteaSixTranEpit	Metalloreductase STEAP, Six-transmembrane epithelial antigen of prostate
Meth1PhosDehy	Methylthioribulose-1-phosphate dehydratase (EC 4.2.1.109)
Meth1PhosDehyRela	Methylthioribulose-1-phosphate dehydratase related protein
Meth1PhosIsom	Methylthioribose-1-phosphate isomerase (EC 5.3.1.23)
MethAbcTranSubsBind	Methionine ABC transporter substrate-binding protein
MethAcceChemProt27	Methyl-accepting chemotaxis protein, hemolysin secretion protein HylB
MethAmin	Methionine aminopeptidase (EC 3.4.11.18)
MethAminPlpDepe	Methionine aminotransferase, PLP-dependent
MethAmmoLyas	Methylaspartate ammonia-lyase (EC 4.3.1.2)
MethAnthBios	Methyltransferase, anthrose biosynthesis
MethCoMethSpecCorr	[Methyl-Co(III) methylamine-specific corrinoid protein]:coenzyme M methyltransferase (EC 2.1.1.247)
MethCoMethSpecCorr2	[Methyl-Co(III) methanol-specific corrinoid protein]:coenzyme M methyltransferase (EC 2.1.1.246)
MethCoaCarbBiotCont	Methylcrotonyl-CoA carboxylase biotin-containing subunit (EC 6.4.1.4)
MethCoaCarbCarbTran	Methylcrotonyl-CoA carboxylase carboxyl transferase subunit (EC 6.4.1.4)
MethCoaDecaAlphChai	Methylmalonyl-CoA decarboxylase, alpha chain (EC 4.1.1.41)
MethCoaDecaBetaChai	Methylmalonyl-CoA decarboxylase, beta chain (EC 4.1.1.41)
MethCoaDecaDeltSubu	Methylmalonyl-CoA decarboxylase, delta-subunit (EC 4.1.1.41)
MethCoaDecaGammChai	Methylmalonyl-CoA decarboxylase, gamma chain (EC 4.1.1.41)
MethCoaDehyPredBy	Methylsuccinyl-CoA dehydrogenase, predicted by (Erb et al, 2007)
MethCoaEpim	Methylmalonyl-CoA epimerase (EC 5.1.99.1)
MethCoaHydr	Methylglutaconyl-CoA hydratase (EC 4.2.1.18)
MethCoaMuta	Methylmalonyl-CoA mutase (EC 5.4.99.2)
MethCoaMutaLargSubu	Methylmalonyl-CoA mutase large subunit, MutB (EC 5.4.99.2)
MethCoaMutaSmalSubu	Methylmalonyl-CoA mutase small subunit, MutA (EC 5.4.99.2)
MethCoaPyruTran12s	Methylmalonyl-CoA:Pyruvate transcarboxylase 12S subunit (EC 2.1.3.1)
MethCoaPyruTran5s	Methylmalonyl-CoA:Pyruvate transcarboxylase 5S subunit (EC 2.1.3.1)
MethCoenMMeth	Methylthiol:coenzyme M methyltransferase
MethCoenMMethCorr	Methylthiol:coenzyme M methyltransferase corrinoid protein
MethCoenMReduAlph	Methyl coenzyme M reductase alpha subunit (EC 2.8.4.1)
MethCoenMReduAsso	Methyl coenzyme M reductase associated protein
MethCoenMReduBeta	Methyl coenzyme M reductase beta subunit (EC 2.8.4.1)
MethCoenMReduGamm	Methyl coenzyme M reductase gamma subunit (EC 2.8.4.1)
MethCoenMReduIAlph	Methyl coenzyme M reductase I alpha subunit (EC 2.8.4.1)
MethCoenMReduIBeta	Methyl coenzyme M reductase I beta subunit (EC 2.8.4.1)
MethCoenMReduIGamm	Methyl coenzyme M reductase I gamma subunit (EC 2.8.4.1)
MethCoenMReduIiAlph	Methyl coenzyme M reductase II alpha subunit (EC 2.8.4.1)
MethCoenMReduIiBeta	Methyl coenzyme M reductase II beta subunit (EC 2.8.4.1)
MethCoenMReduIiGamm	Methyl coenzyme M reductase II gamma subunit (EC 2.8.4.1)
MethCoenMReduOper	Methyl coenzyme M reductase operon protein D
MethCoenMReduOper2	Methyl coenzyme M reductase operon protein C
MethCorrActiProt2	Methyltransferase corrinoid activation protein
MethCorrMeth	Methanol:corrinoid methyltransferase (EC 2.1.1.90)
MethCorrProtCoMeth	[Methylamine--corrinoid protein] Co-methyltransferase (EC 2.1.1.248)
MethCycl	Methenyltetrahydrofolate cyclohydrolase (EC 3.5.4.9)
MethDehy	Methylenetetrahydrofolate dehydrogenase (NADP+) (EC 1.5.1.5)
MethDehyLargSubu	Methanol dehydrogenase large subunit protein (EC 1.1.2.7)
MethDireRepaDnaAden	Methyl-directed repair DNA adenine methylase (EC 2.1.1.72)
MethDnaProtCystMeth	Methylated-DNA--protein-cysteine methyltransferase (EC 2.1.1.63)
MethEnzySimiMure	methanogen enzyme similar to murein synthesis amino acid ligase
MethGammLyas	Methionine gamma-lyase (EC 4.4.1.11)
MethHomoLargSubu	Methanogen homoaconitase, large subunit (EC 4.2.1.114)
MethHomoSmalSubu	Methanogen homoaconitase, small subunit (EC 4.2.1.114)
MethHydrCytoBSubu	Methanophenazine hydrogenase cytochrome b subunit (EC 1.12.98.3)
MethHydrLargSubu	Methanophenazine hydrogenase large subunit (EC 1.12.98.3)
MethHydrMatuProt	Methanophenazine hydrogenase maturation protease (EC 3.4.24.-)
MethHydrSmalSubu	Methanophenazine hydrogenase small subunit precursor (EC 1.12.98.3)
MethLyas	Methylisocitrate lyase (EC 4.1.3.30)
MethMethCorrProt	Methanol methyltransferase corrinoid protein
MethMonoCompAlph	Methane monooxygenase component A alpha chain (EC 1.14.13.25)
MethMonoCompBeta	Methane monooxygenase component A beta chain (EC 1.14.13.25)
MethMonoCompC	Methane monooxygenase component C (EC 1.14.13.25)
MethMonoCompD	Methane monooxygenase component D (EC 1.14.13.25)
MethMonoCompGamm	Methane monooxygenase component A gamma chain (EC 1.14.13.25)
MethMonoReguProt	Methane monooxygenase regulatory protein B
MethMutaESubu	Methylaspartate mutase, E subunit (EC 5.4.99.1)
MethMutaSSubu	Methylaspartate mutase, S subunit (EC 5.4.99.1)
MethReprMetj	Methionine repressor MetJ
MethResiReguSens	Methicillin resistance regulatory sensor-transducer MecR1
MethResiReguSens2	Methicillin resistance regulatory sensor-transducer MecR1, truncated
MethResiReprMeci	Methicillin resistance repressor MecI
MethSemiDehy	Methylmalonate-semialdehyde dehydrogenase (EC 1.2.1.27)
MethSulfReduAsso	Methionine sulfoxide reductase-associated methionine-rich protein
MethSulfReduCyto	Methionine sulfoxide reductase cytochrome b subunit
MethSulfReduMoly	Methionine sulfoxide reductase molybdopterin-binding subunit
MethSynt	Methylglyoxal synthase (EC 4.2.3.3)
MethTetrDehy	Methylene tetrahydromethanopterin dehydrogenase (EC 1.5.99.9)
MethTrnaForm	Methionyl-tRNA formyltransferase (EC 2.1.2.9)
MethTrnaFormRela	Methionyl-tRNA formyltransferase related protein
MethTrnaMethTrmf	Methylenetetrahydrofolate--tRNA-(uracil-5-)-methyltransferase TrmFO (EC 2.1.1.74)
MethTrnaSynt	Methionyl-tRNA synthetase (EC 6.1.1.10)
MethTrnaSyntChlo	Methionyl-tRNA synthetase, chloroplast (EC 6.1.1.10)
MethTrnaSyntClos	Methionyl-tRNA synthetase, clostridial paralog
MethTrnaSyntMito	Methionyl-tRNA synthetase, mitochondrial (EC 6.1.1.10)
MethTrnaSyntRela	Methionyl-tRNA synthetase-related protein
MethTrnaSyntRela2	Methionyl-tRNA synthetase-related protein 2
Meva3Kina	Mevalonate-3-kinase (EC 2.7.1.185)
Meva3Phos5Kina	Mevalonate-3-phosphate-5-kinase (EC 2.7.1.186)
MevaKina	Mevalonate kinase (EC 2.7.1.36)
MfsFamiMultTranProt	MFS family multidrug transport protein, bicyclomycin resistance protein
MgCoNiTranMgteCbs	Mg/Co/Ni transporter MgtE, CBS domain-containing
MgProtIxMonoEste2	Mg protoporphyrin IX monomethyl ester oxidative cyclase (aerobic) (EC 1.14.13.81)
MgProtIxMonoEste3	Mg-protoporphyrin IX monomethyl ester oxidative cyclase (anaerobic) (EC 1.14.13.81)
MgProtOMeth	Mg-protoporphyrin O-methyltransferase (EC 2.1.1.11)
MgTranAtpaAssoProt	Mg(2+)-transport-ATPase-associated protein MgtC
MgTranAtpaPType	Mg(2+) transport ATPase, P-type (EC 3.6.3.2)
MicrColl	Microbial collagenase (EC 3.4.24.3)
MicrCollSecr	Microbial collagenase, secreted (EC 3.4.24.3)
MicrDipe	Microsomal dipeptidase (EC 3.4.13.19)
MicrProtProtSimi	Microcompartment protein protein similar to PduA/PduJ
MiniRiboIii23sRrna	Mini-ribonuclease III ## 23S rRNA maturase
MinoCapsProtBact	Minor capsid protein [Bacteriophage A118]
MinoMyoInosTranIolf	Minor myo-inositol transporter IolF
MinoPiliTypeIvSecr	Minor pilin of type IV secretion complex, VirB5
MitoMembTranForThia	Mitochondrial membrane transporter for thiamine pyrophosphate TPC1
Mn2Fe2TranNramFami2	Mn2+/Fe2+ transporter, NRAMP family
MobiProtMoba	Mobilization protein MobA
MobiProtMobc	mobilization protein MobC
ModuPolySynt	Modular polyketide synthase (EC 2.3.1.- )
MolyAbcTranAtpBind	Molybdenum ABC transporter ATP-binding protein ModC
MolyAbcTranPermProt	Molybdenum ABC transporter permease protein ModB
MolyAbcTranSubsBind	Molybdenum ABC transporter, substrate-binding protein ModA
MolyAden	Molybdopterin adenylyltransferase (EC 2.7.7.75)
MolyBindDomaMode	Molybdate-binding domain of ModE
MolyBindDomaMoea	Molybdopterin binding domain MoeA-like
MolyBiosEnzy	Molybdopterin biosynthesis enzyme
MolyCofaBiosProt5	Molybdenum cofactor biosynthesis protein MoaB
MolyCofaCyti	Molybdenum cofactor cytidylyltransferase (EC 2.7.7.76)
MolyCofaGuan	Molybdenum cofactor guanylyltransferase (EC 2.7.7.77)
MolyGuanDinuBios2	Molybdopterin-guanine dinucleotide biosynthesis protein MobB
MolyMoly	Molybdopterin molybdenumtransferase (EC 2.10.1.1)
MolyOxidIronSulf	Molybdopterin oxidoreductase, iron-sulfur binding subunit (EC 1.2.7.-)
MolySyntAden	Molybdopterin-synthase adenylyltransferase (EC 2.7.7.80)
MolySyntCataSubu	Molybdopterin synthase catalytic subunit MoaE (EC 2.8.1.12)
MolySyntSulfCarr	Molybdopterin synthase sulfur carrier subunit
MolyTranAtpBindProt	MOLYBDENUM TRANSPORT ATP-BINDING PROTEIN MODC (EC 3.6.3.29 )
MolyTranSystProt	Molybdenum transport system protein ModD
MonoBiosPeptTran	Monofunctional biosynthetic peptidoglycan transglycosylase (EC 2.4.2.-)
MonoComp	Monooxygenase component A
MonoCompC	Monooxygenase component C
MonoEtha	Monooxygenase EthA (EC 1.-.-.-)
MonoFad2fe2sCont	Monooxygenase, FAD- and [2Fe-2S]-containing component B
MonoIsocDehyNadp	Monomeric isocitrate dehydrogenase [NADP] (EC 1.1.1.42)
MonoMethCorrProt	Monomethylamine methyltransferase corrinoid protein
MonoPerm	Monomethylamine permease
MonoSarcOxidCura	Monomeric sarcosine oxidase, curated (EC 1.5.3.1)
MotaTolqExbbProt	MotA/TolQ/ExbB proton channel family protein
MoxrLikeAtpaAero	MoxR-like ATPase in aerotolerance operon
MptdArchDihyAldo	MptD, archaeal dihydroneopterin aldolase
MpteArch2Amin4Hydr	MptE, archaeal 2-amino-4-hydroxy-6-hydroxymethyldihydropteridine pyrophosphokinase
MrebLikeProt	MreB-like protein (Mbl protein)
Mrna3EndProcExon	mRNA 3-end processing exonuclease
MrnaEndoLs	mRNA endoribonuclease LS
MrnaInteRele	mRNA interferase RelE
MrnaInteYafq	mRNA interferase YafQ
MrpProtHomo	Mrp protein homolog
MrrRestSystProt	Mrr restriction system protein
MuciDesuSulfMdsa	Mucin-desulfating sulfatase MdsA precursor (EC 3.1.6.14)
MucoCycl	Muconate cycloisomerase (EC 5.5.1.1)
MultAcylCoaThioI	Multifunctional acyl-CoA thioesterase I, protease I, lysophospholipase L1
MultAntiResiProt2	Multiple antibiotic resistance protein MarR
MultAntiResiProt3	Multiple antibiotic resistance protein MarA
MultAntiResiProt4	Multiple antibiotic resistance protein MarB
MultCompAuxiComp	Multisynthetase complex auxiliary component p43
MultEfflPumpP55n1	Multidrug efflux pump P55
MultEfflSystAcra	Multidrug efflux system AcrAB-TolC, inner-membrane proton/drug antiporter AcrB (RND type)
MultEfflSystAcra2	Multidrug efflux system AcrAB-TolC, membrane fusion component AcrA
MultEfflSystAcre	Multidrug efflux system AcrEF-TolC, membrane fusion component AcrE
MultEfflSystAcre2	Multidrug efflux system AcrEF-TolC, inner-membrane proton/drug antiporter AcrF (RND type)
MultEfflSystEmra	Multidrug efflux system EmrAB-OMF, inner-membrane proton/drug antiporter EmrB (MFS type)
MultEfflSystEmra2	Multidrug efflux system EmrAB-OMF, membrane fusion component EmrA
MultEfflSystEmrk	Multidrug efflux system EmrKY-TolC, inner-membrane proton/drug antiporter EmrY (MFS type)
MultEfflSystEmrk2	Multidrug efflux system EmrKY-TolC, membrane fusion component EmrK
MultEfflSystInne	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => MexY of MexXY system
MultEfflSystInne10	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => CmeF
MultEfflSystInne11	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => CmeB
MultEfflSystInne2	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => MexB of MexAB-OprM
MultEfflSystInne3	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => MexQ of MexPQ-OpmE system
MultEfflSystInne4	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => MexI of MexHI-OpmD system
MultEfflSystInne5	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => TriC of TriABC-OpmH system
MultEfflSystInne6	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => MexK of MexJK-OprM/OpmH system
MultEfflSystInne7	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => MexD of MexCD-OprJ system
MultEfflSystInne8	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => MexF of MexEF-OprN system
MultEfflSystInne9	Multidrug efflux system, inner membrane proton/drug antiporter (RND type) => MexW of MexVW-OprM system
MultEfflSystMdta	Multidrug efflux system MdtABC-TolC, inner-membrane proton/drug antiporter MdtC (RND type)
MultEfflSystMdta2	Multidrug efflux system MdtABC-TolC, inner-membrane proton/drug antiporter MdtB (RND type)
MultEfflSystMdta3	Multidrug efflux system MdtABC-TolC, membrane fusion component MdtA
MultEfflSystMdta4	Multidrug efflux system MdtABC-TolC, inner-membrane proton/drug antiporter MdtB-like
MultEfflSystMdte	Multidrug efflux system MdtEF-TolC, membrane fusion component MdtE
MultEfflSystMdte2	Multidrug efflux system MdtEF-TolC, inner-membrane proton/drug antiporter MdtF (RND type)
MultEfflSystMemb	Multidrug efflux system, membrane fusion component => MexX of of MexXY system
MultEfflSystMemb10	Multidrug efflux system, membrane fusion component => MexV of MexVW-OprM system
MultEfflSystMemb12	Multidrug efflux system, membrane fusion component => CmeE
MultEfflSystMemb13	Multidrug efflux system, membrane fusion component => CmeA
MultEfflSystMemb2	Multidrug efflux system, membrane fusion component => MexA of MexAB-OprM
MultEfflSystMemb3	Multidrug efflux system, membrane fusion component => MexP of MexPQ-OpmE system
MultEfflSystMemb4	Multidrug efflux system, membrane fusion component => MexH of MexHI-OpmD system
MultEfflSystMemb5	Multidrug efflux system, membrane fusion component => TriB of TriABC-OpmH system
MultEfflSystMemb6	Multidrug efflux system, membrane fusion component => TriA of TriABC-OpmH system
MultEfflSystMemb7	Multidrug efflux system, membrane fusion component => MexJ of MexJK-OprM/OpmH system
MultEfflSystMemb8	Multidrug efflux system, membrane fusion component => MexC of MexCD-OprJ system
MultEfflSystMemb9	Multidrug efflux system, membrane fusion component => MexE of MexEF-OprN system
MultEfflSystOute	Multidrug efflux system, outer membrane factor associated with MexXY system
MultEfflSystOute11	Multidrug efflux system, outer membrane factor lipoprotein of OprM/OprM family
MultEfflSystOute2	Multidrug efflux system, outer membrane factor lipoprotein => OprM of MexAB-OprM
MultEfflSystOute4	Multidrug efflux system, outer membrane factor lipoprotein => OprJ of MexCD-OprJ system
MultEfflSystOute5	Multidrug efflux system, outer membrane factor lipoprotein => OprN of MexEF-OprN system
MultEfflSystOute6	Multidrug efflux system, outer membrane factor lipoprotein => CmeD
MultEfflSystOute7	Multidrug efflux system, outer membrane factor lipoprotein => CmeC
MultEfflSystOute8	Multidrug efflux system, outer membrane factor lipoprotein => OpmE of MexPQ-OpmE system
MultEfflSystOute9	Multidrug efflux system, outer membrane factor lipoprotein => OpmD of MexHI-OpmD system
MultEfflTranMdtk	Multidrug efflux transporter MdtK/NorM (MATE family)
MultMycoAcidSynt2	Multifunctional mycocerosic acid synthase membrane-associated mas in phthiocerol dimycocerosate cluster
MultResiProtEbra	Multidrug resistance protein EbrA
MultResiProtEbrb	Multidrug resistance protein EbrB
MultResiProtErma	Multidrug resistance protein ErmA
MultResiProtErmb	Multidrug resistance protein ErmB
MultResiProtFunc	Multidrug resistance protein [function not yet clear]
MultResiReguEmrr	Multidrug resistance regulator EmrR (MprA)
MultToxiExtrFami2	Multidrug and toxin extrusion (MATE) family efflux pump YdhE/NorM, homolog
MultTranTran	Multimodular transpeptidase-transglycosylase (EC 3.4.-.-) (EC 2.4.1.129)
MultViruFactRegu	Multiple virulence factor regulator MvfR/PqsR
MureDdEndo	Murein-DD-endopeptidase (EC 3.4.99.-)
MureHydrActiEnvc	Murein hydrolase activator EnvC
MureHydrActiNlpd	Murein hydrolase activator NlpD
MutaMuttProt	Mutator mutT protein (7,8-dihydro-8-oxoguanine-triphosphatase) (EC 3.6.1.-)
MutsDomaProtFami	MutS domain protein, family 2
MutsDomaProtFami2	MutS domain protein, family 6
MutsDomaProtFami3	MutS domain protein, family 4
MutsDomaProtFami4	MutS domain protein, family 5
MutsDomaProtFami5	MutS domain protein, family 8
MutsDomaProtFami6	MutS domain protein, family 7
MutsDomaProtFami7	MutS domain protein, family 9
MutsRelaProtFami	MutS-related protein, family 1
MxigProt	MxiG protein
MxihProt	MxiH protein
MxikProt	MxiK protein
Mxin	MxiN
MycoBindProtMftb	Mycofactocin binding protein MftB
MycoHemoAsspWith	Mycobacterial hemophore asspociated with MmpL11/MmpL3 transport system
MycoPersRespRegu	Mycobacterial persistence response regulator MprA
MycoPrec	Mycofactocin precursor
MycoProdNonrPept	Mycosporine-producing nonribosomal peptide synthetase
MycoRadiSamMatu	Mycofactocin radical SAM maturase
MycoSConjAmidMca	Mycothiol S-conjugate amidase Mca
MycoSystGlyc	Mycofactocin system glycosyltransferase
MycoSystHemeFlav	Mycofactocin system heme/flavin dehydrogenase
MycoSystNadhFlav	Mycofactocin system NADH:flavin oxidoreductase
MycoSystTranRegu	Mycofactocin system transcriptional regulator
MyoInos2Dehy	Myo-inositol 2-dehydrogenase (EC 1.1.1.18)
MyoInos2Dehy1n1	Myo-inositol 2-dehydrogenase 1 (EC 1.1.1.18)
MyoInos2Dehy2n1	Myo-inositol 2-dehydrogenase 2 (EC 1.1.1.18)
N3OxodLHomoLactQuor	N-3-oxododecanoyl-L-homoserine lactone quorum-sensing transcriptional activator
N3OxohLHomoLactQuor	N-3-oxohexanoyl-L-homoserine lactone quorum-sensing transcriptional activator
N3OxohLHomoLactSynt	N-3-oxohexanoyl-L-homoserine lactone synthase
N3OxooLHomoLactQuor	N-3-oxooctanoyl-L-homoserine lactone quorum-sensing transcriptional activator
N3OxooLHomoLactSynt	N-3-oxooctanoyl-L-homoserine lactone synthase
N5CarbRiboMuta	N5-carboxyaminoimidazole ribonucleotide mutase (EC 5.4.99.18)
N5CarbRiboSynt	N5-carboxyaminoimidazole ribonucleotide synthase (EC 6.3.4.18)
N5MethCoenMMethSubu	N5-methyltetrahydromethanopterin:coenzyme M methyltransferase subunit X
N5MethCoenMMethSubu2	N5-methyltetrahydromethanopterin:coenzyme M methyltransferase subunit E (EC 2.1.1.86)
N5MethCoenMMethSubu3	N5-methyltetrahydromethanopterin:coenzyme M methyltransferase subunit D (EC 2.1.1.86)
N5MethCoenMMethSubu4	N5-methyltetrahydromethanopterin:coenzyme M methyltransferase subunit C (EC 2.1.1.86)
N5MethCoenMMethSubu5	N5-methyltetrahydromethanopterin:coenzyme M methyltransferase subunit B (EC 2.1.1.86)
N5MethCoenMMethSubu6	N5-methyltetrahydromethanopterin:coenzyme M methyltransferase subunit A (EC 2.1.1.86)
N5MethCoenMMethSubu7	N5-methyltetrahydromethanopterin:coenzyme M methyltransferase subunit F (EC 2.1.1.86)
N5MethCoenMMethSubu8	N5-methyltetrahydromethanopterin:coenzyme M methyltransferase subunit G (EC 2.1.1.86)
N5MethCoenMMethSubu9	N5-methyltetrahydromethanopterin:coenzyme M methyltransferase subunit H (EC 2.1.1.86)
N6HydrOAcetAeroBios	N6-hydroxylysine O-acetyltransferase, aerobactin biosynthesis protein IucB (EC 2.3.1.102)
NAcet1DMyoInos2Amin	N-acetyl-1-D-myo-inosityl-2-amino-2-deoxy-alpha-D-glucopyranoside deacetylase MshB
NAcet1PhosUrid	N-acetylglucosamine-1-phosphate uridyltransferase (EC 2.7.7.23)
NAcet1PhosUridEuka	N-acetylglucosamine-1-phosphate uridyltransferase eukaryotic (EC 2.7.7.23)
NAcet6Phos2Epim	N-acetylmannosamine-6-phosphate 2-epimerase (EC 5.1.3.9)
NAcet6PhosDeac	N-acetylglucosamine-6-phosphate deacetylase (EC 3.5.1.25)
NAcet6Sulf2	N-acetylgalactosamine-6-sulfatase (EC 3.1.6.4)
NAcetAcid6PhosEthe	N-acetylmuramic acid 6-phosphate etherase (EC 4.2.-.-)
NAcetAuto	N-acetylglucosaminidase Auto (EC 3.2.1.96)
NAcetDiphDecaLRham	N-acetylglucosaminyl-diphospho-decaprenol L-rhamnosyltransferase (EC 2.4.1.289)
NAcetGammAminPhos	N-acetyl-gamma-aminoadipyl-phosphate reductase (EC 1.2.1.-)
NAcetGammGlutPhos	N-acetyl-gamma-glutamyl-phosphate reductase (EC 1.2.1.38)
NAcetKina	N-acetylmannosamine kinase (EC 2.7.1.60)
NAcetLAlanAmid	N-acetylmuramoyl-L-alanine amidase (EC 3.5.1.28)
NAcetLAlanAmidFami6	N-acetylmuramoyl-L-alanine amidase family 4, needed for cell separation and autolysis (EC 3.5.1.28)
NAcetLLDiamAmin	N-acetyl-L,L-diaminopimelate aminotransferase (EC 2.6.1.-)
NAcetLLDiamDeac	N-acetyl-L,L-diaminopimelate deacetylase (EC 3.5.1.47)
NAcetLMalaNAcetHydr	N-acetylglucosaminyl-L-malate N-acetyl hydrolase
NAcetLyas	N-acetylneuraminate lyase (EC 4.1.3.3)
NAcetLysiAmin	N-acetyl-lysine aminotransferase (EC 2.6.1.-)
NAcetLysiDeac	N-acetyl-lysine deacetylase (EC 3.5.1.-)
NAcetNNDiacDiphUnde	N-acetylgalactosamine-N,N'-diacetylbacillosaminyl-diphospho-undecaprenol 4-alpha-N-acetylgalactosaminyltransferase (EC 2.4.1.291)
NAcetSugaAmidWbpg	N-acetyl sugar amidotransferase WbpG
NAcetSynt2	N-acetylglutamate synthase (EC 2.3.1.1)
NAcylAcidRace	N-acylamino acid racemase
NAcylDAminAcidDeac	N-acyl-D-amino-acid deacylase (EC 3.5.1.81)
NAcylHomoLactHydr	N-acyl homoserine lactone hydrolase
NAcylLAminAcidAmid	N-acyl-L-amino acid amidohydrolase (EC 3.5.1.14)
NAcylLHomoLactSynt3	N-acyl-L-homoserine lactone synthetase RhlL (EC 2.3.1.184)
NAcylLHomoLactSynt5	N-acyl-L-homoserine lactone synthetase LasI (EC 2.3.1.184)
NAlphAcetL24Diam	N-alpha-acetyl-L-2,4-diaminobutyrate deacetylase
NButyLHomoLactQuor	N-butyryl-L-homoserine lactone quorum-sensing transcriptional activator
NCarbAmid	N-carbamoylputrescine amidase (EC 3.5.1.53)
NCarbLAminAcidHydr	N-carbamoyl-L-amino acid hydrolase (EC 3.5.1.87)
NCitrNAcetNHydrSynt	N(2)-citryl-N(6)-acetyl-N(6)-hydroxylysine synthase, aerobactin biosynthesis protein IucA (EC 6.3.2.38)
NFormDefo	N-formylglutamate deformylase (EC 3.5.1.68)
NFormDefoAlteForm	N-formylglutamate deformylase [alternative form] (EC 3.5.1.68)
NLHomoLactSyntLuxm	N-(3-hydroxybutanoyl)-L- homoserine lactone synthase LuxM
NLThreSynt	N(6)-L-threonylcarbamoyladenine synthase (EC 2.3.1.234)
NLinkGlycGlycPglg	N-linked glycosylation glycosyltransferase PglG
NMeth	N-methyltransferase (EC 2.1.1.-)
NMeth2	N-methylhydantoinase A (EC 3.5.2.14)
NMethB	N-methylhydantoinase B (EC 3.5.2.14)
NMethLAminAcidOxid	N-methyl-L-amino-acid oxidase (EC 1.5.3.2)
NMethLTrypOxid	N-methyl-L-tryptophan oxidase (EC 1.5.3.-)
NNDiacAcidSynt	N,N'-diacetyllegionaminic acid synthase (EC 2.5.1.101)
NNDiacDiphUndeAlph	N,N'-diacetylbacillosaminyl-diphospho-undecaprenol alpha-1,3-N-acetylgalactosaminyltransferase (ED 2.4.1.290)
NNDiacSpec6PhosBeta	N,N'-diacetylchitobiose-specific 6-phospho-beta-glucosidase (EC 3.2.1.86)
NNDiacSpecReguChbr	N,N'-diacetylchitobiose-specific regulator ChbR, AraC family
NNDiacUtilOperProt	N,N'-diacetylchitobiose utilization operon protein YdjC
NNMethCycl	N(5),N(10)-methenyltetrahydromethanopterin cyclohydrolase (EC 3.5.4.27)
NRiboPhos	N-Ribosylnicotinamide phosphorylase (EC 2.4.2.1)
NSuccArgiLysiRace	N-succinyl arginine/lysine racemase
NSuccLLDiamAmin	N-succinyl-L,L-diaminopimelate aminotransferase (EC 2.6.1.17)
NSuccLLDiamAminType	N-succinyl-L,L-diaminopimelate aminotransferase, type 2 (EC 2.6.1.17)
NSuccLLDiamDesu	N-succinyl-L,L-diaminopimelate desuccinylase (EC 3.5.1.18)
NaDepeBicaTranBica	Na(+)-dependent bicarbonate transporter BicA
NaDepeNuclTranNupc	Na+ dependent nucleoside transporter NupC
NaHAntiNhaaType	Na+/H+ antiporter NhaA type
NaHAntiNhadType	Na+/H+ antiporter NhaD type
NaHAntiSubu	Na(+) H(+) antiporter subunit A (TC 2.A.63.1.2)
NaHAntiSubuB	Na(+) H(+) antiporter subunit B (TC 2.A.63.1.2)
NaHAntiSubuC	Na(+) H(+) antiporter subunit C (TC 2.A.63.1.3)
NaHAntiSubuD	Na(+) H(+) antiporter subunit D (TC 2.A.63.1.3)
NaHAntiSubuE	Na(+) H(+) antiporter subunit E (TC 2.A.63.1.2)
NaHAntiSubuF	Na(+) H(+) antiporter subunit F (TC 2.A.63.1.3)
NaHAntiSubuG	Na(+) H(+) antiporter subunit G (TC 2.A.63.1.3)
NaHDicaSymp2	Na+/H+-dicarboxylate symporters
NaProlSymp	Na+/proline symporter
NaTranNadhQuinRedu	Na(+)-translocating NADH-quinone reductase subunit A (EC 1.6.5.-)
NaTranNadhQuinRedu2	Na(+)-translocating NADH-quinone reductase subunit B (EC 1.6.5.-)
NaTranNadhQuinRedu3	Na(+)-translocating NADH-quinone reductase subunit C (EC 1.6.5.-)
NaTranNadhQuinRedu4	Na(+)-translocating NADH-quinone reductase subunit D (EC 1.6.5.-)
NaTranNadhQuinRedu5	Na(+)-translocating NADH-quinone reductase subunit E (EC 1.6.5.-)
NaTranNadhQuinRedu6	Na(+)-translocating NADH-quinone reductase subunit F (EC 1.6.5.-)
NadDepeDihyDehySubu	NAD-dependent dihydropyrimidine dehydrogenase subunit PreT (EC 1.3.1.1)
NadDepeDihyDehySubu2	NAD-dependent dihydropyrimidine dehydrogenase subunit PreA (EC 1.3.1.1)
NadDepeGlyc3Phos	NAD-dependent glyceraldehyde-3-phosphate dehydrogenase (EC 1.2.1.12)
NadDepeGlyc3Phos2	NAD(P)-dependent glyceraldehyde 3-phosphate dehydrogenase archaeal (EC 1.2.1.59)
NadDepeGlyc3Phos3	NAD-dependent glyceraldehyde-3-phosphate dehydrogenase => Pentalenolactone resistance protein GapA (EC 1.2.1.12)
NadDepeMaliEnzy	NAD-dependent malic enzyme (EC 1.1.1.38)
NadDepeProtDeacSir2n1	NAD-dependent protein deacetylase of SIR2 family
NadHFlavRedu	NAD(P)H-flavin reductase (EC 1.16.1.3) (EC 1.5.1.29)
NadHHydrEpim	NAD(P)H-hydrate epimerase (EC 5.1.99.6)
NadHOxidYrkl	NAD(P)H oxidoreductase YRKL (EC 1.6.99.-)
NadHPlasOxidChai	NAD(P)H-plastoquinone oxidoreductase chain 5, NDHF (EC 1.6.5.-)
NadHPlasOxidChai2	NAD(P)H-plastoquinone oxidoreductase chain 2, NDHB (EC 1.6.5.-)
NadHPlasOxidChai3	NAD(P)H-plastoquinone oxidoreductase chain 1, NDHA (EC 1.6.5.-)
NadHPlasOxidChai4	NAD(P)H-plastoquinone oxidoreductase chain 6, NDHG (EC 1.6.5.-)
NadHPlasOxidChai5	NAD(P)H-plastoquinone oxidoreductase chain 4L, NDHE (EC 1.6.5.-)
NadHPlasOxidChai6	NAD(P)H-plastoquinone oxidoreductase chain 3, NDHC (EC 1.6.5.-)
NadHPlasOxidChai7	NAD(P)H-plastoquinone oxidoreductase chain 4, NDHD (EC 1.6.5.-)
NadHPlasOxidSubu	NAD(P)H-plastoquinone oxidoreductase subunit H, NDHH (EC 1.6.5.-)
NadHPlasOxidSubu2	NAD(P)H-plastoquinone oxidoreductase subunit I, NDHI (EC 1.6.5.-)
NadHPlasOxidSubu3	NAD(P)H-plastoquinone oxidoreductase subunit K, NDHK (EC 1.6.5.-)
NadHPlasOxidSubu4	NAD(P)H-plastoquinone oxidoreductase subunit J, NDHJ (EC 1.6.5.-)
NadHPlasOxidSubu5	NAD(P)H-plastoquinone oxidoreductase subunit M, NDHM (EC 1.6.5.-)
NadHSterDehyLike	NAD(P)H steroid dehydrogenase-like protein in alkane synthesis cluster
NadIndeProtDeacAcuc	NAD-independent protein deacetylase AcuC
NadKina	NAD kinase (EC 2.7.1.23)
NadPyroPeri	NAD pyrophosphatase, periplasmic (EC 3.6.1.22)
NadReduHydrSubuAlph	NAD-reducing hydrogenase subunit alpha (EC 1.12.1.2)
NadReduHydrSubuBeta	NAD-reducing hydrogenase subunit beta (EC 1.12.1.2)
NadReduHydrSubuDelt	NAD-reducing hydrogenase subunit delta (EC 1.12.1.2)
NadReduHydrSubuGamm	NAD-reducing hydrogenase subunit gamma (EC 1.12.1.2)
NadReduHydrSubuHoxe	NAD-reducing hydrogenase subunit HoxE (EC 1.12.1.2)
NadReduHydrSubuHoxf	NAD-reducing hydrogenase subunit HoxF (EC 1.12.1.2)
NadReduHydrSubuHoxh	NAD-reducing hydrogenase subunit HoxH (EC 1.12.1.2)
NadReduHydrSubuHoxu	NAD-reducing hydrogenase subunit HoxU (EC 1.12.1.2)
NadReduHydrSubuHoxy	NAD-reducing hydrogenase subunit HoxY (EC 1.12.1.2)
NadSpecGlutDehy	NAD-specific glutamate dehydrogenase (EC 1.4.1.2)
NadSpecGlutDehyEuka	NAD-specific glutamate dehydrogenase, eukaryotic type (EC 1.4.1.2)
NadSpecGlutDehyLarg	NAD-specific glutamate dehydrogenase, large form (EC 1.4.1.2)
NadSynt	NAD synthetase (EC 6.3.1.5)
NadTranAlphSubu	NAD(P) transhydrogenase alpha subunit (EC 1.6.1.2)
NadTranEndoPoss	NAD transporter of endosymbionts, possible
NadTranSubuBeta	NAD(P) transhydrogenase subunit beta (EC 1.6.1.2)
NadUtilDehySll0Homo	NAD(FAD)-utilizing dehydrogenase, sll0175 homolog
NadhDehy	NADH dehydrogenase (EC 1.6.99.3)
NadhDehyClusWith	NADH dehydrogenase in cluster with putative pheromone precursor (EC 1.6.99.3)
NadhDehyISubu4Invo	NADH dehydrogenase I subunit 4, Involved in photosystem-1 cyclic electron flow
NadhDehySubu1n1	NADH dehydrogenase subunit 1
NadhDehySubu2n1	NADH dehydrogenase subunit 2
NadhDehySubu3n1	NADH dehydrogenase subunit 3
NadhDehySubu4Invo	NADH dehydrogenase subunit 4, Involved in CO2 fixation
NadhDehySubu4l	NADH dehydrogenase subunit 4L
NadhDehySubu5Invo	NADH dehydrogenase subunit 5, Involved in CO2 fixation
NadhDehySubu5n1	NADH dehydrogenase subunit 5
NadhDepeReduFerr	NADH-dependent reduced ferredoxin:NADP+ oxidoreductase subunit A
NadhDepeReduFerr2	NADH-dependent reduced ferredoxin:NADP+ oxidoreductase subunit B
NadhFmnOxid	NADH-FMN oxidoreductase
NadhPyro	NADH pyrophosphatase (EC 3.6.1.22)
NadhQuinOxidChai	NADH-quinone oxidoreductase chain F 2 (EC 1.6.99.5)
NadhQuinOxidSubu	NADH-quinone oxidoreductase subunit 15 (EC 1.6.99.5)
NadhUbiqOxid172Kd	NADH:ubiquinone oxidoreductase 17.2 kD subunit
NadhUbiqOxidChai	NADH-ubiquinone oxidoreductase chain D (EC 1.6.5.3)
NadhUbiqOxidChai10	NADH-ubiquinone oxidoreductase chain J (EC 1.6.5.3)
NadhUbiqOxidChai11	NADH-ubiquinone oxidoreductase chain K (EC 1.6.5.3)
NadhUbiqOxidChai12	NADH-ubiquinone oxidoreductase chain L (EC 1.6.5.3)
NadhUbiqOxidChai13	NADH-ubiquinone oxidoreductase chain M (EC 1.6.5.3)
NadhUbiqOxidChai14	NADH-ubiquinone oxidoreductase chain N (EC 1.6.5.3)
NadhUbiqOxidChai15	NADH-ubiquinone oxidoreductase chain G2 (EC 1.6.5.3)
NadhUbiqOxidChai19	NADH-ubiquinone oxidoreductase chain B homolog (EC 1.6.5.3)
NadhUbiqOxidChai2	NADH ubiquinone oxidoreductase chain A (EC 1.6.5.3)
NadhUbiqOxidChai3	NADH-ubiquinone oxidoreductase chain B (EC 1.6.5.3)
NadhUbiqOxidChai4	NADH-ubiquinone oxidoreductase chain C (EC 1.6.5.3)
NadhUbiqOxidChai5	NADH-ubiquinone oxidoreductase chain E (EC 1.6.5.3)
NadhUbiqOxidChai6	NADH-ubiquinone oxidoreductase chain F (EC 1.6.5.3)
NadhUbiqOxidChai7	NADH-ubiquinone oxidoreductase chain G (EC 1.6.5.3)
NadhUbiqOxidChai8	NADH-ubiquinone oxidoreductase chain H (EC 1.6.5.3)
NadhUbiqOxidChai9	NADH-ubiquinone oxidoreductase chain I (EC 1.6.5.3)
NadpDepe7Cyan7Deaz	NADPH-dependent 7-cyano-7-deazaguanine reductase (EC 1.7.1.13)
NadpDepeBroaRang	NADPH-dependent broad range aldehyde dehydrogenase YqhD
NadpDepeButaDehy	NADPH-dependent butanol dehydrogenase (EC 1.1.1.-)
NadpDepeGlyc3Phos2	NADPH-dependent glyceraldehyde-3-phosphate dehydrogenase (EC 1.2.1.13)
NadpDepeMaliEnzy	NADP-dependent malic enzyme (EC 1.1.1.40)
NadpDepeMethRedu	NADPH-dependent methylglyoxal reductase (D-lactaldehyde dehydrogenase)
NadpDepeMycoRedu	NADPH-dependent mycothiol reductase Mtr
NadpDepeOxid2	NADPH-dependent oxidoreductase
NadpDepePropDehy	NADPH-dependent propanol dehydrogenase
NadpPhos	NADP phosphatase (EC 3.1.3.-)
NadpQuinRedu3	NADPH:quinone reductase (Quinone oxidoreductase) (EC 1.6.5.5)
NadpSpecGlutDehy	NADP-specific glutamate dehydrogenase (EC 1.4.1.4)
NadrTranRegu	NadR transcriptional regulator
NaphSynt	Naphthoate synthase (EC 4.1.3.36)
NegaReguFlagSynt	Negative regulator of flagellin synthesis FlgM (anti-sigma28)
NegaReguHrpExprHrpv	negative regulator of hrp expression HrpV
NeopDSynt	Neopentalenolactone D synthase (EC 1.14.13.171)
NfuaFeSProtMatu	NfuA Fe-S protein maturation
NiacTranNiap	Niacin transporter NiaP
NiacTranYeasDal5n1	Niacin transporter in yeast, DAL5 family
NickBindAcceProt	Nickel-binding accessory protein UreJ-HupE
NickCobaEfflTran	Nickel/cobalt efflux transporter RcnA
NickCobaHomeProt	Nickel/cobalt homeostasis protein RcnB
Nico	Nicotinamidase (EC 3.5.1.19)
NicoAdenDinuGlyc	Nicotine adenine dinucleotide glycohydrolase (NADGH) (EC 3.2.2.5)
NicoDehyFadSubu	Nicotinate dehydrogenase, FAD-subunit (EC 1.17.1.5)
NicoDehyLargMoly	Nicotinate dehydrogenase, large molybdopterin subunit (EC 1.17.1.5)
NicoDehyMediMoly	Nicotinate dehydrogenase, medium molybdopterin subunit (EC 1.17.1.5)
NicoDehySmalFesSubu	Nicotinate dehydrogenase, small FeS subunit (EC 1.17.1.5)
NicoFamiProtYcac	Nicotinamidase family protein YcaC
NicoIsocFamiProt	Nicotinamidase/isochorismatase family protein
NicoNMeth	Nicotinamide N-methyltransferase (EC 2.1.1.1)
NicoNuclAden	Nicotinate-nucleotide adenylyltransferase (EC 2.7.7.18)
NicoNuclAden2	nicotinamide-nucleotide adenylyltransferase (EC 2.7.7.1 )
NicoNuclAdenEuka	Nicotinate-nucleotide adenylyltransferase, eukaryotic PNAT family (EC 2.7.7.18)
NicoNuclAdenEuka2	Nicotinamide-nucleotide adenylyltransferase, eukaryotic PNAT family (EC 2.7.7.1)
NicoNuclAdenNadm	Nicotinamide-nucleotide adenylyltransferase, NadM family (EC 2.7.7.1)
NicoNuclAdenNadm2	Nicotinate-nucleotide adenylyltransferase, NadM family (EC 2.7.7.18)
NicoNuclAdenNadr	Nicotinamide-nucleotide adenylyltransferase, NadR family (EC 2.7.7.1)
NicoNuclAmid	Nicotinamide-nucleotide amidase (EC 3.5.1.42)
NicoNuclAmidPara	Nicotinamide-nucleotide amidase paralog YfaY, no functional activity
NicoNuclAmidPara2	Nicotinamide-nucleotide amidase paralog YdeJ, no functional activity
NicoNuclDimePhos	Nicotinate-nucleotide--dimethylbenzimidazole phosphoribosyltransferase (EC 2.4.2.21)
NicoPhos	Nicotinate phosphoribosyltransferase (EC 6.3.4.21)
NicoPhos2	Nicotinamide phosphoribosyltransferase (EC 2.4.2.12)
NifbDomaProtType	NifB-domain protein, type 2
NifeHydrMetaAsse	[NiFe] hydrogenase metallocenter assembly protein HypF
NifeHydrMetaAsse2	[NiFe] hydrogenase metallocenter assembly protein HypC
NifeHydrMetaAsse3	[NiFe] hydrogenase metallocenter assembly protein HypD
NifeHydrMetaAsse4	[NiFe] hydrogenase metallocenter assembly protein HypE
NifeHydrMetaAsse5	[NiFe] hydrogenase metallocenter assembly protein HybG
NifeHydrNickInco	[NiFe] hydrogenase nickel incorporation protein HypA
NifeHydrNickInco2	[NiFe] hydrogenase nickel incorporation-associated protein HypB
NifeHydrNickInco3	[NiFe] hydrogenase nickel incorporation protein HybF
NifeHydrNickInco4	[NiFe] hydrogenase nickel incorporation HybF-like protein
NifmProt	NifM protein
NiftProt	NifT protein
NifuLikeDomaProt	NifU-like domain protein
NifuLikeProt	NifU-like protein
NifuLikeProt1Chlo	NifU-like protein 1, chloroplast precursor (AtCNfu1, AtCnfU-IVb)
NifuLikeProt2Chlo	NifU-like protein 2, chloroplast precursor (AtCNfu2, AtCnfU-V)
NifuLikeProt3Chlo	NifU-like protein 3 chloroplast precursor (AtCNfu3, AtCnfU-IVa)
NifxAssoProt	NifX-associated protein
NifyProt	NifY protein
NifzProt	NifZ protein
NitrAlphChai	Nitrogenase (molybdenum-iron) alpha chain (EC 1.18.6.1)
NitrAlphChai2	Nitrogenase (iron-iron) alpha chain (EC 1.18.6.1)
NitrAlphChai3	Nitrogenase (vanadium-iron) alpha chain (EC 1.18.6.1)
NitrAssiTranActi	Nitrogen assimilation transcriptional activator NtcB
NitrAssoProtNifo	Nitrogenase-associated protein NifO
NitrBetaChai	Nitrogenase (molybdenum-iron) beta chain (EC 1.18.6.1)
NitrBetaChai2	Nitrogenase (iron-iron) beta chain (EC 1.18.6.1)
NitrBetaChai3	Nitrogenase (vanadium-iron) beta chain (EC 1.18.6.1)
NitrCofaCarrProt	Nitrogenase cofactor carrier protein NafY
NitrDeltChai	Nitrogenase (iron-iron) delta chain (EC 1.18.6.1)
NitrDeltChai2	Nitrogenase (vanadium-iron) delta chain (EC 1.18.6.1)
NitrFamiProtCbiy	Nitroreductase family protein CbiY (Bmega) clustered with, but not required for, cobalamin synthesis
NitrFemoCofaCarr	Nitrogenase FeMo-cofactor carrier protein NifX
NitrFemoCofaScaf	Nitrogenase FeMo-cofactor scaffold and assembly protein NifE
NitrFemoCofaScaf2	Nitrogenase FeMo-cofactor scaffold and assembly protein NifN
NitrFemoCofaSynt	Nitrogenase FeMo-cofactor synthesis FeS core scaffold and assembly protein NifB
NitrFemoCofaSynt2	Nitrogenase FeMo-cofactor synthesis molybdenum delivery protein NifQ
NitrNitrTran	Nitrate/nitrite transporter
NitrNitrTranNark	Nitrate/nitrite transporter NarK
NitrOxidRedu	Nitrous-oxide reductase (EC 1.7.99.6)
NitrOxidReduActi	Nitric oxide reductase activation protein NorD
NitrOxidReduActi2	Nitric oxide reductase activation protein NorQ
NitrOxidReduActi3	Nitric oxide reductase activation protein NorE
NitrOxidReduActi4	Nitric oxide reductase activation protein NorF
NitrOxidReduMatu	Nitrous oxide reductase maturation transmembrane protein NosY
NitrOxidReduMatu2	Nitrous oxide reductase maturation protein NosD
NitrOxidReduMatu3	Nitrous oxide reductase maturation protein NosF (ATPase)
NitrOxidReduMatu4	Nitrous oxide reductase maturation protein, outer-membrane lipoprotein NosL
NitrOxidReduMatu5	Nitrous oxide reductase maturation protein NosR
NitrOxidReduMatu6	Nitrous oxide reductase maturation periplasmic protein NosX
NitrOxidReduSubu	Nitric-oxide reductase subunit B (EC 1.7.99.7)
NitrOxidReduSubu2	Nitric-oxide reductase subunit C (EC 1.7.99.7)
NitrOxidRespTran	Nitric oxide -responding transcriptional regulator NnrR (Crp/Fnr family)
NitrOxidRespTran3	Nitric oxide -responding transcriptional regulator NnrA (Crp/Fnr family)
NitrOxidRespTran4	Nitric oxide -responding transcriptional regulator NnrB (Crp/Fnr family)
NitrRedu2	Nitrite reductase (EC 1.7.2.1)
NitrReduAcceProt	Nitrite reductase accessory protein NirV
NitrReduAssoCType	Nitrite reductase associated c-type cytochorome NirN
NitrReduAssoProt	nitrate reductase associated protein
NitrReduCytoC550n1	Nitrate reductase cytochrome c550-type subunit
NitrReduMatuProt	Nitrogenase (molybdenum-iron) reductase and maturation protein NifH
NitrReduMatuProt2	Nitrogenase (iron-iron) reductase and maturation protein AnfH
NitrReduMatuProt3	Nitrogenase (vanadium-iron) reductase and maturation protein VnfH
NitrReduRelaProt	Nitrite reductase related protein
NitrReguProtNtrb	Nitrogen regulation protein NtrB (EC 2.7.13.3)
NitrReguProtNtrc	Nitrogen regulation protein NtrC
NitrReguProtNtrx	Nitrogen regulation protein NtrX
NitrReguProtNtry	Nitrogen regulation protein ntrY (EC 2.7.3.-)
NitrRespRespRegu	Nitrogen-responsive response regulator NrrA
NitrSpecTranRegu	Nitrogenase (molybdenum-iron)-specific transcriptional regulator NifA
NitrStabProtProt	Nitrogenase stabilizing/protective protein NifW
NitrTranRegu	Nitrogenase (iron-iron) transcriptional regulator
NitrTranReguVnfa	Nitrogenase (vanadium-iron) transcriptional regulator VnfA
NitrVanaCofaSynt	Nitrogenase vanadium-cofactor synthesis protein VnfN
NitrVanaCofaSynt2	Nitrogenase vanadium-cofactor synthesis protein VnfE
NitrVanaCofaSynt3	Nitrogenase vanadium-cofactor synthesis protein VnfX
NitrVanaCofaSynt4	Nitrogenase vanadium-cofactor synthesis protein VnfY
NlpP60FamiLipo	NLP/P60 family lipoprotein
Nmn5NuclExtr	NMN 5'-nucleotidase, extracellular (EC 3.1.3.5)
NmnPhos	NMN phosphatase (EC 3.1.3.5)
NmnSynt	NMN synthetase (EC 6.3.1.-)
NmnaCytiFamiDoma	NMNAT/cytidylyltransferase family domain
NnrsProtInvoResp	NnrS protein involved in response to NO
NnruFamiProtClus	NnrU family protein in cluster with Mesaconyl-CoA hydratase
NonFuncDihySynt2n1	Non functional Dihydropteroate synthase 2
NonPhosGlyc3Phos2	Non-phosphorylating glyceraldehyde-3-phosphate dehydrogenase (NAD)
NonRiboPeptSyntModu	Non-ribosomal peptide synthetase modules, siderophore biosynthesis
NonRiboPeptSyntModu3	Non-ribosomal peptide synthetase modules, pyoverdine
NondAminYpde	Nondeblocking aminopeptidase YpdE (X-X-[^PR]- specific)
None	None
NonrPeptSyntFadd	Nonribosomal peptide synthetase in FadD10 cluster
NonsPoriStruOute	Nonspecific porin and structural outer membrane protein OprF
NopaTranAtpBindProt	Nopaline transporter ATP-binding protein NocP
NopaTranPeriSubs	Nopaline transporter periplasmic substrate-binding protein NocT
NopaTranPermProt	Nopaline transporter permease protein NocM
NopaTranPermProt2	Nopaline transporter permease protein NocQ
NotProlRaceNor4Hydr	Not a Proline racemase, nor 4-hydroxyproline epimerase [missing catalytic residues]
NoveDMannDGlucEpim	Novel D-mannonate-D-gluconate epimerase
NovePyriKinaThid	Novel pyridoxal kinase, thiD family (EC 2.7.1.35)
NpqtCellWallAnch	NPQTN cell wall anchored protein IsdC
NpqtSpecSortB	NPQTN specific sortase B
NreaLikeProtClus	NreA-like protein clustered with nickel/cobalt efflux transporter RcnA
NrfdProt	NrfD protein
NrpsLoadModuThrPg	NRPS loading module Thr-PG-PG-Thr
NrpsModu2PgPgAsn	NRPS module 2 PG-PG-Asn
NrpsModu3PgPg	NRPS module 3 PG-PG
NrpsModu4PgSerGly	NRPS module 4 PG-Ser-Gly-Thr
NrtrReguHypoNrtx	NrtR-regulated hypothetical NrtX, Band 7 protein domain
NrtrReguHypoNrty	NrtR-regulated hypothetical NrtY, PpnK-type ATP-NAD kinase domain
Nucl5TripRdgb	Nucleoside 5-triphosphatase RdgB (dHAPTP, dITP, XTP-specific) (EC 3.6.1.15)
NuclAbcTranAtpBind	Nucleoside ABC transporter, ATP-binding protein
NuclAbcTranPeriNucl	Nucleoside ABC transporter, periplasmic nucleoside-binding protein
NuclAbcTranPermProt	Nucleoside ABC transporter, permease protein 1
NuclAbcTranPermProt2	Nucleoside ABC transporter, permease protein 2
NuclAssoProtYaak	Nucleoid-associated protein YaaK
NuclAssoWithHepn	Nucleotidyltransferase associated with HEPN-containing protein
NuclBindOuteMemb	Nucleoside-binding outer membrane protein
NuclBindProtPinc	Nucleotide binding protein, PINc
NuclTranPossInvo	Nucleotidyl transferase possibly involved in threonylcarbamoyladenosine formation
NuclTripPyroMazg	Nucleoside triphosphate pyrophosphohydrolase MazG (EC 3.6.1.8)
NuclYfbrHdSupe	Nucleotidase YfbR, HD superfamily
NudiDntpDr00n1	Nudix dNTPase DR0092 (EC 3.6.1.-)
NudiDntpDr00n2	Nudix dNTPase DR0004 (EC 3.6.1.-)
NudiDntpDr01n1	Nudix dNTPase DR0149 (EC 3.6.1.-)
NudiDntpDr02n1	Nudix dNTPase DR0261 (EC 3.6.1.-)
NudiDntpDr02n2	Nudix dNTPase DR0274 (EC 3.6.1.-)
NudiDntpDr03n1	Nudix dNTPase DR0329 (EC 3.6.1.-)
NudiDntpDr05n1	Nudix dNTPase DR0550 (EC 3.6.1.-)
NudiDntpDr07n1	Nudix dNTPase DR0784 (EC 3.6.1.-)
NudiDntpDr10n1	Nudix dNTPase DR1025 (EC 3.6.1.-)
NudiDntpDr17n1	Nudix dNTPase DR1776 (EC 3.6.1.-)
NudiDntpDr23n1	Nudix dNTPase DR2356 (EC 3.6.1.-)
NudiFamiNdpaDr09n1	Nudix family (d)NDPase DR0975
NudiHydrAssoWith	NUDIX hydrolase, associated with Thiamin pyrophosphokinase
NudiHydrFamiProt3	Nudix hydrolase family protein YffH
NudiHydrFamiProt4	Nudix hydrolase family protein PA3470
NudiLikeNdpNtpPhos2	Nudix-like NDP and NTP phosphohydrolase NudJ
NudiRelaTranRegu	Nudix-related transcriptional regulator NrtR
NusaProtHomo2Arch	NusA protein homolog 2, archaeal
NusaProtHomoArch	NusA protein homolog, archaeal
NutrGermReceHydr	Nutrient germinant receptor hydrophilic subunit C (GerKC/GerAC/GerBC)
NutrGermReceInne	Nutrient germinant receptor inner membrane subunit A (GerKA/GerAA/GerBA)
NutrGermReceInne2	Nutrient germinant receptor inner membrane subunit B (GerKB/GerAB/GerBB)
OAcetAnthBios	O-acetyltransferase, anthrose biosynthesis
OAcetSulf	O-acetylhomoserine sulfhydrylase (EC 2.5.1.49)
OAntiChaiLengDete	O-antigen chain length determinant protein WzzB
OAntiFlipWzx	O-antigen flippase Wzx
OAntiLiga	O-antigen ligase
OMeth	O-methyltransferase (EC 2.1.1.-)
OMethMysb	O-methyltransferase MysB
OPhosTrnaCystTrna	O-phosphoseryl-tRNA:Cysteinyl-tRNA synthase
OPhosTrnaSeleTran	O-phosphoseryl-tRNA(Sec) selenium transferase (EC 2.9.1.2)
OPhosTrnaSynt	O-phosphoseryl-tRNA(Cys) synthetase (EC 6.1.1.27)
OSuccAcidCoaLiga	O-succinylbenzoic acid--CoA ligase (EC 6.2.1.26)
OSuccSulf	O-succinylhomoserine sulfhydrylase (EC 2.5.1.48)
OSuccSynt	O-succinylbenzoate synthase (EC 4.2.1.113)
OUreiDSeriCyclLiga	O-ureido-D-serine cyclo-ligase (EC 6.3.3.5)
ObgFamiRiboAsseProt	OBG-family ribosome assembly protein NOG1/MJ1408
OctaAcylCarrProt	Octanoate-[acyl-carrier-protein]-protein-N-octanoyltransferase (EC 2.3.1.181)
OctaAcylCarrProt2	Octanoate-[acyl-carrier-protein]-protein-N-octanoyltransferase, LipM (EC 2.3.1.181)
OctaDiphSynt2	Octaprenyl diphosphate synthase (EC 2.5.1.90)
OctaGcvhProtNOcta	Octanoyl-[GcvH]:protein N-octanoyltransferase (EC 2.3.1.204)
OctaTetrRedu	Octaheme tetrathionate reductase
OctoAbcTranAtpBind	Octopine ABC transporter, ATP-binding protein OccP
OctoAbcTranPermProt	Octopine ABC transporter, permease protein OccM
OctoAbcTranPermProt2	Octopine ABC transporter, permease protein OccQ
OctoAbcTranSubsBind	Octopine ABC transporter, substrate-binding protein OccT
OctoCataUptaOper	Octopine catabolism/uptake operon regulatory protein OccR
OleaHydr	Oleate hydratase (EC 4.2.1.53)
Olig	Oligopeptidase A (EC 3.4.24.70)
OligAbcTranPeriOlig	Oligopeptide ABC transporter, periplasmic oligopeptide-binding protein OppA (TC 3.A.1.5.1)
OligLyas	Oligogalacturonate lyase (EC 4.2.2.6)
OligLyas3	Oligohyaluronate lyase (EC 4.2.2.-)
OligPglb	Oligosaccharyltransferase PglB (EC 2.4.1.119)
OligRepeUnitPoly	Oligosaccharide repeat unit polymerase Wzy
OligSpecPoriProt	Oligogalacturonate-specific porin protein KdgM
OligTranAtpBindProt	Oligopeptide transport ATP-binding protein OppD (TC 3.A.1.5.1)
OligTranAtpBindProt2	Oligopeptide transport ATP-binding protein OppF (TC 3.A.1.5.1)
OligTranAtpBindProt3	Oligopeptide transport ATP-binding protein
OligTranPermProt	Oligopeptide transport permease protein OppC-like
OligTranPermProt2	Oligopeptide transport permease protein OppB-like
OligTranSubsBind	Oligopeptide transport substrate-binding protein
OligTranSystPerm	Oligopeptide transport system permease protein OppB (TC 3.A.1.5.1)
OligTranSystPerm2	Oligopeptide transport system permease protein OppC (TC 3.A.1.5.1)
Omeg3PolyFattAcid	omega-3 polyunsaturated fatty acid synthase subunit, PfaA
Omeg3PolyFattAcid2	omega-3 polyunsaturated fatty acid synthase subunit, PfaB
Omeg3PolyFattAcid3	omega-3 polyunsaturated fatty acid synthase subunit, PfaC
Omeg3PolyFattAcid4	omega-3 polyunsaturated fatty acid synthase module PfaB/C
OmegAminAcidPyru	Omega-amino acid--pyruvate aminotransferase (EC 2.6.1.18)
OpcaAlloEffeGluc	OpcA, an allosteric effector of glucose-6-phosphate dehydrogenase, actinobacterial
OpcaAlloEffeGluc2	OpcA, an allosteric effector of glucose-6-phosphate dehydrogenase, cyanobacterial
OpinOxidSubu	Opine oxidase subunit A (EC 1.-.-.-)
OpinOxidSubuB	Opine oxidase subunit B
OpinOxidSubuB2n1	Opine oxidase subunit B2
OpinOxidSubuC	Opine oxidase subunit C
Orfx	OrfX
OrgaAbcTranAtpBind	Organosulfonate ABC transporter ATP-binding protein
OrgaAbcTranPermProt	Organosulfonate ABC transporter permease protein
OrgaAbcTranSubsBind	Organosulfonate ABC transporter substrate-binding protein
OrgaSolvToleProt	Organic solvent tolerance protein precursor
OrgbProtAssoWith	OrgB protein, associated with InvC ATPase of type III secretion system
OrniAmin	Ornithine aminotransferase (EC 2.6.1.13)
OrniCycl	Ornithine cyclodeaminase (EC 4.3.1.12)
OrniDeca	Ornithine decarboxylase (EC 4.1.1.17)
OrniDecaAnti	Ornithine decarboxylase antizyme
OrniDecaAntiInhi	Ornithine decarboxylase antizyme inhibitor
OrniDecaEuka	Ornithine decarboxylase, eukaryotic (EC 4.1.1.17)
OrniRace	Ornithine racemase (EC 5.1.1.12)
Orot5PhosDeca	Orotidine 5'-phosphate decarboxylase (EC 4.1.1.23)
OrotPhos	Orotate phosphoribosyltransferase (EC 2.4.2.10)
OsmoInduLipoBPrec	Osmotically inducible lipoprotein B precursor
OsmoInduProtOsmy	Osmotically inducible protein OsmY
OsmoKChanHistKina	Osmosensitive K+ channel histidine kinase KdpD (EC 2.7.3.-)
OuteMembChanTolc	Outer membrane channel TolC (OpmH)
OuteMembCompTamTran	Outer membrane component of TAM transport system
OuteMembCompTrip	Outer membrane component of tripartite multidrug resistance system
OuteMembFactLipo	Outer membrane factor (OMF) lipoprotein associated wth MdtABC efflux system
OuteMembFactLipo2	Outer membrane factor (OMF) lipoprotein associated wth EmrAB-OMF efflux system
OuteMembFactOmf1n1	Outer membrane factor OMF1 associated with YbhGFSR efflux transporter
OuteMembFactOmf2n1	Outer membrane factor OMF2 associated with YbhGFSR efflux transporter
OuteMembFerrRece	Outer membrane ferripyoverdine receptor
OuteMembFerrRece2	Outer membrane ferripyoverdine receptor FpvA, TonB-dependent
OuteMembFerrRece3	Outer membrane ferripyoverdine receptor FpvB, for Type I pyoverdine
OuteMembLipoLolb2	Outer membrane lipoprotein LolB precursor
OuteMembLipoOmla	Outer membrane lipoprotein OmlA
OuteMembLipoPrec2	Outer membrane lipoprotein precursor, OmpA family
OuteMembLowPermPori	Outer membrane low permeability porin, OprD family
OuteMembLowPermPori10	Outer membrane low permeability porin, OprD family => gallic acid utilization
OuteMembLowPermPori11	Outer membrane low permeability porin, OprD family => PaaM phenylacetic acid porin
OuteMembLowPermPori13	Outer membrane low permeability porin, OprD family => OccD4/OpdT tyrosine
OuteMembLowPermPori14	Outer membrane low permeability porin, OprD family => OccK10/OpdN
OuteMembLowPermPori15	Outer membrane low permeability porin, OprD family => OccD7/OpdB proline
OuteMembLowPermPori16	Outer membrane low permeability porin, OprD family => OccD2/OpdC
OuteMembLowPermPori17	Outer membrane low permeability porin, OprD family => OccD3/OpdP Gly-Glu dipeptide
OuteMembLowPermPori18	Outer membrane low permeability porin, OprD family => OccK7/OpdD, meropenem uptake
OuteMembLowPermPori19	Outer membrane low permeability porin, OprD family => OccD5/OpdI
OuteMembLowPermPori2	Outer membrane low permeability porin, OprB family
OuteMembLowPermPori20	Outer membrane low permeability porin, OprD family => OccK3/OpdO pyroglutamate, cefotaxime uptake
OuteMembLowPermPori21	Outer membrane low permeability porin, OprD family => OccK9/OpdG
OuteMembLowPermPori22	Outer membrane low permeability porin, OprD family => OccK2/OpdF
OuteMembLowPermPori23	Outer membrane low permeability porin, OprD family => OccD8/OpdJ coexpressed with pyoverdine biosynthesis regulon
OuteMembLowPermPori24	Outer membrane low permeability porin, OprD family => OccK6/OpdQ
OuteMembLowPermPori25	Outer membrane low permeability porin, OprD family => OccK11/OpdR
OuteMembLowPermPori26	Outer membrane low permeability porin, OprD family => OccK4/OpdL
OuteMembLowPermPori27	Outer membrane low permeability porin, OprD family => OccK1/OpdK benzoate/histidine, carbenicillin and cefoxitin uptake
OuteMembLowPermPori3	Outer membrane low permeability porin, OprD family => OccD6/OprQ involved in adhesion
OuteMembLowPermPori4	Outer membrane low permeability porin, OprP/OprO family
OuteMembLowPermPori7	Outer membrane low permeability porin, OprD family => OccD1/OprD basic amino acids, carbapenem uptake
OuteMembLowPermPori8	Outer membrane low permeability porin, OprD family => OccK5/OpdH tricarboxylate
OuteMembLowPermPori9	Outer membrane low permeability porin, OprD family => OccK8/OprE anaerobically-induced
OuteMembPeriComp	Outer membrane and periplasm component of type IV secretion of T-DNA complex, has secretin-like domain, VirB9
OuteMembPhosBind	Outer-membrane-phospholipid-binding lipoprotein MlaA
OuteMembPoriCoex	Outer membrane porin, coexpressed with pyoverdine biosynthesis regulon
OuteMembPoriForChit	Outer membrane porin for chitooligosaccharides ChiP
OuteMembPoriOmpc2	Outer membrane porin OmpC
OuteMembPoriOmpf	Outer membrane porin OmpF
OuteMembPoriOmpn	Outer membrane porin OmpN
OuteMembPoriOmps	Outer membrane porin, OmpS
OuteMembPoriPhoe	Outer membrane porin PhoE
OuteMembPoriProt8	Outer membrane porin protein OmpD
OuteMembProtAsse2	Outer membrane protein assembly factor YaeT
OuteMembProtDmsf	outer membrane protein, DmsF
OuteMembProtEpo	Outer membrane protease Epo
OuteMembProtFPrec	Outer membrane protein F precursor
OuteMembProtGPrec	Outer membrane protein G precursor
OuteMembProtHPrec	Outer membrane protein H precursor
OuteMembProtImpRequ	Outer membrane protein Imp, required for envelope biogenesis
OuteMembProtMtrb	outer membrane protein, MtrB
OuteMembProtMtre	outer membrane protein, MtrE
OuteMembProtOmpk	Outer membrane protein OmpK
OuteMembProtOmpt2	Outer membrane protease OmpT
OuteMembProtPgte	Outer membrane protease PgtE
OuteMembProtPla	Outer membrane protease Pla
OuteMembProtPrec	Outer membrane protein A precursor
OuteMembProtSopa	Outer membrane protease SopA
OuteMembPyovEflu	Outer membrane pyoverdine eflux protein
OuteMembRece	Outer membrane (iron.B12.siderophore.hemin) receptor
OuteMembReceForFerr3	Outer membrane receptor for ferric enterobactin and colicins B, D
OuteMembReceForFerr4	Outer membrane receptor for ferric siderophore
OuteMembReceForFerr5	Outer membrane receptor for ferric-pyochelin FptA
OuteMembReceForFerr8	Outer membrane receptor for ferric enterobactin PfeA
OuteMembReceForFerr9	Outer membrane receptor for ferric enantio-pyochelin
OuteMembReceProt4	Outer membrane receptor proteins, likely involved in siderophore uptake
OuteMembSideRece	Outer Membrane Siderophore Receptor IroN
OuteMembTonbDepe	Outer membrane TonB-dependent transducer VreA of trans-envelope signaling system
OuteProtF	outermembrane protein F
OuteSporCoatProt	Outer spore coat protein CotE
OxalCoaDeca	Oxalyl-CoA decarboxylase (EC 4.1.1.8)
OxalDeca	Oxalate decarboxylase (EC 4.1.1.2)
OxalDeca2	Oxaloacetate decarboxylase (EC 4.1.1.3)
OxalDecaAlphChai	Oxaloacetate decarboxylase alpha chain (EC 4.1.1.3)
OxalDecaBetaChai	Oxaloacetate decarboxylase beta chain (EC 4.1.1.3)
OxalDecaGammChai	Oxaloacetate decarboxylase gamma chain (EC 4.1.1.3)
OxalDecaInvoCitr	Oxaloacetate decarboxylase involved in citrate fermentation (EC 4.1.1.3)
OxalDecaInvoCitr2	Oxaloacetate decarboxylase involved in citrate fermentation, predicted (EC 4.1.1.3)
OxalDecaOxdd	Oxalate decarboxylase oxdD (EC 4.1.1.2)
OxidAldoKetoRedu	oxidoreductase of aldo/keto reductase family, subgroup 1
OxidShorChaiDehy	Oxidoreductase, short-chain dehydrogenase/reductase family (EC 1.1.1.-)
OxidStreAntiSigm	Oxidative stress anti-sigma factor NrsF associated with perchlorate reduction
OxidStreReguProt	oxidative stress regulatory protein
OxidStreSigmFact	Oxidative stress sigma factor SigF associated with perchlorate reduction
OxidStreTranRegu	Oxidative stress transcriptional regulator (responsive to S-nitrosothiols)
OxoiDehyAlphBeta	(Pyruvate) Oxoisovalerate Dehydrogenase Alpha & Beta Fusion like
OxygReguInvaProt	Oxygen-regulated invasion protein OrgA
OxygReguInvaProt2	Oxygen-regulated invasion protein OrgB
OxytResiAbcTypeEffl	Oxytetracycline resistance, ABC-type efflux pump ATP-binding component => Otr(C)
OxytResiAbcTypeEffl2	Oxytetracycline resistance, ABC-type efflux pump permease component => Otr(C)
OxytResiMfsEfflPump	Oxytetracycline resistance, MFS efflux pump => Otr(B)
OxytResiProtOtra	Oxytetracycline resistance protein OtrA
OxytResiRiboProt	Oxytetracycline resistance, ribosomal protection type => Otr(A)
P450CytoCompGProt	P450 cytochrome, component of G-protein-coupled receptor (GPCR) system
P450CytoCompGProt2	P450 cytochrome, component of G-protein-coupled receptor (GPCR) system, second copy
P60ExtrProtInvaAsso	P60 extracellular protein, invasion associated protein Iap
PHydrHydr	P-hydroxybenzoate hydroxylase (EC 1.14.13.2)
PaadLikeProtInvo	PaaD-like protein (DUF59) involved in Fe-S cluster assembly
PantBetaAlanLiga	Pantoate--beta-alanine ligase (EC 6.3.2.1)
PantKina	Pantothenate kinase (EC 2.7.1.33)
PantKinaArch	Pantoate kinase, archaeal (EC 2.7.1.-)
PantKinaTypeIiEuka	Pantothenate kinase type II, eukaryotic (EC 2.7.1.33)
PantKinaTypeIiiCoax	Pantothenate kinase type III, CoaX-like (EC 2.7.1.33)
PantNaSymp	Pantothenate:Na+ symporter (TC 2.A.21.1.1)
ParaAminSyntAmid	Para-aminobenzoate synthase, amidotransferase component (EC 2.6.1.85)
ParaAminSyntAmin	Para-aminobenzoate synthase, aminase component (EC 2.6.1.85)
ParaCoenPqqSyntProt	Paralog of coenzyme PQQ synthesis protein C
ParaLikeMembAsso	ParA-like membrane-associated ATPase
PartMethMonoBSubu	Particulate methane monooxygenase B-subunit (EC 1.14.13.25)
PartMethMonoCSubu	Particulate methane monooxygenase C-subunit (EC 1.14.13.25)
PartMethMonoSubu	Particulate methane monooxygenase A-subunit (EC 1.14.13.25)
PartUreaCarb	Partial urea carboxylase (EC 6.3.4.6)
PartUreaCarb2n1	Partial urea carboxylase 2 (EC 6.3.4.6)
PdubLikePolyBody	PduB-like polyhedral body protein clustered with pyruvate formate-lyase
PdujLikeProtClus	PduJ-like protein clustered with pyruvate formate-lyase
PdulLikeProtClus	PduL-like protein clustered with pyruvate formate-lyase
PdutLikeProtClus	PduT-like protein clustered with pyruvate formate-lyase
PduuLikeProtClus	PduU-like protein clustered with pyruvate formate-lyase
PduvLikeProtClus	PduV-like protein clustered with pyruvate formate-lyase
PeFamiProtRv38Comp	PE family protein Rv3893c, component of Type VII secretion system ESX-2
PePgrsFamiProtAprc	PE-PGRS family protein AprC
Pect	Pectinesterase (EC 3.1.1.11)
PectDegrProtKdgf	Pectin degradation protein KdgF
PectLyas	Pectin lyase (EC 4.2.2.10)
PectLyasPrec	Pectate lyase precursor (EC 4.2.2.2)
PellBiofBiosInne	Pellicle/biofilm biosynthesis inner membrane protein PelG, MATE family transporter
PellBiofBiosInne2	Pellicle/biofilm biosynthesis inner membrane protein PelE
PellBiofBiosInne3	Pellicle/biofilm biosynthesis inner membrane protein PelD
PellBiofBiosInne4	Pellicle/biofilm biosynthesis inner membrane protein PslJ, possible O-antigen ligase
PellBiofBiosInne5	Pellicle/biofilm biosynthesis inner membrane protein PslK, MATE transporter family
PellBiofBiosInne6	Pellicle/biofilm biosynthesis inner membrane protein PslL, acetyltransferase
PellBiofBiosOute	Pellicle/biofilm biosynthesis outer membrane lipoprotein PelC
PellBiofBiosPeri	Pellicle/biofilm biosynthesis periplasmic/outer membrane lipoprotein PslD, Wza-like
PellBiofBiosPoly	Pellicle/biofilm biosynthesis polysaccharide copolymerase/tyrosine-kinase PslE, Wzc-like
PellBiofBiosProt	Pellicle/biofilm biosynthesis protein PelF, CAZy glycosyltransferase family 4
PellBiofBiosProt2	Pellicle/biofilm biosynthesis protein PelB
PellBiofBiosProt3	Pellicle/biofilm biosynthesis protein PelA, glycosyl hydrolase/deacetylase
PellBiofBiosProt4	Pellicle/biofilm biosynthesis protein PslA, polyprenyl glycosylphosphotransferase
PellBiofBiosProt5	Pellicle/biofilm biosynthesis protein PslC, CAZy glycosyltransferase family 2
PellBiofBiosProt6	Pellicle/biofilm biosynthesis protein PslF, CAZy glycosyltransferase family 4
PellBiofBiosProt7	Pellicle/biofilm biosynthesis protein PslG, CAZy glycosyltransferase family 39
PellBiofBiosProt8	Pellicle/biofilm biosynthesis protein PslH, CAZy glycosyltransferase family 4
PellBiofBiosProt9	Pellicle/biofilm biosynthesis protein PslI, CAZy glycosyltransferase family 4
PeniBindProt1a1b2	Penicillin-binding protein 1A/1B (PBP1)
PeniBindProt2n1	Penicillin-binding protein 2 (PBP-2)
PeniBindProt4Prec	penicillin-binding protein 4 precursor (EC 3.4.16.4 )
PeniBindProtPbp2n2	Penicillin-binding protein PBP2a, methicillin resistance determinant MecA, transpeptidase
PeniBindProtPbp4n1	Penicillin binding protein PBP4
PeniInseTranTran	Penicillin-insensitive transglycosylase & transpeptidase PBP-1C (EC 2.4.2.-)
PeniVAmidNotInvo	Penicillin V amidase (Pva) not involved in bile hydrolysis
PentFSynt	Pentalenolactone F synthase (EC 1.14.11.36)
PentOxyg	Pentalenene oxygenase (EC 1.14.13.133)
PentSynt2	Pentalenene synthase (EC 4.2.3.7)
PepPyruBindDomaProt	PEP/pyruvate binding domain protein
Pept	peptidase (EC 3.4.24.64 )
PeptAspMeta	Peptidyl-Asp metalloendopeptidase (EC 3.4.24.33)
PeptB	Peptidase B (EC 3.4.11.23)
PeptChaiReleFact	Peptide chain release factor 2
PeptChaiReleFact2	Peptide chain release factor 1
PeptChaiReleFact3	Peptide chain release factor N(5)-glutamine methyltransferase (EC 2.1.1.297)
PeptChaiReleFact4	Peptide chain release factor 3 (EC 4.1.1.68 )
PeptChaiReleFact5	Peptide chain release factor homolog
PeptChaiReleFact7	Peptide chain release factor 2 unshifted fragment
PeptDefo	Peptide deformylase (EC 3.5.1.88)
PeptHydrVirbInvo	Peptidoglycan hydrolase VirB1, involved in T-DNA transfer
PeptLmo0Homo	Peptidase Lmo0394 homolog
PeptLytiProtP45n1	Peptidoglycan lytic protein P45
PeptM23M37Fami	Peptidase, M23/M37 family
PeptMethSulfRedu	Peptide methionine sulfoxide reductase MsrA (EC 1.8.4.11)
PeptMethSulfRedu2	Peptide methionine sulfoxide reductase MsrB (EC 1.8.4.12)
PeptMethSulfRedu5	Peptide methionine sulfoxide reductase regulator MsrR
PeptProlCisTranIsom	Peptidyl-prolyl cis-trans isomerase ppiB (EC 5.2.1.8)
PeptProlCisTranIsom2	Peptidyl-prolyl cis-trans isomerase (EC 5.2.1.8)
PeptProlCisTranIsom3	Peptidyl-prolyl cis-trans isomerase PpiA precursor (EC 5.2.1.8)
PeptProlCisTranIsom4	Peptidyl-prolyl cis-trans isomerase PpiD (EC 5.2.1.8)
PeptProlCisTranIsom5	Peptidyl-prolyl cis-trans isomerase PpiC (EC 5.2.1.8)
PeptSyntMbte	Peptide synthetase MbtE
PeptSyntMbtf	Peptide synthetase MbtF
PeptTranPeriProt	Peptide transport periplasmic protein sapA (TC 3.A.1.5.5)
PeptTranSystAtpBind	Peptide transport system ATP-binding protein sapF (TC 3.A.1.5.5)
PeptTranSystAtpBind2	Peptide transport system ATP-binding protein SapD (TC 3.A.1.5.5)
PeptTranSystPerm	Peptide transport system permease protein sapC (TC 3.A.1.5.5)
PeptTranSystPerm2	Peptide transport system permease protein sapB (TC 3.A.1.5.5)
PeptTrnaHydr	Peptidyl-tRNA hydrolase (EC 3.1.1.29)
PeptTrnaHydrArch	Peptidyl-tRNA hydrolase, archaeal type (EC 3.1.1.29)
PercReduAsseChap	Perchlorate reductase assembly chaperone protein
PercReduReguHist	Perchlorate reduction regulatory histidine kinase PcrR
PercReduReguProt	Perchlorate reduction regulatory protein PcrS
PercReduReguProt2	Perchlorate reduction regulatory protein PcrP
PercReduSubuAlph	Perchlorate reductase subunit alpha
PercReduSubuBeta	Perchlorate reductase subunit beta
PercReduSubuGamm	Perchlorate reductase subunit gamma
PeriAlphAmyl	Periplasmic alpha-amylase (EC 3.2.1.1)
PeriAromAldeOxid	Periplasmic aromatic aldehyde oxidoreductase, molybdenum binding subunit YagR
PeriAromAldeOxid2	Periplasmic aromatic aldehyde oxidoreductase, FAD binding subunit YagS
PeriAromAldeOxid3	Periplasmic aromatic aldehyde oxidoreductase, iron-sulfur subunit YagT
PeriAromAminAcid	Periplasmic aromatic amino acid aminotransferase beta precursor (EC 2.6.1.57)
PeriCTypeCytoDmse	periplasmic c-type cytochrome, DmsE
PeriChorMutaIPrec	Periplasmic chorismate mutase I precursor (EC 5.4.99.5)
PeriDecaCytoCMtra	periplasmic decaheme cytochrome c, MtrA
PeriDecaCytoCMtrd	periplasmic decaheme cytochrome c, MtrD
PeriDimeLyasDddy	Periplasmic dimethylsulfoniopropionate lyase DddY
PeriDivaCatiTole	Periplasmic divalent cation tolerance protein cutA
PeriEsteIroe	Periplasmic esterase IroE
PeriFefeHydrLarg	Periplasmic [FeFe] hydrogenase large subunit (EC 1.12.7.2)
PeriFefeHydrSmal	Periplasmic [FeFe] hydrogenase small subunit (EC 1.12.7.2)
PeriFumaReduFcca	periplasmic fumarate reductase, FccA (EC 1.3.99.1)
PeriHemiBindProt	Periplasmic hemin-binding protein
PeriHynaTypeCyct	Periplasmic HynAB-type cyctochrome-c3 [NiFe] hydrogenase, large subunit (EC 1.12.2.1)
PeriHynaTypeCyct2	Periplasmic HynAB-type cyctochrome-c3 [NiFe] hydrogenase, small subunit (EC 1.12.2.1)
PeriHysaTypeCyct	Periplasmic HysAB-type cyctochrome-c3 [NiFeSe] hydrogenase, small subunit (EC 1.12.2.1)
PeriHysaTypeCyct2	Periplasmic HysAB-type cyctochrome-c3 [NiFeSe] hydrogenase, large subunit (EC 1.12.2.1)
PeriMolyBindDoma	Periplasmic molybdate-binding domain
PeriMurePeptBind	Periplasmic Murein Peptide-Binding Protein MppA
PeriNitrReduComp	Periplasmic nitrate reductase component NapD
PeriNitrReduComp2	Periplasmic nitrate reductase component NapE
PeriNitrReduPrec	Periplasmic nitrate reductase precursor (EC 1.7.99.4)
PeriPentElecTran	periplasmic pentaheme electron-transfer protein, NrfB
PeriProtP19InvoHigh	Periplasmic protein p19 involved in high-affinity Fe2+ transport
PeriProtTort	Periplasmic protein TorT
PeriThioDisuInte	Periplasmic thiol:disulfide interchange protein DsbA
PeriThioDisuInte2	Periplasmic thiol:disulfide interchange protein, DsbA-like
PeriThioDisuOxid	Periplasmic thiol:disulfide oxidoreductase DsbB, required for DsbA reoxidation
PermMajoFaciSupe5	Permease of the major facilitator superfamily in achromobactin biosynthesis operon
PermMajoFaciSupe7	Permease of the major facilitator superfamily in uncharacterized siderophore S biosynthesis operon
Pero2	Peroxidase (EC 1.11.1.7)
PeroStreRegu	Peroxide stress regulator
PeroStreReguPerr	Peroxide stress regulator PerR, FUR family
PeroUreiAmidRutb	Peroxyureidoacrylate/ureidoacrylate amidohydrolase RutB (EC 3.5.1.110)
PertToxiSubu1Prec	Pertussis toxin subunit 1 precursor (NAD-dependent ADP-ribosyltransferase) (EC 2.4.2.-)
PertToxiSubu2Prec	Pertussis toxin subunit 2 precursor (PTX S2)
PertToxiSubu3Prec	Pertussis toxin subunit 3 precursor (PTX S3)
PertToxiSubu4Prec	Pertussis toxin subunit 4 precursor (PTX S4)
PertToxiSubu5Prec	Pertussis toxin subunit 5 precursor (PTX S5)
Pf00FamiFadDepeNad	PF00070 family, FAD-dependent NAD(P)-disulphide oxidoreductase
PfamAcylDoma	pfam01757 acyltransferase domain
PhagHeadProtSaBact	Phage head protein [SA bacteriophages 11, Mu50B]
PhagHollJuncReso	Phage Holliday junction resolvase
PhagIntePhagP4Asso	Phage integrase, Phage P4-associated
PhagShocProt	Phage shock protein A
PhagShocProtB	Phage shock protein B
PhagShocProtC	Phage shock protein C
PhagShocProtD	Phage shock protein D
PhagTermLargSubu4	Phage terminase, large subunit [SA bacteriophages 11, Mu50B]
PhagTermSmalSubu8	Phage terminase, small subunit [SA bacteriophages 11, Mu50B]
Phen4Hydr	Phenylalanine-4-hydroxylase (EC 1.14.16.1)
PhenAcidDegrOper	Phenylacetic acid degradation operon negative regulatory protein PaaX
PhenAcidDegrProt2	Phenylacetic acid degradation protein PaaY
PhenAcidDegrProt8	Phenylacetic acid degradation protein PaaN2, ring-opening aldehyde dehydrogenase (EC 1.2.1.3)
PhenBiosProtPhza	Phenazine biosynthesis protein PhzA
PhenBiosProtPhzb	Phenazine biosynthesis protein PhzB
PhenBiosProtPhzf	Phenazine biosynthesis protein PhzF like
PhenCoaHydr	Phenylitaconyl-CoA hydratase (EC 4.2.1.-)
PhenCoaOxygPaahSubu2	Phenylacetate-CoA oxygenase, PaaH2 subunit
PhenCoenLiga	Phenylacetate-coenzyme A ligase (EC 6.2.1.30)
PhenDehy	Phenylacetaldehyde dehydrogenase (EC 1.2.1.39)
PhenHydrAsseProt	Phenol hydroxylase, assembly protein DmpK
PhenHydrFad2fe2s	Phenol hydroxylase, FAD- and [2Fe-2S]-containing reductase component DmpP
PhenHydrP1OxygComp	Phenol hydroxylase, P1 oxygenase component DmpL (EC 1.14.13.7)
PhenHydrP2ReguComp	Phenol hydroxylase, P2 regulatory component DmpM (EC 1.14.13.7)
PhenHydrP3OxygComp	Phenol hydroxylase, P3 oxygenase component DmpN (EC 1.14.13.7)
PhenHydrP4OxygComp	Phenol hydroxylase, P4 oxygenase component DmpO (EC 1.14.13.7)
PhenModiProtPhzh	Phenazine modifying protein PhzH
PhenSpecMethPhzm	Phenazine-specific methyltransferase PhzM
PhenSyntMycoSide	Phenyloxazoline synthase [mycobactin] siderophore (EC 6.3.2.-)
PhenSyntPolySynt	Phenolpthiocerol synthesis polyketide synthase PpsA
PhenSyntSideIrp2n1	Phenyloxazoline synthase siderophore, Irp2-like
PhenSyntTypeIPoly	Phenolpthiocerol synthesis type-I polyketide synthase PpsD
PhenSyntTypeIPoly2	PHENOLPTHIOCEROL SYNTHESIS TYPE-I POLYKETIDE SYNTHASE PPSC
PhenSyntTypeIPoly4	PhenolpthIocerol synthesis type-i polyketide synthase ppse
PhenSyntTypeIPoly5	Phenolpthiocerol synthesis type-I polyketide synthase PpsB (EC 2.3.1.41)
PhenSyntTypeIPoly6	Phenolpthiocerol synthesis type-I polyketide synthase PpsA (EC 2.3.1.41)
PhenTrnaSyntAlph	Phenylalanyl-tRNA synthetase alpha chain (EC 6.1.1.20)
PhenTrnaSyntAlph4	Phenylalanyl-tRNA synthetase alpha chain, mitochondrial (EC 6.1.1.20)
PhenTrnaSyntAlph6	Phenylalanyl-tRNA synthetase alpha chain, chloroplast (EC 6.1.1.20)
PhenTrnaSyntBeta	Phenylalanyl-tRNA synthetase beta chain (EC 6.1.1.20)
PhenTrnaSyntBeta4	Phenylalanyl-tRNA synthetase beta chain, mitochondrial (EC 6.1.1.20)
PhenTrnaSyntBeta5	Phenylalanyl-tRNA synthetase beta chain, chloroplast (EC 6.1.1.20)
PhenTrnaSyntDoma	Phenylalanyl-tRNA synthetase domain protein (Bsu YtpR)
PhenTrnaSyntMito	Phenylalanyl-tRNA synthetase, mitochondrial (EC 6.1.1.20)
Pheo	Pheophorbidase (EC 3.1.1.82)
PheoOxyg	Pheophorbide a oxygenase (EC 1.14.-.-)
PherCad1PrecLipo	Pheromone cAD1 precursor lipoprotein Cad
PherRespSurfProt	Pheromone response surface protein PrgC
Phi11Orf3HomoSaBact	phi 11 orf36 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf3HomoSaBact2	phi 11 orf37 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf3HomoSaBact3	phi 11 orf38 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf3HomoSaBact4	phi 11 orf33 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf3HomoSaBact5	phi 11 orf31 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf3HomoSaBact6	phi 11 orf32 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf3HomoSaBact7	phi 11 orf35 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf3HomoSaBact8	phi 11 orf39 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf4HomoSaBact	phi 11 orf40 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf4HomoSaBact2	phi 11 orf41 homolog [SA bacteriophages 11, Mu50B]
Phi11Orf4HomoSaBact3	phi 11 orf43 homolog [SA bacteriophages 11, Mu50B]
PhohLikeProt	PhoH-like protein
Phos12	Phosphoribulokinase (EC 2.7.1.19)
Phos2	Phosphomannomutase (EC 5.4.2.8)
Phos3	Phosphopentomutase (EC 5.4.2.7)
Phos4	Phosphatidylglycerophosphatase A (EC 3.1.3.27)
Phos5AminCarbRibo	Phosphoribosylformimino-5-aminoimidazole carboxamide ribotide isomerase (EC 5.3.1.16)
Phos6	Phosphoglucomutase (EC 5.4.2.2)
PhosAbcTranAtpBind3	Phospholipid ABC transporter ATP-binding protein MlaF
PhosAbcTranAtpBind5	Phosphonate ABC transporter ATP-binding protein PtxA (TC 3.A.1.9.1)
PhosAbcTranBindProt	Phospholipid ABC transporter-binding protein MlaB
PhosAbcTranPeriPhos	Phosphate ABC transporter, periplasmic phosphate-binding protein PstS (TC 3.A.1.7.1)
PhosAbcTranPermProt3	Phospholipid ABC transporter permease protein MlaE
PhosAbcTranPermProt5	Phosphonate ABC transporter permease protein PtxC (TC 3.A.1.9.1)
PhosAbcTranShutProt	Phospholipid ABC transporter shuttle protein MlaC
PhosAbcTranSubsBind2	Phospholipid ABC transporter substrate-binding protein MlaD
PhosAbcTranSubsBind3	Phosphonate ABC transporter substrate-binding protein PtxB (TC 3.A.1.9.1)
PhosAcet	Phosphate acetyltransferase (EC 2.3.1.8)
PhosAcetEthaUtil	Phosphate acetyltransferase, ethanolamine utilization-specific (EC 2.3.1.8)
PhosAcylAcpAcylPlsx	Phosphate:acyl-ACP acyltransferase PlsX (EC 2.3.1.n2)
PhosAden	Phosphopantetheine adenylyltransferase (EC 2.7.7.3)
PhosAdenTypeIiEuka	Phosphopantetheine adenylyltransferase, type II eukaryotic (EC 2.7.7.3)
PhosAlphMann	Phosphatidylinositol alpha-mannosyltransferase (EC 2.4.1.57)
PhosAmin	Phosphoserine aminotransferase (EC 2.6.1.52)
PhosAmin2	Phosphonoalanine aminotransferase
PhosAmpCycl	Phosphoribosyl-AMP cyclohydrolase (EC 3.5.4.19)
PhosAtpPyro	Phosphoribosyl-ATP pyrophosphatase (EC 3.6.1.31)
PhosB	Phosphatidylglycerophosphatase B (EC 3.1.3.27)
PhosBindDingProt	Phosphate-binding DING protein (related to PstS)
PhosButy	Phosphate butyryltransferase (EC 2.3.1.19)
PhosCarb	Phosphoenolpyruvate carboxylase (EC 4.1.1.31)
PhosCarb6	Phosphoribosylaminoimidazole carboxylase (EC 4.1.1.21)
PhosCarbArch	Phosphoenolpyruvate carboxylase, archaeal (EC 4.1.1.31)
PhosCarbAtp	Phosphoenolpyruvate carboxykinase [ATP] (EC 4.1.1.49)
PhosCarbGtp	Phosphoenolpyruvate carboxykinase [GTP] (EC 4.1.1.32)
PhosColaAcid	Phosphomannomutase => Colanic acid (EC 5.4.2.8)
PhosCyclLiga	Phosphoribosylformylglycinamidine cyclo-ligase (EC 6.3.3.1)
PhosCyti	Phosphatidate cytidylyltransferase (EC 2.7.7.41)
PhosDeca	Phosphopantothenoylcysteine decarboxylase (EC 4.1.1.36)
PhosDeca2	Phosphatidylserine decarboxylase (EC 4.1.1.65)
PhosDeca3	Phosphonopyruvate decarboxylase (EC 4.1.1.82)
PhosDeca4	Phosphomevalonate decarboxylase (EC 4.1.1.99)
PhosDecaAlphSubu	Phosphonopyruvate decarboxylase, alpha subunit (EC 4.1.1.82)
PhosDecaBetaSubu	Phosphonopyruvate decarboxylase, beta subunit (EC 4.1.1.82)
PhosDehy	Phosphogluconate dehydratase (EC 4.2.1.12)
PhosDehy2	Phosphonate dehydrogenase (EC 1.20.1.1)
PhosDephCoaTran	Phosphoribosyl-dephospho-CoA transferase (EC 2.7.7.-)
PhosDihyPhosAdpBind	Phosphoenolpyruvate-dihydroxyacetone phosphotransferase, ADP-binding subunit DhaL (EC 2.7.1.121)
PhosDihyPhosDihy	Phosphoenolpyruvate-dihydroxyacetone phosphotransferase, dihydroxyacetone binding subunit DhaK (EC 2.7.1.121)
PhosDihyPhosOper	Phosphoenolpyruvate-dihydroxyacetone phosphotransferase operon regulatory protein DhaR
PhosDihyPhosSubu	Phosphoenolpyruvate-dihydroxyacetone phosphotransferase, subunit DhaM (EC 2.7.1.121)
PhosForm	Phosphoribosylglycinamide formyltransferase (EC 2.1.2.2)
PhosForm2	Phosphoribosylaminoimidazolecarboxamide formyltransferase (EC 2.1.2.3)
PhosForm2n1	Phosphoribosylglycinamide formyltransferase 2 (EC 2.1.2.-)
PhosGlycLiga	Phosphoribosylamine--glycine ligase (EC 6.3.4.13)
PhosHomoFuncUnkn	Phosphoribulokinase homolog, function unknown (EC 2.7.1.19)
PhosHydr	Phosphonoacetate hydrolase (EC 3.11.1.2)
PhosHydr2	Phosphonoacetaldehyde hydrolase (EC 3.11.1.1)
PhosHydr3	Phosphonopyruvate hydrolase (EC 3.11.1.3)
PhosInvoMycoCyto	Phosphoribohydrolase involved in Mycobacterial cytokinins production, homolog of plant cytokinin-activating enzyme LOG
PhosInvoThreTA37n1	Phosphotransferase involved in threonylcarbamoyladenosine t(6)A37 formation in tRNA
PhosIsom	Phosphoribosylanthranilate isomerase (EC 5.3.1.24)
PhosKina	Phosphoglycerate kinase (EC 2.7.2.3)
PhosKina2	Phosphomevalonate kinase (EC 2.7.4.2)
PhosLeciHemo	Phospholipase/lecithinase/hemolysin
PhosLikeProtPhp	Phosphotriesterase like protein Php
PhosLikeProtYhfw	Phosphopentomutase like protein YhfW
PhosMuta	Phosphoglycerate mutase (EC 5.4.2.1)
PhosMuta2	Phosphoglucosamine mutase (EC 5.4.2.10)
PhosMutaArchType	Phosphoglycerate mutase (2,3-diphosphoglycerate-independent), archaeal type (EC 5.4.2.12)
PhosMutaFami	Phosphoglycerate mutase family
PhosMutaFami1n1	Phosphoglycerate mutase family 1
PhosMutaFami2	Phosphoglycerate mutase family (Rhiz)
PhosMutaFami2n1	Phosphoglycerate mutase family 2
PhosMutaFami3n1	Phosphoglycerate mutase family 3
PhosMutaFami4n1	Phosphoglycerate mutase family 4
PhosMutaFami5n1	Phosphoglycerate mutase family 5
PhosMutaFamiLmo0n1	Phosphoglycerate mutase family, Lmo0907 homolog
PhosMutaFamiLmo0n2	Phosphoglycerate mutase family, Lmo0556 homolog
PhosNAcetPentTran	Phospho-N-acetylmuramoyl-pentapeptide-transferase (EC 2.7.8.13)
PhosNMeth	Phosphatidylethanolamine N-methyltransferase (EC 2.1.1.17)
PhosPhos2	Phosphoglycolate phosphatase (EC 3.1.3.18)
PhosPhos4	Phosphoenolpyruvate phosphomutase (EC 5.4.2.9)
PhosPhosAbcTranAtp	Phosphonoalanine and/or phosphonopyruvate ABC transporter ATP-binding protein
PhosPhosAbcTranPeri	Phosphonoalanine and/or phosphonopyruvate ABC transporter periplasmic binding component
PhosPhosAbcTranPerm	Phosphonoalanine and/or phosphonopyruvate ABC transporter permease protein
PhosPhosArchType	Phosphoglycolate phosphatase, archaeal type (EC 3.1.3.18)
PhosPhosRsbx	Phosphoserine phosphatase RsbX (EC 3.1.3.3)
PhosPhosSynt	Phosphatidylinositol phosphate synthase
PhosPhosUtilRegu	Phosphonoalanine and phosphonopyruvate utilization regulatory protein, LysR family
PhosProp	Phosphate propanoyltransferase (EC 2.3.1.222)
PhosProtLuxu	Phosphorelay protein LuxU
PhosProtNitrRegu	Phosphocarrier protein, nitrogen regulation associated
PhosPyroSpecOute	Phosphate/pyrophosphate-specific outer membrane porin OprP/OprO
PhosRapcReguPhrc	Phosphatase RapC regulator PhrC, competence and sporulation stimulating factor (CSF)
PhosRcsd	Phosphotransferase RcsD
PhosReguMetaIonTran	Phosphate regulon metal ion transporter containing CBS domains
PhosReguSensProt	Phosphate regulon sensor protein PhoR (SphS) (EC 2.7.13.3)
PhosReguTranRegu	Phosphate regulon transcriptional regulatory protein PhoB (SphR)
PhosSpecOuteMemb	Phosphate-specific outer membrane porin OprP
PhosSpecPhosC	Phosphatidylinositol-specific phospholipase C (EC 4.6.1.13)
PhosStarInduProt	Phosphate starvation-inducible protein PhoH, predicted ATPase
PhosSuccSynt	Phosphoribosylaminoimidazole-succinocarboxamide synthase (EC 6.3.2.6)
PhosSulfReduThio	Phosphoadenylyl-sulfate reductase [thioredoxin] (EC 1.8.4.8)
PhosSynt	Phosphopantothenoylcysteine synthetase (EC 6.3.2.5)
PhosSynt2	Phosphoenolpyruvate synthase (EC 2.7.9.2)
PhosSynt5	Phosphosulfolactate synthase (EC 4.4.1.19)
PhosSyntArch	Phosphopantothenate synthetase, archaeal (EC 6.3.2.36)
PhosSyntGlutAmid	Phosphoribosylformylglycinamidine synthase, glutamine amidotransferase subunit (EC 6.3.5.3)
PhosSyntPursSubu	Phosphoribosylformylglycinamidine synthase, PurS subunit (EC 6.3.5.3)
PhosSyntReguProt	Phosphoenolpyruvate synthase regulatory protein
PhosSyntSyntSubu	Phosphoribosylformylglycinamidine synthase, synthetase subunit (EC 6.3.5.3)
PhosSystPhosProt	Phosphotransferase system, phosphocarrier protein HPr
PhosTranAtpBindProt	Phosphate transport ATP-binding protein PstB (TC 3.A.1.7.1)
PhosTranCompBruc	Phosphopantetheinyl transferase component of [brucebactin] siderophore synthetase (EC 2.7.8.-)
PhosTranCompSide	Phosphopantetheinyl transferase component of siderophore synthetase (EC 2.7.8.-)
PhosTranSystPerm	Phosphate transport system permease protein PstA (TC 3.A.1.7.1)
PhosTranSystPerm2	Phosphate transport system permease protein PstC (TC 3.A.1.7.1)
PhosTranSystRegu	Phosphate transport system regulatory protein PhoU
PhosUptaMetaRegu	Phosphonate uptake and metabolism regulator, LysR-family
PhotI48kProt	photosystem I 4.8K protein (PsaX)
PhotIAsseRelaProt	photosystem I assembly related protein Ycf3
PhotIAsseRelaProt2	photosystem I assembly related protein Ycf4
PhotIAsseRelaProt3	photosystem I assembly related protein Ycf37
PhotIBiogProtBtpa	photosystem I biogenesis protein BtpA
PhotIIronSulfCent2	Photosystem I iron-sulfur center (EC 1.97.1.12)
PhotIP700ChloApop	photosystem I P700 chlorophyll a apoprotein subunit Ia (PsaA)
PhotIP700ChloApop2	photosystem I P700 chlorophyll a apoprotein subunit Ib (PsaB)
PhotISubuIi	photosystem I subunit II (PsaD)
PhotISubuIiiPrec	photosystem I subunit III precursor, plastocyanin (cyt c553) docking protein (PsaF)
PhotISubuIv	photosystem I subunit IV (PsaE)
PhotISubuIx	photosystem I subunit IX (PsaJ)
PhotISubuPsag	photosystem I subunit PsaG
PhotISubuPsan	photosystem I subunit PsaN
PhotISubuPsao	photosystem I subunit PsaO
PhotISubuPsap	photosystem I subunit PsaP
PhotISubuVi	photosystem I subunit VI (PsaH)
PhotISubuViii	photosystem I subunit VIII (PsaI)
PhotISubuX	photosystem I subunit X (PsaK, PsaK1)
PhotISubuXi	photosystem I subunit XI (PsaL)
PhotISubuXii	photosystem I subunit XII (PsaM)
PhotIi10KdaPhos	Photosystem II 10 kDa phosphoprotein (PsbH)
PhotIi10KdaProtPsbr	Photosystem II 10 kDa protein PsbR
PhotIi12KdaExtrProt	Photosystem II 12 kDa extrinsic protein (PsbU)
PhotIi13KdaProtPsb2n2	Photosystem II 13 kDa protein Psb28 (similar to PsbW)
PhotIiCp22ProtPsbs	Photosystem II CP22 protein PsbS
PhotIiCp43Prot	Photosystem II CP43 protein (PsbC)
PhotIiCp47Prot	Photosystem II CP47 protein (PsbB)
PhotIiMangStabProt	Photosystem II manganese-stabilizing protein (PsbO)
PhotIiOxygEvolComp	Photosystem II oxygen evolving complex protein PsbP
PhotIiOxygEvolComp2	Photosystem II oxygen evolving complex protein PsbQ
PhotIiProtD1n1	photosystem II protein D1 (PsbA)
PhotIiProtD2n1	photosystem II protein D2 (PsbD)
PhotIiProtPsb2n1	Photosystem II protein Psb27
PhotIiProtPsbi	Photosystem II protein PsbI
PhotIiProtPsbj	Photosystem II protein PsbJ
PhotIiProtPsbk	Photosystem II protein PsbK
PhotIiProtPsbl	Photosystem II protein PsbL
PhotIiProtPsbm	Photosystem II protein PsbM
PhotIiProtPsbn	Photosystem II protein PsbN
PhotIiProtPsbt2	Photosystem II protein PsbTc
PhotIiProtPsbt3	Photosystem II protein PsbTn
PhotIiProtPsbvCyto	Photosystem II protein PsbV, cytochrome c550
PhotIiProtPsbw	Photosystem II protein PsbW (similar to Psb28)
PhotIiProtPsbx	Photosystem II protein PsbX
PhotIiProtPsby	Photosystem II protein PsbY
PhotIiProtPsbz	Photosystem II protein PsbZ
PhotIiStabAsseFact	Photosystem II stability/assembly factor HCF136/Ycf48
PhotP840ReacCent	Photosystem P840 reaction center subunit PscD
PhotP840ReacCent2	Photosystem P840 reaction center large subunit PscA
PhotP840ReacCent3	Photosystem P840 reaction center iron-sulfur subunit PscB
PhotP840ReacCent4	Photosystem P840 reaction center subunit PscC, cytochrome c-551
PhotReacCentCyto	Photosynthetic reaction center cytochrome c subunit
PhotReacCentHSubu	Photosynthetic reaction center H subunit
PhotReacCentLSubu	Photosynthetic reaction center L subunit
PhotReacCentMSubu	Photosynthetic reaction center M subunit
PhraInhiActiPhos	PhrA, inhibitor of the activity of phosphatase RapA
PhreReguActiPhos	PhrE, regulator of the activity of phosphatase RapE
PhrfReguActiPhos	PhrF, regulator of the activity of phosphatase RapF
PhrgReguActiPhos	PhrG, regulator of the activity of phosphatase RapG
PhrhReguActiPhos	PhrH, regulator of the activity of phosphatase RapH
PhriReguActiPhos	PhrI, regulator of the activity of phosphatase RapI
PhrkReguActiPhos	PhrK, regulator of the activity of phosphatase RapK
PhthPhthDimyTran	Phthiocerol/phthiodiolone dimycocerosyl transferase PapA5 (EC 2.3.1.-)
PhycFerrOxidPcya	Phycocyanobilin:ferredoxin oxidoreductase PcyA (EC 1.3.7.5)
PhylSpecIsocSynt	Phylloquinone-specific isochorismate synthase (EC 5.4.4.2)
PhytDehy	Phytoene dehydrogenase (EC 1.14.99.-)
PhytKina	Phytol kinase (EC 2.7.1.-)
PhytKina3	Phytolphosphate kinase
PhytSynt	Phytoene synthase (EC 2.5.1.32)
PhytSyntBactType	Phytochelatin synthase, bacterial type (EC 2.3.2.15)
PhytSyntEukaType	Phytochelatin synthase, eukaryotic type (EC 2.3.2.15)
PiliRetrProtPilt	Pili retraction protein pilT
PilsCass	PilS cassette
PilzDomaContProt	PilZ domain-containing protein associated with flagellar synthesis TM0905
PimeAcylCarrProt	Pimeloyl-[acyl-carrier protein] methyl ester esterase BioH (EC 3.1.1.85)
PimeAcylCarrProt3	Pimeloyl-[acyl-carrier protein] methyl ester esterase BioK (EC 3.1.1.85)
PimeAcylCarrProt4	Pimeloyl-[acyl-carrier protein] methyl ester esterase BioG (EC 3.1.1.85)
PimeCoaSynt	Pimeloyl-CoA synthase (EC 6.2.1.14)
PiriRelaProtCoex	Pirin-related protein, coexpressed with pyoverdine biosynthesis regulon
PlanBiosProtPlno	plantaricin biosynthesis protein PlnO
PlanBiosProtPlnq	plantaricin biosynthesis protein PlnQ
PlanBiosProtPlnr	plantaricin biosynthesis protein PlnR
PlanBiosProtPlns	plantaricin biosynthesis protein PlnS
PlanBiosProtPlnx	plantaricin biosynthesis protein PlnX (putative)
PlanBiosProtPlny	plantaricin biosynthesis protein PlnY (putative)
PlanInduProtPinf	Plant-inducible protein PinF2, cytochrome P450-like, contributes to virulence
PlanInduProtPinf2	Plant-inducible protein PinF1, cytochrome P450-like, contributes to virulence
Plas	Plastocyanin
PlasConjTranDnaHeli	Plasmid conjugative transfer DNA helicase TrhI
PlasConjTranEndo	Plasmid conjugative transfer endonuclease
PlasMembThiaTran	Plasma membrane thiamine transporter (Vertebrata)
PlasReplProtRepa	plasmid replication protein RepA
PlasReplProtRepb	Plasmid replication protein RepB
PlasReplProtRepc	Plasmid replication protein RepC
PlcrActiProtPapr	PlcR activating protein PapR, quorum-sensing effector
Poly	Polygalacturonase (EC 3.2.1.15)
PolyAlcoDehyPqqDepe	Polyvinyl-alcohol dehydrogenase, PQQ-dependent (EC 1.1.99.23)
PolyAlphGlucGfta	Poly(glycerol-phosphate) alpha-glucosyltransferase GftA (EC 2.4.1.52)
PolyBindProt	Polysulfide binding protein
PolyBindTranDoma	Polysulfide binding and transferase domain
PolyBiosMaloAcpDeca	Polyketide biosynthesis malonyl-ACP decarboxylase PksF (EC 4.1.1.87)
PolyC5EpimAlgg	Poly (beta-D-mannuronate) C5 epimerase AlgG (EC 5.1.3.-)
PolyCyclDehyLipi	Polyketide cyclase/dehydrase/lipid transport
PolyDAlanTranProt	Poly(glycerophosphate chain) D-alanine transfer protein DltD
PolyExpoLipoWza2	Polysaccharide export lipoprotein => Wza
PolyFormBact	Polymer-forming bactofilin
PolyGammGlutSynt2	Poly-gamma-glutamate synthase subunit PgsC/CapC (EC 6.3.2.-)
PolyGammGlutSynt3	Poly-gamma-glutamate synthase subunit PgsB/CapB (EC 6.3.2.-)
PolyGammGlutSynt5	Poly-gamma-glutamate synthase subunit PgsA/CapA (EC 6.3.2.-)
PolyGammGlutSynt6	Poly-gamma-glutamate synthase subunit PgsE/CapE (EC 6.3.2.-)
PolyGluc	Polyphosphate glucokinase (EC 2.7.1.63)
PolyInteAdheBios	Polysaccharide intercellular adhesin (PIA) biosynthesis deacetylase IcaB (EC 3.-.-.-)
PolyInteAdheBios2	Polysaccharide intercellular adhesin (PIA) biosynthesis N-glycosyltransferase IcaA (EC 2.4.-.-)
PolyInteAdheBios3	Polysaccharide intercellular adhesin (PIA) biosynthesis protein IcaC
PolyInteAdheBios4	Polysaccharide intercellular adhesin (PIA) biosynthesis protein IcaD
PolyKina	Polyphosphate kinase (EC 2.7.4.1)
PolyNaph	Polyferredoxin NapH (periplasmic nitrate reductase)
PolyNucl	Polyribonucleotide nucleotidyltransferase (EC 2.7.7.8)
PolyPhosNAcetSynt	Polyprenyl-phospho-N-acetylgalactosaminyl synthase PpgS
PolyPoly	Poly(A) polymerase (EC 2.7.7.19)
PolyReduPsraMoly	Polysulfide reductase PsrA, molybdoperterin-binding subunit (EC 1.12.98.4)
PolyReduPsrbFeSSubu	Polysulfide reductase PsrB, Fe-S subunit (EC 1.12.98.4)
PolyReduPsrcAnch	Polysulfide reductase PsrC, anchor subunit (EC 1.12.98.4)
PolyResiProtArnc	Polymyxin resistance protein ArnC, glycosyl transferase (EC 2.4.-.-)
PolyResiProtArnt	Polymyxin resistance protein ArnT, undecaprenyl phosphate-alpha-L-Ara4N transferase
PolyResiProtPmrg	Polymyxin resistance protein PmrG
PolyResiProtPmrj	Polymyxin resistance protein PmrJ, predicted deacetylase
PolySynt	Polyketide synthase
PolySyntMbtc	Polyketide synthetase MbtC
PolySyntMbtd	Polyketide synthetase MbtD
PoriOmpl	Porin OmpL
PorpDeam	Porphobilinogen deaminase (EC 2.5.1.61)
PorpSynt	Porphobilinogen synthase (EC 4.2.1.24)
PortProtBactA118n1	Portal protein [Bacteriophage A118]
PosiReguLIdonCata	Positive regulator of L-idonate catabolism
PosiReguPhenHydr2	Positive regulator of phenol hydroxylase, DmpR
PosiTranReguEvga	Positive transcription regulator EvgA
Poss25Diam6RiboPyri	Possibly 2,5-diamino-6-ribosylamino-pyrimidinone 5-phosphate reductase, fungal
PossAbcTranPeriSubs	Possible ABC transporter, periplasmic substrate X binding protein precursor
PossHAntiClusWith	Possible H+-antiporter clustered with aerobactin genes
PossHydrAcylRutd	Possible hydrolase or acyltransferase RutD in novel pyrimidine catabolism pathway
PossHypoOxidXdhd	Possible hypoxanthine oxidase XdhD (EC 1.-.-.-)
PossLipoThir	Possible lipoprotein thiredoxin
PossMethClusWith	POSSIBLE METHYLTRANSFERASE CLUSTERED WITH NadR
PossPeriThir	Possible periplasmic thiredoxin
PossReguProtSimi	Possible regulatory protein similar to urea ABC transporter, substrate binding protein
PossRubiChapRbcx	Possible RuBisCo chaperonin RbcX
PossSterDesa	Possible sterol desaturase
PossSubuVariPhos	Possible subunit variant of phosphoribosylaminoimidazolecarboxamide formyltransferase [alternate form]
PossTetrMethDoma	possible tetrapyrrole methyltransferase domain
PossThirSubuVari	Possible third subunit-variant of phosphoribosylaminoimidazolecarboxamide formyltransferase [alternate form]
PotaTranAtpaBChai	Potassium-transporting ATPase B chain (TC 3.A.3.7.1) (EC 3.6.3.12)
PotaTranAtpaCChai	Potassium-transporting ATPase C chain (TC 3.A.3.7.1) (EC 3.6.3.12)
PotaTranAtpaChai	Potassium-transporting ATPase A chain (TC 3.A.3.7.1) (EC 3.6.3.12)
PotaUptaProtInte4	Potassium uptake protein, integral membrane component, KtrC
PoteMolyPterBind	Potential molybdenum-pterin-binding-protein ModG
PpBindFamiProtRv01n1	pp-binding family protein Rv0100
PpeFamiProt	PPE family protein
PpeFamiProtRv02Comp	PPE family protein Rv0286, component of Type VII secretion system ESX-3
PpeFamiProtRv38Comp	PPE family protein Rv3892c, component of Type VII secretion system ESX-2
PqqDepeOxidGdhbFami	PQQ-dependent oxidoreductase, gdhB family
PqqcLikeProt	PqqC-like protein
PqsBiosProtPqsaAnth	PQS biosynthesis protein PqsA, anthranilate-CoA ligase (EC 6.2.1.32)
PqsBiosProtPqsbSimi	PQS biosynthesis protein PqsB, similar to 3-oxoacyl-[acyl-carrier-protein] synthase III
PqsBiosProtPqscSimi	PQS biosynthesis protein PqsC, similar to 3-oxoacyl-[acyl-carrier-protein] synthase III
PqsBiosProtPqshSimi	PQS biosynthesis protein PqsH, similar to FAD-dependent monooxygenases
PqseQuinSignResp	PqsE, quinolone signal response protein
Preb	Prebacteriocin
Prec2CMeth	Precorrin-2 C(20)-methyltransferase (EC 2.1.1.130)
Prec2Oxid	Precorrin-2 oxidase (EC 1.3.1.76)
Prec3bCMeth	Precorrin-3B C(17)-methyltransferase (EC 2.1.1.131)
Prec3bSynt	precorrin-3B synthase (EC 1.14.13.83)
Prec3bSyntCobzC	Precorrin-3B synthase CobZ.C
Prec3bSyntCobzN	Precorrin-3B synthase CobZ.N
Prec4CMeth	Precorrin-4 C(11)-methyltransferase (EC 2.1.1.133)
Prec6aRedu	Precorrin-6A reductase (EC 1.3.1.54)
Prec6aSynt	Precorrin-6A synthase (deacetylating) (EC 2.1.1.152)
Prec6yCMethDeca	Precorrin-6Y C(5,15)-methyltransferase [decarboxylating] (EC 2.1.1.132)
Prec8xMeth	Precorrin-8X methylmutase (EC 5.4.99.61)
Pred2Keto3DeoxResp	Predicted 2-keto-3-deoxygluconate-responsive regulator of glucuronate utilization, IclR family
Pred4DeoxLThre5Hexo	predicted 4-deoxy-L-threo-5-hexosulose-uronate ketol-isomerase (EC 5.3.1.17)
Pred4HydrDipe	Predicted 4-hydroxyproline dipeptidase
PredAlphRiba5Phos	Predicted alpha-ribazole-5-phosphate synthase CblS for cobalamin biosynthesis
PredAlteDeacEcto	Predicted alternative deacetylase in ectoine utilization (replaces DoeB)
PredAlteGlutSynt	Predicted alternative glutathione synthetase (EC 6.3.2.3)
PredAtpaWithChap	Predicted ATPase with chaperone activity, associated with Flp pilus assembly
PredBioaAlteProt	Predicted BioA alternative protein
PredBiotReguProt	predicted biotin regulatory protein BioR (GntR family)
PredBiotReprFrom	Predicted biotin repressor from TetR family
PredBroaSubsSpec	Predicted broad substrate specificity phosphatase
PredBrpLikeProtBlh	Predictet Brp-like protein Blh
PredCellWallAnch	Predicted cell-wall-anchored protein SasA (LPXTG motif)
PredCellWallAnch2	Predicted cell-wall-anchored protein SasD (LPXAG motif)
PredCellWallAnch3	Predicted cell-wall-anchored protein SasC (LPXTG motif)
PredCellWallAnch4	Predicted cell-wall-anchored protein SasK (LPXTG motif)
PredCellWallAnch5	Predicted cell-wall-anchored protein SasF (LPXAG motif)
PredChapLipoYacc	Predicted chaperone lipoprotein YacC, potentially involved in protein secretion
PredCoaBindDomaCog1n1	Predicted CoA-binding domain COG1832
PredDGlucSpecTrap	Predicted D-glucuronide-specific TRAP transporter, substrate-binding component
PredDGlucSpecTrap2	Predicted D-glucuronide-specific TRAP transporter, large transmembrane component
PredDGlucSpecTrap3	Predicted D-glucuronide-specific TRAP transporter, small transmembrane component
PredDMannEpim	Predicted D-mannonate epimerase
PredDTagaEpim	Predicted D-tagaturonate epimerase
PredDyeDecoPeroEnca	Predicted dye-decolorizing peroxidase (DyP), encapsulated subgroup
PredFrucBispAldo	Predicted Fructose-bisphosphate aldolase in Geobacter (EC 4.1.2.13)
PredFuncAnalHomo	Predicted functional analog of homoserine kinase (EC 2.7.1.-)
PredGlucTrapFami	Predicted gluconate TRAP family transporter, DctM subunit
PredGlucTrapFami2	Predicted gluconate TRAP family transporter, DctQ subunit
PredGlucTrapFami3	Predicted gluconate TRAP family transporter, DctP subunit
PredGlycDebrEnzy	Predicted glycogen debranching enzyme (pullulanase-like, but lacking signal peptide)
PredGlycDehy2Subu	Predicted glycolate dehydrogenase, 2-subunit type, iron-sulfur subunit GlcF (EC 1.1.99.14)
PredGlycDehy2Subu2	Predicted glycolate dehydrogenase, 2-subunit type, iron-sulfur subunit GlcD (EC 1.1.99.14)
PredGlycDehyRegu	Predicted glycolate dehydrogenase regulator
PredGlycSyntAdpGluc	Predicted glycogen synthase, ADP-glucose transglucosylase, Actinobacterial type (EC 2.4.1.21)
PredHydrMetaBeta	Predicted hydrolase of the metallo-beta-lactamase superfamily, clustered with KDO2-Lipid A biosynthesis genes
PredHydrTranCytx	Predicted hydroxymethylpyrimidine transporter CytX
PredInneMembProt2	Predicted inner membrane protein CbrB
PredIronDepePero	Predicted iron-dependent peroxidase, Dyp-type family
PredNRiboCrpLike	Predicted N-ribosylNicotinamide CRP-like regulator
PredNicoReguTran	Predicted nicotinate-regulated transporter BH3254
PredNuclPhos	Predicted nucleoside phosphatase
PredOuteMembLipo	Predicted outer membrane lipoprotein YfeY
PredOxidFeSSubu	Predicted oxidoreductase, Fe-S subunit
PredPolySensNsps	Predicted polyamine sensor NspS, involved in biofilm formation
PredPyriBiosProt	Predicted pyridoxine biosynthesis protein (probably from glycolaldehide)
PredReguPutrForProl	Predicted regulator PutR for proline utilization, GntR family
PredRiboAbcTranSubs	Predicted riboflavin ABC transporter, substrate-binding component
PredRiboAbcTranTran	Predicted riboflavin ABC transporter, transmembrane component
PredSecrSystWAtpa	Predicted secretion system W ATPase PilM-like
PredSecrSystWHypo	Predicted secretion system W hypothetical protein
PredSecrSystWProt	Predicted secretion system W protein GspE-like
PredSecrSystWProt2	Predicted secretion system W protein GspG-like 2
PredSecrSystWProt3	Predicted secretion system W protein GspG-like
PredSecrSystWProt4	Predicted secretion system W protein GspD-like
PredSecrSystWProt5	Predicted secretion system W protein GspF-like
PredSecrSystWProt6	Predicted secretion system W protein PilO-like
PredSecrSystWTran	Predicted secretion system W transmembrane protein 1
PredSecrSystXDna	Predicted secretion system X DNA-binding regulator
PredSecrSystXFig0n1	Predicted secretion system X FIG084745: hypothetical protein
PredSecrSystXProt	Predicted secretion system X protein GspG-like 2
PredSecrSystXProt2	Predicted secretion system X protein GspG-like
PredSecrSystXProt3	Predicted secretion system X protein GspD-like
PredSecrSystXProt4	Predicted secretion system X protein GspE-like
PredSecrSystXProt5	Predicted secretion system X protein GspF-like
PredSecrSystXProt6	Predicted secretion system X protein GspG-like 3
PredSecrSystXPseu	Predicted secretion system X pseudopilin PulG-like
PredSecrSystXTran	Predicted secretion system X translation initiation factor
PredSecrSystXTran2	Predicted secretion system X transmembrane protein 2
PredSecrSystXTran3	Predicted secretion system X transmembrane protein 1
PredSialAcidTran	Predicted sialic acid transporter
PredSignTranProt2	Predicted signal-transduction protein containing cAMP-binding and CBS domains
PredSodiDepeGala	Predicted sodium-dependent galactose transporter
PredSodiSeriSymp	Predicted sodium/serine symporter MysT
PredThiaTranPnut	Predicted thiamin transporter PnuT
PredThiaTranThiu	Predicted thiazole transporter ThiU
PredThiaTranThiv	Predicted thiamin transporter ThiV, SSS family
PredTranAccoWith	Predicted transporter accosiated with cytochrome c biogenesis
PredTranReguLiur	Predicted transcriptional regulator LiuR of leucine degradation pathway, MerR family
PredTranReguMyoInos	Predicted transcriptional regulator of the myo-inositol catabolic operon
PredTranReguPyri	Predicted transcriptional regulator of pyridoxine metabolism
PredZnRibbRnaBind	Predicted Zn-ribbon RNA-binding protein with a function in translation
PrepArogDehy	Prephenate and/or arogenate dehydrogenase (unknown specificity) (EC 1.3.1.43) (EC 1.3.1.12)
PrepDehy	Prephenate dehydratase (EC 4.2.1.51)
PrepDehy2	Prephenate dehydrogenase (EC 1.3.1.12)
PrevHostDeatProt	Prevent host death protein, Phd antitoxin
ProbAcylAcpDesaStea	Probable acyl-ACP desaturase, Stearoyl-ACP desaturase (EC 1.14.19.2)
ProbAminAcidBind	Probable amino-acid-binding protein YxeM
ProbAminAcidImpo	Probable amino-acid import ATP-binding protein YxeO
ProbAminAcidPerm	Probable amino-acid permease protein YxeN
ProbAtpSyntSpal	Probable ATP synthase SpaL (Invasion protein InvC) (EC 3.6.3.14)
ProbGlutSTranYfcf	Probable glutathione S-transferase, YfcF homolog (EC 2.5.1.18)
ProbGlutSTranYfcg	Probable glutathione S-transferase, YfcG homolog (EC 2.5.1.18)
ProbGtpaRelaEngc	Probable GTPase related to EngC
ProbHydrCoaDehyHtdx	Probable (3R)-hydroxyacyl-CoA dehydratase HtdX
ProbHydrCoexWith	Probable hydrolase, coexpressed with pyoverdine biosynthesis regulon
ProbIronBindProt	probable iron binding protein from the HesB_IscA_SufA family
ProbIronBindProt2	probable iron binding protein from the HesB_IscA_SufA family in Nif operon
ProbIronBindProt3	probable iron binding protein for iron-sulfur cluster assembly
ProbIronExpoAtpBind	Probable iron export ATP-binding protein FetA
ProbIronExpoPerm	Probable iron export permease protein FetB
ProbLAsco6PhosLact	Probable L-ascorbate-6-phosphate lactonase UlaG (L-ascorbate utilization protein G) (EC 3.1.1.-)
ProbLysiNHydrAsso	Probable Lysine n(6)-hydroxylase associated with siderophore S biosynthesis (EC 1.14.13.59)
ProbMaloSemiRedu	Probable malonic semialdehyde reductase RutE (EC 1.1.1.298)
ProbMetaHydrYqgx	Probable metallo-hydrolase YqgX
ProbMfsTranEnanPyoc	Probable MFS transporter in enantio-pyochelin gene cluster
ProbPolyOAcet	Probable poly(beta-D-mannuronate) O-acetylase (EC 2.3.1.-)
ProbReacFactForAmin	Probable reactivating factor for an aminomutase or amino-lyase
ProbReacFactForD	Probable reactivating factor for D-ornithine aminomutase
ProbSecrMembSeri	Probable secreted or membrane serine protease Rv0983
ProbSperPutrSubs	Probable spermidine/putrescine substrate binding protein in Mollicutes
ProbThioInvoNonRibo	Probable thioesterase involved in non-ribosomal peptide biosynthesis, PA2411 homolog
ProbThioOxidWith	Probable thiol oxidoreductase with 2 cytochrome c heme-binding sites
ProbTranReguProt2	Probable transcription regulator protein of MDR efflux pump cluster
ProbTwoCompSensNear	Probable two-component sensor, near polyamine transporter
ProgCellDeatAnti	Programmed cell death antitoxin YdcD
ProgCellDeatAnti2	Programmed cell death antitoxin ChpS
ProgCellDeatAnti3	Programmed cell death antitoxin PemI
ProgCellDeatAnti4	Programmed cell death antitoxin MazE
ProgCellDeatAnti5	Programmed cell death antitoxin MazE like
ProgCellDeatToxi	Programmed cell death toxin ChpB
ProgCellDeatToxi2	Programmed cell death toxin YdcE
ProgCellDeatToxi3	Programmed cell death toxin MazF
ProgCellDeatToxi4	Programmed cell death toxin PemK
ProgCellDeatToxi5	Programmed cell death toxin MazF like
ProgFramCont	programmed frameshift-containing
ProkUbiqLikeProt	Prokaryotic ubiquitin-like protein Pup
Prol2MethForPyrr	Proline 2-methylase for pyrrolysine biosynthesis
ProlAlanRichProt	Proline and alanine rich protein EspI, component of Type VII secretion system ESX-1
ProlAlanRichProt2	Proline and alanine rich protein EspK, component of Type VII secretion system ESX-1
ProlAmin	Prolyl aminopeptidase (EC 3.4.11.5 )
ProlDehy2	Proline dehydrogenase (EC 1.5.5.2)
ProlDiacTran	Prolipoprotein diacylglyceryl transferase (EC 2.4.99.-)
ProlDipe	Proline dipeptidase (EC 3.4.13.9)
ProlEndo	Prolyl endopeptidase (EC 3.4.21.26)
ProlImin	Proline iminopeptidase (EC 3.4.11.5)
ProlOligFamiProt	Prolyl oligopeptidase family protein (EC 3.4.21.26)
ProlRace	Proline racemase (EC 5.1.1.4)
ProlReduForPyrrBios	Proline reductase for pyrrolysine biosynthesis
ProlSensReguPrlr	Proline sensor-regulator PrlR
ProlSodiSympPutp	Proline/sodium symporter PutP (TC 2.A.21.2.1)
ProlSpecPermProy	Proline-specific permease proY
ProlTrnaSynt	Prolyl-tRNA synthetase (EC 6.1.1.15)
ProlTrnaSyntArch	Prolyl-tRNA synthetase, archaeal/eukaryal type (EC 6.1.1.15)
ProlTrnaSyntBact	Prolyl-tRNA synthetase, bacterial type (EC 6.1.1.15)
ProlTrnaSyntChlo	Prolyl-tRNA synthetase, chloroplast (EC 6.1.1.15)
ProlTrnaSyntMito	Prolyl-tRNA synthetase, mitochondrial (EC 6.1.1.15)
ProlTrnaSyntRela	Prolyl-tRNA synthetase related protein
ProlTrnaSyntRela2	Prolyl-tRNA synthetase-related protein 1
ProoThioEnteBios	Proofreading thioesterase in enterobactin biosynthesis EntH
PropAminAcidLiga	proposed amino acid ligase found clustered with an amidotransferase
PropCataOperRegu	Propionate catabolism operon regulatory protein PrpR
PropCataOperTran2	Propionate catabolism operon transcriptional regulator of GntR family
PropCoaCarbBiotCont	Propionyl-CoA carboxylase biotin-containing subunit (EC 6.4.1.3)
PropCoaCarbCarbTran	Propionyl-CoA carboxylase carboxyl transferase subunit (EC 6.4.1.3)
PropCoaLiga	Propionate--CoA ligase (EC 6.2.1.17)
PropDehyLargSubu	Propanediol dehydratase large subunit (EC 4.2.1.28)
PropDehyMediSubu	Propanediol dehydratase medium subunit (EC 4.2.1.28)
PropDehyReacFact	Propanediol dehydratase reactivation factor large subunit
PropDehyReacFact2	Propanediol dehydratase reactivation factor small subunit
PropDehySmalSubu	Propanediol dehydratase small subunit (EC 4.2.1.28)
PropDiffFaci	Propanediol diffusion facilitator
PropKina	Propionate kinase (EC 2.7.2.15)
PropKinaPropUtil	Propionate kinase, propanediol utilization (EC 2.7.2.1)
PropLipoReguProt	Proposed lipoate regulatory protein YbeD
PropPeptLipiIiFlip	Proposed peptidoglycan lipid II flippase MurJ
PropPrec4Hydr	Proposed precorrin-4 hydrolase (analogous to cobalt-precorrin-5A hydrolase)
PropPrec5Meth	Proposed precorrin-5* (C1)-methyltransferase
PropUtilPolyBody	Propanediol utilization polyhedral body protein PduA
PropUtilPolyBody2	Propanediol utilization polyhedral body protein PduB
PropUtilPolyBody3	Propanediol utilization polyhedral body protein PduJ
PropUtilPolyBody4	Propanediol utilization polyhedral body protein PduK
PropUtilPolyBody5	Propanediol utilization polyhedral body protein PduN
PropUtilPolyBody6	Propanediol utilization polyhedral body protein PduT
PropUtilPolyBody7	Propanediol utilization polyhedral body protein PduU
PropUtilProtPdua	Propanediol utilization protein PduA
PropUtilProtPdum	Propanediol utilization protein PduM
PropUtilProtPduv	Propanediol utilization protein PduV
PropUtilTranActi	Propanediol utilization transcriptional activator
ProqInflOsmoActi	ProQ: influences osmotic activation of compatible solute ProP
Prot34DioxAlphChai	Protocatechuate 3,4-dioxygenase alpha chain (EC 1.13.11.3)
Prot34DioxBetaChai	Protocatechuate 3,4-dioxygenase beta chain (EC 1.13.11.3)
Prot4	Proteorhodopsin
Prot45DioxAlphChai	Protocatechuate 4,5-dioxygenase alpha chain (EC 1.13.11.8)
Prot45DioxBetaChai	Protocatechuate 4,5-dioxygenase beta chain (EC 1.13.11.8)
ProtAcet	Protein acetyltransferase
ProtActiAaaAtpa	proteasome-activating AAA-ATPase (PAN)
ProtBchjInvoRedu	Protein BchJ, involved in reduction of C-8 vinyl of divinyl protochlorophyllide
ProtBf25PredTran	Protein BF2544, predicted transporter component
ProtClusWithEtha	Protein clustered with ethanolamine utilization
ProtClusWithOPhos	Protein clustered with O-phosphoseryl-tRNA(Cys) synthetase
ProtCoOccuWithFig0n1	Protein co-occurring with FIG00645039: hypothetical protein with HTH-domain
ProtCoOccuWithMoly	Protein co-occuring with molybdenum cofactor biosynthesis protein B
ProtCp12ReguCalv	Protein CP12, regulation of Calvin cycle via association/dissociation of PRK/CP12/GAPDH complex
ProtDuf2PredTran	Protein DUF2149, predicted transporter component
ProtEspdCompType	Protein EspD, component of Type VII secretion system ESX-1
ProtEspgCompType	Protein EspG1, component of Type VII secretion system ESX-1
ProtEspgCompType2	Protein EspG3, component of Type VII secretion system ESX-3
ProtEspgCompType3	Protein EspG2, component of Type VII secretion system ESX-2
ProtEsphCompType	Protein EspH, component of Type VII secretion system ESX-1
ProtEspjCompType	Protein EspJ, component of Type VII secretion system ESX-1
ProtEsplCompType	Protein EspL, component of Type VII secretion system ESX-1
ProtExpoMembProt3	Protein-export membrane protein SecG
ProtExpoProtSecb	Protein-export protein SecB (maintains pre-export unfolded state)
ProtFragRequForFila	Protein FraG required for filament integrity and heterocyst maturation
ProtGerpRequForProp2	Protein GerPB, required for proper assembly of spore coat, mutations lead to super-dormant spore
ProtGerpRequForProp3	Protein GerPC, required for proper assembly of spore coat, mutations lead to super-dormant spore
ProtGerpRequForProp4	Protein GerPE, required for proper assembly of spore coat, mutations lead to super-dormant spore
ProtGerpRequForProp6	Protein GerPD, required for proper assembly of spore coat, mutations lead to super-dormant spore
ProtGp10BactA118n1	Protein gp10 [Bacteriophage A118]
ProtGp11BactA118n1	Protein gp11 [Bacteriophage A118]
ProtGp13BactA118n1	Protein gp13 [Bacteriophage A118]
ProtGp14BactA118n1	Protein gp14 [Bacteriophage A118]
ProtGp15BactA118n1	Protein gp15 [Bacteriophage A118]
ProtGp22BactA118n1	Protein gp22 [Bacteriophage A118]
ProtGp23BactA118n1	Protein gp23 [Bacteriophage A118]
ProtGp28BactA118n1	Protein gp28 [Bacteriophage A118]
ProtGp29BactA118n1	Protein gp29 [Bacteriophage A118]
ProtGp30BactA118n1	Protein gp30 [Bacteriophage A118]
ProtGp32ListPhag	Protein gp32 [Listeria phage 2389]
ProtGp33BactA118n1	Protein gp33 [Bacteriophage A118]
ProtGp34BactA118n1	Protein gp34 [Bacteriophage A118]
ProtGp35BactA118n1	Protein gp35 [Bacteriophage A118]
ProtGp37BactA118n1	Protein gp37 [Bacteriophage A118]
ProtGp38BactA118n1	Protein gp38 [Bacteriophage A118]
ProtGp40BactA118n1	Protein gp40 [Bacteriophage A118]
ProtGp41BactA118n1	Protein gp41 [Bacteriophage A118]
ProtGp43BactA118n1	Protein gp43 [Bacteriophage A118]
ProtGp44BactA118n1	Protein gp44 [Bacteriophage A118]
ProtGp45BactA118n1	Protein gp45 [Bacteriophage A118]
ProtGp47RecoRela	Protein gp47, recombination-related [Bacteriophage A118]
ProtGp49ReplInit	Protein gp49, replication initiation [Bacteriophage A118]
ProtGp51BactA118n1	Protein gp51 [Bacteriophage A118]
ProtGp52BactA118n1	Protein gp52 [Bacteriophage A118]
ProtGp55BactA118n1	Protein gp55 [Bacteriophage A118]
ProtGp59BactA118n1	Protein gp59 [Bacteriophage A118]
ProtGp61BactA118n1	Protein gp61 [Bacteriophage A118], similar to Listeria protein LmaD
ProtGp63BactA118n1	Protein gp63 [Bacteriophage A118]
ProtGp65BactA118n1	Protein gp65 [Bacteriophage A118]
ProtGp66BactA118n1	Protein gp66 [Bacteriophage A118], similar to Listeria protein LmaC
ProtGp68BactA118n1	Protein gp68 [Bacteriophage A118]
ProtGp7BactA118n1	Protein gp7 [Bacteriophage A118]
ProtGp8BactA118n1	Protein gp8 [Bacteriophage A118]
ProtGp9BactA118n1	Protein gp9 [Bacteriophage A118]
ProtIi	Protease II (EC 3.4.21.83)
ProtIiiPrec	Protease III precursor (EC 3.4.24.55)
ProtIxMgChelSubu	Protoporphyrin IX Mg-chelatase subunit H (EC 6.6.1.1)
ProtIxMgChelSubu2	Protoporphyrin IX Mg-chelatase subunit D (EC 6.6.1.1)
ProtIxMgChelSubu3	Protoporphyrin IX Mg-chelatase subunit I (EC 6.6.1.1)
ProtIxOxidAeroHemy	Protoporphyrinogen IX oxidase, aerobic, HemY (EC 1.3.3.4)
ProtIxOxidNoveForm	Protoporphyrinogen IX oxidase, novel form, HemJ (EC 1.3.-.-)
ProtIxOxidOxygInde	Protoporphyrinogen IX oxidase, oxygen-independent, HemG (EC 1.3.-.-)
ProtKinaDomaHipa	Protein kinase domain of HipA
ProtLIsoaOMeth	Protein-L-isoaspartate O-methyltransferase (EC 2.1.1.77)
ProtLiahSimiPhag	Protein LiaH, similar to phage shock protein A
ProtLiai	Protein LiaI
ProtMsa	Protein msa (Modulator of sarA)
ProtOfteFounActi	Protein often found in Actinomycetes clustered with signal peptidase and/or RNaseHII
ProtPe35InvoRegu	Protein PE35, involved in regulation of esxAB expression in Type VII secretion system ESX-1
ProtPifiNuclEnco	Protein PIFI, nuclear-encoded factor required for plastidial NAD(P)H dehydrogenase
ProtPiiUmpUridRemo	[Protein-PII]-UMP uridylyl-removing enzyme
ProtPiiUrid	[Protein-PII] uridylyltransferase (EC 2.7.7.59)
ProtProdReguProt	Protease production regulatory protein Hpr (ScoC)
ProtPtlcPentBios	Protein PtlC in pentalenolactone biosynthesis
ProtPufqInvoAsse	Protein PufQ, involved in assembly of B875 and B800-850 pigment-protein complexes
ProtPufxInvoAsse	Protein PufX, involved in assembly of B875 and B800-850 pigment-protein complexes
ProtQmca	Protein QmcA (possibly involved in integral membrane quality control)
ProtSeriThrePhos	Protein serine/threonine phosphatase PrpC, regulation of stationary phase
ProtSimiCobyAcid	Protein similar to cobyrinic acid a,c-diamide synthetase clustered with dissimilatory sulfite reductase
ProtSimiGlutSynt	Protein similar to glutamate synthase [NADPH] small chain, clustered with sulfite reductase
ProtSubuAlph8	proteasome subunit alpha (EC 3.4.25.1)
ProtSubuAlphBact	Proteasome subunit alpha, bacterial (EC 3.4.25.1)
ProtSubuBeta8	proteasome subunit beta (EC 3.4.25.1)
ProtSubuBetaBact	Proteasome subunit beta, bacterial (EC 3.4.25.1)
ProtTadgAssoWith	Protein TadG, associated with Flp pilus assembly
ProtTranSubuSeca2	Protein translocase subunit SecA clustered with accessory secretion system
ProtTranSubuSece	Protein translocase subunit SecE
ProtTranSubuSecy2	Protein translocase subunit SecY clustered with accessory secretion system
ProtTyroKina	Protein-tyrosine kinase (EC 2.7.10.1 )
ProtUnknFuncDuf1n2	Protein of unknown function DUF1447
ProtUnknFuncDuf1n5	Protein of unknown function DUF156
ProtUnknFuncDuf1n63	Protein of unknown function DUF1009 clustered with KDO2-Lipid A biosynthesis genes
ProtUnknFuncDuf2n1	Protein of unknown function DUF208
ProtUnknFuncDuf3n4	protein of unknown function DUF374
ProtUnknFuncDuf8n58	Protein of unknown function DUF81, SAV0084 homolog
ProtUnknFuncSmg	Protein of unknown function Smg
ProtViiPrec	Protease VII (Omptin) precursor (EC 3.4.23.49)
ProtViolAcidSynt	Proto(deoxy)violaceinic acid synthase VioE
ProtVirdVirdOper	Protein VirD5 in virD operon
ProtVirfSecrInto	Protein VirF secreted into plant cell during T-DNA transfer
ProtVonWillFactBind	Protein A, von Willebrand factor binding protein Spa
ProtWithDomaFrom	Protein with domain from phenylalanyl-tRNA synthetase alpha chain
ProtWithParbLike	Protein with ParB-like nuclease domain in PFGI-1-like cluster
ProtWithSimiRtcb	Protein with similarity to RtcB
ProtYaia	Protein YaiA
ProtYaii	Protein YaiI
ProtYcie	Protein YciE
ProtYidd	Protein YidD
ProtYihd	Protein yihD
ProtYkia	Protein YkiA
ProtYrda	Protein YrdA
PsbqLikeProtRequ	PsbQ-like (PQL) protein, required for formation and activity of plastidial NAD(P)H dehydrogenase complex
Pseu	Pseudoazurin
Pseu5Phos	Pseudouridine-5' phosphatase (EC 3.1.3.-)
PseuAcidCyti	Pseudaminic acid cytidylyltransferase (EC 2.7.7.43)
PseuAcidSynt	Pseudaminic acid synthase (EC 4.1.3.-)
PseuDomaMvin	Pseudokinase domain in MviN
PseuExtrZincProt	Pseudolysin, extracellular zinc protease (EC 3.4.24.26)
PseuSynt2	Pseudouridylate synthase (EC 4.2.1.70 )
PseuSyntAdehType	Pseudouridine synthase, Adeh_0195 type (EC 4.2.1.70)
PseuSyntAdehType2	Pseudouridine synthase, Adeh_0265 type (EC 4.2.1.70)
PseuSyntAdehType3	Pseudouridine synthase, Adeh_1865 type (EC 4.2.1.70)
PseuSyntAdehType4	Pseudouridine synthase, Adeh_3379 type (EC 4.2.1.70)
PseuSyntAdehType5	Pseudouridine synthase, Adeh_4177 type (EC 4.2.1.70)
PseuSyntPa20Type	Pseudouridine synthase, PA2043 type (EC 4.2.1.70)
PseuSyntVc16Type	Pseudouridine synthase, VC1668 type (EC 4.2.1.70)
PseuYpaaSimiWith	Pseudogene ypaA, similarity with carboxyl terminus of putative transposase YfaD
PspOperTranActi	Psp operon transcriptional activator
Pter4AlphCarbDehy	Pterin-4-alpha-carbinolamine dehydratase (EC 4.2.1.96)
PtpsV	PTPS-V
PtpsVi	PTPS-VI
PtsIiaLikeNitrRegu	PTS IIA-like nitrogen-regulatory protein PtsN (EC 2.7.1.69 )
PtsReguDomaContProt	PTS-regulatory domain-containing protein YhfY
PtsSyst2OAlphMann	PTS system, 2-O-alpha-mannosyl-D-glycerate-specific IIA component
PtsSyst2OAlphMann2	PTS system, 2-O-alpha-mannosyl-D-glycerate-specific IIB component (EC 2.7.1.69)
PtsSyst2OAlphMann3	PTS system, 2-O-alpha-mannosyl-D-glycerate-specific IIC component
PtsSystFrucGlucSpec	PTS system, fructoselysine/glucoselysine-specific IIA component
PtsSystFrucGlucSpec2	PTS system, fructoselysine/glucoselysine-specific IIB component (EC 2.7.1.69)
PtsSystFrucGlucSpec3	PTS system, fructoselysine/glucoselysine-specific IIC component
PtsSystFrucGlucSpec4	PTS system, fructoselysine/glucoselysine-specific IID component
PtsSystHyalOligSpec	PTS system, hyaluronate-oligosaccharide-specific IIB component (EC 2.7.1.69)
PtsSystHyalOligSpec2	PTS system, hyaluronate-oligosaccharide-specific IID component (EC 2.7.1.69)
PtsSystHyalOligSpec3	PTS system, hyaluronate-oligosaccharide-specific IIC component (EC 2.7.1.69)
PtsSystHyalOligSpec4	PTS system, hyaluronate-oligosaccharide-specific IIA component (EC 2.7.1.69)
PtsSystLactSpecIia	PTS system, lactose-specific IIA component (EC 2.7.1.69)
PtsSystLactSpecIib	PTS system, lactose-specific IIB component (EC 2.7.1.69)
PtsSystLactSpecIic	PTS system, lactose-specific IIC component (EC 2.7.1.69)
PtsSystNNDiacSpec	PTS system, N,N'-diacetylchitobiose-specific IIB component (EC 2.7.1.69)
PtsSystNNDiacSpec2	PTS system, N,N'-diacetylchitobiose-specific IIC component
PtsSystNNDiacSpec3	PTS system, N,N'-diacetylchitobiose-specific IIA component (EC 2.7.1.69)
PtsSystPermNitrRegu	PTS system permease (IIAMan), nitrogen regulatory IIA protein
PtsSystTagaSpecIia	PTS system, tagatose-specific IIA component
PtsSystTagaSpecIib	PTS system, tagatose-specific IIB component (EC 2.7.1.69)
PtsSystTagaSpecIic	PTS system, tagatose-specific IIC component
PtsSystTagaSpecPhos	PTS system, tagatose-specific phosphocarrier protein
PuaLikeDomaPf14n1	PUA-like domain PF14306
PucbProtRequForXant	PucB protein, required for xanthine dehyrogenase activity
PupLigaPafaParaPoss	Pup ligase PafA' paralog, possible component of postulated heterodimer PafA-PafA'
PupLigaPafaPossComp	Pup ligase PafA, possible component of postulated heterodimer PafA-PafA'
PuriCataReguProt2	Purine catabolism regulatory protein PucR
PuriNuclPhos	Purine nucleoside phosphorylase (EC 2.4.2.1)
PuriNuclSyntRepr	Purine nucleotide synthesis repressor
PurrTranReguAsso	PurR: transcription regulator associated with purine metabolism
Puta2Keto3DeoxKina	Putative 2-keto-3-deoxygluconate kinase (EC 2.7.1.45)
Puta3HydrDehyDddb	Putative 3-hydroxypropionate dehydrogenase DddB, Fe-containing (EC 1.1.1.-)
Puta3OxoaAcylCarr10	Putative 3-oxoacyl-[acyl-carrier-protein] synthase III in AHQ biosynthetic operon, related to PqsB
PutaAbcIronSideTran	Putative ABC iron siderophore transporter, fused permease and ATPase domains
PutaAbcTranAtpBind3	Putative ABC transporter ATP-binding protein, spy1790 homolog
PutaAbcTranSpy1Homo	Putative ABC transporter (ATP-binding protein), spy1791 homolog
PutaAbcTranSubsX	Putative ABC transporter of substrate X, ATP-binding subunit
PutaAbcTranSubsX2	Putative ABC transporter of substrate X, permease subunit I
PutaAbcTranSubsX3	Putative ABC transporter of substrate X, permease subunit II
PutaAchrBiosProt	Putative achromobactin biosynthesis protein, related to 2-demethylmenaquinone methyltransferase
PutaActiReguMemb	Putative activity regulator of membrane protease YbbK
PutaAlkaMetaUtil	Putative alkanesulfonate metabolism utilization regulator
PutaAmidSimiCoby	Putative amidotransferase similar to cobyric acid synthase
PutaAminPeraRedu	Putative aminoacrylate peracid reductase RutC
PutaAminTranDoma	Putative aminomethyl transferase domain
PutaAnalCcohCog3n1	Putative analog of CcoH, COG3198
PutaAntiSigmFact	putative anti-sigma factor antagonist
PutaArylSulf	Putative arylsulfate sulfotransferase (EC 2.8.2.22)
PutaAtpBindCompAbc6	Putative ATP-binding component of ABC transporter involved in cytochrome c biogenesis
PutaAtpDepeDnaHeli2	putative ATP-dependent DNA helicase YjcD
PutaBetaGala4Hydr	Putative beta-galactosidase in 4-hydroxyproline catabolic gene cluster
PutaChapLikeProt	Putative chaperon-like protein Ycf39 for quinone binding in Photosystem II
PutaCoenF420Depe	Putative coenzyme F420-dependent oxidoreductase MJ1349
PutaConjTranMobi	Putative conjugative transposon mobilization protein BF0132
PutaCoxLocuProt	putative cox locus protein
PutaCrypDSeriDeam	Putative cryptic D-serine deaminase (EC 4.3.1.18)
PutaCyclDiGmpPhos2	Putative cyclic di-GMP phosphodiesterase, EAL domain protein
PutaCystDesuAsso	Putative cysteine desulfurase, associated with tRNA 4-thiouridine synthase
PutaCytoCBiogFact	Putative cytochrome c biogenesis factor, archaeal
PutaCytoCTypeBiog	Putative cytochrome C-type biogenesis protein
PutaCytoCTypeBiog2	Putative cytochrome c-type biogenesis protein related to CcmF
PutaDeacYgey	Putative deacetylase YgeY
PutaDeca5PhosPhos	Putative decaprenylphosphoryl-5-phosphoribose phosphatase (EC 3.1.3.-)
PutaDeoxSimiYcfh	Putative deoxyribonuclease similar to YcfH, type 3
PutaDeoxSimiYcfh2	Putative deoxyribonuclease similar to YcfH, type 4
PutaDeoxSimiYcfh3	Putative deoxyribonuclease similar to YcfH, type 2
PutaDeoxSimiYcfh4	Putative deoxyribonuclease similar to YcfH, type 5
PutaDeoxYcfh	Putative deoxyribonuclease YcfH
PutaDeoxYjjv	Putative deoxyribonuclease YjjV
PutaDesfETran	Putative Desferrioxamine E transporter
PutaDhntPyro	Putative DHNTP pyrophosphatase
PutaDihyDehy	Putative Dihydrolipoamide dehydrogenase (EC 1.8.1.4)
PutaDihyDehyNadp	Putative dihydropyrimidine dehydrogenase [NADP+], similar to dihydroorotate dehydrogenase
PutaDihyKinaAdpBind	Putative dihydroxyacetone kinase, ADP-binding subunit (EC 2.7.1.29)
PutaDihyKinaDihy	Putative dihydroxyacetone kinase, dihydroxyacetone binding subunit (EC 2.7.1.29)
PutaDipePyovBios2	Putative dipeptidase, pyoverdin biosynthesis PvdM
PutaDnaHeliSupeEnco	Putative DNA helicase, superantigen-encoding pathogenicity islands SaPI
PutaDypTypePeroAsso	Putative Dyp-type peroxidase, associated with bacterial analog of Cox17 protein
PutaEcaPolyWzye	Putative ECA polymerase WzyE
PutaEffeProtOrgc	Putative effector protein OrgC of SPI-1 type III secretion system
PutaEsacProtAnal2	Putative EsaC protein analog (Listeria type 1)
PutaEsatSecrProt	Putative ESAT-secreted protein, BA2187 homolog
PutaEsatSecrProt2	Putative ESAT-secreted protein, BA2188 homolog
PutaEsatSecrProt3	Putative ESAT-secreted protein, BA2189 homolog
PutaExpoProtClus	Putative exported protein clustered with Gamma-glutamyltranspeptidase
PutaFmnHydr	Putative FMN hydrolase (EC 3.1.3.-)
PutaGluc6PhosDehy2	Putative glucose 6-phosphate dehydrogenase effector OpcA
PutaGlutSyntRick	Putative glutamine synthetase, Rickettsiales type (EC 6.3.1.2)
PutaGlycDebrEnzy	Putative glycogen debranching enzyme, archaeal type, TIGR01561
PutaGntrFamiRegu	Putative GntR-family regulatory protein and aminotransferase near polyamine transporter
PutaHaemCytoSecr	Putative haemolysin/cytolysin secreted via TPS pathway
PutaHemeIronUtil	Putative heme iron utilization protein
PutaHistAmmoLyas	Putative histidine ammonia-lyase protein
PutaHydrClusWith	Putative hydrolase in cluster with formaldehyde/S-nitrosomycothiol reductase MscR
PutaInneMembProt2	Putative inner membrane protein YjeT (clustered with HflC)
PutaInneMembProt4	Putative inner membrane protein, DUF1819 superfamily
PutaIronContNadp	Putative iron-containing NADPH-dependent propanol dehydrogenase
PutaIronReduSide	Putative iron reductase in siderophore [Alcaligin] cluster
PutaIronReguMemb2	Putative iron-regulated membrane protein FtpC in pyochelin gene cluster
PutaIronReguMemb3	Putative iron-regulated membrane protein in siderophore cluster
PutaIronSulfClus	Putative iron-sulfur cluster assembly scaffold protein for SUF system, SufE2
PutaLGlutLiga	putative L-glutamate ligase
PutaLargExopInvo	Putative large exoprotein involved in heme utilization or adhesion of ShlA/HecA/FhaA family
PutaLongTailFibr	Putative long tail fibre [Bacteriophage A118]
PutaLyasPtlj	Putative lyase PtlJ
PutaMajoTeicAcid	Putative major teichoic acid biosynthesis protein C
PutaMalaDehySimi	Putative malate dehydrogenase, similar to archaeal MJ1425 (EC 1.1.1.37)
PutaMembBounClpp	Putative membrane-bound ClpP-class protease associated with aq_911
PutaMembProtClus2	Putative membrane protein, clustering with ActP PaaL
PutaMembProtYeih	Putative membrane protein YeiH
PutaMethOligEste	Putative methyl oligogalcturonate esterase
PutaMobiProtBf01n1	Putative mobilization protein BF0133
PutaMonoDoma	putative monooxygenase domain
PutaNAcetDiphGluc	putative N-acetylgalactosaminyl-diphosphoundecaprenol glucuronosyltransferase (EC 2.4.1.- )
PutaNadDepeOxidEc	Putative NAD(P)-dependent oxidoreductase EC-YbbO
PutaNadpDepeOxid	Putative NADP-dependent oxidoreductase PA1648
PutaNitrHydrRegu	Putative nitrile hydratase regulator clustered with urea transport
PutaNonRiboPeptSynt6	Putative non-ribosomal peptide synthetase in AHQ biosynthetic operon
PutaNudiHydrYfcd	Putative Nudix hydrolase YfcD (EC 3.6.-.-)
PutaOligCyclDehy	Putative oligoketide cyclase/dehydratase or lipid transport protein YfjG
PutaOuteMembTonb	Putative outer membrane TonB-dependent receptor associated with haemagglutinin family outer membrane protein
PutaOuteMembViru	Putative outer membrane virulence protein PhoP
PutaOxid4HydrCata	Putative oxidoreductase in 4-hydroxyproline catabolic gene cluster
PutaOxidRv00n1	putative oxidoreductase Rv0097
PutaOxidSco1n1	Putative oxidoreductase SCO1803
PutaOxidSmc0n1	Putative oxidoreductase SMc00968
PutaOxidYncb	Putative oxidoreductase YncB
PutaParvTypePept	Putative parvulin type peptidyl-prolyl isomerase, similarity with PrsA foldase
PutaPentIsom	Putative pentose isomerase
PutaPeptHydrYvbx	Putative peptidoglycan hydrolase YvbX, NOT involved in spore germination
PutaPeriPhosBind2	Putative periplasmic phosphate-binding protein PstS (Mycoplasma type)
PutaPeriPhosBind3	Putative periplasmic phosphate-binding protein PstS (Catenulisporaceae type)
PutaPeriPhosBind4	Putative periplasmic phosphate-binding protein PstS (Halobacteriales type)
PutaPeriProtKina	putative periplasmic protein kinase ArgK and related GTPases of G3E family
PutaPeriProtYibq	Putative periplasmic protein YibQ, distant homology with nucleoside diphosphatase and polysaccharide deacetylase
PutaPertLikeToxi	Putative pertussis-like toxin subunit PtlB
PutaPertLikeToxi2	Putative pertussis-like toxin subunit PtlA (EC 2.4.2.-)
PutaPherCam3Prec	Putative pheromone cAM373 precursor lipoprotein CamS
PutaPherPrecLipo2	Putative pheromone precursor lipoprotein
PutaPhosAbcTranPhos	Putative phosphate ABC transporter, phosphate-binding component
PutaPhosGbaaHomo	Putative phosphoesterase, GBAA2539 homolog
PutaPhosPhos	putative phosphoglycolate phosphatase (EC 3.1.3.18 )
PutaPhosSuccSynt	Putative phosphoribosylaminoimidazole-succinocarboxamide synthase 2 (SAICAR synthetase 2)
PutaPhosSynt	putative phosphatidylglycerophosphate synthase (EC 2.7.8.- )
PutaPhosSyntPyru	Putative phosphoenolpyruvate synthase/pyruvate phosphate dikinase, C-terminal domain
PutaPhosSyntPyru2	Putative phosphoenolpyruvate synthase/pyruvate phosphate dikinase, N-terminal domain
PutaPhosYfbt	Putative phosphatase YfbT
PutaPhosYieh	Putative phosphatase YieH
PutaPhosYqab	Putative phosphatase YqaB
PutaPhotCompAsse	Putative photosynthetic complex assembly protein
PutaPpicTypePept	Putative PpiC-type peptidyl-prolyl cis-trans isomerase precursor associated with VreARI signaling system
PutaPre16sRrnaNucl	Putative pre-16S rRNA nuclease
PutaPrenCont14Dihy	Putative prenyltransferase, contains 1,4-dihydroxy-2-naphthoate octaprenyltransferase domain
PutaPrimSupeEnco	Putative primase, superantigen-encoding pathogenicity islands SaPI
PutaPuriPermYgfo	Putative purine permease YgfO
PutaReduSideBios	Putative reductoisomerase in siderophore biosynthesis gene cluster
PutaRespReguArlr	Putative response regulator ArlR
PutaRiboTranRibn	Putative riboflavin transporter RibN homologue
PutaSecrAcceProt	Putative secretion accessory protein EsaA/YueB
PutaSecrAcceProt2	Putative secretion accessory protein EsaB/YukD
PutaSecrSystComp	Putative secretion system component EssB/YukC
PutaSecrSystComp2	Putative secretion system component EssA
PutaSensAtpaComp	Putative sensor and ATPase, component of G-protein-coupled receptor (GPCR) system
PutaSensHistKina3	Putative sensory histidine kinase YfhA
PutaSensLikeHist2	Putative sensor-like histidine kinase YfhK
PutaShorTailFibr	Putative short tail fibre [Bacteriophage A118]
PutaSideBiosProt	Putative siderophore biosynthesis protein, related to 2-demethylmenaquinone methyltransferase
PutaSnrnSmLikeProt	Putative snRNP Sm-like protein
PutaSnrnSmLikeProt2	Putative snRNP Sm-like protein, Archaeal
PutaStomProhFami2	Putative stomatin/prohibitin-family membrane protease subunit aq_911
PutaSubuAlteCyto	putative subunit of Alternative cytochrome c oxidase
PutaSubuNadHQuin	Putative subunit of NAD(P)H:quinone oxidoreductase
PutaSuccDehySubu	Putative succinate dehydrogenase subunit
PutaSympYjcg	Putative symporter YjcG
PutaTailBasePlat	Putative tail or base plate protein gp17 [Bacteriophage A118]
PutaTailBasePlat2	Putative tail or base plate protein gp19 [Bacteriophage A118]
PutaTailBasePlat3	Putative tail or base plate protein gp18 [Bacteriophage A118]
PutaTeicAcidBios	Putative teichuronic acid biosynthesis glycosyl transferase TuaC
PutaTeicAcidBios3	Putative teichuronic acid biosynthesis glycosyl transferase TuaH
PutaTermSupeEnco	Putative terminase, superantigen-encoding pathogenicity islands SaPI
PutaThioDisuOxid4	Putative thiol:disulfide oxidoreductase involved in cytochrome C-type biogenesis
PutaThioSulfYnje	Putative thiosulfate sulfurtransferase ynjE (EC 2.8.1.1)
PutaTonbDepeHeme	Putative TonB-dependent heme receptor HasR
PutaToxiAnioResi	putative toxic anion resistance protein
PutaTranAntiProt	Putative transcription antitermination protein NusG
PutaTranReguInfe	putative transcriptional regulator, inferred for PFA pathway
PutaTranStatRegu	Putative transition state regulator Abh
PutaTricTranTctc	Putative tricarboxylic transport TctC
PutaTwoCompRespRegu6	Putative two-component response regulator and GGDEF family protein YeaJ
PutaTwoCompSystHist3	Putative two component system histidine kinase YedV
PutaTwoCompSystResp9	Putative two-component system response regulator YedW
PutaTypeIiiSecrSyst	putative type III secretion system EscC protein
PutaTypeIiiSecrSyst2	putative type III secretion system lipoprotein precursor EprK
PutaUnchProtTtha	Putative uncharacterized protein TTHA1760
PutaUndePhosNAcet	Putative undecaprenyl-phosphate N-acetylgalactosaminyl 1-phosphate transferase
PutaUropIiiCMeth	Putative uroporphyrinogen-III C-methyltransferase
PutaUropIiiSyntRela	Putative uroporphyrinogen-III synthase, related to YjjA (in BS) (EC 4.2.1.75)
PutaZnDepeOxidBa21n1	Putative Zn-dependent oxidoreductase BA2113
PutaZnDepeOxidPa52n1	Putative Zn-dependent oxidoreductase PA5234
PutpFragContRegi	putPA fragment of control region
PutrAbcTranPutrBind	Putrescine ABC transporter putrescine-binding protein PotF (TC 3.A.1.11.2)
PutrCarb	Putrescine carbamoyltransferase (EC 2.1.3.6)
PutrImpo	Putrescine importer
PutrOrniAnti	putrescine-ornithine antiporter
PutrProtSympPutr	Putrescine/proton symporter, putrescine/ornithine antiporter PotE
PutrTranActiPuta	PutR, transcriptional activator of PutA and PutP
PutrTranAtpBindProt2	Putrescine transport ATP-binding protein PotG (TC 3.A.1.11.2)
PutrTranSystPerm	Putrescine transport system permease protein PotH (TC 3.A.1.11.2)
PutrTranSystPerm2	Putrescine transport system permease protein PotI (TC 3.A.1.11.2)
PutrUtilRegu	Putrescine utilization regulator
PvdePyovAbcExpoSyst	PvdE, pyoverdine ABC export system, fused ATPase and permease components
PvdoPyovRespSeri2	PvdO, pyoverdine responsive serine/threonine kinase (predicted by OlgaV)
PyocBiosProtPchc	Pyochelin biosynthetic protein PchC, predicted thioesterase
PyocBiosProtPchg	Pyochelin biosynthetic protein PchG, oxidoreductase (NAD-binding)
PyocSyntPchfNonRibo	Pyochelin synthetase PchF, non-ribosomal peptide synthetase module
PyovBiosProtPvdh	Pyoverdin biosynthesis protein PvdH, L-2,4-diaminobutyrate:2-oxoglutarate aminotransferase (EC 2.6.1.76)
PyovBiosProtPvdn	Pyoverdin biosynthesis protein PvdN, putative aminotransferase, class V
PyovBiosRelaProt	Pyoverdine biosynthesis related protein PvdP
PyovChroPrecSynt	Pyoverdine chromophore precursor synthetase PvdL
PyovEfflCarrAtpBind	Pyoverdine efflux carrier and ATP binding protein
PyovSideNonRiboPept	Pyoverdine sidechain non-ribosomal peptide synthetase PvdJ
PyovSideNonRiboPept2	Pyoverdine sidechain non-ribosomal peptide synthetase PvdD
PyovSideNonRiboPept3	Pyoverdine sidechain non-ribosomal peptide synthetase PvdI
PyovSpecEfflMaca	pyoverdine-specific efflux macA-like protein
PyovSyntPvdfN5Hydr	Pyoverdine synthetase PvdF, N5-hydroxyornithine formyltransferase
Pyri4Dehy	Pyridoxal 4-dehydrogenase (EC 1.1.1.107)
Pyri4Oxid	Pyridoxine 4-oxidase (EC 1.1.3.12)
Pyri5NuclYjjg	Pyrimidine 5'-nucleotidase YjjG (EC 3.1.3.5)
Pyri5PhosOxid	Pyridoxamine 5'-phosphate oxidase (EC 1.4.3.5)
Pyri5PhosOxidPhzg	Pyridoxamine 5'-phosphate oxidase PhzG (EC 1.4.3.5)
Pyri5PhosOxidRela	Pyridoxamine 5'-phosphate oxidase-related putative heme iron utilization protein
Pyri5PhosSynt	Pyridoxine 5'-phosphate synthase (EC 2.6.99.2)
Pyri5PhosSyntGlut	Pyridoxal 5'-phosphate synthase (glutamine hydrolyzing), glutaminase subunit (EC 4.3.3.6)
Pyri5PhosSyntSlut	Pyridoxal 5'-phosphate synthase (glutamine hydrolyzing), slutaminase subunit (EC 4.3.3.6)
Pyri5PhosSyntSynt	Pyridoxal 5'-phosphate synthase (glutamine hydrolyzing), synthase subunit (EC 4.3.3.6)
PyriAbcTranAtpBind	Pyrimidine ABC transporter, ATP-binding protein
PyriAbcTranSubsBind	Pyrimidine ABC transporter, substrate-binding component
PyriAbcTranTranComp	Pyrimidine ABC transporter, transmembrane component 2
PyriAbcTranTranComp2	Pyrimidine ABC transporter, transmembrane component 1
PyriDeamArchPred	Pyrimidine deaminase archaeal predicted type 2 (EC 3.5.4.26)
PyriDeoxTripPyro	Pyrimidine deoxynucleoside triphosphate (dYTP) pyrophosphohydrolase NudI
PyriKina	Pyridoxal kinase (EC 2.7.1.35)
PyriMonoRuta	Pyrimidine monooxygenase RutA (EC 1.14.99.46)
PyriNuclDisuOxid4	Pyridine nucleotide-disulphide oxidoreductase family protein associated with PFOR
PyriNuclPhos	Pyrimidine-nucleoside phosphorylase (EC 2.4.2.2)
PyriOperReguProt	Pyrimidine operon regulatory protein PyrR
PyriPermRutg	Pyrimidine permease RutG
PyriPhosDepeProt	Pyridoxal-phosphate-dependent protein EgtE (ergothioneine synthase)
PyriPyruAmin	Pyridoxamine-pyruvate aminotransferase (EC 2.6.1.30)
PyroDepeFruc6Phos	Pyrophosphate-dependent fructose 6-phosphate-1-kinase (EC 2.7.1.90)
PyroSpecOuteMemb	Pyrophosphate-specific outer membrane porin OprO
Pyrr5CarbRedu	Pyrroline-5-carboxylate reductase (EC 1.5.1.2)
Pyrr5CarbReduProg	Pyrroline-5-carboxylate reductase, ProG-like (EC 1.5.1.2)
PyrrCarbPept	Pyrrolidone-carboxylate peptidase (EC 3.4.19.3)
PyrrCont	pyrrolysine-containing
PyrrQuinSynt	Pyrroloquinoline-quinone synthase (EC 1.3.3.11)
PyrrSynt	Pyrrolysine synthetase
PyrrTrnaSynt	Pyrrolysyl-tRNA synthetase (EC 6.1.1.26)
PyrrTrnaSyntAmin	Pyrrolysyl-tRNA synthetase, amino domain (EC 6.1.1.26)
PyrrTrnaSyntCarb	Pyrrolysyl-tRNA synthetase, carboxy domain (EC 6.1.1.26)
PyruCarb	Pyruvate carboxylase (EC 6.4.1.1)
PyruCarbSubu	Pyruvate carboxylase subunit A (EC 6.4.1.1)
PyruCarbSubuB	Pyruvate carboxylase subunit B (biotin-containing) (EC 6.4.1.1)
PyruDeca	Pyruvate decarboxylase (EC 4.1.1.1)
PyruDehy	Pyruvate dehydrogenase (quinone) (EC 1.2.5.1)
PyruDehyE1Comp	Pyruvate dehydrogenase E1 component (EC 1.2.4.1)
PyruDehyE1CompAlph	Pyruvate dehydrogenase E1 component alpha subunit (EC 1.2.4.1)
PyruDehyE1CompBeta	Pyruvate dehydrogenase E1 component beta subunit (EC 1.2.4.1)
PyruDehyE1CompLike	Pyruvate dehydrogenase E1 component like
PyruFerrOxidAlph	Pyruvate:ferredoxin oxidoreductase, alpha subunit (EC 1.2.7.1)
PyruFerrOxidBeta	Pyruvate:ferredoxin oxidoreductase, beta subunit (EC 1.2.7.1)
PyruFerrOxidDelt	Pyruvate:ferredoxin oxidoreductase, delta subunit (EC 1.2.7.1)
PyruFerrOxidGamm	Pyruvate:ferredoxin oxidoreductase, gamma subunit (EC 1.2.7.1)
PyruFerrOxidPore	Pyruvate:ferredoxin oxidoreductase, porE subunit (EC 1.2.7.1)
PyruFerrOxidPorf	Pyruvate:ferredoxin oxidoreductase, porF subunit (EC 1.2.7.1)
PyruFlavOxid	Pyruvate-flavodoxin oxidoreductase (EC 1.2.7.-)
PyruFormLyas	Pyruvate formate-lyase (EC 2.3.1.54)
PyruFormLyasActi	Pyruvate formate-lyase activating enzyme (EC 1.97.1.4)
PyruKina	Pyruvate kinase (EC 2.7.1.40)
PyruOxalTranDoma	Pyruvate:Oxaloacetate transcarboxylase domain protein
PyruOxid	Pyruvate oxidase (EC 1.2.3.3)
PyruOxidCidc	Pyruvate oxidase, CidC
PyruPhosDiki	Pyruvate,phosphate dikinase (EC 2.7.9.1)
PyruUtilEnzySimi	Pyruvate-utilizing enzyme, similar to phosphoenolpyruvate synthase
QrrRna	Qrr RNA
QscrQuorSensCont	QscR quorum-sensing control repressor
QuinDehyTetrCType	Quinol dehydrogenase tetraheme c-type cytochrome PcrQ
QuinDepeOxidDoma	Quinone-dependent oxidoreductase domain
QuinOxid	Quinone oxidoreductase (EC 1.6.5.5)
QuinPhosDeca	Quinolinate phosphoribosyltransferase [decarboxylating] (EC 2.4.2.19)
QuinProtAlcoDehy	Quino(hemo)protein alcohol dehydrogenase, PQQ-dependent (EC 1.1.99.8)
QuinShik5DehyIDelt	Quinate/shikimate 5-dehydrogenase I delta (EC 1.1.1.25)
QuinShikDehyPyrr	Quinate/shikimate dehydrogenase [Pyrroloquinoline-quinone] (EC 1.1.5.8)
QuinSynt	Quinolinate synthetase (EC 2.5.1.72)
QuorSensReguViru	Quorum-sensing regulator of virulence HapR
QuorSensTranActi	Quorum-sensing transcriptional activator YspR
QuorSensTranActi2	Quorum-sensing transcriptional activator YpeR
RadiSamDomaHemeBios	Radical SAM domain heme biosynthesis protein
RadiSamDomaProtPred	Radical SAM domain protein predicted to modify YydF
RadiSamFamiEnzySimi	Radical SAM family enzyme, similar to coproporphyrinogen III oxidase, oxygen-independent, clustered with nucleoside-triphosphatase RdgB
RadiSamFamiProtHutw	Radical SAM family protein HutW, similar to coproporphyrinogen III oxidase, oxygen-independent, associated with heme uptake
RadiSamHemeBiosProt	Radical SAM heme biosynthesis protein AhbD, Fe-coproporphyrin III decarboxylase
RadiSamHemeBiosProt2	Radical SAM heme biosynthesis protein AhbC, 12,18-didecarboxysirohaem deacetylase
RcnrLikeProtClus	RcnR-like protein clustered with cobalt-zinc-cadmium resistance protein CzcD
ReFaceSpecCitrSynt	Re face-specific citrate synthase (EC 2.3.3.3)
RecaProt	RecA protein
RecaRadaReco	RecA/RadA recombinase
RecdLikeDnaHeliAtu2n1	RecD-like DNA helicase Atu2026
RecdLikeDnaHeliYrrc	RecD-like DNA helicase YrrC
RecoDnaRepaProtRect	Recombinational DNA repair protein RecT (prophage associated)
RecoInhiProtMuts	Recombination inhibitory protein MutS2
RecoProtRecr	Recombination protein RecR
RecuHollJuncReso	RecU Holliday junction resolvase
RedChloCataRedu	Red chlorophyll catabolite reductase (EC 1.-.-.-)
RedTypeRubiActiCbbx	Red-type Rubisco activase CbbX, removes Rubisco byproduct XuBP
RedoProtRelaSucc	redox proteins related to the succinate dehydrogenases and fumarate reductases
RedoSensTranActi	Redox-sensitive transcriptional activator SoxR
ReduDisuIsomCopp	Reductase or disulfide isomerase in copper uptake, YcnL
ReduFolaCarrProt	Reduced folate carrier protein RFC1, also transports thiamine mono- and diphosphate
ReguLGalaCataLgor	Regulator of L-galactonate catabolism LgoR, GntR family
ReguPectGalaUtil	Regulator of pectin and galacturonate utilization, GntR family
ReguProt2	Regulatory protein (induces abgABT, used to catabolize p-aminobenzoyl-glutamate)
ReguProtEsprComp	Regulator protein EspR, component of Type VII secretion system ESX-1
ReguProtHrpb	Regulatory protein HrpB
ReguProtLuxo	Regulatory protein LuxO
ReguProtMerrCitr	Regulatory protein, MerR:Citrate synthase
ReguProtRecx	Regulatory protein RecX
ReguProtRsal	Regulatory protein RsaL
ReguSigmSFactFliz	Regulator of sigma S factor FliZ
ReguSmalRnaInvoIron	Regulatory small RNA involved in iron homeostasis RyhB
ReguSupeRespRegu	regulation of superoxide response regulon
Rela6Phos3Hexu	related to 6-phospho-3-hexuloisomerase
RelaDihySynt	Related to Dihydropteroate synthase
RelbStbdReplStab	RelB/StbD replicon stabilization protein (antitoxin to RelE/StbE)
ReleLikeTranRepr	RelE-like translational repressor toxin
RepeHypoProtEsat	Repetitive hypothetical protein in ESAT cluster, COG4495
RepeHypoProtEsat2	Repetitive hypothetical protein in ESAT cluster, BH0979 homolog
RepeHypoProtNear	Repetitive hypothetical protein near ESAT cluster, SA0282 homolog
ReplDnaHeli2	Replicative DNA helicase (DnaB) (EC 3.6.4.12)
ReplDnaHeliPfgi1n1	Replicative DNA helicase in PFGI-1-like cluster (EC 3.6.4.12)
ReplDnaHeliSa1424n1	Replicative DNA helicase [SA14-24] (EC 3.6.1.-)
ReplFact	Replication factor A (ssDNA-binding protein)
ReplHeliRepaPhag	Replicative helicase RepA, Phage P4-associated
ReplInitProt3	Replication initiation protein A
ReplProtRepa	replication protein RepA
ReplProtRepb	Replication protein repB
ReplProtRepc	Replication protein RepC
ReprBactA118n1	Repressor (cro-like) [Bacteriophage A118]
ReprBactA118n2	Repressor (CI-like) [Bacteriophage A118]
ReprCsorCopzOper	Repressor CsoR of the copZA operon
ResoInteBin	Resolvase/integrase Bin
RespArseReduCyto	Respiratory arsenate reductase cytoplasmic chaperone
RespArseReduFesSubu	Respiratory arsentate reductase, FeS subunit (ArrB)
RespArseReduMoBind	Respiratory arsenate reductase, Mo binding subunit (ArrA)
RespNitrReduAlph	Respiratory nitrate reductase alpha chain (EC 1.7.99.4)
RespNitrReduBeta	Respiratory nitrate reductase beta chain (EC 1.7.99.4)
RespNitrReduDelt	Respiratory nitrate reductase delta chain (EC 1.7.99.4)
RespNitrReduGamm	Respiratory nitrate reductase gamma chain (EC 1.7.99.4)
RespReguAspaPhos	response regulator aspartate phosphatase
RespReguAspaPhos10	Response regulator aspartate phosphatase F
RespReguAspaPhos11	Response regulator aspartate phosphatase C
RespReguAspaPhos12	Response regulator aspartate phosphatase G
RespReguAspaPhos13	Response regulator aspartate phosphatase I
RespReguAspaPhos14	Response regulator aspartate phosphatase H (EC 3.1.-.-)
RespReguAspaPhos4	Response regulator aspartate phosphatase A
RespReguAspaPhos5	Response regulator aspartate phosphatase K
RespReguAspaPhos6	Response regulator aspartate phosphatase E
RespReguAspaPhos7	Response regulator aspartate phosphatase J
RespReguAspaPhos8	Response regulator aspartate phosphatase D
RespReguAspaPhos9	Response regulator aspartate phosphatase B (EC 3.1.-.-)
RespReguCrebTwoComp	Response regulator CreB of two-component signal transduction system CreBC
RespReguDrra	response regulator DrrA
RespReguForArabSens	Response regulator for an arabinose sensor
RespReguLiar	Response regulator LiaR
RespReguSaer	Response regulator SaeR (Staphylococcus exoprotein expression protein R)
RespReguZincSigm	Response regulator of zinc sigma-54-dependent two-component system
RetrTypeRnaDireDna	Retron-type RNA-directed DNA polymerase (EC 2.7.7.49)
RhamBios3OxoaAcyl	Rhamnolipids biosynthesis 3-oxoacyl-[acyl-carrier-protein] reductase RhlG (EC 1.1.1.100)
RhamDegrProtRhin	Rhamnogalacturonides degradation protein RhiN
RhhDnaBindProtVirc	RHH DNA-binding protein VirC2, promotes T-DNA transfer
Rhla3AlkaAcidSynt	RhlA, 3-(3-hydroxyalkanoyloxy)alkanoic acids (HAAs) synthase
RhlbTdpRham1n1	RhlB, TDP-rhamnosyltransferase 1 (EC 2.4.1.-)
RhlcTdpRham2n1	RhlC, TDP-rhamnosyltransferase 2 (EC 2.4.1.-)
RhodDomaProt	Rhodanese domain protein
RhodLikeDomaCyst2	Rhodanese-like domain/cysteine-rich domain
RhodLikeDomaRequ	Rhodanese-like domain required for thiamine synthesis
RhodLikeProtChre	Rhodanese-like protein ChrE
RhodRelaSulf	rhodanese-related sulfurtransferase (EC 3.1.2.6 )
RhodRelaSulf1Doma	Rhodanese-related sulfurtransferase, 1 domain
RhodRelaSulf4Doma	Rhodanese-related sulfurtransferase, 4 domains
RhodRelaSulfYibn	Rhodanese-related sulfurtransferase YibN
RhomProtGlpg	Rhomboid protease GlpG (EC 3.4.21.105)
Ribo	Ribokinase (EC 2.7.1.15)
Ribo15Bisp5Ribo1n1	Ribose 1,5-bisphosphate or 5-ribose-1,2-cyclic phosphate dehydrogenase
Ribo15BispIsom	Ribose-1,5-bisphosphate isomerase
Ribo5PhosIsom	Ribose 5-phosphate isomerase A (EC 5.3.1.6)
Ribo5PhosIsomB	Ribose 5-phosphate isomerase B (EC 5.3.1.6)
RiboArreProtRaia	Ribosomal arrest protein RaiA
RiboAssoHeatShoc	Ribosome-associated heat shock protein implicated in the recycling of the 50S subunit (S4 paralog)
RiboAssoInhi	Ribosome-associated inhibitor A
RiboBindFact	Ribosome-binding factor A
RiboBn	Ribonuclease BN (EC 3.1.-.-)
RiboD	Ribonuclease D (EC 3.1.26.3)
RiboE	Ribonuclease E (EC 3.1.26.12)
RiboEInhiRraa	Ribonuclease E inhibitor RraA
RiboEInhiRrab	Ribonuclease E inhibitor RraB
RiboG	Ribonuclease G
RiboHi	Ribonuclease HI (EC 3.1.26.4)
RiboHiRelaProt	Ribonuclease HI-related protein
RiboHiRelaProt2n1	Ribonuclease HI-related protein 2
RiboHiRelaProt3n1	Ribonuclease HI-related protein 3
RiboHiVibrPara	Ribonuclease HI, Vibrio paralog
RiboHibePromFact	Ribosome hibernation promoting factor Hpf
RiboHibeProtYhbh	Ribosome hibernation protein YhbH
RiboHii	Ribonuclease HII (EC 3.1.26.4)
RiboHiii	Ribonuclease HIII (EC 3.1.26.4)
RiboIPrec	Ribonuclease I precursor (EC 3.1.27.6)
RiboIii	Ribonuclease III (EC 3.1.26.3)
RiboInhi	ribonuclease inhibitor
RiboJ	Ribonuclease J (endonuclease and 5' exonuclease)
RiboJ1n1	Ribonuclease J1 (endonuclease and 5' exonuclease)
RiboJ2n1	Ribonuclease J2 (endoribonuclease in RNA processing)
RiboKina	Ribosylnicotinamide kinase (EC 2.7.1.22)
RiboKina2	Riboflavin kinase (EC 2.7.1.26)
RiboKinaEuka	Ribosylnicotinamide kinase, eukaryotic (EC 2.7.1.22)
RiboLargSubuPseu	Ribosomal large subunit pseudouridine synthase C (EC 4.2.1.70)
RiboLargSubuPseu12	Ribosomal large subunit pseudouridine synthase A (EC 5.4.99.29) (EC 5.4.99.28)
RiboLargSubuPseu2	Ribosomal large subunit pseudouridine synthase E (EC 4.2.1.70)
RiboLargSubuPseu3	Ribosomal large subunit pseudouridine synthase D (EC 4.2.1.70)
RiboLargSubuPseu5	Ribosomal large subunit pseudouridine synthase B (EC 4.2.1.70)
RiboLargSubuPseu6	Ribosomal large subunit pseudouridine synthase F (EC 5.4.99.21)
RiboLargSubuPseu7	Ribosomal large subunit pseudouridine(746) synthase (EC 5.4.99.29)
RiboLsuAssoGtpBind	Ribosome LSU-associated GTP-binding protein HflX
RiboM5n1	Ribonuclease M5 (EC 3.1.26.8)
RiboModuFact	Ribosome modulation factor
RiboNicoTranPnuc	Ribosyl nicotinamide transporter, PnuC-like
RiboPProtComp	Ribonuclease P protein component (EC 3.1.26.5)
RiboPProtComp1n1	Ribonuclease P protein component 1 (EC 3.1.26.5)
RiboPProtComp2n1	Ribonuclease P protein component 2 (EC 3.1.26.5)
RiboPProtComp3n1	Ribonuclease P protein component 3 (EC 3.1.26.5)
RiboPProtComp4n1	Ribonuclease P protein component 4 (EC 3.1.26.5)
RiboPh	Ribonuclease PH (EC 2.7.7.56)
RiboPhosPyro	Ribose-phosphate pyrophosphokinase (EC 2.7.6.1)
RiboPhosPyroPoss	Ribose-phosphate pyrophosphokinase, possible alternative form 2
RiboPhosPyroPoss2	Ribose-phosphate pyrophosphokinase, possible alternative form 3
RiboPhosPyroPoss3	Ribose-phosphate pyrophosphokinase, possible alternative form
RiboProtL11Meth	Ribosomal protein L11 methyltransferase (EC 2.1.1.-)
RiboProtL24Conj	Ribosomal protein L24, conjectural
RiboProtL3NGlutMeth	Ribosomal protein L3 N(5)-glutamine methyltransferase (EC 2.1.1.298)
RiboProtL7aeFami	Ribosomal protein L7Ae family protein YlxQ
RiboProtL7pSeriAcet	Ribosomal-protein-L7p-serine acetyltransferase (EC 2.3.1.-)
RiboProtS12pAsp8n1	Ribosomal protein S12p Asp88 (E. coli) methylthiotransferase (EC 2.8.4.4)
RiboProtS12pMeth	Ribosomal protein S12p methylthiotransferase accessory factor YcaO
RiboProtS18pAlan3	Ribosomal-protein-S18p-alanine acetyltransferase ## RimI (EC 2.3.1.-)
RiboProtS5pAlanAcet	Ribosomal-protein-S5p-alanine acetyltransferase (EC 2.3.1.128)
RiboProtS5pAlanAcet3	Ribosomal-protein-S5p-alanine acetyltransferase related protein
RiboProtTypeTetr	Ribosome protection-type tetracycline resistance related proteins, group 2
RiboProtTypeTetr2	Ribosome protection-type tetracycline resistance related proteins
RiboRecyFact	Ribosome recycling factor
RiboReduClasIaAlph	Ribonucleotide reductase of class Ia (aerobic), alpha subunit (EC 1.17.4.1)
RiboReduClasIaBeta	Ribonucleotide reductase of class Ia (aerobic), beta subunit (EC 1.17.4.1)
RiboReduClasIbAlph	Ribonucleotide reductase of class Ib (aerobic), alpha subunit (EC 1.17.4.1)
RiboReduClasIbBeta	Ribonucleotide reductase of class Ib (aerobic), beta subunit (EC 1.17.4.1)
RiboReduClasIi	Ribonucleotide reductase of class II (coenzyme B12-dependent) (EC 1.17.4.1)
RiboReduClasIiiActi	Ribonucleotide reductase of class III (anaerobic), activating protein (EC 1.97.1.4)
RiboReduClasIiiLarg	Ribonucleotide reductase of class III (anaerobic), large subunit (EC 1.17.4.2)
RiboReduProtNrdi	Ribonucleotide reduction protein NrdI
RiboReduTranRegu	Ribonucleotide reductase transcriptional regulator NrdR
RiboRnaProcEndoNob1n1	Ribosomal RNA processing endonuclease Nob1
RiboRneRngFami	Ribonuclease, Rne/Rng family
RiboSecr	Ribonuclease (Barnase), secreted
RiboSileFactRsfa	Ribosomal silencing factor RsfA
RiboSileFactRsfa2	Ribosomal silencing factor RsfA (former Iojap)
RiboSmalSubuBiog	Ribosome small subunit biogenesis RbfA-release protein RsgA
RiboSmalSubuPseu	Ribosomal small subunit pseudouridine synthase A (EC 4.2.1.70)
RiboSyntArch	Riboflavin synthase archaeal (EC 2.5.1.9)
RiboSyntEubaEuka	Riboflavin synthase eubacterial/eukaryotic (EC 2.5.1.9)
RiboT	Ribonuclease T (EC 3.1.13.-)
RiboTranPnux	Riboflavin transporter PnuX
RiboTranRibn	Riboflavin transporter RibN
RiboY	Ribonuclease Y
RiboZ	Ribonuclease Z (EC 3.1.26.11)
Ribu	Ribulokinase (EC 2.7.1.16)
Ribu15BispCarbOxyg	ribulose 1,5-bisphosphate carboxylase/oxygenase activase
Ribu15BispCarbType	Ribulose-1,5-bisphosphate carboxylase, Type III (EC 4.1.1.39)
RibuBispCarb	Ribulose bisphosphate carboxylase (EC 4.1.1.39)
RibuBispCarbLarg	Ribulose bisphosphate carboxylase large chain (EC 4.1.1.39)
RibuBispCarbLike	ribulose-bisphosphate carboxylase-like protein
RibuBispCarbSmal	Ribulose bisphosphate carboxylase small chain (EC 4.1.1.39)
RibuEryt3KinaPote	Ribulosamine/erythrulosamine 3-kinase potentially involved in protein deglycation
RibuPhos3Epim	Ribulose-phosphate 3-epimerase (EC 5.1.3.1)
RidaFragSmalOrf	RidA fragment or small ORF
RidaYer0Uk11Supe	RidA/YER057c/UK114 superfamily protein
RidaYer0Uk11Supe10	RidA/YER057c/UK114 superfamily, 2 tandem domains
RidaYer0Uk11Supe11	RidA/YER057c/UK114 superfamily, 4 tandem domains
RidaYer0Uk11Supe2	RidA/YER057c/UK114 superfamily, group 6
RidaYer0Uk11Supe3	RidA/YER057c/UK114 superfamily, group 1
RidaYer0Uk11Supe4	RidA/YER057c/UK114 superfamily, group 2, YoaB-like protein
RidaYer0Uk11Supe5	RidA/YER057c/UK114 superfamily, group 4
RidaYer0Uk11Supe6	RidA/YER057c/UK114 superfamily, group 3
RidaYer0Uk11Supe7	RidA/YER057c/UK114 superfamily, group 7, YjgH-like protein
RidaYer0Uk11Supe8	RidA/YER057c/UK114 superfamily, 3 tandem domains
RidaYer0Uk11Supe9	RidA/YER057c/UK114 superfamily, group 5
Rna23Po4Rna5OhLiga	RNA-2',3'-PO4:RNA-5'-OH ligase
RnaBindCTermDoma	RNA-binding C-terminal domain PUA
RnaBindDomaProt	RNA-binding domain protein
RnaBindMethFtsjLike	RNA binding methyltransferase FtsJ like
RnaBindProtContRibo	RNA binding protein, contains ribosomal protein S1 domain
RnaBindProtContS1n1	RNA-binding protein, containing S1 domain
RnaBindProtContThum	RNA-binding protein, containing THUMP domain
RnaBindProtHfq	RNA-binding protein Hfq
RnaBindProtJag	RNA-binding protein Jag
RnaNad2Phos	RNA:NAD 2'-phosphotransferase
RnaPolyAssoProtRapa	RNA polymerase associated protein RapA (EC 3.6.1.-)
RnaPolySigm54Fact	RNA polymerase sigma-54 factor RpoN
RnaPolySigm70Fact2	RNA polymerase sigma-70 factor, ECF subfamily (EC 2.7.7.6 )
RnaPolySigmFact	RNA polymerase sigma factor
RnaPolySigmFactFeci	RNA polymerase sigma factor FecI
RnaPolySigmFactFor	RNA polymerase sigma factor for flagellar operon
RnaPolySigmFactRpod	RNA polymerase sigma factor RpoD
RnaPolySigmFactRpoh	RNA polymerase sigma factor RpoH
RnaPolySigmFactRpos	RNA polymerase sigma factor RpoS
RnaPolySigmFactSigb	RNA polymerase sigma factor SigB
RnaPolySporSpecSigm	RNA polymerase sporulation specific sigma factor SigK
RnaPolySporSpecSigm2	RNA polymerase sporulation specific sigma factor SigH
RnaPolySporSpecSigm3	RNA polymerase sporulation specific sigma factor SigF
RnaPolySporSpecSigm4	RNA polymerase sporulation specific sigma factor SigG
RnaPolySporSpecSigm5	RNA polymerase sporulation specific sigma factor SigE
RnaPseuSyntBt06n1	RNA pseudouridylate synthase BT0642
RnaSpliProt	RNA splicing protein
Rnai	RNAIII (delta-hemolysin)
RnasAdapProtRapz	RNase adapter protein RapZ
RnasE5PrimUtrElem	RNase E 5[prime] UTR element
RndEfflSystInneMemb2	RND efflux system, inner membrane transporter
RndEfflSystMembFusi2	RND efflux system, membrane fusion protein
RoadLc7ProtPutaGtpa	Roadblock/LC7 protein, putative GTPase-activating (GAP) component of G-protein-coupled receptor (GPCR) system
RodShapDeteProtMreb	Rod shape-determining protein MreB
RodShapDeteProtMrec	Rod shape-determining protein MreC
RodShapDeteProtMred	Rod shape-determining protein MreD
RodShapDeteProtRoda	Rod shape-determining protein RodA
RossFoldNuclBind	Rossmann fold nucleotide-binding protein Smf possibly involved in DNA uptake
RponDepeTranActi	RpoN-dependent transcriptional activator of GfrABCDEF operon, NtrC family
RsbsNegaReguSigm	RsbS, negative regulator of sigma-B
RsbtCoAntaProtRsbr	RsbT co-antagonist protein RsbRA
RtxToxiActiLysiAcyl	RTX toxin activating lysine-acyltransferase (EC 2.3.1.-)
RtxToxiDeteRelaCa2n1	RTX toxins determinant A and related Ca2+-binding proteins
RtxToxiRelaCa2Bind	RTX toxins and related Ca2+-binding proteins
RtxToxiTranAtpBind	RTX toxin transporter, ATP-binding protein
RtxToxiTranDeteD	RTX toxin transporter, determinant D
RubiActiProtCbbo	Rubisco activation protein CbbO
RubiActiProtCbbq	Rubisco activation protein CbbQ
RubiLikeProt	rubisco-like protein
RubiOperTranRegu	RuBisCO operon transcriptional regulator CbbR
RubiOperTranRegu2	RuBisCO operon transcriptional regulator
Rubr2	Rubrerythrin
SAden2DemeMeth	S-adenosylmethionine:2-demethylmenaquinone methyltransferase (EC 2.1.-.-)
SAdenDecaProeEuka	S-adenosylmethionine decarboxylase proenzyme, eukaryotic (EC 4.1.1.50)
SAdenDecaProeProk	S-adenosylmethionine decarboxylase proenzyme, prokaryotic class 1B (EC 4.1.1.50)
SAdenDecaProeProk2	S-adenosylmethionine decarboxylase proenzyme, prokaryotic class 1A (EC 4.1.1.50)
SAdenDepeMethFunc	S-adenosylmethionine-dependent methyltransferase Functionally Coupled to the MukBEF Chromosome Partitioning Mechanism
SAdenDiac3Amin3Carb2	S-adenosylmethionine:diacylglycerol 3-amino-3-carboxypropyl transferase, BtaA protein
SAdenDiacNMethBtab	S-adenosylmethionine:diacylgycerolhomoserine-N-methyltransferase, BtaB protein
SAdenNucl	S-adenosylhomocysteine nucleosidase (EC 3.2.2.9)
SAdenSynt	S-adenosylmethionine synthetase (EC 2.5.1.6)
SAdenTrnaRiboIsom	S-adenosylmethionine:tRNA ribosyltransferase-isomerase (EC 5.-.-.-)
SAdenTrnaRiboIsom2	S-adenosylmethionine:tRNA ribosyltransferase-isomerase-like protein
SFormHydr	S-formylglutathione hydrolase (EC 3.1.2.12)
SGlutDehy	S-(hydroxymethyl)glutathione dehydrogenase (EC 1.1.1.284)
SLayeProtEa1n1	S-layer protein EA1
SLayeProtSap	S-layer protein Sap
SMethPerm	S-methylmethionine permease
SNitrReduMscr	S-nitrosomycothiol reductase MscR
SRiboLyas	S-ribosylhomocysteine lyase (EC 4.4.1.21)
SaccDehyNadLLysi	Saccharopine dehydrogenase [NAD+, L-lysine-forming] (EC 1.5.1.7)
SaccDehyNadpLGlut	Saccharopine dehydrogenase [NADP , L-glutamate-forming] (EC 1.5.1.10)
Sag1HomoWithEsat	SAG1025 homolog within ESAT-6 gene cluster
SaicLyas	SAICAR lyase (EC 4.3.2.2)
SaliSynt	Salicylate synthetase (EC 4.2.99.21) (EC 5.4.4.2)
SaliSyntSideBios	Salicylate synthetase (EC 4.2.99.21) of siderophore biosynthesis (EC 5.4.4.2)
SamDepeMeth	SAM-dependent methyltransferase (EC 2.1.1.-)
SamDepeMeth2Clus	SAM-dependent methyltransferase 2, in cluster with Hydroxyacylglutathione hydrolase (EC 3.1.2.6)
SamDepeMethBiocLike	SAM-dependent methyltransferase, BioC-like
SamDepeMethDsy4n1	SAM-dependent methyltransferase DSY4148 (UbiE paralog)
SamDepeMethHi00n1	SAM-dependent methyltransferase HI0095 (UbiE paralog)
SamDepeMethSco3n1	SAM-dependent methyltransferase SCO3452 (UbiE paralog)
SamDepeMethSll0n1	SAM-dependent methyltransferase sll0829 (UbiE paralog)
SamDepeMethYafe	SAM-dependent methyltransferase YafE (UbiE paralog)
SarcNMeth	Sarcosine N-methyltransferase (EC 2.1.1.157)
SarcOxidAlphSubu	Sarcosine oxidase alpha subunit (EC 1.5.3.1)
SarcOxidBetaSubu	Sarcosine oxidase beta subunit (EC 1.5.3.1)
SarcOxidDeltSubu	Sarcosine oxidase delta subunit (EC 1.5.3.1)
SarcOxidGammSubu	Sarcosine oxidase gamma subunit (EC 1.5.3.1)
SarcReduCompBAlph	Sarcosine reductase component B alpha subunit (EC 1.21.4.3)
SarcReduCompBBeta	Sarcosine reductase component B beta subunit (EC 1.21.4.3)
Sav0HomoWithEsat	SAV0291 homolog within ESAT-6 gene cluster
ScafProtBactA118n1	Scaffolding protein [Bacteriophage A118]
Scc1Prot	Scc1 protein (Type III secretion chaperone)
Sco1SencFamiProt2	SCO1/SenC family protein associated with Copper-containing nitrite reductase
SeciBindProt2n1	SECIS-binding protein 2
SecrAlkaMetaPrta	Secreted alkaline metalloproteinase, PrtA/B/C/G homolog (EC 3.4.24.-)
SecrCyanCphe	Secreted cyanophycinase CphE (EC 3.4.15.6)
SecrProtEarSupeEnco	Secreted protein Ear, superantigen-encoding pathogenicity islands SaPI
SecrProtEspaComp	Secreted protein EspA, component of Type VII secretion system ESX-1
SecrProtEspbComp	Secreted protein EspB, component of Type VII secretion system ESX-1
SecrProtEspcComp	Secreted protein EspC, component of Type VII secretion system ESX-1
SecrProtEspeComp	Secreted protein EspE, component of Type VII secretion system ESX-1
SecrProtEspfComp	Secreted protein EspF, component of Type VII secretion system ESX-1
SecrProtSuppForCopp	Secreted protein, suppressor for copper-sensitivity ScsC
SecrSporCoatAsso	Secreted and spore coat-associated protein 3, similar to biofilm matrix component TasA and to camelysin
SecrSporCoatAsso2	Secreted and spore coat-associated protein 1, similar to biofilm matrix component TasA and to camelysin
SecrSporCoatAsso3	Secreted and spore coat-associated protein 2, similar to biofilm matrix component TasA and to camelysin
SecrSystEffeSsee	Secretion system effector SseE
SecrVonWillFactBind	Secreted von Willebrand factor-binding protein VWbp
Sedo17Bisp	Sedoheptulose-1,7-bisphosphatase (EC 3.1.3.37)
SegrCondProt	Segregation and condensation protein A
SegrCondProtB	Segregation and condensation protein B
SeleCont	selenocysteine-containing
SeleDepeMolyHydr	Selenium-dependent molybdenum hydroxylase system protein YqeB
SeleDepeTrna2Sele	Selenophosphate-dependent tRNA 2-selenouridine synthase
SeleOCystContHomo	Selenoprotein O and cysteine-containing homologs
SeleSpecTranElon	Selenocysteine-specific translation elongation factor
SeleWateDiki	Selenide,water dikinase (EC 2.7.9.3)
SensHistKinaChvg	Sensor histidine kinase ChvG (EC 2.7.3.-)
SensHistKinaClus	Sensor histidine kinase in cluster with mercury reductase
SensHistKinaColo	Sensor histidine kinase colocalized with HrtAB transporter
SensHistKinaCqss	Sensor histidine kinase CqsS
SensHistKinaCrec	Sensory histidine kinase CreC of two-component signal transduction system CreBC
SensHistKinaGlrk	Sensor histidine kinase GlrK
SensHistKinaLias	Sensor histidine kinase LiaS
SensHistKinaMgTran	Sensor histidine kinase in Mg(2+) transport ATPase cluster
SensHistKinaPrls	Sensor histidine kinase PrlS
SensHistKinaQsec	Sensory histidine kinase QseC
SensHistKinaRcsc	Sensor histidine kinase RcsC (EC 2.7.13.3)
SensHistKinaTwoComp	Sensory histidine kinase in two-component regulatory system with RstA
SensHistKinaVras	Sensor histidine kinase VraS
SensHistProtKina3	Sensor histidine protein kinase SaeS (exoprotein expression protein S) (EC 2.7.13.3)
SensProtBass	Sensor protein BasS (activates BasR)
SensProtDegs	sensor protein degS (EC 2.7.3.- )
SensProtZincSigm	Sensor protein of zinc sigma-54-dependent two-component system
SepiRedu	Sepiapterin reductase (EC 1.1.1.153)
SeptAssoCellDivi	Septum-associated cell division protein DedD
SeptAssoCellDivi2	Septum-associated cell division protein DamX
SeptAssoRareLipo	Septum-associated rare lipoprotein A
SeptFormProtMaf	Septum formation protein Maf
SeptRingFormRegu	Septation ring formation regulator EzrA
SeptSiteDeteProt	Septum site-determining protein MinD
SeptSiteDeteProt2	Septum site-determining protein MinC
SeqaProtNegaModu	SeqA protein, negative modulator of initiation of replication
SerThrProtPhosFami3	Ser/Thr protein phosphatase family protein, UDP-2,3-diacylglucosamine hydrolase homolog (EC 3.6.1.54)
SerTrnaDeac	Ser-tRNA(Ala) deacylase
SeriAcet	Serine acetyltransferase (EC 2.3.1.30)
SeriGlyoAmin	Serine--glyoxylate aminotransferase (EC 2.6.1.45)
SeriHydr	Serine hydroxymethyltransferase (EC 2.1.2.1)
SeriPalm	Serine palmitoyltransferase (EC 2.3.1.50)
SeriPalmSubuLcb1n1	Serine palmitoyltransferase, subunit LCB1 (EC 2.3.1.50)
SeriPalmSubuLcb2n1	Serine palmitoyltransferase, subunit LCB2 (EC 2.3.1.50)
SeriPhosRsbuRegu	Serine phosphatase RsbU, regulator of sigma subunit
SeriProtDegpHtra	Serine protease, DegP/HtrA, do-like (EC 3.4.21.-)
SeriProtHtra	Serine protease HtrA (DegP protein)
SeriProtKinaPLoop	Serine protein kinase (prkA protein), P-loop containing
SeriProtKinaRsbw	Serine-protein kinase RsbW (EC 2.7.11.1)
SeriProtMycoMycp	Serine protease mycosin MycP4, component of Type VII secretion system ESX-4
SeriProtMycoMycp2	Serine protease mycosin MycP3, component of Type VII secretion system ESX-3
SeriProtMycoMycp3	Serine protease mycosin MycP1, component of Type VII secretion system ESX-1
SeriProtMycoMycp4	Serine protease mycosin MycP5, component of Type VII secretion system ESX-5
SeriProtMycoMycp5	Serine protease mycosin MycP2, component of Type VII secretion system ESX-2
SeriProtPutaComp	Serine protease, putative component of Type VII secretion system in Actinobacteria
SeriPyruAmin	Serine--pyruvate aminotransferase (EC 2.6.1.51)
SeriPyruAminArch	Serine-pyruvate aminotransferase/archaeal aspartate aminotransferase
SeriRace	Serine racemase (EC 5.1.1.18)
SeriThreProtKina17	Serine/threonine-protein kinase RIO2 (EC 2.7.11.1)
SeriThreProtKina4	Serine/threonine protein kinase PrkC, regulator of stationary phase
SeriThreProtKina5	Serine/threonine-protein kinase RIO1 (EC 2.7.11.1)
SeriThreProtKina56	Serine/threonine protein kinase PrkC, regulator of stationary phase, short form
SeriThreProtKina60	Serine/threonine-protein kinase YabT (EC 2.7.11.1)
SeriTran	Serine transporter
Serr	Serralysin (EC 3.4.24.40)
SeryTrnaSynt	Seryl-tRNA synthetase (EC 6.1.1.11)
SeryTrnaSyntArch	Seryl-tRNA synthetase, archaeal (EC 6.1.1.11)
SgrrSugaPhosStre	SgrR, sugar-phosphate stress, transcriptional activator of SgrS small RNA
ShigToxiISubu	Shiga toxin I subunit A (EC 3.2.2.22)
ShigToxiISubuB	Shiga toxin I subunit B
ShigToxiIiSubu	Shiga toxin II subunit A (EC 3.2.2.22)
ShigToxiIiSubuB	Shiga toxin II subunit B
Shik5DehyIAlph	Shikimate 5-dehydrogenase I alpha (EC 1.1.1.25)
Shik5DehyIGamm	Shikimate 5-dehydrogenase I gamma (EC 1.1.1.25)
ShikDhLikeProtAsso	Shikimate DH-like protein associated with RibB
ShikKinaI	Shikimate kinase I (EC 2.7.1.71)
ShikKinaIi	Shikimate kinase II (EC 2.7.1.71)
ShikKinaIii	Shikimate kinase III (EC 2.7.1.71)
ShikQuin5DehyIBeta	Shikimate/quinate 5-dehydrogenase I beta (EC 1.1.1.282)
ShorChaiAlcoDehy7	Short-chain alcohol dehydrogenase associated with acetoin utilization
ShorChaiDehyRedu	short-chain dehydrogenase/reductase SDR (EC 1.1.1.275 )
ShorChaiDehyRedu2	Short-chain dehydrogenase/reductase in hypothetical Actinobacterial gene cluster
ShufSpecDnaReco	Shufflon-specific DNA recombinase
SialAcidTranNant	Sialic acid transporter (permease) NanT
SialAcidUtilRegu	Sialic acid utilization regulator, RpiR family
SideAchrAbcTranAtpa	Siderophore achromobactin ABC transporter, ATPase component
SideAchrAbcTranPerm	Siderophore achromobactin ABC transporter, permease protein
SideAchrAbcTranSubs	Siderophore achromobactin ABC transporter, substrate-binding protein
SideAlcaBiosComp	Siderophore [Alcaligin] biosynthesis complex, short chain
SideAlcaBiosComp2	Siderophore [Alcaligin] biosynthesis complex, long chain
SideAlcaBiosEnzy	Siderophore [Alcaligin] biosynthetic enzyme (EC 1.14.13.59)
SideAlcaLikeBios	Siderophore [Alcaligin-like] biosynthesis complex, short chain
SideAlcaLikeBios2	Siderophore [Alcaligin-like] biosynthesis complex, long chain
SideAlcaLikeBios3	Siderophore [Alcaligin-like] biosynthesis complex, medium chain
SideAlcaLikeBios4	Siderophore [Alcaligin-like] biosynthetic enzyme (EC 1.14.13.59)
SideAlcaLikeDeca	Siderophore [Alcaligin-like] decarboxylase (EC 4.1.1.-)
SideAlcaTranAlcs	Siderophore [Alcaligin] translocase AlcS
SideBiosDiam2Oxog	Siderophore biosynthesis diaminobutyrate--2-oxoglutarate aminotransferase (EC 2.6.1.76)
SideBiosL24DiamDeca	Siderophore biosynthesis L-2,4-diaminobutyrate decarboxylase
SideBiosNonRiboPept	Siderophore biosynthesis non-ribosomal peptide synthetase modules
SideBiosProtMono	Siderophore biosynthesis protein, monooxygenase
SideRelaPerm	Siderophore related permease
SideStapAbcTranAtp	Siderophore staphylobactin ABC transporter, ATP-binding protein, putative
SideStapAbcTranPerm	Siderophore staphylobactin ABC transporter, permease protein SirB, putative
SideStapAbcTranPerm2	Siderophore staphylobactin ABC transporter, permease protein SirC, putative
SideStapAbcTranPerm3	Siderophore staphylobactin ABC transporter, permease protein SirB
SideStapAbcTranPerm4	Siderophore staphylobactin ABC transporter, permease protein SirC
SideStapAbcTranSubs	Siderophore staphylobactin ABC transporter, substrate-binding protein SirA, putative
SideStapAbcTranSubs2	Siderophore staphylobactin ABC transporter, substrate-binding protein SirA
SideStapBiosProt	Siderophore staphylobactin biosynthesis protein SbnC
SideStapBiosProt10	Siderophore staphylobactin biosynthesis protein SbnF
SideStapBiosProt2	Siderophore staphylobactin biosynthesis protein SbnE
SideStapBiosProt4	Siderophore staphylobactin biosynthesis protein SbnG
SideStapBiosProt5	Siderophore staphylobactin biosynthesis protein SbnB, cyclodeaminase
SideStapBiosProt6	Siderophore staphylobactin biosynthesis protein SbnI
SideStapBiosProt7	Siderophore staphylobactin biosynthesis protein SbnH
SideStapBiosProt8	Siderophore staphylobactin biosynthesis protein SbnA
SideStapBiosProt9	Siderophore staphylobactin biosynthesis protein SbnD
SideSyntCompLiga	Siderophore synthetase component, ligase
SideSyntLargComp	Siderophore synthetase large component, acetyltransferase
SideSyntSmalComp	Siderophore synthetase small component, acetyltransferase
SideTranProt	Siderophore transport protein
Sigm54DepeDnaBind4	Sigma-54 dependent DNA-binding transcriptional regulator
Sigm54DepeTranRegu10	Sigma-54 dependent transcriptional regulator clustered with pyruvate formate-lyase
Sigm70FactFpviCont	Sigma-70 factor FpvI (ECF subfamily), controling pyoverdin biosynthesis
SigmFactPvdsCont	Sigma factor PvdS, controling pyoverdin biosynthesis
SigmFactReguVrer	Sigma factor regulator VreR (cytoplasmic membrane-localized) of trans-envelope signaling system
SignPeptI	Signal peptidase I (EC 3.4.21.89)
SignPeptLikeProt	Signal peptidase-like protein
SignPeptPeptSppa	Signal peptide peptidase SppA (protease 4)
SignPeptSipwRequ	Signal peptidase SipW, required for TasA secretion (EC 3.4.21.89)
SignPeptTypeIvPrep	Signal peptidase, type IV - prepilin/preflagellin
SignRecoPartAsso	Signal recognition particle associated protein
SignRecoPartProt	Signal recognition particle protein Ffh
SignRecoPartRece2	Signal recognition particle receptor FtsY
SignTranHistProt	Signal transduction histidine-protein kinase BarA (EC 2.7.13.3)
SignTranHistProt5	Signal transduction histidine-protein kinase AtoS ## response regulator AtoC (EC 2.7.13.3)
SignTranProtTrap	Signal transduction protein TRAP (Target of RNAIII-activating protein)
SimiCarbMonoDehy3	Similar to carbon monoxide dehydrogenase corrinoid/iron-sulfur protein
SimiCarbMonoDehy4	Similar to carbon monoxide dehydrogenase CooS subunit
SimiCdpGluc46Dehy	Similar to CDP-glucose 4,6-dehydratase (EC 4.2.1.45)
SimiCoenPqqSyntProt	Similar to coenzyme PQQ synthesis protein B
SimiCytoCTypeBiog2	Similar to cytochrome c-type biogenesis protein CcsA/ResC
SimiCytoChapTord	Similar to cytoplasmic chaperone TorD
SimiEukaPeptProl	Similar to eukaryotic Peptidyl prolyl 4-hydroxylase, alpha subunit (EC 1.14.11.2)
SimiFlagAsseFact	Similar to flagellar assembly factor FliW
SimiGlutCystLiga	Similar to Glutamate--cysteine ligase, function unknown (EC 6.3.2.2)
SimiGlutSynt	Similar to Glutathione synthetase (EC 6.3.2.3)
SimiGlycCleaSyst	Similar to Glycine cleavage system H protein
SimiHypoProtDuf4n1	Similar to hypothetical protein DUF454
SimiImidGlycPhos	Similar to imidazole glycerol phosphate synthase amidotransferase subunit (LPS cluster)
SimiImidGlycPhos2	Similar to imidazole glycerol phosphate synthase cyclase subunit (LPS cluster)
SimiImidGlycPhos3	Similar to imidazole glycerol phosphate synthase cyclase subunit (LPS cluster), type 2
SimiPhosPhosClus	Similar to phosphoglycolate phosphatase, clustered with ribosomal large subunit pseudouridine synthase C
SimiPhosPhosClus2	Similar to phosphoglycolate phosphatase, clustered with ubiquinone biosynthesis SAM-dependent O-methyltransferase
SimiRiboLargSubu	Similar to ribosomal large subunit pseudouridine synthase D, Bacillus subtilis YjbO type
SimiRiboProtL11p	Similar to ribosomal protein L11p
SimiRibu15BispCarb	similar to ribulose-1,5-bisphosphate carboxylase, Type III
SimiRibu15BispCarb2	similar to ribulose-1,5-bisphosphate carboxylase, Type III, too
SimiSecrRcpaCpac	Similar to secretin RcpA/CpaC, associated with Flp pilus assembly
SimiSulfReduAsso	Similar to sulfite reduction-associated protein DsrK
SimiTadzCpaeAsso	Similar to TadZ/CpaE, associated with Flp pilus assembly
SimiTermSmalSubu	Similar to terminase small subunit, yqaS homolog
SimiTrnaPseuSynt	Similar to tRNA pseudouridine synthase A, group TruA2
SimiTrnaPseuSynt3	Similar to tRNA pseudouridine synthase C, group TruC1
SimiTrnaPseuSynt4	Similar to tRNA pseudouridine synthase A, group TruA3
SimiWithGlutSynt	Similarity with glutathionylspermidine synthase, group 1 (EC 6.3.1.8)
SimiWithGlutSynt2	Similarity with glutathionylspermidine synthase, group 2 (EC 6.3.1.8)
SimiWithYeasTran	Similarity with yeast transcription factor IIIC Tau subunit that binds B-block elements of class III promoters
SingStraDnaBindProt	Single-stranded DNA-binding protein
SingStraDnaBindProt5	Single-stranded DNA-binding protein in PFGI-1-like cluster
SingStraDnaBindProt6	Single-stranded DNA-binding protein (prophage associated)
SingStraDnaBindProt9	Single-stranded DNA-binding protein, phage associated
SingStraDnaSpecExon	Single-stranded-DNA-specific exonuclease RecJ (EC 3.1.-.-)
SingStraDnaSpecExon2	Single-stranded-DNA-specific exonuclease RecJ, cyanobacterial paralog
SingStraDnaSpecExon3	Single-stranded-DNA-specific exonuclease RecJ, clostridial paralog
SingStraDnaSpecExon5	Single-stranded-DNA-specific exonuclease RecJ, Bacteriophage SPBc2-type
SingStraExonAsso	Single-stranded exonuclease associated with Rad50/Mre11 complex
SiniProtAntaSinr	SinI protein, antagonist of SinR
SinrReguPostExpo	SinR, regulator of post-exponential-phase responses genes (competence and sporulation)
SiroCoba	Sirohydrochlorin cobaltochelatase (EC 4.99.1.3)
SiroCobaCbik	Sirohydrochlorin cobaltochelatase CbiK (EC 4.99.1.3)
SiroCobaCbix	Sirohydrochlorin cobaltochelatase CbiX(long) (EC 4.99.1.3)
SiroCobaCbix2	Sirohydrochlorin cobaltochelatase CbiX(small) (EC 4.99.1.3)
SiroDecaAhbaAlte	Siroheme decarboxylase AhbA, alternate heme biosynthesis pathway
SiroDecaAhbbAlte	Siroheme decarboxylase AhbB, alternate heme biosynthesis pathway
SiroFerrActiCbik	Sirohydrochlorin ferrochelatase activity of CbiK (EC 4.99.1.4)
SiroFerrActiCysg	Sirohydrochlorin ferrochelatase activity of CysG (EC 4.99.1.4)
SiroFerrCbixAlph	Sirohydrochlorin ferrochelatase CbiX, alphaprotobacterial (EC 4.99.1.4)
SiroFerrSirb	Sirohydrochlorin ferrochelatase SirB (EC 4.99.1.4)
SiteSpecTyroReco	Site-specific tyrosine recombinase
SiteSpecTyroReco2	Site-specific tyrosine recombinase XerC
SiteSpecTyroReco3	Site-specific tyrosine recombinase XerD
SlrPosiReguExtrMatr	Slr, positive regulator of the extracellular matrix biosynthesis operon yqxM-sipW-tasA
SmalAcidSoluSpor5	Small acid-soluble spore protein
SmalMultResiProt	Small multidrug resistance protein BA0833
SmalMultResiProt2	Small multidrug resistance protein BA0832
SmalMultResiProt6	Small multidrug resistance protein Bsu YvdR
SmalMultResiProt7	Small multidrug resistance protein Bsu YvdS
SmalNuclRiboF	Small nuclear ribonucleoprotein F
SmalPrimLikeProt	Small primase-like proteins (Toprim domain)
SmalRasLikeGtpaComp	Small Ras-like GTPase, component of G-protein-coupled receptor (GPCR) system
SmalSecrProtWxg1n1	Small secreted protein of WXG100 family, Type VII secretion target
SmcPept	SMC peptidase
Snap	Snapalysin (EC 3.4.24.77)
SodiDepePhosTran	Sodium-dependent phosphate transporter
SodiGlutSymp	Sodium/glutamate symporter
SodiGlycSympGlyp	Sodium/glycine symporter GlyP
SodiMyoInosCotr	Sodium/myo-inositol cotransporter
SodiSugaCotr	Sodium/sugar cotransporter
SodiTranAtpaSubu	Sodium-transporting ATPase subunit R
SodiTranAtpaSubu2	Sodium-transporting ATPase subunit F
SodiTranAtpaSubu3	Sodium-transporting ATPase subunit C
SodiTranAtpaSubu4	Sodium-transporting ATPase subunit Q
SodiTranAtpaSubu5	Sodium-transporting ATPase subunit G
SodiTranAtpaSubu6	Sodium-transporting ATPase subunit A
SodiTranAtpaSubu7	Sodium-transporting ATPase subunit E
SodiTranAtpaSubu8	Sodium-transporting ATPase subunit B
SodiTranAtpaSubu9	Sodium-transporting ATPase subunit D
SojParaRelaProt	Soj/ParA-related protein
SoluAldoSugaDehy	Soluble aldose sugar dehydrogenase, PQQ-dependent (EC 1.1.5.-)
SoluPyriNuclTran	Soluble pyridine nucleotide transhydrogenase (EC 1.6.1.1)
SorbDehy	Sorbitol dehydrogenase (EC 1.1.1.14)
SortLpxtSpec	Sortase A, LPXTG specific
SosRespReprProtLexa	SOS-response repressor and protease LexA (EC 3.4.21.88)
Spec9OAden	Spectinomycin 9-O-adenylyltransferase
SperExpoProtMdti	Spermidine export protein MdtI
SperExpoProtMdtj	Spermidine export protein MdtJ
SperN1Acet	Spermidine N1-acetyltransferase (EC 2.3.1.57)
SperPutrAbcTranPerm2	Spermidine Putrescine ABC transporter permease component PotB (TC 3.A.1.11.1)
SperPutrImpoAbcTran	Spermidine/putrescine import ABC transporter ATP-binding protein PotA (TC 3.A.1.11.1)
SperPutrImpoAbcTran3	Spermidine/putrescine import ABC transporter permease protein PotC (TC 3.A.1.11.1)
SperPutrImpoAbcTran4	Spermidine/putrescine import ABC transporter substrate-binding protein PotD (TC 3.A.1.11.1)
SperSynt	Spermidine synthase (EC 2.5.1.16)
SpheMono	Spheroidene monooxygenase (EC 1.14.15.9)
SphiAlphHydr	Sphingolipid (S)-alpha-hydroxylase (no EC)
SphiAlphHydrFah1n1	Sphingolipid (R)-alpha-hydroxylase FAH1 (no EC)
SphiLongChaiBase	Sphingoid long chain base kinase (EC 2.7.1.91)
Spi1AssoTranRegu	SPI1-associated transcriptional regulator SprB
Spo0LikePutaSpor	Spo0E-like putative sporulation regulatory protein in grePA-PF operon
SporAssoProtNTerm	Sporulation-associated protease N-terminal domain protein
SporCoatProtCoty	Spore coat protein of CotY/CotZ family
SporCortBiosProt	Spore cortex biosynthesis protein
SporCortLytiEnzy	Spore cortex-lytic enzyme CwlJ
SporCortLytiEnzy2	Spore cortex-lytic enzyme, N-acetylglucosaminidase SleL (EC 3.2.1.-)
SporCortLytiEnzy3	Spore cortex-lytic enzyme, lytic transglycosylase SleB
SporDelaProt	Sporulation delaying protein (cannibalism toxin)
SporDelaProtSdpa	Sporulation-delaying protein SdpA
SporDelaProtSdpb	Sporulation-delaying protein sdpB
SporGermEndoGpr	Spore germination endopeptidase Gpr (EC 3.4.24.78)
SporGermProtGerd	Spore germination protein GerD
SporGermProtYpeb	Spore germination protein YpeB
SporInitPhos	Sporulation initiation phosphotransferase (Spo0F)
SporInitPhosB	Sporulation initiation phosphotransferase B (Spo0B)
SporKina2	Sporulation kinase A (EC 2.7.13.3)
SporKinaB	Sporulation kinase B (EC 2.7.13.3)
SporKinaC	Sporulation kinase C (EC 2.7.13.3)
SporProtGerwNotInvo	Spore protein GerW (YtfJ), not involved in spore germination
SporProtYdhdNotInvo	Spore protein YdhD, not involved in spore germination
SporProtYtfj	Sporulation protein YtfJ
SporProtYtfjBaci	Sporulation protein, YTFJ Bacillus subtilis ortholog
SporSigmEFactProc	Sporulation sigma-E factor processing peptidase (SpoIIGA)
SporSpecProtYabg	Sporulation-specific protease YabG
SporSynt	Sporulenol synthase (EC 4.2.1.137)
SpovRelaProtType2	SpoVS-related protein, type 4
SpovRelaProtType3	SpoVS-related protein, type 5
SpovRelaProtType4	SpoVS-related protein, type 3
SpovRelaProtType5	SpoVS-related protein, type 2
SpovRelaProtType6	SpoVS-related protein, type 1
SquaHopaCycl	Squalene---hopanol cyclase (EC 4.2.1.129)
SrabRna	SraB RNA
SsbProtSaBact11Mu50n1	Ssb protein [SA bacteriophages 11, Mu50B]
SsnaProt	SsnA protein
SsuRiboProtMrp1Mito	SSU ribosomal protein MRP1, mitochondrial
SsuRiboProtMrp1Mito2	SSU ribosomal protein MRP13, mitochondrial
SsuRiboProtMrp1Mito3	SSU ribosomal protein MRP10, mitochondrial
SsuRiboProtPet1Mito	SSU ribosomal protein PET123, mitochondrial
SsuRiboProtRsm2Mito	SSU ribosomal protein RSM22, mitochondrial
SsuRiboProtRsm2Mito2	SSU ribosomal protein RSM28, mitochondrial
SsuRiboProtRsm2Mito3	SSU ribosomal protein RSM24, mitochondrial
SsuRiboProtRsm2Mito4	SSU ribosomal protein RSM25, mitochondrial
SsuRiboProtS10e	SSU ribosomal protein S10e
SsuRiboProtS10p	SSU ribosomal protein S10p (S20e)
SsuRiboProtS10pMito	SSU ribosomal protein S10p (S20e), mitochondrial
SsuRiboProtS11e	SSU ribosomal protein S11e (S17p)
SsuRiboProtS11p	SSU ribosomal protein S11p (S14e)
SsuRiboProtS11pMito	SSU ribosomal protein S11p (S14e), mitochondrial
SsuRiboProtS12e	SSU ribosomal protein S12e
SsuRiboProtS12p	SSU ribosomal protein S12p (S23e)
SsuRiboProtS12pMito	SSU ribosomal protein S12p (S23e), mitochondrial
SsuRiboProtS13e	SSU ribosomal protein S13e (S15p)
SsuRiboProtS13p	SSU ribosomal protein S13p (S18e)
SsuRiboProtS13pMito	SSU ribosomal protein S13p (S18e), mitochondrial
SsuRiboProtS14e	SSU ribosomal protein S14e (S11p)
SsuRiboProtS14p	SSU ribosomal protein S14p (S29e)
SsuRiboProtS14pMito	SSU ribosomal protein S14p (S29e), mitochondrial
SsuRiboProtS14pZinc	SSU ribosomal protein S14p (S29e), zinc-independent
SsuRiboProtS14pZinc2	SSU ribosomal protein S14p (S29e), zinc-dependent
SsuRiboProtS15a	SSU ribosomal protein S15Ae (S8p)
SsuRiboProtS15e	SSU ribosomal protein S15e (S19p)
SsuRiboProtS15p	SSU ribosomal protein S15p (S13e)
SsuRiboProtS15pMito	SSU ribosomal protein S15p (S13e), mitochondrial
SsuRiboProtS16e	SSU ribosomal protein S16e (S9p)
SsuRiboProtS16p	SSU ribosomal protein S16p
SsuRiboProtS16pMito	SSU ribosomal protein S16p, mitochondrial
SsuRiboProtS17e	SSU ribosomal protein S17e
SsuRiboProtS17p	SSU ribosomal protein S17p (S11e)
SsuRiboProtS17pMito	SSU ribosomal protein S17p (S11e), mitochondrial
SsuRiboProtS18e	SSU ribosomal protein S18e (S13p)
SsuRiboProtS18p	SSU ribosomal protein S18p
SsuRiboProtS18pMito	SSU ribosomal protein S18p, mitochondrial
SsuRiboProtS18pZinc	SSU ribosomal protein S18p, zinc-independent
SsuRiboProtS18pZinc2	SSU ribosomal protein S18p, zinc-dependent
SsuRiboProtS19e	SSU ribosomal protein S19e
SsuRiboProtS19p	SSU ribosomal protein S19p (S15e)
SsuRiboProtS19pMito	SSU ribosomal protein S19p (S15e), mitochondrial
SsuRiboProtS20e	SSU ribosomal protein S20e (S10p)
SsuRiboProtS20p	SSU ribosomal protein S20p
SsuRiboProtS21e	SSU ribosomal protein S21e
SsuRiboProtS21p	SSU ribosomal protein S21p
SsuRiboProtS21pMito	SSU ribosomal protein S21p, mitochondrial
SsuRiboProtS22mMito	SSU ribosomal protein S22mt, mitochondrial
SsuRiboProtS23e	SSU ribosomal protein S23e (S12p)
SsuRiboProtS23mMito	SSU ribosomal protein S23mt, mitochondrial
SsuRiboProtS24e	SSU ribosomal protein S24e
SsuRiboProtS24mMito	SSU ribosomal protein S24mt, mitochondrial
SsuRiboProtS25e	SSU ribosomal protein S25e
SsuRiboProtS25mMito	SSU ribosomal protein S25mt, mitochondrial
SsuRiboProtS26e	SSU ribosomal protein S26e
SsuRiboProtS26mMito	SSU ribosomal protein S26mt, mitochondrial
SsuRiboProtS27a	SSU ribosomal protein S27Ae
SsuRiboProtS27e	SSU ribosomal protein S27e
SsuRiboProtS27mMito	SSU ribosomal protein S27mt, mitochondrial
SsuRiboProtS28e	SSU ribosomal protein S28e
SsuRiboProtS28mMito	SSU ribosomal protein S28mt, mitochondrial
SsuRiboProtS29e	SSU ribosomal protein S29e (S14p)
SsuRiboProtS29mMito	SSU ribosomal protein S29mt, mitochondrial
SsuRiboProtS2e	SSU ribosomal protein S2e (S5p)
SsuRiboProtS2p	SSU ribosomal protein S2p (SAe)
SsuRiboProtS2pMito	SSU ribosomal protein S2p (SAe), mitochondrial
SsuRiboProtS30e	SSU ribosomal protein S30e
SsuRiboProtS30mMito	SSU ribosomal protein S30mt, mitochondrial
SsuRiboProtS31mMito	SSU ribosomal protein S31mt, mitochondrial
SsuRiboProtS33mMito	SSU ribosomal protein S33mt, mitochondrial
SsuRiboProtS34mMito	SSU ribosomal protein S34mt, mitochondrial
SsuRiboProtS35mMito	SSU ribosomal protein S35mt, mitochondrial
SsuRiboProtS3ae	SSU ribosomal protein S3Ae
SsuRiboProtS3e	SSU ribosomal protein S3e (S3p)
SsuRiboProtS3p	SSU ribosomal protein S3p (S3e)
SsuRiboProtS3pMito	SSU ribosomal protein S3p (S3e), mitochondrial
SsuRiboProtS4e	SSU ribosomal protein S4e
SsuRiboProtS4pMito	SSU ribosomal protein S4p (S9e), mitochondrial
SsuRiboProtS5e	SSU ribosomal protein S5e (S7p)
SsuRiboProtS5p	SSU ribosomal protein S5p (S2e)
SsuRiboProtS5pMito	SSU ribosomal protein S5p (S2e), mitochondrial
SsuRiboProtS6e	SSU ribosomal protein S6e
SsuRiboProtS6p	SSU ribosomal protein S6p
SsuRiboProtS6pMito	SSU ribosomal protein S6p, mitochondrial
SsuRiboProtS7e	SSU ribosomal protein S7e
SsuRiboProtS7p	SSU ribosomal protein S7p (S5e)
SsuRiboProtS7pMito	SSU ribosomal protein S7p (S5e), mitochondrial
SsuRiboProtS8e	SSU ribosomal protein S8e
SsuRiboProtS8p	SSU ribosomal protein S8p (S15Ae)
SsuRiboProtS8pMito	SSU ribosomal protein S8p (S15Ae), mitochondrial
SsuRiboProtS9e	SSU ribosomal protein S9e (S4p)
SsuRiboProtS9p	SSU ribosomal protein S9p (S16e)
SsuRiboProtS9pMito	SSU ribosomal protein S9p (S16e), mitochondrial
SsuRiboProtSae	SSU ribosomal protein SAe (S2p)
SsuRiboProtVar1Mito	SSU ribosomal protein VAR1, mitochondrial
SsuRrna	SSU rRNA
SsuRrnaNAdenNDime	SSU rRNA (adenine(1518)-N(6)/adenine(1519)-N(6))-dimethyltransferase (EC 2.1.1.182)
Stag0SporProtYaat	Stage 0 sporulation protein YaaT
Stag0SporTwoComp	Stage 0 sporulation two-component response regulator (Spo0A)
StagIiSporProtB	Stage II sporulation protein B
StagIiSporProtD	Stage II sporulation protein D (SpoIID)
StagIiSporProtD2	stage II sporulation protein D
StagIiSporProtM	Stage II sporulation protein M (SpoIIM)
StagIiSporProtP	Stage II sporulation protein P
StagIiSporProtRela	Stage II sporulation protein related to metaloproteases (SpoIIQ)
StagIiSporProtRequ	Stage II sporulation protein required for processing of pro-sigma-E (SpoIIR)
StagIiSporSeriPhos	Stage II sporulation serine phosphatase for sigma-F activation (SpoIIE)
StagIiiSporProtAa	Stage III sporulation protein AA
StagIiiSporProtAb	Stage III sporulation protein AB
StagIiiSporProtAc	Stage III sporulation protein AC
StagIiiSporProtAd	Stage III sporulation protein AD
StagIiiSporProtAe	Stage III sporulation protein AE
StagIiiSporProtAf	Stage III sporulation protein AF
StagIiiSporProtAg	Stage III sporulation protein AG
StagIiiSporProtAh	Stage III sporulation protein AH
StagIiiSporProtD	Stage III sporulation protein D
StagIvSporProSigm	Stage IV sporulation pro-sigma-K processing enzyme (SpoIVFB)
StagIvSporProt	Stage IV sporulation protein A
StagIvSporProtB	Stage IV sporulation protein B
StagIvSporProtFa	Stage IV sporulation protein FA (SpoIVFA)
StagVSporProtAa	Stage V sporulation protein AA (SpoVAA)
StagVSporProtAb	Stage V sporulation protein AB (SpoVAB)
StagVSporProtAc	Stage V sporulation protein AC (SpoVAC)
StagVSporProtAd	Stage V sporulation protein AD (SpoVAD)
StagVSporProtAe1n1	Stage V sporulation protein AE1 (SpoVAE1)
StagVSporProtAe2n1	Stage V sporulation protein AE2 (SpoVAE2)
StagVSporProtAf	Stage V sporulation protein AF (SpoVAF)
StagVSporProtAfPara	Stage V sporulation protein AF paralog
StagVSporProtB	stage V sporulation protein B
StagVSporProtD2	Stage V sporulation protein D (Sporulation-specific penicillin-binding protein)
StagVSporProtE	Stage V sporulation protein E
StagVSporProtInvo	Stage V sporulation protein involved in spore cortex synthesis (SpoVR)
StagVSporProtRequ	Stage V sporulation protein required for dehydratation of the spore core and assembly of the coat (SpoVS)
StagVSporProtRequ2	Stage V sporulation protein required for normal spore cortex and coat synthesis (SpoVM)
StagVSporProtTAbrb	Stage V sporulation protein T, AbrB family transcriptional regulator (SpoVT)
StagVSporProtWhos	Stage V sporulation protein whose disruption leads to the production of immature spores (SpoVK)
StagViSporProtD	Stage VI sporulation protein D
Stap2	Staphylocoagulase
StapAcceRegu	Staphylococcal accessory regulator A (SarA)
StapNuclDoma	Staphylococcus nuclease (SNase) domain
StapRespRespProt2	Staphylococcal respiratory response protein SrrB
StapRespRespProt3	Staphylococcal respiratory response protein SrrA
StatPhasInduRibo	Stationary-phase-induced ribosome-associated protein
StatPhasSecrProt	Stationary phase secreted protein TasA, major protein component of biofilm matrix
Stre3KinaStra	Streptomycin 3'-kinase StrA (EC 2.7.1.87)
Stre3KinaStrb	Streptomycin 3'-kinase StrB (EC 2.7.1.87)
Stre3OAden	Streptomycin 3''-O-adenylyltransferase (EC 2.7.7.47)
StreAcetSat4n1	Streptothricin acetyltransferase => sat-4
StreAcetStreLave	Streptothricin acetyltransferase, Streptomyces lavendulae type
StreCellSurfHemo	Streptococcal cell surface hemoprotein receptor Shr
StreInduProtVes	Stresses-induced protein Ves (HutD)
StreMitoExotZ	Streptococcal mitogenic exotoxin Z (SmeZ)
StrePyroExot	Streptococcal pyrogenic exotoxin A (SpeA)
StrePyroExotC	Streptococcal pyrogenic exotoxin C (SpeC)
StrePyroExotG	Streptococcal pyrogenic exotoxin G (SpeG)
StrePyroExotH	Streptococcal pyrogenic exotoxin H (SpeH)
StrePyroExotI	Streptococcal pyrogenic exotoxin I (SpeI)
StrePyroExotJ	Streptococcal pyrogenic exotoxin J (SpeJ)
StreRespDiirCont	Stress response diiron-containing protein YciF
StreSBiosProt	Streptolysin S biosynthesis protein (SagF)
StreSBiosProtB	Streptolysin S biosynthesis protein B (SagB)
StreSBiosProtC	Streptolysin S biosynthesis protein C (SagC)
StreSBiosProtD	Streptolysin S biosynthesis protein D (SagD)
StreSExpoAtpBind	Streptolysin S export ATP-binding protein (SagG)
StreSExpoTranPerm	Streptolysin S export transmembrane permease (SagH)
StreSExpoTranPerm2	Streptolysin S export transmembrane permease (SagI)
StreSPrec	Streptolysin S precursor (SagA)
StreSSelfImmuProt	Streptolysin S self-immunity protein (SagE)
StruSpecTrnaBind	Structure-specific tRNA-binding protein trbp111
StruSpecTrnaBind2	Structure-specific tRNA-binding protein
SubsSpecCompBioy	Substrate-specific component BioY of biotin ECF transporter
SubsSpecCompFolt	Substrate-specific component FolT of folate ECF transporter
SubsSpecCompNiax	Substrate-specific component NiaX of predicted niacin ECF transporter
SubsSpecCompPant	Substrate-specific component PanT of predicted pantothenate ECF transporter
SubsSpecCompPdxt	Substrate-specific component PdxT of predicted pyridoxine ECF transporter
SubsSpecCompRibu	Substrate-specific component RibU of riboflavin ECF transporter
SubsSpecCompThit	Substrate-specific component ThiT of thiamin ECF transporter
SubsSpecCompThiw	Substrate-specific component ThiW of predicted thiazole ECF transporter
SubsSpecCompYkoe	Substrate-specific component YkoE of thiamin-regulated ECF transporter for HydroxyMethylPyrimidine
SubsSpecCompYkoe2	Substrate-specific component YkoE of thiamin-regulated ECF transporter for Thiamin
SubtFamiDomaProt	Subtilase family domain protein
SuccCoaBenzCoaTran	Succinyl-CoA:(R)-benzylsuccinate CoA-transferase subunit BbsE (EC 2.8.3.15)
SuccCoaBenzCoaTran2	Succinyl-CoA:(R)-benzylsuccinate CoA-transferase subunit BbsF (EC 2.8.3.15)
SuccCoaLigaAdpForm	Succinyl-CoA ligase [ADP-forming] beta chain (EC 6.2.1.5)
SuccCoaLigaAdpForm2	Succinyl-CoA ligase [ADP-forming] alpha chain (EC 6.2.1.5)
SuccCoaMalaCoaTran	Succinyl-CoA:(S)-malate CoA transferase subunit A (EC 2.8.3.22)
SuccCoaMalaCoaTran2	Succinyl-CoA:(S)-malate CoA transferase subunit B (EC 2.8.3.22)
SuccDehyCytoB556n1	Succinate dehydrogenase cytochrome b-556 subunit
SuccDehyCytoB558n1	Succinate dehydrogenase cytochrome b558 subunit
SuccDehyCytoBSubu	Succinate dehydrogenase cytochrome b subunit
SuccDehyFlavAddi	Succinate dehydrogenase flavin-adding protein, antitoxin of CptAB toxin-antitoxin
SuccDehyFlavSubu	Succinate dehydrogenase flavoprotein subunit (EC 1.3.99.1)
SuccDehyHydrMemb	Succinate dehydrogenase hydrophobic membrane anchor protein
SuccDehyIronSulf	Succinate dehydrogenase iron-sulfur protein (EC 1.3.99.1)
SuccQuinReduSubu	Succinate:quinone reductase, subunit SdhE (EC 1.3.5.1)
SuccQuinReduSubu2	Succinate:quinone reductase, subunit SdhF (EC 1.3.5.1)
SuccSemiDehyNad	Succinate-semialdehyde dehydrogenase [NAD] (EC 1.2.1.24)
SuccSemiDehyNad2	Succinate-semialdehyde dehydrogenase [NAD(P)+] (EC 1.2.1.16)
SuccSemiDehyNadp	Succinate-semialdehyde dehydrogenase [NADP+] (EC 1.2.1.16)
Sucr6PhosHydr	Sucrose-6-phosphate hydrolase (EC 3.2.1.26)
Suga1EpimYihr	Sugar-1-epimerase YihR
SugaMaltFermStim	Sugar/maltose fermentation stimulation protein homolog
SugaPhosStreProt	Sugar-phosphate stress protein SgrT (embedded in SgrS)
Sulf3	Sulfatase (EC 3.1.6.-)
SulfAcceProtSufe	Sulfur acceptor protein SufE for iron-sulfur cluster assembly
SulfAcet	Sulfoacetaldehyde acetyltransferase (EC 2.3.3.15)
SulfAden	Sulfate adenylyltransferase (EC 2.7.7.4)
SulfAdenSubu1n1	Sulfate adenylyltransferase subunit 1 (EC 2.7.7.4)
SulfAdenSubu2n1	Sulfate adenylyltransferase subunit 2 (EC 2.7.7.4)
SulfCarrProtThis	Sulfur carrier protein ThiS
SulfCarrProtThis2	Sulfur carrier protein ThiS adenylyltransferase (EC 2.7.7.73)
SulfCystCarrProt	Sulfur/cysteine carrier protein CysO
SulfDecaAlphSubu	Sulfopyruvate decarboxylase - alpha subunit (EC 4.1.1.79)
SulfDecaBetaSubu	Sulfopyruvate decarboxylase - beta subunit (EC 4.1.1.79)
SulfExpoTaueSafe	Sulfite exporter TauE/SafE
SulfMetaProtSsec	Sulfur metabolism protein SseC
SulfModiFact1Prec	Sulfatase modifying factor 1 precursor (C-alpha-formyglycine- generating enzyme 1)
SulfPerm	Sulfate permease
SulfPermTrkType	Sulfate permease, Trk-type
SulfRedoAssoProt	Sulfur redox associated protein DsrC
SulfReduAssoComp	Sulfite reduction-associated complex DsrMKJOP protein DsrK (=HmeD)
SulfReduAssoComp2	Sulfite reduction-associated complex DsrMKJOP protein DsrM (= HmeC)
SulfReduAssoComp3	Sulfite reduction-associated complex DsrMKJOP multiheme protein DsrJ (=HmeF)
SulfReduAssoComp4	Sulfite reduction-associated complex DsrMKJOP iron-sulfur protein DsrO (=HmeA)
SulfReduAssoComp5	Sulfite reduction-associated complex DsrMKJOP protein DsrP (= HmeB)
SulfReduCataSubu	Sulfoxide reductase catalytic subunit YedY
SulfReduHemeBind	Sulfoxide reductase heme-binding subunit YedZ
SulfReduNadpFlav	Sulfite reductase [NADPH] flavoprotein alpha-component (EC 1.8.1.2)
SulfReduNadpHemo	Sulfite reductase [NADPH] hemoprotein beta-component (EC 1.8.1.2)
SulfResiProt	Sulfonamide resistance protein
SulfSubuAlph	Sulfhydrogenase subunit alpha (EC 1.12.1.5)
SulfSubuBeta	Sulfhydrogenase subunit beta (EC 1.12.98.4)
SulfSubuDelt	Sulfhydrogenase subunit delta (EC 1.12.1.5)
SulfSubuGamm	Sulfhydrogenase subunit gamma (EC 1.12.98.4)
SulfSulfLyasSubu	(2R)-sulfolactate sulfo-lyase subunit beta (EC 4.4.1.24)
SulfSulfLyasSubu2	(2R)-sulfolactate sulfo-lyase subunit alpha (EC 4.4.1.24)
SulfSynt	Sulfoethylcysteine synthase
SulfThiaSynt	Sulfomethyl thiazolidine synthase
SulfThioBindProt	Sulfate and thiosulfate binding protein CysP
SulfThioImpoAtpBind	Sulfate and thiosulfate import ATP-binding protein CysA (EC 3.6.3.25)
SulfTran	Sulfur transporter
SulfTran2	Sulfate transporter (EC 4.2.1.1)
SulfTranCyszType	Sulfate transporter, CysZ-type
SulfTranFamiProt	Sulfate transporter family protein
SulfTranSystPerm	Sulfate transport system permease protein CysT
SulfTranSystPerm2	Sulfate transport system permease protein CysW
SulpAlphGluc	Sulpholipid alpha-glucosidase (proposed)
SulpNaSymp	Sulphoquinovose/Na+ symporter
SulpPori	Sulpholipid porin
SupeDismChrc	Superoxide dismutase ChrC
SupeDismCuZn	Superoxide dismutase [Cu-Zn] (EC 1.15.1.1)
SupeDismCuZnPrec	Superoxide dismutase [Cu-Zn] precursor (EC 1.15.1.1)
SupeDismFe	Superoxide dismutase [Fe] (EC 1.15.1.1)
SupeDismFeZn	Superoxide dismutase [Fe-Zn] (EC 1.15.1.1)
SupeDismMn	Superoxide dismutase [Mn] (EC 1.15.1.1)
SupeDismMnFe	Superoxide dismutase [Mn/Fe] (EC 1.15.1.1)
SupeDismSodmLike2	Superoxide dismutase SodM-like protein ChrF
SupeEnteSea	Superantigen enterotoxin SEA
SupeEnteSeb	Superantigen enterotoxin SEB
SupeEnteSec	Superantigen enterotoxin SEC
SupeEnteSed	Superantigen enterotoxin SED
SupeEnteSee	Superantigen enterotoxin SEE
SupeEnteSef	Superantigen enterotoxin SEF
SupeEnteSeg	Superantigen enterotoxin SEG
SupeEnteSeh	Superantigen enterotoxin SEH
SupeEnteSei	Superantigen enterotoxin SEI
SupeEnteSek	Superantigen enterotoxin SEK
SupeEnteSel	Superantigen enterotoxin SEL
SuppCoppSensPuta	Suppression of copper sensitivity: putative copper binding protein ScsA
SuppSigmDepeTran	Suppressor of sigma54-dependent transcription, PspA-like
SurfExclProtSea1n1	Surface exclusion protein Sea1/PrgA
SurfLocaDecaCyto	surface localized decaheme cytochrome c lipoprotein, MtrC
SurfLocaDecaCyto2	surface localized decaheme cytochrome c lipoprotein, MtrH
SurfLocaDecaCyto3	surface localized decaheme cytochrome c lipoprotein, OmcA
SurfLocaDecaCyto4	surface localized decaheme cytochrome c lipoprotein, MtrF
SurfLocaDecaCyto5	surface localized decaheme cytochrome c lipoprotein, MtrG
SurfLocaUndeCyto	surface localized undecaheme cytochrome c lipoprotein, UndB
SurfLocaUndeCyto2	surface localized undecaheme cytochrome c lipoprotein, UndA
SurfPresAntiProt	Surface presentation of antigens protein SpaQ
SurfPresAntiProt10	Surface presentation of antigens protein
SurfPresAntiProt11	Surface presentation of antigens protein SpaN
SurfPresAntiProt12	Surface presentation of antigens protein SpaK
SurfPresAntiProt2	Surface presentation of antigens protein SpaP
SurfPresAntiProt4	Surface presentation of antigens protein SpaO
SurfPresAntiProt5	Surface presentation of antigens protein SpaN (Invasion protein InvJ)
SurfPresAntiProt6	Surface presentation of antigens protein SpaM
SurvProtSuraPrec	Survival protein SurA precursor (Peptidyl-prolyl cis-trans isomerase SurA) (EC 5.2.1.8)
Svp2ProtAssoWith	SVP26 protein associated with early Golgi proteins (SNARE associated domain)
SyntHomoSaccCere3090	syntenic homolog of Saccharomyces cerevisiae YJR014W
T1ssAssoTranLike	T1SS associated transglutaminase-like cysteine proteinase LapP
T1ssSecrAgglRtx	T1SS secreted agglutinin RTX
TDnaBordEndoVird	T-DNA border endonuclease VirD2, RP4 TraG-like relaxase
TDnaBordEndoVird2	T-DNA border endonuclease, VirD1
Taga16BispAldo	Tagatose 1,6-bisphosphate aldolase (EC 4.1.2.40)
Taga16BispAldoGaty	Tagatose-1,6-bisphosphate aldolase GatY (EC 4.1.2.40)
Taga1PhosKinaTagk	Tagatose-1-phosphate kinase TagK
Taga6PhosKina	Tagatose-6-phosphate kinase (EC 2.7.1.144)
TageProt	TagE protein
TailFibeProtSaBact2	Tail fiber protein [SA bacteriophages 11, Mu50B]
TailTapeMeasProt2	Tail tape-measure protein [Bacteriophage A118]
TapeMeasProtSaBact	Tape measure protein [SA bacteriophages 11, Mu50B]
TataBoxBindProt	TATA-box binding protein
TcpPiliSignPeptTcpa	TCP pilin signal peptidase, TcpA processing
TcpPiluViruReguProt	TCP pilus virulence regulatory protein ToxT, transcription activator
TcuaFlavUsedOxid	TcuA: flavoprotein used to oxidize tricarballylate to cis-aconitate
TcubWorkWithTcua	TcuB: works with TcuA to oxidize tricarballylate to cis-aconitate
TcucInteMembProt	TcuC: integral membrane protein used to transport tricarballylate across the cell membrane
TcurReguTcuaGene	TcuR: regulates tcuABC genes used in utilization of tricarballylate
TdpNAcetLipiIiNAcet	TDP-N-acetylfucosamine:lipid II N-acetylfucosaminyltransferase (EC 2.4.1.325)
TeicAcidBiosGlyc	Teichuronic acid biosynthesis glycosyl transferase TuaC
TeicAcidBiosGlyc2	Teichuronic acid biosynthesis glycosyltransferase TuaA
TeicAcidBiosProt2	Teichuronic acid biosynthesis protein TuaE, putative secreted polysaccharide polymerase
TeicAcidBiosProt5	Teichuronic acid biosynthesis protein tuaF
TeicAcidBiosProt8	Teichuronic acid biosynthesis protein TuaB
TeicResiAssoHthType	Teicoplanin-resistance associated HTH-type transcriptional regulator TcaR
TeicResiTranTcab	Teicoplanin resistance transporter TcaB
Tent	Tentoxilysin (EC 3.4.24.68)
TermLargSubuBact	Terminase large subunit [Bacteriophage A118]
TermLargSubuBact2	Terminase, large subunit [Bacteriophage PhiNIH1.1]
TermOxidBiogProt	Terminal oxidase biogenesis protein CtaM, putative heme A, heme O chaperone
TermSmalSubuBact	Terminase small subunit [Bacteriophage A118]
TerpUtilProtAtua	Terpene utilization protein AtuA
TesbLikeAcylCoaThio	TesB-like acyl-CoA thioesterase 3
TesbLikeAcylCoaThio2	TesB-like acyl-CoA thioesterase 5
TesbLikeAcylCoaThio3	TesB-like acyl-CoA thioesterase 4
TesbLikeAcylCoaThio4	TesB-like acyl-CoA thioesterase 2
TesbLikeAcylCoaThio5	TesB-like acyl-CoA thioesterase 1
Tetr4Kina	Tetraacyldisaccharide 4'-kinase (EC 2.7.1.130)
TetrBetaCurcSynt	Tetraprenyl-beta-curcumene synthase (EC 4.2.3.130)
TetrEfflSystComp	Tetrapartite efflux system component, FusD-like => FusD of FusABCDE system
TetrEfflSystComp2	Tetrapartite efflux system component, FusD-like
TetrEfflSystInne	Tetrapartite efflux system, inner membrane component FusBC-like => FusBC of FusABCDE system
TetrEfflSystInne2	Tetrapartite efflux system, inner membrane component FusBC-like
TetrEfflSystMemb	Tetrapartite efflux system, membrane fusion component FusE-like => FusE of FusABCDE system
TetrEfflSystMemb2	Tetrapartite efflux system, membrane fusion component FusE-like
TetrEfflSystOute	Tetrapartite efflux system, outer membrane factor lipoprotein FusA-like => FusA of FusABCDE system
TetrEfflSystOute2	Tetrapartite efflux system, outer membrane factor lipoprotein FusA-like
TetrFamiReguProt2	TetR family regulatory protein of MDR cluster
TetrFamiTranRegu	TetR family transcriptional regulator BA4434
TetrFamiTranRegu15	TetR family transcriptional regulator Bsu YvdT
TetrFamiTranRegu9	TetR family transcriptional regulator BA0834
TetrPeptRepeProt	Tetratrico-peptide repeat (TPR) protein within ESAT-6 gene cluster
TetrReduDehaPcea	Tetrachloroethene reductive dehalogenase PceA (EC 1.97.1.8)
TetrReduDehaPcea2	Tetrachloroethene reductive dehalogenase PceA membrane-bound subunit
TetrReduDehaTcea	Tetrachloroethene reductive dehalogenase TceA
TetrReduDehaTcea2	Tetrachloroethene reductive dehalogenase TceA membrane-bound subunit
TetrReduSensTran	Tetrathionate reductase sensory transduction histidine kinase (EC 2.7.3.-)
TetrReduSubu	Tetrathionate reductase subunit A
TetrReduSubuB	Tetrathionate reductase subunit B
TetrReduSubuC	Tetrathionate reductase subunit C
TetrReduTwoCompResp	Tetrathionate reductase two-component response regulator
TetrResiMfsEfflPump	Tetracycline resistance, MFS efflux pump => Tet(B)
TetrResiMfsEfflPump10	Tetracycline resistance, MFS efflux pump => Tet(D)
TetrResiMfsEfflPump11	Tetracycline resistance, MFS efflux pump => Tet(C)
TetrResiMfsEfflPump12	Tetracycline resistance, MFS efflux pump => Tet(A)
TetrResiMfsEfflPump13	Tetracycline resistance, MFS efflux pump => Tet(E)
TetrResiMfsEfflPump14	Tetracycline resistance, MFS efflux pump => Tet(G)
TetrResiMfsEfflPump15	Tetracycline resistance, MFS efflux pump => Tet(J)
TetrResiMfsEfflPump16	Tetracycline resistance, MFS efflux pump => Tet(K)
TetrResiMfsEfflPump17	Tetracycline resistance, MFS efflux pump => Tet(Y)
TetrResiMfsEfflPump18	Tetracycline resistance, MFS efflux pump => Tet(Z)
TetrResiMfsEfflPump19	Tetracycline resistance, MFS efflux pump => Tet(31)
TetrResiMfsEfflPump2	Tetracycline resistance, MFS efflux pump => unclassified
TetrResiMfsEfflPump20	Tetracycline resistance, MFS efflux pump => Tet(33)
TetrResiMfsEfflPump21	Tetracycline resistance, MFS efflux pump => Tet(39)
TetrResiMfsEfflPump22	Tetracycline resistance, MFS efflux pump => Tet(40)
TetrResiMfsEfflPump23	Tetracycline resistance, MFS efflux pump => Tet(41)
TetrResiMfsEfflPump24	Tetracycline resistance, MFS efflux pump => Tet(42)
TetrResiMfsEfflPump25	Tetracycline resistance, MFS efflux pump => Tet(43)
TetrResiMfsEfflPump26	Tetracycline resistance, MFS efflux pump => Tet(45)
TetrResiMfsEfflPump27	Tetracycline resistance, MFS efflux pump => Tet(47)
TetrResiMfsEfflPump28	Tetracycline resistance, MFS efflux pump => Tcr3
TetrResiMfsEfflPump3	Tetracycline resistance, MFS efflux pump => Tet(H)
TetrResiMfsEfflPump4	Tetracycline resistance, MFS efflux pump => TetA(P)
TetrResiMfsEfflPump5	Tetracycline resistance, MFS efflux pump => Tet(38)
TetrResiMfsEfflPump6	Tetracycline resistance, MFS efflux pump => Tet(30)
TetrResiMfsEfflPump7	Tetracycline resistance, MFS efflux pump => Tet(35)
TetrResiMfsEfflPump8	Tetracycline resistance, MFS efflux pump => Tet(L)
TetrResiMfsEfflPump9	Tetracycline resistance, MFS efflux pump => Tet(V)
TetrResiProtTetm	Tetracycline resistance protein TetM
TetrResiProtTeto	Tetracycline resistance protein TetO
TetrResiProtTetp	Tetracycline resistance protein TetP
TetrResiProtTetq	Tetracycline resistance protein TetQ
TetrResiReguProt	Tetracycline resistance regulatory protein TetR
TetrResiRiboProt	Tetracycline resistance, ribosomal protection type => Tet
TetrResiRiboProt10	Tetracycline resistance, ribosomal protection type => Tet(36)
TetrResiRiboProt11	Tetracycline resistance, ribosomal protection type => Tet(44)
TetrResiRiboProt2	Tetracycline resistance, ribosomal protection type => Tet(M)
TetrResiRiboProt3	Tetracycline resistance, ribosomal protection type => Tet(Q)
TetrResiRiboProt4	Tetracycline resistance, ribosomal protection type => Tet(W)
TetrResiRiboProt5	Tetracycline resistance, ribosomal protection type => TetB(P)
TetrResiRiboProt6	Tetracycline resistance, ribosomal protection type => Tet(O)
TetrResiRiboProt7	Tetracycline resistance, ribosomal protection type => Tet(32)
TetrResiRiboProt8	Tetracycline resistance, ribosomal protection type => Tet(S)
TetrResiRiboProt9	Tetracycline resistance, ribosomal protection type => Tet(T)
TetrResiTetrInac	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(47)
TetrResiTetrInac10	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(56)
TetrResiTetrInac11	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(X)
TetrResiTetrInac2	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(48)
TetrResiTetrInac3	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(49)
TetrResiTetrInac4	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(50)
TetrResiTetrInac5	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(51)
TetrResiTetrInac6	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(52)
TetrResiTetrInac7	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(53)
TetrResiTetrInac8	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(54)
TetrResiTetrInac9	Tetracycline resistance, tetracycline-inactivating enzyme => Tet(55)
Ther2	Thermolysin (EC 3.4.24.27)
TherFamiProt2	thermonuclease family protein, (pXO1-141)
TherSubu	Thermosome subunit
Thia1Puta	Thiaminase 1, putative (EC 2.5.1.2)
ThiaAbcTranAtpaComp	Thiamin ABC transporter, ATPase component
ThiaAbcTranSubsBind	Thiamin ABC transporter, substrate-binding component
ThiaAbcTranThixTran	Thiamin ABC transporter ThiX, transmembrane component
ThiaAbcTranThiySubs	Thiamin ABC transporter ThiY, substrate-binding component
ThiaAbcTranThizAtpa	Thiamin ABC transporter ThiZ, ATPase component
ThiaAbcTranTranComp	Thiamin ABC transporter, transmembrane component
ThiaBiosEnzyThi4n1	Thiazole biosynthetic enzyme Thi4
ThiaBiosLipoApbe	Thiamin biosynthesis lipoprotein ApbE
ThiaDiphAdenTran	Thiamine diphosphate adenylyl transferase (EC 2.7.7.-)
ThiaIiInvoSalvThia	Thiaminase II involved in salvage of thiamin pyrimidine moiety (EC 3.5.99.2)
ThiaIiInvoSalvThia2	Thiaminase II involved in salvage of thiamin pyrimidine moiety, TenA subgroup with Cys in active site (EC 3.5.99.2)
ThiaIiInvoSalvThia3	Thiaminase II involved in salvage of thiamin pyrimidine moiety, TenA subgroup with conserved Glu in active site (EC 3.5.99.2)
ThiaImidReduSide	Thiazolinyl imide reductase in siderophore biosynthesis gene cluster
ThiaKina	Thiamine kinase (EC 2.7.1.89)
ThiaMonoKina	Thiamine-monophosphate kinase (EC 2.7.4.16)
ThiaMonoPhos	Thiamine-monophosphate phosphatase (EC 3.1.3.-)
ThiaPhosPhos	Thiamine-(di)phosphate phosphatase (EC 3.1.3.-)
ThiaPhosPyro	Thiamin-phosphate pyrophosphorylase (EC 2.5.1.3)
ThiaPhosSyntThin	Thiamin-phosphate synthase ThiN (EC 2.5.1.3)
ThiaPyri	Thiamine pyridinylase (EC 2.5.1.2)
ThiaPyro	Thiamin pyrophosphokinase (EC 2.7.6.2)
ThiaPyroRequEnzy	Thiamine pyrophosphate-requiring enzymes
ThiaReguOuteMemb	Thiamin-regulated outer membrane receptor Omr1
ThiaSynt	Thiazole synthase (EC 2.8.1.10)
ThiaTautTeni	Thiazole tautomerase TenI (EC 5.3.99.10)
ThiaTautTeniLike	Thiazole tautomerase TenI-like domain
ThiaTranGeneThi1n1	Thiamin transport gene THI10
ThiaTrip	Thiamine-triphosphatase (EC 3.6.1.28)
ThiaTripSynt	Thiamine-triphosphatase (ThTP) synthase (EC 2.7.4.15)
ThimOlig	Thimet oligopeptidase (EC 3.4.24.15)
Thio	Thioredoxin (EC 1.8.1.8)
ThioActiCyto	Thiol-activated cytolysin
ThioCyanSulfPspe	Thiosulfate:cyanide sulfurtransferase PspE (EC 2.8.1.1)
ThioDehyFamiProt	Thioester dehydrase family protein in surfactin biosynthesis cluster
ThioDisuInteProt	Thiol:disulfide interchange protein DsbC
ThioDisuInteProt2	Thiol:disulfide interchange protein DsbE
ThioDisuInteProt4	Thiol:disulfide interchange protein DsbG precursor
ThioDisuInvoConj	Thiol:disulfide involved in conjugative transfer
ThioDisuOxidAsso	Thiol:disulfide oxidoreductase associated with MetSO reductase
ThioDisuOxidRela	Thiol:disulfide oxidoreductase related to ResA
ThioDisuOxidTlpa	Thiol:disulfide oxidoreductase TlpA
ThioHydrSubuAlph	Thiocyanate hydrolase subunit alpha (EC 3.5.5.8)
ThioHydrSubuBeta	Thiocyanate hydrolase subunit beta (EC 3.5.5.8)
ThioHydrSubuGamm	Thiocyanate hydrolase subunit gamma (EC 3.5.5.8)
ThioLikeProtClus	Thioredoxin-like protein clustered with PA0057
ThioMycoSide	Thioesterase [mycobactin] siderophore
ThioPeroBcpType	Thiol peroxidase, Bcp-type (EC 1.11.1.15)
ThioPvdgInvoNonRibo	Thioesterase PvdG involved in non-ribosomal peptide biosynthesis
ThioRedu	Thioredoxin reductase (EC 1.8.1.9)
ThioReduCytoBSubu	Thiosulfate reductase cytochrome B subunit (membrane anchoring protein)
ThioReduPhsa	Thiosulfate reductase PhsA
ThioReduPhsb	Thiosulfate reductase PhsB
ThioReduPhscCyto	Thiosulfate reductase PhsC, cytochrome B subunit
ThioSideBiosGene	Thioesterase in siderophore biosynthesis gene cluster
ThioSulfGlpe	Thiosulfate sulfurtransferase GlpE (EC 2.8.1.1)
ThioSulfRhod	Thiosulfate sulfurtransferase, rhodanese (EC 2.8.1.1)
ThreCataOperTran	Threonine catabolic operon transcriptional activator TdcA
ThreCataOperTran2	Threonine catabolic operon transcriptional activator TdcR
ThreCompQuorSens	Three-component quorum-sensing regulatory system, response regulator
ThreCompQuorSens2	Three-component quorum-sensing regulatory system, inducing peptide for bacteriocin biosynthesis
ThreCompQuorSens3	Three-component quorum-sensing regulatory system, sensor histidine kinase
ThreDehyBios	Threonine dehydratase biosynthetic (EC 4.3.1.19)
ThreDehyCata	Threonine dehydratase, catabolic (EC 4.3.1.19)
ThreDehyEukaType	Threonine dehydratase, eukaryotic type (EC 4.3.1.19)
ThreSynt	Threonine synthase (EC 4.2.3.1)
ThreTrnaSynt	Threonyl-tRNA synthetase (EC 6.1.1.3)
ThreTrnaSyntFrag	Threonyl-tRNA synthetase fragment
ThreTrnaSyntRela	Threonyl-tRNA synthetase-related protein
ThymKina	Thymidine kinase (EC 2.7.1.21)
ThymKina2	Thymidylate kinase (EC 2.7.4.9)
ThymPhos	Thymidine phosphorylase (EC 2.4.2.4)
ThymSynt	Thymidylate synthase (EC 2.1.1.45)
ThymSyntThyx	Thymidylate synthase ThyX (EC 2.1.1.148)
TimBarrProtPossInvo	TIM barrel protein possibly involved in myo-inositol catabolism
TlddDomaProt	TldD-domain protein
TlddFamiProtActi	TldD family protein, Actinobacterial subgroup
TlddFamiProtBeta	TldD family protein, Beta/Gamma-proteobacterial subgroup
TlddProtPartTlde	TldD protein, part of TldE/TldD proteolytic complex
TldePmbaFamiProt	TldE/PmbA family protein, Actinobacterial subgroup
TldePmbaFamiProt2	TldE/PmbA family protein, Beta/Gamma-proteobacterial subgroup
TldeProtPartTlde	TldE protein, part of TldE/TldD proteolytic complex
TmrnBindProtSmpb	tmRNA-binding protein SmpB
Tn55Tran2	Tn552 transposase
TolBiopTranSystTolr	Tol biopolymer transport system, TolR protein
TolPalSystAssoAcyl	Tol-Pal system-associated acyl-CoA thioesterase
TolPalSystBetaProp	Tol-Pal system beta propeller repeat protein TolB
TolPalSystPeptAsso	Tol-Pal system peptidoglycan-associated lipoprotein PAL
TolPalSystProtTolq	Tol-Pal system protein TolQ
TolPalSystTprRepe	Tol-Pal system TPR repeat containing exported protein YbgF
TolaProt	TolA protein
TolbProtPrecPeri	tolB protein precursor, periplasmic protein involved in the tonb-independent uptake of group A colicins
Tolu4MonoSubuTmoa	Toluene-4-monooxygenase, subunit TmoA
Tolu4MonoSubuTmoa2	Toluene-4-monooxygenase, subunit TmoA alpha
Tolu4MonoSubuTmoa3	Toluene-4-monooxygenase, subunit TmoA beta
Tolu4MonoSubuTmob	Toluene-4-monooxygenase, subunit TmoB
Tolu4MonoSubuTmoc	Toluene-4-monooxygenase, subunit TmoC
Tolu4MonoSubuTmod	Toluene-4-monooxygenase, subunit TmoD
Tolu4MonoSubuTmoe	Toluene-4-monooxygenase, subunit TmoE
Tolu4MonoSubuTmof	Toluene-4-monooxygenase, subunit TmoF
TommBiosCycl	TOMM biosynthesis cyclodehydratase (protein C)
TommBiosDehy	TOMM biosynthesis dehydrogenase (protein B)
TommBiosDockScaf	TOMM biosynthesis docking scaffold (protein D)
TommBiosPrecPept	TOMM biosynthesis precursor peptide (protein A)
TommExpoAbcTranAtp	TOMM export ABC transporter, ATP-binding protein
TommExpoAbcTranPerm	TOMM export ABC transporter, permease protein
TonbDepeFerrAchr	TonB-dependent ferric achromobactin receptor protein
TonbDepeHemeHemo	TonB-dependent heme and hemoglobin receptor HutA
TonbDepeHemeRece	TonB-dependent heme receptor HutR
TonbDepeHemiFerr	TonB-dependent hemin , ferrichrome receptor
TonbDepeHemiRece	TonB-dependent hemin receptor
TonbDepeHemoRece	TonB-Dependent Hemoglobin Receptor HmuR
TonbDepeRece	TonB-dependent receptor
TonbDepeSideRece	TonB-dependent siderophore receptor
TopoIvSubu	Topoisomerase IV subunit A (EC 5.99.1.-)
TopoIvSubuB	Topoisomerase IV subunit B (EC 5.99.1.-)
ToraSpecChapProt	TorA-specific chaperone protein, TorD
Toxi1PinDoma	Toxin 1, PIN domain
Toxi3	Toximoron (Superantigen)
ToxiCoReguPili	Toxin co-regulated pilin A
ToxiCoReguPiluBios	Toxin co-regulated pilus biosynthesis protein E, anchors TcpT to membrane
ToxiCoReguPiluBios10	Toxin co-regulated pilus biosynthesis protein S
ToxiCoReguPiluBios11	Toxin co-regulated pilus biosynthesis protein T, putative ATP-binding translocase of TcpA
ToxiCoReguPiluBios12	Toxin co-regulated pilus biosynthesis protein F, putative outer membrane channel for TcpA extrusion
ToxiCoReguPiluBios2	Toxin co-regulated pilus biosynthesis protein I, chemoreceptor, negative regulator of TcpA
ToxiCoReguPiluBios3	Toxin co-regulated pilus biosynthesis protein P, transcriptional activator of ToxT promoter
ToxiCoReguPiluBios4	Toxin co-regulated pilus biosynthesis protein H, transcriptional activator of ToxT promoter
ToxiCoReguPiluBios5	Toxin co-regulated pilus biosynthesis protein B
ToxiCoReguPiluBios6	Toxin co-regulated pilus biosynthesis protein Q
ToxiCoReguPiluBios7	Toxin co-regulated pilus biosynthesis protein C, outer membrane protein
ToxiCoReguPiluBios8	Toxin co-regulated pilus biosynthesis protein R
ToxiCoReguPiluBios9	Toxin co-regulated pilus biosynthesis protein D
ToxiHigb	Toxin HigB
ToxiShocSyndToxi	Toxic shock syndrome toxin 1 (TSST-1)
TppRequEnzyCoLoca	TPP-requiring enzyme co-localized with putative O-antigen rfb gene cluster
TppRequEnzyCoLoca2	TPP-requiring enzyme co-localized with fatty acid metabolic genes
TprRepeContProt	TPR-repeat-containing protein
TprRepeSel1Subf	TPR repeat, SEL1 subfamily
Tran	Transketolase (EC 2.2.1.1)
Tran2	Transaldolase (EC 2.2.1.2)
Tran23Dihy3HydrIsom	Trans-2,3-dihydro-3-hydroxyanthranilate isomerase (EC 5.3.3.17)
Tran2Cis3DeceAcp	Trans-2,cis-3-Decenoyl-ACP isomerase
TranActiAcetDehy	Transcriptional activator of acetoin dehydrogenase operon AcoR
TranActiAtxa	transcriptional activator AtxA, (pXO1-119)
TranActiGade	Transcriptional activator GadE
TranActiHlyu	Transcriptional activator HlyU
TranActiMaltRegu	Transcriptional activator of maltose regulon, MalT
TranActiNhar	Transcriptional activator NhaR
TranActiPlcr	Transcriptional activator PlcR
TranActiProtCaif	Transcriptional activatory protein CaiF
TranActiProtLuxr	Transcriptional activator protein LuxR
TranActiSimiCynOper	Transcriptional activator similar to cyn operon regulator
TranActiToxr	Transcriptional activator ToxR
TranAntiProtNusg	Transcription antitermination protein NusG
TranAntiProtUpdy	Transcription antitermination protein UpdY
TranAntiWithPtsRegu	Transcriptional antiterminator with PTS regulation domain, SPy0181 ortholog
TranCTermSect	Transketolase, C-terminal section (EC 2.2.1.1)
TranCompBionEner	Transmembrane component BioN of energizing module of biotin ECF transporter
TranCompGeneEner	Transmembrane component of general energizing module of ECF transporters
TranCompYkocEner	Transmembrane component YkoC of energizing module of thiamin-regulated ECF transporter for HydroxyMethylPyrimidine
TranCompYkocEner2	Transmembrane component YkoC of energizing module of thiamin-regulated ECF transporter for Thiamin
TranDisaAcnaRloc	Translation-disabling ACNase RloC
TranEfflProtPtlg	Transmembrane efflux protein PtlG
TranElonCompProt	Transcription elongator complex protein 5
TranElonCompProt2	Transcription elongator complex protein 1
TranElonCompProt3	Transcription elongator complex protein 6
TranElonCompProt4	Transcription elongator complex protein 3, histone acetyltransferase (EC 2.3.1.48)
TranElonCompProt5	Transcription elongator complex protein 4
TranElonCompProt6	Transcription elongator complex protein 2
TranElonFact1Alph	Translation elongation factor 1 alpha-related protein
TranElonFact1Alph2	Translation elongation factor 1 alpha subunit
TranElonFact1Beta	Translation elongation factor 1 beta subunit
TranElonFact1Delt	Translation elongation factor 1 delta subunit
TranElonFact1Gamm	Translation elongation factor 1 gamma subunit
TranElonFact2n1	Translation elongation factor 2
TranElonFact3n1	Translation elongation factor 3
TranElonFactG	Translation elongation factor G
TranElonFactGMito	Translation elongation factor G, mitochondrial
TranElonFactGPara	Translation elongation factor G paralog
TranElonFactGRela	Translation elongation factor G-related protein
TranElonFactGStre	Translation elongation factor G Stremptomyces paralog
TranElonFactLepa	Translation elongation factor LepA
TranElonFactP	Translation elongation factor P
TranElonFactPLys3n1	Translation elongation factor P Lys34:lysine transferase
TranElonFactPLys3n2	Translation elongation factor P Lys34 hydroxylase
TranElonFactTs	Translation elongation factor Ts
TranElonFactTu	Translation elongation factor Tu
TranFactFapr	Transcription factor FapR
TranFactS	Transcription factor S
TranFactSRelaProt	Transcription factor S-related protein 2
TranFactSRelaProt3	Transcription factor S-related protein 3
TranFeruCoaHydr	Trans-feruloyl-CoA hydratase (EC 4.2.1.101)
TranFeruCoaSynt	Trans-feruloyl-CoA synthase (EC 6.2.1.34)
TranForInseSequLike	Transposase for insertion sequence-like element IS431mec
TranGatbDomaProt	Transamidase GatB domain protein
TranHemeTranProt	Transmembrane heme transport protein MmpL3
TranHemeTranProt2	Transmembrane heme transport protein MmpL11
TranInitFact1a	Translation initiation factor 1A
TranInitFact1n1	Translation initiation factor 1
TranInitFact2bAlph	Translation initiation factor 2B alpha/beta/delta-type subunit
TranInitFact2bAlph2	Translation initiation factor 2B alpha subunit
TranInitFact2n1	Translation initiation factor 2
TranInitFact3Rela	Translation initiation factor 3 related protein
TranInitFact3n1	Translation initiation factor 3
TranInitFactB	Transcription initiation factor B
TranInitFactBRela	Transcription initiation factor B-related protein
TranInitFactSui1n1	Translation initiation factor SUI1-related protein
TranInshForInseSequ	Transposase InsH for insertion sequence element IS5
TranL3HydrDehy	trans-L-3-hydroxyproline dehydratase (EC 4.2.1.77)
TranMachAssoProt2	Translation machinery-associated protein 64, YDR117C homolog
TranMessRnaInvoTran	Transfer-messenger RNA (tmRNA) involved in trans-translation
TranNTermSect	Transketolase, N-terminal section (EC 2.2.1.1)
TranPolyDecaDiph	Trans,polycis-decaprenyl diphosphate synthase (EC 2.5.1.86)
TranProtCoOccuWith	Transmembrane protein co-occuring with sulfite exporter TauE/SafE
TranProtDistHomo	transmembrane protein, distant homology with ydbS
TranProtDistHomo2	transmembrane protein, distant homology with ydbT
TranProtInvoDmsp	Transmembrane protein involved in DMSP breakdown
TranProtMt22Clus	Transmembrane protein MT2276, clustered with lipoate gene
TranReguAcraOper	Transcriptional regulator of acrAB operon, AcrR
TranReguAcrrFami	Transcriptional regulator, AcrR family
TranReguAlcrSide	Transcriptional regulator AlcR in siderophore [Alcaligin] cluster
TranReguAlphAcet	Transcriptional regulator of alpha-acetolactate operon alsR
TranReguAracFami10	Transcriptional regulator, AraC family, clustered with MMPA degradation genes
TranReguAracFami4	Transcriptional regulator of AraC family, enterobactin-dependent, predicted
TranReguBiofForm	Transcriptional regulator of biofilm formation (AraC/XylS family)
TranReguBkdrIsol	Transcriptional regulator BkdR of isoleucine and valine catabolism operon
TranReguBltbLocu	Transcriptional regulator in BltB locus
TranReguCataArgi	Transcriptional regulator of catabolic arginine decarboxylase (adiA)
TranReguClusWith	Transcriptional regulator in cluster with unspecified monosaccharide ABC transport system
TranReguClusWith2	Transcriptional regulator in cluster with Zn-dependent hydrolase
TranReguCustWith	Transcriptional regulator in custer with plant-induced nitrilase
TranReguCytr	Transcriptional (co)regulator CytR
TranReguDAlloUtil	Transcriptional regulator of D-allose utilization, RpiR family
TranReguDAlloUtil2	Transcriptional regulator of D-allose utilization, LacI family
TranReguDeguLuxr	Transcriptional regulator DegU, LuxR family
TranReguFattAcid	Transcriptional regulator of fatty acid biosynthesis FabT
TranReguFrucUtil	Transcriptional regulator of fructoselysine utilization operon FrlR
TranReguGlycTrna	Transcriptional regulator in glycyl-tRNA synthetase containing cluster
TranReguGntrFami3	Transcriptional regulator, GntR family, in hypothetical Actinobacterial gene cluster
TranReguHxlrForm	Transcriptional regulator HxlR, formaldehyde assimilation
TranReguKdgrKdgOper	Transcriptional regulator KdgR, KDG operon repressor
TranReguLasr	Transcriptional regulator LasR
TranReguLigrLysr	Transcriptional regulator ligR, LysR family
TranReguLuxrFami7	Transcriptional regulator, luxR family, associated with agmatine catabolism
TranReguLysmAsnc	Transcriptional regulator LysM, AsnC family
TranReguLysrFami3	Transcriptional regulator, LysR family, in glycolate utilization operon
TranReguLysrFami5	Transcriptional regulator, LysR family, in formaldehyde detoxification operon
TranReguMerrFami2	Transcriptional regulator, MerR family, near polyamine transporter
TranReguMerrFami5	Transcriptional regulator, MerR family, associated with photolyase
TranReguMexeOprn	Transcriptional regulator of the MexEF-OprN multidrug efflux system
TranReguMgra	Transcriptional regulator MgrA (Regulator of autolytic activity)
TranReguNanr	transcriptional regulator NanR
TranReguNarr	Transcriptional regulator NarR
TranReguNearVibr	Transcriptional regulator near Vibriobactin biosynthetic gene custer
TranReguPchr	Transcriptional regulator PchR
TranReguPfgi1Like	Transcriptional regulator in PFGI-1-like cluster
TranReguProtRsta	Transcriptional regulatory protein RstA
TranReguProtToxs	Transmembrane regulatory protein ToxS
TranReguProtYcit	Transcriptional regulatory protein YciT
TranReguPtlr	Transcriptional regulator PtlR
TranReguPyriCata	Transcriptional regulator of pyrimidine catabolism (TetR family)
TranReguRegrRpre	Transcriptional regulator RegR, rpressor of hyaluronate and KDG utilization
TranReguReprVita	Transcriptional regulator, repressor of vitamin B6 degradation pathway
TranReguRhlr	Transcriptional regulator RhlR
TranReguRpirFami2	Transcriptional regulator of RpiR family in catabolic operon
TranReguRpirProt	Transcriptional regulator RpiR in protein degradation cluster
TranReguRutrPyri	Transcriptional regulator RutR of pyrimidine catabolism (TetR family)
TranReguSarr	Transcriptional regulator SarR (Staphylococcal accessory regulator R)
TranReguSart	Transcriptional regulator SarT (Staphylococcal accessory regulator T)
TranReguSaru	Transcriptional regulator SarU (Staphylococcal accessory regulator U)
TranReguSarv	Transcriptional regulator SarV (Staphylococcal accessory regulator V)
TranReguSarz	Transcriptional regulator SarZ (Staphylococcal accessory regulator Z)
TranReguSuccCoaSynt	Transcriptional regulator of succinyl CoA synthetase operon
TranReguTetrFami4	Transcriptional regulator, TetR family, associated with agmatine catabolism
TranReguVca0Orth	Transcriptional regulator, VCA0231 ortholog
TranReguYbihTetr	Transcriptional regulator YbiH, TetR family
TranReguYeieLysr	Transcriptional regulator YeiE, LysR family
TranReguYqhcPosi	Transcriptional regulator YqhC, positively regulates YqhD and DkgA
TranRelaMembProt	Transport-related membrane protein
TranRepaCoupFact	Transcription-repair coupling factor
TranReprAeroRece	Transcriptional repressor of aerobactin receptor iutR
TranReprArabUtil	Transcriptional repressor of arabinoside utilization operon, GntR family
TranReprCmeaOper	Transcriptional repressor of CmeABC operon, CmeR
TranReprCoppUpta	Transcriptional repressor in copper uptake, YcnK
TranReprEctoBios	Transcriptional repressor of ectoine biosynthetic genes
TranReprEthrTetr	Transcriptional repressor EthR, TetR family
TranReprForNadBios	Transcriptional repressor for NAD biosynthesis in gram-positives
TranReprForPyruDehy	Transcriptional repressor for pyruvate dehydrogenase complex
TranReprLacOper	Transcriptional repressor of the lac operon
TranReprMyoInosCata	Transcriptional repressor of the myo-inositol catabolic operon DeoR family
TranReprNifGlnaOper	Transcriptional repressor of nif and glnA operons
TranReprProtTrpr	Transcriptional repressor protein TrpR
TranReprProtTyrr	Transcriptional repressor protein TyrR
TranReprPutaPutp	Transcriptional repressor of PutA and PutP
TranReprRcnr	Transcriptional repressor RcnR
TranReprSdpr	Transcriptional repressor SdpR
TranReprUidr	Transcriptional repressor UidR
TranReprZnuaOper	transcriptional repressor of znuABC operon
TranRespReguProt	Transcriptional response regulatory protein GlrR
TranStatReguProt	Transition state regulatory protein AbrB
TranSystPermProt5	Transport system permease protein, associated with thiamin (pyrophosphate?) binding lipoprotein p37
TranTermProtNusa	Transcription termination protein NusA
TranTermProtNusb	Transcription termination protein NusB
TranTranProtMmpl	Transmembrane transport protein MmpL5
TranTranProtMmpl10	Transmembrane transport protein MmpL family
TranTranProtMmpl11	Transmembrane transport protein MmpL8/MmpL10/MmpL12
TranTranProtMmpl12	Transmembrane transport protein MmpL7
TranTranProtMmpl13	Transmembrane transport protein MmpL6
TranTranProtMmpl2	Transmembrane transport protein MmpL2
TranTranProtMmpl5	Transmembrane transport protein MmpL4
TranTranProtMmpl6	Transmembrane transport protein MmpL13
TranTranProtMmpl7	Transmembrane transport protein MmpL9
TranTranProtMmpl8	Transmembrane transport protein MmpL1
TranTranProtMmpl9	Transmembrane transport protein MmpL14
TrapTypeC4DicaTran10	TRAP-type C4-dicarboxylate transport system, periplasmic component, clustered with pyruvate formate-lyase
TrapTypeC4DicaTran9	TRAP-type C4-dicarboxylate transport system, large permease component, clustered with pyruvate formate-lyase
TricTranMembProt	Tricarboxylate transport membrane protein TctA
TricTranProtTctb	Tricarboxylate transport protein TctB
TricTranProtTctc	Tricarboxylate transport protein TctC
TricTranSensProt	Tricarboxylate transport sensor protein TctE
TricTranSensProt2	Tricarboxylate transport sensor protein TctE => Citrate response regulator CitA
TricTranSensProt3	Tricarboxylate transport sensor protein TctE => Mg-citrate response regulator CitS
TricTranTranRegu	Tricarboxylate transport transcriptional regulator TctD
TricTranTranRegu2	Tricarboxylate transport transcriptional regulator TctD => Citrate response regulator CitB
TricTranTranRegu3	Tricarboxylate transport transcriptional regulator TctD => Mg-citrate response regulator CitT
TrilHydrBaciSide	Trilactone hydrolase [bacillibactin] siderophore
TrilHydrIrod	Trilactone hydrolase IroD
TrimCorrProtCoMeth	[Trimethylamine--corrinoid protein] Co-methyltransferase (EC 2.1.1.250)
TrimMethCorrProt	Trimethylamine methyltransferase corrinoid protein
TrimNOxidOperTran	Trimethylamine-N-oxide operon transcriptional regulatory protein TorR
TrimNOxidReduAsso	Trimethylamine-N-oxide reductase associated c-type cytochrome, TorY
TrimNOxidReduAsso2	Trimethylamine-N-oxide reductase associated c-type cytochrome, TorC
TrimNOxidReduTora	Trimethylamine-N-oxide reductase, TorA (EC 1.7.2.3)
TrimNOxidReduTorz	Trimethylamine-N-oxide reductase, TorZ (EC 1.7.2.3)
TrimNOxidSensHist	Trimethylamine-N-oxide sensor histidine kinase TorS (EC 2.7.13.3)
TrimPerm	Trimethylamine permease
TrioIsom	Triosephosphate isomerase (EC 5.3.1.1)
TripAmin	Tripeptide aminopeptidase (EC 3.4.11.4)
TripDephCoaSynt	Triphosphoribosyl-dephospho-CoA synthase (EC 2.4.2.52)
TrkPotaUptaSystProt	Trk potassium uptake system protein TrkA
TrkPotaUptaSystProt2	Trk potassium uptake system protein TrkH
TrkPotaUptaSystProt5	Trk potassium uptake system protein TrkG
TrkaTypeAnioPerm	TrkA-type anion permease
Trna2OMeth	tRNA (cytidine(34)-2'-O)-methyltransferase (EC 2.1.1.207)
Trna2OMeth2	tRNA (guanosine(18)-2'-O)-methyltransferase (EC 2.1.1.34)
Trna2ThioSyntProt2	tRNA 2-thiouridine synthesis protein TusE
Trna4ThioSynt	tRNA 4-thiouridine synthase (EC 2.8.1.4)
Trna5Carb2ThioSynt	tRNA-5-carboxymethylaminomethyl-2-thiouridine(34) synthesis protein MnmE
Trna5Carb2ThioSynt2	tRNA-5-carboxymethylaminomethyl-2-thiouridine(34) synthesis protein MnmG
Trna5Guan	tRNAHis-5'-guanylyltransferase
Trna5Meth2ThioSynt5	tRNA 5-methylaminomethyl-2-thiouridine synthesis sulfur carrier protein TusA
Trna5Meth2ThioSynt6	tRNA 5-methylaminomethyl-2-thiouridine synthase subunit TusD
Trna5Meth2ThioSynt7	tRNA 5-methylaminomethyl-2-thiouridine synthase subunit TusB
Trna5Meth2ThioSynt8	tRNA 5-methylaminomethyl-2-thiouridine synthase subunit TusC
TrnaBindProtYgjh	tRNA-binding protein YgjH
TrnaDepeLipiIiAla	tRNA-dependent lipid II-Ala--L-alanine ligase
TrnaDepeLipiIiAla2	tRNA-dependent lipid II-Ala--L-serine ligase
TrnaDepeLipiIiAlaa	tRNA-dependent lipid II-AlaAla--L-serine ligase
TrnaDepeLipiIiAlaa2	tRNA-dependent lipid II-AlaAla--L-alanine ligase
TrnaDepeLipiIiAmin	tRNA-dependent lipid II--amino acid ligase
TrnaDepeLipiIiGly2	tRNA-dependent lipid II-Gly glycyltransferase (EC 2.3.2.17)
TrnaDepeLipiIiGlyc	tRNA-dependent lipid II--glycine ligase
TrnaDepeLipiIiGlyc2	tRNA-dependent lipid II--glycine ligase (FmhB)
TrnaDepeLipiIiGlyg4	tRNA-dependent lipid II-GlyGlyGly glycyltransferase (EC 2.3.2.18)
TrnaDepeLipiIiGlyg5	tRNA-dependent lipid II-GlyGlyGlyGly glycyltransferase (EC 2.3.2.18)
TrnaDepeLipiIiGlyg6	tRNA-dependent lipid II-GlyGly glycyltransferase (EC 2.3.2.17)
TrnaDepeLipiIiLAlan	tRNA-dependent lipid II--L-alanine ligase
TrnaDepeLipiIiLSeri	tRNA-dependent lipid II--L-serine ligase
TrnaDepeLipiIiSer	tRNA-dependent lipid II-Ser--L-alanine ligase
TrnaDihySynt2	tRNA-dihydrouridine(20/20a) synthase (EC 1.3.1.91)
TrnaDihySynt3	tRNA-dihydrouridine(16) synthase
TrnaDihySyntDusb	tRNA-dihydrouridine synthase DusB
TrnaDime	tRNA dimethylallyltransferase (EC 2.5.1.75)
TrnaGly	tRNA-Gly
TrnaGlyGcc	tRNA-Gly-GCC
TrnaGuanTran	tRNA-guanine transglycosylase (EC 2.4.2.29)
TrnaGuanTran2	tRNA-guanine(15) transglycosylase (EC 2.4.2.48)
TrnaGuanTran3	tRNA-guanine(13/15) transglycosylase (EC 2.4.2.48)
TrnaIA37Meth	tRNA-i(6)A37 methylthiotransferase (EC 2.8.4.3)
TrnaIntrEndo	tRNA-intron endonuclease (EC 3.1.27.9)
TrnaLysiSynt	tRNA(Ile)-lysidine synthetase (EC 6.3.4.19)
TrnaMeth	tRNA (5-methylaminomethyl-2-thiouridylate)-methyltransferase (EC 2.1.1.61)
TrnaMeth9	tRNA (adenine57/58-N1)-methyltransferase (EC 2.1.1.36)
TrnaN6Thre2Meth	tRNA N6-threonylcarbamoyladenosine 2-methylthiotransferase (putative)
TrnaNMeth2	tRNA (guanine(46)-N(7))-methyltransferase (EC 2.1.1.33)
TrnaNMeth4	tRNA (adenine(22)-N(1))-methyltransferase (EC 2.1.1.217)
TrnaNMeth5	tRNA(1)(Val) (adenine(37)-N(6))-methyltransferase (EC 2.1.1.223)
TrnaNuclAddi	tRNA nucleotidyltransferase, A-adding (EC 2.7.7.25)
TrnaNuclCcAddi	tRNA nucleotidyltransferase, CC-adding (EC 2.7.7.21)
TrnaNuclRelaProt2	tRNA nucleotidyltransferase related protein MMP0420
TrnaPseuSynt10	tRNA pseudouridine(38/39) synthase (EC 5.4.99.45)
TrnaPseuSynt11	tRNA pseudouridine(31) synthase (EC 5.4.99.42)
TrnaPseuSynt12	tRNA pseudouridine (54/55) synthase
TrnaPseuSynt2	tRNA pseudouridine(38-40) synthase (EC 5.4.99.12)
TrnaPseuSynt3	tRNA pseudouridine(55) synthase (EC 5.4.99.25)
TrnaPseuSynt5	tRNA pseudouridine(65) synthase (EC 5.4.99.26)
TrnaPseuSynt6	tRNA pseudouridine(13) synthase (EC 5.4.99.27)
TrnaPseuSynt9	tRNA pseudouridine(54/55) synthase
TrnaPseuSyntCyto	tRNA pseudouridine(32) synthase, cytoplasmic (EC 5.4.99.28)
TrnaPseuSyntMito	tRNA pseudouridine(32) synthase, mitochondrial (EC 5.4.99.28)
TrnaSpec2ThioMnma	tRNA-specific 2-thiouridylase MnmA (EC 2.8.1.13)
TrnaSpecAden34Deam	tRNA-specific adenosine-34 deaminase (EC 3.5.4.33)
TrnaTA37Meth	tRNA t(6)A37-methylthiotransferase (EC 2.8.4.5)
TrunCellSurfProt	Truncated cell surface protein map-w
Tryp23Diox	Tryptophan 2,3-dioxygenase (EC 1.13.11.11)
Tryp2Mono	Tryptophan 2-monooxygenase (EC 1.13.12.3)
Tryp2MonoVioaViol	Tryptophan 2-monooxygenase VioA in violacein biosynthesis (EC 1.13.12.3)
TrypAssoMembProt	Tryptophan-associated membrane protein
TrypHydrViodViol	Tryptophan hydroxylase VioD in violacein biosynthesis
TrypPrenIndoDeri	Tryptophanase in a prenylated indole derivative biosynthesis cluster (EC 4.1.99.1)
TrypSynt	Tryptophan synthase (indole-salvaging) (EC 4.2.1.122)
TrypSyntAlphChai	Tryptophan synthase alpha chain (EC 4.2.1.20)
TrypSyntBetaChai	Tryptophan synthase beta chain (EC 4.2.1.20)
TrypTrnaSynt	Tryptophanyl-tRNA synthetase (EC 6.1.1.2)
TrypTrnaSyntChlo	Tryptophanyl-tRNA synthetase, chloroplast (EC 6.1.1.2)
TrypTrnaSyntMito	Tryptophanyl-tRNA synthetase, mitochondrial (EC 6.1.1.2)
TsabProtRequForThre	TsaB protein, required for threonylcarbamoyladenosine (t(6)A) formation in tRNA
TsacProtRequForThre	TsaC protein (YrdC domain) required for threonylcarbamoyladenosine t(6)A37 modification in tRNA
TsacProtRequForThre2	TsaC protein (YrdC-Sua5 domains) required for threonylcarbamoyladenosine t(6)A37 modification in tRNA
TsaeProtRequForThre	TsaE protein, required for threonylcarbamoyladenosine t(6)A37 formation in tRNA
Tsc3ProtStimActi	Tsc3p protein, stimulates activity of serine palmitoyltransferase (LCB1, LCB2)
TtpDepeProtRelaE1n1	TTP-dependent protein, related to E1 component of pyruvate/2-oxoglutarate/acetoin dehydrogenase
TungAbcTranAtpBind	Tungstate ABC transporter, ATP-binding protein
TungAbcTranAtpBind2	Tungstate ABC transporter, ATP-binding protein WtpC
TungAbcTranPermProt	Tungstate ABC transporter, permease protein WtpB
TungAbcTranPermProt2	Tungstate ABC transporter, permease protein
TungAbcTranSubsBind	Tungstate ABC transporter, substrate-binding protein
TungAbcTranSubsBind2	Tungstate ABC transporter, substrate-binding protein WtpA
TungContAldeFerr	Tungsten-containing aldehyde:ferredoxin oxidoreductase (EC 1.2.7.5)
TungContFerrOxid2	Tungsten-containing ferredoxin oxidoreductase WOR4
TungContFormDehy2	tungsten-containing formate dehydrogenase alpha subunit
TungContFormFerr	Tungsten-containing formaldehyde:ferredoxin oxidoreductase
TwinArgiTranProt	Twin-arginine translocation protein TatA
TwinArgiTranProt12	Twin-arginine translocation protein TatAy
TwinArgiTranProt13	Twin-arginine translocation protein TatCy
TwinArgiTranProt2	Twin-arginine translocation protein TatB
TwinArgiTranProt3	Twin-arginine translocation protein TatC
TwinArgiTranProt4	Twin-arginine translocation protein TatAd
TwinArgiTranProt5	Twin-arginine translocation protein TatE
TwinArgiTranProt8	Twin-arginine translocation protein TatCd
TwitMotiProtPilt	Twitching motility protein PilT
Two4fe4sClusProt	Two [4Fe-4S] cluster protein DVU_0531
TwoCompNitrFixaTran	Two-component nitrogen fixation transcriptional regulator FixJ
TwoCompOxygSensHist	Two-component oxygen-sensor histidine kinase FixL
TwoCompRespReguAsso	Two-component response regulator, associated with ferric iron transporter, SPy1062 homolog
TwoCompRespReguAsso2	Two component response regulator associated with urea and amide use
TwoCompRespReguColo	Two-component response regulator colocalized with HrtAB transporter
TwoCompRespReguMala	Two-component response regulator, malate (EC 2.7.3.-)
TwoCompRespReguPfer	Two-component response regulator PfeR, enterobactin
TwoCompRespReguSa14n1	Two-component response regulator SA14-24
TwoCompRespReguVir	Two-component response regulator of vir regulon, VirG
TwoCompRespReguYesn2	Two-component response regulator yesN, associated with MetSO reductase
TwoCompSensHistKina22	Two-component sensor histidine kinase PfeS, enterobactin
TwoCompSensHistKina4	Two-component sensor histidine kinase, malate (EC 2.7.3.-)
TwoCompSensHistKina9	Two-component sensor histidine kinase PleC
TwoCompSensKinaAsso	Two-component sensor kinase, associated with ferric iron transporter, SPy1061 homolog
TwoCompSensKinaSa14n1	Two-component sensor kinase SA14-24
TwoCompSensKinaVir	Two-component sensor kinase of vir regulon, VirA
TwoCompSensKinaYesm2	Two-component sensor kinase yesM, associated with MetSO reductase (EC 2.7.3.-)
TwoCompSensPils	Two-component sensor PilS
TwoCompSystHistKina7	Two component system histidine kinase ArlS (EC 2.7.3.-)
TwoCompSystRespRegu	Two-component system response regulator QseB
TwoCompSystRespRegu2	Two component system response regulator MtrA
TwoCompSystSensHist2	Two component system sensor histidine kinase MtrB
TwoCompSystSensHist5	Two component system sensor histidine kinase MprB
TwoCompSystYycfRegu	Two-component system YycFG regulatory protein YycI
TwoCompSystYycfRegu2	Two-component system YycFG regulatory protein YycH
TwoCompTranReguProt	Two-component transcriptional regulatory protein BasR (activated by BasS)
TwoCompTranReguVrar	Two component transcriptional regulator VraR
Type4FimbBiogProt6	type 4 fimbrial biogenesis protein FimU
TypeCbb3CytoOxid	Type cbb3 cytochrome oxidase biogenesis protein CcoG, involved in Cu oxidation
TypeCbb3CytoOxid2	Type cbb3 cytochrome oxidase biogenesis protein CcoI
TypeCbb3CytoOxid3	Type cbb3 cytochrome oxidase biogenesis protein CcoS, involved in heme b insertion
TypeCbb3CytoOxid4	Type cbb3 cytochrome oxidase biogenesis protein CcoH
TypeIRestModiSyst	Type I restriction-modification system, restriction subunit R (EC 3.1.21.3)
TypeIRestModiSyst2	Type I restriction-modification system, specificity subunit S (EC 3.1.21.3)
TypeIRestModiSyst3	Type I restriction-modification system, DNA-methyltransferase subunit M (EC 2.1.1.72)
TypeISecrMembFusi2	Type I secretion membrane fusion protein, HlyD family
TypeISecrOuteMemb2	Type I secretion outer membrane protein, TolC family
TypeISecrSystAtpa	Type I secretion system ATPase, LssB family LapB
TypeISecrSystAtpa2	type I secretion system ATPase
TypeISecrSystMemb	Type I secretion system, membrane fusion protein LapC
TypeISecrSystOute	Type I secretion system, outer membrane component LapE
TypeIiIvSecrSyst	Type II/IV secretion system protein TadC, associated with Flp pilus assembly
TypeIiIvSecrSyst2	Type II/IV secretion system ATP hydrolase TadA/VirB11/CpaF, TadA subfamily
TypeIiIvSecrSyst3	Type II/IV secretion system secretin RcpA/CpaC, associated with Flp pilus assembly
TypeIiIvSecrSyst4	Type II/IV secretion system ATPase TadZ/CpaE, associated with Flp pilus assembly
TypeIiRestModiEnzy	Type II restriction-modification enzyme, methylase family protein (STM4495 in Salmonella)
TypeIiiEffe	Type III effector
TypeIiiEffeHrpwHair	Type III effector HrpW, hairpin with pectate lyase domain
TypeIiiEffeProtAvre	Type III effector protein AvrE1
TypeIiiHelpProtHrpk	Type III helper protein HrpK1
TypeIiiSecrBridBetw	Type III secretion bridge between inner and outermembrane lipoprotein (YscJ,HrcJ,EscJ, PscJ)
TypeIiiSecrChapProt	Type III secretion chaperone protein for YopE (SycE)
TypeIiiSecrChapProt2	Type III secretion chaperone protein for YopN (SycN,YscB)
TypeIiiSecrChapProt3	Type III secretion chaperone protein for YopD (SycD)
TypeIiiSecrChapProt4	Type III secretion chaperone protein for YopT (SycT)
TypeIiiSecrChapProt5	Type III secretion chaperone protein for YopH (SycH)
TypeIiiSecrChapSycn	Type III secretion chaperone SycN
TypeIiiSecrCytoAtp	Type III secretion cytoplasmic ATP synthase (EC 3.6.3.14, YscN,SpaL,MxiB,HrcN,EscN)
TypeIiiSecrCytoLcrg	Type III secretion cytoplasmic LcrG inhibitor (LcrV,secretion and targeting control protein, V antigen)
TypeIiiSecrCytoPlug	Type III secretion cytoplasmic plug protein (LcrG)
TypeIiiSecrCytoProt	Type III secretion cytoplasmic protein (YscL)
TypeIiiSecrCytoProt2	Type III secretion cytoplasmic protein (YscK)
TypeIiiSecrCytoProt3	Type III secretion cytoplasmic protein (YscI)
TypeIiiSecrCytoProt4	Type III secretion cytoplasmic protein (YscF)
TypeIiiSecrEffeProt	Type III secretion effector protein (YopR, encoded by YscH)
TypeIiiSecrEffeSsef	Type III secretion effector SseF
TypeIiiSecrFlagRegu	Type III secretion and flagellar regulator RtsA
TypeIiiSecrHostInje	Type III secretion host injection protein (YopB)
TypeIiiSecrHostInje2	Type III secretion host injection and negative regulator protein (YopD)
TypeIiiSecrHpabProt	Type III secretion HpaB protein
TypeIiiSecrHrpaPili	Type III secretion HrpA pilin
TypeIiiSecrHypoProt	Type III secretion, hypothetical protein
TypeIiiSecrInjeViru	Type III secretion injected virulence protein (EC 3.4.22.-,YopT,cysteine protease,depolymerizes actin filaments of cytoskeleton,causes cytotoxicity)
TypeIiiSecrInjeViru2	Type III secretion injected virulence protein (YopP,YopJ, induces apoptosis, prevents cytokine induction, inhibits NFkb activation)
TypeIiiSecrInjeViru3	Type III secretion injected virulence protein (YopH,tyrosine phosphatase of FAK and p130cas, prevents phagocytosis)
TypeIiiSecrInjeViru4	Type III secretion injected virulence protein (YopE)
TypeIiiSecrInjeViru5	Type III secretion injected virulence protein (YopO,YpkA,serine-threonine kinase)
TypeIiiSecrInneMemb	Type III secretion inner membrane protein (YscD,homologous to flagellar export components)
TypeIiiSecrInneMemb10	Type III secretion inner membrane protein SctR
TypeIiiSecrInneMemb11	Type III secretion inner membrane protein SctT
TypeIiiSecrInneMemb2	Type III secretion inner membrane protein (YscU,SpaS,EscU,HrcU,SsaU, homologous to flagellar export components)
TypeIiiSecrInneMemb3	Type III secretion inner membrane protein (YscT,HrcT,SpaR,EscT,EpaR1,homologous to flagellar export components)
TypeIiiSecrInneMemb4	Type III secretion inner membrane protein (YscS,homologous to flagellar export components)
TypeIiiSecrInneMemb5	Type III secretion inner membrane protein (YscR,SpaR,HrcR,EscR,homologous to flagellar export components)
TypeIiiSecrInneMemb6	Type III secretion inner membrane protein (YscQ,homologous to flagellar export components)
TypeIiiSecrInneMemb7	Type III secretion inner membrane channel protein (LcrD,HrcV,EscV,SsaV)
TypeIiiSecrInneMemb8	type III secretion inner membrane protein SctL
TypeIiiSecrLowCalc	Type III secretion low calcium response protein (LcrR)
TypeIiiSecrNegaModu	Type III secretion negative modulator of injection (YopK,YopQ,controls size of translocator pore)
TypeIiiSecrNegaRegu	Type III secretion negative regulator (LscZ)
TypeIiiSecrNegaRegu2	Type III secretion negative regulator of effector production protein (LcrQ,YscM, YscM1 and YscM2)
TypeIiiSecrOuteCont	Type III secretion outermembrane contact sensing protein (YopN,Yop4b,LcrE)
TypeIiiSecrOuteNega	Type III secretion outermembrane negative regulator of secretion (TyeA)
TypeIiiSecrOutePore	Type III secretion outermembrane pore forming protein (YscC,MxiD,HrcC, InvG)
TypeIiiSecrPossInje	Type III secretion possible injected virulence protein (YopM)
TypeIiiSecrProt	Type III secretion protein (YscE)
TypeIiiSecrProt2	Type III secretion protein (YscP)
TypeIiiSecrProt4	Type III secretion protein (YscA)
TypeIiiSecrProtEprh	Type III secretion protein EprH
TypeIiiSecrProtHrcq	type III secretion protein HrcQb
TypeIiiSecrProtHrcq2	type III secretion protein HrcQa
TypeIiiSecrProtHrpb	Type III secretion protein, HrpB1
TypeIiiSecrProtHrpb2	Type III secretion protein HrpB2
TypeIiiSecrProtHrpb3	Type III secretion protein HrpB7
TypeIiiSecrProtHrpb4	type III secretion protein HrpB(Pto)
TypeIiiSecrProtHrpd	type III secretion protein HrpD
TypeIiiSecrProtHrpe	Type III secretion protein HrpE
TypeIiiSecrProtHrpg	type III secretion protein HrpG
TypeIiiSecrProtHrpj	type III secretion protein HrpJ
TypeIiiSecrProtHrpp	type III secretion protein HrpP
TypeIiiSecrProtHrpq	type III secretion protein HrpQ
TypeIiiSecrProtHrpt	type III secretion protein HrpT
TypeIiiSecrProtSctc	Type III secretion protein SctC
TypeIiiSecrProtSctj	Type III secretion protein SctJ
TypeIiiSecrProtSctx	Type III secretion protein SctX
TypeIiiSecrProtSsab	Type III secretion protein SsaB
TypeIiiSecrProtSsag	Type III secretion protein SsaG
TypeIiiSecrProtSsah	Type III secretion protein SsaH
TypeIiiSecrProtSsai	Type III secretion protein SsaI
TypeIiiSecrProtSsak	Type III secretion protein SsaK
TypeIiiSecrSpanBact	Type III secretion spans bacterial envelope protein (YscG)
TypeIiiSecrSpanBact2	Type III secretion spans bacterial envelope protein (YscO)
TypeIiiSecrSystProt	Type III secretion system protein BsaR
TypeIiiSecrSystProt2	Type III secretion system protein
TypeIiiSecrSystProt5	type III secretion system protein, YscF family
TypeIiiSecrTherProt	Type III secretion thermoregulatory protein (LcrF,VirF,transcription regulation of virulence plasmid)
TypeIiiSecrTranActi	Type III secretion transcriptional activator HilA
TypeIiiSecrTranEffe	Type III secretion translocator of effector proteins (HrpF, NolX)
TypeIiiSecrTranLipo	Type III secretion transporter lipoprotein (YscW,VirG)
TypeIiiSecrTranRegu	Type III secretion transcriptional regulator HilC (= SirC)
TypeIiiSecrTranRegu2	Type III secretion transcriptional regulator HilD
TypeIiiSecrTranSctl	Type III secretion translocase SctL
TypeIvFimbAsseAtpa	Type IV fimbrial assembly, ATPase PilB
TypeIvFimbAsseProt	Type IV fimbrial assembly protein PilC
TypeIvFimbBiogProt	Type IV fimbrial biogenesis protein PilY1
TypeIvFimbBiogProt2	Type IV fimbrial biogenesis protein PilW
TypeIvFimbBiogProt3	Type IV fimbrial biogenesis protein PilV
TypeIvFimbBiogProt4	type IV fimbrial biogenesis protein PilX
TypeIvFimbBiogProt5	type IV fimbrial biogenesis protein FimT
TypeIvFimbBiogProt6	Type IV fimbrial biogenesis protein PilY2
TypeIvFimbExprRegu	Type IV fimbriae expression regulatory protein PilR
TypeIvPiliPila	Type IV pilin PilA
TypeIvPiluBiogProt10	type IV pilus biogenesis protein PilE
TypeIvPiluBiogProt15	Type IV pilus biogenesis protein PilMx
TypeIvPiluBiogProt16	Type IV pilus biogenesis protein PilNx
TypeIvPiluBiogProt17	Type IV pilus biogenesis protein PilOPx
TypeIvPiluBiogProt2	Type IV pilus biogenesis protein PilM
TypeIvPiluBiogProt3	Type IV pilus biogenesis protein PilQ
TypeIvPiluBiogProt4	Type IV pilus biogenesis protein PilN
TypeIvPiluBiogProt5	Type IV pilus biogenesis protein PilO
TypeIvPiluBiogProt7	Type IV pilus biogenesis protein PilP
TypeIvPrepPeptTadv	Type IV prepilin peptidase TadV/CpaA
TypeIvSecrPathProt	Type IV secretory pathway, protease TraF
TypeIvSecrPathVird2	Type IV secretory pathway, VirD2 components (relaxase)
TypeIvSectLeadPept	Type-IV sectretion leader peptidase/N-methyltransferase
TyroProtKinaEpsd	Tyrosine-protein kinase EpsD (EC 2.7.10.2)
TyroProtKinaTran	Tyrosine-protein kinase transmembrane modulator EpsC
TyroProtKinaWzc2	Tyrosine-protein kinase => Wzc (EC 2.7.10.2)
TyroRecoXerd	Tyrosine recombinase XerD
TyroTrnaSynt	Tyrosyl-tRNA synthetase (EC 6.1.1.1)
TyroTrnaSyntChlo	Tyrosyl-tRNA synthetase, chloroplast (EC 6.1.1.1)
TyroTrnaSyntMito	Tyrosyl-tRNA synthetase, mitochondrial (EC 6.1.1.1)
U6SnrnAssoSmLike	U6 snRNA-associated Sm-like protein LSm6
UbidFamiDecaAsso	UbiD family decarboxylase associated with menaquinone via futalosine
UbiqBiosEnzyCoq7n1	Ubiquinone biosynthesis enzyme COQ7
UbiqBiosMethCoq5n1	Ubiquinone biosynthesis methyltransferase COQ5, mitochondrial precursor (EC 2.1.1.-)
UbiqBiosProtUbij	Ubiquinone biosynthesis protein UbiJ
UbiqBiosReguProt	Ubiquinone biosynthesis regulatory protein kinase UbiB
UbiqCytoCChap	Ubiquinol-cytochrome C chaperone
UbiqLikeSmalArch	Ubiquitin-like small archaeal modifier protein SAMP2
UbiqLikeSmalArch2	Ubiquitin-like small archaeal modifier protein SAMP1
UbiqMenaBiosMeth	Ubiquinone/menaquinone biosynthesis methyltransferase UBIE (EC 2.1.1.-)
Udp23Diac23DideD2	UDP-2,3-diacetamido-2,3-dideoxy-D-glucuronic acid 2-epimerase (EC 5.1.3.23)
Udp23DiacDiph	UDP-2,3-diacylglucosamine diphosphatase (EC 3.6.1.54)
Udp23DiacPyro	UDP-2,3-diacylglucosamine pyrophosphatase
Udp24Diac246Trid	UDP-2,4-diacetamido-2,4,6-trideoxy-beta-L-altropyranose hydrolase (EC 3.6.1.57)
Udp2Acet2DeoxDGluc3	UDP-2-acetamido-2-deoxy-D-glucuronic acid dehydrogenase (NAD+) (EC 1.1.1.335)
Udp2Acet3Amin23Dide	UDP-2-acetamido-3-amino-2,3-dideoxy-D-glucuronic acid acetyltransferase (EC 2.3.1.201)
Udp3O3HydrGlucNAcyl	UDP-3-O-[3-hydroxymyristoyl] glucosamine N-acyltransferase (EC 2.3.1.-)
Udp3O3HydrNAcetDeac	UDP-3-O-[3-hydroxymyristoyl] N-acetylglucosamine deacetylase (EC 3.5.1.-)
Udp4Amin46DideNAcet	UDP-4-amino-4,6-dideoxy-N-acetyl-beta-L-altrosamine transaminase (EC 2.6.1.92)
Udp4Amin46DideNAcet2	UDP-4-amino-4,6-dideoxy-N-acetyl-beta-L-altrosamine N-acetyltransferase (EC 2.3.1.202)
Udp4Amin4DeoxLArab	UDP-4-amino-4-deoxy-L-arabinose--oxoglutarate aminotransferase (EC 2.6.1.-)
Udp4Amin4DeoxLArab2	UDP-4-amino-4-deoxy-L-arabinose formyltransferase (EC 2.1.2.13)
UdpGalaMuta	UDP-galactopyranose mutase (EC 5.4.99.9)
UdpGalaTranGlftCata	UDP-galactofuranosyl transferase GlfT1, catalyzes initiation of cell wall galactan polymerization (EC 2.4.1.287)
UdpGluc46Dehy	UDP-glucose 4,6-dehydratase (EC 4.2.1.76)
UdpGluc4Epim	UDP-glucose 4-epimerase (EC 5.1.3.2)
UdpGluc6Dehy	UDP-glucose 6-dehydrogenase (EC 1.1.1.22)
UdpGlucAcidOxid	UDP-glucuronic acid oxidase (UDP-4-keto-hexauronic acid decarboxylating) (EC 1.1.1.305)
UdpGlucDehyHyalAcid	UDP-glucose dehydrogenase in hyaluronic acid synthesis (EC 1.1.1.22)
UdpGlucDehyTeicAcid	UDP-glucose dehydrogenase in teichuronic acid synthesis TuaD (EC 1.1.1.22)
UdpGlucLipoAlph1n2	UDP-glucose:(glucosyl)lipopolysaccharide alpha-1,2-glucosyltransferase (EC 2.4.1.58)
UdpGlucLpsAlph3Gluc	UDP-glucose:(heptosyl) LPS alpha1,3-glucosyltransferase WaaG (EC 2.4.1.-)
UdpGlucUndePhosGluc	UDP-glucose:undecaprenyl-phosphate glucose-1-phosphate transferase (EC 2.7.8.31)
UdpNAcet1Carb	UDP-N-acetylglucosamine 1-carboxyvinyltransferase (EC 2.5.1.7)
UdpNAcet2Epim	UDP-N-acetylglucosamine 2-epimerase (EC 5.1.3.14)
UdpNAcet2Epim2n1	UDP-N-acetylglucosamine 2-epimerase 2 (EC 5.1.3.14)
UdpNAcet46Dehy	UDP-N-acetylglucosamine 4,6-dehydratase (EC 4.2.1.-)
UdpNAcet46Dehy2	UDP-N-acetylglucosamine 4,6-dehydratase (inverting) (EC 4.2.1.115)
UdpNAcet4Epim	UDP-N-acetylglucosamine 4-epimerase (EC 5.1.3.7)
UdpNAcetAlanLiga	UDP-N-acetylmuramate--alanine ligase (EC 6.3.2.8)
UdpNAcetDGluc6Dehy	UDP-N-acetyl-D-glucosamine 6-dehydrogenase (EC 1.1.1.136)
UdpNAcetDGlut26Diam	UDP-N-acetylmuramoylalanyl-D-glutamate--2,6-diaminopimelate ligase (EC 6.3.2.13)
UdpNAcetDGlutLDiam	UDP-N-acetylmuramoylalanyl-D-glutamate--L-diaminobutyrate ligase
UdpNAcetDGlutLL2n1	UDP-N-acetylmuramoylalanyl-D-glutamate--L,L-2,6-diaminopimelate ligase
UdpNAcetDGlutLLysi	UDP-N-acetylmuramoylalanyl-D-glutamate--L-lysine ligase (EC 6.3.2.7)
UdpNAcetDGlutLOrni	UDP-N-acetylmuramoylalanyl-D-glutamate--L-ornithine ligase
UdpNAcetDGlutLiga	UDP-N-acetylmuramoylalanine--D-glutamate ligase (EC 6.3.2.9)
UdpNAcetDMannDehy	UDP-N-acetyl-D-mannosamine dehydrogenase (EC 1.1.1.-)
UdpNAcetGlycLiga	UDP-N-acetylmuramate--glycine ligase
UdpNAcetLAlanGamm	UDP-N-acetylmuramate:L-alanyl-gamma-D-glutamyl-meso-diaminopimelate ligase (EC 6.3.2.-)
UdpNAcetLMalaGlyc	UDP-N-acetylglucosamine:L-malate glycosyltransferase
UdpNAcetLSeriLiga	UDP-N-acetylmuramate--L-serine ligase
UdpNAcetNAcet	UDP-N-acetylbacillosamine N-acetyltransferase (EC 2.3.1.203)
UdpNAcetNAcetPyro	UDP-N-acetylglucosamine--N-acetylmuramyl-(pentapeptide) pyrophosphoryl-undecaprenol N-acetylglucosamine transferase (EC 2.4.1.227)
UdpNAcetRedu	UDP-N-acetylenolpyruvoylglucosamine reductase (EC 1.1.1.158)
UdpNAcetTran	UDP-N-acetylbacillosamine transaminase (EC 2.6.1.34)
UdpNAcetTripDAlan	UDP-N-acetylmuramoyl-tripeptide--D-alanyl-D-alanine ligase (EC 6.3.2.10)
UdpSulfSynt	UDP-sulfoquinovose synthase (EC 3.13.1.1)
UnchAlanRaceDoma	Uncharacterized alanine racemase domain-containing protein YhfX
UnchChapProtYegd	Uncharacterized chaperone protein YegD
UnchCyanProtSll0n1	Uncharacterized cyanobacterial protein, sll0461 homolog, ProA-like, but lacks essential Cysteine residue at catalytic site
UnchDehyPyrrQuin	Uncharacterized dehydrogenase [pyrroloquinoline-quinone]
UnchDoma	uncharacterized domain
UnchDomaNotCdd	Uncharacterized domain, not in CDD
UnchDuf8FamiProt	Uncharacterized DUF849 family protein SMc01637
UnchFeSProtSideBios	Uncharacterized Fe-S protein in siderophore biosynthesis operon
UnchGlutSTranLike	Uncharacterized glutathione S-transferase-like protein
UnchGstLikeProtYghu	Uncharacterized GST-like protein yghU associated with glutathionylspermidine synthetase/amidase
UnchGstLikeProtYibf	Uncharacterized GST-like protein YibF
UnchGstLikeProtYncg	Uncharacterized GST-like protein yncG
UnchHydrPa06n1	Uncharacterized hydroxylase PA0655
UnchIronCompAbcUpta	Uncharacterized iron compound ABC uptake transporter, permease protein
UnchIronCompAbcUpta2	Uncharacterized iron compound ABC uptake transporter, ATP-binding protein
UnchIronCompAbcUpta3	Uncharacterized iron compound ABC uptake transporter, substrate-binding protein
UnchMembProtYwcb	Uncharacterized membrane protein YwcB
UnchMetaAbcTranEnte	Uncharacterized metabolite ABC transporter in Enterobacteriaceae, ATP-binding protein EC-YbbA
UnchMetaAbcTranEnte2	Uncharacterized metabolite ABC transporter in Enterobacteriaceae, permease protein EC-YbbP
UnchMethYodh	Uncharacterized methyltransferase YodH
UnchMonoGlutYcf6n1	Uncharacterized monothiol glutaredoxin ycf64-like
UnchNudiHydrNudl	Uncharacterized Nudix hydrolase NudL
UnchOuteMembProt	Uncharacterized outer membrane protein YfaZ
UnchPeptU32FamiMemb	Uncharacterized peptidase U32 family member YhbV
UnchProt2	Uncharacterized protein (associated with DNA helicase - Rad25 homolog)
UnchProtBsl7Homo	Uncharacterized protein, Bsl7517 homolog
UnchProtClusWith	Uncharacterized protein clustered with Type I restriction-modification system
UnchProtClusWith2	Uncharacterized protein clustered with hemC, hemD in Alphaproteobacteria
UnchProtCog1n1	Uncharacterized protein COG1849 (DUF357)
UnchProtCog3n1	Uncharacterized protein COG3236
UnchProtContDuf1n1	Uncharacterized protein, contains DUF1788 domain
UnchProtDuf1Poss	Uncharacterized protein DUF1284, possibly iron-sulphur binding
UnchProtDuf5n1	Uncharacterized protein DUF547
UnchProtDvu1n1	Uncharacterized protein DVU1291
UnchProtEcHemx	Uncharacterized protein EC-HemX
UnchProtEcHemyProt	Uncharacterized protein EC-HemY in Proteobacteria (unrelated to HemY-type PPO in GramPositives)
UnchProtGlml	Uncharacterized protein GlmL
UnchProtMj05n15	Uncharacterized protein MJ0570
UnchProtRv04Mt05n1	Uncharacterized protein Rv0487/MT0505 clustered with mycothiol biosynthesis gene
UnchProtSco4n3	Uncharacterized protein SCO4840
UnchProtSimiNTerm	Uncharacterized protein, similar to the N-terminal domain of Lon protease
UnchProtSporDist	Uncharacterized protein sporadically distributed in bacteria and archaea, not a Lon-type protease
UnchProtSporDist2	Uncharacterized protein sporadically distributed in bacteria and archaea, PglZ domain
UnchProtSporDist3	Uncharacterized protein sporadically distributed in bacteria and archaea (STM4496 in Salmonella)
UnchProtTlr1n1	Uncharacterized protein Tlr1954
UnchProtWithLysm	Uncharacterized protein with LysM domain, COG1652
UnchProtYaao	Uncharacterized protein YaaO
UnchProtYabe	Uncharacterized protein YabE
UnchProtYabs	Uncharacterized protein YabS
UnchProtYacpSimi	Uncharacterized protein YacP, similar to C-terminal domain of ribosome protection-type Tc-resistance proteins
UnchProtYaerWith	Uncharacterized protein YaeR with similarity to glyoxylase family
UnchProtYbcj	Uncharacterized protein YbcJ
UnchProtYbfe	Uncharacterized protein ybfE
UnchProtYfad	Uncharacterized protein YfaD
UnchProtYgfm	Uncharacterized protein YgfM
UnchProtYhbu	Uncharacterized protease YhbU
UnchProtYhft	Uncharacterized protein YhfT
UnchProtYhfu	Uncharacterized protein YhfU
UnchProtYkvtNotInvo	Uncharacterized protein YkvT, NOT involved in spore germination
UnchProtYmdb	Uncharacterized protein YmdB
UnchProtYpif	Uncharacterized protein YpiF
UnchProtYpja	Uncharacterized protein YpjA
UnchProtYpoc	Uncharacterized protein YpoC
UnchProtYppc	Uncharacterized protein YppC
UnchProtYrdd	Uncharacterized protein YrdD
UnchProtYvieClus	Uncharacterized protein YviE clustered with flagellar hook-associated proteins
UnchProtYvyf	Uncharacterized protein YvyF
UnchPyriPhosProt	Uncharacterized pyridoxal phosphate protein YhfS
UnchSecrProtAsso	Uncharacterized secreted protein associated with spyDAC
UnchSecrProtYbbr	uncharacterized secreted protein, YBBR Bacillus subtilis homolog
UnchSideBiosProt	Uncharacterized siderophore biosynthesis protein near heme transporter HtsABC
UnchSideSBiosAcsa	Uncharacterized siderophore S biosynthesis AcsA-like protein
UnchSideSBiosProt	Uncharacterized siderophore S biosynthesis protein, AcsD-like
UnchSideSBiosProt2	Uncharacterized siderophore S biosynthesis protein, AcsC-like
UnchSigm54DepeTran	Uncharacterized sigma-54-dependent transcriptional regulator YgeV
UnchTranMdtdMajo	Uncharacterized transporter MdtD of major facilitator superfamily (MFS)
UndeDiph	Undecaprenyl-diphosphatase (EC 3.6.1.27)
UndeDiphBcrc	Undecaprenyl-diphosphatase BcrC (EC 3.6.1.27)
UndePhos4Deox4Form	Undecaprenyl-phosphate 4-deoxy-4-formamido-L-arabinose transferase (EC 2.4.2.53)
UndePhosAlph4Amin	Undecaprenyl phosphate-alpha-4-amino-4-deoxy-L-arabinose arabinosyl transferase (EC 2.4.2.43)
UndePhosAlphNAcet	Undecaprenyl-phosphate alpha-N-acetylglucosaminyl 1-phosphate transferase (EC 2.7.8.33)
UndePhosAminFlip	Undecaprenyl phosphate-aminoarabinose flippase subunit ArnE
UndePhosAminFlip2	Undecaprenyl phosphate-aminoarabinose flippase subunit ArnF
UndePhosGala	Undecaprenyl-phosphate galactosephosphotransferase (EC 2.7.8.6)
UndePhosNNDiac1Phos	Undecaprenyl phosphate N,N'-diacetylbacillosamine 1-phosphate transferase (EC 2.7.8.36)
UnivStreProt	Universal stress protein A
UnivStreProtB	Universal stress protein B
UnivStreProtC	Universal stress protein C
UnivStreProtD	Universal stress protein D
UnivStreProtE	Universal stress protein E
UnivStreProtF	universal stress protein F
UnivStreProtFami	Universal stress protein family
UnivStreProtFami11	Universal stress protein family 8
UnivStreProtFami12	Universal stress protein family 7
UnivStreProtFami13	Universal stress protein family 2
UnivStreProtFami2	Universal stress protein family COG0589
UnivStreProtFami3	Universal stress protein family 1
UnivStreProtFami5	Universal stress protein family 3
UnivStreProtFami6	Universal stress protein family 4
UnivStreProtFami8	Universal stress protein family 6
UnivStreProtFami9	Universal stress protein family 5
UnivStreProtG	Universal stress protein G
UnivStreProtUspa7	Universal stress protein UspA in Ectoine TRAP cluster
UnknPentKinaTm09n1	Unknown pentose kinase TM0952
UnknProbInvoType	Unknown, probably involved in type III secretion
UnsaChonDisaHydr	Unsaturated chondroitin disaccharide hydrolase (3.2.1.180)
UnsaGlucHydr	Unsaturated glucuronyl hydrolase (EC 3.2.1.-)
UnspMonoAbcTranSyst	Unspecified monosaccharide ABC transport system, permease component 2
UnspMonoAbcTranSyst2	Unspecified monosaccharide ABC transport system, permease component Ia (FIG025991)
UnspMonoAbcTranSyst3	Unspecified monosaccharide ABC transport system, permease component Ib (FIG143636)
UnspMonoAbcTranSyst4	Unspecified monosaccharide ABC transport system, ATP-binding protein
UnspMonoAbcTranSyst6	Unspecified monosaccharide ABC transport system, permease component I
Upf0InneMembProt4	UPF0056 inner membrane protein YchE
Upf0InneMembProt9	UPF0056 inner membrane protein MarC
Upf0ProtMj03n1	UPF0218 protein MJ0395
Upf0ProtYaaa	UPF0246 protein YaaA
Upf0ProtYaeh	UPF0325 protein YaeH
Upf0ProtYaza	UPF0213 protein YazA
Upf0ProtYcar	UPF0434 protein YcaR
Upf0ProtYeex	UPF0265 protein YeeX
Upf0ProtYggs	UPF0001 protein YggS
Upf0ProtYhbq	UPF0213 protein YhbQ
Upf0ProtYitk	UPF0234 protein Yitk
Upf0ProtYjga	UPF0307 protein YjgA
Upf0ProtYpib	UPF0302 protein ypiB
Upf0ProtYpsa	UPF0398 protein YpsA
Upf0ProtYqge	UPF0301 protein YqgE
Upf0ProtYrzl	UPF0297 protein YrzL
Upf0ProtYtfp	UPF0131 protein YtfP
Upf0PyriPhosDepe	UPF0425 pyridoxal phosphate-dependent protein MJ0158
UracDnaGlycFami1n1	Uracil-DNA glycosylase, family 1
UracPerm	Uracil permease
UracPhos	Uracil phosphoribosyltransferase (EC 2.4.2.9)
UracXantPerm	uracil-xanthine permease
UreaAbcTranAtpaProt	Urea ABC transporter, ATPase protein UrtD
UreaAbcTranAtpaProt2	Urea ABC transporter, ATPase protein UrtE
UreaAbcTranPermProt	Urea ABC transporter, permease protein UrtB
UreaAbcTranPermProt2	Urea ABC transporter, permease protein UrtC
UreaAbcTranSubsBind	Urea ABC transporter, substrate binding protein UrtA
UreaAcceProtUred	Urease accessory protein UreD
UreaAcceProtUree	Urease accessory protein UreE
UreaAcceProtUref	Urease accessory protein UreF
UreaAcceProtUreg	Urease accessory protein UreG
UreaAlphSubu	Urease alpha subunit (EC 3.5.1.5)
UreaBetaSubu	Urease beta subunit (EC 3.5.1.5)
UreaCarb	Urea carboxylase (EC 6.3.4.6)
UreaCarbWithAllo	Urea carboxylase without Allophanate hydrolase 2 domains (EC 6.3.4.6)
UreaChanUrei	Urea channel UreI
UreaGammSubu	Urease gamma subunit (EC 3.5.1.5)
UreiAmin	Ureidoglycine aminohydrolase
UreiLyas	Ureidoglycolate lyase (EC 4.3.2.3)
UreiMalaSulfDehy	Ureidoglycolate/malate/sulfolactate dehydrogenase family (EC 1.1.1.-)
Uric	Uricase (urate oxidase) (EC 1.7.3.3)
UricAcidPermPucj	Uric acid permease PucJ
UricAcidPermPuck	Uric acid permease PucK
UridDiphGlucPyro	Uridine diphosphate glucose pyrophosphatase (EC 3.6.1.45)
UridKina	Uridine kinase (EC 2.7.1.48)
UridMonoKina	Uridine monophosphate kinase (EC 2.7.4.22)
UrocHydr	Urocanate hydratase (EC 4.2.1.49)
UronDehy	Uronate dehydrogenase (EC 1.1.1.203)
UronIsom	Uronate isomerase (EC 5.3.1.12)
UronIsomFamiBh04n1	Uronate isomerase, family BH0493 (EC 5.3.1.12)
UropIiiDeca	Uroporphyrinogen III decarboxylase (EC 4.1.1.37)
UropIiiMeth	Uroporphyrinogen-III methyltransferase (EC 2.1.1.107)
UropIiiSynt	Uroporphyrinogen-III synthase (EC 4.2.1.75)
UropIiiSyntBactDive	Uroporphyrinogen-III synthase in Bacteroidetes, divergent, putative (EC 4.2.1.75)
UropIiiSyntDiveFlav	Uroporphyrinogen-III synthase, divergent, Flavobacterial type (EC 4.2.1.75)
UropIiiSyntRickDive	Uroporphyrinogen-III synthase in Rickettsia, divergent, putative (EC 4.2.1.75)
UtilProtForUnknCate	Utilization protein for unknown catechol-siderophore X
UtpGluc1PhosUrid	UTP--glucose-1-phosphate uridylyltransferase (EC 2.7.7.9)
UtpGluc1PhosUrid4	UTP--glucose-1-phosphate uridylyltransferase in hyaluronic acid synthesis (EC 2.7.7.9)
UxuOperTranRegu	Uxu operon transcriptional regulator
VTypeAtpSyntSubu	V-type ATP synthase subunit K (EC 3.6.3.14)
VTypeAtpSyntSubu11	V-type ATP synthase subunit H (EC 3.6.3.14)
VTypeAtpSyntSubu2	V-type ATP synthase subunit D (EC 3.6.3.14)
VTypeAtpSyntSubu3	V-type ATP synthase subunit B (EC 3.6.3.14)
VTypeAtpSyntSubu4	V-type ATP synthase subunit A (EC 3.6.3.14)
VTypeAtpSyntSubu5	V-type ATP synthase subunit E (EC 3.6.3.14)
VTypeAtpSyntSubu6	V-type ATP synthase subunit F (EC 3.6.3.14)
VTypeAtpSyntSubu7	V-type ATP synthase subunit I (EC 3.6.3.14)
VTypeAtpSyntSubu8	V-type ATP synthase subunit G (EC 3.6.3.14)
VTypeAtpSyntSubu9	V-type ATP synthase subunit C (EC 3.6.3.14)
ValiDehy	Valine dehydrogenase (EC 1.4.1.-)
ValiPyruAmin	Valine--pyruvate aminotransferase (EC 2.6.1.66)
ValyTrnaSynt	Valyl-tRNA synthetase (EC 6.1.1.9)
ValyTrnaSyntChlo	Valyl-tRNA synthetase, chloroplast (EC 6.1.1.9)
ValyTrnaSyntMito	Valyl-tRNA synthetase, mitochondrial (EC 6.1.1.9)
VanaAbcTranAtpBind	Vanadate ABC transporter, ATP-binding protein
VanaAbcTranPermProt	Vanadate ABC transporter, permease protein
VanaAbcTranSubsBind	Vanadate ABC transporter, substrate-binding protein
VegProt	Veg protein
VegeCellWallProt2	Vegetative cell wall protein gp1 precursor
VeryLongChai3Hydr	Very-long-chain (3R)-3-hydroxyacyl-CoA dehydratase (EC 4.2.1.134)
VeryShorPatcMism	Very-short-patch mismatch repair endonuclease (G-T specific)
VesiFusiAtpa	Vesicle-fusing ATPase (EC 3.6.4.6)
VfrTranRegu	Vfr transcriptional regulator
VibrAmidBondForm	Vibrioferrin amide bond forming protein PvsD
VibrAmidBondForm2	Vibrioferrin amide bond forming protein PvsB
VibrDecaProtPvse	Vibrioferrin decarboxylase protein PvsE
VibrExtrZincProt	Vibriolysin, extracellular zinc protease (EC 3.4.24.25)
VibrLigaCarbProt	Vibrioferrin ligase/carboxylase protein PvsA
VibrMembSpanTran	Vibrioferrin membrane-spanning transport protein PvsC
VibrRecePvua	Vibrioferrin receptor PvuA
VibrUtilProtViub	Vibriobactin utilization protein ViuB
ViolBiosProtViob	Violacein biosynthesis protein vioB
VircProtPromTDna	VirC1 protein promotes T-DNA transfer, ParA/MinD-like
VirdProt	VirD3 protein
VireInvoNuclTran	VirE3 involved in nuclear transport of T-DNA, potential plant transcriptional activator
VireInvoNuclTran2	VirE2 involved in nuclear transport of T-DNA, single-strand DNA binding protein
VireInvoNuclTran3	VirE1 involved in nuclear transport of T-DNA, a chaperone for VirE2
VireProtInduByVira	VirE0 protein, induced by VirAG signaling system
ViruAssoCellWall	Virulence-associated cell-wall-anchored protein SasG (LPXTG motif), binding to squamous nasal epithelial cells
ViruAssoCellWall2	Virulence-associated cell-wall-anchored protein SasH (LPXTG motif)
ViruClusProtBVclb	virulence cluster protein B VclB
ViruClusProtVcla	virulence cluster protein A VclA
ViruPlasIntePgp8n1	Virulence plasmid integrase pGP8-D
ViruPlasParaFami	Virulence plasmid ParA family protein pGP5-D
ViruPlasProtPgp2n1	Virulence plasmid protein pGP2-D
ViruPlasProtPgp3n1	Virulence plasmid protein pGP3-D
ViruPlasProtPgp6n1	Virulence plasmid protein pGP6-D
ViruPlasReplDnaHeli	Virulence plasmid replicative DNA helicase pGP1-D
ViruProtMsga	Virulence protein MsgA
ViruProtPgp4D	Virulence protein pGP4-D
ViruReguFactPrfa	Virulence regulatory factor PrfA
VonWillFactTypeDoma2	Von Willebrand factor type A domain protein, associated with Flp pilus assembly
VulnUtilProtVuub	Vulnibactin utilization protein VuuB
WhibFamiTranRegu	WhiB family transcriptional regulator
XaaProAmin	Xaa-Pro aminopeptidase (EC 3.4.11.9)
XaaProDipePepq	Xaa-Pro dipeptidase PepQ (EC 3.4.13.9)
XantCoDehyMatuFact	Xanthine and CO dehydrogenases maturation factor, XdhC/CoxF family
XantDehyFadBindSubu	Xanthine dehydrogenase, FAD binding subunit (EC 1.17.1.4)
XantDehyIronSulf	Xanthine dehydrogenase iron-sulfur subunit (EC 1.17.1.4)
XantDehyMolyBind	Xanthine dehydrogenase, molybdenum binding subunit (EC 1.17.1.4)
XantGuanPhos	Xanthine-guanine phosphoribosyltransferase (EC 2.4.2.22)
XantInosTripPyro	Xanthosine/inosine triphosphate pyrophosphatase
XantPerm	Xanthine permease
XantPhos	Xanthine phosphoribosyltransferase (EC 2.4.2.22)
XantUracPerm	Xanthine-uracil permease
XantUracPermFami	Xanthine/uracil permease family protein
XylaOligAbcTranAtp	Xylan oligosaccharide ABC transporter, ATP-binding protein 2
XylaOligAbcTranAtp2	Xylan oligosaccharide ABC transporter, ATP-binding protein 1
XylaOligAbcTranPerm	Xylan oligosaccharide ABC transporter, permease component 1
XylaOligAbcTranPerm2	Xylan oligosaccharide ABC transporter, permease component 2
XylaOligAbcTranSubs	Xylan oligosaccharide ABC transporter, substrate-binding component
XyloAbcTranPeriXylo	Xylose ABC transporter, periplasmic xylose-binding protein XylF
XyloAbcTranPermProt2	Xylose ABC transporter, permease protein XylH
Xylu15BispPhosCbby	Xylulose-1,5-bisphosphate phosphatase CbbY, converts this Rubisco inhibiting byproduct to xylulose-5P
Xylu5PhosPhos	Xylulose-5-phosphate phosphoketolase (EC 4.1.2.9)
XyluKina	Xylulose kinase (EC 2.7.1.17)
YabjPuriReguProt	YabJ, a purine regulatory protein and member of the highly conserved YjgF family
YbakProxFamiProt	YbaK/ProX-family protein CD1969
YcilProt	YciL protein
YefmProt	YefM protein (antitoxin to YoeB)
YersSyntThiaRedu	Yersiniabactin synthetase, thiazolinyl reductase component Irp3
YgfdProtThatForm	YgfD: protein that forms a complex with the methylmalonyl-CoA mutase in a pathway for conversion of succinyl-CoA to propionyl-CoA
YhfaProtTraRegiSome	YhfA Protein in tra region of some IncF plasmids
YiheProtSerThrKina	YihE protein, a ser/thr kinase implicated in LPS synthesis and Cpx signalling
YlxpLikeProt	YlxP-like protein
Ync	Ync
Ynd	Ynd
YoebToxiProt	YoeB toxin protein
YpfjProtZincMeta	YpfJ protein, zinc metalloprotease superfamily
YqxmProtRequForLoca	YqxM protein, required for localization of TasA to extracellular matrix
YrbaProt	YrbA protein
YuzdLikeProt	YuzD-like protein
ZincBindDoma	Zinc binding domain
ZincFingTfiiType	Zinc finger, TFIIB-type domain protein
ZincMetaAure	Zinc metalloproteinase aureolysin (EC 3.4.24.29)
ZincResiAssoProt	Zinc resistance-associated protein
ZincUptaReguProt	Zinc uptake regulation protein Zur
ZnDepeHydr2	Zn-dependent hydrolase (beta-lactamase superfamily)
ZnDepeHydrHydr	Zn-dependent hydroxyacylglutathione hydrolase
ZnDepeHydrRnaMeta	Zn-dependent hydrolase, RNA-metabolising, CPSF 100 kDa analog
ZnDepeHydrRnaMeta3	Zn-dependent hydrolase, RNA-metabolising
ZnDepeHydrYycjWalj	Zn-dependent hydrolase YycJ/WalJ, required for cell wall metabolism and coordination of cell division with DNA replication
ZnDepeHydrYycjWalj2	Zn-dependent hydrolase YycJ/WalJ homolog within prophage
ZnRibbContPossRna	Zn-ribbon-containing, possibly RNA-binding protein and truncated derivatives
ZonaOcclToxi	Zona occludens toxin
ZonaOcclToxiLike	Zona occludens toxin-like phage protein
ZwitResiProtZmar	Zwittermicin A resistance protein ZmaR
