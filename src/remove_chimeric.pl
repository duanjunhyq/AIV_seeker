#!/usr/bin/perl

use Getopt::Std;
getopts "i:d:o:c:";
open(IN,$opt_i);
open(IND,$opt_d);
open (o,">$opt_o");

$cutoff_chimeric=$opt_c;

$/ = ">";                              
my $qwqw = <IND>;
my $flag = 0;
while (<IND>) {
	chomp;
	my $seq = '';                     
	my @line = split(/\n+/,$_);
	$head = shift @line;              
	foreach my $line (@line) {
		$seq .= $line;             
	}
	$seq=~s/\s+//g;   
	@tt= split(/\s+/,$head);
	$head=$tt[0];
	$len=length ($seq);
	$length_all{$head}=$len;
}
$/ = "\n";
close(IND);

while (<IN>) {
	chomp;
	$bb1=$_;
	@words1= split/\s+/,$bb1;
	my $reads_name=$words1[0];
	my $aligned_seq=abs($words1[7]-$words1[6])+1;
	if($ttg{$reads_name}){
	}
	else {
		$ttg{$reads_name}=1;
		if($length_all{$reads_name}) {
			$ratio=$aligned_seq/$length_all{$reads_name};
			if($ratio<=$cutoff_chimeric) {
				print o "$reads_name\t$words1[1]\t$aligned_seq\t$length_all{$reads_name}\t$ratio\n";
			}
	        else {
				print "$reads_name\t$words1[1]\t$aligned_seq\t$length_all{$reads_name}\t$ratio\n";
			}
	    }
	    else {
			print "There may be some error with $reads_name\n";
	    }
	}
}

close(IN);
close(o);