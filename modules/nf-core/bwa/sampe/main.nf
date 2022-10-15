process BWA_SAMPE {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::bwa=0.7.17 bioconda::samtools=1.15.1" : null)
    def container_image = "mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:8110a70be2bfe7f75a2ea7f2a89cda4cc7732095-0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    tuple val(meta), path(reads), path(sai)
    path index

    output:
    tuple val(meta), path("*.bam"), emit: bam
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def read_group = meta.read_group ? "-r ${meta.read_group}" : ""

    """
    INDEX=`find -L ./ -name "*.amb" | sed 's/.amb//'`

    bwa sampe \\
        $args \\
        $read_group \\
        \$INDEX \\
        $sai \\
        $reads | samtools sort -@ ${task.cpus - 1} -O bam - > ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
