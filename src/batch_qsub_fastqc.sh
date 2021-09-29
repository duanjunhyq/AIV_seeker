#!/bin/bash
#$ -V
#$ -N aiv_seeker-fastqc
#$ -cwd
#$ -l h_vmem=8G


input1=$1
input2=$2
result_dir=$3
libname=$4
threads=$5

dir_raw=$result_dir/0.raw_fastq
dir_QC=$result_dir/1.QC_report


if [[ $input1 =~ \.fq$ ]];then
	ln -s $input1 $dir_raw/$libname\_R1.fq
	ln -s $input2 $dir_raw/$libname\_R2.fq
elif [[ $input1 =~ \.fastq$ ]];then
	ln -s $input1 $dir_raw/$libname\_R1.fq
	ln -s $input2 $dir_raw/$libname\_R2.fq
elif [[ $input1 =~ \.gz$ ]];then
	gunzip -c $input1 >$dir_raw/$libname\_R1.fq
	gunzip -c $input2 >$dir_raw/$libname\_R2.fq
elif [[ $input1 =~ \.dat$ ]];then
	ln -s $input1 $dir_raw/$libname\_R1.fq
	ln -s $input2 $dir_raw/$libname\_R2.fq
else
	echo "Please check your input files are ended with fq, fastq, dat, or gz"
fi

conda run -n aiv_seeker-fastqc fastqc -t $threads $dir_raw/$libname\_R1.fq -o $dir_QC
conda run -n aiv_seeker-fastqc fastqc -t $threads $dir_raw/$libname\_R2.fq -o $dir_QC