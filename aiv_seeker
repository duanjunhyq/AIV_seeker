#!/usr/bin/perl -w
# Detect Avian Influenza Virus in NGS Metagenomics DATA 
# Last changed Time-stamp: v0.1 <2018-05-15>
#
# Jun Duan
# BCCDC Public Health Laboratory
# University of British Columbia
# jun.duan@bccdc.ca
#
# William Hsiao, PhD
# Senior Scientist (Bioinformatics), BCCDC Public Health Laboratory
# Clinical Assistant Professor, Pathology & Laboratory Medicine, UBC
# Adjunct Professor, Molecular Biology and Biochemistry, SFU
# Rm 2067a, 655 West 12th Avenue 
# Vancouver, BC, V5Z 4R4
# Canada
# Tel: 604-707-2561
# Fax: 604-707-2603

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Config::IniFiles;

my ($help, $NGS_dir, $result_dir,$flow);
my ($step,$threads,$BSR,$margin,$percent);

GetOptions(
    'help|?' => \$help,
    'dir|i=s' => \$NGS_dir,
    'outputfile|o=s' => \$result_dir,
    'threads|t=s' => \$threads,
    'step|s=i' => \$step,
    'BSR|b=f' => \$BSR,
    'margin|m=f' => \$margin,
    'percent|p=f' => \$percent,
    'flow|f' => \$flow,
  );

if($help || !defined $NGS_dir || !defined $result_dir ) {

die <<EOF;

################################################

Pipeline for detecting Avian Influenza Virus from NGS Data

BC Centre for Disease Control
University of British Columbia

AIV_seeker V0.1: Last changed Time-stamp: <2018-05-15>

################################################

Usage: perl AIV_seeker_v0.1.pl -i run_folder -o result_folder    
         -i	path for NGS fastq file directory
         -o	result folder
         -s	step number
         		step 1: Generate the fastq file list
         		step 2: Generate QC report
         		step 3: Quality filtering and merging
         		step 4: First search by Diamond
         		step 5: Get possible AIV reads from Diamond result and do clustering
         		step 6: Assign_subtype based on GISAID database
         		step 7: Generate report
         -f	run the current step and following steps (default false), no parameter
         -b	BSR score (default 0.4)
         -m	margin of BSR score (default 0.3)
         -p	percentage of concordant subtype (default 0.9)
         -t	number of threads
         -h	display help message
         
EOF
}

################################################
my $exe_path = dirname(__FILE__);
my $config_file = "$exe_path/config/config.ini";
our $ini = Config::IniFiles->new(
        -file    => $config_file
        ) or die "Could not open $config_file!";

my $path_db = $ini->val( 'database', 'path_db' );


$step = $step || 0;
$threads = $threads || 45;
$BSR = $BSR || 0.4;
$margin = $margin || 0.3;
$percent = $percent || 0.9;


if (-d "$NGS_dir") {
	 	    $NGS_dir=~s/\/$//;
    }
else {
        print "The input fastq file directory is not existing, please check!\n";
        exit;
	 }

check_folder($result_dir);
check_folder("$result_dir/tmp");
my $run_list="$result_dir/filelist.txt";

if($step==1 or $step==0) {
				&check_filelist($run_list);
				if($flow) { 
				    	  $step=2;
				   }			
    }
my @files=&get_lib_list($run_list);

if($step>1) {
		if($step==2) {
				    &QC_report($result_dir,\@files);
				    if($flow) { 
				    	  $step=$step+1;
				    	}
        }
    if($step==3) {
				    &quality_filtering($result_dir,\@files);	
				    if($flow) { 
				    	  $step=$step+1;
				    	}
        }
    if($step==4) {
				    &search_by_diamond($result_dir,\@files);	
				    if($flow) { 
				    	  $step=$step+1;
				    	}
        }
    if($step==5) {
				    &cluster_reads($result_dir,\@files);	
				    if($flow) { 
				    	  $step=$step+1;
				    	}
        }
    if($step==6) {
				    &assign_subtype($result_dir,\@files);	
				    if($flow) { 
				    	  $step=$step+1;
				    	}
        }
    if($step==7) {
    	      my $gc_sum="$result_dir/sum.txt";
    	      my $output_prefix="report_cluster";
    	      my $input="$result_dir/$output_prefix\_unsorted_sum.txt";
    	      my $output="$result_dir/$output_prefix";
				    &generate_report_cluster($result_dir,$gc_sum,$input,$output);	
				    if($flow) { 
				    	  $step=$step+1;
				    	}
        }
    if($step==8) {
				    &cross_contamination_check_pos($result_dir,\@files);	
				    my $gc_sum="$result_dir/sum.txt";
    	      my $output_prefix="report_cluster_de_contamination";
    	      my $input="$result_dir/9.cross_contamination_check/subtype_report_unsorted.txt";
    	      my $output="$result_dir/9.cross_contamination_check/$output_prefix";
				    #&generate_report_cluster($result_dir,$gc_sum,$input,$output);	
        }
    }

    
