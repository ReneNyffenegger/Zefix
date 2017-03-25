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

my $dest_dir       = "q/";

my @ids_firma;
if ($ids) {
  die "Dest dir $dest_dir does not exist" unless -d $dest_dir;
  die if grep { $_ != '.gitignore' } glob ("$dest_dir*-*");
  @ids_firma = @ARGV or die;
}
elsif ($regexp) {
# print "regexp: $regexp\n";
}
else {
  die "what exactly am I supposed to do?"
}

for my $file (Zefix::daily_summary_files) { #_{

  my $f = Zefix::open_daily_summary_file($file);

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

if (@ids_firma) {

  extract_from_firmen_or_firmen_bezeichnung('firmen'            );
  extract_from_firmen_or_firmen_bezeichnung('firmen_bezeichnung');

}

sub extract_from_firmen_or_firmen_bezeichnung {
  my $firmen_or_firmen_bezeichnung = shift;

  open (my $in , '<:encoding(latin-1)', "$Zefix::zefix_downloads_dir$firmen_or_firmen_bezeichnung") or die;
  open (my $out, '>:encoding(latin-1)', "$dest_dir$firmen_or_firmen_bezeichnung"           ) or die;

  while (my $line = <$in>) {
    my $id = (split "\t", $line)[0];

    if (grep { $_ == $id } @ids_firma) {
       print $out $line;
    }
  }

  close $in;
  close $out;
}
