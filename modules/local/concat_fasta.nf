// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process CONCAT_FASTA {
    echo true
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    input:
    path fasta


    output:
    path 'result/combine.fasta', emit: fasta_out
   
    script:
    def software = getSoftwareName(task.process)

    """
    mkdir result
    cat *.fa >result/combine.fasta

    """
}
