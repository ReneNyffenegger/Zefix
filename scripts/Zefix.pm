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
  $in =~ s/\x{a0}/ /g;
  $in = encode('utf-8', decode('iso-8859-1', $in));
  my @row = split("\t", $in);

  return parse_daily_summary_row($zefix_file, @row);

} #_}

sub s_back { #_{
  my $text = shift;

  $text =~ s/##(\d)d(\d)##/$1.$2/g;
  $text =~ s/## (.)##/ $1./g;
  $text =~ s/##--##/.--/g;
  $text =~ s/##-(.)##/-$1./g;
  $text =~ s/##(.)_(.)_##/$1.$2./g;

# $text =~ s/##S_A_##/S.A./g;

  $text =~ s/##([^#]+)##/$1./g;

  return $text;

} #_}

sub find_persons_from_daily_summary_rec { #_{
  my $rec  = shift;
  my $text = $rec ->{text};

  $text =~ s/(\d)\.(\d)/##$1d$2##/g;
  $text =~ s/(.)\.(.)\./##$1_$2_##/g; # a.A. / S.A.
  $text =~ s/ (.)\./## $1##/g;
  $text =~ s/\.--/##--##/g;

  $text =~ s/-(.)\./##-$1##/g;

  $text =~ s/\b([A-Z][a-z])\./##$1##/g;


  $text =~ s/\bjun\./##jun##/g;
  $text =~ s/\bgeb\./##geb##/g;
  $text =~ s/Gde\./##Gde##/g;
  $text =~ s/StA\./##StA##/g;
# $text =~ s/S\.A\./##S_A_##/g;

  $text =~ s/Prof\./##Prof##/g;

  $text =~ s/(<(R|M)>CH.*?<E>)/ my $x = $1; $x =~ s![.-]!!g; $x /eg;
# $text =~ s/\( *\)//g;

  my @ret = ();

  while ($text =~ s/(Ausgeschiedene Personen und erloschene Unterschriften|Eingetragene Personen(?: neu oder mutierend)?|Personne et signature radiée|Inscription ou modification de personne(?:\(s\))?|Persone dimissionarie e firme cancellate):? *(.*?)\.//) { # ||Inscription ou modification de personne\(s\)|Nuove persone iscritte o modifiche|Procuration collective à deux, limitée aux affaires de la succursale, a été conférée à|Inscription ou modification de personnes)//) {


    my ($intro_text, $personen_text) = ($1, $2);

    for my $person_text (split ';', $personen_text) {


      my $person_rec = {};

      if ($intro_text =~ /^Eingetragene Personen/ or $intro_text =~ /^Inscription/) { #_{
         $person_rec = {'add_rm' => '+'};
      }
      else {
         $person_rec = {'add_rm' => '-'};
      } #_}

      if ($person_text =~ s! *\(?<R>([^<]+)<E>\)?!!g)  {
        $person_rec->{firma} = s_back($1);
      }
#q      if ($person_text =~ / *(.+), (Zweigniederlassung )?(?:in|à) ([^,]+), (Revisionsstelle|organe de révision|Gesellschafterin|Liquidatorin|ufficio di revisione)(.*)/) { #_{
#q
#q        $person_rec->{bezeichnung} = s_back($1);
#q        $person_rec->{in}          = s_back($3);
#q
#q        my $grl = s_back($4);
#q        print "grl: $grl\n";
#q        my $grl_bisher = bisher_nicht_etc($grl, 'bisher');
#q        print "grl: $grl\ngrl bisher: $grl_bisher\n\n";
#q
#q     
#q        if ($grl eq 'Gesellschafterin') {
#q          $person_rec->{gesellschafterin} = 1;
#q        }
#q        elsif ($grl eq 'Revisionsstelle' or $4 eq 'organe de révision' or $4 eq 'ufficio di revisione') {
#q          $person_rec->{revisionsstelle} = 1;
#q        }
#q        elsif ($grl eq 'Liquidatorin') {
#q          $person_rec->{liquidatorin} = 1;
#q        }
#q
#q        my $det = s_back($5);
#q        my $det_bisher  = bisher_nicht_etc($det, 'bisher');
#q
#q        if ($det =~ s/ohne Zeichnungsberechtigung//) {
#q           $person_rec -> {oz} = 1;
#q        }
#q        else {
#q           $person_rec -> {oz} = 0;
#q        }
#q
#q        $person_rec->{stammeinlage} = stammeinlage($det);
#q
#q        $det =~ s/,//g;
#q        $det =~ s/^ *//g;
#q        $person_rec->{rest} = $det;
#q
#q      } #_}
#       if ($person_text =~ / *([^,]+), *([^,]+), (von )?([^,]+), (?:in|à) ([^,]+), *(.*)/) { #_{
      if ($person_text =~ / *(.*), (?:in|à) ([^,]+), *(.*)/) {

        my $name = s_back($1);
        my $more = $3;
        $person_rec->{in} = s_back($2);
        
        if ($name =~ / *(.*), (?:von|de) (.*)/) { #_{

          my $naturliche_person = $1;
          $person_rec->{von} = $2;

          $naturliche_person =~ /([^,]+), *(.*)/;

          $person_rec->{nachname} = $1;
          $person_rec->{vorname } = $2;

        } #_}
        elsif ($name =~ / *(.*), *([^,]+Staatsangehöriger)/) { #_{

          my $naturliche_person = $1;
          $person_rec->{von} = $2;

          $naturliche_person =~ /([^,]+), *(.*)/;

          $person_rec->{nachname} = $1;
          $person_rec->{vorname } = $2;

        } #_}
        else { #_{

          $person_rec->{bezeichnung} = $name;

        } #_}





#       my $person_det = s_back($6);

        my $person_det_bisher = bisher_nicht_etc($more, 'bisher');

        my $person_det_nicht = bisher_nicht_etc($more, 'nicht');


#       @parts = grep { /\w/ } @parts;

        my @parts = split ' *, *', $more;

        
        @parts = grep { #_{ Funktion

           if (/Verwaltungsrates/ or
               /[pP]räsident/     or
               /Geschäftsführer/  or
               /Geschäftsleitung/ or
               /Mitglied/         or
               /\bmembre\b/       or
               /président/) {

              if (exists $person_rec->{function}) {
                $person_rec->{funktion} .= ', '. $_;
              }
              else {
                $person_rec->{funktion} .= $_;
              }
#             print "Already exists $rec->{id_firma}, $person_rec->{nachname}: $person_rec->{funktion}, _ = $_\n" if exists $person_rec->{funktion};
              0;

            }
            else {
              1;
            }

        } @parts; #_}

        @parts = grep { #_{ Zeichnung

           if (/[Uu]nterschrift/ or
               /[Pp]rokura/      or
               /[Zz]eichnungsberechtigung/ or
               /signature/
              ) {

              print "Already exists $rec->{id_firma}: $person_rec->{zeichnung}, _ = $_\n" if exists $person_rec->{zeichnung} and $_ ne $person_rec->{zeichnung};
              $person_rec->{zeichnung} = $_;
              0;

            }
            else {
              1;
            }

        } @parts; #_}

        @parts = grep { #_{ Stammeinlage

           if (/Stammanteil/     or
               /Stammeinlage/
            ) {

              print "Already exists: $person_rec->{stammeinlage}, _ = $_\n" if exists $person_rec->{stammeinlage};
              $person_rec->{stammeinlage} = s_back($_);
              0;

            }
            else {
              1;
            }

        } @parts; #_}


        $person_rec->{rest} = join @parts;
      } #_}
      else {
#q        print "**** $rec->{id_firma} $person_text\n";
      }


      push @ret, $person_rec;
    }
  }
  return @ret;


} #_}

