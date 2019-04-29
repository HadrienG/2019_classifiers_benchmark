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
        file("taxadb/prot.accession2taxid.gz") into prot
        file("taxadb.sqlite") into taxadb
    
    script:
    """
    taxadb download -f -o taxadb
    # don't need the db right away.
    # taxadb create --fast -i taxadb -n taxadb.sqlite
    """
}

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

process centrifuge {
    publishDir "../db/centrifuge", mode: "copy"

    input:
        val(db) from params.db
        file(genomes) from file(params.genomic)
        file(nucl) from nucl_gb
    
    output:
        file("${db}*.cf") into centrifuge_refseq_bav
    
    script:
        """
        cat "${genomes}"/*.fna.gz > "${db}".fna.gz
        gzip -d "${db}".fna.gz
        centrifuge-download -o taxonomy taxonomy
        gzip -d "${nucl}"
        centrifuge-build -p "${task.cpus}" --conversion-table nucl_gb.accession2taxid \
            --taxonomy-tree taxonomy/nodes.dmp --name-table taxonomy/names.dmp \
            "${db}".fna "${db}"
        """
}

process diamond {
    publishDir "../db/diamond", mode: "copy"

    input:
        val(db) from params.db
        file(proteins) from file(params.protein)
        file(nodes) from nodes
        file(names) from names
        file(prot) from prot_gb
    
    output:
        file("${db}*.dmnd") into diamond_refseq_bav
        file("prot.accession2taxid.gz") into prot_gb
        
    
    script:
        """
        cat "${proteins}"/*.faa.gz > "${db}".faa.gz
        diamond makedb -p "${task.cpus}" --in "${db}".faa.gz --db "${db}" \
            --taxonmap "${prot}" --taxonnodes "${names}" "${nodes}"
        """
}

// need more MEM, might need to skipping for tests
process kaiju {
    publishDir "../db/kaiju", mode: "copy"

    input:
        val(db) from params.db
        file(proteins) from file(params.protein)
        file(nucl_gb) from nucl_gb
        file(nodes) from nodes

    
    output:
        file("${db}*.fmi") into kaiju_refseq_bav    
    
    script:
        """
        zcat "${proteins}"/*.faa.gz > proteins.faa
        convertNR -t "${nodes}" -g "${nucl_gb}" -i proteins.faa \
            -a -o proteins.fasta
        mkbwt -n "${task.cpus}" -a ACDEFGHIKLMNPQRSTVWY -o ${db} proteins.faa
        mkfmi ${db}
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
//     kraken-build --threads "${task.cpus}" --build --db "${db}"
//     kraken-build --clean --db "${db}"
//     """
// }

// waiting for the NCBI taxonomy
// process kraken2 {
//     publishDir "../db/kraken2", mode: "copy"

//     input:
//     val(db) from params.db
//     file(genomes) from file(params.genomic)

//     output:
//     file("${db}") into kraken2_refseq_bav

//     script:
//     """
//     kraken2-build --download-taxonomy --db "${db}"
//     find "${genomes}" -name '*.fna.gz' -print0 |\
//         xargs -0 -I{} -n1 kraken-build --add-to-library {} --db "${db}"
//     kraken2-build --threads "${task.cpus}" --build --db "${db}"
//     kraken2-build --clean --db "${db}"
//     """
// }

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
        SLAM --output-file "${db}" --parse-genbank "${genbank}/*.gbff.gz"
        """
}

process mmseqs2 {
    publishDir "../db/mmseqs2", mode: "copy"

    input:
        val(db) from params.db
        file(genomes) from file(params.genomic)
    
    output:
        file("${db}") into mmseqs2_refseq_bav
    
    script:
        """
        zcat "${genomes}"/*.fna.gz > genomes.fna
        mmseqs createdb genomes.fna "${db}"
        """
}

process paladin {
    publishDir "../db/paladin", mode: "copy"

    input:
        val(db) from params.db
        file(proteins) from file(params.protein)
    
    output:
        file("${db}*.dmnd") into paladin_refseq_bav

    script:
        """
        cat "${proteins}"/*.faa.gz > "${db}".faa.gz
        paladin index "${db}".faa.gz
        """
}

process rapsearch {
    publishDir "../db/rapsearch", mode: "copy"

    input:
        val(db) from params.db
        file(proteins) from file(params.protein)
    
    output:
        file("${db}") into rapsearch_refseq_bav
    
    script:
        """
        zcat "${proteins}"/*.faa.gz > "${db}".faa
        prerapsearch -d "${db}".faa -n "${db}"
        """
}

process salmon {
publishDir "../db/salmon", mode: "copy"

    input:
        val(db) from params.db
        file(genomes) from file(params.genomic)
    
    output:
        file("${db}") into salmon_refseq_bav
    
    script:
        """
        zcat "${genomes}"/*.fna.gz > genomes.fna
        salmon index -p "${task.cpus}" -t genomes.fna -i "${db}"
        """
}

process sourmash {
publishDir "../db/sourmash", mode: "copy"

    input:
        val(db) from params.db
        file(genomes) from file(params.genomic)
    
    output:
        file("${db}") into sourmash_refseq_bav
    
    script:
        """
        zcat "${genomes}"/*.fna.gz > genomes.fna
        sourmash compute -p "${task.cpus}" --scaled 1000 \
            -k 31 genomes.fna --singleton
        mv genomes.fna.sig "${db}"
        """
}