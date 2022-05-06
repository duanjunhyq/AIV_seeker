// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process FQ_TO_FA {
    echo true
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    input:
    tuple val(meta), path(reads)


    output:
    tuple val(meta), path('*_merged.fa'), emit: merged_fasta
   
    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def len = reads.size()
    def readList = reads.collect{ it.toString() }
    def fileList = readList.join(",")
    """
    bash fq_to_fa.sh $fileList
    cat *.fasta >${prefix}_merged.fa
    """
}
