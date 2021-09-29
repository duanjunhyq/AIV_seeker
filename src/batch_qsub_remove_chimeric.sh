#!/bin/bash
#$ -V
#$ -N aiv_seeker-chimeric
#$ -cwd
#$ -pe smp 2
#$ -l h_vmem=8G


exe_path=$1
chimeric_threshold=$2
input=$3
db=$4
chimeric_output=$5
without_chimeric_output=$6
lib_no_chimerica_seq=$7
perl $exe_path/src/remove_chimeric.pl -c $chimeric_threshold -i $input -d $db -o $chimeric_output >$without_chimeric_output
if [ -s "$without_chimeric_output" ]; then
    perl $exe_path/src/get_reads_first_round.pl -i $without_chimeric_output -d $db -o $lib_no_chimerica_seq
fi