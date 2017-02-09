#!/usr/bin/perl
use warnings;
use strict;

my $downloaded_dir = "$ENV{digitales_backup}Zefix/downloaded/";

for my $file (glob"$downloaded_dir*-*") {

  open (my $f, '<', $file) or die;

  while (my $in = <$f>) {
    my @row = split("\t", $in);
    if ($row[0] eq '' or $row[0] =~ /\D/) {
       print "$file $.\n";
    }
  }

  close $f;
}
