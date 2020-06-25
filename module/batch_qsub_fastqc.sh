#!/bin/bash
#$ -V
#$ -N flu_fastqc
#$ -cwd
#$ -pe smp 20
#$ -l h_vmem=8G


input1=$1
input2=$2
result_dir=$3
libname=$4
threads=$5

dir_raw=$result_dir/0.raw_fastq
dir_QC=$result_dir/1.QC_report

gunzip -c $input1 >$dir_raw/$libname\_R1.fq
gunzip -c $input2 >$dir_raw/$libname\_R2.fq
fastqc -t $threads $dir_raw/$libname\_R1.fq -o $dir_QC
fastqc -t $threads $dir_raw/$libname\_R2.fq -o $dir_QC