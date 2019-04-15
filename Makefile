docker-build:
	cd dockerfiles && docker build -t hadrieng/blast:2.7.1 -f blast.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/diamond:0.9.24 -f diamond.Dockerfile .
	cd dockerfiles && docker build -t hadrieng/kaiju:1.6.3 -f kaiju.Dockerfile .

docker-push:
	docker push hadrieng/blast:2.7.1
	docker push hadrieng/diamond:0.9.24
	docker push hadrieng/kaiju:1.6.3

docker: docker-build docker-push