#!/usr/local/bin/perl
#program by duanjun1981@gmail.om
use Getopt::Std;
getopts "i:d:o:";
open(IN,$opt_i);  #processed OTU table
open(IND,$opt_d); #otu_name
open (o,">$opt_o"); #output reads list


   

while (<IN>) {
		chomp;
    $line=$_;
	  #next if ($line=~/^uniq_otu/);
	  next if ($line=~/^\s+/);
	  if($line=~/^uniq_otu/) {
	  			@libs= split/\t/,$line;
	  			shift @libs;
	  	}
	  else {
	  	   @words= split/\t/,$line;
	  	   $otu_name=shift @words;
	  	   $mark=0;
		   $i=0;
	  	   foreach $item(@words) {
		            
	  	   			if($item>0) {
	  	   					$mark=$mark+1;
							$relation{$otu_name}{$libs[$i]}=1;
	  	   				}
				    $i=$i+1;
	  	   	}
	  	   # if($mark==1) {
	  	   	    # ($index_max,$value_max)=&max_value(\@words);
	  	   	    # $relation{$otu_name}=$libs[$index_max];
	  	   	# }
	  	   # else {
	  	   		# print "please check the input format, only one dominant value is allowed!";
	  	   	# }

	  	}
	  
}

close(IN);

while (<IND>) {
		chomp;
    $line=$_;

	  #next if ($line=~/^uniq_otu/);
	  next if ($line=~/^\s+/);
	  if($line=~/^uniq_otu/) {
	  			@libs= split/\t/,$line;
	  			shift @libs;
	  	}
	  else {
	  	   @words= split/\t/,$line;
	  	   $otu_name=shift @words;
	  	   $i=-1;
	  	   foreach $libname(@libs) {
	  	   	    $i=$i+1;
	  	   			if($relation{$otu_name}{$libname}==1) {
	  	   						@reads= split/\,/,$words[$i];
	  	   		 	      foreach $read_name(@reads) {
	  	   		 	    		  print o "$read_name\n";
	  	   		 	    	}
	  	   				}
	  	   	}
	  	   
	  	   
	  	   
	  	  
	  	}
	}
close(IND);	

sub max_value () {
	  my ($array) = @_;
	  @data=@{$array};
		my $i = $#data;
    my $max = $i;
    $max = $data[$i] > $data[$max] ? $i : $max while $i--;
    #print "Max value is $data[$max], at index $max\n";
    return ($max,$data[$max]);
}




close(IND);
close(o);