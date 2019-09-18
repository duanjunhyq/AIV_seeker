#!/usr/bin/perl

use Getopt::Std;
getopts "i:m:n:o:";
open(IN,$opt_i);  #input
open (o,">$opt_o"); #results after removing
open (o1,">$opt_m"); #multiple dominant
open (o2,">$opt_n"); #single dominant
$num_cutoff=10;
$fold_cutoff=3;


$head=<IN>;
chomp $head;
@libname= split/\t/,$head;
shift @libname;
print o1 "$head\n";
print o2 "$head\n";
print o "$head\n";

while(<IN>) {
	chomp;
	my $djm=$_;
	@words= split/\t/,$djm;	
 	$otu_name=shift @words;
 	$mark=0;
 	$i=-1;
 	my %dominant;
 	foreach $item(@words) {
    $i=$i+1;
    if($item>=$num_cutoff) {
      $mark=$mark+1;
      $dominant{$i}=$item;
    }
  }
  @sorted = sort { $b <=> $a } @words;
  
  #only one dominant  
  if($mark==1) {
    if($sorted[1]==0) {
      $sorted[1]=1;
    }
    if($sorted[0]/$sorted[1]>=$fold_cutoff) {
      print o2 "$djn\n";
      print o "$otu_name";
      $j=-1;
      foreach $item(@words) {
        $j=$j+1;
        if($dominant{$j}) {
          print o "\t$dominant{$j}";
        }
        else {
          print o "\t0";
        }
      }
      print o "\n";
    }
  }
  
  #more than one dominant
  if($mark>1) {
    if($sorted[1]<1) {
      $sorted[1]=1;
    }
    if($sorted[0]/$sorted[1]>=$fold_cutoff) {
      print o1 "$djm\n";
      print o "$otu_name";
      foreach $item(@words) {
        if($item==$sorted[0]) {
          print o "\t$item";
        }
        else {
          print o "\t0";
        }
      }
      print o "\n";
    }
  	  
  }
}
close(IN);
