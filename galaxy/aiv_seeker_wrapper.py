#!/usr/bin/env python

"""

aivseeker_wrapper.py
A wrapper script for aivseeker
Jun Duan - University of British Columbia, BC Centre for Disease Conntrol

"""

import argparse
import sys
import tempfile
import os
import shutil
import uuid

current_path=os.path.dirname(os.path.abspath(__file__))

parser = argparse.ArgumentParser(description='python aivseeker_wrapper.py ')

# required parameters

parser.add_argument('-i','--input', help="list of paired end data", required=True, action='append')
parser.add_argument('-x','--qc_report', dest="qc_report", help="multiQC report", required=True)
parser.add_argument('-y','--report_raw', dest="report_raw", help="subtype report (raw)", required=True)

#debleeding parameters
parser.add_argument('-l','--debled_overlap', dest="debled_overlap",help="overlap threshold for debleeding",required=False)
parser.add_argument('-c','--debled_identity', dest="debled_identity",help="identity threshold for debleeding",required=False)
parser.add_argument('-z','--report_debled', dest="report_debled",help="subtype report (debled)",required=False)

args = parser.parse_args()

qc_report=args.qc_report
report_raw=args.report_raw

def random_string(string_length=10):
    """Returns a random string of length string_length."""
    random = str(uuid.uuid4()) # Convert UUID format to a Python string.
    random = random.upper() # Make all characters uppercase.
    random = random.replace("-","") # Remove the UUID '-'.
    return random[0:string_length] # Return the random string.

def cleanup_before_exit(tmp_dir):
    if tmp_dir and os.path.exists(tmp_dir):
        shutil.rmtree(tmp_dir)
def stop_err(msg):
    sys.stderr.write(msg)
    sys.exit()

#create tmp folder
tmp=tempfile.gettempdir()
#tmp="/tmp"
tmp=current_path+"/tmp"
tmp_prefix="aivseeker_"
tmp_folder=tmp_prefix+random_string(8)
#tmp_folder="aivseeker_1D3818A1"
tmp_dir_path=os.path.join(tmp,tmp_folder)
if os.path.exists(tmp_dir_path):
	os.rmdir(tmp_dir_path)
	os.mkdir(tmp_dir_path)
else:
	os.mkdir(tmp_dir_path)
filelist=os.path.join(tmp_dir_path, "filelist.txt")

#write sample reads path to filelist.txt
f = open(filelist, "wt")
for item in args.input:
    current_list = item.split(",")
    if(len(current_list)<3):
        stop_err("Error: the format should be: Sample_name,forward_reads_path,reverse_reads_path")
    else:
        if(len(current_list)==3):
            sample_name=current_list[0]
            forward_reads=current_list[1]
            reverse_reads=current_list[2]
            f.write(sample_name+"\t"+forward_reads+"\t"+reverse_reads+"\t"+'default'+"\n")
f.close


tmp_file="tmp.txt"
f = open(tmp_file, "w")
f.close


com="perl "+current_path \
     + "/AIV_seeker/AIV_Seeker.pl" \
     + " -i " + tmp_dir_path \
     + " -o " + tmp_dir_path \
     + " -s " +'2' \
     + " -g" \
     + " -f"

if(args.report_debled):
    com=com \
    + " -w" \
    + " -l " + args.debled_overlap \
    + " -c " + args.debled_identity

print(com)
os.system(com)






# result_report_raw=tmp_dir_path+"/9.subtype_raw/4.report/report_raw_s1.csv"

#QC report

# com2="print " +com +" "+ tmp_dir_path+">2.txt" 
# os.system(com2)
qc_report_file=tmp_dir_path+"/2.multiQC/multiQC_report.html"
shutil.copyfile(qc_report_file, qc_report)


#shutil.copyfile(tmp_dir_path+"/filelist.txt",qc_report)

#Subtyping report
report_raw_file=tmp_dir_path+"/9.subtype_raw/4.report/report_uniq_s1.csv"
shutil.copyfile(report_raw_file, report_raw)

if(args.report_debled):
    result_report_debled=tmp_dir_path+'/10.debled_'+args.debled_overlap+'_'+args.debled_identity+'/9.report_debled'+'/report_debled_uniq_s1.csv'
    shutil.copyfile(result_report_debled, args.report_debled)







