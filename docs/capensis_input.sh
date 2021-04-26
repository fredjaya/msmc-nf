#!/bin/bash

## ENVIRONMENT VARIABLES ##
export OUT=/scratch/Scape/fred/msmc
export SRC=/home/fjay0039/msmc-nf/src
export PREFIX=capensis
export REF=${OUT}/GCF_003254395.2_Amel_HAv3.1_genomic.fna
export k=35
export BAMDIR=/scratch/Scape/fred/recal_bam

## ANALYSIS ##

# Get list of scaffolds
cd ${OUT}/mask
ls *.bed.gz | perl -pe 's/^.*?_//g' | perl -pe 's/_mask.bed.gz//g' > ${OUT}/scaffolds.txt

# Generate files with average depth for all scaffolds per individual
${SRC}/8_sed_cov.sh

# Calculate coverage per scaffold by individual, to avoid exceeding qsub limit
for i in ${OUT}/sampleId*; do qsub -v BAMDIR,OUT $i; done

# Issues with calling bam from recalibrated .bam files
# First line would contain:
# `BCF)##fileformat=VCFv1.4`
# qsub -v BAMDIR,OUT,PREFIX,SRC ${SRC}/9_bam_caller.sh

# Attempting bamCaller.py with GVCFs
cd /scratch/Scape/fred/2010_gvcf
ls *.vcf | xargs -I {} -n 1 -P 16 sh -c 'echo 'bgzipping' {} && bgzip -c {} > {}.gz && echo 'tabixing' {}.gz && tabix -p vcf {}.gz'
# Moved to ${OUT}/vcf
cd ${OUT}/vcf
cat ${OUT}/scaffolds.txt | xargs -I {} -n 1 -P 177 sh -c 'tabix ${SAMPLE} {} > ${SAMPLE}_{}.vcf'

# Generate .vcf and masks with bamCaller .py
${SRC}/9_bam_caller.sh SAMPLE
