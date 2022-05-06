// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from '../functions'

params.options = [:]
options    = initOptions(params.options)

process DEREP_FULLLENGTH {
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
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*_merge_filtered_depred.fa"), emit: fasta
    path  '*.version.yml'                                 , emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    vsearch --derep_fulllength $fasta \
            --output ${meta.id}_merge_filtered_depred.fa \
            --sizeout \
            --relabel ${meta.id}- \
            --uc ${meta.id}_vsearch_derep.uc



    cat <<-END_VERSIONS > ${software}.version.yml
    "${task.process}":
        vsearch: \$(vsearch --version 2>&1 | head -n 1|cut -d'_' -f1|cut -d' ' -f2)
    END_VERSIONS

    """
}