<?php

include (getenv('github_root') . 'Zefix/web/php/db.php');

$dbh = db_connect('test');


check_gemeinde ($dbh);
check_zweck    ($dbh);
check_firma_bez($dbh);
check_firma    ($dbh);
echo "Ok\n";

function check_firma($dbh) {

  check_count($dbh, 'firma', 7);

  $sth = db_prep_exec($dbh, 'select * from firma order by id', array());
  #                    id,         code13 ,    hpts,  gem, kapital,  cur, st,  del,   shab#,                                     ,                  ,        ,zus.,   pf,   plz ,  ort           
  cmp_firma($sth,  451407, 'CH02040197464',    null,  261,  100000, 'CHF', 2, null, 3242819, null                                ,'Glatttalstrasse' ,'104 h',null, null, '8052', 'Zürich'       , 3);
  cmp_firma($sth,  712087, 'CH40040245074',    null, 4021, 2000000, 'CHF', 2, null, 2185269, null                                ,'Täfernstrasse'   ,  '7'  ,null, null, '5405', 'Baden-Dättwil', 4);
  cmp_firma($sth,  728139, 'CH02010440290',    null,  155,    null, null , 2, null, 6180656, null                                ,'Bahnhofstrasse'  , '14'  ,null, null, '8708', 'Männedorf'    , 1);
  cmp_firma($sth,  823465, 'CH02030293815',    null,  261,  100000, 'CHF', 2, null, 1667155, null                                ,'Zypressenstrasse', '71'  ,null, null, '8004', 'Zürich'       , 3);
  cmp_firma($sth,  934296, 'CH02030334394',    null,  261,  100000, 'CHF', 2, null, 3232871,'c/o ADP Analyse Design Planung GmbH','Glatttalstrassse','104f' ,null, null, '8052', 'Zürich'       , 3);
  cmp_firma($sth, 1290391, 'CH13040238566',    null, 1301,   20000, 'CHF', 2, null, 3281571, null                                ,'Kornhausstrasse' , '86'  ,null, null, '8840', 'Einsiedeln'   , 4);
  cmp_firma($sth, 1292466, 'CH02090047847', 1290391,   56,    null, null , 2, null, 3315327, null                                ,'Dorfstrasse'     ,'115'  ,null, null, '8424', 'Embrach'      , 9);

  echo "firma ok\n";

}

function cmp_firma($sth, $id, $code13, $id_hauptsitz, $id_gemeinde, $kapital, $currency, $status, $loesch_dat, $shab_seq, $care_of, $strasse, $hausnummer, $address_zusatz, $postfach, $plz, $ort, $rechtsform) {

  $row = $sth -> fetch();

  if ($row[1] != $code13) {
    throw new Exception("cmp_firma $id: code13 $row[1] != $code13");
  }
  if ($row[2] != $id_hauptsitz) {
    throw new Exception("cmp_firma $id: hauptsitz $row[2] != $id_hauptsitz");
  }
  if ($row[3] != $id_gemeinde) {
    throw new Exception("cmp_firma $id: id_gemeinde $row[3] != $id_gemeinde");
  }
  if ($row[4] != $kapital) {
    throw new Exception("cmp_firma $id: kapital $row[4] != $kapital");
  }
  if ($row[8] != $shab_seq) {
    throw new Exception("cmp_firma $id: shab_seq $row[8] != $shab_seq");
  }
  if ($row[10] != $strasse) {
    throw new Exception("cmp_firma $id: strasse $row[8] != $strasse");
  }

  if ($row[ 0] != $id             or
#     $row[ 1] != $code13         or
#     $row[ 2] != $id_hauptsitz   or
#     $row[ 3] != $id_gemeinde    or
      $row[ 5] != $currency       or
      $row[ 6] != $status         or
      $row[ 7] != $loesch_dat     or
      $row[ 9] != $care_of        or
#     $row[10] != $strasse        or
      $row[11] != $hausnummer     or
      $row[12] != $address_zusatz or
      $row[13] != $postfach       or
      $row[14] != $plz            or
      $row[15] != $ort          ) {
    throw new Exception("cmp_firma $id");
  }

  if ($row[16] != $rechtsform) {
    throw new Exception("cmp_firma Rechtform $row[16] != $rechtsform");
  }

}

