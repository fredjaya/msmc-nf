#!/bin/bash

## INSTALATION ##

# Install seqability
cd ~
wget http://lh3lh3.users.sourceforge.net/download/seqbility-20091110.tar.bz2 && \
tar xjvf seqbility-20091110.tar.bz2 && \
rm seqbility-20091110.tar.bz2 && \
cd seqbility-20091110 && \
make

# Install msmc-tools


## ENVIRONMENT VARIABLES ##
export OUT=/scratch/Scape/fred/msmc
export SRC=/home/fjay0039/msmc-nf/src
export PREFIX=capensis
export REF=${OUT}/GCF_003254395.2_Amel_HAv3.1_genomic.fna
export k=35
export SEQB=/home/fjay0039/seqbility-20091110

## ANALYSIS ##

# Index reference genome [${REF}.bwt .pac .ann .amb .sa]
qsub -v REF,OUT ${SRC}/1_bwa_index.sh

# Extract overlapping ${k}-mer subsequences [(x*) ${PREFIX}_split.k]
qsub -v SEQB,REF,k,OUT,PREFIX ${SRC}/2_extract_kmers

# Align reads to reference [${PREFIX}_split.${k}.sai]
qsub -v PREFIX,REF,OUT,k ${SRC}/3_bwa_aln.sh

# Convert to single-read alignment []
qsub -v OUT,PREFIX,REF,k ${SRC}/4_bwa_samse.sh

# Generate raw mask
qsub -v SEQB,OUT,PREFIX,k ${SRC}/5_raw_mask.sh

# Generate final mask with stringency
qsub -v SEQB,OUT,PREFIX,k ${SRC}/6_gen_mask.sh 

# Convert .fasta mask to a .bed-formatted mask
qsub -v SRC,OUT,PREFIX,k ${SRC}/7_make_mappability_mask.sh
