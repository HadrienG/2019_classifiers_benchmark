process build {
    label "kraken2"
    publishDir "${params.output}/kraken2", mode: "copy"
    input:
        val(db)
        file(genomic)
        file(nucl_gb)
        file(nucl_wgs)
        file(nodes)
        file(names)
    output:
        file("${db}")
    script:
        """
        mkdir -p "${db}/taxonomy" "${db}/library"
        cp "${nucl_gb}" "${nucl_wgs}" "${nodes}" "${names}" "${db}/taxonomy/"
        gzip -f -d "${db}/taxonomy/"*.gz
        kraken2-build --add-to-library "${genomic}" --db "${db}"
        kraken2-build --threads "${task.cpus}" --build --db "${db}"
        kraken2-build --clean --db "${db}"
        """
}

process run {
    label "kraken2"
    publishDir "${db}/kraken2", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("kraken2*.txt")
    script:
        """
        kraken2 --db "${db}/kraken2/refseq_bav" --output "kraken2_${id}.txt" \
            --fastq-input --threads "${task.cpus}" \
            --report "kraken2_${id}_report.txt"
            --paired "${reads}"
        """
}