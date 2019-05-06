#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import random
import logging
import argparse

from pathlib import Path
from shutil import copyfileobj


def random_datasets(n, genomes_path):
    """pick n random genomes from a list of genomes

    Args:

    n: n genomes to pick
    genomes: assemblies.txt file

    Returns:
    list: paths of selected genomes
    """
    p = Path(genomes_path)
    genomes = list(p.glob("*.fna.gz"))
    random_genomes = random.sample(population=genomes, k=n)
    return random_genomes


def concatenate(files, output):
    """concatenate files together
    """
    logger = logging.getLogger(__name__)
    try:
        out_file = open(output, 'wb')
    except (IOError, OSError) as e:
        logger.error('Failed to open output file: %s' % e)
        sys.exit(1)

    with out_file:
        for file_name in files:
            if file_name is not None:
                with open(file_name, 'rb') as f:
                    copyfileobj(f, out_file)


def main():
    parser = argparse.ArgumentParser(
        prog="select n genomes from a directory of genomes (../db/genomic)",
        usage="python select_genomes.py -n N -o output.fasta [--seed S]",
        description="select n random genomes from a directory of genomes"
    )
    parser.add_argument(
        "-n",
        help="number of genomes to pick at random",
        required=True,
        type=int
    )
    parser.add_argument(
        "--seed",
        default=1,
        help="random seed to use. Default = 1"
    )
    parser.add_argument(
        "--output",
        help="output file name",
        required=True
    )
    args = parser.parse_args()
    random.seed(args.seed)

    genomes = random_datasets(args.n, "../db/genomic")
    concatenate(genomes, args.output)


if __name__ == "__main__":
    main()
