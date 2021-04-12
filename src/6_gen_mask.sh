#!/bin/bash

#PBS -P RDS-FSC-Scape-RW
#PBS -l select=1:ncpus=1:mem=30GB
#PBS -l walltime=01:00:00

PL=${SEQB}/gen_mask
OUT=${OUT}/mask

$PL -l ${k} -r 0.5 ${OUT}/${PREFIX}_rawMask.${k}.fa > ${OUT}/${PREFIX}_mask.${k}.50.fa 
