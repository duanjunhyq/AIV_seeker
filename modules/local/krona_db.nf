// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options    = initOptions(params.options)

process KRONA_DB {

    conda (params.enable_conda ? "bioconda::krona=2.7.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/krona:2.7.1--pl526_5"
    } else {
        container "quay.io/biocontainers/krona:2.7.1--pl526_5"
    }

    output:
    path("taxonomy/taxonomy.tab"), emit: db
    path '*.version.yml'         , emit: version

    script:
    def software = getSoftwareName(task.process)
    """
    ktUpdateTaxonomy.sh taxonomy
    echo \$(ktImportTaxonomy 2>&1) | sed 's/^.*KronaTools //; s/ - ktImportTaxonomy.*//' > ${software}.version.yml
    """
}