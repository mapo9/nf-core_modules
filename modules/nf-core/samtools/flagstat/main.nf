process SAMTOOLS_FLAGSTAT {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::samtools=1.15.1" : null)
    def container_image = "samtools:1.15.1--h1170115_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("*.flagstat"), emit: flagstat
    path  "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    samtools \\
        flagstat \\
        --threads ${task.cpus} \\
        $bam \\
        > ${prefix}.flagstat

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
