package Zefix;

# use Exporter;
# use Encode qw(decode encode);

use warnings;
use strict;
use utf8;
use Text::Wrap; $Text::Wrap::columns = 180;

use DBI;

our $zefix_root_dir;
our $zefix_downloads_dir;

my $debug        = 0;
my $debug_indent = 0;

sub init { #_{

  my $env   = shift or die;
     $debug = shift;

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


} #_}

sub daily_summary_files { #_{
  return sort grep { $_ !~ /\.old$/ } glob "${zefix_downloads_dir}*-*";
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
  $in =~ s/  */ /g;
  $in =~ s/ ,/,/g;
  return $in;

} #_}

sub parse_daily_summary_line { #_{
  my $zefix_file = shift;
  my $line     = shift;

  chomp $line;
  $line =~ s/\x{a0}/ /g;

  my @row = split "\t", $line;

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

  return parse_daily_summary_line($zefix_file, $in);

} #_}

sub s_back { #_{
  my $text = shift;

  $text =~ s/##-_und_##/- und /g;

  $text =~ s/##dipl_##/dipl./g;
  $text =~ s/##k beschr##/, beschränkt/g;
  $text =~ s/##k_und_GF([^#]*)##/, und Geschäftsführer$1/g;
  $text =~ s/##_und_GF([^#]*)##/ und Geschäftsführer$1/g;
  $text =~ s/##_und_DIR([^#]*)##/ und Direktor$1/g;
  $text =~ s/##_und_SEKR([^#]*)##/ und Sekretär$1/g;
  $text =~ s/##_und_KASS_und##/ und Kassier und/g;
  $text =~ s/##_und_KASS([^#]*)##/ und Kassier$1/g;
  $text =~ s/##_und_AKT([^#]*)##/ und Aktuar$1/g;
  $text =~ s/##_und_FLUGPLATZCHEF([^#]*)##/ und Flugplatzchef$1/g;
  $text =~ s/##GES_und_##/Gesellschafter und /g;
  $text =~ s/##_und_GES([^#]*)##/ und Gesellschafter$1/g;
  $text =~ s/##(\d)d(\d)##/$1.$2/g;
  $text =~ s/## (.)##/ $1./g;
  $text =~ s/##--##/.--/g;
  $text =~ s/##-(.)##/-$1./g;
  $text =~ s/##p_(.*?)##/ ($1)/g;
  $text =~ s/##(.)_(.)_##/$1.$2./g;


  $text =~ s/##k_(.*?)##/, $1/g;
  $text =~ s/##([^#]+)##/$1./g;

  return $text;

} #_}

