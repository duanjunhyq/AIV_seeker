// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process ASSIGN_SUBTYPE {
    echo true
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "pandas=1.0.5" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.0.5' :
        'quay.io/biocontainers/pandas:1.0.5' }"


    input:
    tuple val(meta), path(bsrFile)

    output:
    tuple val(meta), path('*_subtype_pass.csv'), emit: pass
    tuple val(meta), path('*_subtype_fail.csv'), emit: fail
   
    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    assign_subtype.py -i $bsrFile -o ${prefix}_subtype_pass.csv -u ${prefix}_subtype_fail.csv
   
    """
}
