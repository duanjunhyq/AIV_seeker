#!/bin/bash
#$ -V
#$ -N flu_extract_seq
#$ -cwd
#$ -pe smp 1
#$ -l h_vmem=8G


exe_path=$1
input=$2
db=$3
output=$4
perl $exe_path/module/get_reads_first_round.pl -i $input -d $db -o $output