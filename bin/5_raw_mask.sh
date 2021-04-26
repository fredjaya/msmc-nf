#!/bin/bash

#PBS -P RDS-FSC-Scape-RW
#PBS -l select=1:ncpus=1:mem=30GB
#PBS -l walltime=01:00:00

PL=${SEQB}/gen_raw_mask.pl
OUT=${OUT}/mask

$PL ${OUT}/${PREFIX}_split.${k}.sam > ${OUT}/${PREFIX}_rawMask.${k}.fa 
