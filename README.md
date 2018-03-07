# Benchmarking of taxonomy assignment software for metagenomics

# Table of Contents

* [Reduced Databases](#benchmarked-software)
* [Software tested](#software-tested)
* [Datasets](#datasets)

## Databases

As of `Tue Mar 6` There are 9655 complete bacterial genomes, 13892 viral genomes and 292 archaeal genomes available in NCBI genomes, for a total of 23839 genomes.

We'll use a fraction of this in order to render this benchmark possible.

- [ ] Agree on number of genomes to select (1000?)
- [ ] Agree on selection criteria
- [ ] Select genomes
- [ ] Build the databases for the

## Software tested

Classifier | Version | Database | Run | License
--- | --- | --- | --- | ---
Kraken | | | No | GPL3
Kaiju | | | No | GPL3
Salmon | | | No | GPL3
Diamond | | | No | BSD
Blast | | | No | GPL2
Rapsearch | | | No | GPL3

## Datasets

A number of datasets will be simulated using [InSilicoSeq](https://github.com/HadrienG/InSilicoSeq)

- [ ] Agree on the abundance of the datasets (both low and high?)
- [ ] Agree on the number of datasets (10 -> 100?)

## Benchmarking

- X iterations with datasets:
    - randomly drawn from the database
    - randomly drawn from the database **and** with genomes not present in the database