function check_firma_bez($dbh) {

  check_count($dbh, 'firma_bez', 13);


  $sth = db_prep_exec($dbh, 'select * from firma_bez order by id_firma, dt_ab', array());
  cmp_firma_bez($sth,  451407, '940', 1, 'DE', -1, 'adp Analyse, Design & Programmierung GmbH'                                 , '1996-01-01', '2007-05-10');
  cmp_firma_bez($sth,  451407, '930', 1, 'DE', -1, 'ADP Analyse Design Planung GmbH'                                           , '2007-05-11', '2016-12-22');
  cmp_firma_bez($sth,  451407, '920', 1, 'DE',  3, 'ADP Analyse Design Planung AG'                                             , '2016-12-23', '9999-12-31');
  cmp_firma_bez($sth,  712087, '990', 1, 'DE',  3, 'Varian Medical Systems Imaging Laboratory GmbH'                            , '2003-07-03', '9999-12-31');
  cmp_firma_bez($sth,  728139, '990', 1, 'DE',  3, 'Volltext Lienert'                                                          , '2003-11-26', '9999-12-31');
  cmp_firma_bez($sth,  823465, '990', 1, 'DE', -1, 'd1 solutions ag'                                                           , '2005-12-28', '2011-10-31');
  cmp_firma_bez($sth,  823465, '980', 1, 'DE',  3, 'D1 Solutions AG'                                                           , '2011-11-01', '9999-12-31');
  cmp_firma_bez($sth,  934296, '990', 1, 'DE', -1, 'CBC Core Banking Competence Center AG'                                     , '2009-02-02', '2009-11-11');
  cmp_firma_bez($sth,  934296, '980', 1, 'DE',  3, 'Akyon AG'                                                                  , '2009-11-12', '9999-12-31');
  cmp_firma_bez($sth,  934296, '980', 2, 'EN',  3, 'Akyon Ltd.'                                                                , '2009-11-12', '9999-12-31');
  cmp_firma_bez($sth,  934296, '980', 2, 'FR',  3, 'Akyon SA'                                                                  , '2009-11-12', '9999-12-31');
  cmp_firma_bez($sth, 1290391, '990', 1, 'DE',  3, 'PUR Luftservice GmbH'                                                      , '2017-01-12', '9999-12-31');
  cmp_firma_bez($sth, 1292466, '990', 1, 'DE',  3, 'PUR Luftservice GmbH'                                                      , '2017-01-30', '9999-12-31');

  echo "firma_bez ok\n";

}

function cmp_firma_bez($sth, $id_firma, $seq, $typ, $sprachcode, $status, $bezeichnung, $dt_ab, $db_bis) {

  
  $row = $sth -> fetch();
  if ($row[0] != $id_firma) {
    throw new Exception("cmp_firma_bez id_firma: $row[0] != $id_firma");
  }
  if ($row[1] != $seq           or
      $row[2] != $typ           or
      $row[3] != $sprachcode    or
      $row[4] != $status        or
      $row[5] != $bezeichnung   or
      $row[6] != $dt_ab         or
      $row[7] != $db_bis
  ) {
    throw new Exception("cmp_firma_bez $id_firma");
  }
}

