#!/usr/local/bin/perl
#program by duanjun1981@gmail.om
use Getopt::Std;
getopts "i:d:o:";
open(IN,$opt_i);
open(IND,$opt_d);
open (o,">$opt_o");

($libname)=(split qr{/}, $opt_i)[-1];
($libname)=(split qr{\_}, $libname)[0];

while(<IN>) {
	chomp;
	my $djm=$_;
	@words= split/\s+/,$djm;	
  $name=$words[0];
  @names= split/\_/,$name;
  if($names[1]) {
  	  $refseq_id="$names[0]\_$names[1]";
  	  $refseq_db{$refseq_id}=1;
  	  last;
  	}
  
	
}
close(IN);

while(<IND>) {
	chomp;
	my $djm=$_;
	@words= split/\t/,$djm;	

  if($refseq_db{$words[0]}) {
  	   $url=$words[19];
  	   ($LastInUrl) = (split qr{/}, $url)[-1];
  	   system("wget $url/$LastInUrl\_cds_from_genomic.fna.gz");
  	   system("gzip -d $LastInUrl\_cds_from_genomic.fna.gz");
  	   last;
  	}
 }
close(IND);
@genelist=("HA","NA","M1","PA","NP","PB1","PB2","NS1");


open(INN,"$LastInUrl\_cds_from_genomic.fna");
$/ = ">";                              
my $qwqw = <INN>;
my $flag = 0;
while (<INN>) {
		chomp;
    my $seq = '';                     
		my @line = split(/\n+/,$_);
		$head = shift @line;              
		foreach my $line (@line) {
			   $seq .= $line;             
	    }
	  $seq=~s/\s+//;
    if($head=~/\[gene\=(\S+)\]/) {
    		$genename=$1;
    		$seqdb_seq{$genename}=$seq;
    		$seqdb_title{$genename}=$head;
    		$seqdb_len{$genename}=length($seq);
    	}
		
}


$/ = "\n";

close INN;

open(IN1,">$libname\_ref.fa");
open(IN2,">$libname\_g.txt");
foreach $gene_label(@genelist) {
		  if($seqdb_seq{$gene_label}) {
		  	   if($gene_label eq "M1") {
		  	   	    print IN1 ">MP\t$LastInUrl\t$seqdb_title{$gene_label}\n$seqdb_seq{$gene_label}\n";
		  	        print IN2 "MP\t$seqdb_len{$gene_label}\n";
		  	   	}
		  	   else {
		  	   	    print IN1 ">$gene_label\t$LastInUrl\t$seqdb_title{$gene_label}\n$seqdb_seq{$gene_label}\n";
		  	        print IN2 "$gene_label\t$seqdb_len{$gene_label}\n";
		  	   	}
		  	   
		  	}
}

close IN1;
close IN2;
system("rm -fr $LastInUrl\_cds_from_genomic.fna");