░█████╗░██╗██╗░░░██╗░██████╗███████╗███████╗██╗░░██╗███████╗██████╗░
██╔══██╗██║██║░░░██║██╔════╝██╔════╝██╔════╝██║░██╔╝██╔════╝██╔══██╗
███████║██║╚██╗░██╔╝╚█████╗░█████╗░░█████╗░░█████═╝░█████╗░░██████╔╝
██╔══██║██║░╚████╔╝░░╚═══██╗██╔══╝░░██╔══╝░░██╔═██╗░██╔══╝░░██╔══██╗
██║░░██║██║░░╚██╔╝░░██████╔╝███████╗███████╗██║░╚██╗███████╗██║░░██║
╚═╝░░╚═╝╚═╝░░░╚═╝░░░╚═════╝░╚══════╝╚══════╝╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝ 

## AIV_seeker is optimized for detecting and identification of Avian Influenza Virus from metagenomics data.

### Introduction

The application of next generation sequencing (NGS) in infectious disease surveillance and outbreak investigations has become a promising area. Environmental sampling provides a method to collect and identify potentially dangerous pathogens that are circulating in an animal population, however detection of a low-abundance pathogen target in a large metagenomic background is still a challenge. AIV_seeker pipeline that is optimized for detecting and identifying low-abundance avian influenza virus (AIV) from metagenomic NGS data. 

Features
*  AIV_seeker can be used to automatically process metagenomics NGS data and generate subtyping results.
*  A heatmap is generated to visualize the results.
*  An experimental method is incorporated to deal with index-hopping issue resulted from Illumina platfrom
*  The results can be used to generate phylogenetic tree through our another pipeline AIV_tree
*  Web based service has been developed for Galaxy and IRIDA (http://206.12.95.227/). 


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

If there is anything wrong with the environment, you can uninstall environment:

```
$ bash uninstall_envs.sh
```

### How to use

Mount conda environement

```
$ source activate aiv_seeker
```

Test if AIV_sekeer is installed correctly. You can type aiv_seeker.pl in any directory.

```
$ aiv_seeker.pl
```

Then it will promot like this:

```

AIV_seeker: A pipeline for detecting avian influenza virus from NGS metagenomics Data

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


Once you put all your NGS raw data in a folder, you can run the pipeline like this

```
$ aiv_seeker.pl -i your_input_folder -o your_output_folder
```

If you are using Sun Grid Engine scheduler, you can add "-a" to let it run by cluster, and add "-t" to designate how many threads you want to use like this

```
$ aiv_seeker.pl -i your_input_folder -o your_output_folder -a -t 20
```

The default is not to keep intermediate files. If you want to keep intermediate files, you can add "-u"

```
$ aiv_seeker.pl -i your_input_folder -o your_output_folder -t 20 -u
```

The default is not to run debleeding step. You can add "-w" to get debleeding results

```
$ aiv_seeker.pl -i your_input_folder -o your_output_folder -t 20 -w
```

If you want to run some specific step, you can run it like this:

```
$ aiv_seeker.pl -i your_input_folder -o your_output_folder -t 20 -s 1 -f
```


### How to find results


<img src="https://github.com/duanjunhyq/AIV_seeker/blob/master/img/subtype.jpg">
