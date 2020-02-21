process build {
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