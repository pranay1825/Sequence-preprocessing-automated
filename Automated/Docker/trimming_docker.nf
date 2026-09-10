nextflow.enable.dsl=2

params.reads = "data/*_{1,2}.fastq.gz"
params.outdir = "results"

workflow {

    reads_ch = Channel
        .fromFilePairs(params.reads)
        .ifEmpty { error "No paired-end FASTQ files found!" }

    trimmed_ch = TRIM(reads_ch)
}

process TRIM {

    tag "$sample_id"

    publishDir "${params.outdir}/trimmed", mode: 'copy'
    container "quay.io/biocontainers/fastp:0.23.4--h5f740d0_0"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id),
          path("trimmed_${sample_id}_1.fastq.gz"),
          path("trimmed_${sample_id}_2.fastq.gz")

    script:
    """
    fastp \
      -i ${reads[0]} \
      -I ${reads[1]} \
      -o trimmed_${sample_id}_1.fastq.gz \
      -O trimmed_${sample_id}_2.fastq.gz \
      -h ${sample_id}.html \
      -j ${sample_id}.json
    """
}
