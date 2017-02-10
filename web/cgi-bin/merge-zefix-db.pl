#!/usr/bin/perl
use warnings;
use strict;

print "Content-type: text/plain\r\n\r\n";

my $query_string = $ENV{QUERY_STRING};

# print "db_root = $db_root\n";
print "query_string = $query_string\n";

my $env;
if ($query_string =~ /^env=(.+)/) {
  $env = $1;
}
else {
  print "No env found\n";
  exit -1;
}

if ($env ne 'prod' and $env ne 'test') {
  print "Env neither prod nor test!\n";
  exit -1;
}

print "found env=$env\n";

my $root_dir = $ENV{DOCUMENT_ROOT} . "/../$env/";
my $filename = "${root_dir}upload/zefix.db";

print "filename=$filename\n";

unless (-e "$filename.000.gz") {

  print "$filename.000.gz does not exist\n";
  exit -1;
}

my $cnt_in = 0;
open (my $out, '>', $filename) or (print "Could not open $filename\n" and exit -1);
binmode $out;

print "$filename opened\n";

while (-e sprintf("$filename.%03d.gz", $cnt_in)) {

  my $cmd = sprintf("gunzip $filename.%03d.gz", $cnt_in);
  print "cmd = $cmd\n";
  print readpipe($cmd);

  open (my $in, '<', sprintf("$filename.%03d", $cnt_in)) or (print "Could not open " . sprintf("$filename.%03d", $cnt_in) . " for reading" and exit -1);
  binmode $in;
  print "$cnt_in\n";
  while (read($in, my $buf, 1024)) {
    print $out $buf;
  }
  close $in;

  $cnt_in++;
}
close $out;

cmd("mv ${root_dir}/db/zefix.db ${root_dir}/db/zefix.db.mv");
cmd("mv $filename ${root_dir}/db/");
# print "$cmd\n";
# print readpipe($cmd);

print "finished\n";
exit 0;

sub cmd { #_{
  my $cmd = shift;
  print "$cmd\n";
  print readpipe($cmd);
} #_}
