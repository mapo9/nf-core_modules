process TRANSDECODER_PREDICT {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::transdecoder=5.5.0" : null)
    def container_image = "transdecoder:5.5.0--pl5262hdfd78af_4"
    container [ params.container_registry ?: 'quay.io/comp-bio-aging' , container_image ].join('/')


    input:
    tuple val(meta), path(fasta)
    path(fold)

    output:
    tuple val(meta), path("*.transdecoder.pep")  , emit: pep
    tuple val(meta), path("*.transdecoder.gff3") , emit: gff3
    tuple val(meta), path("*.transdecoder.cds")  , emit: cds
    tuple val(meta), path("*.transdecoder.bed")  , emit: bed
    path "versions.yml"                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    TransDecoder.Predict \\
        $args \\
        -O ${prefix} \\
        -t \\
        $fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        transdecoder: \$(echo \$(TransDecoder.Predict --version) | sed -e "s/TransDecoder.Predict //g")
    END_VERSIONS
    """
}
