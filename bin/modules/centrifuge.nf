process build {
    label "centrifuge"
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

process run {
    label "centrifuge"
    publishDir "${params.output}/centrifuge", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("centrifuge_*.txt")
    script:
        """
        centrifuge -x "${db}centrifuge/refseq_bav" -1 "${reads[0]}" \
             -2 "${reads[1]}" --report-file "centrifuge_${id}_report.txt" \
             -S "centrifuge_${id}.txt" -p "${task.cpus}"
        """
}