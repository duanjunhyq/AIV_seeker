#!/usr/bin/perl -w

use Getopt::Long;
my %opts;
GetOptions(\%opts,"i:s","d:s","o:s");
open I,"$opts{'i'}"||die"$!";
open I2,"$opts{'d'}"||die"$!";

if (-e $opts{'i'}) {	
}
else {
	exit;
}

my %name;
my %seqdb;
$/=">";
while (<I2>) {   
	chomp;
    my $seq = '';                     
	my @line = split(/\n+/,$_);
	my $head1 = shift @line;              
	foreach my $line (@line) {
		$seq .= $line;             
	}
	if($head1) {
		$seq=~s/\s+//g;
		my @temp=split(/\s+/,$head1);
		$seqdb{$temp[0]}=$seq;
	}
}
$/="\n";
my %outputfile;
while (<I>) {
	chomp;
	my $line=$_;
	my @words= split/\s+/,$line;	
	$sample_name=pop @words;
	if($words[0]) {
		my $filename="$sample_name\_$words[4]\_$words[3]\_$words[5]";
		if($outputfile{$filename}) {
			open(n1,">>$opts{'o'}/$filename\.fa");
			print n1 ">$line\n$seqdb{$words[0]}\n";
			close n1;
		}
		else {
			open(m1,">$opts{'o'}/$filename.fa") ;
			print m1 ">$line\n$seqdb{$words[0]}\n";
			close m1;
			$outputfile{$filename}=1;
		}
	}
}
			

close(I);



