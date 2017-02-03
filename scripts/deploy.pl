#!/usr/bin/perl
use warnings;
use strict;

use lib "$ENV{github_top_root}lib/tq84-PerlModules";
use tq84_ftp;

my $ftp = new tq84_ftp('TQ84_RN');

$ftp -> cwd('/httpdocs/Firmen/') or die;
chdir('../web/') or die;

$ftp -> put('.htaccess'  ) or die;
$ftp -> put('handler.php') or die;
