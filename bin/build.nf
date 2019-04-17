#!/usr/bin/env nextflow

params.genomic = "../db/genomic"
params.protein = "../db/protein"

params.db = "refseq_bav"

process blast {
    publishDir "../db/blast", mode: "copy"

    input:
        val(db) from params.db
        file(genomes) from file(params.genomic)
    
    output:
        file("${db}.n*") into blast_refseq_bav
    
    script:
        """
        cat "${genomes}"/*.fna.gz > "${db}".fna.gz
        gzip -d "${db}".fna.gz
        makeblastdb -in "${db}".fna -dbtype nucl -out "${db}"
        """
}

// waiting for the NCBI taxonomy
// process kraken {
//     publishDir "../db/kraken", mode: "copy"

//     input:
//     val(db) from params.db
//     file(genomes) from file(params.genomic)

//     output:
//     file("${db}") into kraken_refseq_bav

//     script:
//     """
//     kraken-build --download-taxonomy --db "${db}"
//     find "${genomes}" -name '*.fna.gz' -print0 |\
//         xargs -0 -I{} -n1 kraken-build --add-to-library {} --db "${db}"
//     kraken-build --build --db "${db}"
//     kraken-build --clean --db "${db}"
//     """
// }

