# class_validation
## Benchmarking of metagenomic classifiers

### Table of Contents

* [Simulating Data](#simulating-data)
* [Classifiers Used](#classifiers)
* [Databases](#databases)

### Simulating Data

*TODO*

### Classifiers

Classifier | Version | Database / Index | Run | License
--- | --- | --- | --- | ---
Kraken | 0.10.5-beta | Built (used 483G RAM) | No | GPL3
Kaiju | 63cc2ce* | Built (used 194G RAM) | No | GPL3
Salmon | 0.7.2 | In progress | No | GPL3
Diamond | 0.7.10.59 | Built | No | BSD
Blast | 2.5.0 | Built | No | GPL2
Rapsearch | 2.22 | Built | No | GPL3

* 1.4.3 available 19th of October. The new version should be used

### Databases

refseq bacteria - archea - viruses
https://www.ncbi.nlm.nih.gov/genome/doc/ftpfaq/#protocols

release 78

```
rsync --copy-links --recursive --times --verbose rsync://ftp.ncbi.nlm.nih.gov/refseq/release/bacteria/ bacteria/

rsync --copy-links --recursive --times --verbose rsync://ftp.ncbi.nlm.nih.gov/refseq/release/archaea/ archaea/

rsync --copy-links --recursive --times --verbose rsync://ftp.ncbi.nlm.nih.gov/refseq/release/viral/ viral/

zcat */*.genomic.fna.gz > refseq_78_bav.fna

find ./refseq_78_bav/ -name "*.gbff.gz" | xargs -n 1 -P 5 -i /opt/sw/kaiju/63cc2ce/bin/gbk2faa.pl '{}' '{}'.faa
cat refseq_78_bav/*.gz.faa > refseq_78_bav.faa
```

#### kaiju

```
/opt/sw/kaiju/63cc2ce/bin/mkbwt -n 5 -e 3 -a ACDEFGHIKLMNPQRSTVWY -o kaiju refseq_78_bav.faa
```

#### salmon

```
salmon index -t refseq_78_bav.fna -i salmon
```

#### kraken

```
kraken-build --download-taxonomy --db kraken
kraken-build --add-to-library ../refseq_78_bav.fna --db kraken
kraken-build --build --db kraken --jellyfish-hash-size 3032887480
```

#### diamond

```
diamond makedb --in ../refseq_78_bav.faa -d diamond
```

#### blast

```
makeblastdb -dbtype prot -in ../refseq_78_bav.faa -title blast_protein -out blast_protein
makeblastdb -dbtype nucl -in ../refseq_78_bav.fna -title blast_nucleotide -out blast_nucleotide
```

#### rapsearch

```
prerapsearch -d ../refseq_78_bav.fna -n rapsearch
```
