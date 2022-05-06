// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process REMOVE_BLEEDING_IDS {
    echo true
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "pandas=1.0.5" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/pandas:1.0.5"
    } else {
        container "quay.io/biocontainers/pandas:1.0.5"
    }

    input:
    tuple val(meta), path(subtype_tsv_file)

    path pass_ids

    output:
    path('*_subtype_pass_filtered.csv'),  emit: subtype_file
    

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"


    """
    remove_bleeding_ids.py -i $subtype_tsv_file -d $pass_ids -o $prefix\_subtype_pass_filtered.csv
   
    """
}
