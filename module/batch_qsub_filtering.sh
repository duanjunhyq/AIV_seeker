#!/bin/bash
#$ -V
#$ -N flu_filtering
#$ -cwd
#$ -pe smp 20
#$ -l h_vmem=8G


exe_path=$1
libname=$2
result_dir=$3
trimmomatic=$4
fastq_to_fasta=$5
adaptor=$6
threads=$7


dir_raw=$result_dir/0.raw_fastq
dir_file_processed=$result_dir/3.file_processed
dir_fasta_processed=$result_dir/4.fasta_processed
	
perl $exe_path/module/convert_fastq_name.pl $dir_raw/$libname\_R1.fq $dir_raw/$libname\_N\_R1.fq      
perl $exe_path/module/convert_fastq_name.pl $dir_raw/$libname\_R2.fq $dir_raw/$libname\_N\_R2.fq
$trimmomatic PE -threads $threads -phred33 $dir_raw/$libname\_N\_R1.fq $dir_raw/$libname\_N\_R2.fq $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_S\_R1.fq $dir_file_processed/$libname\_P\_R2.fq  $dir_file_processed/$libname\_S\_R2.fq  ILLUMINACLIP\:$adaptor\:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20  MINLEN:60
cat $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_P\_R2.fq $dir_file_processed/$libname\_S\_R1.fq $dir_file_processed/$libname\_S\_R2.fq >$dir_file_processed/$libname\_combine.fastq
$fastq_to_fasta -Q 33 -i $dir_file_processed/$libname\_combine.fastq -o $dir_fasta_processed/$libname\_raw.fasta
