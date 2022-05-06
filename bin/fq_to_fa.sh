#!/usr/bin/env bash

IFS=',' read -ra ADDR <<< "$1"
for i in "${ADDR[@]}"; do
    file=$i
    sampleName=$(echo $file | awk -F\_ '{print $1}')
    if [[ $file == *\_1.trim.fastq.gz ]]; then
    	 zcat $file|awk 'BEGIN{P=1;postfix="\/1"}{if(P==1){gsub(/^[@]/,">");print $1"/1"};if(P==2){print}; if(P==4)P=0; P++}' >${sampleName}_paired_R1.fasta
    elif [[ $file == *\_2.trim.fastq.gz ]]; then
    	 zcat $file|awk 'BEGIN{P=1;postfix="\/1"}{if(P==1){gsub(/^[@]/,">");print $1"/2"};if(P==2){print}; if(P==4)P=0; P++}' >${sampleName}_paired_R2.fasta
    elif [[ $file == *\_1.fail.fastq.gz ]]; then
    	 zcat $file|awk 'BEGIN{P=1;postfix="\/1"}{if(P==1){gsub(/^[@]/,">");print $1"/1"};if(P==2){print}; if(P==4)P=0; P++}' >${sampleName}_unpaired_R1.fasta
    elif [[ $file == *\_2.fail.fastq.gz ]]; then
    	 zcat $file|awk 'BEGIN{P=1;postfix="\/1"}{if(P==1){gsub(/^[@]/,">");print $1"/2"};if(P==2){print}; if(P==4)P=0; P++}' >${sampleName}_unpaired_R2.fasta
   	else
   		echo "Please check your file name to make sure it is ended with *_[1|2].trim.fastq.gz or *_[1|2].fail.fastq.gz"
    fi
done
