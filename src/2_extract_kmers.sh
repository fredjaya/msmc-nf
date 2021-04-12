#!/bin/bash

#PBS -P RDS-FSC-Scape-RW
#PBS -l select=1:ncpus=1:mem=8GB
#PBS -l walltime=00:10:00

mkdir -p ${OUT}/mask
OUT=${OUT}/mask
SPLITFA=$SEQB/splitfa

cd $OUT
$SPLITFA $REF $k | split -l 20000000 && \
cat ${OUT}/x* >> ${OUT}/${PREFIX}_split.${k} && \
rm ${OUT}/x*
