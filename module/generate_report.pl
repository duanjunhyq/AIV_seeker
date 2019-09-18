#!/usr/bin/perl

use Getopt::Long;

my ($help, $subtype_file, $output_file,$gc_file,$cov_file);
my %reads_no;
my %reads_gc;
GetOptions('help|?' => \$help,
            'folder|i=s' => \$subtype_file,
            'outputfile|o=s' => \$output_file,
            'threads|m=s' => \$gc_file,
            'step|n=s' => \$cov_file,
					);

if($help || !defined $subtype_file || !defined $output_file || !defined $gc_file|| !defined $cov_file ) {
	die <<EOF;

################################################

Script used for generating report for Avian Influenza Virus from NGS Data

BC Centre for Disease Control
University of British Columbia

V1.0: Last changed Time-stamp: <2018-03-27>

################################################

Usage:   perl generate_report.pl.pl -i subtype_file -o outputfile -m gc_file -n cov_file      
         -i	subtype file
         -o	output file
         -m	gc_file
         -n	cov_file
         -h	display this help message
         
EOF
}
open(IN,"$subtype_file");  #subtype
open(INN,"$gc_file");  #GC report
open (INM,"$cov_file");  #coverage
##########################
while(<INM>) {
	chomp;
	my $line1=$_;
	@worddb= split/\s+/,$line1;	
	if($worddb[0]){
		$GC_report{$worddb[0]}=$line1;
		print "$line1\n";
	}
}
close INM;


while(<INN>) {
	chomp;
	my $line1=$_;
	@worddb= split/\s+/,$line1;	
	if($worddb[0]){
		${$cov_report{$worddb[0]}}{$worddb[1]}=$worddb[2];
	}
}
close INN;


while(<IN>) {
	chomp;
	my $djm1=$_;
	my @word1= split/\t/,$djm1;	
	my $name=shift @word1; 
	#print "$djm1\n"; 
	if($name) {
  		foreach my $item(@word1) {
			if($item=~/(\w+)\_(\w+)\_(\w+)\((\d+)\)\[id:(\S+)\]/) {
				my $family=$1;
				my $gene=$2;
				my $subtype=$3;
				my $reads_no=$4;
				my $id_percent=$5;
				my $subname;
				if($gene=~/HA/ or $gene=~/NA/) {
					$subname="$family\_$subtype";
					if($gene=~/un/i) {
						$subname="$family\_$subtype\_un";
					}
					else {
						$subname="$family\_$subtype";
					}				
				}
				elsif($gene=~/MP/) {
					$subname="$family\_MP";
				}
				elsif($gene=~/NS1/) {
					$subname="$family\_NS";
				}
				else {
					$subname="$family\_$gene";
				}			
				${$number_report{$name}}{$subname}=$reads_no;
				${$id_report{$name}}{$subname}=$id_percent;
  			}
  			else {
				#print "$item\n";
			}
  							  			  
  		}
  			#print "\n";
  	}
}
close(IN);


$report_stype1=$output_file."_s1.csv";
$report_stype2=$output_file."_s2.csv";
$report_stype3=$output_file."_s3.csv";
open (o1,">$report_stype1");  #report1

@sample_name=keys %GC_report;
@sample_name=sort { substr($a, 1) <=> substr($b, 1)  } (@sample_name);


foreach my $libname(@sample_name) {
	my (@HA,@NA,@other); 
	my $print_mark_HA=$print_mark_NA=$print_mark_other=0;
	foreach my $subname(keys %{$id_report{$libname}}) {
		$report_item="$subname\(${$number_report{$libname}}{$subname}\)";
		if($subname=~/\_H\d+/) {
			push (@HA,$report_item);
		}
		elsif($subname=~/\_N\d+/) {
			push @NA,$report_item;
		}
		else {
			push @other,$report_item;
		}
	}

	print o1 "$GC_report{$libname}\t";
		 
	if(scalar @HA>0) {
		foreach $HA_tag(@HA) {
			if($print_mark_HA==0) {
				print o1 "\t$HA_tag";
				$print_mark_HA=1;
			}
			else {
				print o1 ",$HA_tag";
			}
		}
	}
	else {
		print o1 "\t-";
	}
	if(scalar @NA>0) {
		foreach $NA_tag(@NA) {
			if($print_mark_NA==0) {
				print o1 "\t$NA_tag";
				$print_mark_NA=1;
			}
			else {
				print o1 ",$NA_tag";
			}
		}
	}
	else {
		print o1 "\t-";
	}
	if(scalar @other>0) {
		foreach $other_tag(@other) {
			if($other_tag=~/\_M1\(/) {
				$other_tag=~s/\_M1\(/\_MP\(/;
			}
			if($other_tag=~/\_M2\(/) {
				$other_tag=~s/\_M2\(/\_MP\(/;
			}
			if($print_mark_other==0) {
				print o1 "\t$other_tag";
				$print_mark_other=1;
			}
			else {
				print o1 ",$other_tag";
			}
		}
	}
	else {
		print o1 "\t-";
	}

	print o1 "\n";
}

close(o1);

open (o2,">$report_stype2");  #report2
my (@title,@title_other);

#@HA_sum=("A_H1","A_H2","A_H3","A_H4","A_H5","A_H6","A_H7","A_H8","A_H9","A_H10","A_H1","A_H2","A_H1")

@other_sum=("A_NP","A_NS1","A_PB1","A_PB2","A_PA","A_MP");


for($i=1;$i<17;$i++) {
	push (@title,"A\_H$i");
	}
for($i=1;$i<10;$i++) {
	push (@title,"A\_N$i");
	}
my @title_all = (@title, @other_sum);

print o2 "subtype";
foreach my $libname(@sample_name) {
	print o2 "\t$libname";
}
print o2 "\n";
foreach $title_name (@title_all) {
	print o2 "$title_name";
	foreach my $libname(@sample_name) {
		if($title_name eq "A_MP") {
			$title_M1="A_M1";
			$title_M2="A_M2";
			if(${$number_report{$libname}}{$title_M1}) {
			  	$report_item="${$number_report{$libname}}{$title_M1}";
				print o2 "\t$report_item";
			}
			elsif(${$number_report{$libname}}{$title_M2}) {
			  	$report_item="${$number_report{$libname}}{$title_M2}";
				print o2 "\t$report_item";
			}
			  			
			else {
			  	print o2 "\t\-";
			}
		}
		else {
			if(${$number_report{$libname}}{$title_name}) {
			  	$report_item="${$number_report{$libname}}{$title_name}";
				print o2 "\t$report_item";
			}
			else {
			  	print o2 "\t\-";
			}
		}
		
	}
	print o2 "\n";
}


#######################

open (o3,">$report_stype3");  #report2
my (@title,@title_other);
@other_sum=("A_NP","A_NS","A_PB1","A_PB2","A_PA","A_MP");
for($i=1;$i<17;$i++) {
	push (@title,"A\_H$i");
	}
for($i=1;$i<10;$i++) {
	push (@title,"A\_N$i");
	}
my @title_all = (@title, @other_sum);
print o3 "Library";
foreach my $subtype(@title_all) {
	print o3 "\t$subtype";
}
print o3 "\n";

foreach my $libname(@sample_name) {
	print o3 "$GC_report{$libname}";
	foreach my $subtype(@title_all) {
		if(${$number_report{$libname}}{$subtype}) {
			$report_item=${$number_report{$libname}}{$subtype};
			print o3 "\t$report_item";
		}
		else {
			print o3 "\t0";
		}
	}
	print o3 "\n";
  }
close(o3);