#!/usr/bin/perl

use Getopt::Long;
my %opts;
GetOptions(\%opts,"i:s","d:s","s:s","o:s","m:s");
die unless $opts{"i"}and$opts{"o"}and$opts{"d"};
open IN,"$opts{'i'}"||die"$!";
open IND,"$opts{'d'}"||die"$!";
open INS,"$opts{'s'}"||die"$!";
open INO,">$opts{'o'}"||die"$!";



my %virus_gene;
my %virus_class;
my $virus_type;
my %bit_socore_self;
my %reads_list;
#
while(<IND>) {
	chomp;
	my $line_ind=$_;
	my @word1= split(/\s+/,$line_ind);	
	$virus_gene{$word1[0]}=$word1[1];
	$virus_class{$word1[0]}=$word1[2];
	if($word1[3]=~/(H\d+)(N\d+)/) {
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
close(IND);

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
close(INS);
if($opts{'m'}) {
	open INM,"$opts{'m'}"||die;              
    $/ = ">";                              
    my $qwqw = <INM>;
    my $flag = 0;
    while (<INM>) {
		chomp;		
        my $seq = '';                     
		my @line = split(/\n+/,$_);
		my $head = shift @line;              
		# foreach my $line (@line) {
			# $seq .= $line;             
	    # }
		@temp=split(/\s+/,$head);
        my $head1=shift @temp;
        if($head1) {
		  $reads_list{$head1}=1;
		}
	}
    $/ = "\n";
	close(INM);

}

my %tgg;

my $last_query=$last_target="";
while(<IN>) {
	chomp;
	my $line_in=$_;
	my @word1= (split/\t+/,$line_in);	
    my $query=$word1[0];
	my $target=$word1[1];
	my $BSR=$word1[11]/$bit_score_self{$word1[0]};
	$BSR=sprintf("%.3f", $BSR);
	if($query ne $last_query or $target ne $last_target) {
		if($virus_type{$target} and $reads_list{$query}) {
			print INO "$query\t$target\t$virus_gene{$word1[1]}\t$virus_class{$word1[1]}\t$virus_type{$word1[1]}\t$word1[2]\t$word1[11]\t$bit_score_self{$word1[0]}\t$BSR\n";
			$last_query=$query;
			$last_target=$target;
		}
	}
}
close(IN);
