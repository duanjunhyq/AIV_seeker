#!/usr/bin/env bash

IFS=',' read -ra ADDR <<< "$1"
for i in "${ADDR[@]}"; do
    file=$i
    sampleName=$(echo $file | awk -F\_ '{print $1}')
    if [[ $file == *\_1.fail.fastq.gz ]]; then
    	gunzip -c $file >${sampleName}_unpaired_R1.fastq
    elif [[ $file == *\_2.fail.fastq.gz ]]; then
        gunzip -c "$file" >${sampleName}_unpaired_R2.fastq
    elif [[ $file == *_merged_and_unmerged.fastq ]]; then
        pass
    else
      	echo "Please qcheck your file name to make sure it is ended with *_[1|2].fail.fastq.gz or *_merged_unmerged_combine.fq]"
    fi
done
