p3-echo $1 | p3-get-drug-genomes --resistant --eq "genome_name,$2" --attr genome_id >res.tbl
p3-echo $1 | p3-get-drug-genomes --susceptible --eq "genome_name,$2" --attr genome_id >sus.tbl
nohup p3-signature-families --verbose --col=genome_id --gs1=res.tbl --gs2=sus.tbl >res.signatures.tbl 2>res.log &
nohup p3-signature-families --verbose --col=genome_id --gs1=sus.tbl --gs2=res.tbl >sus.signatures.tbl 2>sus.log &
