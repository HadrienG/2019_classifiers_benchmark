process build {
    publishDir "${params.output}/blast", mode: "copy"
    input:
        val(db)
        file(genomic)
    output:
        file("${db}.n*")
    script:
        """
        makeblastdb -in "${genomic}" -dbtype nucl -out "${db}"
        """
}

// process run {
//  // unimplemented
// }