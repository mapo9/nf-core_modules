process BISCUIT_INDEX {
    tag "$fasta"
    label 'process_long'

    conda (params.enable_conda ? "bioconda::biscuit=1.0.2.20220113" : null)
    def container_image = "biscuit:1.0.2.20220113--h81a5ba2_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    path fasta, stageAs: "BiscuitIndex/*"

    output:
    path "BiscuitIndex/*.fa*", emit: index, includeInputs: true
    path "versions.yml"      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    biscuit \\
        index \\
        $args \\
        $fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        biscuit: \$( biscuit version |& sed '1!d; s/^.*BISCUIT Version: //' )
    END_VERSIONS
    """
}
