# Benchmarking of taxonomy assignment software for metagenomics

# Table of Contents

- [Software tested](#software-tested)
- [Databases](#databases)
- [Datasets](#datasets)
- [Benchmarking](#benchmarking)

## Software tested

| Classifier | Version    | Database built | Run | License |
| ---------- | ---------- | -------------- | --- | ------- |
| Blast      | 2.7.1      | No             | No  | GPL2    |
| Centrifuge | 1.0.4_beta | No             | No  | GPL3    |
| Diamond    | 0.9.24     | No             | No  | BSD     |
| Kaiju      | 1.6.3      | No             | No  | GPL3    |
| Kraken     | 1.1        | No             | No  | GPL3    |
| Kraken     | 2.0.7_beta | No             | No  | GPL3    |
| Krakenuniq | 0.5.7      | No             | No  | GPL3    |
| K-slam     | 1.0        | No             | No  | GPL3    |
| Mmseqs2    | 8.fac81    | No             | No  | GPL3    |
| Paladin    | 1.4.4      | No             | No  | MIT     |
| Rapsearch  | 2.24       | No             | No  | GPL3    |
| Salmon     | 0.13.1     | No\*           | No  | GPL3    |
| Sourmash   | 2.0.0      | No             | No  | BSD     |

All the software have their docker image, using the same base and installed via `conda`

## Databases

### Download

As of `2019-04-16` There are 13193 complete bacterial genomes, 8583 viral genomes and 283 archaeal genomes available in RefSeq complete genomes, for a total of 16877 genomes.

To download refseq, use `make download`, which will placed in the `db` directory

A summary, `assemblies.csv` will also be created with the columns "taxid", "species_taxid", "accession" and "organism_name"

### Build

To build the databases, use `make build`.
The databases are in `db/$software_name`

## Datasets

The following datasets are simulated using [InSilicoSeq](https://github.com/HadrienG/InSilicoSeq)

| Abundance | Platform       | N datasets | N reads |
| --------- | -------------- | ---------- | ------- |
| 10        | MiSeq, Novaseq | 5          | 5M      |
| 50        | MiSeq, Novaseq | 5          | 5M      |
| 200       | MiSeq, Novaseq | 5          | 5M      |

for a total of 30 datasets.
Genomes in theses datasets were selected at random from refseq.

## Benchmarking

- X iterations with datasets:
  - randomly drawn from the database
  - randomly drawn from the database **and** with genomes not present in the database
