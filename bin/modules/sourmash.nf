process build {
    label "sourmash"
    publishDir "${params.output}/sourmash", mode: "copy"
    input:
        val(db)
        file(genomic)
    output:
        file("${db}.fna.sig")
    script:
        """
        sourmash compute -p "${task.cpus}" --scaled 1000 \
            -k 31 "${genomic}" --singleton
        """
}

process Run {
    label "sourmash"
    publishDir "${params.output}/sourmash", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("sourmash*.txt")
    script:
        """
        sourmash compute -p "${task.cpus}" --scaled 1000 \
            -k 31 ${reads} --merge "${id}" -o "${id}_reads.sig"
        sourmash lca classify --db "${db}/sourmash/refseq_bav" \
        --query "${id}_reads.sig" -o "sourmash_${id}.txt"
        sourmash lca summarize --db "${db}/sourmash/refseq_bav" \
        --query "${id}_reads.sig" -o "sourmash_${id}_sum.txt"
        """
}