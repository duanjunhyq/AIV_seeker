#!/bin/bash
#$ -V
#$ -N flu_vsearch_derep
#$ -cwd
#$ -pe smp 32
#$ -l h_vmem=8G


exe_path=$1
vsearch=$2
aiv_reads=$3
libname=$4

input=$aiv_reads/$libname\_first_round.fa


output_derep_seq=$aiv_reads/$libname\_reads_derep.fa
output_derep_uc=$aiv_reads/$libname\_vsearch-derep.uc
output_derep_seq_with_tag=$aiv_reads/$libname\_reads_derep_with_tag.fa

$vsearch --derep_fulllength $input --output $output_derep_seq --sizeout --uc $output_derep_uc
perl $exe_path/module/add_tag_to_seq.pl $output_derep_seq $output_derep_seq_with_tag $libname
