// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process SUM_HEATMAP {
    echo true
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "pandas=1.0.5" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-d14219255233ee6cacc427e28a7caf8ee42e8c91:0a22c7568e4a509925048454dad9ab37fa8fe776-0' :
        'quay.io/biocontainers/mulled-v2-d14219255233ee6cacc427e28a7caf8ee42e8c91:0a22c7568e4a509925048454dad9ab37fa8fe776-0' }"


    input:
    path(input)

    output:
    path('*_subtype.pdf'), emit: table
   
    script:
    def software = getSoftwareName(task.process)

    """
    subtype_to_heatmap.py -i ${input} -o summary
    
    """
}
