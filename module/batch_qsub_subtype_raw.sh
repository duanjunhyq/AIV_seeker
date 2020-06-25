#!/bin/bash
#$ -V
#$ -N flu_subtype_raw
#$ -cwd
#$ -pe smp 5
#$ -l h_vmem=8G


exe_path=$1
result_dir=$2
libname=$3
margin=$4
BSR=$5
percent=$6
blast_db_ano=$7
source1=$8


     

blast_dir=$result_dir/7.blast
blast_dir_vs_db=$blast_dir/1.blast_to_db
blast_dir_self=$blast_dir/2.blast_to_self
cluster_subtype=$result_dir/9.subtype_raw
dir_chimeric_seq=$result_dir/8.check_chimeric/2.de_chimeric_seq

cluster_subtype_step1_blast_sorted=$cluster_subtype/1.step_blast_sorted
cluster_subtype_step2_subtype=$cluster_subtype/2.step_subtype_file
cluster_subtype_step3_seq=$cluster_subtype/3.step_subtype_seq

perl $exe_path/module/parse_m8_BSR.pl -i $blast_dir_vs_db/$libname\_blastout.m8 -s $blast_dir_self/$libname\_self.m8 -d $blast_db_ano -o $cluster_subtype_step1_blast_sorted/$libname\_sorted.txt -m $dir_chimeric_seq/$libname\_no_chimeric.fa

if [ -s ${cluster_subtype_step1_blast_sorted}/${libname}\_sorted.txt ]; then
	perl $exe_path/module/assign_subtype_v2.pl -i $cluster_subtype_step1_blast_sorted/$libname\_sorted.txt -o $cluster_subtype_step2_subtype/$libname\_subtype.txt -u $cluster_subtype_step2_subtype/$libname\_unclassified.txt -m $margin -b $BSR -p $percent
	perl $exe_path/module/sum_subtype_depricated.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -o $cluster_subtype_step2_subtype/$libname\_summary_depricated.txt
	perl $exe_path/module/getseq_subtype.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -d $dir_chimeric_seq/$libname\_no_chimeric.fa -o $cluster_subtype_step3_seq/$source1
fi