#!/usr/bin/perl

use Getopt::Long;
my ($help, $input_file, $output_file);
my ($step,$threads);
GetOptions('help|?' => \$help,
            'folder|i=s' => \$input_file,
            'outputfile|o=s' => \$output_file,
            'unidentified_file|u=s' => \$unidentified_file,
            'BSR|b=f' => \$BSR,
            'margin|m=f' => \$margin,
            'percent|p=f' => \$percent,
            'identity|x=f' => \$identity_threshold,
						);

if($help || !defined $input_file || !defined $output_file || !defined $unidentified_file) {
	die <<EOF;

################################################

Pipeline for detecting Avian Influenza Virus from NGS Data

BC Centre for Disease Control
University of British Columbia

V1.0: Last changed Time-stamp: <2017-07-27>

################################################

Usage:   perl assign_subtype.pl.pl -i sorted_m8_file -o outputfile -u unidentified_file -s summary_file -f identify_threshold   
         -i	input file of sorted m8
         -o	output file
         -u unidentified_file (inconsistent subtype)
         -b BSR score (default 0.4)
         -m	margin of BSR score (default 0.3)
         -p	percentage of consistent subtype (default 0.9)
         -x threshold for identity (default 85%)
         -h	display this help message
EOF
}

################################################
our $BSR = $BSR || 0.4;
our $margin = $margin || 0.3;
our $percent = $percent || 0.9;
our $identity_threshold = $identity_threshold || 85;

open IN,"$input_file"||die"$!";
open INO,">$output_file"||die"$!";
open INU,">>$unidentified_file"||die"$!";
my %tgg_id;
my %subtype_cal;


my @name1=split("\/",$input_file);
my @name2=split("\_",$name1[-1]);
my $sample_name=$name2[0];
my $last_query="";
my $max_score;
my %identity_array;
my $max_fre;
my @max_array;
my $max_subtype;
while(<IN>) {
	chomp;
	my $djm1=$_;
	my @word1= split/\s+/,$djm1;
  if($word1[8]>=$BSR && $word1[5]>=$identity_threshold) {
    my $query=$word1[0];
    my $class=$word1[2];
    my $gene=$word1[3];
    my $serotype=$word1[4];
    my $identity=$word1[5];
    if($serotype=~/(H\d+)(N\d+)/){
        my $temp_HA=$1;
        my $temp_NA=$2;
        if($gene=~/HA/) {
          $sub_full_name="$class\_$gene\_$temp_HA";
        }
        elsif($gene=~/NA/) {
          $sub_full_name="$class\_$gene\_$temp_NA";
        }
        else{
          $sub_full_name="$class\_$gene\_un";
        }
    }
    else {
      $sub_full_name="$class\_$gene\_un";
    }
    #print "$sub_full_name\n";
    if($mark{$query}) {
      my $margin_dif=($max_BSR-$word1[8])/$max_BSR;
      if($margin_dif<=$margin) {
        $mark{$query}=$mark{$query}+1;  				           
        push @{$identity_array{$sub_full_name}},$identity;
        $last_query=$query;
      }
    }
    else {  				    
      if($last_query ne "") {  				    	    
        foreach $subname(keys %identity_array) {
          #print "$subname\n";
          my @array=@{$identity_array{$subname}};
          #print "@array\n";
          if($#array>$max) {
            @max_array=@array;
            $max_subtype=$subname;
            $max_fre=scalar @array;
          }
        }
        $cal_ratio=(scalar @max_array)/$mark{$last_query};
        $aveage_id=average(@max_array);
        $cal_ratio=sprintf("%.2f", $cal_ratio); 
        $cal_identity=sprintf("%.1f", $aveage_id); 
        my @type=split(/\_/,$max_subtype);
        #print "hhaha\t$cal_ratio\n";
        if($cal_ratio>=$percent) {
          print INO "$last_query\t$max_fre\/$mark{$last_query}\t$cal_ratio\t$type[0]\t$type[1]\t$type[2]\t$cal_identity\t$sample_name\n";
        }
        else {
          print INU "$last_query\t$max_fre\/$mark{$last_query}\t$cal_ratio\t$type[0]\t$type[1]\t$type[2]\t$cal_identity\t$sample_name\n";
        }
        %identity_array=();
        $max_fre=0;
        @max_array=();
        $max_subtype="";
      }
      $mark{$query}=1;
      $max_BSR=$word1[8];  				    
      push @{$identity_array{$sub_full_name}},$identity;
    }
  }
}
close IN;
foreach $subname(keys %identity_array) {
  #print "$subname\n";
  my @array=@{$identity_array{$subname}};
  #print "@array\n";
  if($#array>$max) {
    @max_array=@array;
    $max_subtype=$subname;
    $max_fre=scalar @array;
  }
}
$cal_ratio=(scalar @max_array)/$mark{$last_query};
$aveage_id=average(@max_array);
$cal_ratio=sprintf("%.2f", $cal_ratio); 
$cal_identity=sprintf("%.1f", $aveage_id); 
my @type=split(/\_/,$max_subtype);

if($cal_ratio>=$percent) {
  print INO "$last_query\t$max_fre\/$mark{$last_query}\t$cal_ratio\t$type[0]\t$type[1]\t$type[2]\t$cal_identity\t$sample_name\n";
}
else {
  print INU "$last_query\t$max_fre\/$mark{$last_query}\t$cal_ratio\t$type[0]\t$type[1]\t$type[2]\t$cal_identity\t$sample_name\n";
}




sub average {
  my @array_sub = @_;
  return unless @array_sub; 
  my $total;
  foreach (@array_sub) {
    $total += $_;
  }
  return $total / @array_sub;
}