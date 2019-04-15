# Benchmarking of taxonomy assignment software for metagenomics

# Table of Contents

- [Software tested](#software-tested)
- [Reduced Databases](#benchmarked-software)
- [Datasets](#datasets)

## Software tested

| Classifier | Version    | Database built | Run | License |
| ---------- | ---------- | -------------- | --- | ------- |
| Blast      | 2.7.1      | No             | No  | GPL2    |
| Centrifuge | 1.0.4_beta | No             | No  | GPL3    |
| Diamond    | 0.9.24     | No             | No  | BSD     |
| Kaiju      | 1.6.3      | No             | No  | GPL3    |
| Kraken     | 1.1        | No             | No  | GPL3    |
| Kraken     | 2.0.7_beta | No             | No  | GPL3    |
| K-slam     | 1.0        | No             | No  | GPL3    |
| Mmseqs2    | 8.fac81    | No             | No  | GPL3    |
| Paladin    | 1.4.4      | No             | No  | MIT     |
| Rapsearch  | 2.24       | No             | No  | GPL3    |
| Salmon     | 0.13.1     | No             | No  | GPL3    |
| Sourmash   | 2.0.0      | No             | No  | BSD     |

## Databases

As of `Tue Mar 6` There are 9655 complete bacterial genomes, 13892 viral genomes and 292 archaeal genomes available in NCBI genomes, for a total of 23839 genomes.

We'll use a fraction of this in order to render this benchmark possible.

- [ ] Agree on number of genomes to select (1000?)
- [ ] Agree on selection criteria
- [ ] Select genomes
- [ ] Build the databases for the selected software

## Datasets

A number of datasets will be simulated using [InSilicoSeq](https://github.com/HadrienG/InSilicoSeq)

- [ ] Agree on the abundance of the datasets (both low and high?)
- [ ] Agree on the number of datasets (10 -> 100?)

## Benchmarking

- X iterations with datasets:
  - randomly drawn from the database
  - randomly drawn from the database **and** with genomes not present in the database
