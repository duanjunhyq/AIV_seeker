#!/usr/bin/perl -w

use strict;
use warnings;
my $file_in=$ARGV[0];
my $file_out=$ARGV[1];
my $num=0;
open I,"<$file_in" or die $!;
open O,">$file_out" or die $!;
my $label;
if($file_in=~/\_R1/) {
  $label="1"
}
if($file_in=~/\_R2/) {
  $label="2"
}

do{
  my $f =<I>;
  chomp $f;
  if(($f =~ /^\@M/)||($f =~ /^\@N/)||($f =~ /^\+HWI/)){ 
    $num++;
    my @s=split(/\s+/, $f);
    if($s[1]) {
      if ($s[1]=~/([1|2])\:N\:/) {
      	$label=$1;
      	print O "$s[0]\/$label\n";
      }
      else {
        print O "$f\n";
 			}
    }
    else {
      print O "$s[0]\/$label\n";
    }
  }
else {
    print O "$f\n";
  }
}until eof(I);
