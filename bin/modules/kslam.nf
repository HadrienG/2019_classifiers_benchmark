process build {
    label "kslam"
    publishDir "${params.output}/kslam", mode: "copy"
    input:
        val(db)
        file(nodes)
        file(names)
        file(genomes)
    output:
        file("taxDB")
        file("database")
    script:
        """
        gzip -d "${genomes}"/*.gbff.gz
        SLAM --parse-taxonomy "${names}" "${nodes}" --output-file taxDB
        SLAM --output-file database --parse-genbank "${genomes}"/*.gbff
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
        SLAM --db "${db}/kslam" --output-file "kslam_${id}.txt" \
            "${reads}"
        """
}