#!/usr/bin/perl -w

open INI,"$ARGV[0]"||die;   
check_folder($ARGV[1]);
check_folder("$ARGV[1]/$ARGV[2]");
#$i=0;          
$/ = ">";                              
my $qwqw = <INI>;
my $flag = 0;
while (<INI>) {
	chomp;
	my $seq = '';                     
	my @line = split(/\n+/,$_);
	$head1 = shift @line;              
	foreach my $line (@line) {
		$seq .= $line;             
	}
	if($head1 and $seq) {
		$seq=~s/\s+//g;
		@items=split(/\_/,$_);
		open INO,">>$ARGV[1]/$ARGV[2]/$items[0]\_reads_ok.fa"||die;  
 		print INO ">$head1\n$seq\n";
 		close INO;
	}
}


sub check_folder {
	my ($folder) = @_;
	if (-d $folder) { }
	else {
		mkdir $folder;
	}		 
}
