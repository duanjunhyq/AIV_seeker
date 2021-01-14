#!/usr/bin/perl

use Getopt::Std;
getopts "i:o:";
use File::Basename;
my @name1=split("\/",$opt_i);
my @name2=split("\_",$name1[-1]);
my $sample_name=$name2[0];
open(IN,$opt_i);
open (o,">$opt_o");
while(<IN>) {
	chomp;
	my $line=$_;
	@items= split(/\s+/,$line);	
	my $reads_name=$items[0];
  	my $gene=$items[4];
	my $class=$items[3];
	my $serotype=$items[5];
	my $identity=$items[6];
	if($gene=~/HA|NA/) {
		$sub_full_name="$class\_$gene\_$serotype";
	}
    else {
		$sub_full_name="$class\_$gene\_un";
	}
	if($reads_name) {
		push @${$all{$sub_full_name}},$identity;
		if($reads_name=~/\;size\=(\d+)/) {
			$sum{$sub_full_name}=$sum{$sub_full_name}+1;
		}
		else {
			$sum{$sub_full_name}++;
		}
	}
}
close(IN);

open(o, ">$opt_o") ||die"$!";
print o "$sample_name\t";
foreach $subtype(keys %all) {
	$average_id=average(@${$all{$subtype}});
	$average_id=sprintf("%.1f", $average_id); 
	print o "\t$subtype($sum{$subtype})[id:$average_id%]";
}

print o "\n";


sub average {
    my @array_sub = @_;
    return unless @array_sub; 
    my $total;
    foreach (@array_sub) {
        $total += $_;
    }
    return $total / @array_sub;
}
