#!/bin/bash
set -e  # Stop on error

SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
. ${SCRIPT_DIR}/requirements/requirements.txt
echo $blast
CONFIG_FILE="${SCRIPT_DIR}/config.ini"

CONDA_ENV_MAIN=aiv_seeker
CONDA_ENV_BLAST=aiv_seeker-blast
CONDA_ENV_DIAMOND=aiv_seeker-diamond
CONDA_ENV_FASTQC=aiv_seeker-fastqc
CONDA_ENV_MULTIQC=aiv_seeker-multiqc
CONDA_ENV_TRIMMOMATIC=aiv_seeker-trimmomatic
CONDA_ENV_VSEARCH=aiv_seeker-vsearch
CONDA_ENV_FASTX_TOOLKIT=aiv_seeker-fastx_toolkit

echo "=== Checking conda version ==="
conda --version

echo "=== Installing pipeline's Conda environments ==="

if [[ "$1" == mamba ]]; then
  conda install mamba -y -c conda-forge
  mamba create -n ${CONDA_ENV_blast} --file ${REQ_BLAST} -y -c defaults -c r -c bioconda -c conda-forge
  mamba create -n ${CONDA_ENV_BLAST} -y -c defaults -c bioconda -c conda-forge blast=$blast
  mamba create -n ${CONDA_ENV_DIAMOND} -y -c defaults -c bioconda -c conda-forge diamond=$diamond
  mamba create -n ${CONDA_ENV_FASTQC} -y -c defaults -c bioconda -c conda-forge fastqc=$fastqc
  mamba create -n ${CONDA_ENV_MULTIQC} -y -c defaults -c bioconda -c conda-forge multiqc=$multiqc
  mamba create -n ${CONDA_ENV_TRIMMOMATIC} -y -c defaults -c bioconda -c conda-forge trimmomatic=$trimmomatic
  mamba create -n ${CONDA_ENV_VSEARCH} -y -c defaults -c bioconda -c conda-forge vsearch=$vsearch
  mamba create -n ${CONDA_ENV_FASTX_TOOLKIT} -y -c defaults -c bioconda -c conda-forge fastx_toolkit=$fastx_toolkit
  mamba create -n ${CONDA_ENV_MAIN} -y -c defaults -c bioconda -c conda-forge perl=$perl python=$python seaborn=$seaborn
else
  echo
  echo "If it takes too long to resolve conflicts, then try with mamba."
  echo
  echo "Usage: ./install_conda_env.sh mamba"
  echo
  echo "mamba will resolve conflicts much faster then the original conda."
  echo "If you get another conflict in the mamba installation step itself "
  echo "Then you may need to clean-install miniconda3 and re-login."
  echo
  conda create -n ${CONDA_ENV_BLAST} -y -c defaults -c bioconda -c conda-forge blast=$blast
  conda create -n ${CONDA_ENV_DIAMOND} -y -c defaults -c bioconda -c conda-forge diamond=$diamond
  conda create -n ${CONDA_ENV_FASTQC} -y -c defaults -c bioconda -c conda-forge fastqc=$fastqc
  conda create -n ${CONDA_ENV_MULTIQC} -y -c defaults -c bioconda -c conda-forge multiqc=$multiqc
  conda create -n ${CONDA_ENV_TRIMMOMATIC} -y -c defaults -c bioconda -c conda-forge trimmomatic=$trimmomatic
  conda create -n ${CONDA_ENV_VSEARCH} -y -c defaults -c bioconda -c conda-forge vsearch=$vsearch
  conda create -n ${CONDA_ENV_FASTX_TOOLKIT} -y -c defaults -c bioconda -c conda-forge fastx_toolkit=$fastx_toolkit
  conda create -n ${CONDA_ENV_MAIN} -y -c defaults -c bioconda -c conda-forge perl=$perl python=$python seaborn=$seaborn
fi