sub find_persons_from_daily_summary_rec { #_{
  my $rec  = shift;
  my $text = $rec ->{text};

  $text =~ s/\. *<B>.*//;


  $text =~ s/(\d)\.(\d)/##$1d$2##/g;
  $text =~ s/(.)\.(.)\./##$1_$2_##/g; # a.A. / S.A.

  $text =~ s/- und /##-_und_##/g;

  $text =~ s/, *und Geschäftsführer(\w*)/##k_und_GF$1##/g;  # , und Geschäftsführer
  $text =~ s/ *und Geschäftsführer(\w*)/##_und_GF$1##/g;    #   und Geschäftsführer
  $text =~ s/ *und Direktor(\w*)/##_und_DIR$1##/g;          #   und Direktor
  $text =~ s/ *und Sekretär(\w*)/##_und_SEKR$1##/g;         #   und Sekretär
  $text =~  s/ und Kassier und/##_und_KASS_und##/g;         #
  $text =~ s/ *und Kassier(\w*)/##_und_KASS$1##/g;          #
  $text =~ s/ *und Aktuar(\w*)/##_und_AKT$1##/g;          #
  $text =~ s/ *und Flugplatzchef(\w*)/##_und_FLUGPLATZCHEF$1##/g; # 
  $text =~ s/Gesellschafter und /##GES_und_##/g; # 
  $text =~ s/ und Gesellschafter(\w*)/##_und_GES$1##/g;


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


  $text =~ s/, von und in /##k_von_und_in##/g;


  my @ret = ();

  if (not registeramt_with_special_wording($rec)) { #_{

    debug('not registeramt_with_special_wording');

    $debug_indent++;

    my @PARTS = split /(Ausgeschiedene Personen(?: und|,) erloschene Unterschriften|Eingetragene Personen(?: (?:neu(?: oder mutierend)?|Geändert))?|Personne et signature radiée|Inscription ou modification de personne(?:\(s\))?|Persone dimissionarie e firme cancellate|Persone iscritte|Nuove persone iscritte o modifiche|Personne\(s\) inscrite\(s\)|Personen neu oder mutierend|Ausgeschiedene Personen|Gelöschte Personen): */, $text;
#   my @PARTS = split /(Ausgeschiedene Personen(?: und|,) erloschene Unterschriften|Eingetragene Personen(?: (?:neu oder mutierend|Geändert))?|Personne et signature radiée|Inscription ou modification de personne(?:\(s\))?|Persone dimissionarie e firme cancellate|Persone iscritte|Nuove persone iscritte o modifiche|Personne\(s\) inscrite\(s\)|Personen neu oder mutierend|Ausgeschiedene Personen): */, $text;
    debug('scalar @PARTS: ' . scalar @PARTS);

    if (@PARTS == 1 and $text =~ /Stiftungsrat:/) { # f798777

      @PARTS = split /(Stiftungsrat:)/, $text;
      debug('After split Stiftungsrat: - scalar @PARTS: ' . scalar @PARTS);
#     unshift @PARTS, 'Eingetragene Personen';

    }

    my $special_parsing = shift @PARTS;


    $special_parsing =~ s/##k_von_und_in##/, von und in /;
    $special_parsing =~ s/#1<#von_([^_]+?)_und_([^.]*?)#1>#/ von $1 und $2/g;

    debug("special_parsing: $special_parsing");
    $debug_indent++;
 #_{ Special parsing
    while ($special_parsing =~ s/Die Zweigniederlassung von [^.]+ ist erloschen\.?//) { #_{
#     print "yepp\n";
    } #_}
    while ($special_parsing =~ s/Für die Zweigniederlassung zeichne. ([^.]+)//) { #_{
    #
    # f 738038
    #
    
      my $zeichnungen_text = $1;

      my @zeichnungsarten = split '; *', $zeichnungen_text;

      for my $zeichnungsart_text (@zeichnungsarten) {

        $zeichnungsart_text =~ m/(mit \w+(?: zu zweien)?) (.*)/;

        my $zeichnung = $1;
        my $who = $2;

#       print "\n\n\nxxx: zeichnung = $zeichnung\n  who = $who\n";
        who_and_zeichnung(\@ret, $who, $zeichnung);

      }


   
    } #_}
    while ($special_parsing =~ s/\. *(?<name>[^.]+?),? (?:ist nicht mehr) (?<funktion>[^,]+), (seine|ihre) Unterschrift ist erloschen//) { #_{

       my $name = $+{name};

       my $person_rec = {add_rm => '-'};
       $person_rec -> {funktion} = $+{funktion};
      ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

       push @ret, $person_rec;


    } #_}
    while ($special_parsing =~ s/\. *(?<name_alt>[^.]+?)? (?:ist nicht mehr) (?<funktion>Revisionsstelle)\. Neue \k'funktion': (?<name_neu>.[^.]+?), in (?<in>[^.]+)//) { #_{

       my $person_rec = {add_rm => '-'};
       $person_rec -> {funktion} = $+{funktion};
       $person_rec -> {bezeichnung} = $+{name_alt};

       push @ret, $person_rec;

       $person_rec = {add_rm => '+'};
       $person_rec -> {funktion} = $+{funktion};
       $person_rec -> {bezeichnung} = $+{name_neu};
       $person_rec -> {in} = $+{in};

       push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. *(?<name_alt>[^.]+?), bisher eingetragen, zeichnet neu mit dem Namen (?<name_neu>[^.]+)//) { #_{

        my $name_alt = $+{name_alt};
        my $name_neu = $+{name_neu};


        my $person_rec = {add_rm => '-'};

       ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name_alt);
       push @ret, $person_rec;

       $person_rec = {add_rm => '+'};

       ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name_neu);
       push @ret, $person_rec;


    } #_}
    while ($special_parsing =~ s/\. *([^.]+?)(?:, sind )?zurückgetreten, (?:ihre|seine) Unterschrift ist erloschen//) { #_{

      my $personen = $1;
      for my $person (split /(?:;| und) */, $personen) {

        my $person_rec = {add_rm => '-'};

        $person =~ /([^,]+)(?:,| ist als) (.*?) *$/;
        my $name     = $1;
        $person_rec->{funktion} = $2;

       ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

       push @ret, $person_rec;

      }

    } #_}
    while ($special_parsing =~ s/\. *(?<name>[^.]+), (?:von (?<von>[^.]+?)|(?<von>[^.]*?Staatsangehörige[^.]*?)), in (?<in>[^.,]+?), ist zum (?<funktion>[^.]*?) (?<zeichnung>mit [^.]*?) ernannt worden//) { #_{
      my $person_rec = {add_rm => '+'};

      my $name     = $+{name};
      my $funktion = $+{funktion};
      $person_rec -> {zeichnung} = $+{zeichnung};
      $person_rec -> {von} = s_back($+{von});
      $person_rec -> {in} = $+{in};

      $funktion =~ s/räsidenten\b/räsident/;
      $person_rec -> {funktion} = $funktion;
      
     ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. *(?<name>[^.]+), (?:von und in )(?<wo>[^.]+?), ist zum (?<funktion>[^.]*?) (?<zeichnung>mit [^.]*?) ernannt worden//) { #_{
      my $person_rec = {add_rm => '+'};


      my $name     = $+{name};
      my $funktion = $+{funktion};
      $person_rec -> {zeichnung} = $+{zeichnung};
      $person_rec -> {von} = s_back($+{wo});
      $person_rec -> {in} = $+{wo};

      $funktion =~ s/räsidenten\b/räsident/;
      $person_rec -> {funktion} = $funktion;
      
     ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. *(?<name>[^.]+), bisher eingetragen, ist zum (?<funktion>[^.]+?) ernannt worden//) { #_{ TODO Beachte Ähnlichkeit zum nächsten s
      my $person_rec = {add_rm => '+'};


      my $name     = $+{name};
      my $funktion = $+{funktion};
      $funktion =~ s/räsidenten\b/räsident/;
      $person_rec -> {funktion} = $funktion;
     ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. *(?<name>[^.]+),? bisher eingetragen, ist jetzt (?<funktion>[^.]+)//) { #_{ TODO Beachte Ähnlichkeit zum vorherigen s
      my $person_rec = {add_rm => '+'};



      my $name     = $+{name};
      my $funktion = $+{funktion};
      debug ("bisher eingetragen, ist jetzt...$funktion");
      $funktion =~ s/räsidenten\b/räsident/;
      $person_rec -> {funktion} = $funktion;
     ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. D.. (\w+(?: zu zweien)?) von ([^.]+) ist erloschen//) { #_{

      my $zeichnung = $1;
      my $whom      = $2;


#     if ($zeichnung =~ /Kollektivprokura|zu zweien/) {

        $zeichnung =~ s/^Die //;

        for my $name (split /(?:, und|,| und) */, $whom) {

          my $person_rec = {add_rm => '-'};

          $person_rec -> {zeichnung} = $zeichnung;

          ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

          push @ret, $person_rec;

        }
         
#     }
#     else {
#       print "unexpected Zeichnung $zeichnung\n";
#     }

    } #_}
    while ($special_parsing =~ s/\. *(?<funktion>[^:.]+?): (?<name>[^,]+?), (?:von (?<von>[^.]+?)|(?<von>.*?Staatsangehörige.*?)), in (?<in>[^.]+?), zeichnet (?<zeichnung>mit [^.]+)//) { #_{


      my $name      = $+{name};
#     my $zeichnung = ${zeichnung};

      my $person_rec = {add_rm => '+'};
      $person_rec -> {funktion}  = $+{funktion} ;
      $person_rec -> {zeichnung} = $+{zeichnung};
      $person_rec -> {von}       = $+{von};
      $person_rec -> {in}        = $+{in};

     ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. Eingetragene Personen neu:*(?<name>[^.]+), (?:von (?<von>[^.]+?)|(?<von>[^.]*?Staatsangehörige[^.]*?)), in (?<in>[^.,]+?), (?<funktion>[^.]*), (?<zeichnung>[^.]*)//) { #_{

       print "! Warning 'Eingetragene Personen neu' in special_parsing should not occur anymore\n";
       debug('special parsing, Eingetragene Personen neu');
       $debug_indent++;
       my $name = $+{name};

       debug("Name=$name");

       my $person_rec = {add_rm => '+'};
       $person_rec -> {funktion} = $+{funktion};
       $person_rec -> {zeichnung} = $+{zeichnung};
       $person_rec -> {von} = $+{von};
       $person_rec -> {in} = $+{in};
      ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

       push @ret, $person_rec;

       $debug_indent--;

    } #_}
    while ($special_parsing =~ s/\. *([^.]+?), bisher [^,]+, zeichnet neu mit ([^.]+)//) { #_{

      my $name      = $1;
      my $zeichnung = $2;

      my $person_rec = {add_rm => '+'};
      $person_rec -> {zeichnung} = $zeichnung;

     ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

      push @ret, $person_rec;

    } #_}
    while ($special_parsing =~ s/\. *([^.]+?, von [^.]+?, in [^.]+?)(?:;|,) beide (mit [^.]+)//) { #_{

      debug('special parsing, beide mit ... ');


      my $personen  = $1;
      my $zeichnung = $2;

      for my $person (split /(?:;| und) */, $personen) {
 
         my $person_rec ={add_rm => '+'};
         $person_rec -> {zeichnung} = $zeichnung;

         $person =~ /(.*), von (.*?), in ([^,.]+)(?:, ist )?(.*)/;

         my $name     = $1;
         my $von      = $2;
         my $in       = $3;
         my $funktion = $4;

        ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

         $person_rec->{von} = s_back($von);
         $person_rec->{in } = s_back($in);
         $person_rec->{funktion } = $funktion if $funktion;
 
         push @ret, $person_rec;
 
      }

    } #_}
    while ($special_parsing =~ s/\. *([^.]+?) zeichne. (?:\w+ )?(mit [^.]+)//) { #_{
      my $who = $1;
      my $zeichnung = $2;

      who_and_zeichnung(\@ret, $who, $zeichnung);


    } #_}
    while ($special_parsing =~ s/\. Gelöschte Personen:*(?<name>[^.]+?), (?<funktion>[^.]*)//) { #_{
       print "! Warning Gelöschte Personen in special_parsing should not occur anymore\n";

       my $name = $+{name};

       my $person_rec = {add_rm => '-'};
       $person_rec -> {funktion} = $+{funktion};
      ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

       push @ret, $person_rec;


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

     ($rec_person->{nachname}, $rec_person->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

      push @ret, $rec_person;


    } #_}
    while ($special_parsing =~ s/(Revisionsstelle|Réviseur): (.*), (?:in|à) ([^.]+)\.//) { #_{

      my $rec_person = {
        add_rm      => '+',
        bezeichnung =>  s_back($2),
        in          =>  s_back($3),
        funktion    =>  $1
      };

      push @ret, $rec_person;
    } #_}
    while ($special_parsing =~ s/Die bisherige Revisionsstelle (.*), in (.*), ist weggefallen//) { #_{

      my $rec_person = {
        add_rm      => '-',
        bezeichnung =>  s_back($1),
        in          =>  s_back($2),
        funktion    =>  'Revisionsstelle'
      };

      push @ret, $rec_person;
    } #_}
    while ($special_parsing =~ s/Aufsichtsbehörde neu: ([^[.]+)//) { #_{

      my $aufsichtsbehoerde = s_back($1);
      $aufsichtsbehoerde =~ s/ *$//;
      my $rec_person = {
        add_rm      => '+',
        bezeichnung =>  $aufsichtsbehoerde,
        in          => '', # f 270248
        funktion    => 'Aufsichtsbehörde'
      };

      push @ret, $rec_person;
    } #_}
    while ($special_parsing =~ s/\. ([^,]+), eingetragen mit (\w+(?: zu zweien)?), ist neu wohnhaft in ([^.]+)//) { #_{

      my $name       = $1;
      my $zeichnung =  $2;
      my $in = s_back($3);

      my $rec_person = {
        add_rm      => '+',
        zeichnung   => $zeichnung,
        in          => $in,
      };
     ($rec_person->{nachname}, $rec_person->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

      push @ret, $rec_person;
    } #_}
 #_}
    $debug_indent--;
    debug("while (\@PARTS) [scalar \@PARTS=" . scalar @PARTS . ']');
    $debug_indent++;
    while (@PARTS) { #_{

      debug('PART -------');
      $debug_indent++;

      my $intro_text    = shift @PARTS;
      my $personen_text = shift @PARTS;

      debug("intro_text  = $intro_text");

      my @person_parts;


      debug("personen_text, vor escape_und(): $personen_text\n");
      $personen_text = escape_und($personen_text);
      $personen_text =~ s/ *\[nicht:[^\]]+\]//g;
      $personen_text =~ s/ *\[bisher:[^\]]+\]//g;
      debug("personen_text, nach escape_und(): $personen_text\n");


      @person_parts = grep {defined} split /(?:\.|;|,? und |, ((?:beide|alle drei) mit [^.]*)) */, $personen_text;
      debug ('scalar @person_parts=' . scalar @person_parts);

      for my $person_text (@person_parts) { #_{
        debug("person_text loop = $person_text");
        $debug_indent ++;

#       debug("person_text vorher = $person_text");
        $person_text =~ s/##k_von_und_in##/, von und in /;
#       $person_text =~ s/#1<#von_([^_]+?)_und_([^.]*?)#1>#/ von $1 und $2/g;
        $person_text = unescape_und($person_text);

        if ($person_text =~ /^ *beide (mit .*)/) { #_{

          my $zeichnung = $1;
          debug("beide mit $zeichnung");

          if (@ret < 2) {
            print "! beide mit ... ret (" . scalar @ret . ") < 2\n";
          }
          else {
            $ret[-1]->{zeichnung} = $zeichnung;
            $ret[-2]->{zeichnung} = $zeichnung;
          }

          $debug_indent --;
          next;
        } #_}
#       if ($person_text =~ /^ alle drei (mit .*)/) 

        my $person_rec = {};
  
        if ($intro_text =~ /^Eingetragene Personen/ or $intro_text =~ /[iI]nscrip?t/ or $intro_text =~ /[Pp]ersone iscritte/ or $intro_text =~ /^Personen neu/ or $intro_text eq 'Stiftungsrat:') { #_{
           debug ("add_rm = + (intro_text = $intro_text");
           $person_rec = {'add_rm' => '+'};
        }
        else {
           debug ("add_rm = - (intro_text = $intro_text");
           $person_rec = {'add_rm' => '-'};
        } #_}
  
        if ($person_text =~ s! *[([]?<R>([^<]+)<E>[)\]]?!!g)  { #_{
          $person_rec->{firma} = s_back($1);
        } #_}
        if ($intro_text eq 'Gelöschte Personen') { #_{
           debug ('Gelöschte Personen');
           if ($person_text =~ /^(?<name>[^,]+), *(?<funktion>[^,]+)$/) {
             $person_rec -> {funktion} = $+{funktion};
            ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($+{name});
            push @ret, $person_rec;
            next;
          }
          print "! Warning Gelöschte Personen: too many ,\n";
        } #_}
        if ($person_text =~ / *(?<name>.*?), (?:von und in) (?<vonin>[^,]+?), *(?<more>.*)/) { #_{
          my $name = $+{name};
          my $more = $+{more};
          $person_rec->{von}      = $+{vonin};
          $person_rec->{in}       = $+{vonin};

          debug ('person_text =~ <name> .. von und in .. more');
  
          $debug_indent++;
  
          name_to_nachname_vorname($rec, $person_rec, $name);
          parse_person_more       ($rec, $person_rec, $more);

          $debug_indent--;
  
        } #_}
        elsif ($person_text =~ / *(.*?), (?:in|à) ([^,]+),?( [^,]+##p_\w\w\w?##,)? *(.*)/) { #_{

          debug ('person_text =~ in|a');
          $debug_indent++;
  
          my $name = s_back($1);
          my $in   = s_back($2);
          my $country_with_parans = $3;
          my $more = $4;
          $person_rec->{in} = s_back($in);

          debug("name = $name");
          debug("in   = $in");
          debug("more = $more");
  
          if ($country_with_parans) { #_{
            debug('country_with_parans');
            $country_with_parans = s_back($country_with_parans);
            $country_with_parans =~ s/ *,$//;
            $person_rec->{in} .= "," . s_back($country_with_parans);
          } #_}
  
          if ($name =~ / *(.*), (?:Heimat:|von|de|da) (.*)/) { #_{
            debug('Heimat:|von|de|da');
  
            my $naturliche_person = $1;
            $person_rec->{von} = $2;
            name_to_nachname_vorname($rec, $person_rec, $naturliche_person);
  
  
          } #_}
          elsif ($name =~ / *(.*), *([^,]*(?:Staatsangehöriger?|ressortissant|cittadino|\bcitoyen)[^]]*)/) { #_{
            debug('Staatsangehörige');
  
            my $naturliche_person = $1;
            $person_rec->{von} = $2;
  
            $naturliche_person =~ /([^,]+), *(.*)/;
  
            $person_rec->{nachname} = $1;
            $person_rec->{vorname } = $2;
  
          } #_}
          else { #_{
            debug('else, bezeichnung = name');
  
            $person_rec->{bezeichnung} = $name;
  
          } #_}
  
          parse_person_more($rec, $person_rec, $more);

          $debug_indent--;
  
  
        } #_}
        else { #_{
  #q        print "**** $rec->{id_firma} $person_text\n";
        } #_}
  
  
        if ($person_rec->{bezeichnung} or $person_rec->{vorname} or $person_rec->{nachname}) {
          push @ret, $person_rec;
        }
        $debug_indent --;
      } #_}
  
      $debug_indent--;
    } #_}
    $debug_indent--;

    $debug_indent--;
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

  debug('for my $rec_..');
  for my $rec_ (@ret) { #_{
#   $rec_->{von} = split_von($rec_->{von});


#   if ($rec->{vorname} and $rec->{vorname} =~ s/(( *Prof\. *)*( *Dr\. *)*( *\bh\. *c\. *)*)//) {
    if ($rec_->{vorname}) {
      my @titles;
        
      while ($rec_->{vorname} =~ s/ *((Prof|Dr|h\. ?c)\.) *//) { # Achtung: Da gibt's einen »genannt % Dr. PI«
        push @titles, $1;
      } 
#       and $rec->{vorname} =~ s/(( *Prof\. *)*( *Dr\. *)*( *\bh\. *c\. *)*)//) {

      $rec_->{titel} = join " ", @titles;
    }
    else {
      $rec_->{titel} = '';
    }

#   if ($rec->{vorname} =~ s/ *Prof\. *//g) {
#     push @titles, 'Dr.';
#   }
#   if ($rec->{vorname} =~ s/ *Dr\. *//) {
#     push @titles, 'Dr.';
#   }

  } #_}

  return @ret;


} #_}

