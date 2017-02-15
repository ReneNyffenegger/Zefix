package Zefix;

# use Exporter;
use Encode qw(decode encode);

use warnings;
use strict;

use DBI;

# our @ISA = 'Exporter';
# our @EXPORT = qw( $dbh shorten_fqn t_2_date_string date_string_2_t t_now);

our $zefix_root_dir;
our $zefix_downloads_dir;

sub init { #_{

  my $env = shift or die;

  if ($env eq 'test') {
    $zefix_root_dir = "$ENV{github_root}Zefix/test/";
  }
  elsif ($env eq 'dev') {
    $zefix_root_dir = "$ENV{digitales_backup}Zefix/";
  }
  else {
     die "unknown env $env\n";
  }
  die $zefix_root_dir unless -d $zefix_root_dir;
  
  $zefix_downloads_dir = "${zefix_root_dir}downloaded/";
  die unless -d $zefix_downloads_dir;

  unless ($^O eq 'MSWin32') {
    # Input files seem to be in dos format.
    # Why it does not need be changed in a windows environment is still a mystery to me.
    $/ = "\r\n";
  }


# 
# my $db = "${zefix_root_dir}zefix.db";
# 
# my $dbh = DBI->connect("dbi:SQLite:dbname=$db") or die "Could not open/create $db";
# $dbh->{AutoCommit} = 0;

# return $dbh;
} #_}

sub daily_summary_files { #_{
  return sort glob "${zefix_downloads_dir}*-*";
} #_}

sub open_daily_summary_file { #_{
  my $filename = shift;

  my $zefix_file = {};
  open ($zefix_file->{fh}, '<', $filename) or die;


   my ($yr, $no) = $filename =~ m/(\d+)-(\d+)$/;
   if ($yr gt '01' or $no gt '164') {
     $zefix_file->{gt_01_164} = 1;
   }
   else {
     $zefix_file->{gt_01_164} = 0;
   }
   if ($yr gt '03' or $no gt '076') {
     $zefix_file->{gt_03_076} = 1;
   }
   else {
     $zefix_file->{gt_03_076} = 0;
   }

   return $zefix_file;

} #_}

# sub read_summary_line { #_{
#   my $fh       = shift;
#   my $filename = shift;
# 
#   my $in = <$fh>;
# 
#   return unless $in;
# 
#   chomp $in;
# 
#   $in = encode('utf-8', decode('iso-8859-1', $in));
# 
#   my @row = split("\t", $in);
# 
#   return parse_daily_summary_row($filename, @row);
# 
# } #_}

sub parse_daily_summary_row { #_{
  my $zefix_file = shift;
# my $filename = shift;
  my @row      = @_;


# my ($yr, $no) = $filename =~ m/(\d+)-(\d+)$/;

  my $rec = {};

  my $i = 0;

  $rec->{id_firma}       = $row[$i];
  $i ++;

  $rec->{ch_ident}       = $row[$i];

  $i = 5;
  $rec->{registeramt}    = $row[$i];

  $i++;
  $i++;
  $rec->{dt_journal}     = to_dt($row[$i]);

  $i ++;
  $rec->{no_journal}     = $row[$i];

  $i ++;
  $rec->{dt_publikation} = to_dt($row[$i]);

  $i ++;
  $rec->{no_ausgabe} = $row[$i];

  $i ++;
  $rec->{shab_page} = $row[$i];

  if ($zefix_file->{gt_01_164}) {
# if ($yr gt '01' or $no gt '164') {
    $i ++;
    $rec->{shab_sequence} = $row[$i];
  }
  else {
    $rec->{shab_sequence} = 0;
  }

  $i ++;
  $rec->{neueintrag} = True_False_to_1_0($row[$i]);

  $i ++;
  $rec->{mut_status} = $row[$i];

  $i ++;
  $rec->{mut_firma} = $row[$i];

  $i ++;
  $rec->{mut_rechtsform} = $row[$i];

  $i ++;
  $rec->{mut_kapital} = $row[$i];

  $i ++;
  $rec->{mut_domizil} = $row[$i];

  $i ++;
  $rec->{mut_zweck} = True_False_to_1_0($row[$i]);

  $i ++;
  $rec->{mut_organ} = True_False_to_1_0($row[$i]);

  $i ++; # ???

  $i ++;
  $rec->{text} = $row[$i];

    $i ++;
#   die ">$row[$i]<" if $row[$i] ne ' ' and $row[$i] != '';
  # $rec->{text_2} = $row[$i];
  
  if ($zefix_file->{gt_03_076}) {
    $i ++;
    $rec->{care_of} = $row[$i];
  
    $i ++;
    $rec->{strasse} = $row[$i];
  
    $i ++;
    $rec->{hausnummer} = $row[$i];
  
    $i ++;
    $rec->{postfach} = $row[$i];
  
    $i ++;
    $rec->{plz} = $row[$i];
  
    $i ++;
    $rec->{ort} = $row[$i];
  
    $i ++;
    $rec->{zweck} = $row[$i];
  }

  return $rec;

} #_}

