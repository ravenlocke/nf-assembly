#!/usr/bin/env python

import os
import subprocess
import multiprocessing

nproc = str( multiprocessing.cpu_count() )

command = [
	'trimmomatic',
	'PE',
	'-threads',
	nproc,
	"${fwd}",
	"${rev}",
	'forward_paired.fastq.gz',
	'forward_unpaired.fastq.gz',
	'reverse_paired.fastq.gz',
	'reverse_unpaired.fastq.gz',
	'SLIDINGWINDOW:4:${params.Q}',
	'LEADING:${params.Q}',
	'TRAILING:${params.Q}',
	'MINLEN:50'
	]

subprocess.call(command)
os.remove( 'forward_unpaired.fastq.gz' )
os.remove( 'reverse_unpaired.fastq.gz' )
