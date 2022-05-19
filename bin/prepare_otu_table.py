#!/usr/bin/env python3

"""
Prepare OTU table for further index hopping check

"""

import argparse
import csv
import re
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
    args = parser.parse_args()
    if args.input is None or args.output is None or args.output_name is None:
        parser.print_help()
        sys.exit(0)
    return args


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

    pattern=re.compile(r'^(\S+)-\d+;size=(\d+)')
    # output all the name to file
    f_name = open(args.output_name, "w")

    for key in mydict:
        value =  ','.join(mydict[key])
        f_name.write(key+"\t"+value+"\n")
        for item in mydict[key]:
            matches = pattern.search(item)
            try: 
                if(matches.groups()[0] and matches.groups()[1]):
                    samplename = matches.groups()[0]
                    size = int(matches.groups()[1])
                    sample_dic[samplename] = 1
            except:
                sys.exit("Please check sequence ID if it fits the pattern: (r'^(\S+)-\d+;size=(\d+)')")
            if my_data_dic[key][samplename]:
                my_data_dic[key][samplename] = my_data_dic[key][samplename]+size
            else:
                my_data_dic[key][samplename] = size
    f_name.close

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


    

        
   

      