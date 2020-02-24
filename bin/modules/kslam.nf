process build {
    label "kslam"
    publishDir "${params.output}/kslam", mode: "copy"
    input:
        val(db)
        file(nodes)
        file(names)
        file(genomes)
    output:
        file("${db}")
    script:
        """
        SLAM --parse-taxonomy "${names}" "${nodes}" --output-file taxDB
        SLAM --output-file "${db}" --parse-genbank "${genomes}"/*.gbff.gz
        """
}

process Run {
    label "kslam"
    publishDir "${params.output}/kslam", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("kslam*.txt")
    script:
        """
        SLAM --db "${db}/kslam/refseq_bav" --output-file "kslam_${id}.txt" \
            "${reads}"
        """
}