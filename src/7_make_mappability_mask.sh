#!/bin/bash

#PBS -P RDS-FSC-Scape-RW
#PBS -l select=1:ncpus=1:mem=16GB
#PBS -l walltime=02:00:00

module load python/2.7.15
OUT=${OUT}/mask
cd ${OUT}

python ${SRC}/makeMappabilityMask.py ${OUT} ${PREFIX} ${k}
