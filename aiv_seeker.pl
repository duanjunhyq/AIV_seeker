#!/usr/bin/env perl
# Detect avian influenza virus in NGS metagenomics DATA 

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my ($help, $NGS_dir, $result_dir,$flow,$auto,$run_cluster,$run_galaxy,$run_debled,$run_paired_only,$keep_running_folder);
my ($step,$threads,$BSR,$margin,$percent,$overlap_level,$level,$identity_threshold,$cluster_identity,$chimeric_threshold);

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
    'identity_threshold|x=f' => \$identity_threshold,
    'chimeric_threshold|z=f' => \$chimeric_threshold,
    'level|l=f' => \$overlap_level,
    'cluster_identity|c=f' => \$cluster_identity,
    'run_cluster|a' => \$run_cluster,
    'run_galaxy|g' => \$run_galaxy,
    'run_debled|w' => \$run_debled,
    'keep_running_folder|u' => \$keep_running_folder,
    'run_paired_only|k' => \$run_paired_only,
  );

if($help || !defined $NGS_dir || !defined $result_dir ) {

die <<EOF;

####################################################################

░█████╗░██╗██╗░░░██╗░██████╗███████╗███████╗██╗░░██╗███████╗██████╗░
██╔══██╗██║██║░░░██║██╔════╝██╔════╝██╔════╝██║░██╔╝██╔════╝██╔══██╗
███████║██║╚██╗░██╔╝╚█████╗░█████╗░░█████╗░░█████═╝░█████╗░░██████╔╝
██╔══██║██║░╚████╔╝░░╚═══██╗██╔══╝░░██╔══╝░░██╔═██╗░██╔══╝░░██╔══██╗
██║░░██║██║░░╚██╔╝░░██████╔╝███████╗███████╗██║░╚██╗███████╗██║░░██║
╚═╝░░╚═╝╚═╝░░░╚═╝░░░╚═════╝░╚══════╝╚══════╝╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝                       

AIV_seeker(v0.2) maintained by duanjun1981\@gmail.com

Centre for Infectious Disease Genomics and One Health
Simon Fraser University

https://github.com/duanjunhyq/AIV_seeker

####################################################################

AIV_seeker: A pipeline for detecting avian influenza virus from NGS metagenomics Data

Usage: aiv_seeker.pl -i run_folder -o result_folder -s 1 -f 
         -i path for NGS fastq file directory
         -o result folder
         -s step number
            step 1: Generate the fastq file list
            step 2: Generate QC report
            step 3: Quality filtering
            step 4: First round search by Diamond
            step 5: Group reads to remove duplicates
            step 6: Second round search by BLAST
            step 7: Remove chimeric sequences
            step 8: Assign subtypes and generate report
            step 9: cross-contamination detection and generate report
         -f only run the designated step (defined by -s, default false), no parameter
         -b BSR score (default 0.4)
         -m margin of BSR score (default 0.3)
         -p percentage of concordant subtype (default 0.9)
         -t number of threads (default 2)
         -h display help message
         -l overlap level (default 0.7)
         -x threshold for identity (default 90%)
         -z threshold for chimeric check (default 75%)
         -c identity for clustering when dealing with cross-talking (default 0.97)
         -a run by cluster (default false)
         -g run galaxy job (default false)
         -w run debleeding process
         -k generate results based on paired reads only (remove unpaired reads)
         -u keep the intermediate files (default remove)
         
EOF
}

my $exe_path = dirname(__FILE__);
# my $config_file = "$exe_path/config/config.ini";
# my $config = new Config::Simple($config_file);
# my $fastqc = $config->param('fastqc');
# my $multiqc = $config->param('multiqc');
# my $blast = $config->param('blast');

my $path_db = "$exe_path/database";
$step = $step || 1;
$threads = $threads || 2;
$BSR = $BSR || 0.4;
$margin = $margin || 0.3;
$percent = $percent || 0.9;
$overlap_level = $overlap_level || 0.7;
$identity_threshold = $identity_threshold || 90;
$chimeric_threshold = $chimeric_threshold || 0.75;
$cluster_identity=$cluster_identity || 0.97;

if (-d "$NGS_dir") {
    $NGS_dir=~s/\/$//;
}
else {
    print "The input fastq file directory is not existing, please check!\n";
    exit;
}

my $result_dir_work="$result_dir/tmp_dir";
check_folder($result_dir_work);
my $logs="$result_dir_work/logs";
check_folder($logs);

my $run_list="$result_dir_work/filelist.txt";
if($flow) {
    $auto=0;
}
else {
    $auto=1;
}


if($step==1) {
    &check_filelist($run_list);
    if($auto) {
        $step=$step+1;
    }
}

my @files=&get_lib_list($run_list);

