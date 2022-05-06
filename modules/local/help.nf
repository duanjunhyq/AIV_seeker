def printHelp() {
  log.info """
  Usage:
    nextflow run main.nf -profile [singularity | docker | conda) --prefix [prefix] --mode [reference | user]  [workflow-options]

  Description:
    AIV_seeker is a pipeline that is optimized for detecting and identifying
    low-abundance avian influenza virus (AIV) from metagenomic NGS data. All
    options set via CLI can be set in conf directory

  Nextflow arguments (single DASH):
    -profile                  Allowed values: conda & singularity

  Mandatory workflow arguments (mutually exclusive):
    --prefix                  A (unique) string prefix for output directory for each run.
    --mode                    A flag for user uploaded data through visualization app or
                              high-throughput analyses (reference | user) (Default: reference)

  Optional:

  Input options:
    --seq                     Input SARS-CoV-2 genomes or consensus sequences
                              (.fasta file)
    --meta                    Input Metadata file of SARS-CoV-2 genomes or consensus sequences
                              (.tsv file)
    --userfile                Specify userfile
                              (fasta | vcf) (Default: None)
    --gisaid_metadata         If lineage assignment is preferred by mapping metadata to GISAID
                              metadata file, provide the metadata file (.tsv file)
    --variants                Provide a variants file
                              (.tsv) (Default: $baseDir/assets/ncov_variants/variants_who.tsv)
    --outdir                  Output directory
                              (Default: $baseDir/results)
    --gff                     Path to annotation gff for variant consequence calling and typing.
                              (Default: $baseDir/assets/ncov_genomeFeatures/MN908947.3.gff3)
    --ref                     Path to SARS-CoV-2 reference fasta file
                              (Default: $baseDir/assets/ncov_refdb/*)
    --bwa_index               Path to BWA index files
                              (Default: $baseDir/assets/ncov_refdb/*)
    QC
      --skip_fastqc [bool]            Skip FastQC (Default: false)
      --skip_picard_metrics [bool]    Skip Picard CollectMultipleMetrics (Default: false)
      --skip_preseq [bool]            Skip Preseq (Default: false)
      --skip_plot_profile [bool]      Skip deepTools plotProfile (Default: false)
      --skip_plot_fingerprint [bool]  Skip deepTools plotFingerprint (Default: false)
      --skip_ataqv [bool]             Skip Ataqv (Default: false)
      --skip_igv [bool]               Skip IGV (Default: false)
      --skip_multiqc [bool]           Skip MultiQC (Default: false)

  Selection options:

    --ivar                    Run the iVar workflow instead of Freebayes(default)
    --bwamem                  Run the BWA workflow instead of MiniMap2(default)
    --skip_pangolin           Skip PANGOLIN. Can be used if metadata already have lineage
                              information or mapping is preferred method
    --skip_mapping            Skip Mapping. Can be used if metadata already have lineage
                              information or PANGOLIN is preferred method

  Genomic Analysis parameters:

    BBMAP
    --maxns                   Max number of Ns allowed in the sequence in qc process
    --minlength               Minimun length of sequence required for sequences
                              to pass qc filtration. Sequence less than minlength
                              are not taken further

    IVAR/FREEBAYES
    --ploidy                  Ploidy (Default: 1)
    --mpileupDepth            Mpileup depth (Default: unlimited)
    --var_FreqThreshold       Variant Calling frequency threshold for consensus variant
                              (Default: 0.75)
    --var_MaxDepth            Maximum reads per input file depth to call variant
                              (mpileup -d, Default: 0)
    --var_MinDepth            Minimum coverage depth to call variant
                              (ivar variants -m, freebayes -u Default: 10)
    --var_MinFreqThreshold    Minimum frequency threshold to call variant
                              (ivar variants -t, Default: 0.25)
    --varMinVariantQuality    Minimum mapQ to call variant
                              (ivar variants -q, Default: 20)

  Surveillance parameters:
    --virusseq                True/False (Default: False). If your data is from
                              VirusSeq Data Portal (Canada's Nation COVID-19
                              genomics data portal).
                              Passing this argument adds an acknowledgment
                              statement to the surveillance report.
                              see https://virusseq-dataportal.ca/acknowledgements
  """.stripIndent()
}
