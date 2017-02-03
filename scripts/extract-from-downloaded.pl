#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;

my $id_firma = shift or die;

my $downloaded_dir = "$ENV{digitales_backup}Zefix/downloaded/";
my $dest_dir       = "extracted/";

die unless -d $downloaded_dir;
die unless -d $dest_dir;

die if glob("$dest_dir*-*");

for my $file (glob"$downloaded_dir*-*") {
  my $file_base = basename($file);

  open (my $f, '<', $file) or die;
  while (my $in = <$f>) {

    my @row = split("\t", $in);
    if ($row[0] == $id_firma) {
      print "found in $file\n";
      open (my $out, '>>', "$dest_dir$file_base") or die;
      print $out $in;
      close $out;

    }

  }

}