sub True_False_to_1_0 { #_{
  my $tf = shift;

  return 1 if $tf eq 'True';
  return 0 if $tf eq 'False';

  die "$tf";
} #_}

sub are_persons_expected { #_{

  my $rec = shift;

  unless ($rec->{mut_firma} or $rec->{mut_rechtsform} or $rec->{mut_kapital} or $rec->{mut_domizil} or $rec->{mut_zweck} or $rec->{mut_organ}) {
   
    goto skip if $rec->{mut_status} == 20;
    goto skip if $rec->{text} =~ /La procédure de faillite, suspendue faute d'actif, a été clôturée/;

    return 1;

#   my @personen = Zefix::find_persons_from_daily_summary_rec($rec);
#   die "Keine Personen: " .  $file_ ."\n" . $rec->{id_firma} unless @personen;

    skip:

  }

  return 0;

} #_}

sub bisher_nicht_etc { #_{
  # $_[0]  ... text
  # $_[1]  ... nicht, bisher ...
  

  if ($_[0] =~ s/ *\[$_[1]:([^]]*)\]//) {
    return $1;
  }
  if ($_[1] eq 'bisher') {
    if ($_[0] =~ s/ *\[précédemment:([^]]*)\]//) {
      return $1;
    }
  }
  return '';
} #_}

sub stammeinlage { #_{

  if ($_[0] =~ s/mit eine. Stamm(?:einlage|anteil) von (.*)//) {
    return $1;
  }

  if ($_[0] =~ s/mit (\d+ Stammanteilen .*)//) {
    return $1;
  }

  return undef;

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
