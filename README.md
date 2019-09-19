# AIV_seeker
## AIV_seeker is optimized for detecting and identification of Avian Influenza Virus from metagenomics data.

```
Usage: perl AIV_seeker.pl -i run_folder -o result_folder
         -i     path for NGS fastq file directory
         -o     result folder
         -s     step number
                        step 1: Generate the fastq file list
                        step 2: Generate QC report
                        step 3: Quality filtering and merging
                        step 4: First search by Diamond
                        step 5: Cluster reads
                        step 6: Second search by BLAST
                        step 7: Remove chimeric sequences
                        step 8: cross-contamination detection
                        step 9: Detect subtype
                        step 10: Generate report
         -f     run the current step and following steps (default false), no parameter
         -b     BSR score (default 0.4)
         -m     margin of BSR score (default 0.3)
         -p     percentage of concordant subtype (default 0.9)
         -t     number of threads
         -h     display help message
         -l overlap level (default 0.7)
         -x threshold for identity (default 90%)
         -z threshold for chimeric check (default 90%)
         -c identity for clustering when dealing with cross-talking (default 0.97)

```

<img src="https://github.com/duanjunhyq/AIV_seeker/blob/master/img/subtype.jpg">
