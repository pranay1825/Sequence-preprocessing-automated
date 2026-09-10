nextflow.enable.dsl=2

params.reads = "data/*_{1,2}.fastq.gz"
params.outdir = "results"

workflow {

    reads_ch = Channel
        .fromFilePairs(params.reads)
        .ifEmpty { error "No paired-end FASTQ files found!" }

    trimmed_ch = TRIM(reads_ch)

    FASTQC(trimmed_ch)
    assembly_ch = ASSEMBLY(trimmed_ch)
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

process FASTQC {

    tag "$sample_id"

    publishDir "${params.outdir}/fastqc", mode: 'copy'

    container "quay.io/biocontainers/fastqc:0.11.9--0"

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

process ASSEMBLY {

    tag "$sample_id"

    publishDir "${params.outdir}/assembly", mode: 'copy'

    container "quay.io/biocontainers/megahit:1.2.9--h8b12597_0"

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    path("${sample_id}")

    script:
    """
    megahit \
        -1 ${read1} \
        -2 ${read2} \
        -o ${sample_id}
    """
}
