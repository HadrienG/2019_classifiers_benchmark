process build {
    publishDir "${params.output}/paladin", mode: "copy"
    input:
        val(db)
        file(protein_gz)
    output:
        file("${db}.*")
    script:
        """
        paladin index -r3 "${protein_gz}"
        """
}