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
    my $dt_ab         = to_dt ($row[6]);
    my $dt_bis        = to_dt ($row[7]);

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

    my $stichwort_already_inserted = {};

    fill_stichwort_firma($r->{id_firma}, $zweck                           , $sth_ins_stichwort_firma, $stichwort_already_inserted);
    fill_stichwort_firma($r->{id_firma}, lc decode_utf8($r->{bezeichnung}), $sth_ins_stichwort_firma, $stichwort_already_inserted);

    $cnt ++;
# # return if $cnt > 10000;
    print "$cnt\n" unless $cnt % 1000;
  } #_}

   my $end_t = time;
   printf("load_stichwoerter_table in %5.2f seconds\n", $end_t - $start_t);
   print "cnt = $cnt\n";

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

  %stichwoerter =  (
#    'Reiseagentur'             => {qrs => [ qr/reiseagentur/, qr/agences? de voyage/, qr/agenzi\w* di viaggio/ ] },
#    'Lebensmittel'             => {qrs => [ qr/lebensmittel/            ] },
#    'Pizzeria'                 => {qrs => [ qr/pizzeria/                ] },
#    'Drogerie'                 => {qrs => [ qr/drogeri/                 ] },
#    'Coiffeur'                 => {qrs => [ qr/coiffeur/                ] },
#    'Autohandel'               => {qrs => [ qr/autohandel/              ] },
#    'Recycling'                => {qrs => [ qr/recycling/, qr/abfall/, qr/entsorg/   ] },  # Sonderabfall
#    'Waffen'                   => {qrs => [ qr/waff/                    ] },
#    'Apotheke'                 => {qrs => [ qr/apothek/                 ] },
#    'Haustiere'                => {qrs => [ qr/haustier/                ] },
#    'Umweltschutz'             => {qrs => [ qr/umweltschutz/            ] },
#    'Früchte'                  => {qrs => [ qr/frucht/                  ] },
#    'glutenfrei'               => {qrs => [ qr/glutenfrei/              ] },
#    'laktosefrei'              => {qrs => [ qr/la[ck]tosen?frei/        ] },
#    'Kräuter'                  => {qrs => [ qr/kraut/                   ] },
#    'Bestattungen'             => {qrs => [ qr/bestattung/              ] },
#    'Übernachtungsmöglichkeit' => {qrs => [ qr/ubernachtung/            ] },
#    'Artist'                   => {qrs => [ qr/clown/, qr/pantomim/, qr/komik/, qr/animation/            ] },  # Firmen/f844659
#    'Hundetraining'            => {qrs => [ qr/hundetraining/           ] },
#    'Stahl'                    => {qrs => [ qr/stahl/                   ] },
#    'Kupfer'                   => {qrs => [ qr/kupfer/                  ] },
#    'Zink'                     => {qrs => [ qr/zink/                    ] }, # --> Verzinkerei
#    'Gold'                     => {qrs => [ qr/gold/                    ] },
#    'Silber'                   => {qrs => [ qr/silber/                  ] },
#    'Ressourcen'               => {qrs => [ qr/ress?ource/              ] },
#    'Eisenerz'                 => {qrs => [ qr/eisenerz/                ] },
#    'Kohle'                    => {qrs => [ qr/kohle/                   ] },
#    'seltene Erden'            => {qrs => [ qr/seltene\w* Erde/         ] },
#    'Kohlenwasserstoff'        => {qrs => [ qr/kohlenwasserstoff/       ] }, # --> id_firma = 1227880;
#    'Mineralien'               => {qrs => [ qr/minerali?en/             ] },
#    'Batterien'                => {qrs => [ qr/batteri/                 ] },
#    'Dachisolationen'          => {qrs => [ qr/dachisolation/           ] },
#    'Multimedia'               => {qrs => [ qr/musik/, qr/film/, qr/foto/, qr/kamera/         ] },  # Spielfilm, Fernsehfilm, Dokumentarfilm, Serien, Dokusoaps … f534794
#    'Mediizin'                 => {qrs => [ qr/medizin/                 ] },
#    'Bedachungen'              => {qrs => [ qr/bedachung/               ] },
#    'Versicherungsberatung'    => {qrs => [ qr/versicherungsberatung/   ] },
#    'Drehbücher'               => {qrs => [ qr/drehbuch/, qr/storrytelling/, qr/regie/ ] }, # Warum ist Joe/Volltext nicht erfasst
#    'Journalismus'             => {qrs => [ qr/journalismus/ ] },
#    'Public relation'          => {qrs => [ qr/public relation/ ] },
#    'Werbung'                  => {qrs => [ qr/werbung/ ] },
#    'Datenverarbeitung'        => {qrs => [ qr/datenverarbeitung/       ] },
#    'Radio'                    => {qrs => [ qr/radio/                   ] },
#    'Programmierung'           => {qrs => [ qr/programmierung/          ] },
#    'Betrug'                   => {qrs => [ qr/betrug/                  ] }, # !!!
#    'Kleintier'                => {qrs => [ qr/kleintier/               ] }, #     Kleintierpraxis...
#    'Tierarzt'                 => {qrs => [ qr/tierarzt/, qr[veterinär/ ] }, #     TODO Testcase für Verinär
#    'Detektei'                 => {qrs => [ qr/detekt/                  ] },
#    'Alternativ'               => {qrs => [ qr/alternativ/              ] },
#    'Keramik'                  => {qrs => [ qr/keramik/                 ] },
# #  'Food recycling'           => {qrs => [ qr/food recycling/          ] },  # f84593
#    'Naturstein'               => {qrs => [ qr/naturstein/              ] },
     'Spengler'                 => {qrs => [ qr/spengler.*/              ] },
  );

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
  id             int  primary key,
  stichwort      text not null
)
") or die;
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

sub to_dt { #_{
  my $str = shift;

  return '9999-12-31' unless $str; # 1082610, Trimos Ltd
  
  die "$str" unless $str =~ /^((\d\d\d\d)-(\d\d)-(\d\d)) 00:00:00$/;

  my $dt = $1;

  $dt = '9999-12-31' if $dt eq '2100-12-31';

  return $dt;
} #_}

sub to_txt { #_{
# return $_[0];
  return encode('utf-8', decode('iso-8859-1', $_[0]));
} #_}
