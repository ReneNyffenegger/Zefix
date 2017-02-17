#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;

use Getopt::Long;

GetOptions (
  'ids'      => \my $ids,
  'regexp:s' => \my $regexp
) or die;


my $downloaded_dir = "$ENV{digitales_backup}Zefix/downloaded/";
my $dest_dir       = "extracted/";

die unless -d $downloaded_dir;
die unless -d $dest_dir;

my @ids_firma;
if ($ids) {
  die if glob("$dest_dir*-*");
  @ids_firma = @ARGV or die;
}
elsif ($regexp) {

}
else {
  die "what exactly am I supposed to do?"
}

for my $file (glob"$downloaded_dir*-*") { #_{
  my $file_base = basename($file);

  open (my $f, '<', $file) or die;
  while (my $in = <$f>) { #_{

    if ($ids) { #_{
      my @row = split("\t", $in);
      
      if (grep {$_ == $row[0]} @ids_firma) {
        print "found $row[0] in $file\n";
        open (my $out, '>>', "$dest_dir$file_base") or die;
        print $out $in;
        close $out;
  
      }
    } #_}
    elsif ($regexp) { #_{

      if ($in =~ /$regexp/) {

        print $in;
      }

    } #_}

  } #_}

} #_}
