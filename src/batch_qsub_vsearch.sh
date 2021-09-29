#!/bin/bash
#$ -V
#$ -N aiv_seeker-vsearch
#$ -cwd
#$ -l h_vmem=8G


exe_path=$1
aiv_reads=$2
libname=$3

input=$aiv_reads/$libname\_first_round.fa


output_derep_seq=$aiv_reads/$libname\_reads_derep.fa
output_derep_uc=$aiv_reads/$libname\_vsearch-derep.uc
output_derep_seq_with_tag=$aiv_reads/$libname\_reads_derep_with_tag.fa

conda run -n aiv_seeker-vsearch vsearch --derep_fulllength $input --output $output_derep_seq --sizeout --uc $output_derep_uc
perl $exe_path/src/add_tag_to_seq.pl $output_derep_seq $output_derep_seq_with_tag $libname
