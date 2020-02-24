process build {
    label "blast"
    publishDir "${params.output}/blast", mode: "copy"
    input:
        val(db)
        file(genomic)
    output:
        file("${db}.n*")
    script:
        """
        makeblastdb -in "${genomic}" -dbtype nucl -out "${db}"
        """
}

process run {
    label "blast"
    publishDir "${params.output}/blast", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("blast*.txt")
    script:
        """
        blastn -db "${db}/blast/refseq_bav" -evalue 1.0e-5 \
            -out "blast_${id}_R1.txt" -query "${reads[0]}" -outfmt 6 \
            -num_threads "${task.cpus}"
        blastn -db "${db}/blast/refseq_bav" -evalue 1.0e-5 \
            -out "blast_${id}_R2.txt" -query "${reads[1]}" -outfmt 6 \
            -num_threads "${task.cpus}"
        """
}