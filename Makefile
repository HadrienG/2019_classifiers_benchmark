docker-build:
	cd dockerfiles && docker build -t hadrieng/blast:2.7.1 -f blast.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/diamond:0.9.24 -f diamond.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/kaiju:1.6.3 -f kaiju.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/kraken:1.1 -f kraken.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/kraken2:2.0.7_beta -f kraken2.Dockerfile .

docker-push:
	docker push hadrieng/blast:2.7.1
	docker push hadrieng/diamond:0.9.24
	docker push hadrieng/kaiju:1.6.3
	docker push hadrieng/kraken:1.1
	docker push hadrieng/kraken2:2.0.7_beta

docker: docker-build docker-push