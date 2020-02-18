process build {
    publishDir "${params.output}/rapsearch", mode: "copy"
    input:
        val(db)
        file(protein)
    output:
        file("${db}")
    script:
        """
        prerapsearch -d "${protein}" -n "${db}"
        """
}