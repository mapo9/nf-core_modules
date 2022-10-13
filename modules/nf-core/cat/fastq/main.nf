process CAT_FASTQ {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    def container_image = "/ubuntu:20.04"
    container { (params.container_registry ?: '' + container_image) }

    input:
    tuple val(meta), path(reads, stageAs: "input*/*")

    output:
    tuple val(meta), path("*.merged.fastq.gz"), emit: reads
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def readList = reads instanceof List ? reads.collect{ it.toString() } : [reads.toString()]
    if (meta.single_end) {
        if (readList.size >= 1) {
            """
            cat ${readList.join(' ')} > ${prefix}.merged.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                cat: \$(echo \$(cat --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
            END_VERSIONS
            """
        }
    } else {
        if (readList.size >= 2) {
            def read1 = []
            def read2 = []
            readList.eachWithIndex{ v, ix -> ( ix & 1 ? read2 : read1 ) << v }
            """
            cat ${read1.join(' ')} > ${prefix}_1.merged.fastq.gz
            cat ${read2.join(' ')} > ${prefix}_2.merged.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                cat: \$(echo \$(cat --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
            END_VERSIONS
            """
        }
    }

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def readList = reads instanceof List ? reads.collect{ it.toString() } : [reads.toString()]
    if (meta.single_end) {
        if (readList.size > 1) {
            """
            touch ${prefix}.merged.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                cat: \$(echo \$(cat --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
            END_VERSIONS
            """
        }
    } else {
        if (readList.size > 2) {
            """
            touch ${prefix}_1.merged.fastq.gz
            touch ${prefix}_2.merged.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                cat: \$(echo \$(cat --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
            END_VERSIONS
            """
        }
    }

}
