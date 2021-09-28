#!/usr/bin/perl

use Getopt::Std;
getopts "i:m:n:x:";
open(IN,$opt_i);  #input

open (o2,">$opt_n"); #otu name

while(<IN>) {
	chomp;
	my $djm=$_;
	@words= split/\t/,$djm;	
 	$type=$words[0];
 	$query=$words[8];
 	$subject=$words[9];
 	if($type=~/S/) {
		push @{$uniq_group{$query}},$query;
 	}
 	if($type=~/H/) {
		push @{$uniq_group{$subject}},$query;
 	}
}
close(IN);
foreach $uniq_name(keys %uniq_group) {
	@cal_otu=@{$uniq_group{$uniq_name}};
	foreach $item(@cal_otu) {
		@temp=split/\_/,$item;	
		$library=$temp[0];
		my $raw_size=$item;
		$raw_size=~/\;size\=(\d+)/;
		$raw_size_ok=$1;
		$otu->{$uniq_name}->{$library}=$otu->{$uniq_name}->{$library}+1;
		$size->{$uniq_name}->{$library}=$size->{$uniq_name}->{$library}+$raw_size_ok;
		push @{$otuname->{$uniq_name}->{$library}},$item;
		$alllib{$library}=1;
	}
}

@libnames=keys %alllib;
$mark=0;
open (o1,">$opt_m"); #otu table
#generate otu table
foreach $otu_name(keys %{$otu}) {
	if($mark==0) {
		print o1 "uniq_otu";
		foreach $libname(@libnames) {
			print o1 "\t$libname";
		}
		print o1 "\n";
		$mark=1;
	}
	print o1 "$otu_name";
	foreach $libname(@libnames) {
		if($otu->{$otu_name}->{$libname}) {
			print o1 "\t$otu->{$otu_name}->{$libname}";
		}
		else {
			print o1 "\t0";
		}
	}
	print o1 "\n";
}

close(o1);
open (o2,">$opt_n"); #otu table
#generate otu_name table
$mark=0;
foreach $otu_name(keys %{$otu}) {
	if($mark==0) {
		print o2 "uniq_otu";
		foreach $libname(@libnames) {
			print o2 "\t$libname";
		}
		print o2 "\n";
		$mark=1;
	}
	print o2 "$otu_name";
	foreach $libname(@libnames) {
		if($otuname->{$otu_name}->{$libname}) {
			$link_string=join(',', @{$otuname->{$otu_name}->{$libname}});
			print o2 "\t$link_string";
		}
		else {
			print o2 "\t-";
		}
	}
	print o2 "\n";
}
close o2;

open (o3,">$opt_x"); #raw size table
#generate otu_name table
$mark=0;
foreach $otu_name(keys %{$otu}) {
	if($mark==0) {
		print o3 "uniq_otu";
		foreach $libname(@libnames) {
			print o3 "\t$libname";
		}
		print o3 "\n";
		$mark=1;
	}
	print o3 "$otu_name";
	foreach $libname(@libnames) {
		if($otu->{$otu_name}->{$libname}) {
			print o3 "\t$size->{$otu_name}->{$libname}";
		}
		else {
			print o3 "\t0";
		}
	}
	print o3 "\n";
}

close(o1);