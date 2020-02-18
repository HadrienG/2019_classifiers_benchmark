process build {
publishDir "${params.output}/sourmash", mode: "copy"

    input:
        val(db)
        file(genomic)
    
    output:
        file("${db}.fna.sig")
    
    script:
        """
        sourmash compute -p "${task.cpus}" --scaled 1000 \
            -k 31 "${genomic}" --singleton
        """
}