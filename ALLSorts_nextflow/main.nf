#! /usr/bin/env nextflow

nextflow.enable.dsl=2
params.files = "$baseDir/Files/*_RNASEQ_Clinical1.0_dragen.quant.genes.sf"
params.Rscript = "$baseDir/Rscript.R"
params.gtf1 = "$baseDir/gtf1.txt"
params.df = "$baseDir/df.txt"

process run_R {
    
    publishDir "Counts/$files.simpleName", mode: 'copy'
    debug true

    input:
    path(files)
    
    output:
    file "counts.csv"

    script:
    """
    Rscript $params.Rscript $params.gtf1 $params.df $files counts.csv
    """
}

process run_Allsorts {

    publishDir "${projectDir}/Results", mode: 'copy'

    input:
    file(files)

    output:
    tuple file('*.csv'), file('*png'), file('*html')

    script:
    """
    source activate allsorts
    ALLSorts -samples $files -destination ./
    """
}

workflow {
    channel.fromPath(params.files) \
        | run_R \
        | collectFile(name: 'counts.csv', keepHeader:true) \
        | run_Allsorts
}
