#!/bin/bash
#$ -V
#$ -N flu_diamond
#$ -cwd
#$ -pe smp 25
#$ -l h_vmem=8G


diamond=$1
diamond_db=$2
result_dir=$3
libname=$4
threads=$5

dir_fasta_processed=$result_dir/4.fasta_processed
dir_diamond=$result_dir/5.diamond

diamond blastx -d $diamond_db -q $dir_fasta_processed/$libname\_raw\.fasta -a $result_dir/tmp/$libname -e 0.1 -p $threads -t $result_dir/tmp --salltitles
diamond view -a $result_dir/tmp/$libname\.daa -o $dir_diamond/$libname\.m8
rm -fr $result_dir/tmp/$libname\.daa