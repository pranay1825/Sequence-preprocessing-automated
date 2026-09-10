nextflow.enable.dsl=2

params.reads  = "data/*_{1,2}.fastq.gz"
params.outdir = "results"

workflow {

    reads_ch = Channel
        .fromFilePairs(params.reads)
        .ifEmpty { error "No paired-end FASTQ files found!" }

    assembly_ch=ASSEMBLY(reads_ch)
}

process ASSEMBLY {

    tag "$sample_id"

    publishDir "${params.outdir}/assembly", mode: 'copy'

    container "quay.io/biocontainers/megahit:1.2.9--h8b12597_0"

    input:
    tuple val(sample_id), path(reads)

    output:
    path("${sample_id}")

    script:
    """
    megahit \
        -1 ${reads[0]} \
        -2 ${reads[1]} \
        -t 8 \
        --min-contig-len 1000 \
        -o ${sample_id}
    """
}
