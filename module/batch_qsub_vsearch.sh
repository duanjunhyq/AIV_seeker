#!/bin/bash
#$ -V
#$ -N flu_vsearch_derep
#$ -cwd
#$ -pe smp 32
#$ -l h_vmem=8G


exe_path=$1
input=$2
output_derep_seq=$3
output_derep_uc=$4
output_derep_seq_with_tag=$5
libname=$6
vsearch --derep_fulllength $input --output $output_derep_seq --sizeout --uc $output_derep_uc
perl $exe_path/module/add_tag_to_seq.pl $output_derep_seq $output_derep_seq_with_tag $libname
