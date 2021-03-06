process build {
    label "rapsearch"
    publishDir "${params.output}/rapsearch", mode: "copy"
    input:
        val(db)
        file(protein)
    output:
        file("${db}")
    script:
        """
        prerapsearch -d "${protein}" -n "${db}"
        """
}

process Run {
    label "rapsearch"
    publishDir "${params.output}/rapsearch", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("rapsearch*")
    script:
        """
        rapsearch -q "${reads[0]}" -d "${db}/rapsearch/refseq_bav" \
            -o "rapsearch_${id}_R1" -e 1.0e-5 -z "${task.cpus}"
        rapsearch -q "${reads[1]}" -d "${db}/rapsearch/refseq_bav" \
            -o "rapsearch_${id}_R2" -e 1.0e-5 -z "${task.cpus}"
        """
}