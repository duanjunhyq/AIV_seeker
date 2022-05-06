#!/usr/bin/env python3

"""
Prepare OTU table for further index hopping check

"""

import argparse
import csv
import pandas as pd
import re
import numpy as np
import sys

class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]

def getList(dict):
    return dict.keys()

def parse_args():
    parser = argparse.ArgumentParser(
                        description='Assign subtype')
    parser.add_argument('-i', '--input', type=str, default=None,
                        help='input file (read ID and related reference sequence subtypes and BSR scores)')
    parser.add_argument('-o', '--output', type=str, default=None,
                        help='Output file')
    parser.add_argument('-n', '--output_name', type=str, default=None,
                        help='Output all the names to a file')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    mydict = {} 
    my_data_dic = {} 
    sample_dic = {}
    f = open(args.output, "w")

    my_data_dic = AutoDict()
    with open(args.input,"r") as csvfile:
        reader = csv.reader(csvfile, delimiter='\t')
        for line in reader:
            query =  line[8]
            subject = line[9]
            if line[0] == "S":
                mydict[query] = [query]
            elif line[0] == "H":
                mydict[subject].append(query) 
            else:
                continue

    pattern=re.compile(r'^(\S+)-\d+_size=(\d+)')
    name_list_all = []
    for key in mydict:
        name_list_all = name_list_all +  mydict[key]       
        for item in mydict[key]:
            matches = pattern.search(item)
            try: 
                if(matches.groups()[0] and matches.groups()[1]):
                    samplename = matches.groups()[0]
                    size = int(matches.groups()[1])
                    sample_dic[samplename] = 1
            except:
                sys.exit("Please check the sample name (without any special characters like '_', '-', '*')")
            if my_data_dic[key][samplename]:
                my_data_dic[key][samplename] = my_data_dic[key][samplename]+size
            else:
                my_data_dic[key][samplename] = size

    seqNames = getList(my_data_dic)
    sampleNames=getList(sample_dic)
    line = 'seqname'
    for tmp_sample in sampleNames:
        line = line + "\t"+tmp_sample
    f.write(line+"\n")             
    for tmp_seq in seqNames:
        line = tmp_seq
        for tmp_sample in sampleNames:
            if(my_data_dic[tmp_seq][tmp_sample]):
                line=line+("\t"+str(my_data_dic[tmp_seq][tmp_sample]))
            else:
                line=line+("\t"+str(0))
        f.write(line+"\n")             
          
    f.close

    # output all the name to file

    f_name = open(args.output_name, "w")
    for seqname in name_list_all:
        f_name.write(seqname+"\n")
    f_name.close


      