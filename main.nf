#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.out="/scratch/Scape/fred/msmc"
params.ref="${params.out}/GCF_003254395.2_Amel_HAv3.1_genomic.fna"
params.prefix="capensis"
params.k="35"
params.scaffolds="${params.out}/scaffolds.txt"
params.bam="/scratch/Scape/fred/recal_bam/Fdrone_recalibrated_reads.{bam,bai}"

log.info """\
===============
out = ${params.out}
ref = ${params.ref}
prefix = ${params.prefix}
k = ${params.k}
scaffolds = ${params.scaffolds}
bam = ${params.bam}
===============
"""

bam_ch = Channel.fromFilePairs(params.bam)

Channel
    .fromPath(params.scaffolds)
    .splitText()
    .set { scaffolds_ch }

process coverage_per_scaffold {
    
    module 'samtools/1.9'
    tag "$sampleId"
    tag "$scaffold"
    echo true

    input:
        each scaffold from scaffolds_ch 
        tuple val(sampleId), path(bamfiles) from bam_ch 
    
    output:
        file *.cov

    script:
    def bam = bamfiles.findAll{ it.toString() =~ /.bam/ }.join('')
    """
    ~/msmc-nf/src/coverage_per_scaffold.sh $scaffold $bam $sampleId
    """
}

/*
process mpileup {
    
    input:
        path ref from params.ref
        path fai from params.fai
        path dict from params.dict
        val scaffold from 
        tuple val(sampleId), path(bamfiles) from recalbam_ch

    output:


    script:
    def bam = bamfiles.findAll{ it.toString() =~ /.bam/ }.join('')
    """
    samtools mpileup -d 8000 -q 20 -Q 20 -C 50 -u -f ${ref} ${bam} | \
    bcftools call -c -V indels | \
    ${MSMC}/bamCaller.py 30 ${OUT}/${BAM}_mask.bed.gz | \
    gzip -c > ${OUT}/${sampleId}.vcf.gz
}
*/

process bam_caller {

    input:
        
    output:

    script:   

}
