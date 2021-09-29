#!/bin/bash
#$ -V
#$ -N aiv_seeker-debled-subtype
#$ -cwd
#$ -pe smp 2
#$ -l h_vmem=8G


exe_path=$1
result_dir=$2
libname=$3
cluster_identity=$4
margin=$5
BSR=$6
percent=$7
flu_ref_gene_relation=$8
source=$9
overlap_level=${10}

blast_dir=$result_dir/7.blast
blast_dir_vs_db=$blast_dir/1.blast_to_db
blast_dir_self=$blast_dir/2.blast_to_self
dir_debled=$result_dir/10.debled\_$overlap_level\_$cluster_identity
cluster_subtype=$dir_debled/8.subtype_debled
cluster_subtype_step1_blast_sorted=$cluster_subtype/1.step_blast_sorted
cluster_subtype_step2_subtype=$cluster_subtype/2.step_subtype_file
cluster_subtype_step3_seq=$cluster_subtype/3.step_subtype_seq

debled_reads_ok=$result_dir/10.debled\_$overlap_level\_$cluster_identity/7.debled_reads_ok

perl $exe_path/src/parse_m8_BSR.pl -i $blast_dir_vs_db/$libname\_blastout.m8 -s $blast_dir_self/$libname\_self.m8 -d $flu_ref_gene_relation -o $cluster_subtype_step1_blast_sorted/$libname\_sorted.txt -m $debled_reads_ok/$source/$libname\_reads_ok.fa

if [ -s ${cluster_subtype_step1_blast_sorted}/${libname}\_sorted.txt ]; then
	perl $exe_path/src/assign_subtype_v2.pl -i $cluster_subtype_step1_blast_sorted/$libname\_sorted.txt -o $cluster_subtype_step2_subtype/$libname\_subtype.txt -u $cluster_subtype_step2_subtype/$libname\_unclassified.txt -m $margin -b $BSR -p $percent
	perl $exe_path/src/sum_subtype_depricated.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -o $cluster_subtype_step2_subtype/$libname\_summary_depricated.txt
	perl $exe_path/src/sum_subtype_uniq.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -o $cluster_subtype_step2_subtype/$libname\_summary_uniq.txt
	perl $exe_path/src/getseq_subtype.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -d $debled_reads_ok/$source/$libname\_reads_ok.fa -o $cluster_subtype_step3_seq/$source
fi