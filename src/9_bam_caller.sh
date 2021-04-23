#!/bin/bash

#PBS -P RDS-FSC-Scape-RW
#PBS -l select=1:ncpus=1:mem=8GB
#PBS -l walltime=1:00:00

SCAFFOLD=NC_037638.1
SAMPLE=Larv01
BAM=${BAMDIR}/${SAMPLE}_recalibrated_reads.bam
COVERAGE=`cat ${OUT}/coverage/${SAMPLE}_${SCAFFOLD}.cov`
MASK=${OUT}/mask/${PREFIX}_${SCAFFOLD}_mask.bed.gz

module load bcftools/1.9

mkdir -p ${OUT}/vcf

bcftools mpileup -Ou -r $SCAFFOLD -f $REF $BAM | \
    perl -pe 's/^.*(?=##fileformat=VCFv4.2)//g' | \
    bcftools call -c -V indels | \
    ${SRC}/bamCaller.py ${COVERAGE} ${MASK} > \
    ${OUT}/vcf/${SAMPLE}_${SCAFFOLD}.vcf
