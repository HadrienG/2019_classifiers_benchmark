process build {
    publishDir "${params.output}/mmseqs2", mode: "copy"
    input:
        val(db)
        file(genomic)
    output:
        file("${db}")
    script:
        """
        mmseqs createdb "${genomic}" "${db}"
        """
}