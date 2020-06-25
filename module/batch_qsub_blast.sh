#!/bin/bash
#$ -V
#$ -N flu_blastn
#$ -cwd
#$ -pe smp 25
#$ -l h_vmem=8G


input=$1
blast_output=$2
blast_output_self=$3
flugenedb=$4
threads=$5

/home/dj/miniconda3/envs/aiv/bin/blastn -num_threads $threads -db $flugenedb -query $input -evalue 1e-20 -out $blast_output -outfmt 6 -num_alignments 250 -dust no
/home/dj/miniconda3/envs/aiv/bin/makeblastdb -in $input -dbtype nucl
/home/dj/miniconda3/envs/aiv/bin/blastn -db $input -query $input -evalue 1e-10 -out $blast_output_self -outfmt 6 -num_alignments 1 -dust no

#old version 
#blastall -i $input -d $GISAID -o blast_output -p blastn -e 1e-20 -F F -b 250 -v 250 -m 8
#blastall -p blastn -i $input -d $input -o $blast_output_self -m 8 -e 1e-10 -F F -b 1 -v 1