process build {
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