#!/usr/bin/env python3

"""
Remove chimeras based on aligning against reference sequences.

BLAST alignment file format:

"qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen qcovs"

"""

import csv
import argparse

def parse_args():
    parser = argparse.ArgumentParser(
        description='Extract fasta sequences using a list of sequence IDs.')
    parser.add_argument('-i', '--input', type=str, default=None,
                        help='BLAST alignment file')
    parser.add_argument('-o', '--output', type=str, default=None, help='Output file')
    parser.add_argument('-c', '--cutoff', type=float, default=0.75, help='Query Coverage')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    input = args.input # Input file
    output = args.output # Output file
    cutoff = int(args.cutoff*100)

    outfile = open(output, "w")
    with open(input,"r") as csvfile:
        reader = csv.reader(csvfile, delimiter='\t')
        seen = set() 
        for line in reader:
            if line[0] not in seen:
                seen.add(line[0])
                if(int(line[13])>=cutoff):
                    outfile.write("\t".join(str(item) for item in line))
                    outfile.write("\n")
            else:
                continue
        