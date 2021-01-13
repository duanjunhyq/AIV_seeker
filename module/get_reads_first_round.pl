#!/usr/bin/perl -w

use Getopt::Long;
my %opts;
GetOptions(\%opts,"i:s","d:s","o:s");
die unless $opts{"i"} and $opts{"o"} and $opts{"d"};
open I,"$opts{'i'}"||die"$!";
open I2,"$opts{'d'}"||die"$!";
open O,">$opts{'o'}"||die"$!";
my %name;
while (<I>) {
	my $djm=$_;
	my @words= split/\s+/,$djm;	
	$name{$words[0]}=$words[0];	
}
close(I);

$/=">";
while (<I2>) {   
	chomp;
    my $seq =""; 
    my $head="";                    
	my @line = split(/\n+/,$_);
	$head = shift @line;
	if ($head) {
		my @temp=split(/\s+/,$head);
	  	my $head1=shift @temp;
   		foreach my $line (@line) {
			$seq .= $line;             
	   	}
	    $seq=~s/\s+//g;
		if ($name{$head1}) {
			print O ">$head1\n$seq\n";
		}
	}
}
$/="\n";
close I2;
close O;
