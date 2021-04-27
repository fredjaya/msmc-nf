#!/usr/bin/env nextflow

/*
 * PARAMETERS AND CHANNELS
 */ 

//params.out="/scratch/Scape/fred/msmc"
params.in="/media/meep/GenomeAbyss/capensis"
params.out="/media/meep/GenomeAbyss/nf_test"
params.ref="${params.in}/GCF_003254395.2_Amel_HAv3.1_genomic.fna"
params.tools="/home/meep/Desktop/Biocomputing/msmc-tools"
params.prefix="capensis"
params.k="35"
params.samples="${params.in}/samples.txt"
params.scaffolds="${params.in}/true_scaffolds.txt"
params.coverage="${params.in}/coverage/*.txt"
params.bam="${params.in}/recal_bam/Fdrone{_recalibrated_reads.bam,_recalibrated_reads.bai}"
params.mask_genome="${params.in}/mask_indiv/*_*.genMask.bed.gz"
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

Channel.from("Fdrone", "Worker").set{samples_ch}
Channel.from("NC_037653.1").into{scaffolds_bamcaller_ch;scaffolds_multihet_ch}

Channel
    .fromFilePairs(params.bam)
    .set { bamfiles_ch }

log.info """\

===== DIRECTORIES AND PATHS =====
in          = ${params.in}
out         = ${params.out}
ref         = ${params.ref}
tools       = ${params.tools}
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
        val tools from params.tools
    
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
    ${tools}/bamCaller.py \
        `cat ${out}/coverage/${sampleId}_${scaffold}.cov` \
        ${sampleId}_${scaffold}.indMask.bed.gz | \
        gzip -c > ${sampleId}_${scaffold}.bamCalled.vcf.gz
    """

}

process multihet_single {

    conda 'python=3.7'
    
    publishDir "${params.out}/msmc_input"

    input:
        val tools from params.tools
        val dir from params.in
        val prefix from params.prefix
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.indMask.bed.gz") from mask_indiv
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.bamCalled.vcf.gz") from vcf_bamcalled
        //tuple val(prefix), val(scaffold), path("${prefix}_${scaffold}.genMask.bed.gz") from params.mask_genome

    output:
        tuple val(sampleId), val(scaffold),
            path("${sampleId}_${scaffold}.msmcInput.txt")
 
    script:
    """
    ${tools}/generate_multihetsep.py \
        --mask ${sampleId}_${scaffold}.indMask.bed.gz \
        --mask ${dir}/mask_genome/${prefix}_${scaffold}.genMask.bed.gz \
        ${sampleId}_${scaffold}.bamCalled.vcf.gz \
        > ${sampleId}_${scaffold}.msmcInput.txt 
    """
}
