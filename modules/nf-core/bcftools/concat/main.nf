process BCFTOOLS_CONCAT {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::bcftools=1.15.1" : null)
    def container_image = "bcftools:1.15.1--h0ea216a_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    tuple val(meta), path(vcfs), path(tbi)

    output:
    tuple val(meta), path("*.gz"), emit: vcf
    path  "versions.yml"         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"
    """
    bcftools concat \\
        --output ${prefix}.vcf.gz \\
        $args \\
        --threads $task.cpus \\
        ${vcfs}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n1 | sed 's/^.*bcftools //; s/ .*\$//')
    END_VERSIONS
    """
}
