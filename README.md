░█████╗░██╗██╗░░░██╗░██████╗███████╗███████╗██╗░░██╗███████╗██████╗░
██╔══██╗██║██║░░░██║██╔════╝██╔════╝██╔════╝██║░██╔╝██╔════╝██╔══██╗
███████║██║╚██╗░██╔╝╚█████╗░█████╗░░█████╗░░█████═╝░█████╗░░██████╔╝
██╔══██║██║░╚████╔╝░░╚═══██╗██╔══╝░░██╔══╝░░██╔═██╗░██╔══╝░░██╔══██╗
██║░░██║██║░░╚██╔╝░░██████╔╝███████╗███████╗██║░╚██╗███████╗██║░░██║
╚═╝░░╚═╝╚═╝░░░╚═╝░░░╚═════╝░╚══════╝╚══════╝╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝ 

## AIV_seeker is optimized for detecting and identification of Avian Influenza Virus from metagenomics data.


### How to install


Download the code from GitHub

```
$ git clone https://github.com/duanjunhyq/AIV_seeker.git
```

Install environments 

```
$ cd AIV_seeker
$ bash install_envs.sh
```

Tips: If it takes too long to resolve Conda package conflicts, then try with mamba to install environments.

```
$ bash install_envs.sh
```
### Activate conda environment 

```
source activate aiv_seeker

```


### Usage

```

AIV_Seeker: A pipeline for detecting avian influenza virus from NGS metagenomics Data

Usage: aiv_seeker.pl -i run_folder -o result_folder
         -i path for NGS fastq file directory
         -o result folder
         -s step number
            step 1: Generate the fastq file list
            step 2: Generate QC report
            step 3: Quality filtering
            step 4: First round search by Diamond
            step 5: Group reads to remove duplicates
            step 6: Second round search by BLAST
            step 7: Remove chimeric sequences
            step 8: Assign subtypes and generate report
            step 9: cross-contamination detection and generate report
         -f only run the designated step (defined by -s, default false), no parameter
         -b BSR score (default 0.4)
         -m margin of BSR score (default 0.3)
         -p percentage of concordant subtype (default 0.9)
         -t number of threads (default 2)
         -h display help message
         -l overlap level (default 0.7)
         -x threshold for identity (default 90%)
         -z threshold for chimeric check (default 75%)
         -c identity for clustering when dealing with cross-talking (default 0.97)
         -a run by cluster (default false)
         -g run galaxy job (default false)
         -w run debleeding process
         -k generate results based on paired reads only (remove unpaired reads)
         -u keep the intermediate files (default remove)

```

<img src="https://github.com/duanjunhyq/AIV_seeker/blob/master/img/subtype.jpg">
