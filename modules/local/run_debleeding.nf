// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process RUN_DEBLEEDING {
    echo true
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
    path uc_file

    output:
    path "seqids_pass.txt",  emit: pass
    path "result_fail.txt",  emit: fail_table
    path "result_pass.txt",  emit: pass_table


    script:
    def software = getSoftwareName(task.process)


    """
    prepare_otu_table.py -i $uc_file -o otu_table.tsv -n name_list.txt
    debleeding.py -i otu_table.tsv -o result_pass.txt -u result_fail.txt 
    get_seqid_after_debleeding.py -i result_pass.txt -d name_list.txt -o seqids_pass.txt
   
    """
}
