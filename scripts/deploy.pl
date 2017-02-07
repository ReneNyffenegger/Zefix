#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;

use lib "$ENV{github_top_root}lib/tq84-PerlModules";
use tq84_ftp;
use tq84_timestamp_last_script_execution;

my $ftp = new tq84_ftp('TQ84_RN');
# $ftp->binary;

$ftp -> cwd('/php/') or die;
put('../web/php/db.php'   );
put('../web/php/zefix.php');

$ftp -> cwd('/db/') or die;
# put("$ENV{digitales_backup}Zefix/zefix.db");

$ftp -> cwd('/httpdocs/Firmen/') or die;
put('../web/.htaccess'  );
put('../web/handler.php');

$ftp -> cwd('/cgi-bin/') or die;
put('../web/cgi-bin/merge-zefix-db.pl', 1);

$ftp ->cwd('/db/');
# put('../test/zefix.db');


sub put {
  my $local_file = shift;
  my $chmod_755  = shift;

  return unless is_file_modified_since_last_script_execution($local_file);
  print "ftp put $local_file\n";
  $ftp -> put($local_file) or die;
  if ($chmod_755) {
    printf "chmod 755 %s\n", basename($local_file);
    $ftp -> site("chmod 755  " . basename($local_file)) or die $!
  }
}
