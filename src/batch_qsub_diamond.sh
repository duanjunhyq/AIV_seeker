#!/bin/bash
#$ -V
#$ -N aiv_seeker-diamond
#$ -cwd
#$ -l h_vmem=8G


diamond_db=$1
result_dir=$2
libname=$3
threads=$4

dir_fasta_processed=$result_dir/4.fasta_processed
dir_diamond=$result_dir/5.diamond

conda run -n aiv_seeker-diamond diamond blastx -d $diamond_db -q $dir_fasta_processed/$libname\_raw\.fasta -o $dir_diamond/$libname\.m8 -e 100 -p $threads -t $result_dir/tmp --masking 0 
