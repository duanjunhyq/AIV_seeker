#!/usr/bin/perl

use Getopt::Long;
my %opts;
GetOptions(\%opts,"i:s");
die unless $opts{"i"};
open INPUT,"$opts{'i'}"||die"$!";

$line_position = 0;
$count = 0;
$total_len=0;
$total_gc=0;
$len=0;

while(<INPUT>)  {
  chomp;
  $line_position++;
  if($line_position == 2) {
    $seq = $_;
    $seq=~s/\s+//;
    $len=length($seq);
    $GCcount = $seq=~ tr/GCgc//;
    $total_gc=$total_gc+$GCcount;
    $total_len=$total_len+$len;
  }
  if($line_position == 4) {
    $line_position = 0;
    $count++;
  }
}

close(INPUT);

if ($total_len>0) {
  $GC_percent=$total_gc/$total_len;
  $GC_percent_rounded = sprintf "%.2f", $GC_percent; 
  print"$opts{'i'}\t$count\t$total_len\t$GC_percent_rounded\n";
} 
else {
	print"$opts{'i'}\t$count\t$total_len\t$GC_percent_rounded\n";
}
