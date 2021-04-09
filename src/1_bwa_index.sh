#!/bin/bash

#PBS -P RDS-FSC-Scape-RW
#PBS -l select=1:ncpus=1:mem=16GB
#PBS -l walltime=2:00:00

module load bwa/0.7.17

cd $OUT
bwa index $REF
