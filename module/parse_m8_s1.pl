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

use Getopt::Long;
my %opts;
GetOptions(\%opts,"i:s","d:s","s:s","o:s");
die unless $opts{"i"}and$opts{"o"}and$opts{"d"};
open IN,"$opts{'i'}"||die"$!";
open IND,"$opts{'d'}"||die"$!";
open INS,"$opts{'s'}"||die"$!";
open INO,">$opts{'o'}"||die"$!";
my %virus_gene;
my %virus_class;
my $virus_type;
my %bit_socore_self;
while(<IND>) {
  chomp;
	my $line_ind=$_;
	my @word1= split(/\s+/,$line_ind);	
  $virus_gene{$word1[0]}=$word1[1];
	$virus_class{$word1[0]}=$word1[2];
	if($word1[3]=~/(H\d+)(\N\d+)/) {
		   $H_type=$1;
		   $N_type=$2;
		   if($word1[1]=~/HA/) {
		   	   $virus_type{$word1[0]}=$H_type;
		   	}
		   elsif($word1[1]=~/NA/) {
		   	   $virus_type{$word1[0]}= $N_type;
		     }
		   else {
		   	  $virus_type{$word1[0]}=$word1[3];
		   	}
		}
	else {
			print "Error! Please check $word1[3]\n";
		}
	
}
while(<INS>) {
  chomp;
	my $line_ind=$_;
	my @word1= split(/\t+/,$line_ind);	
  if($bit_score_self{$word1[0]}) {
  	}
  else{
  		$bit_score_self{$word1[0]}=$word1[11];
  	}
}

my %tgg;
while(<IN>) {
	chomp;
	my $line_in=$_;
	my @word1= (split/\t+/,$line_in);	
  my $query=$word1[0];
	my $target=$word1[1];
	my $BSR=$word1[11]/$bit_score_self{$word1[0]};
	if(${$tgg{$query}}{$target}) {
		
		}
	else {
			print INO "$query\t$target\t$virus_gene{$word1[1]}\t$virus_class{$word1[1]}\t$virus_type{$word1[1]}\t$word1[2]\t$word1[11]\t$bit_score_self{$word1[0]}\t$BSR\n";
			${$tgg{$query}}{$target}=1;
			}
}
close(IN);
close(INO);
