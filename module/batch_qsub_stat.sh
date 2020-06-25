#!/bin/bash
#$ -V
#$ -N flu_stat
#$ -cwd
#$ -pe smp 20
#$ -l h_vmem=8G


exe_path=$1
libname=$2
result_dir=$3



dir_raw=$result_dir/0.raw_fastq
dir_file_processed=$result_dir/3.file_processed
dir_fasta_processed=$result_dir/4.fasta_processed
	
perl $exe_path/module/sum_fastq_file.pl -i $dir_raw/$libname\_N\_R1.fq >>$result_dir/tmp/$libname\_fastq_sequence_sum.txt
perl $exe_path/module/sum_fastq_file.pl -i $dir_raw/$libname\_N\_R2.fq >>$result_dir/tmp/$libname\_fastq_sequence_sum.txt
perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_P\_R1.fq >>$result_dir/tmp/$libname\_fastq_sequence_sum.txt
perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_P\_R2.fq >>$result_dir/tmp/$libname\_fastq_sequence_sum.txt
perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_S\_R1.fq >>$result_dir/tmp/$libname\_fastq_sequence_sum.txt
perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_S\_R2.fq >>$result_dir/tmp/$libname\_fastq_sequence_sum.txt
perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_combine.fastq >>$result_dir/tmp/$libname\_fastq_sequence_sum.txt