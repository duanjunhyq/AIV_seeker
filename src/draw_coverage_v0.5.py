#!/usr/bin/python
#duanjun1981@gmail.com


import sys, getopt
import matplotlib.pyplot as plt
import numpy as np
#import math
import seaborn as sns
import re

class AutoVivification(dict):
    """Implementation of perl's autovivification feature."""
    def __missing__(self, key):
        value = self[key] = type(self)()
        return value
        
def check_path_with_slash(folder):
    if not folder.endswith("/"):
        folder += "/"
    return folder
    
def sorted_by_number( l ):
    convert = lambda text: int(text) if text.isdigit() else text
    alphanum_key = lambda key: [convert(c) for c in re.split('([0-9]+)', key)]
    return sorted(l, key = alphanum_key)
def main(argv):
    inputfile = ''
    outputfile = ''
    number_of_columns = 5   #number of plot per row
    gene_list=["PB2","NS1","MP","NA","NP","HA","PA","PB1"]
    try:
        opts, args = getopt.getopt(argv,"hi:o:d:",["ifile=","dfile=","ofile="])
    except getopt.GetoptError:
        print('draw_coverage_v0.4.py -i <sample_list.txt> -d <input_dir> -o <outputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('draw_coverage_v0.4.py -i <sample_list.txt> -d input_dir -o <outputfile>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-d", "--dfile"):
            dirfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg
    sample_file = open(inputfile, 'r')
    samples = sample_file.read().split('\n')
    sample_file.close()
    sample_list=[]
    for sample_line in samples:
        if sample_line:
            words = sample_line.split()
            sample_list.append(words[0])
    number_of_subplots = len(sample_list)
    Rows = number_of_subplots // number_of_columns 
    Rows += number_of_subplots % number_of_columns
    Position = range(1,number_of_subplots + 1)
    fig = plt.figure(figsize=(30,20))
    fontsize_cust=16
    pre_length = {
		    "PB1" : 2274,
		    "PB2" : 2007,
		    "NS1" : 693,
		    "MP" : 759,
		    "NA" : 1410,
		    "HA" : 2011,
		    "NP" : 1497,
		    "PA" : 2151,
		    	}
    for k in range(number_of_subplots):
        ax = fig.add_subplot(Rows,number_of_columns,Position[k])
        sample_name=sample_list[k]
        ax.set_title(sample_name,fontsize=fontsize_cust)
        ax.set_ylabel('Log2(Depth)',fontsize=fontsize_cust)
        ax.set_xticks([], [])
        ########################################################## read data
        pos_dict = AutoVivification()
        filename=check_path_with_slash(dirfile)+sample_name+"_cov.txt"
        datafile_raw = open(filename, 'r')
        sepfile_raw = datafile_raw.read().split('\n')
        datafile_raw.close()
        for datapair in sepfile_raw:
            if datapair:
                xypair = datapair.split('\t')
                pos_dict[xypair[0]][xypair[1]]= [xypair[2]];
        i=0
        len_list=[]
        x = []
        y = []

        for genename in gene_list:
            #print genename+"\t"+str(len(pos_dict[genename]))
            if len(pos_dict[genename])>0:
                len_list.append(len(pos_dict[genename]))
                #print pos_dict[genename]
                for position in sorted_by_number(pos_dict[genename]):
        	          i=i+1
        	          #print i
        	          #print position
        	          x.append(i)
        	          y.append(int(pos_dict[genename][position][0])+1)
            else:
                #print genename+"\t"+str(pre_length[genename])
                len_list.append(int(pre_length[genename]))
                for position in range (1,int(pre_length[genename])): 
        	          i=i+1
        	         # print position
        	          x.append(i)
        	          y.append(1)
#            
        y=np.log2(y)
        x_sm = np.array(x)
        y_sm = np.array(y)
        ########################################################## plot coverage
        start_x=0
        all_count=0
        label_pos=[]
        for s in len_list:
    	      start=all_count
    	      all_count=all_count+s
    	      end=all_count-1
    	      x_temp=x_sm[start:end]
    	      y_temp=y_sm[start:end]
    	      label_pos.append(start+(end-start)/2)
    	      with sns.color_palette("Set2"):
     	          plt.fill_between( x_temp, y_temp, alpha=0.8)
     	          plt.plot(x_temp, y_temp, '-',linewidth=0.3)
        plt.xticks(label_pos, gene_list, rotation='vertical',fontsize=fontsize_cust)
        plt.tight_layout(pad=5,w_pad=0, h_pad=1)
        ax.tick_params(axis='y', labelsize=fontsize_cust)
        
        
        ##########################################################

        #ax.plot(1,2)

        
    #plt.show()
    plt.savefig(outputfile+'.pdf')
    
if __name__ == "__main__":
    main(sys.argv[1:])

