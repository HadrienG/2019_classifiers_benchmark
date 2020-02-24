process build {
    label "kaiju"
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

process Run {
    label "kaiju"
    publishDir "${params.output}/kaiju", mode: "copy"
    input:
        file(db)
        tuple val(id), file(reads)
    output:
        file("kaiju*.txt")
    script:
        """
        kaiju -t "${db}/taxonomy/nodes.dmp" -f "${db}/kaiju/refseq_bav.fmi" \
            -i "${reads[0]}" -j "${reads[1]}" -o "kaiju_${id}.txt" \
            -z "${task.cpus}"
        kaijuReport -t "${db}/taxonomy/nodes.dmp" \
            -n "${db}/taxonomy/names.dmp" -i "kaiju_${id}.txt" -r species \
            -o "kaiju_${id}_species.txt"
        kaijuReport -t "${db}/taxonomy/nodes.dmp" \
            -n "${db}/taxonomy/names.dmp" -i "kaiju_${id}.txt" -r genus \
            -o "kaiju_${id}_genera.txt"
        """
}