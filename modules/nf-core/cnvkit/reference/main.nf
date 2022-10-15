process CNVKIT_REFERENCE {
    tag "$fasta"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::cnvkit=0.9.9" : null)
    def container_image = "cnvkit:0.9.9--pyhdfd78af_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    path fasta
    path targets
    path antitargets

    output:
    path "*.cnn"       , emit: cnn
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: targets.BaseName

    """
    cnvkit.py \\
        reference \\
        --fasta $fasta \\
        --targets $targets \\
        --antitargets $antitargets \\
        --output ${prefix}.reference.cnn \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cnvkit: \$(cnvkit.py version | sed -e "s/cnvkit v//g")
    END_VERSIONS
    """
}
