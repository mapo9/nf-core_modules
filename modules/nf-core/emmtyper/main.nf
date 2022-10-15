process EMMTYPER {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::emmtyper=0.2.0" : null)
    def container_image = "emmtyper:0.2.0--py_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.tsv"), emit: tsv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    emmtyper \\
        $args \\
        $fasta \\
        > ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        emmtyper: \$( echo \$(emmtyper --version 2>&1) | sed 's/^.*emmtyper v//' )
    END_VERSIONS
    """
}
