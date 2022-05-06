// include modules
include {printHelp              } from '../modules/local/help'
include {header                 } from '../modules/local/header'


if (params.help){
    log.info header()
    printHelp()
    exit 0
}


/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/
def modules = params.modules.clone()

params.diamond_pep_db = "$baseDir/assets/diamond_db/avian_pep_db.fas"
params.aiv_gene_db = "$baseDir/assets/blast_db/avian_flu_gene.0.99.fas"
params.aiv_gene_metadata = "$baseDir/assets/blast_db/avivan_flu_gene_metadata.csv"
params.chimera_cutoff = 0.75



include { INPUT_CHECK        }    from '../modules/local/input_check'               addParams( options: [:] )
include { GET_SOFTWARE_VERSIONS } from '../modules/local/get_software_versions'     addParams( options: [publish_files: ['tsv':'']])

/*


========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/
if (params.input)      { ch_input      = file(params.input)      } else { exit 1, 'Input samplesheet file not specified!' }
//
// MODULE: Installed directly from nf-core/modules
//
include { CAT_FASTQ                     } from '../modules/nf-core/modules/cat/fastq/main'                     addParams( options: modules['illumina_cat_fastq']                     )
include { FASTQC                        } from '../modules/nf-core/modules/fastqc/main'                        addParams( options: modules['illumina_cutadapt_fastqc']               )



//
// SUBWORKFLOW: Consisting entirely of nf-core/modules
//
def fastp_options = modules['illumina_fastp']
def diamond_blastx_options = modules['diamond_blastx']

if (params.save_trimmed_fail) { fastp_options.publish_files.put('fail.fastq.gz','seq/fail') }
if (params.save_trimmed_good) { fastp_options.publish_files.put('trim.fastq.gz','seq/trim') }
if (params.save_merged) { fastp_options.publish_files.put('merged.fastq.gz','seq/trim') }

def multiqc_options   = modules['illumina_multiqc']
multiqc_options.args += params.multiqc_title ? Utils.joinModuleArgs(["--title \"$params.multiqc_title\""]) : ''

def vsearch_vsearch_options = modules['vsearch_vsearch_options']
def debleeding_options = modules['debleeding_options']

ch_multiqc_config = file("$baseDir/assets/multiqc_config.yaml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config, checkIfExists: true) : Channel.empty()



include { FASTQC_FASTP                                        } from '../subworkflows/local/fastqc_fastp' addParams( fastqc_raw_options: modules['illumina_fastqc_raw'], fastqc_trim_options: modules['illumina_fastqc_trim'], fastp_options: fastp_options )
include { MULTIQC                                             } from '../modules/local/multiqc'                     addParams( options: multiqc_options                       )
include { FILTER                                        } from '../modules/local/vsearch/filter' addParams( options: modules['vsearch_filter'])
include { MERGEPAIRS                                        } from '../modules/local/vsearch/mergepairs' addParams( options: modules['vsearch_mergepairs'])
include { DEREP_FULLLENGTH                                        } from '../modules/local/vsearch/derep_fulllength' addParams( options: modules['vsearch_derep_fulllength'])
include { CONCAT_FASTQ                                        } from '../modules/local/concat_fastq'
include { BLAST_MAKEBLASTDB  as BLAST_MAKEBLASTDB_AIV             } from '../modules/nf-core/modules/blast/makeblastdb/main' addParams( options: modules['blast_makeblastdb_nucl'])
include { BLAST_MAKEBLASTDB  as BLAST_MAKEBLASTDB_SELF             } from '../modules/nf-core/modules/blast/makeblastdb/main' addParams( options: modules['blast_makeblastdb_nucl'])
include { BLAST_BLASTN  as  BLAST_BLASTN_AIV                                    } from '../modules/nf-core/modules/blast/blastn/main' addParams( options: modules['blast_blastn'])
include { BLAST_BLASTN   as BLAST_BLASTN_SELF      } from '../modules/nf-core/modules/blast/blastn/main' addParams( options: modules['blast_blastn_self'])

include { CHIMERA_CHECK                                        } from '../modules/local/chimera_check' addParams( options: modules['chimera_check'])
include { CAL_BSR_SCORE   } from '../modules/local/cal_BSR_score' addParams( options: modules['cal_bsr_score'])
include { ASSIGN_SUBTYPE   } from '../modules/local/assign_subtype' addParams( options: modules['assign_subtype'])
include { SUM_TABLE   } from '../modules/local/sum_table' addParams( options: modules['sum_table'])
include { SUM_HEATMAP   } from '../modules/local/sum_heatmap' addParams( options: modules['sum_heatmap'])
include { REMOVE_BLEEDING_IDS   } from '../modules/local/remove_bleeding_ids' addParams( options: modules['remove_bleeding_ids'])
include { SUM_TABLE as SUM_TABLE_DEBLED   } from '../modules/local/sum_table' addParams( options: modules['sum_table_debled'])
include { SUM_HEATMAP as SUM_HEATMAP_DEBLED   } from '../modules/local/sum_heatmap' addParams( options: modules['sum_heatmap_debled'])






include { DIAMOND_MAKEDB                                             } from '../modules/nf-core/modules/diamond/makedb/main'
include { DIAMOND_BLASTX                                             } from '../modules/nf-core/modules/diamond/blastx/main' addParams( options: diamond_blastx_options)
include { FQ_TO_FA                                        } from '../modules/local/fq_to_fa' 
include { EXTRACTSEQ  as  EXTRACTSEQ_FIRST_ROUND                                     } from '../modules/local/extractseq' addParams( options: modules['extract_seq_first_round'])
include { EXTRACTSEQ  as  EXTRACTSEQ_WITHOUT_CHIMERAS                                     } from '../modules/local/extractseq' addParams( options: modules['extract_seq_without_chimeras'])


include { DEBLEEDING } from '../subworkflows/local/debleeding' addParams(vsearch_vsearch_options: vsearch_vsearch_options, debleeding_options: debleeding_options)



include { KRAKEN2_DB_PREPARE                                  } from '../modules/local/kraken2/kraken2_db_prepare'
include { KRAKEN2                                             } from '../modules/local/kraken2/kraken2'                     addParams( options: modules['kraken2']                    )
include { KRONA_DB                                            } from '../modules/local/krona/krona_db'
include { KRONA                                               } from '../modules/local/krona/krona'                       addParams( options: modules['krona']                      )
include { CENTRIFUGE_DB_PREPARE                          } from '../modules/local/centrifuge/centrifuge_db_prepare'
include { CENTRIFUGE                                          } from '../modules/local/centrifuge/centrifuge'  addParams( options: modules['centrifuge'] )



if(params.centrifuge_db){
    Channel
        .value(file( "${params.centrifuge_db}" ))
        .set { ch_centrifuge_db_file }
} else {
    ch_centrifuge_db_file = Channel.empty()
}

if(params.kraken2_db){
    Channel
        .value(file( "${params.kraken2_db}" ))
        .set { ch_kraken2_db_file }
} else {
    ch_kraken2_db_file = Channel.empty()
}

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary
def multiqc_report    = []
def pass_mapped_reads = [:]
def fail_mapped_reads = [:]

workflow AIVSEEKER {
    ch_versions = Channel.empty()
    if(params.diamond_pep_db){
        Channel
        .value(file( "${params.diamond_pep_db}" ))
        .set { ch_ref_diamond_db }
    }


    ch_aiv_gene_db = Channel
        .fromPath(params.aiv_gene_db)
        .map { file -> tuple(file.baseName, file) }

    if(params.aiv_gene_metadata){
        Channel
        .value(file( "${params.aiv_gene_metadata}" ))
        .set { ch_aiv_gene_metadata }
    }
    /*
    ================================================================================
             Read FASTQ files 
    ================================================================================
    */

    INPUT_CHECK (
        ch_input,
        params.platform
    )
    .sample_info
    .map {
        meta, fastq ->
            meta.id = meta.id.split('_')[0..-2].join('_')
            [ meta, fastq ]
    }
    .groupTuple(by: [0])
    .branch {
        meta, fastq ->
            single  : fastq.size() == 1
                return [ meta, fastq.flatten() ]
            multiple: fastq.size() > 1
                return [ meta, fastq.flatten() ]
    }
    .set { ch_fastq }
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
    
    /*
    ================================================================================
            Concatenate FASTQ files from same sample
    ================================================================================
    */

    CAT_FASTQ (
        ch_fastq.multiple
    )
    .mix(ch_fastq.single)
    .set { ch_cat_fastq }
    /*
    ================================================================================
            Quality check and filtering 
    ================================================================================
    */
    FASTQC_FASTP (
        ch_cat_fastq
    ) 
    ch_kraken2_fastq    =         FASTQC_FASTP.out.trim_reads_paired
    ch_versions = ch_versions.mix(FASTQC_FASTP.out.fastqc_version.first().ifEmpty(null))
    ch_versions = ch_versions.mix(FASTQC_FASTP.out.fastp_version.first().ifEmpty(null))

    /*
    ================================================================================
            Quality check and filtering 
    ================================================================================
    */
    ch_paired_fastq = Channel.empty()
    ch_unpaired_fastq = Channel.empty()
    ch_combined_fastq  = Channel.empty()
    unpaired_with_merged_unmerged_combine = Channel.empty()

    ch_paired_fastq = FASTQC_FASTP.out.trim_reads_paired
    ch_unpaired_fastq = FASTQC_FASTP.out.trim_reads_unpaired


    if(!params.skip_krona) {
        KRONA_DB ()
    }

    if (!params.skip_centrifuge) {
        
        CENTRIFUGE_DB_PREPARE ( ch_centrifuge_db_file )
        CENTRIFUGE (
          ch_paired_fastq,
          CENTRIFUGE_DB_PREPARE.out.db
        )
        CENTRIFUGE.out.results_for_krona
            .map { classifier, meta, report ->
                def meta_new = meta.clone()
                meta_new.classifier  = classifier
                [ meta_new, report ]
            }
            .set { ch_tax_classifications }
        if (!params.skip_krona){
            KRONA (
                ch_tax_classifications,
                KRONA_DB.out.db.collect()
            )
        }
        
    }
    if (!params.skip_kraken2){
        
        KRAKEN2_DB_PREPARE (
            ch_kraken2_db_file
        )
        KRAKEN2 (
            ch_paired_fastq,
             KRAKEN2_DB_PREPARE.out.db
        )
        KRAKEN2.out.results_for_krona
            .map { classifier, meta, report ->
                def meta_new = meta.clone()
                meta_new.classifier  = classifier
                [ meta_new, report ]
            }
            .set { ch_tax_classifications }
        if (!params.skip_krona){
            KRONA (
                ch_tax_classifications,
                KRONA_DB.out.db.collect()
            )
        }
        
    }

    

   /*
    if (params.centrifuge_db && params.kraken2_db && !params.skip_kraken2 && !params.skip_centrifuge && !params.skip_krona) {
        
        CENTRIFUGE.out.results_for_krona.mix(KRAKEN2.out.results_for_krona)
            .map { classifier, meta, report ->
                def meta_new = meta.clone()
                meta_new.classifier  = classifier
                [ meta_new, report ]
            }
            .set { ch_tax_classifications }
        KRONA (
            ch_tax_classifications,
            KRONA_DB.out.db.collect()
        )
     
    }
    
    
    if ( params.centrifuge_db && params.skip_kraken2 && !params.skip_centrifuge && !params.skip_krona) {

        CENTRIFUGE.out.results_for_krona
            .map { classifier, meta, report ->
                def meta_new = meta.clone()
                meta_new.classifier  = classifier
                [ meta_new, report ]
            }
            .set { ch_tax_classifications }
        KRONA (
            ch_tax_classifications,
            KRONA_DB.out.db.collect()
        )
     
    }
    
    if ( params.kraken2_db && params.skip_centrifuge && !params.skip_kraken2 && !params.skip_krona) {     

        KRAKEN2.out.results_for_krona
            .map { classifier, meta, report ->
                def meta_new = meta.clone()
                meta_new.classifier  = classifier
                [ meta_new, report ]
            }
            .set { ch_tax_classifications }
        KRONA (
            ch_tax_classifications,
            KRONA_DB.out.db.collect()
        )
     
    }
    
    
*/


    MERGEPAIRS(ch_paired_fastq)
    
    if (params.keep_paired_only == false) {
        ch_unpaired_fastq
            .join(MERGEPAIRS.out.merged_unmerged_combine)
            .map { row->
                    tuple row[0], [(row[2])]+(row[1])
            }.set{unpaired_with_merged_unmerged_combine}

 
        CONCAT_FASTQ(unpaired_with_merged_unmerged_combine)
        ch_combined_fastq = CONCAT_FASTQ.out.all_combine            
    }
    else {

        ch_combined_fastq = MERGEPAIRS.out.merged_unmerged_combine
    }
    
  
    FILTER(ch_combined_fastq)
    DEREP_FULLLENGTH(FILTER.out.all_filtered)
    ch_derep_fasta= DEREP_FULLLENGTH.out.fasta


   // FQ_TO_FA(ch_combined_fastq)


    /*
    ================================================================================
            Diamond search (First round)
    ================================================================================
    */
    DIAMOND_MAKEDB(ch_ref_diamond_db)
    DIAMOND_BLASTX(ch_derep_fasta, DIAMOND_MAKEDB.out.db)

    
    DIAMOND_BLASTX.out.txt.join(ch_derep_fasta)
                     .set{ch_diamond_output}

    EXTRACTSEQ_FIRST_ROUND(ch_diamond_output) 
    /*
    ================================================================================
            BLAST search (First round)
    ================================================================================
    */


    BLAST_MAKEBLASTDB_AIV(ch_aiv_gene_db)
    ch_ref_db = BLAST_MAKEBLASTDB_AIV.out.db

    ch_ref_db.map{meta, db->[db]}
                 .set{ch_ref_db_sorted}
    EXTRACTSEQ_FIRST_ROUND.out.fasta.combine(ch_ref_db_sorted)
                                    .set{ch_input_for_first_round_blast}
    BLAST_BLASTN_AIV(ch_input_for_first_round_blast)
    

    CHIMERA_CHECK(BLAST_BLASTN_AIV.out.txt)

    CHIMERA_CHECK.out.txt.join(ch_derep_fasta)
                         .set{ch_chimera_check_out}


    EXTRACTSEQ_WITHOUT_CHIMERAS(ch_chimera_check_out)



    ch_blast_db_self = BLAST_MAKEBLASTDB_SELF(EXTRACTSEQ_WITHOUT_CHIMERAS.out.fasta).db    
   
    BLAST_BLASTN_SELF(EXTRACTSEQ_WITHOUT_CHIMERAS.out.fasta.join(ch_blast_db_self))

    

     /*
    ================================================================================
           Calculate BSR Score
    ================================================================================
    */
    
    
    def metafile = params.aiv_gene_metadata

    CHIMERA_CHECK.out.txt.join(BLAST_BLASTN_SELF.out.txt)
                         .join(BLAST_BLASTN_AIV.out.txt)
                         .map{meta, align_ref, align_self, align_all -> tuple(meta, align_ref, align_self, align_all, metafile)}
                         .set{ch_input_for_cal_BSR}
    CAL_BSR_SCORE(ch_input_for_cal_BSR)

     /*
    ================================================================================
           Assign subtype
    ================================================================================
    */

    ASSIGN_SUBTYPE(CAL_BSR_SCORE.out.txt)

    ASSIGN_SUBTYPE.out.pass.collect(it->it[1])
                            .set{ch_input_for_sum_table}
    SUM_TABLE(ch_input_for_sum_table)
    SUM_HEATMAP(SUM_TABLE.out.table)


    /*
    ================================================================================
           Debleeding 
    ================================================================================
    */

    if (!params.skip_debleeding) {
        EXTRACTSEQ_WITHOUT_CHIMERAS.out.fasta.collect(it->it[1])
                            .set{ch_input_for_check_debleeding}
        DEBLEEDING(ch_input_for_check_debleeding)
        REMOVE_BLEEDING_IDS(ASSIGN_SUBTYPE.out.pass, DEBLEEDING.out.pass_ids)
        REMOVE_BLEEDING_IDS.out.subtype_file
                            .collect()
                            .set{ch_input_for_sum_table_delbed}
        SUM_TABLE_DEBLED(ch_input_for_sum_table_delbed)
        SUM_HEATMAP_DEBLED(SUM_TABLE_DEBLED.out.table)
    }
    /*
    ================================================================================
           Pipeline reporting 
    ================================================================================
    */
    /*
    ch_versions
        .map { it -> if (it) [ it.baseName, it ] }
        .groupTuple()
        .map { it[1][0] }
        .flatten()
        .collect()
        .set { ch_versions }
    
    GET_SOFTWARE_VERSIONS (
        ch_versions.map { it }.collect()
    )
    */

    /*
    ================================================================================
           QC report
    ================================================================================
    */
/*
    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(Channel.from(ch_multiqc_config))
    ch_multiqc_files = ch_multiqc_files.mix(GET_SOFTWARE_VERSIONS.out.yaml.collect())
    
    MULTIQC (
        ch_multiqc_files.collect(),
        FASTQC_FASTP.out.fastqc_raw_zip.collect{it[1]}.ifEmpty([]),
        FASTQC_FASTP.out.trim_json.collect{it[1]}.ifEmpty([]),
        FASTQC_FASTP.out.fastqc_trim_zip.collect{it[1]}.ifEmpty([]),
       
    )
    multiqc_report       = MULTIQC.out.report.toList()
    ch_versions = ch_versions.mix(MULTIQC.out.version.ifEmpty(null))

*/
  
}

/*
========================================================================================
    THE END
========================================================================================
*/