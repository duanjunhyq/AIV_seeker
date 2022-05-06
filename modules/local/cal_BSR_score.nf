// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process CAL_BSR_SCORE {
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
    tuple val(meta), path(align_ref), path(align_self), path(align_all), path(metadata)

    output:
    tuple val(meta), path('*_BSR.txt'), emit: txt
   
    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    cal_BSR_score.py -i $align_ref -d $metadata -s $align_self -a $align_all -o ${prefix}_BSR.txt
   
    """
}
