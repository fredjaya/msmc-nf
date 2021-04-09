#!/usr/bin/env nextflow

nextflow.enable.dsl=2

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
