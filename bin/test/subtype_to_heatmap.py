#!/usr/bin/env python3

"""
AIV subtype heatmap

"""

import argparse
import os
import csv
import pandas as pd
import re
import numpy as np
import seaborn as sns; sns.set_theme()
import matplotlib.pyplot as plt

def parse_args():
    parser = argparse.ArgumentParser(
                        description='Assign subtype')
    parser.add_argument('-i', '--input', type=str, default=None,
                        help='folder that contains all the subtype files')
    parser.add_argument('-o', '--output_prefix', type=str, default=None,
                        help='Output prefix')
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    fig, ax = plt.subplots(figsize=(30,30))
    df_data = pd.read_csv(args.input, sep=',', index_col="sampleName", keep_default_na=True) 
    df_data=df_data.fillna(0)
    data_t=df_data
    data_t=np.log2(data_t+1)
    ax.set_xlabel('')
    g=sns.clustermap(data_t, linewidths=0.05, linecolor='black', cmap="YlGnBu", vmin=0, vmax=8, col_cluster=False)
    ax = g.ax_heatmap
    ax.set_ylabel('')
    plt.savefig(args.output_prefix+"_subtype.pdf")