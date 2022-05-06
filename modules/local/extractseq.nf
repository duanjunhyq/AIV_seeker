// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process EXTRACTSEQ {
    echo true
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "biopython=1.76" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.76' :
        'quay.io/biocontainers/biopython:1.76' }"


    input:
    tuple val(meta), path(idList), path(fastaFile)

    output:
    tuple val(meta), path('*_out.fa'), emit: fasta
   
    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    extract_seq.py -i $idList -d $fastaFile -o ${prefix}_out.fa -p 1

    """
}
