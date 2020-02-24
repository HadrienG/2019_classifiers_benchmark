process build {
    label "mmseqs2"
    publishDir "${params.output}/mmseqs2", mode: "copy"
    input:
        val(db)
        file(genomic)
    output:
        file("${db}")
    script:
        """
        mmseqs createdb "${genomic}" "${db}"
        """
}

process Run {
    label "mmseqs2"
    publishDir "${params.output}/mmseqs2", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("mmseqs2*.txt") into mmseqs2_output
    script:
        """
        mkdir tmp1
        mmseqs easy-search "${reads[0]}" "${db}/mmseqs2/refseq_bav" \
            "mmseqs2_${id}_R1.txt" tmp1 --search-type 3 --threads "${task.cpus}"
        mkdir tmp2
        mmseqs easy-search "${reads[1]}" "${db}/mmseqs2/refseq_bav" \
            "mmseqs2_${id}_R2.txt" tmp2 --search-type 3 --threads "${task.cpus}"
        """
}