process taxonomy {
    publishDir "${params.output}/taxonomy", mode: "copy"
    output:
        file("taxadb/names.dmp"), emit: names
        file("taxadb/nodes.dmp"), emit: nodes
        file("taxadb/nucl_gb.accession2taxid.gz"), emit: nucl_gb
        file("taxadb/nucl_wgs.accession2taxid.gz"), emit: nucl_wgs
        file("taxadb/prot.accession2taxid.gz"), emit: prot
        file("taxadb.sqlite"), emit: taxadb
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
        file("${db}.fna.gz"), emit: genomic_gz
        file("${db}.fna"), emit: genomic
        file("${db}.faa.gz"), emit: protein_gz
        file("${db}.faa"), emit: protein
    script:
        """
        cat "${genomes}"/*.fna.gz > "${db}.fna.gz"
        gzip -dc "${db}.fna.gz" > "${db}.fna"
        cat "${proteins}"/*.faa.gz > "${db}.faa.gz"
        gzip -dc "${db}.faa.gz" > "${db}.faa"
        """
}