function check_zweck($dbh) {

  check_count($dbh, 'zweck', 7);

  $sth = db_prep_exec($dbh, 'select * from zweck order by id_firma', array());
  cmp_zweck($sth,  451407, 'Die Gesellschaft bezweckt die Beratung und Schulung von Unternehmen und Verwaltungen in allen wirtschaftlichen, organisatorischen und technischen Belangen, insbesondere der Analyse, Konzeption, Planung und Projektierung sowie Entwicklung, Lieferung und Unterhalt von IT-Software und -Infrastruktur.  Die Gesellschaft kann Zweigniederlassungen und Tochtergesellschaften im In- und Ausland errichten und sich an anderen Unternehmen im In- und Ausland beteiligen sowie alle Geschäfte tätigen, die direkt oder indirekt mit ihrem Zweck in Zusammenhang stehen. Die Gesellschaft kann im In- und Ausland Grundeigentum erwerben, belasten, veräussern und verwalten. Sie kann auch Finanzierungen für eigene oder fremde Rechnung vornehmen sowie Garantien und Bürgschaften für Tochtergesellschaften und Dritte eingehen.');
  cmp_zweck($sth,  712087, 'Vertrieb von elektronischen und technischen Einrichtungen aller Art und deren Bestandteile sowie Forschungs- und Entwicklungsarbeiten auf dem Gebiete elektronischer und technischer Einrichtungen im Medizinbereich, insbesondere im Bereich der Bildmanagement- und Behandlungsplanung Software; kann Patente, Handelsmarken, technische und industrielle Kenntnisse erwerben, verwalten und übertragen, sich an anderen Industrie- und Handelsunternehmen beteiligen, Zweigniederlassungen und Tochtergesellschaften errichten sowie Grundeigentum erwerben, belasten, veräussern und verwalten.');
  cmp_zweck($sth,  728139, 'Werbeberatung, Konzeption und Produktion von Ideen und Werbung, insbesondere Texte (Werbetexte, PR-Texte, Journalismus, Drehbücher, Ghostwriting und weitere Textsorten) und Grafik (Logodesign, Layouts für Broschüren, Inserate, Flyer, Plakate und weitere Werbeformen).');
  cmp_zweck($sth,  823465, 'Zweck der Gesellschaft ist die Erbringung von Dienstleistungen in den Bereichen Unternehmensberatung, Organisation und Coaching. Die Gesellschaft kann Tochtergesellschaften und Zweigniederlassungen im In- und Ausland errichten, Vertretungen übernehmen und alle Geschäfte eingehen, die den Gesellschaftszweck direkt oder indirekt fördern. Sie kann sich auch an anderen Unternehmungen beteiligen, Darlehen aufnehmen sowie Grundstücke erwerben, verwalten und veräussern.');
  cmp_zweck($sth,  934296, 'Die Gesellschaft bezweckt die Beratung und Schulung von Unternehmen in allen wirtschaftlichen, organisatorischen und technischen Belangen, insbesondere der Analyse, Konzeption, Planung und Projektierung sowie Entwicklung, Lieferung und Unterhalt von IT-Software und Infrastruktur. Die Gesellschaft kann Zweigniederlassungen und Tochtergesellschaften im In- und Ausland errichten und sich an anderen Unternehmen im In- und Ausland beteiligen sowie alle Geschäfte tätigen, die direkt oder indirekt mit ihrem Zweck in Zusammenhang stehen. Die Gesellschaft kann im In- und Ausland Grundeigentum erwerben, belasten, veräussern und verwalten. Sie kann auch Finanzierungen für eigene oder fremde Rechnung vornehmen sowie Garantien und Bürgschaften für Tochtergesellschaften und Dritte eingehen.');
  cmp_zweck($sth, 1290391, 'Zweck der Gesellschaft ist die Erbringung von Dienstleistungen im Bereich Lüftungsreinigung und -service. Ferner bezweckt die Gesellschaft die Planung, Ausführung, Wartung und Reparatur von Klima- und Lüftungsanlagen sowie den Handel mit Waren aller Art, insbesondere mit Klima- und Lüftungsanlagen sowie deren Komponenten. Die Gesellschaft kann Grundeigentum erwerben, belasten, verwalten und veräussern. Sie kann im In- und Ausland Tochterunternehmen und Zweigniederlassungen gründen sowie sich an anderen Unternehmen im In- und Ausland beteiligen. Sie kann Finanzierungen für eigene oder fremde Rechnung vornehmen sowie Garantien und Bürgschaften für Tochtergesellschaften und Dritte eingehen. Sie kann Urheberrechte, Patente und Lizenzen aller Art erwerben, belasten, verwalten und veräussern. Sie kann im Übrigen alle Geschäfte tätigen, die geeignet sind, die Entwicklung des Unternehmens sowie die Erreichung des Gesellschaftszwecks zu fördern.');
  cmp_zweck($sth, 1292466, '');

  echo "zweck ok\n";

}

function cmp_zweck($sth, $id_firma, $zweck) {

  $row = $sth -> fetch();

  if ($row[0] != $id_firma) {
    throw new Exception ("cmp_zweck $id_firma $row[0]");
  }
  if ($row[1] != $zweck) {
    throw new Exception ("cmp_gemeinde: $id, $id_firma");
  }

}

function check_gemeinde($dbh) {

  check_count($dbh, 'gemeinde', 5);

  $sth = db_prep_exec($dbh, 'select * from gemeinde order by id', array());
  cmp_gemeinde($sth,   56, 'Embrach'      );
  cmp_gemeinde($sth,  155, 'Männedorf'    );
  cmp_gemeinde($sth,  261, 'Zürich'       );
  cmp_gemeinde($sth, 1301, 'Einsiedeln'   );
  cmp_gemeinde($sth, 4021, 'Baden'        );

  echo "gemeinde ok\n";
}

function cmp_gemeinde($sth, $id, $gemeinde) {

  $row = $sth -> fetch();

  if ($row[0] != $id) {
    throw new Exception ("cmp_gemeinde: $id, $gemeinde, $row[0], $row[1]");
  }
  if ($row[1] != $gemeinde) {
    throw new Exception ("cmp_gemeinde: $id, $gemeinde, $row[0], $row[1]");
  }

}

function check_count($dbh, $table_name, $expected_cnt) {

  $cnt = db_cnt_table($dbh, $table_name);
  
  if ($cnt != $expected_cnt) {
    throw new Exception("$table_name cnt: $cnt");
  }
}


?>
