#!/usr/bin/perl
use warnings;
use strict;
use Encode qw(decode encode);

use DBI;
binmode(STDOUT, ":utf8");

my $dbh = DBI->connect("dbi:SQLite:dbname=../test/zefix.db") or die "Could not open/create zefix.db";

#   '    cmp_person_firma($sth,  $cnt++,  ' ,
my $sth = $dbh -> prepare ("
  select
            pf.id_firma             ,
            pf.dt_journal           ,
            pf.add_rm               ,
            p.nachname              ,
            p.vorname               ,
            p.von                   ,
            p.bezeichnung           ,
            pf.in_                  ,
            pf.funktion             ,
            pf.zeichnung            ,
            pf.einlage   
  from
    person_firma pf join
    person       p on pf.id_person = p.id
  where
    pf.id_firma in (279826, 467455, 959835) and
    pf.dt_journal > '2009-02-01'
  order by
    pf.dt_journal,
    id_firma,
    ifnull(nachname   , 'ZZ'),
    ifnull(vorname    , 'ZZ'),
    ifnull(bezeichnung, 'ZZ');
") or die;

$sth -> execute or die;

while (my $r = $sth->fetchrow_hashref) {

  printf '    cmp_person_firma($sth,  $cnt++, %7d, %-12s, %3s, %-19s, %-19s, %-38s, %-44s, %-28s, %-45s, %-55s, %-56s);
', num($r->{id_firma}   ),
   str($r->{dt_journal }),
   str($r->{add_rm     }),
   str($r->{nachname   }),
   str($r->{vorname    }),
   str($r->{von        }),
   str($r->{bezeichnung}),
   str($r->{in_        }),
   str($r->{funktion   }),
   str($r->{zeichnung  }),
   str($r->{einlage    });

}

sub num {
  my $num = shift;

  return 'null' unless defined $num;
  return $num;
}

sub str {
  my $str = shift;
  return ' null' unless defined $str;
  $str = decode('utf-8', $str);
  $str =~ s/'/\\'/g;
  return "'$str'";
}

