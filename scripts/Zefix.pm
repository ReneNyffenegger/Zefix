package Zefix;

# use Exporter;
use Encode qw(decode encode);

use warnings;
use strict;
use utf8;

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
  die "Zefix root dir $zefix_root_dir does not exist" unless -d $zefix_root_dir;
  
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
  open ($zefix_file->{fh}, '<:encoding(iso-8859-1)', $filename) or die "Could not open $filename";

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

sub read_next_daily_summary_line { #_{
  my $zefix_file = shift;

  my $in = readline($zefix_file->{fh});
  unless ($in) {
    close ($zefix_file->{fh});
    return;
  }
# chomp $in;
# $in =~ s/\x{a0}/ /g;
  return $in;

} #_}

sub parse_daily_summary_line { #_{
  my $zefix_file = shift;
  my $line     = shift;

  chomp $line;
  $line =~ s/\x{a0}/ /g;

  my @row = split "\t", $line;

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
  $rec->{neueintrag} = True_False_to_1_0($row[$i], $i);

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
  $rec->{mut_zweck} = True_False_to_1_0($row[$i], $i);

  $i ++;
  $rec->{mut_organ} = True_False_to_1_0($row[$i], $i);

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

  my $in = read_next_daily_summary_line($zefix_file);
  return unless $in;


# my @row = split("\t", $in);

# return parse_daily_summary_row($zefix_file, @row);
  return parse_daily_summary_line($zefix_file, $in);

} #_}

sub s_back { #_{
  my $text = shift;

  $text =~ s/##dipl_##/dipl./g;
  $text =~ s/##k beschr##/, beschränkt/g;
  $text =~ s/##(\d)d(\d)##/$1.$2/g;
  $text =~ s/## (.)##/ $1./g;
  $text =~ s/##--##/.--/g;
  $text =~ s/##-(.)##/-$1./g;
  $text =~ s/##p_(.*?)##/ ($1)/g;
  $text =~ s/##(.)_(.)_##/$1.$2./g;

# $text =~ s/##S_A_##/S.A./g;

  $text =~ s/##([^#]+)##/$1./g;
  $text =~ s/##k_(.*?)##/, $1/g;

  return $text;

} #_}

