process taxonomy {
    publishDir "${params.output}/taxonomy", mode: "copy"
    output:
        path("taxadb/names.dmp", emit: names)
        path("taxadb/nodes.dmp", emit: nodes)
        path("taxadb/nucl_gb.accession2taxid.gz", emit: nucl_gb)
        path("taxadb/nucl_wgs.accession2taxid.gz", emit: nucl_wgs)
        path("taxadb/prot.accession2taxid.gz", emit: prot)
        path("taxadb.sqlite", emit: taxadb)
    script:
        """
        taxadb download -t full -f -o taxadb
        taxadb create --fast -i taxadb -n taxadb.sqlite
        """
}

process decompress {
    input:
        val(db)
        file(genomes)
        file(proteins)
    output:
        path("${db}.fna.gz", emit: genomic_gz)
        path("${db}.fna", emit: genomic)
        path("${db}.faa.gz", emit: protein_gz)
        path("${db}.faa", emit: protein)
    script:
        """
        cat "${genomes}"/*.fna.gz > "${db}.fna.gz"
        gzip -dc "${db}.fna.gz" > "${db}.fna"
        cat "${proteins}"/*.faa.gz > "${db}.faa.gz"
        gzip -dc "${db}.faa.gz" > "${db}.faa"
        """
}