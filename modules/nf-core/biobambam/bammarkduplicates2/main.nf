process BIOBAMBAM_BAMMARKDUPLICATES2 {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::biobambam=2.0.183" : null)
    def container_image = "biobambam:2.0.183--h9f5acd7_1"
    container (params.container_registry ?: 'quay.io/biocontainers' , container_image)


    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam")        , emit: bam
    tuple val(meta), path("*.metrics.txt"), emit: metrics
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bammarkduplicates2 \\
        $args \\
        I=$bam \\
        O=${prefix}.bam \\
        M=${prefix}.metrics.txt \\
        tmpfile=$prefix \\
        markthreads=$task.cpus

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bammarkduplicates2: \$(echo \$(bammarkduplicates2 --version 2>&1) | sed 's/^This is biobambam2 version //; s/..biobambam2 is .*\$//' )
    END_VERSIONS
    """
}
