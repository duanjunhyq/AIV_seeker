import pandas as pd
import argparse
import sys
import csv
import re


parser = argparse.ArgumentParser(description='Generate heatmap for aiv_seeker')
parser.add_argument("-i",'--input', type=str, help="input file (required)")
parser.add_argument("-o", '--output', help="output pass sequence IDs (required)", type=str)
parser.add_argument("-u",'--unclassified', help="output fail sequence IDs (required)", type=str)
parser.add_argument('-n', '--num_cutoff', type=int, default=10, 
                         help='threshold for the lowest number of sequence if considered as dominant (default 10)')
parser.add_argument('-f', '--fold_cutoff', type=float, default=3, 
                         help='fold cutoff (default 3 times)')

args = parser.parse_args()

if args.input is None or args.output is None or args.unclassified is None:
	parser.print_help()
	sys.exit(0)



f_pass = open(args.output, "w")
f_fail = open(args.unclassified, "w")

# read otu table
data = pd.read_csv(args.input,index_col="seqname",sep='\t')

# add one column to mark max and second max column

data['max_vs_second_max'] = (data.where(data.gt(0))
                 .stack().groupby(level=0)
                 .apply(lambda x: x.nlargest(2).index
                                   .get_level_values(1).to_list())
                )


title = "seqname"+"\t"+"dominant_sample"+"\t"+"status"+"\t"+"max"+"\t"+'second_max'+"\n"
f_pass.write(title)
f_fail.write(title)

for index, contents in data.iterrows():
        check = contents[-1]
        if len(check) == 1:
                max_item = contents[check[0]]
                f_pass.write(index+"\t"+check[0]+"\t"+"0"+"\t"+str(max_item)+"\t"+'0'+"\n")
        else:
        	max_item = contents[check[0]]
        	second_max = contents[check[1]]
        	if max_item>=args.num_cutoff and max_item/second_max>=args.fold_cutoff:
        		f_pass.write(index+"\t"+check[0]+"\t"+"1"+"\t"+str(max_item)+"\t"+str(second_max)+"\n")
        	else:
        		f_fail.write(index+"\t"+check[0]+"\t"+"2"+"\t"+str(max_item)+"\t"+str(second_max)+"\n")


f_pass.close
f_fail.close