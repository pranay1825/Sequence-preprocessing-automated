nextflow.enable.dsl=2

params.reads = "data/*_{1,2}.fastq.gz"
params.outdir = "results"

workflow {

    reads_ch = Channel
        .fromFilePairs(params.reads, flat: true)
        .ifEmpty { error "No paired-end FASTQ files found!" }

    FASTQC(reads_ch)
}

process FASTQC {

    tag "$sample_id"

    publishDir "${params.outdir}/fastqc", mode: 'copy'
    container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    path "*_fastqc.html"
    path "*_fastqc.zip"

    script:
    """
    fastqc $read1 $read2
    """
}