################################################

sub get_lib_list() {
    my ($run_list) = @_;
    my @libs;
		open(IN,$run_list);
		while(<IN>) {
				chomp;
				my $line=$_;
				if($line) {
						push @libs,$line;
					}
			  			
		 }
		close IN;
		return @libs;
	}
	
sub check_filelist() {
	  my ($run_list) = @_;
		if (-e $run_list) {
				print "File list is already existing. Would you like to generate a new list (Y/N):";
				my $checkpoint;
				do {
						my $input = <STDIN>;
						chomp $input;
      			if($input =~ m/^[Y]$/i) {
      					 system("perl $exe_path/module/scan_NGS_dir.pl -i $NGS_dir -o $run_list");
      					 $checkpoint=1;
      				 } 
      			 elsif ($input =~ m/^[N]$/i) {
          			 print "You said no, so we will use the existing $run_list\n";
          			 $checkpoint=2;
      				 } 
      			 else {
         				 print "Invalid option, please input again (Y/N):";
      				 }
      		 } while ($checkpoint<1) ;
       }
       else {
       			 system("perl $exe_path/module/scan_NGS_dir.pl -i $NGS_dir -o $run_list");
       	}
     }

sub check_folder {
		my ($folder) = @_;
		if (-d $folder) { }
		else {
   			 mkdir $folder;
   		}		 
  }

sub QC_report () {
	  my ($result_dir,$files) = @_;
	  my $dir_raw="$result_dir/0.raw_fastq";
    my $dir_QC="$result_dir/1.QC_report";
		check_folder($dir_raw);
		check_folder($dir_QC);
		foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
  		      system("gunzip -c $libs[1] >$dir_raw/$libname\_R1.fq");
				    system("gunzip -c $libs[2] >$dir_raw/$libname\_R2.fq");
				    system("fastqc -t $threads $dir_raw/$libname\_R1.fq -o $dir_QC");
				    system("fastqc -t $threads $dir_raw/$libname\_R2.fq -o $dir_QC");
 	      }
	}

sub quality_filtering () {
	  my ($result_dir,$files) = @_;
	  my $dir_raw="$result_dir/0.raw_fastq";
    my $dir_file_processed="$result_dir/2.file_processed";
    my $dir_fasta_processed="$result_dir/3.fasta_processed";
		check_folder($dir_file_processed);
		check_folder($dir_fasta_processed);
		my $trimmomatic = $ini->val( 'tools', 'trimmomatic');
    my $flash = $ini->val( 'tools', 'flash');
    my $fastq_to_fasta = $ini->val( 'tools', 'fastq_to_fasta');
    my $adaptor = $ini->val( 'database', 'adaptor');
		foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            system("perl $exe_path/module/convert_fastq_name.pl $dir_raw/$libname\_R1.fq $dir_raw/$libname\_N\_R1.fq");
				    system("rm -fr $dir_raw/$libname\_R1.fq");
				    system("perl $exe_path/module/convert_fastq_name.pl $dir_raw/$libname\_R2.fq $dir_raw/$libname\_N\_R2.fq");
				    system("rm -fr $dir_raw/$libname\_R2.fq");
            system("java -jar $trimmomatic PE -threads $threads -phred33 $dir_raw/$libname\_N\_R1.fq $dir_raw/$libname\_N\_R2.fq $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_S\_R1.fq $dir_file_processed/$libname\_P\_R2.fq  $dir_file_processed/$libname\_S\_R2.fq  ILLUMINACLIP\:$adaptor\:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20  MINLEN:60");
            system("$flash -o $libname -d $dir_file_processed $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_P\_R2.fq -t $threads");
            system("cat $dir_file_processed/$libname\.extendedFrags.fastq $dir_file_processed/$libname\.notCombined_1.fastq $dir_file_processed/$libname\.notCombined_2.fastq $dir_file_processed/$libname\_S\_R1.fq $dir_file_processed/$libname\_S\_R2.fq >$dir_file_processed/$libname\_combine.fastq");
            system("$fastq_to_fasta -Q 33 -i $dir_file_processed/$libname\_combine.fastq -o $dir_fasta_processed/$libname\_ok.fasta");
            #####
            system("perl $exe_path/module/sum_fastq_file.pl -i $dir_raw/$libname\_N\_R1.fq >>$result_dir/fastq_sequence_sum.txt"); 
	          system("perl $exe_path/module/sum_fastq_file.pl -i $dir_raw/$libname\_N\_R2.fq >>$result_dir/fastq_sequence_sum.txt"); 
	          system("perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_P\_R1.fq >>$result_dir/fastq_sequence_sum.txt"); 
	          system("perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_P\_R2.fq >>$result_dir/fastq_sequence_sum.txt"); 
	          system("perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_S\_R1.fq >>$result_dir/fastq_sequence_sum.txt"); 
	          system("perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_S\_R2.fq >>$result_dir/fastq_sequence_sum.txt"); 
	          system("perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\.extendedFrags.fastq >>$result_dir/fastq_sequence_sum.txt"); 
	          system("perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\.notCombined_1.fastq >>$result_dir/fastq_sequence_sum.txt"); 
	          system("perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\.notCombined_2.fastq >>$result_dir/fastq_sequence_sum.txt"); 
	          system("perl $exe_path/module/sum_fastq_file.pl -i $dir_file_processed/$libname\_combine.fastq >>$result_dir/fastq_sequence_sum.txt"); 
      }
    system("perl $exe_path/module/sum_table.pl -i $result_dir/fastq_sequence_sum.txt -o $result_dir/sum.txt");

}

