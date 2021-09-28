#!/usr/bin/perl
# Detect AIV reads in NGS DATA 
# Last changed Time-stamp: <2017-07-27>
#
# Jun Duan
# BCCDC Public Health Laboratory
# University of British Columbia
# duanjun1981@gmail.com
#
# William Hsiao, PhD
# Senior Scientist (Bioinformatics), BCCDC Public Health Laboratory
# Clinical Assistant Professor, Pathology & Laboratory Medicine, UBC
# Adjunct Professor, Molecular Biology and Biochemistry, SFU
# Rm 2067a, 655 West 12th Avenue 
# Vancouver, BC, V5Z 4R4
# Canada
# Tel: 604-707-2561
# Fax: 604-707-2603


use Getopt::Std;
getopts "i:m:n:";
open(IN,$opt_i);  #input
open (o1,">$opt_m"); #uniq otu name
open (o2,">$opt_n"); #cross otu name

$head=<IN>;
chomp $head;
@libname= split/\t/,$head;
shift @libname;
print o1 "$head\n";
print o2 "$head\n";


while(<IN>) {
	chomp;
	my $djm=$_;
	@words= split/\t/,$djm;	
 	$otu_name=shift @words;
 	$mark=0;
 	foreach $item(@words) {
 				if($item>0) {
 						$mark=$mark+1;
 					}
 		}
  if($mark>1) {
  		print o2 "$djm\n";
  	}
  else {
  		print o1 "$djm\n";
  	}
}
close(IN);
