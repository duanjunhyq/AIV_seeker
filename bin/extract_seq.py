#!/usr/bin/env python3

"""
Extract fasta sequences using a list of sequence IDs.

"""

import argparse
from Bio import SeqIO

def parse_args():
    parser = argparse.ArgumentParser(
        description='Extract fasta sequences using a list of sequence IDs.')
    parser.add_argument('-i', '--input', type=str, default=None,
                        help='A list of sequence IDs. Each line contains one ID and the line can be seperated by tab. You can use -t to designate which column contains the ID.')
    parser.add_argument('-d', '--db', type=str, default=None,
                        help='Fasta file that contains all the fasta sequences ')
    parser.add_argument('-o', '--output', type=str, default=None, help='Output file')
    parser.add_argument('-p', '--position', type=int, default=1, help='The column number that contains the sequence ID (Default 1)')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    fasta_file = args.db # Input fasta file
    wanted_file = args.input # Input interesting sequence IDs, one per line
    result_file = args.output # Output fasta file
    wanted = set()
    with open(wanted_file) as f:
        for line in f:
            line = line.strip()
            position = args.position-1
            try:
                id = line.split()[position]
            except:
                print("Please check if your designate column for the ID is existing.")

            if line.split()[position] != "":
                wanted.add(id)

    fasta_sequences = SeqIO.parse(open(fasta_file),'fasta')
    with open(result_file, "w") as f:
        for seq in fasta_sequences:
            if seq.id in wanted:
                SeqIO.write([seq], f, "fasta")