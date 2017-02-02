#!/usr/bin/perl
use warnings;
use strict;

use DBI;
use Encode qw(decode encode);
my $zefix_root;

if ('test') {
  $zefix_root = "$ENV{github_root}Zefix/test/";
}
else {
  $zefix_root = "$ENV{digitales_backup}Zefix/";
}
die $zefix_root unless -d $zefix_root;

my $zefix_downloads = "${zefix_root}downloaded/";
die unless -d $zefix_downloads;

my $db = "${zefix_root}zefix.db";
# die unless -f $db;



my $dbh = DBI->connect("dbi:SQLite:dbname=$db") or die "Could not open/create $db";
$dbh->{AutoCommit} = 0;

my $cnt_gemeinden = $dbh->selectrow_array('select count(*) from gemeinde');

print "cnt gemeinde: $cnt_gemeinden\n";
my $load_gemeinden = ! $cnt_gemeinden;
$load_gemeinden = 1;


load_firmen();
load_firmen_bez();

$dbh -> commit;

sub load_firmen { #  {

  my %Gemeinde_NR_2_Name;

  my $cnt = 0;
  my $tsv_firmen     = "${zefix_downloads}firmen";

  die unless -f $tsv_firmen;

  trunc_table_firma();
  trunc_table_zweck();

  my $sth_gemeinde;
  if ($load_gemeinden) {
     trunc_table_gemeinde();
     $sth_gemeinde = $dbh -> prepare('insert into gemeinde values(?, ?)') or die;
  }
  my $sth_firma = $dbh -> prepare ('insert into firma values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)') or die;
  my $sth_zweck = $dbh -> prepare ('insert into zweck values (?,?)                            ') or die;


  open (my $f_firmen, '<', $tsv_firmen) or die;
  while (my $in = <$f_firmen>) { #  {
    $cnt ++;
    my @row = split("\t", $in);

    my $fi_firma         = $row[ 0]; #  {
    my $fi_Code13        = $row[ 1];
    my $fi_RechtsformID  = $row[ 2];
    my $fi_firma1        = $row[ 3];
    my $fi_GemeindeNR    = $row[ 4];
    my $fi_GemeindeName  = to_txt($row[5]);
    my $fi_RegisteramtID = $row[ 6];
    my $fi_Kapital       = $row[ 7];
    my $fi_CurrencyID    = $row[ 8];
    my $fi_statusID      = $row[ 9]; # 0: gelöscht, 2: aktiv, 3: in Auflösung (von Amtes wegen, Konkurs, Fusion)
    my $fi_Loeschdat     = $row[10]; # Wenn status = 0
#   my $fi_SHABDat       = $row[11]; # ignorieren, nur Zefix intern
#   my $fi_ShabNr        = $row[12]; # ignorieren, nur Zefix intern
#   my $fi_ShabSeite     = $row[13]; # ignorieren, nur Zefix intern
#   my $fi_MutTyp        = $row[14]; # ignorieren, nur Zefix intern
#   my $fi_DatumMutation = $row[15]; # ignorieren, nur Zefix intern
    my $fi_ShabSequence  = $row[16];
    my $fi_Address       = $row[17]; # Always emtpy?
    my $fi_CareOf        = to_txt($row[18]);
    my $fi_Strasse       = to_txt($row[19]);
    my $fi_Hausnummer    = $row[20];
    my $fi_Addresszusatz = to_txt($row[21]);
    my $fi_Postfach      = $row[22];
    my $fi_PLZ           = $row[23];
    my $fi_Ort           = to_txt($row[24]);
    my $fi_Zweck         = to_txt($row[25]); #  }

    if ($load_gemeinden) { # {
      if (! $fi_GemeindeName) {
        print "fi_GemeindeName is empty\n";
      }
      else {
        if (exists $Gemeinde_NR_2_Name{$fi_GemeindeNR}) {
          if ($Gemeinde_NR_2_Name{$fi_GemeindeNR} ne $fi_GemeindeName) {
            printf "%5d %-30s %-30s\n", $fi_GemeindeNR, $Gemeinde_NR_2_Name{$fi_GemeindeNR}, $fi_GemeindeName;
          }
          else {
            print "TODO bekannte Gemeinde $fi_GemeindeName\n";
          }
        }
        else {
          $sth_gemeinde -> execute($fi_GemeindeNR, $fi_GemeindeName);
          $Gemeinde_NR_2_Name{$fi_GemeindeNR} = $fi_GemeindeName;
        }
      }
    } # }

    my $fi_name = '???';

    $fi_Loeschdat =~ s/ 00:00:00$//;

    $sth_firma -> execute($fi_firma,
      # $fi_name, 
        $fi_Code13, $fi_firma1, $fi_GemeindeNR, $fi_Kapital, $fi_CurrencyID, $fi_statusID, $fi_Loeschdat, $fi_ShabSequence, $fi_CareOf, $fi_Strasse, $fi_Hausnummer, $fi_Addresszusatz, $fi_Postfach, $fi_PLZ, $fi_Ort
      # , $fi_Zweck
      );
    $sth_zweck -> execute($fi_firma, $fi_Zweck);
  } #  }

} #  }