sub find_persons_from_daily_summary_rec { #_{
  my $rec  = shift;
  my $text = $rec ->{text};

  $text =~ s/\. *<B>.*//;


  $text =~ s/(\d)\.(\d)/##$1d$2##/g;
  $text =~ s/(.)\.(.)\./##$1_$2_##/g; # a.A. / S.A.

  $text =~ s/(##._._##) (Präsident|Gesellschafter|Inhaber|Aktuar|Mitglied|Vizepräsident|Direktor)/$1, $2/g;


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
  $text =~ s/, GB\b/##k_GB##/g;
  $text =~ s/, USA\b/##k_USA##/g;
  $text =~ s/ \((.{1,3})\)/##p_$1##/g;
  $text =~ s/, beschränkt\b/##k beschr##/g;
  $text =~ s/\bdipl\./##dipl_##/g; # f325321, 2001-05-31

  $text =~ s/(<(R|M)>CH.*?<E>)/ my $x = $1; $x =~ s![.-]!!g; $x /eg;

  my @ret = ();

  if (not registeramt_with_special_wording($rec)) { #_{

    my @PARTS = split /(Ausgeschiedene Personen(?: und|,) erloschene Unterschriften|Eingetragene Personen(?: neu oder mutierend)?|Personne et signature radiée|Inscription ou modification de personne(?:\(s\))?|Persone dimissionarie e firme cancellate|Persone iscritte|Nuove persone iscritte o modifiche|Personne\(s\) inscrite\(s\)|Personen neu oder mutierend|Ausgeschiedene Personen): */, $text;

    my $special_parsing = shift @PARTS;

    while ($special_parsing =~ s/\. *([^.]+?)(?:, sind )?zurückgetreten, (?:ihre|seine) Unterschrift ist erloschen//) { #_{

      my $personen = $1;
      for my $person (split /(?:;| und) */, $personen) {

        my $person_rec = {add_rm => '-'};

        $person =~ /([^,]+)(?:,| ist als) (.*?) *$/;
        my $name     = $1;
        $person_rec->{funktion} = $2;

#      (my $name, $person_rec->{von}, $person_rec->{in}) = text_to_name_in_von($person);
       ($person_rec->{nachname}, $person_rec->{vorname}) = name_to_nachname_vorname($name);

       push @ret, $person_rec;

      }

    } #_}
    while ($special_parsing =~ s/\. *(?<name>[^.]+), (?:von (?<von>[^.]+?)|(?<von>.*?Staatsangehörige.*?)), in (?<in>[^.]+?) ist zum (?<funktion>.*?) (?<zeichnung>mit .*?) ernannt worden//) { #_{
      my $person_rec = {add_rm => '+'};


      my $name     = $+{name};
      my $funktion = $+{funktion};
      $person_rec -> {zeichnung} = $+{zeichnung};
      $person_rec -> {von} = $+{von};
      $person_rec -> {in} = $+{in};

      $funktion =~ s/räsidenten\b/räsident/;
      $person_rec -> {funktion} = $funktion;
      
     ($person_rec->{nachname}, $person_rec->{vorname}) = name_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. *(?<name>[^.]+), bisher eingetragen, ist zum (?<funktion>[^.]+?) ernannt worden//) { #_{
      my $person_rec = {add_rm => '+'};


      my $name     = $+{name};
      my $funktion = $+{funktion};
      $funktion =~ s/räsidenten\b/räsident/;
      $person_rec -> {funktion} = $funktion;
     ($person_rec->{nachname}, $person_rec->{vorname}) = name_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. *([^.]+?) von ([^.]+) ist erloschen//) { #_{

      my $zeichnung = $1;
      my $whom      = $2;


#     print "unexpected registeramt $rec->{registeramt} for special_parsing\n" unless $rec->{registeramt} == 217;
      if ($zeichnung =~ /Kollektivprokura|zu zweien/) {

        $zeichnung =~ s/^Die //;

        for my $name (split /(?:, und|,| und) */, $whom) {

          my $person_rec = {add_rm => '-'};

          $person_rec -> {zeichnung} = $zeichnung;

          ($person_rec->{nachname}, $person_rec->{vorname}) = name_to_nachname_vorname($name);

          push @ret, $person_rec;

        }
         
      }
      else {
        print "unexpected Zeichnung $zeichnung\n";
      }

    } #_}
    while ($special_parsing =~ s/\. *(?<funktion>[^:.]+?): (?<name>[^,]+?), (?:von (?<von>[^.]+?)|(?<von>.*?Staatsangehörige.*?)), in (?<in>[^.]+?), zeichnet (?<zeichnung>mit [^.]+)//) { #_{

      my $name      = $+{name};
#     my $zeichnung = ${zeichnung};

      my $person_rec = {add_rm => '+'};
      $person_rec -> {funktion}  = $+{funktion} ;
      $person_rec -> {zeichnung} = $+{zeichnung};
      $person_rec -> {von}       = $+{von};
      $person_rec -> {in}        = $+{in};

     ($person_rec->{nachname}, $person_rec->{vorname}) = name_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. *([^.]+?), bisher [^,]+, zeichnet neu mit ([^.]+)//) { #_{

      my $name      = $1;
      my $zeichnung = $2;

      my $person_rec = {add_rm => '+'};
      $person_rec -> {zeichnung} = $zeichnung;

     ($person_rec->{nachname}, $person_rec->{vorname}) = name_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. *([^.]+?, von [^.]+?, in [^.]+?), beide (mit [^.]+)//) { #_{


      my $personen  = $1;
      my $zeichnung = $2;

      print "Matched: \np: $personen\nz: $zeichnung\n";

      for my $person (split ';', $personen) {
 
         my $person_rec ={add_rm => '+'};
         $person_rec -> {zeichnung} = $zeichnung;

         $person =~ /(.*), von (.*?), in (.*?), ist (.*)/;

         my $name     = $1;
         my $von      = $2;
         my $in       = $3;
         my $funktion = $4;

        ($person_rec->{nachname}, $person_rec->{vorname}) = name_to_nachname_vorname($name);

         $person_rec->{von} = s_back($von);
         $person_rec->{in } = s_back($in);
         $person_rec->{funktion } = $funktion;
 
#       (my $name, $person_rec->{von}, $person_rec->{in}) = text_to_name_von_in($person);
 
         push @ret, $person_rec;
 
      }

    } #_}
    while ($special_parsing =~ s/\. *([^.]+?) zeichne. (?:\w+ )?(mit [^.]+)//) { #_{
      my $who = $1;
      my $zeichnung = $2;

      for my $person (split /,? und /, $who ) {

        my $person_rec = {add_rm=>'+'};
        $person_rec->{zeichnung} = $zeichnung;

       (my $name, $person_rec->{von}, $person_rec->{in}) = text_to_name_von_in($person);


       ($person_rec->{nachname}, $person_rec->{vorname}) = name_to_nachname_vorname($name);

        push @ret, $person_rec;

      }

    } #_}
    while ($special_parsing =~ s/\. *(?<name>[^,]+?), (?:von (?<von>[^.]+?)|(?<von>.*?Staatsangehörige.*?)), in (?<in>[^.]+?), ist (?<funktion>[^.]+) (?<zeichnung>mit [^.]+)//) { #_{

      my $rec_person = {
        add_rm    => '+',
        von       =>  s_back($+{von      }),
        in        =>  s_back($+{in       }),
        funktion  =>  s_back($+{funktion }),
        zeichnung =>  s_back($+{zeichnung})
      };

      my $name = $1;

     ($rec_person->{nachname}, $rec_person->{vorname}) = name_to_nachname_vorname($name);

      push @ret, $rec_person;


    } #_}

    while (@PARTS) { #_{

      my $intro_text    = shift @PARTS;
      my $personen_text = shift @PARTS;

      my @person_parts;
      @person_parts = split /(?:\.|;) */, $personen_text;

      for my $person_text (@person_parts) { #_{

      my $person_rec = {};

      if ($intro_text =~ /^Eingetragene Personen/ or $intro_text =~ /[iI]nscrip?t/ or $intro_text =~ /[Pp]ersone iscritte/ or $intro_text =~ /^Personen neu/) { #_{
         $person_rec = {'add_rm' => '+'};
      }
      else {
         $person_rec = {'add_rm' => '-'};
      } #_}

      if ($person_text =~ s! *[([]?<R>([^<]+)<E>[)\]]?!!g)  { #_{
        $person_rec->{firma} = s_back($1);
      } #_}
      if ($person_text =~ / *(.*?), (?:in|à) ([^,]+?), *(.*)/) { #_{

        my $name = s_back($1);
        my $more = $3;
        $person_rec->{in} = s_back($2);


        if ($name =~ / *(.*), (?:von|de|da) (.*)/) { #_{

          my $naturliche_person = $1;
          $person_rec->{von} = $2;

          if ($rec->{registeramt} != 229) { #_{
             $naturliche_person =~ /([^,]+), *(.*)/;

             $person_rec->{nachname} = $1;
             $person_rec->{vorname } = $2;
          } #_}
          else {  #_{ Registeramt 229 does not seem to have commas between first and last name

             ($person_rec->{nachname}, $person_rec->{vorname}) = name_to_nachname_vorname($naturliche_person);

#            $naturliche_person =~ s/^([Vv]on) /$1%%/;

#            $naturliche_person =~ /([^ ]+) +(.*)/;

#            $person_rec->{nachname} = $1;
#            $person_rec->{vorname } = $2;

#            $person_rec->{nachname} =~ s/(.*)%%/$1 /;

             $person_rec->{von} =~ s/ *\(bisher von .*\)//;
             $person_rec->{in}  =~ s/ *\(bisher in .*\)//;

          } #_}

        } #_}
        elsif ($name =~ / *(.*), *([^,]*(?:Staatsangehöriger?|ressortissant|cittadino|\bcitoyen)[^]]*)/) { #_{

          my $naturliche_person = $1;
          $person_rec->{von} = $2;

          $naturliche_person =~ /([^,]+), *(.*)/;

          $person_rec->{nachname} = $1;
          $person_rec->{vorname } = $2;

        } #_}
        else { #_{

          $person_rec->{bezeichnung} = $name;

        } #_}


        $more =~ s/ *[[(](?:bisher|précédemment|finora):? *([^\])]+)[\])]//;

        my $person_det_bisher = $1;

        $more =~ s/ *\[come finora\]//;
        $more =~ s/ *[[(]wie bisher[\])]//;

        $more =~ s/ *[[(](?:nicht|non): *([^\])]+)[\])]//;
        my $person_det_nicht = $1;



        my @parts = split ' *, *', $more;

        @parts = grep { #_{ Zeichnung

           if (/[Uu]nterschrift/           or
               /[Pp]rokura/                or
               /[Zz]eichnungsberechtigung/ or
               /signature/                 or
               /\bcon firma /              or
               /\bcon procura /            or
               /\bavec procuration\b/      or
               /senza diritto di firma/
              ) {

              print "Already exists $rec->{id_firma}: $person_rec->{zeichnung}, _ = $_\n" if exists $person_rec->{zeichnung} and $_ ne $person_rec->{zeichnung};
              $person_rec->{zeichnung} = s_back($_);
              0;

            }
            else {
              1;
            }

        } @parts; #_}

        @parts = grep { #_{ Funktion


           if (/Verwaltungsrat/           or
               /[pP]räsident/             or
               /Geschäftsführer/          or
               /Revisionsstelle\b/        or
               /Geschäftsleitung/         or
               /Gesellschafter(in)?\b/    or
               /Mitglied/                 or
               /Aktuar(in)?\b/            or
               /Inhaber(in)?\b/           or
               /Geschäftsführung\b/       or
               /Vorsitzender?\b/          or
               /\bassocié\b/              or
               /\bgérant\b/               or
               /[Kk]assier/               or
               /\bmembre\b/               or
               /organe de révision/       or
               /Sekrertär(in)?\b/         or
               /Direktor(in)?\b/          or
               /Generaldirektor(in)?\b/   or
               /\bprésident/              or
               /\bpresidente\b/           or
               /Liquidator(in)\b/         or
               /Delegierter?\b/           or
               /ufficio di revisione/     or
               /\btitulaire\b/            or
               /\bassociée?\b/            or
               /\bdirecteur\b/            or
               /\bdirectrice\b/           or
               /\bdirettore\b/            or
               /\bdirettrice\b/           or
               /\bamministratore\b/       or
               /\bamministratrice\b/      or
               /\b[lL]iquidatore?\b/      or
               /\bliquidateur\b/          or
               /\bliquidatrice\b/         or
               /\bGeschäftsleiter(in)?\b/ or
               /\bmembro\b/               or
               /\bSekretär(in)?\b/        or
               /\bsegretari[ao]\b/        or
               /\bsoci[oa]\b/             or
               /\badministrateur\b/       or
               /Beisitzer(in)?\b/         or
               /Leiter de/                or
               /\bsecrétaire\b/           or
               /\btitolare\b/             or
               /\bdelegato\b/             or
               /\bgerente\b/              or
               /Kommanditär(in)?/         or
               /responsabile della succursale/   or
               /Aufsichtsbehörde/         or
               /Obmann\b/                 or
               /Prokurist(in)?\b/         or
               /Obmännin\b/               or
               /Vizeobmann\b/             or
               /Vizeobmännin\b/           or
               /Bankleiter(in)?/          or
               /Flugplatzchef(in)?/       or
               /\bdipl\./                 or
               /Chef/          
               
             ) {

              if (exists $person_rec->{function}) {
                $person_rec->{funktion} .= ', '. $_;
              }
              else {
                $person_rec->{funktion} .= s_back($_);
                $person_rec->{funktion} =~ s/^ *//;
              }
#             print "Already exists $rec->{id_firma}, $person_rec->{nachname}: $person_rec->{funktion}, _ = $_\n" if exists $person_rec->{funktion};
              0;

            }
            else {
              1;
            }

        } @parts; #_}

        @parts = grep { #_{ Stammeinlage

           if (/Stammanteil/                 or
               /Stammeinlage/                or
               /con (una|\d+) quot[ea]\b/    or
               /pour (une|\d+) parts? sociales? de /
            ) {

              print "Already exists: $person_rec->{stammeinlage}, _ = $_\n" if exists $person_rec->{stammeinlage};
              $person_rec->{stammeinlage} = s_back($_);
              0;

            }
            else {
              1;
            }

        } @parts; #_}

        $person_rec->{rest} = join " @ ",  @parts;

      } #_}
      else { #_{
#q        print "**** $rec->{id_firma} $person_text\n";
      } #_}


      if ($person_rec->{bezeichnung} or $person_rec->{vorname} or $person_rec->{nachname}) {
        push @ret, $person_rec;
      }
    } #_}

  } #_}

  } #_}
  else { #_{ 550, 660

    while ($text =~ s/Associée: ([^,.]+), à ([^,.]+), ([^,]+parts de [^,.]+)//) { #_{

      my $person_rec = {
        add_rm       =>'+',
        bezeichnung  => s_back($1),
        funktion     => 'Associée',
        in           => s_back($2),
        stammeinlage => s_back($3)
      };

      push @ret, $person_rec;

    } #_}

    if ($text =~ s/ *([^.]+) est conférée à ([^.]+)\.//) {

      my $zeichnung        = $1;
      my $signature_halter = $2;

      my @persons;

      while ($signature_halter =~ s/([^,]+), (?:de |d')([^,]+), à ([^,]+)(?:, (présidente[^,]*))? *//) { #_{

        my $name = $1;

        my $person_rec = {
           add_rm    =>'+',
           in        => $2,
           von       => $3,
           zeichnung => $zeichnung
        };

        if ($4) {
          $person_rec -> {funktion} = $4;
        }

        $name =~ s/^ *et *//;
        $name =~ /([^ ]+) +(.*)/;
        $person_rec -> {nachname} = $1;
        $person_rec -> {vorname} = $2;


        push @persons, $person_rec;
     
      } #_}


      if ($signature_halter =~ /les (\w+) gérants/) { #_{

        map {
          if ($_->{funktion}) {

            if (substr($_->{funktion}, -1) eq 'e') {
              $_->{funktion} .= ' et gérante';
            }
            else {
              $_->{funktion} .= ' et gérant';
            }
          }
          else {
            $_->{funktion} = 'gérant';
          }
        }  @persons;

      } #_}

      push @ret, @persons;

    }

  } #_}

  return @ret;


} #_}

