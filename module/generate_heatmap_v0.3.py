import seaborn as sn
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import argparse
import sys
import csv
import re
import pyqt5

parser = argparse.ArgumentParser(description='Generate heatmap for aiv_seeker')
parser.add_argument("-i", help="input file (required)", type=str)
parser.add_argument("-o", help="out put file (required)", type=str)
parser.add_argument("-d", help="name list file", type=str)  #name dictionary
args = parser.parse_args()
input = args.i
output  = args.o

if args.i is None or args.o is None:
	parser.print_help()
	print(input)
	print(output)
	sys.exit(0)

if args.d:
	with open(args.d, 'r') as file:
		reader = csv.reader(file, delimiter = '\t')
		list_dic={}
		for row in reader:
			x=re.match(r"^[sS]\d+$",row[0])
			if x:
				list_dic[row[0]]=row[2]
			else:
				list_dic["s"+row[0]]=row[2]
			

fig, ax = plt.subplots(figsize=(30,30))
data = pd.read_csv(input,index_col="subtype",sep='\t',) 
if args.d:
	data.rename(columns=list_dic,inplace=True) 
data_t=data.T

sn.set(font_scale=0.5)
data_t=data_t.drop(['Libname'])
data_t[data_t == '-'] = 0
data_t=data_t.apply(lambda x: pd.to_numeric(x), axis=0)

data_t=np.log2(data_t+1)
ax.set_xlabel('')
g=sn.clustermap(data_t,linewidths=0.05,linecolor='black',cmap="YlGnBu",vmin=0, vmax=8,col_cluster=False)
ax = g.ax_heatmap
ax.set_ylabel('')
plt.savefig(output+".pdf")
# plt.show()
