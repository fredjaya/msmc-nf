#!/usr/bin/env nextflow

/*
 * PARAMETERS AND CHANNELS
 */ 

//params.out="/scratch/Scape/fred/msmc"
params.out="/media/meep/GenomeAbyss/capensis"
params.ref="${params.out}/GCF_003254395.2_Amel_HAv3.1_genomic.fna"
params.tools="/home/meep/Desktop/Biocomputing/msmc-tools/"
params.prefix="capensis"
params.k="35"
params.scaffolds="${params.out}/true_scaffolds.txt"
params.coverage="${params.out}/coverage/*.txt"
params.bam="${params.out}/recal_bam/Fdrone{_recalibrated_reads.bam,_recalibrated_reads.bai}"

Channel
    .fromPath(params.scaffolds)
    .splitText()
    .map { it -> it.trim() } 
    .set { scaffolds_ch }

Channel
    .fromFilePairs(params.bam)
    .set { bamfiles_ch }

log.info """\

===== DIRECTORIES AND PATHS =====
out         = ${params.out}
ref         = ${params.ref}
msmc-tools  = ${params.tools}
prefix      = ${params.prefix}
k           = ${params.k}
scaffolds   = ${params.scaffolds}
coverage    = ${params.coverage}
bam         = ${params.bam}

"""

/*
 * PROCESSES
 */

process bamcaller {
    
    // cpus 1
    // time 1h
    // mem 8G
    conda 'bioconda::bcftools=1.8 python=3.7'
 
    input:
        tuple val(sampleId), path(bamfiles) from bamfiles_ch
        path ref from params.ref
        each scaffold from scaffolds_ch
        val out from params.out
        val tools from params.tools
 
    script:
    def bam = bamfiles.findAll{ it.toString() =~ /.bam/ }.join('')
    """
    mkdir -p ${out}/ind_mask
    mkdir -p ${out}/vcf

    bcftools mpileup -Ou -r ${scaffold} -f ${ref} ${bam} | \
    bcftools call -c -V indels | \
    ${tools}/bamCaller.py \
        `cat ${out}/coverage/${sampleId}_${scaffold}.cov` \
        ${out}/ind_mask/${sampleId}_${scaffold}.bed.gz \
        > ${out}/vcf/${sampleId}_${scaffold}.vcf 
    """

}

test.view { it.trim() }

process multihet_single {

    script:
    """
    
    """    
}
/*
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