sub registeramt_with_special_wording { #_{
  my $rec = shift;
  return grep { $rec->{registeramt} eq $_ } qw(550 645 660) ;
} #_}

sub True_False_to_1_0 { #_{
  my $tf = shift;
  my $i  = shift;

  if (not defined $tf) {

    print "not defined $i\n";
    return;
  }

  return 1 if $tf eq 'True';
  return 0 if $tf eq 'False';

  print "True False: $tf\n";
} #_}

sub are_persons_expected { #_{

  my $rec = shift;

  unless ($rec->{mut_firma} or $rec->{mut_rechtsform} or $rec->{mut_kapital} or $rec->{mut_domizil} or $rec->{mut_zweck} or $rec->{mut_organ} or $rec->{mut_status}) {
   
    goto skip if $rec->{mut_status} == 20;
    goto skip if $rec->{text} =~ /La procédure de faillite, suspendue faute d'actif, a été clôturée/;

    return 1;

#   my @personen = Zefix::find_persons_from_daily_summary_rec($rec);
#   die "Keine Personen: " .  $file_ ."\n" . $rec->{id_firma} unless @personen;

    skip:

  }

  return 0;

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

sub name_to_nachname_vorname { #_{
  my $name = shift;

  $name =~ s/^([Vv]on) /$1%%/;

  $name =~ /([^ ]+) +(.*)/;

  my $nachname = $1;
  my $vorname  = $2;

  $nachname =~ s/(.*)%%/$1 /;

  return (s_back($nachname), s_back($vorname));

} #_}

sub text_to_name_von_in { #_{
  my $text = shift;
  $text =~ /(.*?), von (.*?), in (.*?)(,|$)/;

  my $name = $1;
  my $von  = $2;
  my $in   = $3;

  return (s_back($name), s_back($von), s_back($in));
} #_}

1;
