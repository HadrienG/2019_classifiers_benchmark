process build {
    publishDir "${params.output}/diamond", mode: "copy"
    input:
        val(db)
        file(protein_gz)
        file(nodes)
        file(prot)
    output:
        file("${db}*.dmnd")       
    script:
        """
        diamond makedb -p "${task.cpus}" --in "${protein_gz}" \
            --db "${db}" --taxonmap "${prot}" --taxonnodes "${nodes}"
        """
}