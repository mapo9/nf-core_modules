process BEDTOOLS_INTERSECT {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::bedtools=2.30.0" : null)
    def container_image = "bedtools:2.30.0--hc088bd4_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    tuple val(meta), path(intervals1), path(intervals2)
    val extension

    output:
    tuple val(meta), path("*.${extension}"), emit: intersect
    path  "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bedtools \\
        intersect \\
        -a $intervals1 \\
        -b $intervals2 \\
        $args \\
        > ${prefix}.${extension}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version | sed -e "s/bedtools v//g")
    END_VERSIONS
    """
}