if($step>1) {
    if($step==2) {
        &QC_report($result_dir_work,\@files);
        if($auto) {
            $step=$step+1;
        }
    }

    if($step==3) {
        if(-s "$result_dir_work/fastq_sequence_sum.txt") {
            system("rm -fr $result_dir_work/fastq_sequence_sum.txt");
        }
        &quality_filtering($result_dir_work,\@files);
        if($run_cluster) {
            system("cat $result_dir_work/tmp/*\_fastq_sequence_sum.txt >$result_dir_work/fastq_sequence_sum.txt");
        }
        system("perl $exe_path/src/sum_table.pl -i $result_dir_work/fastq_sequence_sum.txt -o $result_dir_work/sum.txt");
        if($auto) {
            $step=$step+1;
        }
    }

    if($step==4) {
        check_folder("$result_dir_work/tmp");
        &search_by_diamond($result_dir_work,\@files);
        if($run_cluster) {
            check_qsub_status("aiv_seeker-diamond");
        }
        if($auto) {
            $step=$step+1;
        }
    }

    if($step==5) {
        &get_AIV_reads($result_dir_work,\@files);
        if($run_cluster) {
            check_qsub_status("aiv_seeker-extract");
        }
        &cluster_AIV_reads_vsearch($result_dir_work,\@files);
        if($run_cluster) {
            check_qsub_status("aiv_seeker-vsearch");
        }
        if($auto) {
            $step=$step+1;
        }
    }

    if($step==6) {
        &blast_AIV($result_dir_work,\@files);
        if($auto) {
            $step=$step+1;
        }
    }

    if($step==7) {
        &remove_chimeric($result_dir_work,\@files);
        if($auto) {
            $step=$step+1;
        }
    }

    if($step==8) {
        &assign_subtype_raw($result_dir_work,\@files);
        &raw_report($result_dir,$result_dir_work,\@files);
        if($auto) {
            $step=$step+1;
        }
    }

    if($step==9 and $run_debled) {
        &debleeding($result_dir_work,\@files);
        &assign_subtype_debled($result_dir_work,\@files);
        &debled_report($result_dir,$result_dir_work,\@files);
    }
    
    #delete tmp files
    if($keep_running_folder){}
    else {
        system("rm -fr $result_dir_work");
    } 

    #step101 is a testing function to generate coverage map (assuming only contain one strain for each sample)
    if($step==101) {
        &find_refseq($result_dir_work,\@files);
        &get_depth($result_dir_work,\@files);
    }
}

    
sub check_filelist() {
    my ($run_list) = @_;
    if (-s $run_list) {
        print "File list is already existing. Would you like to generate a new list (Y/N):";
        my $checkpoint;
        do {
            my $input = <STDIN>;
            chomp $input;
            if($input =~ m/^[Y]$/i) {
                system("perl $exe_path/src/scan_NGS_dir.pl -i $NGS_dir -o $run_list");
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
        system("perl $exe_path/src/scan_NGS_dir.pl -i $NGS_dir -o $run_list");
    }
}

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

sub QC_report () {
    my ($result_dir_work,$files) = @_;
    my $dir_raw="$result_dir_work/0.raw_fastq";
    my $dir_QC="$result_dir_work/1.QC_report";
    my $dir_multiQC="$result_dir_work/2.multiQC";
    check_folder($dir_raw);
    check_folder($dir_QC);
    check_folder($dir_multiQC);
    foreach my $items(@$files) {
        my @libs= split(/\t/,$items); 
        my $libname=$libs[0];
        if($run_cluster) {
            my $shell= "qsub -o $logs -e $logs -pe mpi $threads $exe_path/src/batch_qsub_fastqc.sh $libs[1] $libs[2] $result_dir_work $libname $threads";
            system($shell);
        }
        else {
            if($libs[1]=~/\.fq$/i) {
                system("ln -s $libs[1] $dir_raw/$libname\_R1.fq");
                system("ln -s $libs[2] $dir_raw/$libname\_R2.fq");
            }
            elsif($libs[1]=~/\.fastq$/i) {
                system("ln -s $libs[1] $dir_raw/$libname\_R1.fq");
                system("ln -s $libs[2] $dir_raw/$libname\_R2.fq");
            }
            elsif($libs[1]=~/\.gz$/i) {
                system("gunzip -c $libs[1] >$dir_raw/$libname\_R1.fq");
                system("gunzip -c $libs[2] >$dir_raw/$libname\_R2.fq");
            }
            elsif($libs[1]=~/\.dat$/i){
                system("ln -s $libs[1] $dir_raw/$libname\_R1.fq");
                system("ln -s $libs[2] $dir_raw/$libname\_R2.fq");
            }
            else {
                print "Please check your input files are ended with fq, fastq, dat, or gz";
                exit;
            }
            system("conda run -n aiv_seeker-fastqc fastqc -t $threads $dir_raw/$libname\_R1.fq -o $dir_QC");
            system("conda run -n aiv_seeker-fastqc fastqc -t $threads $dir_raw/$libname\_R2.fq -o $dir_QC");
        }      
    }
    if($run_cluster) {
        check_qsub_status("aiv_seeker-fastqc");
    }
    system("conda run -n aiv_seeker-multiqc multiqc -n multiQC_report -f $dir_QC -o $dir_multiQC");
}


sub quality_filtering () {
    my ($result_dir_work,$files) = @_;
    my $dir_raw="$result_dir_work/0.raw_fastq";
    my $dir_file_processed="$result_dir_work/3.file_processed";
    my $dir_fasta_processed="$result_dir_work/4.fasta_processed";
    check_folder($dir_file_processed);
    check_folder($dir_fasta_processed);
    my $adaptor = "$path_db/adapter.fa";
    if($run_cluster) {
        check_folder("$result_dir_work/tmp");
        foreach my $items(@$files) {
            my @libs= split(/\t/,$items);
            my $libname=$libs[0];
            my $shell;
            if($run_cluster) {
                if($run_paired_only) {
                    my $run_paired_only_tag="True";
                    $shell= "qsub -o $logs -e $logs -pe mpi $threads $exe_path/src/batch_qsub_filtering.sh $exe_path $libname $result_dir_work $adaptor $threads $run_paired_only_tag";
                }
                else {
                    $shell= "qsub -o $logs -e $logs -pe mpi $threads $exe_path/src/batch_qsub_filtering.sh $exe_path $libname $result_dir_work $adaptor $threads";
                }
            system($shell);
            }
        }
        check_qsub_status("aiv_seeker-filtering");
        system("rm -fr $result_dir_work/tmp/*");
        foreach my $items(@$files) {
            my @libs= split(/\t/,$items);
            my $libname=$libs[0];
            my $shell= "qsub -o $logs -e $logs -pe mpi $threads $exe_path/src/batch_qsub_stat.sh $exe_path $libname $result_dir_work";
            system($shell);
        }
        check_qsub_status("aiv_seeker-stat");
    }
    else {
        foreach my $items(@$files) {
            my @libs= split(/\t/,$items);
            my $libname=$libs[0];
            system("perl $exe_path/src/convert_fastq_name.pl $dir_raw/$libname\_R1.fq $dir_raw/$libname\_N\_R1.fq");
            system("rm -fr $dir_raw/$libname\_R1.fq");
            system("perl $exe_path/src/convert_fastq_name.pl $dir_raw/$libname\_R2.fq $dir_raw/$libname\_N\_R2.fq");
            system("rm -fr $dir_raw/$libname\_R2.fq");
            system("conda run -n aiv_seeker-trimmomatic trimmomatic PE -threads $threads -phred33 $dir_raw/$libname\_N\_R1.fq $dir_raw/$libname\_N\_R2.fq $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_S\_R1.fq $dir_file_processed/$libname\_P\_R2.fq  $dir_file_processed/$libname\_S\_R2.fq  ILLUMINACLIP\:$adaptor\:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20  MINLEN:60");
            if($run_paired_only) {
                system("cat $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_P\_R2.fq >$dir_file_processed/$libname\_combine.fastq");
            }
            else {
                system("cat $dir_file_processed/$libname\_P\_R1.fq $dir_file_processed/$libname\_P\_R2.fq $dir_file_processed/$libname\_S\_R1.fq $dir_file_processed/$libname\_S\_R2.fq >$dir_file_processed/$libname\_combine.fastq");
            }      
            system("conda run -n aiv_seeker-fastx_toolkit fastq_to_fasta -Q 33 -i $dir_file_processed/$libname\_combine.fastq -o $dir_fasta_processed/$libname\_raw.fasta");
            system("perl $exe_path/src/sum_fastq_file.pl -i $dir_raw/$libname\_N\_R1.fq >>$result_dir_work/fastq_sequence_sum.txt");
            system("perl $exe_path/src/sum_fastq_file.pl -i $dir_raw/$libname\_N\_R2.fq >>$result_dir_work/fastq_sequence_sum.txt");
            system("perl $exe_path/src/sum_fastq_file.pl -i $dir_file_processed/$libname\_P\_R1.fq >>$result_dir_work/fastq_sequence_sum.txt");
            system("perl $exe_path/src/sum_fastq_file.pl -i $dir_file_processed/$libname\_P\_R2.fq >>$result_dir_work/fastq_sequence_sum.txt");
            system("perl $exe_path/src/sum_fastq_file.pl -i $dir_file_processed/$libname\_S\_R1.fq >>$result_dir_work/fastq_sequence_sum.txt");
            system("perl $exe_path/src/sum_fastq_file.pl -i $dir_file_processed/$libname\_S\_R2.fq >>$result_dir_work/fastq_sequence_sum.txt");
            system("perl $exe_path/src/sum_fastq_file.pl -i $dir_file_processed/$libname\_combine.fastq >>$result_dir_work/fastq_sequence_sum.txt");
        }
    }
}


sub search_by_diamond () {
    my ($result_dir_work,$files) = @_;
    my $dir_fasta_processed="$result_dir_work/4.fasta_processed";
    my $dir_diamond="$result_dir_work/5.diamond";
    my $diamond_db = "$path_db/avian_pep_db.dmnd";
    #my $diamond = $ini->val( 'tools', 'diamond');
    check_folder($dir_diamond); 
    foreach my $items(@$files) {
        my @libs= split(/\t/,$items);
        my $libname=$libs[0];
        if($run_cluster) {
            my $shell= "qsub -o $logs -e $logs -pe mpi $threads $exe_path/src/batch_qsub_diamond.sh $diamond_db $result_dir_work $libname $threads";
            system($shell);
        }
        else {
            system("conda run -n aiv_seeker-diamond diamond blastx -d $diamond_db -q $dir_fasta_processed/$libname\_raw\.fasta -o $dir_diamond/$libname\.m8 -e 100 -p $threads -t $result_dir_work/tmp --masking 0 ");
        }
    }
}


sub get_AIV_reads () {
  my ($result_dir_work,$files) = @_;
  my $dir_file_processed="$result_dir_work/4.fasta_processed";
  my $dir_diamond="$result_dir_work/5.diamond";
  my $aiv_reads_first_round="$result_dir_work/6.clustered_reads";    
  check_folder($aiv_reads_first_round);
  foreach my $items(@$files) {
    my @libs= split(/\t/,$items); 
    my $libname=$libs[0];
    if($run_cluster) {
      my $shell= "qsub -o $logs -e $logs $exe_path/src/batch_qsub_extract_seq.sh $exe_path $dir_diamond/$libname\.m8 $dir_file_processed/$libname\_raw\.fasta $aiv_reads_first_round/$libname\_first_round.fa";
      system($shell);
    }
    else {
      system("perl $exe_path/src/get_reads_first_round.pl -i $dir_diamond/$libname\.m8 -d $dir_file_processed/$libname\_raw\.fasta -o $aiv_reads_first_round/$libname\_first_round.fa");
    }
  }
}

sub cluster_AIV_reads_vsearch () {
    my ($result_dir_work,$files) = @_;
    my $aiv_reads="$result_dir_work/6.clustered_reads";
    foreach my $items(@$files) {
        my @libs= split(/\t/,$items);
        my $libname=$libs[0];
        my $source=$libs[3];
        my $p1="conda run -n aiv_seeker-vsearch vsearch --threads $threads --derep_fulllength $aiv_reads/$libname\_first_round.fa --output $aiv_reads/$libname\_reads_derep.fa --sizeout --uc $aiv_reads/$libname\_vsearch-derep.uc";
        my $p2="perl $exe_path/src/add_tag_to_seq.pl $aiv_reads/$libname\_reads_derep.fa $aiv_reads/$libname\_reads_derep_with_tag.fa $libname";
        if(-s "$aiv_reads/$libname\_first_round.fa") {
            if($run_cluster) {
                my $shell="qsub -o $logs -e $logs -pe mpi $threads $exe_path/src/batch_qsub_vsearch.sh $exe_path $aiv_reads $libname";
                system($shell);
            }
            else {
                system($p1);
                system($p2);
            }
        }
    }
}


sub blast_AIV () {
    my ($result_dir_work,$files) = @_;
    my $blast_dir="$result_dir_work/7.blast";
    my $blast_dir_vs_db="$blast_dir/1.blast_to_db";
    my $blast_dir_self="$blast_dir/2.blast_to_self";
    my $aiv_reads="$result_dir_work/6.clustered_reads";
    my $flu_ref_gene = "$path_db/aiv_gene_0.99";
    check_folder($blast_dir);
    check_folder($blast_dir_vs_db);
    check_folder($blast_dir_self);
    foreach my $items(@$files) {
        my @libs= split(/\t/,$items);
        my $libname=$libs[0];
        my $source=$libs[3];
        my $p1="conda run -n aiv_seeker-blast blastn -num_threads $threads -db $flu_ref_gene -query $aiv_reads/$libname\_reads_derep_with_tag.fa -evalue 1e-20 -out $blast_dir_vs_db/$libname\_blastout.m8 -outfmt 6 -num_alignments 250 -dust no";
        my $p2="conda run -n aiv_seeker-blast makeblastdb -in $aiv_reads/$libname\_reads_derep_with_tag.fa -dbtype nucl";
        my $p3="conda run -n aiv_seeker-blast blastn -num_threads $threads -db $aiv_reads/$libname\_reads_derep_with_tag.fa -query $aiv_reads/$libname\_reads_derep_with_tag.fa -out $blast_dir_self/$libname\_self.m8 -outfmt 6 -num_alignments 1 -dust no";
        if($run_cluster) {
            my $shell="qsub -o $logs -e $logs -pe mpi $threads $exe_path/src/batch_qsub_blast.sh $aiv_reads/$libname\_reads_derep_with_tag.fa $blast_dir_vs_db/$libname\_blastout.m8 $blast_dir_self/$libname\_self.m8 $flu_ref_gene $threads";
            system($shell);
        }
        else {
            system($p1);
            system($p2);
            system($p3);
        }
    }
    if($run_cluster) {
        check_qsub_status("aiv_seeker-blast");
    }
}


sub remove_chimeric() {
    my ($result_dir_work,$files) = @_;
    my $dir_chimeric="$result_dir_work/8.check_chimeric";
    my $dir_chimeric_processed="$dir_chimeric/1.processed";
    my $dir_chimeric_seq="$dir_chimeric/2.de_chimeric_seq";
    my $blast_dir="$result_dir_work/7.blast";
    my $blast_dir_vs_db="$blast_dir/1.blast_to_db";
    my $blast_dir_self="$blast_dir/2.blast_to_self";
    my $aiv_reads="$result_dir_work/6.clustered_reads";
    check_folder($dir_chimeric);
    check_folder($dir_chimeric_processed);
    check_folder($dir_chimeric_seq);
    foreach my $items(@$files) {
        my @libs= split(/\t/,$items);
        my $libname=$libs[0];
        my $source=$libs[3];
        if($run_cluster) {
            system("qsub -o $logs -e $logs $exe_path/src/batch_qsub_remove_chimeric.sh $exe_path $chimeric_threshold $blast_dir_vs_db/$libname\_blastout.m8 $aiv_reads/$libname\_reads_derep_with_tag.fa $dir_chimeric_processed/$libname\_chimeric\_$chimeric_threshold\.txt $dir_chimeric_processed/$libname\_without_chimeric\_$chimeric_threshold\.txt $dir_chimeric_seq/$libname\_no_chimeric.fa");
        }
        else {
            system("perl $exe_path/src/remove_chimeric.pl -c $chimeric_threshold -i $blast_dir_vs_db/$libname\_blastout.m8 -d $aiv_reads/$libname\_reads_derep_with_tag.fa -o $dir_chimeric_processed/$libname\_chimeric\_$chimeric_threshold\.txt >$dir_chimeric_processed/$libname\_without_chimeric\_$chimeric_threshold\.txt");
            if(-s "$dir_chimeric_processed/$libname\_without_chimeric\_$chimeric_threshold\.txt") {
                system("perl $exe_path/src/get_reads_first_round.pl -i $dir_chimeric_processed/$libname\_without_chimeric\_$chimeric_threshold\.txt -d $aiv_reads/$libname\_reads_derep_with_tag.fa -o $dir_chimeric_seq/$libname\_no_chimeric.fa");
            }
        }
    }
    if($run_cluster) {
        check_qsub_status("aiv_seeker-chimeric");
    }
}


sub debleeding() {
    my ($result_dir_work,$files) = @_;
    my %source_all;
    my $dir_chimeric_seq="$result_dir_work/8.check_chimeric/2.de_chimeric_seq";
    my $dir_debled="$result_dir_work/10.debled\_$overlap_level\_$cluster_identity";
    my $dir_combined_seq="$dir_debled/0.combined_seq";
    check_folder($dir_combined_seq);
    system("rm -fr $dir_combined_seq/*");
    foreach my $items(@$files) {
        my @libs= split(/\t/,$items);
        my $libname=$libs[0];
        my $source=$libs[3]; 
        if($source) {
            $source_all{$source}=1;
        }
        if(-s "$dir_chimeric_seq/$libname\_no_chimeric.fa") {
            system("cat $dir_chimeric_seq/$libname\_no_chimeric.fa >>$dir_combined_seq/$source\_debled_step1.fa");
        }
    }
    my $dir_debled_step1_vsearch_out="$dir_debled/1.step_vsearch_out";
    my $dir_debled_step2_otu="$dir_debled/2.step_otu";
    my $dir_debled_step3_otu_processed="$dir_debled/3.step_otu_processed";
    my $dir_debled_step4_cross="$dir_debled/4.step_cross_detection";
    my $dir_debled_step5_cross_removed="$dir_debled/5.step_cross_removed";
    my $dir_debled_step6_reads_list="$dir_debled/6.step_reads_list";
    my $debled_reads_ok="$dir_debled/7.debled_reads_ok";
    check_folder($dir_debled_step1_vsearch_out);
    check_folder($dir_debled_step2_otu);
    check_folder($dir_debled_step3_otu_processed);
    check_folder($dir_debled_step4_cross);
    check_folder($dir_debled_step5_cross_removed);
    check_folder($dir_debled_step6_reads_list);
    check_folder($debled_reads_ok);

    foreach my $source(keys %source_all) {
        if($run_cluster) {
            system("qsub -o $logs -e $logs -pe mpi $threads $exe_path/src/batch_qsub_debled.sh $exe_path $dir_combined_seq $source $cluster_identity $dir_debled $overlap_level $threads");
        }
        else {
            system("conda run -n aiv_seeker-vsearch vsearch --threads $threads --cluster_size $dir_combined_seq/$source\_debled_step1.fa --id $cluster_identity --target_cov $overlap_level --centroids $dir_debled_step1_vsearch_out/$source\_centroids.fa --uc $dir_debled_step1_vsearch_out/$source\_reads_cluster.uc --strand both --sizeout");
            system("perl $exe_path/src/parse_uc_to_otu.pl -i $dir_debled_step1_vsearch_out/$source\_reads_cluster.uc -m $dir_debled_step2_otu/$source\_otu.txt -n $dir_debled_step2_otu/$source\_otu_name.txt -x $dir_debled_step2_otu/$source\_otu_orginal.txt");
            system("perl $exe_path/src/parse_otu.pl -i $dir_debled_step2_otu/$source\_otu_orginal.txt -m $dir_debled_step3_otu_processed/$source\_otu_uniq.txt -n $dir_debled_step3_otu_processed/$source\_otu_cross.txt");
            system("perl $exe_path/src/detect_cross_talk.pl -i $dir_debled_step3_otu_processed/$source\_otu_cross.txt -o $dir_debled_step4_cross/$source\_otu_cross_removed.txt -m $dir_debled_step4_cross/$source\_otu_cross_multiple_dominant.txt -n $dir_debled_step4_cross/$source\_otu_cross_single_dominant.txt");
            system("cat $dir_debled_step3_otu_processed/$source\_otu_uniq.txt $dir_debled_step4_cross/$source\_otu_cross_removed.txt >$dir_debled_step5_cross_removed/$source\_otu_processed.txt");
            system("perl $exe_path/src/get_debleeded_reads_list_x.pl -i $dir_debled_step5_cross_removed/$source\_otu_processed.txt -d $dir_debled_step2_otu/$source\_otu_name.txt -o $dir_debled_step6_reads_list/$source\_reads_list_ok.txt");
            system("perl $exe_path/src/get_reads_first_round.pl -i $dir_debled_step6_reads_list/$source\_reads_list_ok.txt -d $dir_combined_seq/$source\_debled_step1.fa -o $dir_debled_step6_reads_list/$source\_reads_all_ok.fa");
            system("perl $exe_path/src/divide_fasta_into_lib.pl $dir_debled_step6_reads_list/$source\_reads_all_ok.fa $debled_reads_ok $source");
        }
    }
    if($run_cluster) {
        check_qsub_status("aiv_seeker-debleeding");
    }
}



sub assign_subtype_debled () {
    my ($result_dir_work,$files) = @_;
    my $blast_dir_vs_db="$result_dir_work/7.blast/1.blast_to_db";
    my $blast_dir_self="$result_dir_work/7.blast/2.blast_to_self";
    my $dir_debled="$result_dir_work/10.debled\_$overlap_level\_$cluster_identity";
    my $cluster_subtype="$dir_debled/8.subtype_debled";
    my $cluster_subtype_step1_blast_sorted="$cluster_subtype/1.step_blast_sorted";
    my $cluster_subtype_step2_subtype="$cluster_subtype/2.step_subtype_file";
    my $cluster_subtype_step3_seq="$cluster_subtype/3.step_subtype_seq";
    check_folder($cluster_subtype_step1_blast_sorted);
    check_folder($cluster_subtype_step2_subtype);
    check_folder($cluster_subtype_step3_seq);
    my $debled_reads_ok="$result_dir_work/10.debled\_$overlap_level\_$cluster_identity/7.debled_reads_ok";
    foreach my $items(@$files) {
        my @libs= split(/\t/,$items);
        my $libname=$libs[0];
        my $source=$libs[3];
        check_folder("$cluster_subtype_step3_seq/$source");
        #my $flu_ref_gene_relation = $ini->val( 'database', 'flu_ref_gene_relation');
        my $flu_ref_gene_relation = "$path_db/avian_flu_gene_0.99_relationship.txt";
        if(-s "$debled_reads_ok/$source/$libname\_reads_ok.fa") {
            if($run_cluster) {
                system("qsub -o $logs -e $logs $exe_path/src/batch_qsub_subtype_debled.sh $exe_path $result_dir_work $libname $cluster_identity $margin $BSR $percent $flu_ref_gene_relation $source $overlap_level");
            }
            else {
                system("perl $exe_path/src/parse_m8_BSR.pl -i $blast_dir_vs_db/$libname\_blastout.m8 -s $blast_dir_self/$libname\_self.m8 -d $flu_ref_gene_relation -o $cluster_subtype_step1_blast_sorted/$libname\_sorted.txt -m $debled_reads_ok/$source/$libname\_reads_ok.fa");
                if(-s "$cluster_subtype_step1_blast_sorted/$libname\_sorted.txt") {
                    system("perl $exe_path/src/assign_subtype_v2.pl -i $cluster_subtype_step1_blast_sorted/$libname\_sorted.txt -o $cluster_subtype_step2_subtype/$libname\_subtype.txt -u $cluster_subtype_step2_subtype/$libname\_unclassified.txt -m $margin -b $BSR -p $percent");
                    system("perl $exe_path/src/sum_subtype_depricated.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -o $cluster_subtype_step2_subtype/$libname\_summary_depricated.txt\n");
                    system("perl $exe_path/src/sum_subtype_uniq.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -o $cluster_subtype_step2_subtype/$libname\_summary_uniq.txt\n");
                    system("perl $exe_path/src/getseq_subtype.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -d $debled_reads_ok/$source/$libname\_reads_ok.fa -o $cluster_subtype_step3_seq/$source");
                }
            }
        }
  }
  if($run_cluster) {
      check_qsub_status("aiv_seeker-debled-subtype");
  }
}

sub debled_report() {
    my ($result_dir,$result_dir_work,$files) = @_;
    my $dir_report="$result_dir_work/10.debled\_$overlap_level\_$cluster_identity/9.report_debled";
    check_folder($dir_report);
    system("cat $result_dir_work/10.debled\_$overlap_level\_$cluster_identity/8.subtype_debled/2.step_subtype_file/*_summary_depricated.txt >$dir_report/subtype_report_debled_unsorted.txt");
    system("cat $result_dir_work/10.debled\_$overlap_level\_$cluster_identity/8.subtype_debled/2.step_subtype_file/*_summary_uniq.txt >$dir_report/subtype_report_debled_uniq_unsorted.txt");
    my $gc_sum="$result_dir_work/sum.txt";
    my $input="$dir_report/subtype_report_debled_unsorted.txt";
    my $input_uniq="$dir_report/subtype_report_debled_uniq_unsorted.txt";
    my $output="$dir_report/report_debled_raw";
    my $output_uniq="$dir_report/report_debled_uniq";
    &generate_report_cluster($gc_sum,$input,$output);
    &generate_report_cluster($gc_sum,$input_uniq,$output_uniq);
    if($run_galaxy) {}
    else {
        if($run_galaxy) {
        }
        else {
            system("python $exe_path/src/generate_heatmap_v0.3.py -i $dir_report/report_debled_raw_s2.tsv -o $dir_report/report_debled_raw");
            system("python $exe_path/src/generate_heatmap_v0.3.py -i $dir_report/report_debled_uniq_s2.tsv -o $dir_report/report_debled_uniq");
        }
    }
    system("rm -fr $input");
    system("rm -fr $input_uniq");

    #copy results
    system("cp -r $dir_report $result_dir");
    system("cp -r $result_dir_work/10.debled\_$overlap_level\_$cluster_identity/8.subtype_debled/3.step_subtype_seq $result_dir");
    system("mv $result_dir/9.report_debled $result_dir/report_debled");
    system("mv $result_dir/3.step_subtype_seq $result_dir/report_seq_debled");


}


sub check_folder {
  my ($folder) = @_;
  if (-d $folder) { }
  else {
      system("mkdir -p $folder");
    }    
}

sub generate_report_cluster () {
  my ($gc_sum,$input,$output) = @_;
  system("perl $exe_path/src/generate_report_cluster.pl -i $input -m $gc_sum -o $output");
}

sub check_qsub_status {
  my ($m) = @_;
  my $var=readpipe("qstat -xml|grep $m");
  $var=~s/\n//g;
  $var=~s/\+s//g;
  while($var=~/$m/) {
    sleep(10);
    $var=readpipe("qstat -xml|grep $m");
    $var=~s/\n//g;
    $var=~s/\+s//g;
  }
}

sub assign_subtype_raw () {
    my ($result_dir_work,$files) = @_;
    my $blast_dir_vs_db="$result_dir_work/7.blast/1.blast_to_db";
    my $blast_dir_self="$result_dir_work/7.blast/2.blast_to_self";
    my $cluster_subtype="$result_dir_work/9.subtype\_raw";
    my $cluster_subtype_step1_blast_sorted="$cluster_subtype/1.step_blast_sorted";
    my $cluster_subtype_step2_subtype="$cluster_subtype/2.step_subtype_file";
    my $cluster_subtype_step3_seq="$cluster_subtype/3.step_subtype_seq";
    my $dir_chimeric="$result_dir_work/8.check_chimeric";
    my $dir_chimeric_seq="$dir_chimeric/2.de_chimeric_seq";
    my $aiv_reads_first_round="$result_dir_work/6.clustered_reads";
    check_folder($cluster_subtype_step1_blast_sorted);
    check_folder($cluster_subtype_step2_subtype);
    check_folder($cluster_subtype_step3_seq);
    my $flu_reads_ok="$result_dir_work/6.clustered_reads";
    my $blast_db_ano = "$path_db/avian_flu_gene_0.99_relationship.txt";
    foreach my $items(@$files) {
        my @libs= split(/\t/,$items);
        my $libname=$libs[0];
        my $source=$libs[3];
        check_folder("$cluster_subtype_step3_seq/$source");
        if(-s "$dir_chimeric_seq/$libname\_no_chimeric.fa") {
            if($run_cluster) {
                my $shell="qsub -o $logs -e $logs $exe_path/src/batch_qsub_subtype_raw.sh $exe_path $result_dir_work $libname $margin $BSR $percent $blast_db_ano $source";
                system($shell);
            }
            else {
                system("perl $exe_path/src/parse_m8_BSR.pl -i $blast_dir_vs_db/$libname\_blastout.m8 -s $blast_dir_self/$libname\_self.m8 -d $blast_db_ano -o $cluster_subtype_step1_blast_sorted/$libname\_sorted.txt -m $dir_chimeric_seq/$libname\_no_chimeric.fa");
                if(-s "$cluster_subtype_step1_blast_sorted/$libname\_sorted.txt") {
                    system("perl $exe_path/src/assign_subtype_v2.pl -i $cluster_subtype_step1_blast_sorted/$libname\_sorted.txt -o $cluster_subtype_step2_subtype/$libname\_subtype.txt -u $cluster_subtype_step2_subtype/$libname\_unclassified.txt -m $margin -b $BSR -p $percent");
                    system("perl $exe_path/src/sum_subtype_depricated.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -o $cluster_subtype_step2_subtype/$libname\_summary_depricated.txt");
                    system("perl $exe_path/src/sum_subtype_uniq.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -o $cluster_subtype_step2_subtype/$libname\_summary_uniq.txt");
                    system("perl $exe_path/src/getseq_subtype.pl -i $cluster_subtype_step2_subtype/$libname\_subtype.txt -d $aiv_reads_first_round/$libname\_reads_derep_with_tag.fa -o $cluster_subtype_step3_seq/$source");
                }
            }
        }
    }
    if($run_cluster) {
        check_qsub_status("aiv_seeker-subtype");
    }
}

sub raw_report() {
    my ($result_dir,$result_dir_work,$files) = @_;
    my $dir_report="$result_dir_work/9.subtype_raw/4.report";
    check_folder($dir_report);
    system("cat $result_dir_work/9.subtype\_raw/2.step_subtype_file/*_summary_depricated.txt >$dir_report/subtype_report_raw_unsorted.txt");
    system("cat $result_dir_work/9.subtype\_raw/2.step_subtype_file/*_summary_uniq.txt >$dir_report/subtype_report_uniq_unsorted.txt");
    my $gc_sum="$result_dir_work/sum.txt";
    my $input="$dir_report/subtype_report_raw_unsorted.txt";
    my $input_uniq="$dir_report/subtype_report_uniq_unsorted.txt";
    my $output="$dir_report/report_raw";
    my $output_uniq="$dir_report/report_uniq";
    &generate_report_cluster($gc_sum,$input,$output);
    &generate_report_cluster($gc_sum,$input_uniq,$output_uniq);
    if($run_galaxy) {

    }
    else {
        system("python $exe_path/src/generate_heatmap_v0.3.py -i $dir_report/report_raw_s2.tsv -o $dir_report/report_raw");
        system("python $exe_path/src/generate_heatmap_v0.3.py -i $dir_report/report_uniq_s2.tsv -o $dir_report/report_uniq");
    }
    system("rm -fr $input");
    system("rm -fr $input_uniq");

    #copy results files
    system("cp -r $dir_report $result_dir");
    system("cp -r $result_dir_work/9.subtype_raw/3.step_subtype_seq $result_dir");    
    system("mv $result_dir/4.report $result_dir/report");
    system("cp $result_dir_work/2.multiQC/multiQC_report.html $result_dir/report/");
    system("mv $result_dir/3.step_subtype_seq $result_dir/report_seq");

 
}

sub find_refseq () {
  my ($result_dir_work,$files) = @_;
  my $coverage_dir="$result_dir_work/101.coverage";
  my $refseq_tab="$coverage_dir/1.ref_align_tab";
  my $refseq_seq="$coverage_dir/2.ref_seq";
  check_folder("$refseq_tab");
  check_folder("$refseq_seq");
  my $mash_ref_db = "$exe_path/database/refseq.genomes.k21s1000.msh";
  my $assembly_summary_refseq = "$exe_path/database/assembly_summary_refseq.txt";
  foreach my $items(@$files) {
    my @libs= split(/\t/,$items); 
    my $libname=$libs[0];

    ##method 1
    my $dir_chimeric_seq="$result_dir_work/8.check_chimeric/2.de_chimeric_seq/$libname\_no_chimeric.fa";
    system("mash sketch -m 5 $dir_chimeric_seq");
    system("mash dist $mash_ref_db $dir_chimeric_seq\.msh > $refseq_tab/$libname.tab");
    system("sort -gk3 $refseq_tab/$libname.tab >$refseq_tab/$libname\_sorted.tab");
    system("perl $exe_path/src/get_refseq_GCF_dj.pl -i $refseq_tab/$libname\_sorted.tab -d $assembly_summary_refseq");
    system("mv $libname\_ref.fa $refseq_seq");
    system("mv $libname\_g.txt $refseq_seq");
    #method 2
    # my $HA_NA="$refseq_tab/$libname\_HA_NA.fa";
    # system("cat $result_dir_work/9.subtype_raw/3.step_subtype_seq/1.raw/$libname\_A\_HA\_*.fa >$HA_NA");
    # system("cat $result_dir_work/9.subtype_raw/3.step_subtype_seq/1.raw/$libname\_A\_NA\_*.fa >>$HA_NA");
    # system("mash sketch -m 5 $HA_NA");
    # system("mash dist $mash_ref_db $HA_NA\.msh > $refseq_tab/$libname.tab");
    # system("sort -gk3 $refseq_tab/$libname.tab >$refseq_tab/$libname\_sorted.tab");
    # system("perl $exe_path/src/get_refseq_GCF_dj.pl -i $refseq_tab/$libname\_sorted.tab -d $assembly_summary_refseq");
    # system("mv $libname\_ref.fa $refseq_seq");
    # system("mv $libname\_g.txt $refseq_seq");
  }
  
}

sub get_depth() {
  my ($result_dir_work,$files) = @_;
  my $coverage_dir="$result_dir_work/101.coverage";
  my $refseq_tab="$coverage_dir/1.ref_align_tab";
  my $refseq_seq="$coverage_dir/2.ref_seq";
  my $dir_depth="$coverage_dir/3.depth";
  check_folder("$dir_depth");
  my $mark_label=1;
  foreach my $items(@$files) {
    my @libs= split(/\t/,$items); 
    my $libname=$libs[0];
    my $dir_chimeric_seq="$result_dir_work/8.check_chimeric/2.de_chimeric_seq/$libname\_no_chimeric.fa";
    system("bowtie2-build $refseq_seq/$libname\_ref.fa $refseq_seq/$libname\_refdb");
    system("bowtie2 -x $refseq_seq/$libname\_refdb -f $dir_chimeric_seq -S $dir_depth/$libname.sam");
    system("samtools view -bS $dir_depth/$libname.sam > $dir_depth/$libname.bam");
    system("samtools sort $dir_depth/$libname.bam -o $dir_depth/$libname.sorted.bam");
    system("samtools depth $dir_depth/$libname.sorted.bam > $dir_depth/$libname\_depth.txt");
    system("bedtools genomecov -d -ibam $dir_depth/$libname.sorted.bam >> $dir_depth/$libname\_cov.txt");
    if($mark_label==1) {      
      system("rm -fr $coverage_dir/depth_cov_sum_*.txt");
      system("perl $exe_path/src/generate_depth_cov_report.pl -l $libname -i $dir_depth/$libname\_cov.txt -o $coverage_dir/depth_cov_sum -m");
      $mark_label=0;
    }
    else {
      system("perl $exe_path/src/generate_depth_cov_report.pl -l $libname -i $dir_depth/$libname\_cov.txt -o $coverage_dir/depth_cov_sum");
    }
    
  }
  system("python $exe_path/src/draw_coverage_v0.5.py -i $result_dir_work/filelist.txt -d $dir_depth -o $coverage_dir/coverage_fig");
    
}
