process build {
    publishDir "${params.output}/kaiju", mode: "copy"
    input:
        val(db)
        file(protein)
        file(prot)
        file(nodes)
    output:
        file("${db}*.fmi")
    script:
        """
        gzip -f -d "${prot}"
        convertNR -t "${nodes}" -g prot.accession2taxid \
            -i "${protein}" -a -o proteins.fasta
        mkbwt -n "${task.cpus}" -a ACDEFGHIKLMNPQRSTVWY -o ${db} proteins.fasta
        mkfmi ${db}
        """
}