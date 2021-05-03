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

Channel
    .fromPath(params.scaffolds)
    .splitText()
    .map { it -> it.trim() } 
    .set { scaffolds_ch }
*/

Channel
    .from("NC_037651.1", "NC_037653.1", "NC_037652.1", "NC_001566.1", "NW_020555788.1")
    .into { scaffolds_bamcaller_ch
            scaffolds_multihet_ch
            }

Channel
    .fromFilePairs(params.bam)
    .set { bamfiles_ch }

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

process multihet_single {
    
    //cpus 1
    //time < 10m
    //mem < 8GB
    conda 'python=3.7'
    
    input:
        val path from params.path
        val dir from params.in
        val prefix from params.prefix
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.indMask.bed.gz") from mask_indiv
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.bamCalled.vcf.gz") from vcf_bamcalled
        //tuple val(prefix), val(scaffold), path("${prefix}_${scaffold}.genMask.bed.gz") from params.mask_genome

    output:
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.msmcInput.txt") into concat_inputs_ch
 
    script:
    """
    ${path}/msmc-tools/generate_multihetsep.py \
        --mask ${sampleId}_${scaffold}.indMask.bed.gz \
        --mask ${dir}/mask_genome/${prefix}_${scaffold}.genMask.bed.gz \
        ${sampleId}_${scaffold}.bamCalled.vcf.gz \
        > ${sampleId}_${scaffold}.msmcInput.txt 
    """
}

process concat_inputs {
    echo true
    publishDir "${params.out}/msmc_input"

    input:
        tuple val(sampleId), val(scaffold), path(msmc_input) from concat_inputs_ch

    output:
        tuple val(sampleId), path("${sampleId}.mergedInput.txt") into msmc_in
       
    script:
    """
    echo "sampleId: ${sampleId}"
    echo "msmc_input: ${msmc_input}"

    cat ${msmc_input} > ${sampleId}.mergedInput.txt
    """ 
}
/*
process msmc {
    
    publishDir "${params.out}/msmc_output"

    input:
        val path from params.path
        tuple val(sampleId), path("${sampleId}.mergedInput.txt") from msmc_in 
        
    output:
        path("${sampleId}.final.txt")
        path("${sampleId}.loop.txt")
        path("${sampleId}.log")
 
    script:
    """
    ${path}/msmc2-2.1.2-bin/build/release/msmc2 \
        ${sampleId}.mergedInput.txt \
        -o ${sampleId}
    """
}
*/
