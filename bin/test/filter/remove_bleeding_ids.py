#!/usr/bin/env python3

"""
Remove bleedng ids 

"""

import argparse
import pandas as pd
import sys

def parse_args():
    parser = argparse.ArgumentParser(
                        description='Assign subtype')
    parser.add_argument('-i', '--input', type=str, default=None,
                        help='input file (table after assigning subtypes)')
    parser.add_argument('-d', '--db', type=str, default=None,
                        help='sequence IDs that passed debleeding process')
    parser.add_argument('-o', '--output', type=str, default=None,
                        help='Output file')
    args = parser.parse_args()
    if args.input is None or args.output is None or args.db is None:
    	parser.print_help()
    	sys.exit(0)
    return args

if __name__ == '__main__':
	args = parse_args()
	df_data = pd.read_csv(args.input, keep_default_na=False)
	df_db = pd.read_csv(args.db, index_col=0, header=None, keep_default_na=False)
	set_all_pass_ids = set(df_db.index.values) 
	df_filtered_data=df_data[df_data.read_id.isin(set_all_pass_ids)]
	df_filtered_data.to_csv(args.output, index=False)