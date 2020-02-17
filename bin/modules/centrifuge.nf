process build {
    publishDir "${params.output}/centrifuge", mode: "copy"
    input:
        val(db)
        file(genomic)
        file(nucl)
        file(nodes)
        file(names)
    output:
        file("${db}*.cf")
    script:
        """
        gzip -f -d "${nucl}"
        centrifuge-build -p "${task.cpus}" --conversion-table nucl_gb.accession2taxid \
            --taxonomy-tree "${nodes}" --name-table "${names}" \
            "${genomic}" "${db}"
        """
}