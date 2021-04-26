#!/bin/bash

#PBS -P RDS-FSC-Scape-RW
#PBS -l select=1:ncpus=8:mem=20GB
#PBS -l walltime=2:00:00

KMER=${OUT}/mask/${PREFIX}_split.${k}
module load bwa/0.7.17

bwa aln -t 8 -R 1000000 -O 3 -E 3 $REF ${KMER} > ${KMER}.sai
