# Nextflow: Assembly

This repository contains a Nextflow workflow for assembly of Illumina paired-end reads. Two workflow can be run in two modes:
- master : runs a 'normal' assembly of the given paired-end reads
- hybrid : runs a hybrid assembly of the given paired-end reads using nanopore data

Regardless of the desired mode, the workflow consists of the following stages:

1. Read trimming of Illumina data using [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) (v0.39). 
  - This carries out (1) a sliding window trim, (2) a leading trim, (3) a trailing trim, and (4) a minimum length trim (fixed at 50 bp). For more information on what these trim operations are doing, please follow the Trimmomatic link above. A default Q-score threshold of 30 is used (1 in 1,000 probability that the basecall is incorrect), but this can be modified (see Running the workflow)
2. Assembly of reads into contigs / scaffolds using [SPAdes](http://cab.spbu.ru/software/spades/) (v3.13.1)
3. Identification of putative coding sequences using [Prodigal](https://github.com/hyattpd/Prodigal) (v2.6.3)

Further, the workflow will generate a read quality control report post-trimming (using [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) v0.11.8) and an assembly report using [Quast](http://bioinf.spbau.ru/quast) (v5.0.2).

Please note:
- In hybrid mode, nanopore data is *not* trimmed. This is because the [SPAdes documentation](http://spades.bioinf.spbau.ru/release3.11.1/manual.html) states that there is no need to pre-correct the data.
- Trimmomatic is not used to perform adapter trimming. This is deliberate: see [this blog post](https://www.ecseq.com/support/ngs/trimming-adapter-sequences-is-it-necessary) and links to discussions for the pros and cons of adapter trimming. TL;DR: 
> But there are also applications (transcriptome sequencing, whole genome sequencing, etc.) where adapter contamination can be expected to be so small (due to an appropriate size selection) that one could consider to skip the adapter removal and thereby save time and efforts.

## Running the workflow
The normal assembly workflow can be invoked with the following command:

```
nextflow run ravenlocke/nf-assembly -r master --fwd <filename> --rev <filename> \
  --meta <true/false> --outdir <dirname>

# Parameters are as follows:
#   --fwd: the name of the file with the forward reads
#   --rev: the name of the file with the reverse reads
#   --meta: whether the reads are metagenomic (true) or not (false)
#   --outdir: the name of the folder where results should be written to
#
#   OPTIONAL PARAMTERS:
#   --Q: the Q-score threshold to use for Trimmomatic (default 30)
```

The hybrid assembly workflow can be invoked similarly by specifying a different branch (-r) and adding a --nanopore parameter specifying where the nanopore reads are.

```
nextflow run ravenlocke/nf-assembly -r hybrid --fwd <filename> --rev <filename> \
  --meta <true/false> --outdir <dirname>

# Parameters are as follows:
#   --fwd: the name of the file with the forward reads
#   --rev: the name of the file with the reverse reads
#   --nanopore: the name of the file with the nanopore reads in
#   --meta: whether the reads are metagenomic (true) or not (false)
#   --outdir: the name of the folder where results should be written to
#
#   OPTIONAL PARAMTERS:
#   --Q: the Q-score threshold to use for Trimmomatic (default 30)
```

This workflow has only been tested with the reads given as gzipped FASTQ files.
