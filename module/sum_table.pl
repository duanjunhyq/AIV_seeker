#!/usr/bin/perl

use Getopt::Std;
getopts "i:o:d:";
use File::Basename;

open(IN,$opt_i);
open (o,">$opt_o");

while(<IN>) {
      chomp;
      my $line=$_;
	@items= split(/\s+/,$line);	
	my $lib_path=$items[0];
	if($tgg{$lib_path}) {
	     print "Please check duplication\n";
	     print "$lib_path\n";
	     exit;
      }
      else {
	     $tgg{$lib_path}=1;
	}

      if($lib_path) { 
            $lib_fullname=basename($lib_path);
      	@name1= split(/\./,$lib_fullname);
      	@name2= split(/\_/,$name1[0]);
            $libname=$name2[0];
	      $libs{$libname}=1;
      	if($lib_path=~/0\.raw_fastq/) {
      	   	$raw_no_reads{$libname}=$raw_no_reads{$libname}+$items[1];
      	   	$raw_no_bases{$libname}=$raw_no_bases{$libname}+$items[2];
      	   	$raw_GC{$libname}=$raw_GC{$libname}+$items[3];
      	}
      	if($lib_path=~/combine.fastq/) {
      	   	$final_no_reads{$libname}=$items[1];
      	   	$final_no_bases{$libname}=$items[2];
      	   	$final_GC{$libname}=$items[3];
            }
      	if($lib_path=~/\_P\_R[1|2]\.fq/) {
      	   	$processed_paired_no_reads{$libname}=$processed_paired_no_reads{$libname}+$items[1];
      	   	$processed_paired_no_bases{$libname}=$processed_paired_no_bases{$libname}+$items[2];
      	   	$processed_paired_GC{$libname}=$processed_paired_GC{$libname}+$items[3];
            }
      	if($lib_path=~/\_S\_R[1|2]\.fq/) {
      	   	$processed_single_no_pair{$libname}=$processed_single_no_pair{$libname}+$items[1];
      	   	$processed_single_no_bases{$libname}=$processed_single_no_bases{$libname}+$items[2];
      	   	$processed_single_GC{$libname}=$processed_single_GC{$libname}+$items[3];
      	}

      }
 
}

close(IN);

print o "Libname\t#Raw_reads\t#Pairs\t#Bases\t%GC\tFinal_reads\t#Bases\t%GC\t#Reads after filtering (pairs)\t#Bases\t%GC\tSingle_F\t#Bases\t%GC\tSingle_R\t#Bases\t%GC\tMerged_reads\t#Bases\t%GC\tUn_merged_F\t#Bases\t%GC\tUn_merged_R\t#Bases\t%GC\n";

foreach $lib(keys %libs) {
	$raw_GC{$lib}=$raw_GC{$lib}/2;
	$processed_single_GC{$lib}=$processed_single_GC{$lib}/2;
	$processed_paired_GC{$lib}=$processed_paired_GC{$lib}/2;
	print o "$lib\t$raw_no_reads{$lib}\t$raw_no_bases{$lib}\t$raw_GC{$lib}\t";
	print o "$final_no_reads{$lib}\t$final_no_bases{$lib}\t$final_GC{$lib}\t";
	print o "$processed_paired_no_reads{$lib}\t$processed_paired_no_bases{$lib}\t$processed_paired_GC{$lib}\t";
	print o "$processed_single_no_pair{$lib}\t$processed_single_no_bases{$lib}\t$processed_single_GC{$lib}\n";
	 
}

close(o);





