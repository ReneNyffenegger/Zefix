#!/usr/bin/perl
use warnings;
use strict;

use Zefix;

Zefix::init('dev');

# my $downloaded_dir = "$ENV{digitales_backup}Zefix/downloaded/";

# my @row;
my $file_;
my $rec;


my %registeramt_seen;
for my $file (Zefix::daily_summary_files()) {

  $file_ = $file;

  my $zefix_file = Zefix::open_daily_summary_file($file);

  while ($rec = Zefix::parse_next_daily_summary_line($zefix_file)) {

    if ($rec->{id_firma} eq '' or $rec->{id_firma} =~ /\D/) {
       failed('id_firma');
    }
    if ($rec->{ch_ident} !~ /^CH\d{11}$/  and $rec->{ch_ident} !~ /^ch007\d{8}$/ and $rec->{ch_ident} ne '') { # CH ...
       failed('ch_ident');
    }
    if (! grep { $_ eq $rec->{registeramt} } qw ( 400 509 280 350 500 660 514 550 670 270 320 440 524 645 290 300 310 528 503 73 170 53 35 150 100 626 251 621 506 600 229 217 20 130 120 92 212 224 200 160 249 255 260 232 206 247 261 140 254 240 244 530 241 501 36) ) {
      failed('registeramt');
    }
    if ($rec->{dt_journal} !~ /^\d\d\d\d-\d\d-\d\d 00:00:00$/) {
       failed('dt_journal');
    }
    if ($rec->{no_journal} !~ /^\d+$/) {
       failed('no_journal');
    }
    if ($rec->{dt_publikation} !~ /^\d\d\d\d-\d\d-\d\d 00:00:00$/) {
       failed('dt_publikation');
    }
    if ($rec->{no_ausgabe} !~ /^\d+$/  and $rec->{no_ausgabe} > 250) {
       failed('no_ausgabe');
    }
    if ($rec->{shab_page} !~ /^\d+$/) {
       failed('shab_page');
    }
    if ($rec->{shab_sequence} !~ /^\d+$/) {
       failed('shab_sequence');
    }
    if ($rec->{neueintrag} != 0 and $rec->{neueintrag} != 1) {
       failed('neueintrag');
    }
    if (! grep { $_ eq $rec->{mut_status} } qw (-1 0 1 11 12 13 14 20 30 40)) {
       failed('mut_status');
    }
    if ($rec->{mut_firma} != -1 and $rec->{mut_firma} != 0 and $rec->{mut_firma} != 1) {
       failed('mut_firma');
    }
    if ($rec->{mut_rechtsform} != -1 and $rec->{mut_rechtsform} != 0 and $rec->{mut_rechtsform} != 1) {
       failed('mut_rechtsform');
    }
    if (! grep { $_ eq $rec->{mut_kapital} } qw (0 1 2 3 4 5 6 7)) {
       failed('mut_kapital');
    }
    if ($rec->{mut_domizil} != 0 and $rec->{mut_domizil} != 1 and $rec->{mut_domizil} != 2) { # != 2 ab 08-010
       failed('mut_domizil');
    }
    if ($rec->{mut_zweck} != 0 and $rec->{mut_zweck} != 1) {
       failed('mut_zweck');
    }
    if ($rec->{mut_organ} != 0 and $rec->{mut_organ} != 1) {
       failed('mut_organ');
    }
    if ($rec->{care_of} and $rec->{care_of} !~ m!^c/o!) {
#      failed('care_of');
    }



#     unless (exists $registeramt_seen{$rec->{registeramt}}) {
# 
#       print "$rec->{registeramt}\n";
# 
# #     $registeramt_seen{$rec->{registeramt}} = {};
#       open ( $registeramt_seen{$rec->{registeramt}}, '>', "registeramt_$rec->{registeramt}.txt") or die;
#       
#     }
# 
#     print { $registeramt_seen{$rec->{registeramt}} } "$rec->{text}\n";


#    die "(SHAB): " .  $file_ ."\n" . $rec->{id_firma} . "\n" . $rec->{text} unless $rec->{text} =~ /\(SHAB|FUSC|FOSC [^)]+\)/;



#  unless ($rec->{mut_firma} or $rec->{mut_rechtsform} or $rec->{mut_kapital} or $rec->{mut_domizil} or $rec->{mut_zweck} or $rec->{mut_organ}) {

#   
#    goto skip if $rec->{mut_status} == 20;
#    goto skip if $rec->{text} =~ /La procédure de faillite, suspendue faute d'actif, a été clôturée/;

#    my @personen = Zefix::find_persons_from_daily_summary_text($rec->{text});
#    die "Keine Personen: " .  $file_ ."\n" . $rec->{id_firma} unless @personen;


#    skip:

#  }

    

  }

# close $f;
}

sub failed {
# my $file = shift;
# my $line = shift;
  my $item = shift;

  printf("%s %4d %-15s %8d >%s<\n", $file_, $., $item, $rec->{id_firma}, $rec->{$item});
# die if $row[$i];

}
