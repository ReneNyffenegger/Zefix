#!/usr/bin/perl
# .mode column
# .width 9 20 100
# select f.id, s.stichwort, f.bezeichnung  from firma f join stichwort_firma sf on sf.id_firma = f.id join stichwort s on sf.id_stichwort = s.id order by s.stichwort, f.bezeichnung;
use warnings;
use strict;
use utf8;
use 5.10.0;
use Encode;
use DBI;
use Encode qw(decode encode);
use Getopt::Long;
use Time::HiRes qw(time);

use Zefix;

my $zefix_root;
my %stichwoerter;

unless ($^O eq 'MSWin32') {
  # Input files seem to be in dos format.
  # Why it does not need be changed in a windows environment is still a mystery to me.
  $/ = "\r\n";
}

my $env = 'test';

GetOptions (
  'prod'    => \my $prod
) or die;

$env = 'prod' if $prod;
print "env = $env\n";

Zefix::init($env eq 'prod' ? 'dev' : 'test');

if ($env eq 'test') {
  $zefix_root = "$ENV{github_root}Zefix/test/";
}
elsif ($env eq 'prod') {
  $zefix_root = "$ENV{digitales_backup}Zefix/";
}
else {
   die "unknown env $env\n";
}
die $zefix_root unless -d $zefix_root;

my $zefix_downloads = "${zefix_root}downloaded/";
die unless -d $zefix_downloads;

my $db = "${zefix_root}zefix.db";
# die unless -f $db;



my $dbh = DBI->connect("dbi:SQLite:dbname=$db") or die "Could not open/create $db";
$dbh->{AutoCommit} = 0;

load_daily_summaries();
load_person();

$dbh -> commit;
# exit;

my %word_cnt;
load_stichwoerter();
$dbh -> commit;
for my $word (sort { $word_cnt{$b} <=> $word_cnt{$a} } keys %word_cnt) {
  printf "%5d: $word\n", $word_cnt{$word};
}
# exit;

print "TODO: Forcing gemeinden to be loaded\n";
# $load_gemeinden = 1;
trunc_table_gemeinde();
my $cnt_gemeinden = $dbh->selectrow_array('select count(*) from gemeinde');
print "cnt_gemeinden=$cnt_gemeinden\n";


my $load_gemeinden = ! $cnt_gemeinden;



load_firmen();
load_firmen_bez();

$dbh -> commit;

# Without AutoCommit: »cannot VACUUM from within a transaction«
$dbh->{AutoCommit} = 1;
$dbh -> do('vacuum');

if ($env eq 'test') {
  chdir '../test';
  print readpipe 'php test_load.php';
}

sub load_daily_summaries { #_{ Basically loads person_firma_stg

  trunc_table_person_firma_stg();

  my $sth_ins_person_firma_stg = $dbh->prepare('insert into person_firma_stg values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?               )') or die;
# my $sth_ins_person_firma_stg = $dbh->prepare('insert into person_firma_stg values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');

  my $file_cnt = 0;
  for my $file (Zefix::daily_summary_files()) { #_{
    $file_cnt ++;
    print "$file [$file_cnt]\n";

    my $zefix_file = Zefix::open_daily_summary_file($file);
    while (my $rec = Zefix::parse_next_daily_summary_line($zefix_file)) { #_{

      my @personen = Zefix::find_persons_from_daily_summary_rec($rec);
      for my $personen_rec (@personen) { #_{


        $sth_ins_person_firma_stg->execute( #_{
                 $rec         ->{id_firma},
                 $rec         ->{dt_journal},
                 $personen_rec->{add_rm},
                 $personen_rec->{titel},
                 $personen_rec->{nachname},
                 $personen_rec->{vorname},
                 $personen_rec->{von},
#              ${$personen_rec->{von}}[0],
#              ${$personen_rec->{von}}[1],
#              ${$personen_rec->{von}}[2],
#              ${$personen_rec->{von}}[3],
#              ${$personen_rec->{von}}[4],
#              ${$personen_rec->{von}}[5],
                 $personen_rec->{bezeichnung},
                 $personen_rec->{in},

                 $personen_rec->{funktion},
                 $personen_rec->{zeichnung},
                 $personen_rec->{stammeinlage},
        ); #_}

      } #_}

    } #_}

  } #_}

} #_}