sub split_von { #_{

  return [] unless $_[0];

  return [sort (split ('(?:,| und | et | e )', $_[0]))];
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
  my $rec        = shift;
  my $person_rec = shift;
  my $name       = shift;

  $debug_indent++;

  debug("name_to_nachname_vorname name = $name");

  if ($rec->{registeramt} == 229) {  #_{ Registeramt 229 does not seem to have commas between first and last name

     ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);


     $person_rec->{von} =~ s/ *\(bisher von .*\)//;
     $person_rec->{in}  =~ s/ *\(bisher in .*\)//;

  } #_}
  else { #_{
     if ($name =~ /([^,]+), *(.*)/) {
       $person_rec->{nachname} = $1;
       $person_rec->{vorname } = $2;
     }
     else {

      
      if ($rec->{registeramt} == 217) {
       ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);
      }
      else {
       ($person_rec->{vorname}, $person_rec->{nachname}) = name_ohne_komma_to_nachname_vorname($name);
      }

     }

  } #_}
  $debug_indent--;

} #_}

sub name_ohne_komma_to_nachname_vorname { #_{
  $debug_indent ++;
  my $name = shift;

  debug("name_ohne_komma_to_nachname_vorname, name = $name");

  $name =~ s/^([Vv]on) /$1%%/;

  $name =~ /([^ ]+) +(.*)/;

  my $nachname = $1;
  my $vorname  = $2;

  $nachname =~ s/(.*)%%/$1 /;

  $debug_indent --;
  return (s_back($nachname), s_back($vorname));

} #_}

