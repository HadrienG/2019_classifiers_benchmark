FROM continuumio/miniconda:4.5.12

LABEL maintainer="Hadrien Gourlé <hadrien.gourle@slu.se>"
LABEL description="krakenuniq 0.5.7 docker image for https://github.com/HadrienG/2018_classifiers_benchmark"

# Install procps so that Nextflow can poll CPU usage
RUN apt-get update && apt-get install -y procps && apt-get clean -y

COPY krakenuniq.yml /
RUN conda env create -f /krakenuniq.yml && conda clean -a
ENV PATH /opt/conda/envs/krakenuniq/bin:$PATH