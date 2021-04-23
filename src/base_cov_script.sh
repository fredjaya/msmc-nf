#!/bin/bash

#PBS -P RDS-FSC-Scape-RW
#PBS -l select=1:ncpus=1:mem=1GB
#PBS -l walltime=00:05:00

module load samtools/1.9

samtools depth -r SCAFFOLD ${BAMDIR}/SAMPLE_recalibrated_reads.bam | \
	awk '{sum += $3} END {if (NR==0) print NR; else print sum / NR}' \
	> ${OUT}/coverage/SAMPLE_SCAFFOLD.cov
