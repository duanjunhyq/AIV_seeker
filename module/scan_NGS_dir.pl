#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';

my ($help, $NGS_dir, $output_file);

GetOptions('help|?' => \$help,
    'folder|i=s' => \$NGS_dir,
    'outputfile|o=s' => \$output_file,
);

if($help || !defined $NGS_dir || !defined $output_file ) {
	die <<EOF;
Usage:   perl scan_NGS_directory_dj.pl -i directory -o outputfile        
         -i       path for NGS directory
         -o       output file
         -h       display this help message
EOF
}

opendir(DIR, $NGS_dir) or die $!;
my %filepath;
while (my $file = readdir(DIR)) {
	if($file=~/.gz/) {
		my @item=split(/\_/,$file);
		push @{$filepath{$item[0]}},$file;
	}
}

my $abs_path = abs_path($NGS_dir);
my @list=keys %filepath;

open(o1,">$output_file");
foreach my $item(@list) {
	my $libname;
	my $run_name=basename($NGS_dir);
	if($item=~/BC\-\d+\-SID\-\d+\-(.*)/) {
	    $libname=$1;
	}
	else {
	    $libname=$item;
	}
	if(@{$filepath{$item}}[0]=~/\_R1\_.*\.gz/) {
	    my $run_name=basename($NGS_dir);
		print o1 "$libname\t$abs_path/@{$filepath{$item}}[0]\t$abs_path/@{$filepath{$item}}[1]\t$run_name\n";
	}
	else {   
		print o1 "$libname\t$abs_path/@{$filepath{$item}}[1]\t$abs_path/@{$filepath{$item}}[0]\t$run_name\n";
	}		
}
closedir(DIR);



