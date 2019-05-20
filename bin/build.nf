#!/usr/bin/env nextflow

params.genomic = "../db/genomic"
params.protein = "../db/protein"
params.genbank = "../db/genbank"

params.db = "refseq_bav"

process taxonomy {
    publishDir "../db/taxonomy", mode: "copy"

    output:
        file("taxadb/names.dmp") into names
        file("taxadb/nodes.dmp") into nodes
        file("taxadb/nucl_gb.accession2taxid.gz") into nucl_gb
        file("taxadb/nucl_wgs.accession2taxid.gz") into nucl_wgs
        file("taxadb/prot.accession2taxid.gz") into prot
        // file("taxadb.sqlite") into taxadb
    
    script:
        """
        taxadb download -t full -f -o taxadb
        taxadb create --fast -i taxadb -n taxadb.sqlite
        """
}

process decompress {
    input:
        val(db) from params.db
        file(genomes) from file(params.genomic)
        file(proteins) from file(params.protein)

    output:
        file("${db}.fna.gz") into genomic_gz
        file("${db}.fna") into genomic
        file("${db}.faa.gz") into protein_gz
        file("${db}.faa") into protein
    
    script:
        """
        cat "${genomes}"/*.fna.gz > "${db}.fna.gz"
        gzip -dc "${db}.fna.gz" > "${db}.fna"
        cat "${proteins}"/*.faa.gz > "${db}.faa.gz"
        gzip -dc "${db}.faa.gz" > "${db}.faa"
        """
}

process blast {
    publishDir "../db/blast", mode: "copy"

    input:
        val(db) from params.db
        file(genomic)
    
    output:
        file("${db}.n*") into blast_refseq_bav
    
    script:
        """
        makeblastdb -in "${genomic}" -dbtype nucl -out "${db}"
        """
}

process centrifuge {
    publishDir "../db/centrifuge", mode: "copy"

    input:
        val(db) from params.db
        file(genomic)
        file(nucl) from nucl_gb
        file(nodes) from nodes
        file(names) from names
    
    output:
        file("${db}*.cf") into centrifuge_refseq_bav
    
    script:
        """
        gzip -f -d "${nucl}"
        centrifuge-build -p "${task.cpus}" --conversion-table nucl_gb.accession2taxid \
            --taxonomy-tree "${nodes}" --name-table "${names}" \
            "${genomic}" "${db}"
        """
}

process diamond {
    publishDir "../db/diamond", mode: "copy"

    input:
        val(db) from params.db
        file(protein_gz)
        file(nodes) from nodes
        file(prot) from prot
    
    output:
        file("${db}*.dmnd") into diamond_refseq_bav        
    
    script:
        """
        diamond makedb -p "${task.cpus}" --in "${protein_gz}" \
            --db "${db}" --taxonmap "${prot}" --taxonnodes "${nodes}"
        """
}

process kaiju {
    publishDir "../db/kaiju", mode: "copy"

    input:
        val(db) from params.db
        file(protein)
        file(prot) from prot
        file(nodes) from nodes

    
    output:
        file("${db}*.fmi") into kaiju_refseq_bav    
    
    script:
        """
        gzip -f -d "${prot}"
        convertNR -t "${nodes}" -g prot.accession2taxid \
            -i "${protein}" -a -o proteins.fasta
        mkbwt -n "${task.cpus}" -a ACDEFGHIKLMNPQRSTVWY -o ${db} proteins.faa
        mkfmi ${db}
        """
}

process kraken {
    publishDir "../db/kraken", mode: "copy"

    input:
    val(db) from params.db
    file(genomic)
    file(nucl_gb) from nucl_gb
    file(nucl_wgs) from nucl_wgs
    file(nodes) from nodes
    file(names) from names

    output:
    file("${db}") into kraken_refseq_bav

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

process kraken2 {
    publishDir "../db/kraken2", mode: "copy"

    input:
    val(db) from params.db
    file(genomic)
    file(nucl_gb) from nucl_gb
    file(nucl_wgs) from nucl_wgs
    file(nodes) from nodes
    file(names) from names

    output:
    file("${db}") into kraken2_refseq_bav

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

process kslam {
    publishDir "../db/kslam", mode: "copy"

    input:
        val(db) from params.db
        file(nodes) from nodes
        file(names) from names
        file(genomes) from file(params.genbank)

    output:
        file("${db}") into kslam_refseq_bav

    script:
        """
        SLAM --parse-taxonomy "${names}" "${nodes}" --output-file taxDB
        SLAM --output-file "${db}" --parse-genbank "${genomes}"/*.gbff.gz
        """
}

process mmseqs2 {
    publishDir "../db/mmseqs2", mode: "copy"

    input:
        val(db) from params.db
        file(genomic)
    
    output:
        file("${db}") into mmseqs2_refseq_bav
    
    script:
        """
        mmseqs createdb "${genomic}" "${db}"
        """
}

process paladin {
    publishDir "../db/paladin", mode: "copy"

    input:
        val(db) from params.db
        file(protein_gz)
    
    output:
        file("${db}.*") into paladin_refseq_bav

    script:
        """
        paladin index -r3 "${protein_gz}"
        """
}

process rapsearch {
    publishDir "../db/rapsearch", mode: "copy"

    input:
        val(db) from params.db
        file(protein)
    
    output:
        file("${db}") into rapsearch_refseq_bav
    
    script:
        """
        prerapsearch -d "${protein}" -n "${db}"
        """
}

process salmon {
publishDir "../db/salmon", mode: "copy"

    input:
        val(db) from params.db
        file(genomic)
    
    output:
        file("${db}") into salmon_refseq_bav
    
    script:
        """
        salmon index -p "${task.cpus}" -t ${genomic} -i "${db}"
        """
}

process sourmash {
publishDir "../db/sourmash", mode: "copy"

    input:
        val(db) from params.db
        file(genomic)
    
    output:
        file("${db}.fna.sig") into sourmash_refseq_bav
    
    script:
        """
        sourmash compute -p "${task.cpus}" --scaled 1000 \
            -k 31 "${genomic}" --singleton
        """
}