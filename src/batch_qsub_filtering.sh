#!/bin/bash
#$ -V
#$ -N aiv_seeker-filtering
#$ -cwd
#$ -l h_vmem=8G


exe_path=$1
libname=$2
result_dir=$3
adaptor=$4
threads=$5


dir_raw=$result_dir/0.raw_fastq
dir_file_processed=$result_dir/3.file_processed
dir_fasta_processed=$result_dir/4.fasta_processed
	
perl $exe_path/src/convert_fastq_name.pl $dir_raw/$libname\_R1.fq $dir_raw/$libname\_N\_R1.fq      
perl $exe_path/src/convert_fastq_name.pl $dir_raw/$libname\_R2.fq $dir_raw/$libname\_N\_R2.fq
conda run -n aiv_seeker-trimmomatic trimmomatic PE -threads $threads -phred33 $dir_raw/$libname\_N\_R1.fq $dir_raw/$libname\_N\_R2.fq $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_S\_R1.fq $dir_file_processed/$libname\_P\_R2.fq  $dir_file_processed/$libname\_S\_R2.fq  ILLUMINACLIP\:$adaptor\:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20  MINLEN:60

if [ -z "$6" ]
  then
    cat $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_P\_R2.fq $dir_file_processed/$libname\_S\_R1.fq $dir_file_processed/$libname\_S\_R2.fq >$dir_file_processed/$libname\_combine.fastq
else
	cat $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_P\_R2.fq >$dir_file_processed/$libname\_combine.fastq
fi

conda run -n aiv_seeker-fastx_toolkit fastq_to_fasta -Q 33 -i $dir_file_processed/$libname\_combine.fastq -o $dir_fasta_processed/$libname\_raw.fasta
