#!/usr/bin/env python3

"""
Assign subtype.

"""

import argparse
import csv
import pandas as pd
import re
import numpy as np

def return_subtype(gene, subtype):
    gene = str(gene)
    subtype = str(subtype)
    pattern=re.compile(r'(H\d+)(N\d+)')
    matches = pattern.search(subtype)
    if(gene == "HA"):        
        return matches.groups()[0]
    elif(gene == "NA"):
        return matches.groups()[1]
    else:
        return gene

def apply_complex_function(x):
    return return_subtype(x['gene'], x['subtype'])


def parse_args():
    parser = argparse.ArgumentParser(
                        description='Assign subtype')
    parser.add_argument('-i', '--input', type=str, default=None,
                        help='input file (read ID and related reference sequence subtypes and BSR scores)')
    parser.add_argument('-o', '--output', type=str, default=None,
                        help='Output file')
    parser.add_argument('-u', '--un_classified', type=str, default=None,
                        help='un_classified reads because of not passing thresholds)')
    parser.add_argument('-b', '--BSR_score', type=float, default=0.5, 
                         help='BSR score (default 0.5)')
    parser.add_argument('-m', '--margin', type=float, default=0.2, 
                         help='score drop margin from the max BSR score (default 20%)')
    parser.add_argument('-p', '--percent_max_occur', type=float, default=0.8,
                        help='percentage of the subtype with maximum occurrency (default 0.8)')
    parser.add_argument('-t', '--identity', type=float, default=85,
                       help='threshold for identity (default 85%')
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    cutoff_identity = args.identity
    cutoff_BSR_score = args.BSR_score
    cutoff_percent_max_occur = args.percent_max_occur
    cutoff_margin = args.margin

    df_data = pd.read_csv(args.input, sep='\t', header=None, keep_default_na=False) 
    df_data.columns = ["read_id", "ref_id","type",  \
                       "gene", "subtype", "identity", \
                       "query_score", "ref_score", "bsr_score"]


    # add specific subtype to column subtype_processed
    df_data['subtype_processed'] = df_data.apply(lambda row : return_subtype(row['gene'], row['subtype']), axis = 1)   
    
    # filter data based on identity and BSR score
    index_filtered = df_data.query('identity >= @cutoff_identity and bsr_score >= @cutoff_BSR_score').index
    df_data_filtered = df_data.iloc[index_filtered,] 

    # remove alignment if it's BSR score lower than the margin of the max BSR score
    df_data_filtered_by_margin = df_data_filtered.copy()
    df_data_filtered_by_margin['bsr_max'] = df_data_filtered_by_margin.groupby(['read_id'], sort=False)['bsr_score'].transform(max)
    df_data_processed = df_data_filtered_by_margin[(df_data_filtered_by_margin['bsr_max']-df_data_filtered_by_margin['bsr_score']/df_data_filtered_by_margin['bsr_max'])<=cutoff_margin]

    # calculate percentage of the subtype with maximum occurrency 

    size = df_data_processed.groupby(['read_id']).size().to_frame('total').reset_index()
    max_occurrency = df_data_processed.groupby(['read_id','subtype_processed']).size().sort_values().groupby(level=0).tail(1).reset_index()
    max_occurrency.columns = ["read_id","subtype","max_occurrency"]
    result= pd.merge(max_occurrency, size, on = ["read_id"])
    result["ratio"] = round(result['max_occurrency']/result['total'],2)
    result_pass = result[result["ratio"] >= cutoff_percent_max_occur]
    

    # output classified read list to file
    result_pass.to_csv(args.output, index=False)


    # check unclassified reads
    if(args.un_classified): 
        list_original = df_data['read_id'].tolist()
        list_pass_all =  result_pass['read_id'].tolist()
        set_fail_all = set(list_original) - set(list_pass_all)
        list_pass_identity_and_bsr = df_data_filtered['read_id'].tolist()
        set_fail_identity_and_bsr = set(list_original) - set(list_pass_identity_and_bsr)
        set_fail_per_of_max_occurrency = set(set_fail_all) - set_fail_identity_and_bsr
        df_fail = pd.DataFrame(list(set_fail_all), columns = ["read_id"])


        for idx, row in df_fail.iterrows():
            if  df_fail.loc[idx,'read_id'] in set_fail_identity_and_bsr:
                df_fail.loc[idx,'fitler_identity_and_bsr'] = "failed"
                continue
            else:
                df_fail.loc[idx,'fitler_identity_and_bsr'] = "passed"

            if  df_fail.loc[idx,'read_id'] in set_fail_per_of_max_occurrency:
                df_fail.loc[idx,'fitler_per_of_max_occurrency'] = "failed"
            else:
                df_fail.loc[idx,'fitler_per_of_max_occurrency'] = "passed"
        # output classified read list to file
        if(len(df_fail.index))==0:
            df_fail = pd.DataFrame()
        df_fail.to_csv(args.un_classified, index=False)
    




   