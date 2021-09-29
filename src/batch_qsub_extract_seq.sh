#!/bin/bash
#$ -V
#$ -N aiv_seeker-extract
#$ -cwd
#$ -pe smp 1
#$ -l h_vmem=8G


exe_path=$1
input=$2
db=$3
output=$4
perl $exe_path/src/get_reads_first_round.pl -i $input -d $db -o $output