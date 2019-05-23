#!/usr/bin/env python

import subprocess
import multiprocessing
import psutil

ncores = str( multiprocessing.cpu_count() )
memory_gb = str(
	int( psutil.virtual_memory().total / 1024.0 / 1024.0 / 1024.0 )
)

if ${meta} == True:
	command = [
		'spades.py',
		'--meta',
		'--pe1-1',
		"${fwd}",
		'--pe1-2',
		"${rev}",
		'-o',
		'assembly',
		'-t',
		ncores,
		'-m',
		memory_gb
		]

elif ${meta} == False:
        command = [
                'spades.py',
                '--pe1-1',
                "${fwd}",
                '--pe1-2',
                "${rev}",
                '-o',
                'assembly',
                '-t',
                ncores,
                '-m',
                memory_gb
                ]

else:
	raise Exception("This shouldn't happen...")

subprocess.call( command )
