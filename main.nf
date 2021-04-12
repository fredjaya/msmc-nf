#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.out="/scratch/Scape/fred/msmc"
params.ref="${params.out}/GCF_003254395.2_Amel_HAv3.1_genomic.fna"
params.prefix="capensis"
params.k="35"


process bwa_index {
    
    publishDir params.outdir
    module 'bwa/0.7.17'

    input:
        file ref from params.ref
    
    output:
        file 
 
    script:
    """
    bwa index ${ref}
    """

}

process bwa_aln {

    publishDir params.outdir
    module 'bwa/0.7.17'

    input:
        
}