############################################################################################

sub search_by_diamond () {
	  my ($result_dir,$files) = @_;
	  my $dir_fasta_processed="$result_dir/3.fasta_processed";
	  my $dir_diamond="$result_dir/4.diamond";
	  my $diamond_db = $ini->val( 'database', 'diamond_db');
    my $diamond = $ini->val( 'tools', 'diamond');
	  check_folder($dir_diamond);	
	  foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            system("$diamond blastx -d $diamond_db -q $dir_fasta_processed/$libname\_ok\.fasta -a $libname -e 0.00001 -p $threads -t $result_dir/tmp --salltitles");
            system("$diamond view -a $libname\.daa -o $dir_diamond/$libname\.m8");
            system("rm -fr $libname\.daa");
        }
}

sub cluster_reads () {
	  my ($result_dir,$files) = @_;
	  my $dir_candidate_AIV_reads="$result_dir/5.candidate_AIV_reads";
	  my $dir_diamond="$result_dir/4.diamond";
	  my $dir_fasta_processed="$result_dir/3.fasta_processed";
		check_folder($dir_candidate_AIV_reads);
		foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            my $source=$libs[3];
            my $usearch = $ini->val( 'tools', 'usearch');
            system("perl $exe_path/module/get_reads_fist_round.pl -i $dir_diamond/$libname\.m8 -d $dir_fasta_processed/$libname\_ok\.fasta -o $dir_candidate_AIV_reads/$libname\_reads_first_round.fa");
            system("$usearch -sortbylength $dir_candidate_AIV_reads/$libname\_reads_first_round.fa -fastaout $dir_candidate_AIV_reads/$libname\_reads_first_round_sorted.fa");
		        system("$usearch -cluster_fast $dir_candidate_AIV_reads/$libname\_reads_first_round_sorted.fa -id 0.99 -centroids $dir_candidate_AIV_reads/$libname\_reads_cluster.fa -uc $dir_candidate_AIV_reads/$libname\_reads_cluster.uc -strand both --sizeout");
            system("perl $exe_path/module/cal_duplication_ratio.pl -i $libname -s $source -m $dir_candidate_AIV_reads/$libname\_reads_first_round.fa -n $dir_candidate_AIV_reads/$libname\_reads_cluster.fa -o $result_dir/PCR_dup_rate.txt");
       }
}

