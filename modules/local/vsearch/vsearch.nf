// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from '../functions'

params.options = [:]
options    = initOptions(params.options)

process VSEARCH {
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
    path fasta

    output:
    path "centroids.fa", emit: fasta
    path "cluster.uc" , emit: uc
    path  '*.version.yml'                                , emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    vsearch --cluster_size $fasta \
            --centroids centroids.fa  \
            --uc cluster.uc \
            --threads $task.cpus \
            --strand both \
            --id 0.97 \
            --target_cov 0.7


    cat <<-END_VERSIONS > ${software}.version.yml
    "${task.process}":
        vsearch: \$(vsearch --version 2>&1 | head -n 1|cut -d'_' -f1|cut -d' ' -f2)
    END_VERSIONS

    """
}