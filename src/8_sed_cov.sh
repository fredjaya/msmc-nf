#!/bin/bash

mkdir -p ${OUT}/cov_scripts
mkdir -p ${OUT}/coverage

## Create individual scripts for each sample and scaffold ##
rm ${OUT}/cov_scripts/*
for bam in `ls ${BAMDIR}/*.bam`; do
    sample="$(basename $bam _recalibrated_reads.bam)"
    for scaffold in `cat ${OUT}/scaffolds.txt`; do
        cat ${SRC}/base_cov_script.sh | \
        sed "s/SCAFFOLD/$scaffold/g" | \
        sed "s/SAMPLE/$sample/g" \
        > ${OUT}/cov_scripts/${sample}_${scaffold}.sh
	echo "Done: ${sample} ${scaffold}"
        done
    done
