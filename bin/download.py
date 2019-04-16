#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys
import logging

import requests


def listing():
    """download assembly lists for bacteria, archaea anv viruses
    """
    refseq = "https://ftp.ncbi.nlm.nih.gov/genomes/refseq"

    bac = "bacteria/assembly_summary.txt"
    arc = "archaea/assembly_summary.txt"
    vir = "viral/assembly_summary.txt"
    summaries = [bac, arc, vir]

    for summary in summaries:
        url = f"{refseq}/{summary}"
        output_file = "db/assembly_summaries.txt"

        request = requests.get(url, stream=True)

        with open(output_file, "ab") as f:
            for chunk in request.iter_content(chunk_size=1024):
                if chunk:
                    f.write(chunk)
                    f.flush()


def download(assembly_list):
    """download all genomes on an assembly list
    """


def main():
    listing()


if __name__ == "__main__":
    main()