sub load_firmen_bez {
  my $tsv_firmen_bez = "${zefix_downloads}firmen_bezeichnung";
  die unless -f $tsv_firmen_bez;

  trunc_table_firma_bez();
  my $sth_firma_bez = $dbh -> prepare ('insert into firma_bez values (?,?,?,?,?,?,?,?)') or die;

  open (my $f_firmen_bez, '<', $tsv_firmen_bez) or die;
  while (my $in = <$f_firmen_bez>) {
    my @row = split("\t", $in);

    my $fi_id         = $row[0];
    my $seq           = $row[1];
    my $typ           = $row[2];
    my $sprachcode    = $row[3]; # DE, FR, IT, EN, XX
    my $status        = $row[4]; # -1: nicht mehr gültige Bezeichnung, 3: letztgültige Bezeichnung
    my $bezeichnung   = to_txt($row[5]);
    my $dt_ab         = to_dt($row[6]);
    my $dt_bis        = to_dt($row[7]);

    $sth_firma_bez -> execute($fi_id, $seq, $typ, $sprachcode, $status, $bezeichnung, $dt_ab, $dt_bis);
  
  }

}

sub trunc_table_firma_bez { # {
  $dbh -> do('drop table if exists firma_bez') or die;

  $dbh -> do("
create table firma_bez (
  id_firma       int       not null,
  seq            int       not null,
  typ                              , -- ???
  sprachcode     int       not null,
  status         int       not null,
  bezeichnung    text      not null,
  dt_ab          text      not null,
  dt_bis         text      not null
--foreign key (id_firma) references firma
)
") or die;

} # }

sub trunc_table_firma { #  {

  $dbh -> do('drop table if exists firma') or die;
  $dbh -> do("

create table firma (
  id             int,
--name           varchar    not null,
  code13         varchar    not null,
  firma1         int,
  gemeinde_id    int        not null,
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
--zweck          text,
  -----
  primary key (id)
--foreign key (gemeinde_id) references gemeinden
)
") or die;

} #  }

sub trunc_table_zweck { #
  $dbh -> do('drop table if exists zweck');
  $dbh -> do("
    
create table zweck (
  id_firma          int,
  zweck             text,
  constraint zweck_pk primary key (id_firma)
)
") or die;

} # }

sub trunc_table_gemeinde { # {
  $dbh -> do('drop table if exists gemeinde') or die;
  $dbh -> do("
create table gemeinde (
  id             int ,
  name           text       not null
)
") or die;
} # }

sub to_dt {
  my $str = shift;
  die unless $str =~ /^((\d\d\d\d)-(\d\d)-(\d\d)) 00:00:00$/;

  my $dt = $1;

  $dt = '9999-12-31' if $dt eq '2100-12-31';

  return $dt;
}

sub to_txt {
  return $_[0];
  return encode('utf-8', decode('iso-8859-1', $_[0]));
}
