#!/bin/bash

CONDA_ENV_MAIN=aiv_seeker
CONDA_ENV_DIAMOND=aiv_seeker-diamond
CONDA_ENV_BLAST=aiv_seeker-blast
CONDA_ENV_FASTQC=aiv_seeker-fastqc
CONDA_ENV_MULTIQC=aiv_seeker-multiqc
CONDA_ENV_TRIMMOMATIC=aiv_seeker-trimmomatic
CONDA_ENV_VSEARCH=aiv_seeker-vsearch
CONDA_ENV_FASTX_TOOLKIT=aiv_seeker-fastx_toolkit

conda env remove -n ${CONDA_ENV_MAIN} -y
conda env remove -n ${CONDA_ENV_DIAMOND} -y
conda env remove -n ${CONDA_ENV_BLAST} -y
conda env remove -n ${CONDA_ENV_FASTQC} -y
conda env remove -n ${CONDA_ENV_MULTIQC} -y
conda env remove -n ${CONDA_ENV_TRIMMOMATIC} -y
conda env remove -n ${CONDA_ENV_VSEARCH} -y
conda env remove -n ${CONDA_ENV_FASTX_TOOLKIT} -y