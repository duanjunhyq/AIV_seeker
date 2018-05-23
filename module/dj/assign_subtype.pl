#!/usr/bin/perl
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

#use strict;
#use warnings;
use Getopt::Long;

my ($help, $input_file, $output_file);
my ($step,$threads);
GetOptions('help|?' => \$help,
            'folder|i=s' => \$input_file,
            'outputfile|o=s' => \$output_file,
            'unidentified_file|u=s' => \$unidentified_file,
            'summary_file|s=s' => \$summary_file,
            'BSR|b=f' => \$BSR,
            'margin|m=f' => \$margin,
            'percent|p=f' => \$percent,
						);

if($help || !defined $input_file || !defined $output_file || !defined $unidentified_file|| !defined $summary_file) {
	die <<EOF;

################################################

Pipeline for detecting Avian Influenza Virus from NGS Data

BC Centre for Disease Control
University of British Columbia

V1.0: Last changed Time-stamp: <2017-07-27>

################################################

Usage:   perl assign_subtype.pl.pl -i sorted_m8_file -o outputfile -u unidentified_file -s summary_file     
         -i	input file of sorted m8
         -o	output file
         -u unidentified_file (inconsistent subtype)
         -s summary_file
         -b BSR score (default 0.4)
         -m	margin of BSR score (default 0.3)
         -p	percentage of consistent subtype (default 0.7)
         -h	display this help message
EOF
}

################################################
our $BSR = $BSR || 0.4;
our $margin = $margin || 0.3;
our $percent = $percent || 0.7;

open IN,"$input_file"||die"$!";

my %tgg_id;
my %subtype_cal;
my %max_BSR;

my @name1=split("\/",$input_file);
my @name2=split("\_",$name1[-1]);
my $sample_name=$name2[0];
while(<IN>) {
	chomp;
	my $djm1=$_;
	my @word1= split/\t+/,$djm1;	
  my $query=$word1[0];
	my $gene=$word1[2];
	my $class=$word1[3];
	my $serotype=$word1[4];
	my $identity=$word1[5];
	if($gene=~/HA|NA/) {
				 $sub_name="$gene\_$class\_$serotype";
		}
  else {
  			$sub_name="$gene\_$class\_un";
  	}
  if($max_BSR{$query}) {}
  else {
  		$max_BSR{$query}=$word1[8];
  	}
  
  if($word1[8]>=$BSR) {
  			my $margin_dif=($max_BSR{$query}-$word1[8])/$max_BSR{$query};
  			if($margin_dif<=$margin) {
  							#########################################
  								  $tgg_id{$query}++;
  									${$subtype_cal{$query}}{$sub_name}++;
  									${$tgg_identity{$query}}{$sub_name}=${$tgg_identity{$query}}{$sub_name}+$identity;
  							#########################################
  					}
  	}

}

close(IN);


my @allid=keys %tgg_id;

if ($#allid>0) {
	open INO,">$output_file"||die"$!";
	
	foreach $id(@allid) {		
		@subtype=keys %{$subtype_cal{$id}};
		$max=$cal_identity=$cal_ratio=0;
	  foreach $sub_item(@subtype) {
	    	    	if(${$subtype_cal{$id}}{$sub_item}>$max) {
	    	    	  		 $max=${$subtype_cal{$id}}{$sub_item};
	    	    	  		 $cal_identity=${$tgg_identity{$id}}{$sub_item}/${$subtype_cal{$id}}{$sub_item};
	    	    	  		 $cal_ratio=${$subtype_cal{$id}}{$sub_item}/$tgg_id{$id};
	    	    	  		 $cal_subtype=$sub_item;
	    	    	  }
    	}
	    $cal_identity=sprintf("%.1f", $cal_identity); 
	    if($cal_ratio>=$percent) {
	    	   	my @type=split(/\_/,$cal_subtype);
	    	   	print  INO "$id\t$max\/$tgg_id{$id}\t$cal_ratio\t$type[0]\t$type[1]\t$type[2]\t$cal_identity\t$sample_name\n";
	    	  	my $subtype_report="$type[1]\_$type[0]_$type[2]";
	    	  	$subtype_report=~s/\s+//g;
	    	  	$report_no{$subtype_report}++;
	    	  	$report_identity{$subtype_report}=$report_identity{$subtype_report}+$cal_identity;
	    	  } 
	    else {
	    	   open INU,">>$unidentified_file"||die"$!";
	    		 print INU "$id\t$max\/$tgg_id{$id}\t$cal_ratio\t$type[0]\t$type[1]\tun\t$cal_identity\t$sample_name\n";
	    		 close INU;
	    	}
	}
		close INO;
		
open(INO1, ">$summary_file") ||die"$!";
print INO1 "$sample_name\t";
foreach $subtype(keys %report_no) {
				$average_id=$report_identity{$subtype}/$report_no{$subtype};
				$average_id=sprintf("%.1f", $average_id); 
				print INO1 "\t$subtype($report_no{$subtype})[id:$average_id%]";
			}
print INO1 "\n";
close INO1;

	}
