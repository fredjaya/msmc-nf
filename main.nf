#!/usr/bin/env nextflow

/*
 * SETUP 
 */ 

/*
Channel
    .fromPath(params.samples)
    .splitText()
    .map { it -> it.trim() } 
    .set { samples_ch }
*/

Channel
    .fromPath(params.scaffolds)
    .splitText()
    .map { it -> it.trim() } 
    .into { scaffolds_bamcaller_ch
            scaffolds_multihet_ch
            }

Channel
    .fromFilePairs(params.bam)
    .set { bamfiles_ch }

Channel
    .fromPath(params.mask_genome)
    .map { file ->
        def scaffold = (file.toString() =~ /(NC|NW)_\d+\.1/)[0][0]
        return tuple('', scaffold, file)
    }
    .set { mask_genome_ch }

log.info """\

===== DIRECTORIES AND PATHS =====
in          = ${params.in}
out         = ${params.out}
trace       = ${params.trace}
ref         = ${params.ref}
path        = ${params.path}
prefix      = ${params.prefix}
k           = ${params.k}
samples     = ${params.samples}
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

    publishDir "${params.out}",
        saveAs: { filename ->
                    if (filename.endsWith(".bed.gz")) "mask_indiv/${filename}"
                    else if (filename.endsWith(".vcf.gz")) "vcf/${filename}"
                }

    input:
        tuple val(sampleId), path(bamfiles) from bamfiles_ch
        path ref from params.ref
        each scaffold from scaffolds_bamcaller_ch
        val out from params.in
        val path from params.path
    
    output:
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.indMask.bed.gz") into mask_indiv
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.bamCalled.vcf.gz") into vcf_bamcalled
    
    script:
    def bam = bamfiles.findAll{ it.toString() =~ /.bam/ }.join('')
    """
    bcftools mpileup -Ou -r ${scaffold} --threads 8 -f ${ref} ${bam} | \
    bcftools call -c --threads 8 -V indels | \
    ${path}/msmc-tools/bamCaller.py \
        `cat ${out}/coverage/${sampleId}_${scaffold}.cov` \
        ${sampleId}_${scaffold}.indMask.bed.gz | \
        gzip -c > ${sampleId}_${scaffold}.bamCalled.vcf.gz
    """

}

mask_indiv
    .join(vcf_bamcalled)
    .join(mask_genome_ch, by:1)
    .map { it -> [ it[1], it[0], it[2], it[6], it[4] ] }
    .set { multihet_in }

process multihet_single {
    
    //cpus 1
    //time < 10m
    //mem < 8GB
    conda 'python=3.7'
   
    publishDir "${params.out}/msmc_input"
 
    input:
        val path from params.path
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.indMask.bed.gz"),
            path("${scaffold}.genMask.bed.gz"),
            path("${sampleId}_${scaffold}.bamCalled.vcf.gz") from multihet_in

    output:
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.msmcInput.txt") into msmc_in
 
    script:
    """
    ${path}/msmc-tools/generate_multihetsep.py \
        --mask ${sampleId}_${scaffold}.indMask.bed.gz \
        --mask ${scaffold}.genMask.bed.gz \
        ${sampleId}_${scaffold}.bamCalled.vcf.gz \
        > ${sampleId}_${scaffold}.msmcInput.txt 
    """
}

process msmc {

    echo true 
    publishDir "${params.out}/msmc_output"

    input:
        val path from params.path
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_*.msmcInput.txt") from msmc_in.groupTuple(by: 0) 
        
    output:
        path("${sampleId}.final.txt")
        path("${sampleId}.loop.txt")
        path("${sampleId}.log")
 
    script:
    """
    ${path}/msmc2-2.1.2-bin/build/release/msmc2 \
        -o ${sampleId} \
        ${sampleId}_*.msmcInput.txt
    """
}
