#!/usr/bin/env python

import os
import shutil
import subprocess

if ${meta} == True:
	command = [
		'prodigal',
		'-i',
		os.path.join("${contigs}", "contigs.fasta"),
		'-a',
		'cds_translated.fasta',
		'-d',
		'cds.fasta',
		'-p',
		'meta',
		'-c',
		'-q'
		]

elif ${meta} == False:
        command = [
                'prodigal',
                '-i',
                os.path.join("${contigs}", "contigs.fasta"),
                '-a',
                'cds_translated.fasta',
                '-d',
                'cds.fasta',
                '-c',
                '-q'
                ]

else:
	raise Exception("This shouldn't happen.")

subprocess.call(command)

os.mkdir("prodigal_out")
shutil.move("cds.fasta", "prodigal_out")
shutil.move("cds_translated.fasta", "prodigal_out")

