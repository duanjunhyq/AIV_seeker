// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process CHIMERA_CHECK {
    echo true
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "python=3.8" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8' :
        'quay.io/biocontainers/python:3.8' }"


    input:
    tuple val(meta), path(blastout)



    output:
    tuple val(meta), path('*_without_chimeras.txt'), emit: txt
   
    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def args = options.args ?: ''

    """
    chimera_check.py -i $blastout \
        -o ${prefix}_without_chimeras.txt \
        -c $params.chimera_cutoff 

    """
}
