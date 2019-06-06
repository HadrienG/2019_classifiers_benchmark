#!/usr/bin/env nextflow

abundance = Channel.from( 10, 50, 200 )
platform = Channel.from ( "miseq", "novaseq" )
iteration = Channel.from ( 1, 2, 3, 4, 5 )

params.genomic = "../db/genomic"

process create_datasets {
    publishDir "../results/reads", mode: "copy"

    input:
        file(genomes) from file(params.genomic)
        val abundance
        val iteration
    output:
        set val(iteration), val(abundance), file("genomes_${n}.fna.gz") into genome_files

    script:
        """
        python3 /repo/bin/select_genomes.py -n "${abundance}" --seed "${iteration}" \
            --genomes "${genomes}" --output "${abundance}_${iteration}.fna.gz"
        """
}

process simulate_datasets {
    publishDir "../results/reads", mode: "copy"

    input:
        val platform
        set val(iteration), val(abundance), file(genomes) from genome_files

    output:
        file("*.fastq") into reads

    script:
        """
        iss generate --cpus "${task.cpus}" --model "${platform}" \
            --genomes "${genomes}" -n 5M \
            --output "${platform}_${abundance}_${iteration}"
        """
}