process build {
    label "kraken"
    publishDir "${params.output}/kraken", mode: "copy"
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
        cp "${nucl_gb}" "${nucl_wgs}" "${nodes}" "${names}" \
            "${db}/taxonomy/"
        gzip -f -d "${db}/taxonomy/"*.gz
        kraken-build --add-to-library "${genomic}" --db "${db}"
        kraken-build --threads "${task.cpus}" --build --db "${db}"
        kraken-build --clean --db "${db}"
        """
}

process Run {
    label "kraken"
    publishDir "${params.output}/kraken", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("kraken*.txt")
    script:
        """
        kraken --db "${db}/kraken/refseq_bav" --output "kraken_${id}.txt" \
            --fastq-input --threads "${task.cpus}" \
            --paired "${reads}"
        kraken-report --db "${db}/kraken/refseq_bav" "kraken_${id}.txt" \
            > "kraken_${id}_report.txt"
        """
}