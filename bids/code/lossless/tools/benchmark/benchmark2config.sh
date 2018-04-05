#!/bin/bash

# uncomment if necessary (some remote servers require this)
#module unload gcc
#module unload intel
#module load r
python analysis/support/tools/benchmark/logStats.py
Rscript analysis/support/tools/benchmark/generateBenchmark.R
python analysis/support/tools/benchmark/generateConfig.py