sub parse_next_daily_summary_line { #_{
  my $zefix_file = shift;

  my $in = readline($zefix_file->{fh});
  unless ($in) {
    close ($zefix_file->{fh});
    return;
  }
  chomp $in;
  $in = encode('utf-8', decode('iso-8859-1', $in));
  my @row = split("\t", $in);

  return parse_daily_summary_row($zefix_file, @row);

} #_}


sub s_back { #_{
  my $text = shift;

  $text =~ s/## (.)##/ $1./g;
  $text =~ s/##-(.)##/-$1./g;
  $text =~ s/##(.)_(.)_##/$1.$2./g;

  $text =~ s/##([^#]+)##/$1./g;
  $text =~ s/##(\d)d(\d)##/$1.$2/g;

  return $text;

} #_}

sub find_persons_from_daily_summary_rec { #_{
  my $rec  = shift;
  my $text = $rec ->{text};

  $text =~ s/(.)\.(.)\./##$1_$1_##/g; # a.A.
  $text =~ s/ (.)\./## $1##/g;
  $text =~ s/-(.)\./##-$1##/g;

  $text =~ s/\b([A-Z][a-z])\./##$1##/g;


  $text =~ s/\bjun\./##jun##/g;
  $text =~ s/\bgeb\./##geb##/g;
  $text =~ s/Gde\./##Gde##/g;
  $text =~ s/StA\./##StA##/g;

  $text =~ s/Prof\./##Prof##/g;
  $text =~ s/(\d)\.(\d)/##$1d$2d##/g;

  $text =~ s/(<(R|M)>CH.*?<E>)/ my $x = $1; $x =~ s![.-]!!g; $x /eg;
# $text =~ s/\( *\)//g;

  my @ret = ();


# while ($text =~ s/Ausgeschiedene Personen und erloschene Unterschriften:? *(.*?)(?<!(Dr)\.(?!,)//) { # |Eingetragene Personen neu oder mutierend|Inscription ou modification de personne\(s\)|Nuove persone iscritte o modifiche|Procuration collective à deux, limitée aux affaires de la succursale, a été conférée à|Inscription ou modification de personnes)//) {
  while ($text =~ s/(Ausgeschiedene Personen und erloschene Unterschriften|Eingetragene Personen(?: neu oder mutierend)?):? *(.*?)\.//) { # ||Inscription ou modification de personne\(s\)|Nuove persone iscritte o modifiche|Procuration collective à deux, limitée aux affaires de la succursale, a été conférée à|Inscription ou modification de personnes)//) {

    my ($intro_text, $personen_text) = ($1, $2);

    for my $person_text (split ';', $personen_text) {

      my $person_rec = {};

      if ($intro_text =~ /^Eingetragene Personen/) {
         $person_rec = {'add_rm' => '+'};
      }
      else {
         $person_rec = {'add_rm' => '-'};
      }

#     if ($person_text =~ s!<R>([^<]+)<E>! TODO: FIRMA-ABC $1!g)  {

#       $person_rec->{firma} =$person_text;

#     }
      if ($person_text =~ / *(.+), (Zweigniederlassung )?in ([^,]+), (Revisionsstelle|Gesellschafterin|Liquidatorin)/) {

        $person_rec->{bezeichnung} = s_back($1);
        $person_rec->{in}          = s_back($3);

        if ($4 eq 'Gesellschafterin') {
          $person_rec->{gesellschafterin} = 1;
        }
        elsif ($4 eq 'Revisionsstelle') {
          $person_rec->{revisionsstelle} = 1;
        }
        elsif ($4 eq 'Liquidatorin') {
          $person_rec->{liquidatorin} = 1;
        }

      }
      elsif ($person_text =~ / *([^,]+), *([^,]+), (von )?([^,]+), in ([^,]+), *(.*)/) {

        
        $person_rec->{nachname} = s_back($1);
        $person_rec->{vorname } = s_back($2);
        $person_rec->{von     } = s_back($4);
        $person_rec->{in      } = s_back($5);

      }
#     elsif ($person_text =~ / *([^,]+), in ([^,]+), Stammeinlage: \w+ ([\d']+)/) {

#       $person_rec->{bezeichnung} = s_back($1);
#       $person_rec->{in}          = s_back($2);


#     }
#     elsif ($person_text =~ / *([^,]+), in ([^,]+), Gesellschafterin, /) {
#       $person_rec->{gesellschafterin} = 1;
#       $person_rec->{bezeichnung} = s_back($1);
#       $person_rec->{in         } = s_back($2);
#     }
      else {
        print "$rec->{id_firma} $person_text\n";
      }

      push @ret, $person_rec;
    }
  }
  return @ret;

#   while ($text =~ s/(Ausgeschiedene Personen und erloschene Unterschriften|Eingetragene Personen neu oder mutierend|Inscription ou modification de personne\(s\)|Nuove persone iscritte o modifiche|Procuration collective à deux, limitée aux affaires de la succursale, a été conférée à|Inscription ou modification de personnes):? *(.*?)(?<!Dr)\.(?!,)//) {
#     my ($intro, $ausgesch_pers) = ($1, $2);
#     for my $person (split ';', $ausgesch_pers) {
# 
#       if ($person =~ s!<R>([^<]+)<E>! TODO: FIRMA-ABC $1!g)  {
# 
#       }
# 
#       push @ret, $person;
#     }
#   }
#   if (my ($etainte) = $text =~ /La procuration de (.*?) est éteinte./) {
#     push @ret, $etainte;
#   }
#   
#   while ($text =~ s!Personne\(s\) et signature\(s\) radiée\(s\): *([^.]+)!!g) {
#     my ($radies) = $1;
#     for my $person (split ' et ', $radies) {
#       push @ret, $person;
#     }
#   }
# 
#   while ($text =~ s!Les pouvoirs de (.*?) sont radiés!!g) {
#     my ($names) = $1;
#     for my $person (split ' et ', $names) {
#       push @ret, $person;
#     }
#   }
# 
#   while ($text =~ s!\. *([^.]+) * a maintenant la signature collective à deux!!g) {
#     my ($maint) = $1;
#     for my $person (split ' et ', $maint) {
#       push @ret, $person;
#     }
#   }
#   while ($text =~ s/(?<!S\.A)\. *(.*?) * n'est plus (organe de révision).//g) {  # 16-039 / f286101 
#     my ($name, $xyz) = ($1, $2);
#     push @ret, $name;
#   }
# # while ($text =~ s/(?<!S\.A)\. *(.*?) * n'est plus organe de révision.//g) {  # 16-039 / f286101 
# #   my ($name) = $1;
# #   push @ret, $name;
# # }
# 
#   while ($text =~ s!\. *([^.]+), ist zum Verwaltungsratsmitglied mit Kollektivunterschrift zu zweien ernannt worden!!g) {
#     my ($names) = $1;
#     for my $person (split ' et ', $names) {
#       push @ret, $person;
#     }
#   }
# 
# #   while ($text =~ s!\. *(.*), dont la procuration est éteinte, est nommée administratrice avec signature individuelle.!!) {
# #     my ($names) = $1;
# # #   for my $person (split ' et ', $names) {
# #       push @ret, $names;
# # #   }
# #   }
# 
#   while ($text =~ s!\. *([^.]+) *sont nommés ([^.]+)!!g) {
#     my ($nommes, $quoi) = ($1, $2);
#     for my $person (split ' et ', $nommes) {
#       push @ret, $person;
#     }
#   }
# 
#   return @ret;

} #_}


sub True_False_to_1_0 { #_{
  my $tf = shift;

  return 1 if $tf eq 'True';
  return 0 if $tf eq 'False';

  die "$tf";
} #_}


sub to_dt { #_{
  my $str = shift;

  return '9999-12-31' unless $str; # 1082610, Trimos Ltd
  
  die "$str" unless $str =~ /^((\d\d\d\d)-(\d\d)-(\d\d)) 00:00:00$/;

  my $dt = $1;

  $dt = '9999-12-31' if $dt eq '2100-12-31';

  return $dt;
} #_}

1;
