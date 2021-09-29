#!/bin/bash
#$ -V
#$ -N aiv_seeker-debleeding
#$ -cwd
#$ -l h_vmem=8G

exe_path=$1
dir_combined_seq=$2
source=$3
cluster_identity=$4
dir_debled=$5
overlap_level=$6
threads=$7

dir_debled_step1_vsearch_out=$dir_debled/1.step_vsearch_out
dir_debled_step2_otu=$dir_debled/2.step_otu
dir_debled_step3_otu_processed=$dir_debled/3.step_otu_processed
dir_debled_step4_cross=$dir_debled/4.step_cross_detection
dir_debled_step5_cross_removed=$dir_debled/5.step_cross_removed
dir_debled_step6_reads_list=$dir_debled/6.step_reads_list
debled_reads_ok=$dir_debled/7.debled_reads_ok

conda run -n aiv_seeker-vsearch vsearch --threads $threads --cluster_size $dir_combined_seq/$source\_debled_step1.fa --id $cluster_identity --target_cov $overlap_level --centroids $dir_debled_step1_vsearch_out/$source\_centroids.fa --uc $dir_debled_step1_vsearch_out/$source\_reads_cluster.uc --strand both --sizeout
perl $exe_path/src/parse_uc_to_otu.pl -i $dir_debled_step1_vsearch_out/$source\_reads_cluster.uc -m $dir_debled_step2_otu/$source\_otu.txt -n $dir_debled_step2_otu/$source\_otu_name.txt -x $dir_debled_step2_otu/$source\_otu_orginal.txt
perl $exe_path/src/parse_otu.pl -i $dir_debled_step2_otu/$source\_otu_orginal.txt -m $dir_debled_step3_otu_processed/$source\_otu_uniq.txt -n $dir_debled_step3_otu_processed/$source\_otu_cross.txt
perl $exe_path/src/detect_cross_talk.pl -i $dir_debled_step3_otu_processed/$source\_otu_cross.txt -o $dir_debled_step4_cross/$source\_otu_cross_removed.txt -m $dir_debled_step4_cross/$source\_otu_cross_multiple_dominant.txt -n $dir_debled_step4_cross/$source\_otu_cross_single_dominant.txt
cat $dir_debled_step3_otu_processed/$source\_otu_uniq.txt $dir_debled_step4_cross/$source\_otu_cross_removed.txt >$dir_debled_step5_cross_removed/$source\_otu_processed.txt

perl $exe_path/src/get_debleeded_reads_list_x.pl -i $dir_debled_step5_cross_removed/$source\_otu_processed.txt -d $dir_debled_step2_otu/$source\_otu_name.txt -o ${dir_debled_step6_reads_list}/${source}\_reads_list_ok.txt
perl $exe_path/src/get_reads_first_round.pl -i $dir_debled_step6_reads_list/$source\_reads_list_ok.txt -d $dir_combined_seq/$source\_debled_step1.fa -o $dir_debled_step6_reads_list/$source\_reads_all_ok.fa
perl $exe_path/src/divide_fasta_into_lib.pl $dir_debled_step6_reads_list/$source\_reads_all_ok.fa $debled_reads_ok $source