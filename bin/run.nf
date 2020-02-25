#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

params.db = "../db"
params.data = "../results/reads/*_R{1,2}.fastq"
params.output = "../results/classification/raw"

include Run as run_blast from './modules/blast' params(output: params.output)
include Run as run_centrifuge from './modules/centrifuge' params(output: params.output)
include Run as run_diamond from './modules/diamond' params(output: params.output)
include Run as run_kaiju from './modules/kaiju' params(output: params.output)
include Run as run_kraken from './modules/kraken' params(output: params.output)
include Run as run_kraken2 from './modules/kraken2' params(output: params.output)
// include Run as run_kslam from './modules/kslam' params(output: params.output)
// include Run as run_mmseqs2 from './modules/mmseqs2' params(output: params.output)
// include Run as run_paladin from './modules/paladin' params(output: params.output)
// include Run as run_rapsearch from './modules/rapsearch' params(output: params.output)
// include Run as run_sourmash from './modules/sourmash' params(output: params.output)


Channel
    .fromFilePairs(params.data)
    .dump()
    .set{reads}

workflow {
    db = file(params.db)

    run_blast(db, reads)
    run_centrifuge(db, reads)
    run_diamond(db, reads)
    run_kaiju(db, reads)
    run_kraken(db, reads)
    run_kraken2(db, reads)
    // run_kslam(db, reads)
    // run_mmseqs2(db, reads)
    // run_paladin(db, reads)
    // run_rapsearch(db, reads)
    // run_sourmash(db, reads)
}
