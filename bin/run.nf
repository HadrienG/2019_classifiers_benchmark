#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

params.db = "../db"
params.data = "../results/reads"
params.output = "../results/classification/raw"

include Run as run_blast from './modules/blast' params(output: params.output)
include Run as run_centrifuge from './modules/centrifuge' params(output: params.output)
include Run as run_diamond from './modules/diamond' params(output: params.output)
include Run as run_kaiju from './modules/kaiju' params(output: params.output)
include Run as run_kraken from './modules/kraken' params(output: params.output)
include Run as run_kraken2 from './modules/kraken2' params(output: params.output)
include Run as run_kslam from './modules/kslam' params(output: params.output)
include Run as run_mmseqs2 from './modules/mmseqs2' params(output: params.output)
include Run as run_paladin from './modules/paladin' params(output: params.output)
include Run as run_rapsearch from './modules/rapsearch' params(output: params.output)
include Run as run_sourmash from './modules/sourmash' params(output: params.output)


Channel
    .fromFilePairs( params.data + '*_{R1,R2}.fastq', size: 2, flat: true)
    .ifEmpty { error "Cannot find any reads matching: ${params.data}" }
    .set{reads}

workflow {
    run_blast(params.db, reads)
    run_centrifuge(params.db, reads)
    run_diamond(params.db, reads)
    run_kaiju(params.db, reads)
    run_kraken(params.db, reads)
    run_kraken2(params.db, reads)
    run_kslam(params.db, reads)
    run_mmseqs2(params.db, reads)
    run_paladin(params.db, reads)
    run_rapsearch(params.db, reads)
    run_sourmash(params.db, reads)
}
