#!/usr/bin/perl

open IN,"$ARGV[0]"||die;        
open INO,">$ARGV[1]"||die;    
   
$/ = ">";                              
my $qwqw = <IN>;
my $flag = 0;
while (<IN>) {
		chomp;
		
        my $seq = '';                     
		my @line = split(/\n+/,$_);
		$head = shift @line;              
		foreach my $line (@line) {
			$seq .= $line;             
	    }
	    @temp=split(/\s+/,$head);
	    $head=shift @temp;
        if(length($seq)>0) {
		   print INO ">$ARGV[2]\_$head\n$seq\n";
		}
}

$/ = "\n";

close IN;