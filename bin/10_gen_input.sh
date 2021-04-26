#!/bin/bash

SAMPLE=$1
OUT=/media/meep/GenomeAbyss/capensis
SRC=/home/meep/Desktop/Biocomputing/msmc-tools

mkdir -p ${OUT}/input

for scaffold in `cat ${OUT}/scaffolds.txt`; do
	
	MASK_IND=${OUT}/bam_caller/${SAMPLE}_${scaffold}_mask.bed.gz
	MASK_GEN=${OUT}/mask/capensis_${scaffold}_mask.bed.gz
	VCF=${OUT}/bam_caller/${SAMPLE}_${scaffold}.vcf.gz

	${SRC}/generate_multihetsep.py --mask=${MASK_IND} --mask=${MASK_GEN} ${VCF} > ${OUT}/input/${SAMPLE}_${scaffold}_msmcIn.txt
done
