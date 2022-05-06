#!/usr/bin/env python3

"""
Assign AIV subtype.

"""

import argparse
import os
import csv
import pandas as pd
import re
import numpy as np
from functools import reduce
import sys

def return_raw_size(read_id):
    read_id = str(read_id)
    pattern=re.compile(r';size=(\d+)')
    matches = pattern.search(read_id)
    if(matches.groups()[0]):
        return int(matches.groups()[0])
    
def sorted_names (namelist):
    namelist = list(namelist)
    namelist_sorted = []
    HA_list = [ "H" + str(i+1) for i in list(range(16))]
    NA_list = [ "N" + str(i+1) for i in list(range(9))]
    Other_list = ['MA','NP','NS','PA','PB1','PB2']
    ref_list = HA_list + NA_list + Other_list 
    for item in ref_list:
        if item in set(namelist):
            namelist_sorted.append(item)
    return(namelist_sorted)


def parse_args():
    parser = argparse.ArgumentParser(
                        description='Assign subtype')
    parser.add_argument('-i', '--input', type=str, default=None,
                        help='input file list that contains all the subtype files')
    parser.add_argument('-d', '--dir', type=str, default=None,
                        help='folder that contains all the subtype files')
    parser.add_argument('-o', '--output_prefix', type=str, default=None,
                        help='Output prefix')
    parser.add_argument('-r', '--report_raw', action = "store_true",
                        help='report number of raw sequences (default false)')
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    all_table_unique = all_table_raw = {}  
    sampleList= []
    if(args.dir):
        fileList = [f for f in os.listdir(args.dir) if f.endswith('.csv')]
    elif(args.input):
        fileList = args.input.split(",")
    else:
        sys.exit("Please input a list and specify a directory for the subtype files")

    for file in fileList:
        sampleName = file.split("_")[0]
        sampleList.append(sampleName)
        if(args.dir):
            df_data = pd.read_csv(args.dir+"/"+file, sep=',', keep_default_na=False) 
        if(args.input):
            df_data = pd.read_csv(file, sep=',', keep_default_na=False) 
        # add raw_size column
        df_data['raw_size'] = df_data.apply(lambda row : return_raw_size(row['read_id']), axis = 1)
        
        

        if(args.report_raw):
            # summarize raw sequences
            raw_table=df_data.groupby(['subtype'])['raw_size'].sum().reset_index(name='counts')
            raw_table.columns = ["subtype", sampleName]
            all_table_raw[sampleName] = raw_table
        else: 
            # summarize unique sequences
            unique_table=df_data.groupby(['subtype']).size().reset_index(name='counts')
            unique_table.columns = ["subtype", sampleName]
            all_table_unique[sampleName] = unique_table  


        
    # Generate report
    if(args.report_raw):
        # report raw sequences
        raw_dataframes = all_table_raw.values()
        raw_dataframe_list = list(raw_dataframes)
        df_merged_raw = reduce(lambda  left,right: pd.merge(left,right,on=['subtype'],
                                            how='outer'), raw_dataframe_list).fillna('NaN')
        df_merged_raw=df_merged_raw.set_index('subtype')
        df_raw_result = df_merged_raw.T
        df_raw_result = df_raw_result.reindex(columns=sorted_names(df_raw_result.columns))
        df_raw_result.reset_index().rename(columns={'index': 'sampleName'}).to_csv(args.output_prefix +"_raw.csv", index=False)

    else: 
        # report unique sequences
        unique_dataframes = all_table_unique.values()
        unique_dataframe_list = list(unique_dataframes)
        df_merged_unique = reduce(lambda  left,right: pd.merge(left,right,on=['subtype'],
                                            how='outer'), unique_dataframe_list).fillna('NaN')
        df_merged_unique=df_merged_unique.set_index('subtype')
        df_unique_result = df_merged_unique.T
        df_unique_result = df_unique_result.reindex(columns=sorted_names(df_unique_result.columns))
        df_unique_result.reset_index().rename(columns={'index': 'sampleName'}).to_csv(args.output_prefix +"_uni.csv", index=False)
