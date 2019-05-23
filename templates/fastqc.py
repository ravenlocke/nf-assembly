#!/usr/bin/env python

import os
import shutil
import subprocess
import multiprocessing

ncores = str( multiprocessing.cpu_count() )

command = ['fastqc', '-t', ncores, "${fwd}"]
subprocess.call(command)
command = ['fastqc', '-t', ncores, "${rev}"]
subprocess.call(command)

os.mkdir('fastqc_results')
[shutil.move(i, 'fastqc_results') for i in os.listdir('.') if i.endswith('_fastqc.html')]
[shutil.move(i, 'fastqc_results') for i in os.listdir('.') if i.endswith('_fastqc.zip')]
