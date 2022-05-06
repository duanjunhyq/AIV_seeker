//
// DEBLEEDING to remove potential wrong assigned reads
//

params.vsearch_vsearch_options       = [:]
params.debleeding_options       = [:]

include { CONCAT_FASTA                                   } from '../../modules/local/concat_fasta'
include { VSEARCH                                        } from '../../modules/local/vsearch/vsearch' addParams( options: params.vsearch_vsearch_options)
include { RUN_DEBLEEDING                                        } from '../../modules/local/run_debleeding' addParams( options: params.debleeding_options)



workflow DEBLEEDING {
    take:
    fasta // channel: [ fasta sequences] ]

    main:

    //
    // Use vsearch to group sequences
    //
    CONCAT_FASTA(fasta)
    VSEARCH(CONCAT_FASTA.out.fasta_out)
    RUN_DEBLEEDING(VSEARCH.out.uc)

    emit:
    pass_ids = RUN_DEBLEEDING.out.pass

}