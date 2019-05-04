workdir = $(shell pwd)

download:
	docker run -v $(workdir):/mnt/proj -it --rm hadrieng/classifiers_benchmark:0.1.0 python bin/download.py

build:
	cd bin && nextflow run build.nf -resume -with-report ../results/build.html

clean:
	rm -rf work/
	rm -rf .nextflow.log*
	cd bin && rm -rf .nextflow.log*
	cd bin && rm -rf work/

docker-build:
	cd dockerfiles && docker build -t hadrieng/classifiers_benchmark:0.1.0 -f classifiers_benchmark.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/blast:2.7.1 -f blast.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/centrifuge:1.0.4_beta -f centrifuge.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/diamond:0.9.24 -f diamond.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/kaiju:1.6.3 -f kaiju.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/kraken:1.1 -f kraken.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/kraken2:2.0.8_beta -f kraken2.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/krakenuniq:0.5.7 -f krakenuniq.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/kslam:1.0 -f kslam.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/mmseqs2:8.fac81 -f mmseqs2.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/paladin:1.4.4 -f paladin.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/rapsearch:2.24 -f rapsearch.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/salmon:0.13.1 -f salmon.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/sourmash:2.0.0 -f sourmash.Dockerfile .

docker-push:
	docker push hadrieng/classifiers_benchmark:0.1.0
	docker push hadrieng/blast:2.7.1
	docker push hadrieng/centrifuge:1.0.4_beta
	docker push hadrieng/diamond:0.9.24
	docker push hadrieng/kaiju:1.6.3
	docker push hadrieng/kraken:1.1
	docker push hadrieng/kraken2:2.0.8_beta
	docker push hadrieng/krakenuniq:0.5.7
	docker push hadrieng/kslam:1.0
	docker push hadrieng/mmseqs2:8.fac81
	docker push hadrieng/paladin:1.4.4
	docker push hadrieng/rapsearch:2.24
	docker push hadrieng/salmon:0.13.1
	docker push hadrieng/sourmash:2.0.0

docker: docker-build docker-push