sub assign_subtype () {
	  my ($result_dir,$files) = @_;
	  my $dir_candidate_AIV_reads="$result_dir/5.candidate_AIV_reads";
	  my $cluster_blast_out="$result_dir/6.cluster_blast";
	  my $cluster_subtype="$result_dir/7.cluster_subtype";
	  my $cluster_subtype_seq="$result_dir/8.subtype_seq";
		check_folder($cluster_blast_out);
		check_folder($cluster_subtype);
		check_folder($cluster_subtype_seq);
		foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            my $source=$libs[3];
            my $usearch = $ini->val( 'tools', 'usearch');
            my $GISAID = $ini->val( 'database', 'GISAID');
            my $GISAID_relation = $ini->val( 'database', 'GISAID_relation');
            system("blastall -i $dir_candidate_AIV_reads/$libname\_reads_cluster.fa -d $GISAID -o $cluster_blast_out/$libname\_blastout.m8 -p blastn -e 1e-20 -F F -v 250 -v 250 -m 8 -a $threads");
            system("formatdb -i $dir_candidate_AIV_reads/$libname\_reads_cluster.fa -p F");
				    system("blastall -p blastn -i $dir_candidate_AIV_reads/$libname\_reads_cluster.fa -d $dir_candidate_AIV_reads/$libname\_reads_cluster.fa -o $cluster_blast_out/$libname\_self.m8 -m 8 -e 1e-10 -F F -b 1 -v 1 -a $threads");
				    system("perl $exe_path/module/parse_m8_s1.pl -i $cluster_blast_out/$libname\_blastout.m8 -s $cluster_blast_out/$libname\_self.m8 -d $GISAID_relation -o $cluster_blast_out/$libname\_sorted.txt");
				    system("perl $exe_path/module/assign_subtype.pl -i $cluster_blast_out/$libname\_sorted.txt -o $cluster_subtype/$libname\_subtype.txt -u $cluster_subtype/$libname\_unclassified.txt -s $cluster_subtype/$libname\_summary.txt -m $margin -b $BSR -p $percent");
				    system("perl $exe_path/module/getseq_subtype.pl -i $cluster_subtype/$libname\_subtype.txt -d $dir_candidate_AIV_reads/$libname\_reads_cluster.fa -o $cluster_subtype_seq");
   
       }
}

sub generate_report_cluster () {
	  my ($result_dir,$gc_sum,$input,$output) = @_;
	  my $cluster_subtype="$result_dir/7.cluster_subtype";
	  if(-e $input) {
	  	   system("rm -fr $input");
	  	}
	  system("cat $cluster_subtype/*summary.txt >>$input");
  	system("perl $exe_path/module/generate_report_cluster.pl -i $input -m $gc_sum -o $output");
}

sub cross_contamination_check () {
	  my ($result_dir,$files) = @_;
	  my $cross_contamination_dir="$result_dir/9.cross_contamination_check";
	  my $cluster_debled_bed="$cross_contamination_dir/1.bed";
	  my $cluster_debled_bed_top="$cross_contamination_dir/2.bed_top_hit";
	  my $cluster_debled_bed_combined_by_run="$cross_contamination_dir/3.bed_combined_by_run";
	  my $cluster_debled_bed_first_screen="$cross_contamination_dir/4.first_screen";
	  my $cluster_check="$cross_contamination_dir/5.check";
	  my $cluster_blast_out="$result_dir/6.cluster_blast";
	  my $cluster_debled_subtype="$cross_contamination_dir/8.subtype_contamination_removed";
	  my $dir_candidate_AIV_reads="$result_dir/5.candidate_AIV_reads";
	  my $cluster_debled_reads="$cross_contamination_dir/9.reads_contamination_removed";
		check_folder($cluster_debled_reads);
	  check_folder($cluster_check);
	  check_folder($cross_contamination_dir);
	  check_folder($cluster_debled_bed);	
	  check_folder($cluster_debled_bed_top);
	  check_folder($cluster_debled_bed_combined_by_run);
	  check_folder($cluster_debled_bed_first_screen);
	  check_folder($cluster_debled_subtype);
	  check_folder($cluster_debled_reads);
	  foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            my $source=$libs[3];
            #system("perl $exe_path/module/m8_to_bed_cluster.pl -i $result_dir/6.cluster_blast/$libname\_blastout.m8 -m $cluster_debled_bed/$libname\_bed.txt -n $cluster_debled_bed_top/$libname\_top_bed.txt -l $libname -s $source");
				    #system("cat $cluster_debled_bed/$libname\_bed.txt >>$cluster_debled_bed_combined_by_run/$source\_bed_all.txt");
        }
    foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            my $source=$libs[3];
            if ( -s "$cluster_debled_bed_top/$libname\_top_bed.txt") {
			  	      my $folder_screen="$cluster_debled_bed_first_screen/$source";
			  	      check_folder($folder_screen);
				        if ( -s "$folder_screen/$libname\_overlap_S_bed.txt") {
				               # system("perl $exe_path/module/create_overlap_folder.pl -i $folder_screen/$libname\_overlap_S_bed.txt -d $folder_screen/$libname\_overlap_C_bed.txt -f $cluster_check -s $source -l $libname");
				             }				    
			         } 
        
        }
     #system("perl $exe_path/module/compare_overlap_draw_one_vs_others.pl -i $cluster_check -l 0.7"); 
     foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            my $source=$libs[3];
			  	  #system("perl $exe_path/module/assign_subtype_cluster_debled.pl -i $cluster_blast_out/$libname\_sorted.txt -o $cluster_debled_subtype/$libname\_subtype.txt -u $cluster_debled_subtype/$libname\_unclassified.txt -s $cluster_debled_subtype/$libname\_summary.txt -m $margin -b $BSR -p $percent -d $cross_contamination_dir/7.overlap_checked/$libname\_overlap_remove_final.txt");
		        #system("perl $exe_path/module/getseq_subtype.pl -i $cluster_debled_subtype/$libname\_subtype.txt -d $dir_candidate_AIV_reads/$libname\_reads_cluster.fa -o $cluster_debled_reads");
			   
       }
     #system("cat $cluster_debled_subtype/*summary.txt >$cross_contamination_dir/subtype_report_unsorted.txt");
    
}


