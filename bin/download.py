#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import csv
import sys
import logging

import requests


def download(url, output_file, chunk_size=1024, append=False):
    """download an url
    """
    if url.startswith("ftp://"):  # requests doesnt support ftp
        url = url.replace("ftp://", "https://")
    if url:
        request = requests.get(url, stream=True)

    mode = "ab" if append is True else "wb"
    with open(output_file, mode) as f:
        for chunk in request.iter_content(chunk_size=chunk_size):
            if chunk:
                f.write(chunk)
                f.flush()


def listing():
    """download assembly lists for bacteria, archaea anv viruses
    """
    logger = logging.getLogger(__name__)

    refseq = "https://ftp.ncbi.nlm.nih.gov/genomes/refseq"

    bac = "bacteria/assembly_summary.txt"
    arc = "archaea/assembly_summary.txt"
    vir = "viral/assembly_summary.txt"
    summaries = [bac, arc, vir]

    output_file = "db/assembly_summaries.txt"
    try:
        assert os.path.exists(output_file) is False
    except AssertionError as e:
        logger.warning(f"{output_file} already exists.")
        logger.warning("Skipping Listing...")
        return output_file

    for summary in summaries:
        url = f"{refseq}/{summary}"
        logger.info(f"Downloading {url}")
        download(url, output_file, append=True)

    return output_file


def download_assemblies(assembly_list):
    """download all genomes on an assembly list
    """
    logger = logging.getLogger(__name__)

    os.makedirs("db/genomic", exist_ok=True)
    os.makedirs("db/protein", exist_ok=True)
    with open(assembly_list, "r") as f:
        for line in f:
            if line.startswith("#"):
                continue
            elif line.split("\t")[11] != "Complete Genome":
                continue
            else:
                ftp_dir_path = line.split("\t")[19]
                assembly_name = ftp_dir_path.split("/")[-1]
                genomic = f"{ftp_dir_path}/{assembly_name}_genomic.fna.gz"
                protein = f"{ftp_dir_path}/{assembly_name}_protein.faa.gz"

                logger.info(f"Downloading files for {assembly_name}")
                download(genomic, f"db/genomic/{assembly_name}_genomic.fna.gz")
                download(protein, f"db/protein/{assembly_name}_protein.faa.gz")
                summary(line, "db/assemblies.csv")


def summary(line, output_file):
    """create a summary file for the downloaded genomes
    """
    with open(output_file, "a", newline="") as csv_file:
        writer = csv.writer(csv_file, delimiter=",",
                            quotechar="|", quoting=csv.QUOTE_MINIMAL)
        row = [
            line.split("\t")[5],
            line.split("\t")[6],
            line.split("\t")[0],
            line.split("\t")[7]]
        writer.writerow(row)


def main():
    assembly_list = listing()
    download_assemblies(assembly_list)


if __name__ == "__main__":
    main()
