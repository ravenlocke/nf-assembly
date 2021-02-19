#!/usr/bin/env python

import os
import subprocess
import multiprocessing

nproc = str( multiprocessing.cpu_count() )

command = [
	'trimmomatic',
	'SE',
	'-threads',
	nproc,
	"${reads_untrimmed}",
	'reads_clean.fastq.gz',
	'SLIDINGWINDOW:4:${params.Q}',
	'LEADING:${params.Q}',
	'TRAILING:${params.Q}',
	'MINLEN:50'
	]

subprocess.call(command)
os.remove( 'forward_unpaired.fastq.gz' )
os.remove( 'reverse_unpaired.fastq.gz' )
