workflow {

    reads_ch = Channel
        .fromFilePairs(params.reads)
        .ifEmpty { error "No paired-end FASTQ files found!" }

    assembly_ch = ASSEMBLY(reads_ch)

    METAQUAST(assembly_ch)
}

process METAQUAST {

    tag "$assembly_dir"

    publishDir "${params.outdir}/metaquast", mode: 'copy'

    container "quay.io/biocontainers/quast:5.3.0--py39pl5321hdbdd923_1"

    input:
    path assembly_dir

    output:
    path("${assembly_dir}_metaquast")

    script:
    """
    metaquast \
        ${assembly_dir}/final.contigs.fa \
        -o ${assembly_dir}_metaquast
    """
}
