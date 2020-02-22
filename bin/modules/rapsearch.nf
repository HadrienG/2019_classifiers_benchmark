process build {
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

process run {
    publishDir "${params.output}/rapsearch", mode: "copy"
    input:
        tuple val(id), file(reads)
    output:
        file("*.txt")
    script:
        """
        rapsearch -q "${reads[0]}" -d "${db}/rapsearch/refseq_bav" \
            -o "rapsearch_${id}_R1.txt" -e 1.0e-5 -z "${task.cpus}"
        rapsearch -q "${reads[1]}" -d "${db}/rapsearch/refseq_bav" \
            -o "rapsearch_${id}_R2.txt" -e 1.0e-5 -z "${task.cpus}"
        """
}