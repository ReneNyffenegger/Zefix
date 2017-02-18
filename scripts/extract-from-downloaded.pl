#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;

use Getopt::Long;
use Text::Wrap; $Text::Wrap::columns = 180;

use Zefix;

GetOptions (
  'ids'      => \my $ids,
  'regexp:s' => \my $regexp
) or exit;

Zefix::init('dev');

# my $downloaded_dir = "$ENV{digitales_backup}Zefix/downloaded/";
my $dest_dir       = "q/";
# 
# die unless -d $downloaded_dir;

my @ids_firma;
if ($ids) {
  die unless -d $dest_dir;
  die if glob("$dest_dir*-*");
  @ids_firma = @ARGV or die;
}
elsif ($regexp) {
# print "regexp: $regexp\n";
}
else {
  die "what exactly am I supposed to do?"
}

for my $file (Zefix::daily_summary_files) { #_{
# glob"$downloaded_dir*-*"


# open (my $f, '<', $file) or die;
  my $f = Zefix::open_daily_summary_file($file);
# while (my $in = <$f>)

  while(my $in = Zefix::read_next_daily_summary_line($f)) { #_{

    if ($ids) { #_{
      my @row = split("\t", $in);
      
      if (grep {$_ == $row[0]} @ids_firma) {
        print "found $row[0] in $file\n";
        my $file_base = basename($file);
        open (my $out, '>>', "$dest_dir$file_base") or die;
        print $out $in;
        close $out;
  
      }
    } #_}
    elsif ($regexp) { #_{

      if ($in =~ /$regexp/) {
        my $rec = Zefix::parse_daily_summary_line($f, $in);
        print "  file;         $file\n";
        print "  id_firma:     $rec->{id_firma}\n";
        print "  ch_ident:     $rec->{ch_ident}\n";
        print "  registeramt:  $rec->{registeramt}\n";
        print "  dt_journal:   $rec->{dt_journal}\n";
        print "  text:         " . wrap("", "                ", $rec->{text}), "\n";
        print "\n";
#       print $in;
      }

    } #_}

  } #_}

} #_}
