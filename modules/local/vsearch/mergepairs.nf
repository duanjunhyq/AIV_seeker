// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from '../functions'

params.options = [:]
options    = initOptions(params.options)

process MERGEPAIRS {
    tag "${meta.id}"
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::vsearch=2.21.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/vsearch:2.21.1--h95f258a_0"
    } else {
        container "quay.io/biocontainers/vsearch:2.21.1--h95f258a_0"
    }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("trim_reads_merged_and_unmerged.fastq"), emit: merged_unmerged_combine
    path  "*_merge_stat.txt"                            , emit: merge_stat
    path  '*.version.yml'                                 , emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    vsearch --fastq_mergepairs ${reads[0]} \
        --reverse ${reads[1]} \
        --threads $task.cpus \
        --fastq_minmergelen 60 \
        --fastq_allowmergestagger \
        --fastq_maxdiffs 10 \
        --fastq_minovlen 10 \
        --fastqout merge.fastq \
        --fastqout_notmerged_fwd unmerged_F.fastq \
        --fastqout_notmerged_rev unmerged_R.fastq \
        --log log.txt \
        2>${meta.id}_merge_stat.txt
    cat merge.fastq unmerged_F.fastq unmerged_R.fastq > trim_reads_merged_and_unmerged.fastq
    cat <<-END_VERSIONS > ${software}.version.yml
    "${task.process}":
        vsearch: \$(vsearch --version 2>&1 | head -n 1|cut -d'_' -f1|cut -d' ' -f2)
    END_VERSIONS

    """
}