#!/usr/bin/env nextflow

params.reads = null
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
if (params.reads == null){
	error "--fwd is a required parameter (the location of the forward reads)"
} else {
	input_reads = file( params.reads )
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
	file "reads.fastq.gz" into reads
	
	script:
	"""
	ln -s $input_reads "reads.fastq.gz"
	"""
}

process runTrimmomatic {
	container 'ravenlocke/trimmomatic:0.39'

	input:
	file reads_untrimmed from reads

	output:
	file "reads_clean.fastq.gz" into reads_trimmed_assembly, reads_trimmed_qc
 

	script:
	template "trimmomatic.py"
}

process runFastQC {
	publishDir "${outdir}", mode: 'copy'

        container 'ravenlocke/fastqc:0.11.8'

        input:
        file trimmed_reads from reads_trimmed_qc

	output:
	file "fastqc_results" into fastqc_results

        script:
        template "fastqc.py"
}



process runSpades {
	publishDir "${outdir}", mode: 'copy'

	container 'djskelton/spades:3.14.1'

	input: 
	file trimmed_reads from reads_trimmed_assembly

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

