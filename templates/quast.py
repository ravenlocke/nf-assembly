#!/usr/bin/env python

import os
import subprocess

if ${meta} == True:
	command = ['metaquast.py']
elif ${meta} == False:
	command = ['quast.py']
else:
	raise Exception("This shouldn't happen")

command += [
	'--min-contig',
	'0',
	'--pe1',
	"${fwd}",
	"--pe2",
	"${rev}",
	os.path.join("${contigs}", "contigs.fasta")
	]

subprocess.call(command)
