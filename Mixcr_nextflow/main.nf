#! /usr/bin/env nextflow
nextflow.enable.dsl=2
params.fastqDir = "$baseDir/Files"

process run_mixcr_align {

    publishDir "Results/${names}", mode: 'copy'

    input:
    tuple val(names), path(file1), path(file2)
    
    output:
    tuple val(names), file("alignments.vdjca")
    
    script:
    """
    mixcr align -p rna-seq -s hsa -OallowPartialAlignments=true -t 8 ${params.fastqDir}/$file1 ${params.fastqDir}/$file2 alignments.vdjca
    """
}

process run_mixcr_assemblePartial_1{
   
    publishDir "Results/${names}", mode: 'copy'

    input:
    tuple val(names), path(alignments) 

    output:
    tuple val(names), path("alignments_rescued_1.vdjca")
    
    script:
    """
    mixcr assemblePartial ${alignments} alignments_rescued_1.vdjca
    """
}

process run_mixcr_assemblePartial_2{

    publishDir "Results/${names}", mode: 'copy'

    input:
    tuple val(names), path(alignments_rescued_1)

    output:
    tuple val(names), path("alignments_rescued_2.vdjca")

    script:
    """
    mixcr assemblePartial $alignments_rescued_1 alignments_rescued_2.vdjca
    """
}

process run_mixcr_extend{

    publishDir "Results/${names}", mode: 'copy'

    input:
    tuple val(names), path(alignments_rescued_2)

    output:
    tuple val(names), path("alignments_rescued_2_extended.vdjca")

    script:
    """
    mixcr extend $alignments_rescued_2 alignments_rescued_2_extended.vdjca
    """
}

process run_mixcr_assemble{

    publishDir "Results/${names}", mode: 'copy'

    input:
    tuple val(names), path(alignments_rescued_2_extended)

    output:
    tuple val(names), path("clones.clns")
    
    script:
    """
    mixcr assemble $alignments_rescued_2_extended clones.clns
    """
}

process run_mixcr_export{
    
    publishDir "Results/${names}", mode: 'copy'

    input:
    tuple val(names), path(clones)

    output:
    tuple path("clones.*")

    script:
    """
    mixcr exportClones $clones clones.txt
    mixcr exportClones -c TRB $clones clones.TRB.txt
    mixcr exportClones -c IGH $clones clones.IGH.txt
    """
}

workflow {
   Files_ch = Channel.fromFilePairs("$baseDir/Files/*_R{1,2}.fastq.gz",flat: true)
      run_mixcr_align(Files_ch)
      run_mixcr_assemblePartial_1(run_mixcr_align.out)
      run_mixcr_assemblePartial_2(run_mixcr_assemblePartial_1.out)
      run_mixcr_extend(run_mixcr_assemblePartial_2.out)
      run_mixcr_assemble(run_mixcr_extend.out)
      run_mixcr_export(run_mixcr_assemble.out)
}
