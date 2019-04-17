#!/usr/bin/env nextflow

params.genomic = "db/genomic"
params.protein = "db/protein"

params.db = "refseq_bav"

process kraken {
    publishDir "db/kraken", mode: "copy"

    input:
        val(db) from val(params.db)
        file(genomes) from file(params.genomic)

    output:
        file("${db}") into kraken_refseq_bav

    script:
        """
        kraken-build --download-taxonomy --db "${db}"
        find "${genomes}" -name '*.fna.gz' -print0 |\
            xargs -0 -I{} -n1 kraken-build --add-to-library {} --db "${db}"
        kraken-build --build --db "${db}"
        kraken-build --clean --db "${db}"
        """
}