#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use Getopt::Long;

use lib "$ENV{github_top_root}lib/tq84-PerlModules";
use tq84_ftp;
use tq84_timestamp_last_script_execution;

my $env = 'test';
GetOptions (
  'prod'    => \my $prod
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

$ftp -> cwd("${ftp_root}php/") or die;
put('../web/php/db.php'   );
put('../web/php/zefix.php');

# $ftp -> cwd("${ftp_root}db/") or die;
# put("$ENV{digitales_backup}Zefix/zefix.db");

if ($env eq 'test') {
  $ftp -> cwd('/httpdocs/Virmen/') or die;
}
else {
  $ftp -> cwd('/httpdocs/Firmen/') or die;
}
put('../web/.htaccess'  );
put('../web/handler.php');

$ftp -> cwd('/cgi-bin/') or die;
put('../web/cgi-bin/merge-zefix-db.pl');


if (is_file_modified_since_last_script_execution($db_file)) {
  put_db();
}
else {
  print "not putting $db_file, is older\n";
}


sub put_db { #_{

  $ftp ->cwd("${ftp_root}/upload") or die;

  for my $remote_db_file_part (grep {/^zefix.db\./} $ftp->ls) {
    print "deleting remote file $remote_db_file_part\n";
    $ftp -> delete ($remote_db_file_part) or die
  }

  for my $tmp_db_file_part (glob '/tmp/zefix.db.*') {
    print "deleting $tmp_db_file_part\n";
    unlink $tmp_db_file_part or die;
  }

# unlink glob ("$db_file.*");

  if ($env eq 'test') {
    system "split-file.pl -b 777 -c 2181      -d /tmp $db_file";
  }
  else {
    system "split-file.pl        -c 10000000  -d /tmp $db_file";
  }
  
  for my $zefix_part (glob "/tmp/zefix.db.*") {

    system("gzip $zefix_part");
  
#   my $remote_name_part = $zefix_part;
  
#   if ($env eq 'test') {
#     $remote_name_part =~ s/.*zefix\.db.(\d+)/zefix-test.db.$1/;
#   }
#   else {
#   $remote_name_part =~ s/.*zefix\.db.(\d+)/zefix.db.$1/;
#   }
  
  # print "$remote_name_part\n";
  
    put("${zefix_part}.gz");
#   put(, remote_file => $remote_name_part, force => 1);
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
    $ftp -> put($local_file) or die;
  }

# if ($chmod_755) {
#   printf "chmod 755 %s\n", basename($local_file);
#   $ftp -> site("chmod 755  " . basename($local_file)) or die $!
# }

} #_}
