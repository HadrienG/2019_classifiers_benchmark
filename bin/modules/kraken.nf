process build {
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
        kraken-build --add-to-library "${genomic}" --db "${db}"
        kraken-build --threads "${task.cpus}" --build --db "${db}"
        kraken-build --clean --db "${db}"
        """
}