sub cross_contamination_check_pos () {
	  my ($result_dir,$files) = @_;
	  my $cross_contamination_dir="$result_dir/9.cross_contamination_check_pos";
	  my $cluster_debled_bed="$cross_contamination_dir/1.bed";
	  my $cluster_debled_bed_top="$cross_contamination_dir/2.bed_top_hit";
	  my $cluster_debled_bed_combined_by_run="$cross_contamination_dir/3.bed_combined_by_run";
	  my $cluster_debled_bed_first_screen="$cross_contamination_dir/4.first_screen";
	  my $cluster_check="$cross_contamination_dir/5.check";
	  my $cluster_blast_out="$result_dir/6.cluster_blast";
	  my $cluster_debled_subtype="$cross_contamination_dir/8.subtype_contamination_removed";
	  my $dir_candidate_AIV_reads="$result_dir/5.candidate_AIV_reads";
	  my $cluster_debled_reads="$cross_contamination_dir/9.reads_contamination_removed";
		check_folder($cluster_debled_reads);
	  check_folder($cluster_check);
	  check_folder($cross_contamination_dir);
	  check_folder($cluster_debled_bed);	
	  check_folder($cluster_debled_bed_top);
	  check_folder($cluster_debled_bed_combined_by_run);
	  check_folder($cluster_debled_bed_first_screen);
	  check_folder($cluster_debled_subtype);
	  check_folder($cluster_debled_reads);
	  foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            my $source=$libs[3];
            #system("perl $exe_path/module/m8_to_bed_cluster.pl -i $result_dir/6.cluster_blast/$libname\_blastout.m8 -m $cluster_debled_bed/$libname\_bed.txt -n $cluster_debled_bed_top/$libname\_top_bed.txt -l $libname -s $source");
				    #system("cat $cluster_debled_bed/$libname\_bed.txt >>$cluster_debled_bed_combined_by_run/$source\_bed_all.txt");
        }
    foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            my $source=$libs[3];
            if ( -s "$cluster_debled_bed_top/$libname\_top_bed.txt") {
			  	      my $folder_screen="$cluster_debled_bed_first_screen/$source";
			  	      check_folder($folder_screen);
				        if ( -s "$folder_screen/$libname\_overlap_S_bed.txt") {
				                system("perl $exe_path/module/create_overlap_folder.pl -i $folder_screen/$libname\_overlap_S_bed.txt -d $folder_screen/$libname\_overlap_C_bed.txt -f $cluster_check -s $source -l $libname");
				             }				    
			         } 
        
        }
     system("perl $exe_path/module/compare_overlap_draw_one_vs_others.pl -i $cluster_check -l 0.7"); 
     foreach my $items(@$files) {
            my @libs= split(/\t/,$items); 
            my $libname=$libs[0];
            my $source=$libs[3];
			  	  system("perl $exe_path/module/assign_subtype_cluster_debled.pl -i $cluster_blast_out/$libname\_sorted.txt -o $cluster_debled_subtype/$libname\_subtype.txt -u $cluster_debled_subtype/$libname\_unclassified.txt -s $cluster_debled_subtype/$libname\_summary.txt -m $margin -b $BSR -p $percent -d $cross_contamination_dir/7.overlap_checked/$libname\_overlap_remove_final.txt");
		        system("perl $exe_path/module/getseq_subtype.pl -i $cluster_debled_subtype/$libname\_subtype.txt -d $dir_candidate_AIV_reads/$libname\_reads_cluster.fa -o $cluster_debled_reads");
			   
       }
     system("cat $cluster_debled_subtype/*summary.txt >$cross_contamination_dir/subtype_report_unsorted.txt");
    
}
