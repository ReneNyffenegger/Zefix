#!/usr/bin/perl
use warnings;
use strict;

print "Content-type: text/plain\r\n\r\n";

my $db_root = $ENV{DOCUMENT_ROOT} . "/../db/";
print "db_root = $db_root\n";

my $filename = "${db_root}zefix.db";

unless (-e "$filename.000") {

  print "$filename.000 does not exist\n";
  exit -1;
}

my $cnt_in = 0;
open (my $out, '>', $filename) or die;
binmode $out;

while (-e sprintf("$filename.%03d", $cnt_in)) {

  open (my $in, '<', sprintf("$filename.%03d", $cnt_in)) or die;
  binmode $in;
  print "$cnt_in\n";
  while (read($in, my $buf, 10000)) {
    print $out $buf;
  }
  close $in;

  $cnt_in++;
}
close $out;

print "finished\n";
exit 0;
