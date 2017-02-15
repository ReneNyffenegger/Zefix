#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use Getopt::Long;

use lib "$ENV{github_top_root}lib/tq84-PerlModules";
use tq84_ftp;
use tq84_timestamp_last_script_execution;

my $ftp_last_cwd = '';

my $env = 'test';
GetOptions (
  'prod'             => \my $prod,
  'ftp-db-restart:i' => \my $ftp_db_restart
) or die;
$env = 'prod' if $prod;


my $zefix_root;
my $ftp_root;
if ($env eq 'test') {
  $zefix_root = "$ENV{github_root}Zefix/test/";
  $ftp_root = '/test/';
}
else {
  $zefix_root = "$ENV{digitales_backup}Zefix/";
  $ftp_root = '/prod/';
}
my $db_file = "${zefix_root}zefix.db";
die unless -e $db_file;

my $ftp = new tq84_ftp('TQ84_RN');
# $ftp->binary;

ftp_cwd("${ftp_root}php/") or die;
put('../web/php/db.php'   );
put('../web/php/zefix.php');


if ($env eq 'test') {
  ftp_cwd('/httpdocs/Virmen/') or die;
}
else {
  ftp_cwd('/httpdocs/Firmen/') or die;
}
put('../web/.htaccess'  );
put('../web/handler.php');

ftp_cwd('/cgi-bin/') or die;
put('../web/cgi-bin/merge-zefix-db.pl');


print "db_file=$db_file\n";
if ($ftp_db_restart or is_file_modified_since_last_script_execution($db_file)) {
  print "Putting $db_file\n";
  put_db();
}
else {
  print "not putting $db_file, is older\n";
}


sub put_db { #_{

  ftp_cwd("${ftp_root}/upload") or die;

  my $temp_dir;
  if ($^O eq 'MSWin32') {
     $temp_dir = 'C:\\temp';
  }
  else {
     $temp_dir = '/tmp';
  }
  print "temp_dir = $temp_dir\n";

  unless ($ftp_db_restart) { #_{

    for my $remote_db_file_part (grep {/^zefix.db\./} $ftp->ls) {
      print "deleting remote file $remote_db_file_part\n";
      $ftp -> delete ($remote_db_file_part) or die
    }
  
    for my $tmp_db_file_part (glob "$temp_dir/zefix.db.*") {
      print "deleting $tmp_db_file_part\n";
      unlink $tmp_db_file_part or die;
    }
  
  
    if ($env eq 'test') {
      system "split-file.pl -b 777 -c 2181      -d $temp_dir $db_file";
    }
    else {
      system "split-file.pl        -c 10000000  -d $temp_dir $db_file";
    }

  } #_}
  
  print "Looping over $temp_dir/zefix.db.*\n";
  for my $zefix_part (glob "$temp_dir/zefix.db.*") {

    my $file_to_put;

    print "  $zefix_part\n";
    if ($zefix_part !~ /\.gz$/) { #_{
      print "     gzip $zefix_part\n";
      system("gzip $zefix_part");
      $file_to_put = "${zefix_part}.gz";
    }
    else {
      $file_to_put = ${zefix_part};
    } #_}

    if ($ftp_db_restart) {

      my ($num) = $file_to_put =~ /(\d+)/;

      if ($num >= $ftp_db_restart) {
         print "    restarting num $num > ftp_db_restart $ftp_db_restart, putting $file_to_put\n";
         put($file_to_put, force => 1);
      }

    }
    else { 
      print "  putting $file_to_put\n";
      put($file_to_put);
    }
  }

} #_}

sub put { #_{
  my $local_file = shift;
  my %opts = @_;

  unless ($opts{force}) {
    return unless is_file_modified_since_last_script_execution($local_file);
  }

  if ($opts{remote_file}) {
    print "ftp put $local_file $opts{remote_file}\n";
    $ftp -> put($local_file, $opts{remote_file}) or die "Could not put $local_file to $opts{remote_file}";
  }
  else {
    print "ftp put $local_file\n";
    while (! $ftp -> put($local_file)) {
      print "Could not put $local_file to $ftp_last_cwd ... reconnecting\n";
      $ftp = new tq84_ftp('TQ84_RN');
      ftp_cwd($ftp_last_cwd);
    }
    print "I've successfully(?) put $local_file to $ftp_last_cwd\n";
  }

# if ($chmod_755) {
#   printf "chmod 755 %s\n", basename($local_file);
#   $ftp -> site("chmod 755  " . basename($local_file)) or die $!
# }

} #_}

sub ftp_cwd {
  my $path = shift;
  $ftp -> cwd($path) or die;
  print "ftp: changed working directory to $path\n";
  $ftp_last_cwd = $path;
}
