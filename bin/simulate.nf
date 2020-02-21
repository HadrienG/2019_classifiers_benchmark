#!/usr/bin/env nextflow

abundance = Channel.from( 10, 50, 200 )
platform = Channel.from ( "miseq", "novaseq" )
iteration = Channel.from ( 1, 2, 3, 4, 5 )

combinations = abundance
    .combine(iteration)

params.genomic = "../db/genomic"

process create_datasets {
    publishDir "../results/reads", mode: "copy"

    input:
        file(genomes) from file(params.genomic)
        set val(abundance), val(iteration) from combinations
    output:
        set val(iteration), val(abundance), file("${abundance}_${iteration}.fna") into genome_files

    script:
        """
        python3 /repo/bin/select_genomes.py -n "${abundance}" --seed "${iteration}" \
            --genomes "${genomes}" --output "${abundance}_${iteration}.fna.gz"
        gzip -dc "${abundance}_${iteration}.fna.gz" > "${abundance}_${iteration}.fna"
        """
}

datasets = genome_files
    .combine(platform)

process simulate_datasets {
    publishDir "../results/reads", mode: "copy"

    input:
        set val(iteration), val(abundance), file(genomes), val(platform) from datasets

    output:
        file("*.fastq") into reads

    script:
        """
        iss generate --cpus "${task.cpus}" --model "${platform}" \
            --genomes "${genomes}" -n 5M \
            --output "${platform}_${abundance}_${iteration}"
        """
}