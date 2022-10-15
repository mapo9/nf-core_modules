process ATLAS_RECAL {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::atlas=0.9.9" : null)
    def container_image = "atlas:0.9.9--h082e891_0"
    container [ params.container_registry ?: 'quay.io/biocontainers' , container_image ].join('/')


    input:
    tuple val(meta), path(bam), path(bai), path(empiric), path(readgroups)
    path(alleles)
    path(invariant_sites)

    output:
    tuple val(meta), path("*.txt"), emit:recal_patterns
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def PMD = empiric ? "pmdFile=${empiric}" : ""
    def ALLELES = alleles ? "alleleFile=${alleles}" : ""
    def INVARIANTS = invariant_sites ? "window=${invariant_sites}" : ""
    def READGROUPS = readgroups ? "poolReadGroups=${readgroups}" : ""

    """
    atlas \\
        task=recal \\
        bam=$bam \\
        $PMD \\
        $READGROUPS \\
        $ALLELES \\
        $INVARIANTS \\
        out=$prefix \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        atlas: \$((atlas 2>&1) | grep Atlas | head -n 1 | sed -e 's/^[ \t]*Atlas //')
    END_VERSIONS
    """
}
