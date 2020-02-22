process build {
    publishDir "${params.output}/paladin", mode: "copy"
    input:
        val(db)
        file(protein_gz)
    output:
        file("${db}.*")
    script:
        """
        paladin index -r3 "${protein_gz}"
        """
}

process run {
    publishDir "${params.output}/paladin", mode: "copy"
    input:
        tuple val(id), file(reads)
    output:
        file("paladin*.tsv")
    script:
        """
        paladin align -f 100 -t "${task.cpus}" -o "paladin_${id}_R1" \
            ../db/paladin/refseq_bav "${reads[0]}"
        paladin align -f 100 -t "${task.cpus}" -o "paladin_${id}_R2" \
            ../db/paladin/refseq_bav "${reads[1]}"
        """
}