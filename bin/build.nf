#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

params.genomic = "../db/genomic"
params.protein = "../db/protein"
params.genbank = "../db/genbank"

params.db = "refseq_bav"
params.output = "../db"

include taxonomy from './modules/taxonomy' params(output: params.output)
include decompress from './modules/taxonomy'

include build as build_blast from './modules/blast' params(output: params.output)
include build as build_centrifuge from './modules/centrifuge' params(output: params.output)
include build as build_diamond from './modules/diamond' params(output: params.output)
include build as build_kaiju from './modules/kaiju' params(output: params.output)
include build as build_kraken from './modules/kraken' params(output: params.output)
include build as build_kraken2 from './modules/kraken2' params(output: params.output)
include build as build_kslam from './modules/kslam' params(output: params.output)
include build as build_mmseqs2 from './modules/mmseqs2' params(output: params.output)
include build as build_paladin from './modules/paladin' params(output: params.output)
include build as build_rapsearch from './modules/rapsearch' params(output: params.output)
include build as build_sourmash from './modules/sourmash' params(output: params.output)

worklow {
    taxonomy()
    decompress(params.db, params.genomic, params.protein)

    names = taxonomy.out.names
    nodes = taxonomy.out.nodes
    nucl_gb = taxonomy.out.nucl_gb
    nucl_wgs = taxonomy.out.nucl_wgs
    prot = taxonomy.out.prot

    genbank = file(params.genbank)
    genomic = decompress.out.genomic
    protein = decompress.out.protein
    protein_gz = decompress.out.protein_gz

    build_blast(params.db, genomic)
    build_centrifuge(params.db, genomic, nuclt_gb, nodes, names)
    build_diamond(params.db, protein_gz, nodes, prot)
    build_kaiju(params.db, protein, prot, nodes)
    build_kraken(params.db, genomic, nucl_gb, nucl_wgs, nodes, names)
    build_kraken2(params.db, genomic, nucl_gb, nucl_wgs, nodes, names)
    build_kslam(params.db, nodes, names, genbank)
    build_mmseqs2(params.db, genomic)
    build_paladin(params.db, protein_gz)
    build_rapsearch(params.db, protein)
    build_sourmash(params.db, genomic)
}