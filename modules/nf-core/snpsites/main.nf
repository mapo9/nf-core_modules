process SNPSITES {
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::snp-sites=2.5.1" : null)
    def container_image = "snp-sites:2.5.1--hed695b0_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    path alignment

    output:
    path "*.fas"        , emit: fasta
    path "*.sites.txt"  , emit: constant_sites
    path "versions.yml" , emit: versions
    env   CONSTANT_SITES, emit: constant_sites_string

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    snp-sites \\
        $alignment \\
        $args \\
        > filtered_alignment.fas

    echo \$(snp-sites -C $alignment) > constant.sites.txt

    CONSTANT_SITES=\$(cat constant.sites.txt)

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snpsites: \$(snp-sites -V 2>&1 | sed 's/snp-sites //')
    END_VERSIONS
    """
}
