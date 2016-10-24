# class_validation
## Benchmarking of metagenomic classifiers

#### Classifiers:

Classifier | Database / index | Run
--- | --- | ---
Kraken | Waiting for c4 |
Kaiju | Built (used 194G RAM) |
Salmon | In progress |
Diamond | |
Blast | |

#### Databases:

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

##### kaiju

```
/opt/sw/kaiju/63cc2ce/bin/mkbwt -n 5 -e 3 -a ACDEFGHIKLMNPQRSTVWY -o kaiju_db refseq_78_bav.faa
```

##### salmon
```
salmon index -t refseq_78_bav.fna -i salmon
```

##### kraken
Ram problem. We might want to lower the hash size for jellyfish.
We'll still need ~461G of RAM to put the k-mers in memory

```
kraken-build --download-taxonomy --db kraken
kraken-build --add-to-library ../refseq_78_bav.fna --db kraken
kraken-build --build --db kraken
```
