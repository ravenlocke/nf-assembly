#!/usr/bin/env nextflow

params.fwd = null
params.rev = null
params.nanopore = null
params.meta = null
params.Q = 30
params.outdir = null

/*
Check that the relevant parameters are present to carry out the assembly
*/

// Checking whether the user has identified the same as metagenomic or single-cell
if (params.meta == true){
	meta = 'True'
} else if (params.meta == false){
	meta = 'False'
} else {
	error "--meta must be true or false"
}

// Checking whether the user has indicated the location of the forward / reverse sequences
if (params.fwd == null){
	error "--fwd is a required parameter (the location of the forward reads)"
} else if (params.rev == null){
	error "--rev is a required parameter (the location of the reverse reads"
} else if (params.nanopore == null){
	error "--nanopore is a required parameter (the location of the nanopore reads)"
} else {
	fwd = file( params.fwd )
	rev = file( params.rev ) 
	nanopore = file( params.nanopore )
}


// Create the outdir
if (params.outdir == null){
	error "--outdir is a required parameter (the name of the directory to store results)"
} else {
	outdir = file( params.outdir )
	outdir.mkdirs()
}


/*
Run the Nextflow workflow
*/

// This process exposes the forward and reverse reads to the rest of the workflow.
process exposeData {
	output:
	file "forward.fastq.gz" into fwd_read_qc
	file "reverse.fastq.gz" into rev_read_qc
	file "nanopore.fastq.gz" into nanopore_reads

	script:
	"""
	ln -s $fwd "forward.fastq.gz"
	ln -s $rev "reverse.fastq.gz"
	ln -s $nanopore "nanopore.fastq.gz"
	"""
}

process runTrimmomatic {
	container 'ravenlocke/trimmomatic:0.39'

	input:
	file fwd from fwd_read_qc
	file rev from rev_read_qc

	output:
	file "forward_paired.fastq.gz" into fwd_read_assembly, fwd_read_analysis
	file "reverse_paired.fastq.gz" into rev_read_assembly, rev_read_analysis

	script:
	template "trimmomatic.py"
}

process runFastQC {
	publishDir "${outdir}", mode: 'copy'

        container 'ravenlocke/fastqc:0.11.8'

        input:
        file fwd from fwd_read_analysis
        file rev from rev_read_analysis

	output:
	file "fastqc_results" into fastqc_results

        script:
        template "fastqc.py"
}



process runSpades {
	publishDir "${outdir}", mode: 'copy'

	container 'ravenlocke/spades:3.13.1'

	input: 
	file fwd from fwd_read_assembly
	file rev from rev_read_assembly
	file nanopore from nanopore_reads

	output:
	file "assembly" into contigs

	script:
	template "spades.py"

}


process runProdigal {
	publishDir "${outdir}", mode: 'copy'
	container 'ravenlocke/prodigal:2.6.3'

	input:
	file contigs

	output:
	file "prodigal_out" into cdsout

	script:
	template "prodigal.py"
}

process runQuast{
	publishDir "${outdir}", mode: 'copy'
	container 'ravenlocke/quast:5.0.2'

	input:
	file contigs from contigs
	file fwd from fwd_read_assembly
	file rev from rev_read_assembly

	output:
	file "quast_results" into quast_results
	
	script:
	template "quast.py"

}

