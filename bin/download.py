#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import csv
import sys
import logging

import requests

from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry


class BadRequestError(Exception):
    """Exception to raise when a http request does not return 200
    """

    def __init__(self, url, status_code):
        super().__init__(f"{url} returned {status_code}")


def download(url, output_file, chunk_size=1024, append=False):
    """download an url
    """
    session = requests.Session()
    retry = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[502, 503, 504]
    )
    session.mount('https://', HTTPAdapter(max_retries=retry))

    if url.startswith("ftp://"):  # requests doesnt support ftp
        url = url.replace("ftp://", "https://")
    if url:
        # first we check the header for a valid response
        response = requests.head(url)
        if response.status_code == 200:
            request = requests.get(url, stream=True, timeout=300)
        else:
            raise BadRequestError(url, response.status_code)

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
        logger.warning(f"Downloading {url}")
        try:
            download(url, output_file, append=True)
        except BadRequestError as e:
            logger.error(f"Could not download {url}")
    return output_file


def download_assemblies(assembly_list):
    """download all genomes on an assembly list
    """
    logger = logging.getLogger(__name__)

    os.makedirs("db/genomic", exist_ok=True)
    os.makedirs("db/protein", exist_ok=True)
    os.makedirs("db/genbank", exist_ok=True)
    with open(assembly_list, "r") as f:
        for line in f:
            if line.startswith("#"):
                continue
            elif line.split("\t")[11] != "Complete Genome":
                continue
            else:
                ftp_dir_path = line.split("\t")[19]
                name = ftp_dir_path.split("/")[-1]
                genomic = f"{ftp_dir_path}/{name}_genomic.fna.gz"
                protein = f"{ftp_dir_path}/{name}_protein.faa.gz"
                genbank = f"{ftp_dir_path}/{name}_genomic.gbff.gz"

                logger.warning(f"Downloading files for {name}")
                try:
                    download(genomic, f"db/genomic/{name}_genomic.fna.gz")
                    download(protein, f"db/protein/{name}_protein.faa.gz")
                    download(genbank, f"db/genbank/{name}_genomic.gbff.gz")
                    summary(line, "db/assemblies.csv")
                except BadRequestError as e:
                    logger.warning(f"Could not download {name}")
                    logger.warning("Skipping organism")
                    cleanup(name)


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


def cleanup(name):
    """if a file has failed to download, remove all the organism's files
    """
    genomic = f"db/genomic/{name}_genomic.fna.gz"
    protein = f"db/protein/{name}_protein.faa.gz"
    genbank = f"db/genbank/{name}_genomic.gbff.gz"
    files = [genomic, protein, genbank]
    for f in files:
        try:
            os.remove(f)
        except FileNotFoundError as e:
            continue


def main():
    assembly_list = listing()
    download_assemblies(assembly_list)


if __name__ == "__main__":
    main()