echo "=== Configuring for pipeline's Conda environments ==="
CONDA_PREFIX_BLAST=$(conda env list | grep -E "\b${CONDA_ENV_BLAST}[[:space:]]" | awk '{if (NF==3) print $3; else print $2}')
CONDA_PREFIX_DIMAOND=$(conda env list | grep -E "\b${CONDA_ENV_DIAMOND}[[:space:]]" | awk '{if (NF==3) print $3; else print $2}')
CONDA_PREFIX_FASTQC=$(conda env list | grep -E "\b${CONDA_ENV_FASTQC}[[:space:]]" | awk '{if (NF==3) print $3; else print $2}')
CONDA_PREFIX_MULTIQC=$(conda env list | grep -E "\b${CONDA_ENV_MULTIQC}[[:space:]]" | awk '{if (NF==3) print $3; else print $2}')
CONDA_PREFIX_TRIMMOMATIC=$(conda env list | grep -E "\b${CONDA_ENV_TRIMMOMATIC}[[:space:]]" | awk '{if (NF==3) print $3; else print $2}')
CONDA_PREFIX_VSEARCH=$(conda env list | grep -E "\b${CONDA_ENV_VSEARCH}[[:space:]]" | awk '{if (NF==3) print $3; else print $2}')
CONDA_PREFIX_FASTX_TOOLKIT=$(conda env list | grep -E "\b${CONDA_ENV_FASTX_TOOLKIT}[[:space:]]" | awk '{if (NF==3) print $3; else print $2}')
CONDA_PREFIX_MAIN=$(conda env list | grep -E "\b${CONDA_ENV_MAIN}[[:space:]]" | awk '{if (NF==3) print $3; else print $2}')

if [ ! "${CONDA_PREFIX_BLAST}" -o ! "${CONDA_PREFIX_DIMAOND}" -o ! "${CONDA_PREFIX_FASTQC}" -o ! "${CONDA_PREFIX_MULTIQC}" -o ! "${CONDA_PREFIX_TRIMMOMATIC}" -o ! "${CONDA_PREFIX_VSEARCH}" -o ! "${CONDA_PREFIX_FASTX_TOOLKIT}"  -o ! "${CONDA_PREFIX_MAIN}" ];
then
	echo "Error: Pipeline's Conda environments not found."
	echo "Try to reinstall pipeline's Conda environments."
	echo
	echo "1) $ bash uninstall_conda_env.sh"
	echo "2) $ bash install_conda_env.sh"
	exit 1
fi


# make activate.d to init pipeline's Conda envs
CONDA_LIB="${CONDA_PREFIX_MAIN}/lib"
CONDA_BIN="${CONDA_PREFIX_MAIN}/bin"
CONDA_ACTIVATE_D="${CONDA_PREFIX_MAIN}/etc/conda/activate.d"
CONDA_DEACTIVATE_D="${CONDA_PREFIX_MAIN}/etc/conda/deactivate.d"
CONDA_ACTIVATE_SH="${CONDA_ACTIVATE_D}/env_vars.sh"
CONDA_DEACTIVATE_SH="${CONDA_DEACTIVATE_D}/env_vars.sh"
mkdir -p ${CONDA_ACTIVATE_D}
mkdir -p ${CONDA_DEACTIVATE_D}
touch ${CONDA_ACTIVATE_SH}
touch ${CONDA_DEACTIVATE_SH}

#format diamond db

conda run -n aiv_seeker-diamond diamond makedb --in ${SCRIPT_DIR}/database/avian_pep_db.fas -d ${SCRIPT_DIR}/database/avian_pep_db
conda run -n aiv_seeker-blast makeblastdb -in ${SCRIPT_DIR}/database/avian_flu_gene.0.99.fas  -dbtype nucl -out ${SCRIPT_DIR}/database/aiv_gene_0.99

# chmod u+rx ${SCRIPT_DIR}/*.pl
# chmod u+rx $SCRIPT_DIR/module/*.pl
# chmod u+rx $SCRIPT_DIR/module/*.py
# chmod u+rx $SCRIPT_DIR/module/*.sh

echo "export PATH=${SCRIPT_DIR}:\$PATH" > ${CONDA_ACTIVATE_SH}
echo "export QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb" >> ${CONDA_ACTIVATE_SH}

echo "=== All done successfully ==="

