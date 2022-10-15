process CLONALFRAMEML {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::clonalframeml=1.12" : null)
    def container_image = "clonalframeml:1.12--h7d875b9_1"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    tuple val(meta), path(newick), path(msa)

    output:
    tuple val(meta), path("*.emsim.txt")                   , emit: emsim, optional: true
    tuple val(meta), path("*.em.txt")                      , emit: em
    tuple val(meta), path("*.importation_status.txt")      , emit: status
    tuple val(meta), path("*.labelled_tree.newick")        , emit: newick
    tuple val(meta), path("*.ML_sequence.fasta")           , emit: fasta
    tuple val(meta), path("*.position_cross_reference.txt"), emit: pos_ref
    path "versions.yml"                                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    ClonalFrameML \\
        $newick \\
        <(gzip -cdf $msa) \\
        $prefix \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        clonalframeml: \$( echo \$(ClonalFrameML -version 2>&1) | sed 's/^.*ClonalFrameML v//' )
    END_VERSIONS
    """
}
