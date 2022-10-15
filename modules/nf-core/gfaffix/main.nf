process GFAFFIX {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? 'bioconda::gfaffix=0.1.4' : null)

    def container_image = "gfaffix:0.1.4--hec16e2b_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    tuple val(meta), path(gfa)

    output:
    tuple val(meta), path("*.gfa"), emit: gfa
    tuple val(meta), path("*.txt"), emit: affixes
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gfaffix \\
        $args \\
        $gfa \\
        -o ${prefix}.gfaffix.gfa > ${prefix}.affixes.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gfaffix: \$(gfaffix --version 2>&1 | grep -o 'gfaffix .*' | cut -f2 -d ' ')
    END_VERSIONS
    """
}
