// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process SUM_TABLE {
    echo true
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "pandas=1.0.5" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.0.5' :
        'quay.io/biocontainers/pandas:1.0.5' }"


    input:
    path(subtype_file)

    output:
    path('*_subtype.csv'), emit: table
   
    script:
    def software = getSoftwareName(task.process)


    """
    mkdir input_dir
    mv *.csv input_dir
    report_subtype.py -i input_dir -o summary 
    
    """
}
