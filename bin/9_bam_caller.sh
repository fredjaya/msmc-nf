#!/bin/bash

SAMPLE=$1
OUT=/media/meep/GenomeAbyss/capensis
SRC=/home/meep/Desktop/Biocomputing/msmc-tools

mkdir -p ${OUT}/bam_caller

for scaffold in `cat ${OUT}/scaffolds.txt`; do
	cat ${OUT}/vcf/${SAMPLE}_${scaffold}.vcf | \
		${SRC}/bamCaller.py \
		`cat ${OUT}/coverage/${SAMPLE}_${scaffold}.cov` \
		${OUT}/bam_caller/${SAMPLE}_${scaffold}_mask.bed.gz | \
		gzip -c > ${OUT}/bam_caller/${SAMPLE}_${scaffold}.vcf.gz
done