sub load_person { #_{

  $dbh -> do('drop table if exists person') or die;
  $dbh -> do('
    create table person (
      id          integer primary key,
      vorname     text,
      nachname    text,
      von         text,
      bezeichnung text,
--    in_         text,
      cnt         integer not null,
      cnt_firma   integer not null
    )
  ');

  $dbh -> do('
    insert into person (vorname, nachname, von, bezeichnung,
    --in_,
    cnt, cnt_firma)
      select
        vorname,
        nachname,
        von,
        bezeichnung,
--      in_,
        count(*) cnt,
        count(distinct id_firma) cnt_firma
      from
        person_firma_stg
      group by
        vorname,
        nachname,
        von,
        bezeichnung
 --     in_
 --     having count(distinct id_firma) > 1
   ');


  $dbh -> do('drop table if exists person_firma') or die;

# $dbh -> do("create index stage_ix_ on person_firma_stg (       vorname       ,         nachname,              von,                bezeichnung      )")
  $dbh -> do("create index stage_ix_ on person_firma_stg (ifnull(vorname, '?') || ifnull(nachname, '?') || ifnull(von, '?') || ifnull(bezeichnung, '?'))");
# $dbh -> do("create index stage_ix_ on person           (vorname || '?' || nachname || '?' || von || '?' || bezeichnung || '?' || in_)")

  $dbh -> do("

--  explain query plan

    create table person_firma as
    select
      s.id_firma,
      p.id            id_person,
      s.dt_journal,
      s.add_rm,
      s.in_,
      s.titel,
      s.funktion,
      s.zeichnung,
      s.stammeinlage   einlage
    from
      person_firma_stg s                                                                join
      person           p on
        ifnull(s.vorname, '?') || ifnull(s.nachname, '?') || ifnull(s.von, '?') || ifnull(s.bezeichnung, '?') =
        ifnull(p.vorname, '?') || ifnull(p.nachname, '?') || ifnull(p.von, '?') || ifnull(p.bezeichnung, '?')

--    person           p on ifnull(s.vorname    , '?') = ifnull(p.vorname    , '?') and
--                          ifnull(s.nachname   , '?') = ifnull(p.nachname   , '?') and
--                          ifnull(s.von        , '?') = ifnull(p.von        , '?') and
--                          ifnull(s.bezeichnung, '?') = ifnull(p.bezeichnung, '?')
--                          ifnull(s.in_        , '?') = ifnull(p.in_        , '?')
   ") or die;

 $dbh -> do("drop table person_firma_stg");
 $dbh -> do("create index person_firma_ix_id_firma  on person_firma(id_firma )");
 $dbh -> do("create index person_firma_ix_id_person on person_firma(id_person)");
 $dbh -> do("create index person_ix_nachname_vorname_von on person(nachname, vorname, von)");


} #_}

sub load_firmen { #_{

 my $fi_firma         ; # my $fi_firma_last = -1; #_{
 my $fi_Code13        ;
 my $fi_RechtsformID  ;
 my $fi_hauptsitz     ;
 my $fi_GemeindeNR    ;
 my $fi_GemeindeName  ;
#my $fi_RegisteramtID ;
 my $fi_Kapital       ;
 my $fi_CurrencyID    ;
 my $fi_statusID      ;
 my $fi_Loeschdat     ;
#my $fi_SHABDat       ;
#my $fi_ShabNr        ;
#my $fi_ShabSeite     ;
#my $fi_MutTyp        ;
#my $fi_DatumMutation ;
 my $fi_ShabSequence  ;
 my $fi_Address       ;
 my $fi_CareOf        ;
 my $fi_Strasse       ;
 my $fi_Hausnummer    ;
 my $fi_Addresszusatz ;
 my $fi_Postfach      ;
 my $fi_PLZ           ;
 my $fi_Ort           ;
 my $fi_Zweck         ; #_}

 # 2017-03-22: Fix Typos:
  $fi_Zweck =~s/ m Rahmender/m Rahmen der/g;
  $fi_Zweck =~s/\blm/Im/g;

  print "load_firmen\n";
  my $cnt = 0;

  my %Gemeinde_NR_2_Name;

  my $tsv_firmen     = "${zefix_downloads}firmen";

  die unless -f $tsv_firmen;

  trunc_table_firma();
  trunc_table_zweck();

  my $sth_gemeinde;
  if ($load_gemeinden) {
#    trunc_table_gemeinde();
     $sth_gemeinde = $dbh -> prepare('insert into gemeinde values(?, ?)') or die;
  }
  my $sth_firma_stg = $dbh -> prepare ('insert into firma_stage values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)') or die;
  my $sth_zweck     = $dbh -> prepare ('insert into zweck       values (?,?)                              ') or die;


  open (my $f_firmen, '<', $tsv_firmen) or die;
  my $start_t = time;
  while (my $in = <$f_firmen>) { #_{


    chomp $in;

    my @row = split("\t", $in);

    state $fi_firma_last = $row[0];
    if ($fi_firma_last != $row[0]) {

      $fi_Loeschdat =~ s/ 00:00:00$// if defined $fi_Loeschdat;
  
      $cnt++;
      $sth_firma_stg -> execute($fi_firma, $fi_Code13, $fi_hauptsitz, $fi_GemeindeNR, $fi_Kapital, $fi_CurrencyID, $fi_statusID, $fi_Loeschdat, $fi_ShabSequence, $fi_CareOf, $fi_Strasse, $fi_Hausnummer, $fi_Addresszusatz, $fi_Postfach, $fi_PLZ, $fi_Ort, $fi_RechtsformID);
      $sth_zweck -> execute($fi_firma, $fi_Zweck);

    }

    $fi_firma         = $row[ 0]; #_{
    $fi_Code13        = $row[ 1];
    $fi_RechtsformID  = $row[ 2];
    $fi_hauptsitz     = $row[ 3] || undef;
    $fi_GemeindeNR    = $row[ 4] || undef;
    $fi_GemeindeName  = to_txt($row[5]);
#   $fi_RegisteramtID = $row[ 6];
    $fi_Kapital       = $row[ 7] || undef;
    $fi_CurrencyID    = $row[ 8] || undef;
    $fi_statusID      = $row[ 9]; #  || undef; # 0: gelöscht, 2: aktiv, 3: in Auflösung (von Amtes wegen, Konkurs, Fusion)
    $fi_Loeschdat     = $row[10] || undef; # Wenn status = 0
#   $fi_SHABDat       = $row[11]; # ignorieren, nur Zefix intern
#   $fi_ShabNr        = $row[12]; # ignorieren, nur Zefix intern
#   $fi_ShabSeite     = $row[13]; # ignorieren, nur Zefix intern
#   $fi_MutTyp        = $row[14]; # ignorieren, nur Zefix intern
#   $fi_DatumMutation = $row[15]; # ignorieren, nur Zefix intern
    $fi_ShabSequence  = $row[16] || undef;
    $fi_Address       = $row[17]; # Always emtpy?
    $fi_CareOf        = to_txt($row[18]);
    $fi_Strasse       = to_txt($row[19]);
    $fi_Hausnummer    = $row[20];
    $fi_Addresszusatz = to_txt($row[21]);
    $fi_Postfach      = $row[22];
    $fi_PLZ           = $row[23];
    $fi_Ort           = to_txt($row[24]);
    $fi_Zweck         = to_txt($row[25]); #_}

    if ($load_gemeinden) { #_{
      if (! $fi_GemeindeName) {
        print "fi_GemeindeName is empty\n";
      }
      else {
        if (exists $Gemeinde_NR_2_Name{$fi_GemeindeNR}) {
          if ($Gemeinde_NR_2_Name{$fi_GemeindeNR} ne $fi_GemeindeName) {
            printf "%5d %-30s %-30s\n", $fi_GemeindeNR, $Gemeinde_NR_2_Name{$fi_GemeindeNR}, $fi_GemeindeName;
          }
        }
        else {
          $sth_gemeinde -> execute($fi_GemeindeNR, $fi_GemeindeName);
          $Gemeinde_NR_2_Name{$fi_GemeindeNR} = $fi_GemeindeName;
        }
      }
    } #_}


    $fi_firma_last = $fi_firma;

    print "$cnt\n" unless $cnt % 10000;
  } #_}

  $cnt++;
  $sth_firma_stg -> execute($fi_firma, $fi_Code13, $fi_hauptsitz, $fi_GemeindeNR, $fi_Kapital, $fi_CurrencyID, $fi_statusID, $fi_Loeschdat, $fi_ShabSequence, $fi_CareOf, $fi_Strasse, $fi_Hausnummer, $fi_Addresszusatz, $fi_Postfach, $fi_PLZ, $fi_Ort, $fi_RechtsformID);
  $sth_zweck -> execute($fi_firma, $fi_Zweck);

  $dbh->do('create index firma_gemeinde_ix on firma (id_gemeinde)');

  my $end_t = time;

  printf("load_firmen: loaded %i records in %5.2f seconds (%7.2f recs/s)\n", $cnt, $end_t - $start_t, $cnt/($end_t - $start_t));

} #_}

sub load_firmen_bez { #_{
  print "load_firmen_bez\n";
  my $cnt = 0;
  my $tsv_firmen_bez = "${zefix_downloads}firmen_bezeichnung";
  die unless -f $tsv_firmen_bez;

  trunc_table_firma_bez();
  my $sth_firma_bez = $dbh -> prepare ('insert into firma_bez values (?,?,?,?,?,?,?,?)') or die;

  open (my $f_firmen_bez, '<', $tsv_firmen_bez) or die;
  my $start_t = time;
  while (my $in = <$f_firmen_bez>) {
    $cnt++;
    chomp $in; 
    my @row = split("\t", $in);

    my $fi_id         = $row[0];
    my $seq           = $row[1];
    my $typ           = $row[2];
    my $sprachcode    = $row[3]; # DE, FR, IT, EN, XX
    my $status        = $row[4]; # -1: nicht mehr gültige Bezeichnung, 3: letztgültige Bezeichnung
    my $bezeichnung   = to_txt($row[5]);
    my $dt_ab         = Zefix::to_dt ($row[6]);
    my $dt_bis        = Zefix::to_dt ($row[7]);

    $sth_firma_bez -> execute($fi_id, $seq, $typ, $sprachcode, $status, $bezeichnung, $dt_ab, $dt_bis);
  
    print "$cnt\n" unless $cnt % 10000;
  }

  my $end_t = time;
  printf("load_firmen_bez: loaded %i records in %5.2f seconds (%7.2f recs/s)\n", $cnt, $end_t - $start_t, $cnt/($end_t - $start_t));

  $start_t = time;
  print "stage to firma\n";
  $dbh -> do('

    insert into firma select

      s.id             ,
      b.bezeichnung    ,
      s.code13         ,
      s.id_hauptsitz   ,
      s.id_gemeinde    ,
      s.kapital        ,
      s.currency       ,
      s.status         ,
      s.loesch_dat     ,
      s.shab_seq       ,
      s.care_of        ,
      s.strasse        ,
      s.hausnummer     ,
      s.address_zusatz ,
      s.postfach       ,
      s.plz            ,
      s.ort            ,
      s.rechtsform     
    from
      firma_stage   s       join
      firma_bez     b on s.id = b.id_firma and b.status = 3 and b.typ = 1
    ');
  $dbh -> do('drop table firma_stage');
  $end_t = time;
  printf("done: in %5.2f seconds\n", $end_t - $start_t);

} #_}

sub load_stichwoerter { #_{
  my $start_t = time;
  trunc_table_stichwort();
  trunc_table_stichwort_firma();

  init_stichwoerter();
  load_stichwoerter_table(%stichwoerter);
  
  my $sth_ins_stichwort_firma = $dbh->prepare('insert into stichwort_firma values(?, ?)') or die;
  my $sth = $dbh -> prepare( #_{
    '
    select
      f.id           id_firma,
      f.bezeichnung  bezeichnung,
      z.zweck
    from
      firma f join
      zweck z on f.id = z.id_firma'
  ) or die; #_}
  $sth -> execute;

  my $cnt = 0;
  while (my $r = $sth -> fetchrow_hashref) { #_{
#   print $r->{bezeichnung},"\n";
    my $zweck = lc decode_utf8($r->{zweck});
#   my $zweck = lc ($r->{zweck});

    $zweck =~ s/\bdie gesellschaft kann.*//;
    $zweck =~ s/; (sie )?kann.*//;
    $zweck =~ tr/äöüéê/aouee/;

    my $stichwort_already_inserted = {};

    fill_stichwort_firma($r->{id_firma}, $zweck                           , $sth_ins_stichwort_firma, $stichwort_already_inserted);
    fill_stichwort_firma($r->{id_firma}, lc decode_utf8($r->{bezeichnung}), $sth_ins_stichwort_firma, $stichwort_already_inserted);

    $cnt ++;
# # return if $cnt > 10000;
    print "$cnt\n" unless $cnt % 1000;
  } #_}


  $dbh->do('create index stichwort_firma_firma_ix     on stichwort_firma(id_firma)');
  $dbh->do('create index stichwort_firma_stichwort_ix on stichwort_firma(id_stichwort)');
  $dbh->do('create index stichwort__ix on stichwort(stichwort)');

  $dbh->do('analyze stichwort');
  $dbh->do('analyze stichwort_firma');

  my $end_t = time;
  printf("load_stichwoerter_table in %5.2f seconds\n", $end_t - $start_t);
  print "cnt = $cnt\n";

  for my $stichwort (sort keys %stichwoerter) {
    for my $qr (@{$stichwoerter{$stichwort}{qrs}}) {
#     printf "%-30s %-30s %6d\n", $stichwort, $qr, $stichwoerter{$stichwort}{qrs_cnt}{$qr} // 0;

    }
  }

} #_}

sub fill_stichwort_firma { #_{
  my $id_firma                   = shift;
  my $text                       = shift;
  my $sth_ins                    = shift;
  my $stichwort_already_inserted = shift;

  for my $stichwort (keys %stichwoerter) {

    next if $stichwort_already_inserted->{$stichwort};
    for my $qr (@{$stichwoerter{$stichwort}{qrs}}) {
      if ($text =~ $qr) {

         $sth_ins -> execute($id_firma, $stichwoerter{$stichwort}{id}) or die;
         $stichwort_already_inserted->{$stichwort} = 1;

         $stichwoerter{$stichwort}{qrs_cnt}{$qr}++;

      }
    }
  }

# q  $text =~ s/[ &?".,;'()!_:]/ /g;
# q  $text =~ s/-//g;
# q
# q  my @words = split ' ', $text;
# q  for my $word (@words) { #_{
# q
# q    $word =~ s/n$//; #_{
# q    $word =~ s/r$//;
# q    $word =~ s/e$//;
# q    $word =~ s/s$//;
# q    $word =~ s/ä/a/;
# q    $word =~ s/ö/o/;
# q    $word =~ s/ü/u/;
# q    $word =~ s/é/e/;
# q    $word =~ s/è/e/;
# q    $word =~ s/á/a/;
# q    $word =~ s/à/a/;
# q    $word =~ s/ó/o/; #_}
# q
# q    next if $word eq 'd'; #_{
# q    next if $word eq 'vo';
# q    next if $word eq 'und';
# q    next if $word eq 'et';
# q    next if $word eq 'sowi';
# q    next if $word eq 'fu';
# q    next if $word eq 'verwaltung';
# q    next if $word eq 'verkauf';
# q    next if $word eq 'od';
# q    next if $word eq 'o';
# q    next if $word eq 'insbesonder';         #  !!!!!!
# q    next if $word eq 'AG';
# q    next if $word eq 'i';
# q    next if $word eq 'di';
# q    next unless $word;
# q    next if $word eq 'a';
# q    next if $word eq 'all';
# q    next if $word eq 'la';
# q    next if $word eq 'l';
# q    next if $word eq 'mit';
# q    next if $word eq 'art';
# q    next if $word eq 'liquidatio';
# q    next if $word eq 'handel';
# q    next if $word eq 'im';
# q    next if $word eq 'de';
# q    next if $word eq 'erwerb';
# q    next if $word eq 'gesellschaft';
# q    next if $word eq 'gmbh';
# q    next if $word eq 'ag';
# q    next if $word eq 'bezweckt';
# q    next if $word eq 'sagl'; #_}
# q
# q    $word_cnt{$word} ++;
# q
# q    for my $stichwort (keys %stichwoerter) {
# q
# q      next if $stichwort_already_inserted->{$stichwort};
# q
# q      for my $qr (@{$stichwoerter{$stichwort}{qrs}}) {
# q        if ($word =~ $qr) {
# q          $sth_ins -> execute($id_firma, $stichwoerter{$stichwort}{id}) or die;
# q          $stichwort_already_inserted->{$stichwort} = 1;
# q        }
# q      }
# q
# q    }
# q
# q  } #_}

} #_}

sub load_stichwoerter_table { #_{
  my %stichwoerter = @_;

  my $sth_stichwort = $dbh->prepare('insert into stichwort values(?,?)') or die;
  my $id_ = 1;
  for my $stichwort (keys %stichwoerter) {
    $stichwoerter{$stichwort}{id}=$id_;

    $sth_stichwort->execute($id_, $stichwort);

    $id_++;
  }

} #_}

sub init_stichwoerter { #_{


  #  Holz / Spielwaren ---> automatisch: Holzspielwaren
  #  Blech / Bearbeitung ---> Blechbearbeitung
  #  Freizeit / Artikel ---> Freizeitarikel
  #  Telefon  / Anlagen  ---> Telefonanlagen
  #  ... / Liebhaber ----> ...liebhaber
  #  Gesundheit ... produkte --> Gesundheitsprodukte
  #  Lebensmittel ... laden
  #  Antennen ... bau
  #  Körper ... Pflege ... mittel  
  #
  #  Vital-, Wild-, Roh-, Reformhaus-, glutenfreie und vegane Kost
  #
  #
  #  dienst == service
  #
  #  adj. digitaler Publikationen
  #


  %stichwoerter =  ( #_{

   'Abdichten'                  => {qrs => [ qr/\babdicht/               ] },
   'Abwasser'                   => {qrs => [ qr/abwasser/                ] },
   'Accessoires'                => {qrs => [ qr/\baccessoir/             ] },
   'Aluminium'                  => {qrs => [ qr/aluminium/               ] },
   'Alternativ'                 => {qrs => [ qr/alternativ/              ] },
   'Anhänger'                   => {qrs => [ qr/anhanger/                ] },
   'Anlässe'                    => {qrs => [ qr/\banlasse?\b/            ] },
   'Antennenbau'                => {qrs => [ qr/antennenbau/             ] },
   'Apotheke'                   => {qrs => [ qr/apothek/                 ] },
   'Archäologie'                => {qrs => [ qr/archaolog/               ] },
   'Architekt'                  => {qrs => [ qr/architekt/               ] },
   'Artist'                     => {qrs => [ qr/clown/, qr/pantomim/, qr/komik/, qr/animation/            ] },  # Firmen/f844659
   'Atelier'                    => {qrs => [ qr/atelier/                 ] },
   'Autohandel'                 => {qrs => [ qr/autohandel/              ] },
   'Automobil'                  => {qrs => [ qr/automobil/               ] },
   'Baby'                       => {qrs => [ qr/\bbab(y|i)/, qr/saugling/  ] },
   'Bäckerei'                   => {qrs => [ qr/backerei/                ] },
   'Backwaren'                  => {qrs => [ qr/backwaren/               ] },
   'Balkon'                     => {qrs => [ qr/balkon/                  ] },
   'Bank'                       => {qrs => [ qr/\bbank/                  ] }, # Datenbank, Bankette
   'Batterien'                  => {qrs => [ qr/batteri/                 ] },
   'Baugewerbe'                 => {qrs => [ qr/baugewerbe/              ] },
   'Baumaterialien'             => {qrs => [ qr/baumaterial/             ] },
   'Bautenschutz'               => {qrs => [ qr/bautenschutz/            ] },
   'Bauunternehmung'            => {qrs => [ qr/bauunternehm/            ] },
   'Beauty'                     => {qrs => [ qr/beauty/                  ] },
   'Bedachungen'                => {qrs => [ qr/bedachung/               ] },
   'Bekleidung'                 => {qrs => [ qr/bekleidung/              ] },
   'Bestattungen'               => {qrs => [ qr/bestattung/              ] },
   'Begrünung'                  => {qrs => [ qr/begrunung/               ] },
   'Betrug'                     => {qrs => [ qr/betrug/                  ] }, # !!!
   'Bier'                       => {qrs => [ qr/\bbier/                  ] },
   'Bildhauer'                  => {qrs => [ qr/bildhauer/               ] },
   'Bildung'                    => {qrs => [ qr/bildung/                 ] },
   'biologisch'                 => {qrs => [ qr/\bbio(logisch)?/         ] },
   'Blech'                      => {qrs => [ qr/blech/                   ] },
   'Blechbearbeitung'           => {qrs => [ qr/blechbearbeitung/        ] },
   'Blumen'                     => {qrs => [ qr/\bblume/                 ] },
   'Brandschutz'                => {qrs => [ qr/brandschutz/             ] },
   'Brockenhaus'                => {qrs => [ qr/brockenhaus/             ] },
   'Brot'                       => {qrs => [ qr/\bbrot/                  ] },
   'Bücher'                     => {qrs => [ qr/\bbuch(er)?n?\b/         ] },
   'Buchhaltung'                => {qrs => [ qr/buchhaltung/             ] },
   'Bügelservice'               => {qrs => [ qr/bugel(n|service)/        ] },
   'Bürsten'                    => {qrs => [ qr/\bburste/                ] },
   'Catering'                   => {qrs => [ qr/catering/                ] },
   'Chrom'                      => {qrs => [ qr/chrom/                   ] },
   'Cafe'                       => {qrs => [ qr/\bcafe\b/                ] },
   'Coiffeur'                   => {qrs => [ qr/coiffeur/                ] },
   'Container'                  => {qrs => [ qr/container/               ] },
   'Crêpes'                     => {qrs => [ qr/crepes/                  ] },
   'Dach'                       => {qrs => [ qr/\b(be)?dach/             ] },
   'Dachisolationen'            => {qrs => [ qr/dachisolation/           ] },
   'Dämmschutz'                 => {qrs => [ qr/dammschutz/              ] },
   'Datacenter'                 => {qrs => [ qr/data-?center/            ] },
   'Datenbank'                  => {qrs => [ qr/datenbank/               ] },
   'Datenverarbeitung'          => {qrs => [ qr/datenverarbeitung/       ] },
   'Dekoration'                 => {qrs => [ qr/dekoration/              ] },
   'Detektei'                   => {qrs => [ qr/detekt/                  ] },  # Ermittlungen
   'Deutschland'                => {qrs => [ qr/\bdeutsch\b/             ] },
   'Digitaldruck'               => {qrs => [ qr/digitaldruck/            ] },
   'Dorfzeitung'                => {qrs => [ qr/dorfzeitung/             ] },
   'Drehbücher'                 => {qrs => [ qr/drehbuch/, qr/storrytelling/ ] }, # Warum ist Joe/Volltext nicht erfasst
   'Druck'                      => {qrs => [ qr/(be)?druck/, qr/litho/, qr/\bsatz\b/, qr/print/   ] },
   'Drogerie'                   => {qrs => [ qr/drogeri/                 ] },
   'Düngemittel'                => {qrs => [ qr/dungemittel/] },
   'Edelmetall'                 => {qrs => [ qr/edelmetall/              ] },
   'Edelstahl'                  => {qrs => [ qr/edelstahl/               ] },
   'EDV'                        => {qrs => [ qr/\bedv\b/                 ] },
   'Eherecht'                   => {qrs => [ qr/ehe-?.*recht/            ] },
   'Einbruchschutz'             => {qrs => [ qr/einbruchschutz/          ] },
   'Eisenerz'                   => {qrs => [ qr/eisenerz/                ] },
   'Elektro'                    => {qrs => [ qr/elektro/                 ] },
   'Elektrosmog'                => {qrs => [ qr/elektrosmog/             ] },
   'Energie'                    => {qrs => [ qr/energie/                 ] },
   'Energiegewinnung'           => {qrs => [ qr/energiegewinnung/        ] },
   'Erdarbeiten'                => {qrs => [ qr/erdarbeiten/             ] },
   'Ersatzteile'                => {qrs => [ qr/ersatzteile/             ] },
   'Export'                     => {qrs => [ qr/export/                  ] },
   'Fahrrad'                    => {qrs => [ qr/(fahr|zwei)rad/, qr/\bvelos?/ ] }, 
   'Fahrschule'                 => {qrs => [ qr/fahrschule/              ] }, 
   'Fahrzeuge'                  => {qrs => [ qr/fahrzeug/                ] }, 
   'Fassadensysteme'            => {qrs => [ qr/fassadensystem/          ] }, 
   'Fenster'                    => {qrs => [ qr/fenster/                 ] }, 
   'Fitness'                    => {qrs => [ qr/fitness/                 ] },
   'Floristik'                  => {qrs => [ qr/floristik/               ] },
   'Food recycling'             => {qrs => [ qr/food recycling/          ] },  # f84593
   'Förderung'                  => {qrs => [ qr/forderung/               ] }, 
   'Forschung'                  => {qrs => [ qr/forschung/               ] }, 
   'Frankreich'                 => {qrs => [ qr/\bfrankreich/, qr/\bfranzosisch/]},
   'Freizeit'                   => {qrs => [ qr/freizeit/                ] },
   'Freizeitartikel'            => {qrs => [ qr/freizeitartikel/         ] },
   'Frischwasser'               => {qrs => [ qr/frischwasser/            ] },
   'Fugenabdichtung'            => {qrs => [ qr/fugenabdichtung/         ] },
   'Früchte'                    => {qrs => [ qr/frucht/                  ] },
   'Galvanik'                   => {qrs => [ qr/galvani/                 ] },  # sa Verchromen, Vernickeln, Verzinken, Verkupfern, insbesondere Versilbern und Vergolden // 
   'Gastronomie'                => {qrs => [ qr/gastronomie/             ] },
   'Garage'                     => {qrs => [ qr/garage/                  ] },
   'Garagentore'                => {qrs => [ qr/garagentore/             ] },
   'Garten'                     => {qrs => [ qr/garten/                  ] },  # sa Verchromen, Vernickeln, Verzinken, Verkupfern, insbesondere Versilbern und Vergolden // 
   'Gärtnerei'                  => {qrs => [ qr/gartnerei/               ] },
   'Gebäck'                     => {qrs => [ qr/geback/                  ] },
   'Gebäudereinigungen'         => {qrs => [ qr/gebaudereinigungen/      ] },
   'Geburtshilfe'               => {qrs => [ qr/geburtshilfe/            ] },
   'Gemüse'                     => {qrs => [ qr/gemuse/                  ] },
   'Genussmittel'               => {qrs => [ qr/genussmittel/            ] },
   'Getränke'                   => {qrs => [ qr/getranke/                ] },
   'Gips'                       => {qrs => [ qr/\bgips\b/                ] },
   'Gipser'                     => {qrs => [ qr/\bgipser/                ] },
   'Glasfaser'                  => {qrs => [ qr/glasfaser/               ] },
   'glutenfrei'                 => {qrs => [ qr/glutenfrei/              ] },
   'Geländer'                   => {qrs => [ qr/gelander/                ] }, 
   'Geld'                       => {qrs => [ qr/geld/                    ] }, 
   'Gesundheit'                 => {qrs => [ qr/gesundheit/              ] }, 
   'Gold'                       => {qrs => [ qr/gold/                    ] }, # s.a. Edelmetall
   'Grabbepflanzung'            => {qrs => [ qr/grabbepflanzung/         ] },
   'Grafik'                     => {qrs => [ qr/gra(f|ph)i[ck]/          ] },
   'Grafit'                     => {qrs => [ qr/gra(f|ph)it/             ] },
   'Gynäkologie'                => {qrs => [ qr/gynakologie/, qr/frauenarzt/ ]},
   'Handel'                     => {qrs => [ qr/handel/                  ] }, # how, not what!
   'Handelsrecht'               => {qrs => [ qr/handels-?.*recht/        ] },
   'Hardware'                   => {qrs => [ qr/\bhard-?.*ware\b/        ] },
   'Haushalt'                   => {qrs => [ qr/haushalt/                ] },
   'Haushaltsbedarf'            => {qrs => [ qr/haushaltsbedarf/         ] },
   'Hauslieferdienst'           => {qrs => [ qr/hausliefer(dienst|service)/ ] },
   'Haustiere'                  => {qrs => [ qr/haustier/                ] },
   'Haustierbetreuung'          => {qrs => [ qr/haustierbetreuung/       ] },
   'Hauswartung'                => {qrs => [ qr/hauswart/                ] },
   'Heizöl'                     => {qrs => [ qr/heizol/                  ] },
   'Heizung'                    => {qrs => [ qr/heizung/, qr/chauffage/  ] },
   'Helium'                     => {qrs => [ qr/helium/                  ] },
   'Herstellung'                => {qrs => [ qr/herstellung/, qr/fabrikation/, qr/fertigung/ ]},  # Produktion, produziert...
   'Hochbau'                    => {qrs => [ qr/\bhoch-?.*baus\b/        ] },
   'Hochtemperatur'             => {qrs => [ qr/hochtemperatur/          ] },
   'Holz'                       => {qrs => [ qr/\bholz/                  ] },
   'Hotel'                      => {qrs => [ qr/hotel/                   ] },
   'Hund'                       => {qrs => [ qr/\bhund/                  ] },
   'Hundetraining'              => {qrs => [ qr/hundetraining/           ] },
   'Human Ressource'            => {qrs => [ qr/human ressource/         ] },
   'Hütte'                      => {qrs => [ qr/hutten?\b/, qr/\bhutte/  ] },
   'Immobilien'                 => {qrs => [ qr/immobilien/              ] },
   'Immobilienverwaltung'       => {qrs => [ qr/immobilien-?verwaltung/  ] },
   'Import'                     => {qrs => [ qr/import/                  ] },
   'Industrie'                  => {qrs => [ qr/industrie/               ] },
   'Industrieöfen'              => {qrs => [ qr/industrieofen/           ] },
   'Informatik'                 => {qrs => [ qr/informatik/              ] },
   'Innenarchitektur'           => {qrs => [ qr/innenarchitektur/        ] },
   'Internet'                   => {qrs => [ qr/internet/                ] },
   'Italien'                    => {qrs => [ qr/\bitalien/               ] },
   'IT-Dienstleistung'          => {qrs => [ qr/it-.*dienstleistung/     ] },
   'Jagd'                       => {qrs => [ qr/jagd/                    ] },
   'Jugend'                     => {qrs => [ qr/jugend/                  ] },
   'Journalismus'               => {qrs => [ qr/journalismus/            ] },
   'Kamin'                      => {qrs => [ qr/\bkamin/                 ] },
   'Käminfeger'                 => {qrs => [ qr/\bkaminfeger/            ] },
   'Kanalbau'                   => {qrs => [ qr/kanalbau/                ] },
   'Kanalreinigung'             => {qrs => [ qr/kanal-?.*reinigung/      ] },
   'Kälte'                      => {qrs => [ qr/\bkalte/                 ] },
   'Kartonagen'                 => {qrs => [ qr/kartonage/               ] },
   'Käse'                       => {qrs => [ qr/kase/                    ] },
   'Käserei'                    => {qrs => [ qr/kaserei/                 ] },
   'Keramik'                    => {qrs => [ qr/\bkerami/                ] },
   'Kinderkrippe'               => {qrs => [ qr/kinderkrippe/, qr/kinderhort/         ] },
   'Kleintier'                  => {qrs => [ qr/kleintier/               ] }, #     Kleintierpraxis...
   'Klimatechnik'               => {qrs => [ qr/klimatechnik/            ] },
   'Konditorei'                 => {qrs => [ qr/konditorei/              ] },
   'Kohle'                      => {qrs => [ qr/kohle/                   ] },
   'Kohlenstoff'                => {qrs => [ qr/kohlenstoff/             ] },
   'Konserven'                  => {qrs => [ qr/\bkonserve/              ] },
   'Kokillen'                   => {qrs => [ qr/kokille/                 ] }, #   ????
   'Kohlenwasserstoff'          => {qrs => [ qr/kohlenwasserstoff/       ] }, # --> id_firma = 1227880;
   'Kommunikationstechnik'      => {qrs => [ qr/kommunikationstechnik/   ] },
   'Korrosion'                  => {qrs => [ qr/korrosion/               ] },
   'Kosmetik'                   => {qrs => [ qr/\b(c|k)osmeti/           ] },
   'Kücheneinrichtung'          => {qrs => [ qr/kucheneinrichtung/       ] }, #  Küchen vs Kuchen!
   'Kräftwerk'                  => {qrs => [ qr/\bkraftwerk/             ] },
   'Kräuter'                    => {qrs => [ qr/kraut/                   ] },
   'Kredit'                     => {qrs => [ qr/kredit/                  ] },
   'Kunst'                      => {qrs => [ qr/\bkunst(ler)?\b/, qr/artist/         ] },
   'Kunststoff'                 => {qrs => [ qr/kunststoff/              ] },
   'Kurierdienst'               => {qrs => [ qr/kurierdienst/                        ] },
   'Kultur'                     => {qrs => [ qr/kultur/                  ] },
   'Kupfer'                     => {qrs => [ qr/kupfer/                  ] },
   'Lack'                       => {qrs => [ qr/\black/                  ] },
   'Lagerung'                   => {qrs => [ qr/\blagerung/              ] },
   'laktosefrei'                => {qrs => [ qr/la[ck]tosen?frei/        ] },
   'Laminat'                    => {qrs => [ qr/laminat/                 ] },
   'Laufservice'                => {qrs => [ qr/laufservice/             ] },
   'Lebensmittel'               => {qrs => [ qr/lebensmittel/            ] },
   'Lebensmittelladen'          => {qrs => [ qr/lebensmittelladen/       ] },
   'Landwirtschaft'             => {qrs => [ qr/landwirt/                ] },
   'Laser'                      => {qrs => [ qr/laser/                   ] },
   'Licht'                      => {qrs => [ qr/licht/, qr/leucht/       ] },
   'Liebhaber'                  => {qrs => [ qr/liebhaber/               ] },
   'Liegenschaften'             => {qrs => [ qr/liegenschaften/, qr/neubau/, qr/immobil/     ] },
   'Liegenschaftenunterhalt'    => {qrs => [ qr/liegenschaftenunterhalt/                     ] },
   'Logistik'                   => {qrs => [ qr/logistik/                                    ] },
   'Lüftung'                    => {qrs => [ qr/luftung/                 ] },
   'Maler'                      => {qrs => [ qr/maler/                   ] },  # Exclude Familiennam
   'Maurer'                     => {qrs => [ qr/kundenmaurer/            ] },  # Exclude Familiennam
   'Magnesium'                  => {qrs => [ qr/magnesium/               ] },
   'Maler'                      => {qrs => [ qr/\bmaler/                 ] },
   'Medizin'                    => {qrs => [ qr/medizin/                 ] },
   'Messinstrumente'            => {qrs => [ qr/mess-?instrument/        ] },
   'Messtechnik'                => {qrs => [ qr/messtechnik/             ] },
   'Metall'                     => {qrs => [ qr/metall/                  ] },
   'Metzgerei'                  => {qrs => [ qr/metzgerei/               ] },
   'Messing'                    => {qrs => [ qr/messing/                 ] },
   'Milch'                      => {qrs => [ qr/milch/                   ] },
   'Mineralien'                 => {qrs => [ qr/minerali?en/             ] },
   'Mineralöl'                  => {qrs => [ qr/mineralol/               ] },
   'Möbel'                      => {qrs => [ qr/mobel/                   ] },
   'Mode'                       => {qrs => [ qr/\bmode/                  ] },  # Exclude Modell ! (f271150)
   'Montage'                    => {qrs => [ qr/montage/, qr/monteur/    ] }, 
   'Motorrad'                   => {qrs => [ qr/motorrad/                ] }, 
   'Multimedia'                 => {qrs => [ qr/musik/, qr/film/, qr/foto/, qr/kamera/, qr/video/, qr/fernseh/         ] },  # Spielfilm, Fernsehfilm, Dokumentarfilm, Serien, Dokusoaps â€¦ f534794
   'Nähmaschine'                => {qrs => [ qr/nähmaschinen/            ] },
   'Nahrungsmittel'             => {qrs => [ qr/nahrungsmittel/          ] },
   'Naturprodukte'              => {qrs => [ qr/naturprodukt/            ] },
   'Naturstein'                 => {qrs => [ qr/naturstein/              ] },
   'Neuronale Netzwerke'        => {qrs => [ qr/neuronal\w* netz/        ] },
   'Nickel'                     => {qrs => [ qr/nickel/                  ] },
   'Oberflächenbehandlung'      => {qrs => [ qr/oberflachenbehandlung/   ] },
   'Ofenbau'                    => {qrs => [ qr/ofenbau/                 ] },
   'Öl'                         => {qrs => [ qr/\boe?l(en)?\b/           ] },
   'Olivenöl'                   => {qrs => [ qr/olivenol/                ] },
   'Online-Shop'                => {qrs => [ qr/online.shop/             ] },
   'Optik'                      => {qrs => [ qr/optik/                   ] },
   'Palladium'                  => {qrs => [ qr/palladium/               ] },
   'Papeterie'                  => {qrs => [ qr/papeterie/               ] },
   'Parkett'                    => {qrs => [ qr/parkett/                 ] },
   'Parfümerie'                 => {qrs => [ qr/parfumerie/              ] },
   'Partnervermittlung'         => {qrs => [ qr/partnervermittlung/      ] },  # Vermittlung
   'Partyservice'               => {qrs => [ qr/party-?service/          ] },
   'Persönlichkeitsentwicklung' => {qrs => [ qr/personlichkeitsentwicklung/] },
   'Pharma'                     => {qrs => [ qr/\bpharma/                ] },
   'Pizzeria'                   => {qrs => [ qr/pizzeria/                ] },
   'Pizzakurier'                => {qrs => [ qr/pizza.?kurrier/          ] },
   'Pferd'                      => {qrs => [ qr/pferd/                   ] },
   'Pflege'                     => {qrs => [ qr/pflege/                  ] },
   'Plattenleger'               => {qrs => [ qr/plattenleger/            ] },
   'Polieren'                   => {qrs => [ qr/polieren/                ] },
   'Prävention'                 => {qrs => [ qr/pravention/, qr/\bvorbeug/ ] },
   'Präxis'                     => {qrs => [ qr/praxis/                  ] },
   'Programmierung'             => {qrs => [ qr/programmier/             ] },  # TODO Entfernen neurolinguistisch (f401976)
   'Projektmanagement'          => {qrs => [ qr/projektmanagement/       ] },
   'Public relation'            => {qrs => [ qr/public relation/         ] },
   'Radio'                      => {qrs => [ qr/radio/                   ] },
   'Raiffeisen'                 => {qrs => [ qr/raiffeisen/              ] },
   'Raumgestaltung'             => {qrs => [ qr/raumgestaltung/          ] },
   'Recycling'                  => {qrs => [ qr/recycling/, qr/abfall/, qr/entsorg/   ] },  # Sonderabfall
   'Reform'                     => {qrs => [ qr/reform/                  ] },
   'Rekrutierung'               => {qrs => [ qr/rekrutierung/, qr/recruiting/, qr/arbeitsvermittlung/ ]},
   'Reinigung'                  => {qrs => [ qr/reinigung/               ] },
   'Reiten'                     => {qrs => [ qr/\breite(r|n)/            ] },
   'Reisen'                     => {qrs => [ qr/\breisen\b/              ] },
   'Reiseagentur'               => {qrs => [ qr/reiseagentur/, qr/reiseburo/, qr/agences? de voyage/, qr/agenzi\w* di viaggio/ ] },
   'Renovation'                 => {qrs => [ qr/renovation/              ] },
   'Refigerator'                => {qrs => [ qr/refigerator/             ] },
   'Reparatur'                  => {qrs => [ qr/reparatur/               ] },
   'Reparaturwerkstätte'        => {qrs => [ qr/reparaturwerkstatte/     ] },
   'Ressourcen'                 => {qrs => [ qr/ress?ource/              ] },  # ohne «Human Ressource» !
   'Restaurant'                 => {qrs => [ qr/restaurant/, qr/beiz\b/, qr/kaffee?haus/, qr/\bcafe\b/  ] },
   'Regie'                      => {qrs => [ qr/regie\b/                 ] },
   'Roboter'                    => {qrs => [ qr/roboter/                 ] },
   'Rohrreinigungen'            => {qrs => [ qr/rohr-?reinigung/         ] },
   'Rohstoff'                   => {qrs => [ qr/rohstoff/                ] },
   'Rückbau'                    => {qrs => [ qr/ruckbau/                 ] },
   'SAC'                        => {qrs => [ qr/\bsac\b/                 ] }, # f1033730
   'Sachenrecht'                => {qrs => [ qr/sachen-?.*recht/         ] },
   'Sandstrahlen'               => {qrs => [ qr/sandstrahl/              ] },
   'Sanierung'                  => {qrs => [ qr/sanierung/               ] },
   'Sanitär'                    => {qrs => [ qr/sanitai?r/               ] },
   'Sauce'                      => {qrs => [ qr/\bsauce/                 ] },
   'Schachtentleerung'          => {qrs => [ qr/schachtentleerung/       ] },
   'Schall'                     => {qrs => [ qr/schall/                  ] },
   'Schaufenster'               => {qrs => [ qr/schaufenster/            ] },
   'Schleifen'                  => {qrs => [ qr/schleif/                 ] },
   'Schlosserei'                => {qrs => [ qr/schlosserei/             ] }, # ö vs o!
   'Schmuck'                    => {qrs => [ qr/schmuck/                 ] },
   'Schrauben'                  => {qrs => [ qr/schrauben/               ] },
   'Schreinerei'                => {qrs => [ qr/schreiner/               ] },
   'Schulung'                   => {qrs => [ qr/schulung/                ] },
   'Schwimmbad'                 => {qrs => [ qr/schwimmbad/              ] },
   'seltene Erden'              => {qrs => [ qr/seltene\w* erde/         ] }, # f1019843 ???
   'Seniorenbetreuung'          => {qrs => [ qr/seniorenbetreuung/       ] },
   'Shakes'                     => {qrs => [ qr/\bshakes?\b/             ] },
   'Shop'                       => {qrs => [ qr/\bshops?\b/              ] },
   'Schuhe'                     => {qrs => [ qr/\bschuheb/               ] },
   'Sicherheit'                 => {qrs => [ qr/sicherheit/              ] },
   'Sicherheitsdienstleistungen'=> {qrs => [ qr/sicherheitsdienstleistungen/ ] },
   'Siebdruck'                  => {qrs => [ qr/siebdruck/               ] },
   'Signaletik'                 => {qrs => [ qr/signaletik/              ] },
   'Silber'                     => {qrs => [ qr/silber/                  ] }, # s.a Edelmetall
   'Software'                   => {qrs => [ qr/software/                ] },
   'Sondermetall'               => {qrs => [ qr/sondermetall/            ] },
   'Spengler'                   => {qrs => [ qr/spengler/                ] },
   'Spielwaren'                 => {qrs => [ qr/spiel(ware|zeug)/        ] },
   'Spritzarbeiten'             => {qrs => [ qr/spritzarbeiten/          ] },
   'Sport'                      => {qrs => [ qr/\bsport/                 ] }, # Transport , Skisport
   'Sportartikel'               => {qrs => [ qr/\bsport-?.*artikel/      ] },
   'Sportbekleidung'            => {qrs => [ qr/\bsportbekleidung/       ] },
   'Stahl'                      => {qrs => [ qr/stahl/                   ] },
   'Stellenvermittlung'         => {qrs => [ qr/stellenvermittlung/      ] }, # s.a. recruiting
   'Steuerberatung'             => {qrs => [ qr/steuerberatung/          ] }, 
   'Steuerrecht'                => {qrs => [ qr/steuerrecht/             ] }, 
   'Steuerung'                  => {qrs => [ qr/steuerung/               ] }, 
   'Strom'                      => {qrs => [ qr/\bstrom/                 ] }, 
   'Take-Away'                  => {qrs => [ qr/take.?away/              ] }, # 
   'Tankstelle'                 => {qrs => [ qr/tankstelle/              ] }, # 
   'Tauchen'                    => {qrs => [ qr/tauchausrustung/, qr/tauchen/, qr/\btauch/ ] }, # 
   'Tanzen'                     => {qrs => [ qr/\btanz/                  ] },
   'Teigwaren'                  => {qrs => [ qr/teigwaren/               ] }, # 
   'Telefon'                    => {qrs => [ qr/telefon/                 ] },
   'Telefonanlagen'             => {qrs => [ qr/telefonanlagen/          ] },
   'Tennis'                     => {qrs => [ qr/tennis/                  ] },
   'Teppich'                    => {qrs => [ qr/teppich/                 ] }, # 
   'Terrasse'                   => {qrs => [ qr/terrasse/                ] },
   'Texte'                      => {qrs => [ qr/\btexte?n?\b/            ] },
   'Textilien'                  => {qrs => [ qr/textilien/               ] },
   'Tiefbau'                    => {qrs => [ qr/\btief-?.*baus?\b/       ] },
   'Tierarzt'                   => {qrs => [ qr/tierarzt/, qr/veterinar/ ] }, #     TODO Testcase für VerinÃ¤r
   'Tore'                       => {qrs => [ qr/\btore?n?/               ] },
   'Tormonteur'                 => {qrs => [ qr/tormonteur/              ] },
   'Transport'                  => {qrs => [ qr/transport/               ] },
   'Treuhand'                   => {qrs => [ qr/treuhand/                ] },
   'Turbine'                    => {qrs => [ qr/turbine/                 ] },
   'Türen'                      => {qrs => [ qr/\bture?n?\b/             ] },
   'Übersetzungen'              => {qrs => [ qr/\bubersetzung/, qr/dolmetsch/ ]},
   'Übernachtungsmöglichkeit'   => {qrs => [ qr/ubernachtung/            ] },
   'Uhren'                      => {qrs => [ qr/\buhr(en)?\b/            ] },
   'Ungarn'                     => {qrs => [ qr/ungarn/                  ] },
   'Unternehmungsberatung'      => {qrs => [ qr/unternehumungsberatung/  ] },
   'Unterhalt'                  => {qrs => [ qr/unterhalt\b/             ] },
   'Unterhaltung'               => {qrs => [ qr/unterhaltung/            ] },
   'Unterhaltungselektronik'    => {qrs => [ qr/unterhaltungselektronik/ ] },
   'Unterhaltsarbeiten'         => {qrs => [ qr/unterhaltsarbeiten/      ] },
   'Umbau'                      => {qrs => [ qr/\bumbau/                 ] },
   'Umwelt'                     => {qrs => [ qr/umwelt/                  ] },
   'Umweltschutz'               => {qrs => [ qr/umweltschutz/            ] },
   'Umwelttechnik'              => {qrs => [ qr/umwelttechnik/           ] },
   'Umzug'                      => {qrs => [ qr/\bumzug/                 ] },
   'vegan'                      => {qrs => [ qr/vegan/                   ] },
   'Veranstaltung'              => {qrs => [ qr/veranstaltung/           ] },
   'Verflüssigung'              => {qrs => [ qr/\bverflussig/            ] },
   'Vermietung'                 => {qrs => [ qr/vermietung/              ] },
   'Verpflegung'                => {qrs => [ qr/verpflegung/             ] },
   'Versicherung'               => {qrs => [ qr/versicherung/            ] },
   'Versicherungsberatung'      => {qrs => [ qr/versicherungsberatung/   ] },
   'Vintage'                    => {qrs => [ qr/vintage/                 ] },
   'Visualisierung'             => {qrs => [ qr/visualisierung/          ] },
   'Waffen'                     => {qrs => [ qr/waff/                    ] },
   'Wärme'                      => {qrs => [ qr/\bwarme/                 ] },
   'Wäscherei'                  => {qrs => [ qr/wascherei/               ] },
   'Wasser'                     => {qrs => [ qr/wasser/                  ] },
   'Wasseraufbereitung'         => {qrs => [ qr/wasseraufbereitung/      ] },
   'Wasserstoff'                => {qrs => [ qr/wasserstoff/             ] },
   'Wasserversorgung'           => {qrs => [ qr/wasserversorgung/        ] },
   'Werbung'                    => {qrs => [ qr/\bwer(b|e)/              ] },
   'Wertschriften'              => {qrs => [ qr/wertschriften/           ] },
   'Wein'                       => {qrs => [ qr/\bwein/                  ] },
   'Weiterbildung'              => {qrs => [ qr/weiterbildung/           ] },
   'Wellness'                   => {qrs => [ qr/wellness/                ] },
   'Wintergarten'               => {qrs => [ qr/wintergarten/            ] },
   'Würste'                     => {qrs => [ qr/\bwurst/                 ] },
   'Zahlungsverkehr'            => {qrs => [ qr/zahlungsverkehr/         ] }, #
   'Zahnarzt'                   => {qrs => [ qr/zahnarzt/                ] }, #
   'Ziegellei'                  => {qrs => [ qr/ziegelei/                ] }, 
   'Zink'                       => {qrs => [ qr/zink/                    ] }, # --> Verzinkerei
   'Zinn'                       => {qrs => [ qr/zinn/                    ] }, #
   'Zöliakie'                   => {qrs => [ qr/zoliakie/                ] }, #
   'Zubehör'                    => {qrs => [ qr/zubehor/                 ] }, #


  ); #_}

} #_}

sub trunc_table_firma_bez { #_{
  $dbh -> do('drop table if exists firma_bez') or die;

  $dbh -> do("
create table firma_bez (
  id_firma       int       not null,
  seq            int       not null,
  typ            int       not null, -- 1=Bevorzugte Bezeichnung? 2=Alternative Bezeichnung ?
  sprachcode     int       not null,
  status         int       not null,
  bezeichnung    text      not null,
  dt_ab          text      not null,
  dt_bis         text      not null
--foreign key (id_firma) references firma
)
") or die;

} #_}

sub trunc_table_firma { #_{

  $dbh -> do('drop table if exists firma_stage') or die;
  $dbh -> do('drop table if exists firma'      ) or die;

  $dbh -> do("
create table firma_stage (
  id             int,
  code13         varchar,
  id_hauptsitz   int,
  id_gemeinde    int,
  kapital        number,
  currency       varchar,
  status         int,
  loesch_dat     text,
  shab_seq       int,
  care_of        text,
  strasse        text,
  hausnummer     text,
  address_zusatz text,
  postfach       text,
  plz            text,
  ort            text,
  rechtsform     int
)
") or die;

  $dbh -> do("
create table firma (
  id             int,
  bezeichnung    varchar    not null,
  code13         varchar    not null,
  id_hauptsitz   int,
  id_gemeinde    int        not null,
  kapital        number,
  currency       varchar,
  status         int        not null,  -- Firmen/f621
  loesch_dat     text,
  shab_seq       int,
  care_of        text,
  strasse        text,
  hausnummer     text,
  address_zusatz text,
  postfach       text,
  plz            text,
  ort            text       not null,
  rechtsform     int        not null,
  -----
  primary key (id)
--foreign key (id_gemeinde) references gemeinden
)
") or die;

} #_}

sub trunc_table_zweck { #_{
  $dbh -> do('drop table if exists zweck');
  $dbh -> do("
    
create table zweck (
  id_firma          int   not null,
  zweck             text,
  constraint zweck_pk primary key (id_firma)
)
") or die;

} #_}

sub trunc_table_gemeinde { #_{
  $dbh -> do('drop table if exists gemeinde') or die;
  $dbh -> do("
create table gemeinde (
  id             int ,
  name           text       not null
)
") or die;
} #_}

sub trunc_table_stichwort { #_{
  $dbh -> do('drop table if exists stichwort') or die;
  $dbh -> do("

create table stichwort (
  id             integer  primary key,
  stichwort      text     not null
)
") or die;

  $dbh -> do ('create unique index stichwort_ix_stichwort on stichwort(stichwort)');

} #_}

sub trunc_table_stichwort_firma { #_{
  $dbh -> do('drop table if exists stichwort_firma') or die;
  $dbh -> do("

create table stichwort_firma (
  id_firma       int not null,
  id_stichwort   int not null
)
") or die;
} #_}

sub trunc_table_person_firma_stg { #_{
  $dbh -> do('drop table if exists person_firma_stg') or die;
  $dbh -> do("

create table person_firma_stg (
  id_firma          int  not null,
  dt_journal        text not null,
  add_rm            text not null,
  titel             text,
  nachname          text,
  vorname           text,
  --
  von               text,
--von1              text,
--von2              text,
--von3              text,
--von4              text,
--von5              text,
--von6              text,
  --
  bezeichnung       text,
  in_               text,
  --
  funktion          text check (funktion != ''),
  zeichnung         text check (zeichnung != ''),
  stammeinlage      text check (stammeinlage != '')
)
") or die;
} #_}

# sub to_dt { #_{
#   my $str = shift;
# 
#   return '9999-12-31' unless $str; # 1082610, Trimos Ltd
#   
#   die "$str" unless $str =~ /^((\d\d\d\d)-(\d\d)-(\d\d)) 00:00:00$/;
# 
#   my $dt = $1;
# 
#   $dt = '9999-12-31' if $dt eq '2100-12-31';
# 
#   return $dt;
# } #_}

sub to_txt { #_{
# return $_[0];
  return encode('utf-8', decode('iso-8859-1', $_[0]));
} #_}
