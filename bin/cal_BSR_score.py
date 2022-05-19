#!/usr/bin/env python3

"""
Calculate BSR score based on alignment.

"""

import argparse
import csv
import pandas as pd


def parse_args():
    parser = argparse.ArgumentParser(
                        description='Calculate BSR score based on alignment')
    parser.add_argument('-i', '--input', type=str, default=None,
                        help='blastn alignment after filtering chimeras. Only canadidate reads left')
    parser.add_argument('-s', '--aln_self', type=str, default=None,
                        help='blastn alignment file based on aligning reads against itself')
    parser.add_argument('-a', '--aln_all', type=str, default=None,
                        help='blastn alignment file based on aligning reads against itself')
    parser.add_argument('-d', '--db', type=str, default=None,
                        help='metadata file that contains the subtype information for the reference genes')
    parser.add_argument('-o', '--output', type=str, default=None,
                        help='Output file')

    return parser.parse_args()

def listToString(s): 
    str1 = "" 
    for item in s: 
        str1 += item
    return str1 
        

if __name__ == '__main__':
    args = parse_args()
    df_meta = pd.read_csv(args.db, index_col=0, keep_default_na=False)  # metadata
    df_reads_vs_ref_filtered = pd.read_csv(args.input, sep='\t', header=None)    
    df_reads_vs_self = pd.read_csv(args.aln_self, sep='\t', header=None) 
    df_reads_vs_ref_all = pd.read_csv(args.aln_all, sep='\t', header=None) 
    df_reads_vs_self.columns = df_reads_vs_ref_filtered.columns = df_reads_vs_ref_all.columns = ["qseqid", "sseqid", "pident", "length", "mismatch", \
                                                 "gapopen", "qstart", "qend", "sstart", "send", \
                                                  "evalue", "bitscore", "qlen", "qcovs"] 
    df_reads_vs_self_processed = df_reads_vs_self.drop_duplicates(subset=['qseqid'])
    df_reads_vs_self_processed = df_reads_vs_self_processed.set_index('qseqid')

    candidate_reads_list = set(df_reads_vs_ref_filtered["qseqid"].unique().tolist())


    f = open(args.output, "w")
   
    for row in df_reads_vs_ref_all.itertuples():
        read_id = row[1]
        if read_id not in candidate_reads_list:
            continue
        ref_gene = row[2]
        identity = row [3]     
        alignment_score = int(row[12])
        list_out=[]
        try:
            ref_score = df_reads_vs_self_processed["bitscore"][read_id]
        except:
            continue
        
        RSA_score = round(int(alignment_score)/int(ref_score), 2)
        
        list_out = [read_id, ref_gene, df_meta["Type"][ref_gene], df_meta["Gene"][ref_gene], df_meta["Subtype"][ref_gene], \
                 round(identity, 1), alignment_score, ref_score, RSA_score]          
        f.write("\t".join(map(str, list_out))) 
        f.write("\n")
    f.close()


   