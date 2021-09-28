#!/usr/local/bin/perl
#duanjun1981@gmail.com

use Getopt::Std;
getopts "i:l:o:m";

@genelist=("HA","NA","MP","PA","NP","PB1","PB2","NS1");
if($opt_m) {
	open(INO1,">>$opt_o\_cov.txt");
	open(INO2,">>$opt_o\_depth.txt");	
	print INO1 "Sample";
	print INO2 "Sample";
	for($i=0;$i<=$#genelist;$i=$i+1) {
		print INO1 "\t$genelist[$i]";
		print INO2 "\t$genelist[$i]";
	}
	print INO1 "\n";
	print INO2 "\n";
	close(INO1);
	close(INO2);
	exit;
}
else {
	open(IN,$opt_i);
	if(-s $opt_i) {
		while(<IN>) {
			chomp;
			my $line=$_;
			@words= split(/\s+/,$line);
			if($words[2]>0) {
				$tgg_depth{$words[0]}=$tgg_depth{$words[0]}+$words[2];
				$tgg_cov{$words[0]}=$tgg_cov{$words[0]}+1;
				$tgg_len{$words[0]}=$tgg_len{$words[0]}+1;
			}
			else {			
				$tgg_len{$words[0]}=$tgg_len{$words[0]}+1;
			}
		}	

		open(INO1,">>$opt_o\_cov.txt");
		open(INO2,">>$opt_o\_depth.txt");
		print INO1 "$opt_l";
		print INO2 "$opt_l";		
		foreach $gene_label(@genelist) {
			if($tgg_len{$gene_label}==0) {
				print INO1 "\t0";
				print INO2 "\t0";
			}
			else {
				$coverage=($tgg_cov{$gene_label}/$tgg_len{$gene_label})*100;
				$depth=$tgg_depth{$gene_label}/$tgg_len{$gene_label};
				$coverage=sprintf("%.1f",$coverage);
				$depth=sprintf("%.1f",$depth);
				print INO1 "\t$coverage";
				print INO2 "\t$depth";
			}
		}
      
	}
	else {
		for($i=0;$i<=$#genelist;$i=$i+1) {
			print INO1 "\t0";
			print INO2 "\t0";
		}
	}


	print INO1 "\n";
	print INO2 "\n";

	close(INO1);
	close(INO2);
	close IN;

}

