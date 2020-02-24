process build {
    label "diamond"
    publishDir "${params.output}/diamond", mode: "copy"
    input:
        val(db)
        file(protein_gz)
        file(nodes)
        file(prot)
    output:
        file("${db}*.dmnd")       
    script:
        """
        diamond makedb -p "${task.cpus}" --in "${protein_gz}" \
            --db "${db}" --taxonmap "${prot}" --taxonnodes "${nodes}"
        """
}

process run {
    label "diamond"
    publishDir "${params.output}/diamond", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("diamond*.txt")
    script:
        """
        diamond blastx -d "${db}/diamond/refseq_bav" -q "${reads[0]}" \
            -o "diamond_${id}_R1.txt" -f 102 -p "${task.cpus}"
        diamond blastx -d "${db}/diamond/refseq_bav" -q "${reads[1]}" \
            -o "diamond_${id}_R2.txt" -f 102 -p "${task.cpus}"
        """
}