#!/bin/bash

#PBS -P RDS-FSC-Scape-RW
#PBS -l select=1:ncpus=1:mem=80GB
#PBS -l walltime=15:00:00

SA=${OUT}/mask/${PREFIX}_split.${k}
module load bwa/0.7.17

bwa samse -f ${SA}.sam $REF ${SA}.sai ${SA}
