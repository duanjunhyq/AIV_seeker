#!/bin/bash
#$ -V
#$ -N flu_remove_chimeric
#$ -cwd
#$ -pe smp 32
#$ -l h_vmem=8G


exe_path=$1
chimeric_threshold=$2
input=$3
db=$4
chimeric_output=$5
without_chimeric_output=$6
lib_no_chimerica_seq=$7
perl $exe_path/module/remove_chimeric.pl -c $chimeric_threshold -i $input -d $db -o $chimeric_output >$without_chimeric_output
if [ -s "$without_chimeric_output" ]; then
    perl $exe_path/module/get_reads_first_round.pl -i $without_chimeric_output -d $db -o $lib_no_chimerica_seq
fi