sub parse_person_more { #_{
  my $rec        = shift;
  my $rec_person = shift;
  my $more       = shift;


  $debug_indent++;

  debug("parse_person_more($more)");


# 2017-03-24 commented: version that tried to fix [ … ] and ( … ) in one match
# $more =~ s/ *[[(](?:bisher|précédemment|finora):? *([^\])]+)[\])]//;
#
# Now: two matches. Hopefully a bit better...
  $more =~ s/ *\[(?:bisher|précédemment|finora):? *([^\]]+)\]//;
  $more =~ s/ *\((?:bisher|précédemment|finora):? *([^\)]+)\)//;

  my $person_det_bisher = $1;

  $more =~ s/ *\[come finora\]//;
  $more =~ s/ *[[(]wie bisher[\])]//;

  $more =~ s/ *[[(](?:nicht|non): *([^\])]+)[\])]//;
# $more =~ s/ *[\[]bisher:([^\])]+)[\]]//;
  debug ("after remove [] $more");
  my $person_det_nicht = $1;

  my @parts = split ' *, *', $more;

  @parts = grep { #_{

    if (/ *(Gesellschafter\w*) (mit einer Stammeinlage von [^#]+)##k_und_GF([^#]*)## */) {

      $rec_person->{funktion    } = "$1 und Geschäftsführer$3";
      $rec_person->{stammeinlage} = $2;

      debug("Gesellschafter..mit Stammeinlage..und");

      0;
    }
    else {
      1;
    }

  } @parts; #_}

  @parts = grep { #_{ Zeichnung


     if (/[Uu]nterschrift/           or
         /[Pp]rokura/                or
         /[Zz]eichnungsberechtigung/ or
         /signature/                 or
         /\bcon firma /              or
         /\bcon procura /            or
         /\bavec procuration\b/      or
         /senza diritto di firma/    or
         /\bKU\b/
        ) {

    #   TODO This should really not be...
        s/##$//;
        s/#1>#$//;

        debug("Zeichnung: $_<");

        if (exists $rec_person->{zeichnung} and $_ ne $rec_person->{zeichnung}) {
        
        #
        #  Zb f385488 / Test: 17-058
        #
          print "Already exists $rec->{id_firma}: $rec_person->{nachname} $rec_person->{vorname} $rec_person->{zeichnung}, _ = $_\n" ;
        }
        $rec_person->{zeichnung} = s_back($_);
        0;

      }
      else {
        1;
      }

  } @parts; #_}

  @parts = grep { #_{ Funktion


     if (/Verwaltungsrat/           or #_{
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
         /\badministratrice\b/       or
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
         /Quästor(in)?\b/       or
         /Rechnungsführer(in)?\b/       or
         /\bdipl\./                 or
         /\bGM\b/                  or
         /Chef/            or
         /provisorischer SR/  # f270248 #_}
         
       ) {

        debug ("Funktion: $_");
        if (exists $rec_person->{funktion}) {
          $rec_person->{funktion} .= ', '. $_;
        }
        else {
          $rec_person->{funktion} = s_back($_);
          $rec_person->{funktion} =~ s/^ *//;
        }
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
         /pour (une|\d+) parts? sociales? de / or
         /mit einer Kommanditsumme von/
      ) {

        print "Already exists: $rec_person->{stammeinlage}, _ = $_\n" if exists $rec_person->{stammeinlage};
        $rec_person->{stammeinlage} = s_back($_);
        0;

      }
      else {
        1;
      }

  } @parts; #_}

  $rec_person->{rest} = join " @ ",  @parts;

  $debug_indent --;


} #_}

sub text_to_name_von_in { #_{
  my $text = shift;
# $text =~ /(.*?), von (.*?), in (.*?)(,|$)(.*)/;
  $text =~ /(.*?), von (.*?), in (.*?)(,|$)(.*)/;

  my $name      = $1;
  my $von       = $2;
  my $in        = $3;

  my $funktion  = $5;

# print "\n\n text_to_name_von_in, funktion = $funktion\n\n";

  return (s_back($name), s_back($von), s_back($in), $funktion);
} #_}

sub who_and_zeichnung { #_{
  my $ret_ref   = shift;
  my $who       = shift;
  my $zeichnung = shift;

  $who =~ s/(von \w+ )und( \w+)/$1##UND##$2/g; # f718052 (Test) Reutimann Werner, von Zürich und Waltalingen

  my $funktion;

  my @persons_recs;

  my @persons = split /,? und /, $who;
  for my $person (@persons ) {

    $person =~ s/##UND##/und/;
    my $person_rec = {add_rm=>'+'};
    $person_rec->{zeichnung} = $zeichnung;

   (my $name, $person_rec->{von}, $person_rec->{in}, $funktion) = text_to_name_von_in($person);


   ($person_rec->{nachname}, $person_rec->{vorname}) = name_ohne_komma_to_nachname_vorname($name);

    push @$ret_ref    , $person_rec;
    push @persons_recs, $person_rec;

  }

  if ($funktion) {
    $funktion =~ s/^ *//;
    $funktion =~ s/ *$//;
    $funktion =~ s/^beide *//;
    $funktion =~ s/glieder$/glied/;
    map {$_->{funktion} = $funktion} @persons_recs;
  }


} #_}

sub escape_und { #_{
  my $text = shift;
#
# $text =~ s/ von ((?:(?!in ))[^.,]+?) und ([^\];.,]+)/#1<#von_$1_und_$2#1>#/g;

# print "\n\n\n$text\n\n";
# $text =~ s/ von (.*?) und (.*?)(?= und | von |, in)/#1<#von_$1_und_$2#1>#/g;

# Test...
# my $text = "abc VVV foo III pqr hash def VVV bar hash baz III stu hash ghi VVV bbb, ccc hash ddd III vwx";
#    $text =~ s/ VVV ((?:(?!III).)*?) hash (.*?)(?=III)/ VVV $1 HASH $2/g;
#  (http://stackoverflow.com/questions/43046270/why-does-word-another-word-match-only-a-character)

# $text =~ s/ von (.(?!, in ))*? und (.*?)(?=, in)/#1<#von_$1_und_$2#1>#/g;
# $text =~ s/ von (.(?!, in ))*? und (.*?)(?=, in)/  von    1: $1\n    2: $2\n   3: $3\n  4: $4\n/g;
# print "\n\n\n$text\n\n";
  $text =~ s/ von ((?:(?!, in ).)*?) und (.*?)(?=;|, in)/#1<#von_$1_und_$2#1>#/g;
# print "\n\n\n$text\n\n";

  $text =~ s/ und mit einem Stammanteil von /##_und_mit_stammanteil_von_##/g;
  return $text;

} #_}

sub unescape_und { #_{
  my $text = shift;
  $text =~ s/##_und_mit_stammanteil_von_##/ und mit einem Stammanteil von /g;
  $text =~ s/#1<#von_([^_]+?)_und_([^.]*?)#1>#/ von $1 und $2/g;
  return $text;
} #_}

sub debug { #_{
  return unless $debug;
  print '  ' x $debug_indent;
# print "$_[0]\n";
  print wrap('', '  ' x $debug_indent, $_[0]);
  print "\n";
} #_}

1;
