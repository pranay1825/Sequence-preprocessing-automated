# Sequence preprocessing automated

Nextflow (DSL2) workflows that automate the preprocessing steps of a metagenomics
analysis: adapter/quality trimming, read QC, de novo assembly, and assembly QC.

Each step exists both as a standalone workflow and as a process inside the combined
`main.nf` pipeline, in two flavours — one that expects the tools installed locally,
and a `_docker` variant that pins a Biocontainers image per process.

## Layout

```
Automated/
├── main.nf              # trim → FastQC + assembly, tools from PATH
├── main_docker.nf       # same pipeline, each process pinned to a Biocontainer
├── trimming.nf          # fastp only
├── fastqc.nf            # FastQC process
├── assembly.nf          # MEGAHIT only
├── metaquast.nf         # assembly + MetaQUAST QC
└── Docker/              # containerised versions of the individual steps
    ├── trimming_docker.nf
    ├── fastqc_docker.nf
    ├── assembly_docker.nf
    └── metaquast_docker.nf

COMMANDS/Commands.txt            # raw CLI equivalents plus downstream awk/HMMER steps
FILES DONE USING GALAXY.txt      # SRA accessions processed on the Galaxy server instead
```

## Tools

| Step | Tool | Container (Docker variants) |
| --- | --- | --- |
| Trimming | fastp | `quay.io/biocontainers/fastp:0.23.4--h5f740d0_0` |
| Read QC | FastQC | `quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0` |
| Assembly | MEGAHIT | `quay.io/biocontainers/megahit:1.2.9--h8b12597_0` |
| Assembly QC | MetaQUAST | `quay.io/biocontainers/quast:5.3.0--py39pl5321hdbdd923_1` |

## Running

Paired-end reads are picked up from `data/` as `*_{1,2}.fastq.gz` and results are
published to `results/`:

```bash
# tools available locally
nextflow run Automated/main.nf

# containerised
nextflow run Automated/main_docker.nf -with-docker

# override the defaults
nextflow run Automated/main.nf --reads 'reads/*_R{1,2}.fastq.gz' --outdir out
```

Individual steps run the same way, e.g. `nextflow run Automated/trimming.nf`.

## Downstream steps

`COMMANDS/Commands.txt` records the manual commands used after assembly — six-frame
translation with `transeq`, `hmmscan` against a profile HMM, Prodigal gene prediction,
and the awk one-liners used to pull out and length-filter the resulting ORFs. These
are not wired into the Nextflow pipeline yet.

## Known gaps

- `fastqc.nf` and `Docker/fastqc_docker.nf` declare the `FASTQC` process but no
  `workflow` block, so running either directly makes Nextflow treat the process as
  the entry point and ask for `--sample_id` on the command line. FastQC still runs
  as part of `main.nf` / `main_docker.nf`.
