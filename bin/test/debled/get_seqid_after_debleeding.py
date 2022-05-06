#!/usr/bin/env python3

"""
Prepare OTU table for further index hopping check

"""

import argparse
import csv
import re
import sys



def check_source(seqid, source): 
    pattern=re.compile(r'^(\S+)-\d+_size=(\d+)')

    try:
        matches = pattern.search(seqid)
        if(matches.groups()[0]):
            if matches.groups()[0] == source:
                return True
            else: 
                return False
    except:
        sys.exit("Please check sequence ID if it fits the pattern: (r'^(\S+)-\d+_size=(\d+)')")

def parse_args():
    parser = argparse.ArgumentParser(
                        description='remove bleeding ids')
    parser.add_argument('-i', '--input', type=str, default=None,
                        help='input file (read ID and related reference sequence subtypes and BSR scores)')
    parser.add_argument('-d', '--db', type=str, default=None,
                        help='name list from sorted un file')  
    parser.add_argument('-o', '--output', type=str, default=None,
                        help='Output file')
    args = parser.parse_args()
    if args.input is None or args.output is None or args.db is None:
        parser.print_help()
        sys.exit(0)
    return args


if __name__ == '__main__':
    args = parse_args()   

    mydict = {} 
    list_ids_good = []

   # f = open(args.output, "w")


    with open(args.db,"r") as csvfile:
        reader = csv.reader(csvfile, delimiter='\t')
        for line in reader:
            mydict[line[0]] = line[1]

    with open(args.input,"r") as csvfile:
        reader = csv.reader(csvfile, delimiter='\t')
        header = next(reader)
        for line in reader:
            list_tmp=mydict[line[0]].split(",")            
            list_ids_good = list_ids_good + list(filter(lambda seqid: check_source(seqid, line[1]), list_tmp))

    with open(args.output, "w") as outfile:
        outfile.write("\n".join(list_ids_good))

