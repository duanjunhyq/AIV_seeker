#!/bin/bash
#$ -V
#$ -N aiv_seeker-blast
#$ -cwd
#$ -l h_vmem=8G

input=$1
blast_output=$2
blast_output_self=$3
flugenedb=$4
threads=$5


conda run -n aiv_seeker-blast blastn -num_threads $threads -db $flugenedb -query $input -evalue 1e-20 -out $blast_output -outfmt 6 -num_alignments 250 -dust no
conda run -n aiv_seeker-blast makeblastdb -in $input -dbtype nucl
conda run -n aiv_seeker-blast blastn -db $input -query $input -evalue 1e-10 -out $blast_output_self -outfmt 6 -num_alignments 1 -dust no
