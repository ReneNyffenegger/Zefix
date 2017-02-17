<?php

include (getenv('github_root') . 'Zefix/web/php/db.php');

$dbh = db_connect('test');


check_gemeinde    ($dbh);
check_zweck       ($dbh);
check_firma_bez   ($dbh);
check_firma       ($dbh);
check_person_firma($dbh);
echo "Ok\n";

function check_firma($dbh) { #_{

  check_count($dbh, 'firma', 13);

  $sth = db_prep_exec($dbh, 'select * from firma order by id', array());
  #                    id,                                                           code13 ,    hpts,  gem, k apital,   cur, st,  del         ,   shab#,                                     ,                    ,       ,zus.,   pf, plz ,   ort             Rf
  cmp_firma($sth,   74461, 'Guamo SA'                                      , 'CH52430026861',    null,  5250,  200000, 'CHF',  2, null         , 3258589, null                                ,'Via Bossi'         ,  50   ,null, null,  6830 ,'Chiasso'       , 3);
  cmp_firma($sth,   76284, 'Frédéric Hänni S.A., installations électriques', 'CH67730001455',    null,  6800,  210000, 'CHF',  2, null         , 5320100, null                                ,'rue du Temple'     ,   3   ,null, null,  2900 ,'Porrentruy'    , 3);
  cmp_firma($sth,  150042, 'Genossenschaft christkatholisches Jugendhaus'  , 'CH14050020797',    null,	1403,	   null,  null,  2, null         , 3259371,'c/o Peter von Moos'                 ,'Melchaaweg'        ,   2   ,null, null,  6074 ,'Giswil'        , 5);
  cmp_firma($sth,  186673, 'Storella AG'                                   , 'CH50930004966',    null,	5097,	  50000, 'CHF',  0,'2001-05-09'  ,    null, null                                ,''                  , null  ,null, null,  null , null           , 3);
  cmp_firma($sth,  251792, 'Storella GmbH'                                 , 'CH32090204910',  468163,	3251,	   null,  null,  2, null         , 5723906,	null                                ,'Tiefenackerstrasse', '49'  ,null, null, '9450', 'Altstätten'   , 9);
  cmp_firma($sth,  451407, 'ADP Analyse Design Planung AG'                 , 'CH02040197464',    null,   261,  100000, 'CHF',  2, null         , 3242819, null                                ,'Glatttalstrasse'   ,'104 h',null, null, '8052', 'Zürich'       , 3);
  cmp_firma($sth,  468163, 'Storella Sagl'                                 , 'CH50940068681',    null,  5097,   50000, 'CHF',  2, null         , 2942553, null                                ,'Via Gabbietta'     ,  '3'  ,null, null, '6614', 'Brissago'     , 4);
  cmp_firma($sth,  712087, 'Varian Medical Systems Imaging Laboratory GmbH', 'CH40040245074',    null,  4021, 2000000, 'CHF',  2, null         , 2185269, null                                ,'Täfernstrasse'     ,  '7'  ,null, null, '5405', 'Baden-Dättwil', 4);
  cmp_firma($sth,  728139, 'Volltext Lienert'                              , 'CH02010440290',    null,   155,    null, null ,  2, null         , 6180656, null                                ,'Bahnhofstrasse'    , '14'  ,null, null, '8708', 'Männedorf'    , 1);
  cmp_firma($sth,  823465, 'D1 Solutions AG'                               , 'CH02030293815',    null,   261,  100000, 'CHF',  2, null         , 1667155, null                                ,'Zypressenstrasse'  , '71'  ,null, null, '8004', 'Zürich'       , 3);
  cmp_firma($sth,  934296, 'Akyon AG'                                      , 'CH02030334394',    null,   261,  100000, 'CHF',  2, null         , 3232871,'c/o ADP Analyse Design Planung GmbH','Glatttalstrassse'  ,'104f' ,null, null, '8052', 'Zürich'       , 3);
  cmp_firma($sth, 1290391, 'PUR Luftservice GmbH'                          , 'CH13040238566',    null,  1301,   20000, 'CHF',  2, null         , 3281571, null                                ,'Kornhausstrasse'   , '86'  ,null, null, '8840', 'Einsiedeln'   , 4);
  cmp_firma($sth, 1292466, 'PUR Luftservice GmbH'                          , 'CH02090047847', 1290391,    56,    null, null ,  2, null         , 3315327, null                                ,'Dorfstrasse'       ,'115'  ,null, null, '8424', 'Embrach'      , 9);

  echo "firma ok\n";

} #_}

function cmp_firma($sth, $id, $bezeichnung, $code13, $id_hauptsitz, $id_gemeinde, $kapital, $currency, $status, $loesch_dat, $shab_seq, $care_of, $strasse, $hausnummer, $address_zusatz, $postfach, $plz, $ort, $rechtsform) { #_{

  $row = $sth -> fetch();

  if ( ! eq($row[0], $id)) {
    throw new Exception("cmp_firma id $row[0] != $id");
  }
  if ( ! eq($row[1], $bezeichnung)) {
    throw new Exception("cmp_firma $id: bezeichnung $row[1] != $bezeichnung");
  }
  if ( ! eq($row[2], $code13)) {
    throw new Exception("cmp_firma $id: code13 $row[2] != $code13");
  }
  if ( ! eq($row[3], $id_hauptsitz)) {
    throw new Exception("cmp_firma $id: hauptsitz $row[3] != $id_hauptsitz");
  }
  if ( ! eq($row[4], $id_gemeinde)) {
    throw new Exception("cmp_firma $id: id_gemeinde $row[4] != $id_gemeinde");
  }
  if ( ! eq($row[5], $kapital)) {
    throw new Exception("cmp_firma $id: kapital $row[5] != $kapital");
  }
  if ( ! eq($row[6], $currency)) {
    throw new Exception("cmp_firma $id: currency $row[6] != $currency");
  }
  if (! eq($row[7], $status)) {
    throw new Exception("cmp_firma $id: status $row[7] != $status");
  }
  if ( ! eq($row[8], $loesch_dat)) {
    throw new Exception("cmp_firma $id: loeschdat $row[8] != $loesch_dat");
  }
  if ( ! eq($row[9], $shab_seq)) {
    throw new Exception("cmp_firma $id: shab_seq $row[9] != $shab_seq");
  }
  if ( ! eq($row[11], $strasse)) {
    throw new Exception("cmp_firma $id: strasse $row[11] != $strasse");
  }

  if (# $row[ 0] != $id             or
#     $row[ 1] != $code13         or
#     $row[ 2] != $id_hauptsitz   or
#     $row[ 3] != $id_gemeinde    or
#     $row[ 6] != $currency       or
#     $row[ 7] != $status         or
#     $row[ 8] != $loesch_dat     or
      $row[10] != $care_of        or
#     $row[10] != $strasse        or
      $row[12] != $hausnummer     or
      $row[13] != $address_zusatz or
      $row[14] != $postfach       or
      $row[15] != $plz            or
      $row[16] != $ort          ) {
    throw new Exception("cmp_firma $id");
  }

  if ( ! eq($row[17], $rechtsform)) {
    throw new Exception("cmp_firma Rechtform $row[17] != $rechtsform");
  }

} #_}

function check_firma_bez($dbh) { #_{

  check_count($dbh, 'firma_bez', 20);


  $sth = db_prep_exec($dbh, 'select * from firma_bez order by id_firma, dt_ab', array());
  cmp_firma_bez($sth,   74461, '940', 1, 'IT',  3, 'Guamo SA'                                                                  , '1996-01-01', '9999-12-31');
  cmp_firma_bez($sth,   76284, '940', 1, 'FR',  3, 'Frédéric Hänni S.A., installations électriques'                            , '1996-01-01', '9999-12-31');
  cmp_firma_bez($sth,  150042, '940', 1, 'DE',  3, 'Genossenschaft christkatholisches Jugendhaus'                              , '1996-01-01', '9999-12-31');
  cmp_firma_bez($sth,  186673, '940', 1, 'IT',  3, 'Storella AG'                                                               , '1996-01-01', '9999-12-31');
  cmp_firma_bez($sth,  251792, '940', 1, 'DE',  3, 'Storella GmbH'                                                             , '1996-01-01', '9999-12-31');
  cmp_firma_bez($sth,  451407, '940', 1, 'DE', -1, 'adp Analyse, Design & Programmierung GmbH'                                 , '1996-01-01', '2007-05-10');
  cmp_firma_bez($sth,  451407, '930', 1, 'DE', -1, 'ADP Analyse Design Planung GmbH'                                           , '2007-05-11', '2016-12-22');
  cmp_firma_bez($sth,  451407, '920', 1, 'DE',  3, 'ADP Analyse Design Planung AG'                                             , '2016-12-23', '9999-12-31');
  cmp_firma_bez($sth,  468163, '940', 1, 'IT',  3, 'Storella Sagl'                                                             , '1999-12-04', '9999-12-31');
  cmp_firma_bez($sth,  468163, '940',	2, 'FR',  3, 'Storella GmbH'                                                             , '1999-12-04', '9999-12-31');
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

} #_}

function cmp_firma_bez($sth, $id_firma, $seq, $typ, $sprachcode, $status, $bezeichnung, $dt_ab, $dt_bis) { #_{

  
  $row = $sth -> fetch();
  if ( ! eq($row[0], $id_firma)) {
    throw new Exception("cmp_firma_bez id_firma: $row[0] != $id_firma");
  }
  if ( ! eq($row[1], $seq)) {
    throw new Exception("cmp_firma_bez $id_firma seq $row[1] != $seq");
  }
  if ( ! eq($row[2], $typ)) {
    throw new Exception("cmp_firma_bez $id_firma typ $row[2] != $typ");
  }
  if ( ! eq($row[3], $sprachcode)) {
    throw new Exception("cmp_firma_bez $id_firma sprachcode $row[3] != $sprachcode");
  }
  if ( ! eq($row[4], $status)) {
    throw new Exception("cmp_firma_bez $id_firma status $row[4] != $status");
  }
  if ( ! eq($row[5], $bezeichnung)) {
    throw new Exception("cmp_firma_bez $id_firma bezeichnung $row[5] != $bezeichnung");
  }
  if ( ! eq($row[6], $dt_ab)) {
    throw new Exception("cmp_firma_bez $id_firma dt_ab $row[6] != $dt_ab");
  }
  if ( ! eq($row[7], $dt_bis)) {
    throw new Exception("cmp_firma_bez $dt_bis dt_bis $row[7] != $dt_bis");
  }
#  if (# $row[1] != $seq           or
##     $row[2] != $typ           or
##     $row[3] != $sprachcode    or
##     $row[4] != $status        or
##     $row[5] != $bezeichnung   or
##     $row[6] != $dt_ab         or
#      $row[7] != $db_bis
#  ) {
#    throw new Exception("cmp_firma_bez $id_firma");
#  }
} #_}

function check_zweck($dbh) { #_{

  check_count($dbh, 'zweck', 13);

  $sth = db_prep_exec($dbh, 'select * from zweck order by id_firma', array());
  cmp_zweck($sth,   74461, 'la compra-vendita, la costruzione e l\'amministrazione di immobili, nonché la partecipazione a società similari, sia nazionali che estere. La società può inoltre effettuare ogni operazione ed assumere ogni funzione suscettibile di contribuire direttamente o indirettamente a raggiungere lo scopo.');
  cmp_zweck($sth,   76284, 'L\'exploitation d\'une entreprise d\'électricité ainsi que l\'exploitation d\'une concession téléphonique. Elle pourra également s\'occuper de l\'achat et de la vente d\'appareils électriques.');
  cmp_zweck($sth,  150042, 'Bau, Unterhalt und Betrieb eines Jugendhauses zur Durchführung von Ferienlagern, Tagungen und Kursen, Landschulwochen, Familienferien und ähnlichem.');
  cmp_zweck($sth,  186673, '');
  cmp_zweck($sth,  251792, '');
  cmp_zweck($sth,  451407, 'Die Gesellschaft bezweckt die Beratung und Schulung von Unternehmen und Verwaltungen in allen wirtschaftlichen, organisatorischen und technischen Belangen, insbesondere der Analyse, Konzeption, Planung und Projektierung sowie Entwicklung, Lieferung und Unterhalt von IT-Software und -Infrastruktur.  Die Gesellschaft kann Zweigniederlassungen und Tochtergesellschaften im In- und Ausland errichten und sich an anderen Unternehmen im In- und Ausland beteiligen sowie alle Geschäfte tätigen, die direkt oder indirekt mit ihrem Zweck in Zusammenhang stehen. Die Gesellschaft kann im In- und Ausland Grundeigentum erwerben, belasten, veräussern und verwalten. Sie kann auch Finanzierungen für eigene oder fremde Rechnung vornehmen sowie Garantien und Bürgschaften für Tochtergesellschaften und Dritte eingehen.');
  cmp_zweck($sth,  468163, 'Il commercio di impianti solari e di case prefabbricate risparmianti energia, tecnica energetica, elementi edili di tutti i generi come pure il commercio all\'ingrosso di prodotti tessili per la protezione solare ed il tempo libero. La società può eseguire tutte le operazioni direttamente o indirettamente correlate allo scopo sociale o che ne favoriscano l\'attuazione, istituire succursali o stabilimenti sul territorio nazionale o all\'estero, partecipare direttamente o indirettamente ad altre società o istituzioni o erogare loro servizi finanziari. La società può acquistare, amministrare e vendere degli immobili.');
  cmp_zweck($sth,  712087, 'Vertrieb von elektronischen und technischen Einrichtungen aller Art und deren Bestandteile sowie Forschungs- und Entwicklungsarbeiten auf dem Gebiete elektronischer und technischer Einrichtungen im Medizinbereich, insbesondere im Bereich der Bildmanagement- und Behandlungsplanung Software; kann Patente, Handelsmarken, technische und industrielle Kenntnisse erwerben, verwalten und übertragen, sich an anderen Industrie- und Handelsunternehmen beteiligen, Zweigniederlassungen und Tochtergesellschaften errichten sowie Grundeigentum erwerben, belasten, veräussern und verwalten.');
  cmp_zweck($sth,  728139, 'Werbeberatung, Konzeption und Produktion von Ideen und Werbung, insbesondere Texte (Werbetexte, PR-Texte, Journalismus, Drehbücher, Ghostwriting und weitere Textsorten) und Grafik (Logodesign, Layouts für Broschüren, Inserate, Flyer, Plakate und weitere Werbeformen).');
  cmp_zweck($sth,  823465, 'Zweck der Gesellschaft ist die Erbringung von Dienstleistungen in den Bereichen Unternehmensberatung, Organisation und Coaching. Die Gesellschaft kann Tochtergesellschaften und Zweigniederlassungen im In- und Ausland errichten, Vertretungen übernehmen und alle Geschäfte eingehen, die den Gesellschaftszweck direkt oder indirekt fördern. Sie kann sich auch an anderen Unternehmungen beteiligen, Darlehen aufnehmen sowie Grundstücke erwerben, verwalten und veräussern.');
  cmp_zweck($sth,  934296, 'Die Gesellschaft bezweckt die Beratung und Schulung von Unternehmen in allen wirtschaftlichen, organisatorischen und technischen Belangen, insbesondere der Analyse, Konzeption, Planung und Projektierung sowie Entwicklung, Lieferung und Unterhalt von IT-Software und Infrastruktur. Die Gesellschaft kann Zweigniederlassungen und Tochtergesellschaften im In- und Ausland errichten und sich an anderen Unternehmen im In- und Ausland beteiligen sowie alle Geschäfte tätigen, die direkt oder indirekt mit ihrem Zweck in Zusammenhang stehen. Die Gesellschaft kann im In- und Ausland Grundeigentum erwerben, belasten, veräussern und verwalten. Sie kann auch Finanzierungen für eigene oder fremde Rechnung vornehmen sowie Garantien und Bürgschaften für Tochtergesellschaften und Dritte eingehen.');
  cmp_zweck($sth, 1290391, 'Zweck der Gesellschaft ist die Erbringung von Dienstleistungen im Bereich Lüftungsreinigung und -service. Ferner bezweckt die Gesellschaft die Planung, Ausführung, Wartung und Reparatur von Klima- und Lüftungsanlagen sowie den Handel mit Waren aller Art, insbesondere mit Klima- und Lüftungsanlagen sowie deren Komponenten. Die Gesellschaft kann Grundeigentum erwerben, belasten, verwalten und veräussern. Sie kann im In- und Ausland Tochterunternehmen und Zweigniederlassungen gründen sowie sich an anderen Unternehmen im In- und Ausland beteiligen. Sie kann Finanzierungen für eigene oder fremde Rechnung vornehmen sowie Garantien und Bürgschaften für Tochtergesellschaften und Dritte eingehen. Sie kann Urheberrechte, Patente und Lizenzen aller Art erwerben, belasten, verwalten und veräussern. Sie kann im Übrigen alle Geschäfte tätigen, die geeignet sind, die Entwicklung des Unternehmens sowie die Erreichung des Gesellschaftszwecks zu fördern.');
  cmp_zweck($sth, 1292466, '');

  echo "zweck ok\n";

} #_}

function cmp_zweck($sth, $id_firma, $zweck) { #_{

  $row = $sth -> fetch();

  if (! eq($row[0], $id_firma)) {
    throw new Exception ("cmp_zweck $id_firma $row[0]");
  }
  if (! eq($row[1], $zweck)) {

    print "Zweck missmatch
       id_firma: $id_firma
       expected: $zweck
       found:    $row[1]
    ";

    throw new Exception ("cmp_zweck: $id_firma, $row[1]");
  }

} #_}

function check_person_firma($dbh) { #_{

  check_count($dbh, 'person_firma', 79);
  $sth = db_prep_exec($dbh, 'select * from person_firma order by dt_journal, id_firma');
  $cnt=1;

  $gs='Gesellschafter';
  $gf='Geschäftsführung';
  $rev='Revisionsstelle';
  $inh='Inhaber';
  $varian='Varian Medical Systems International AG';

  cmp_person_firma($sth, $cnt++, 468163   ,'2001-01-23'  ,'-'  ,'Dettwiler'     ,'Werner'           ,'Reigoldswil'                         ,NULL                                               ,'Eichberg'                  ,'socio e gerente'                            , 'con firma individuale'                               , 'con una quota da CHF 1\'000.--'                       ); #_{
  cmp_person_firma($sth, $cnt++, 251792   ,'2001-07-30'  ,'-'  ,'Dettwiler'     ,'Werner'           ,'Reigoldswil'                         ,NULL                                               ,'Eichberg'                  ,'Gesellschafter und Geschäftsführer'         , 'mit Einzelunterschrift'                              ,  NULL                                                  );
  cmp_person_firma($sth, $cnt++, 251792   ,'2001-07-30'  ,'+'  ,'Wüst'          ,'Günter'           ,'Oberriet SG'                         ,NULL                                               ,'Lüchingen (Altstätten)'    ,'Gesellschafter und Geschäftsführer'         , 'mit Einzelunterschrift'                              ,  NULL                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2002-04-30'  ,'+'  ,'Huber'         ,'Marcel'           ,'Eschenbach LU'                       ,NULL                                               ,'Eschenbach LU'             ,'Kassier'                                    , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2003-06-30'  ,'+'  , null           , null              , null                                 ,'Varian Medical Systems International AG'          ,'Zug'                       ,'Gesellschafterin'                           , 'ohne Zeichnungsberechtigung'                         , 'mit einer Stammeinlage von CHF 1\'999\'000.--'        );
  cmp_person_firma($sth, $cnt++, 712087   ,'2003-06-30'  ,'+'  ,'Oderbolz'      ,'Fritz'            ,'Tübach'                              , null                                              ,'Hünenberg'                 ,'Gesellschafter'                             , 'ohne Zeichnungsberechtigung'                         , 'mit einer Stammeinlage von CHF 1\'000.--'             );
  cmp_person_firma($sth, $cnt++, 712087   ,'2003-06-30'  ,'+'  ,'Vogt'          ,'Heinz'            ,'Lauwil'                              , null                                              ,'Baldingen'                 ,'Geschäftsführer'                            , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2003-06-30'  ,'+'  , null           , null              , null                                 ,'PricewaterhouseCoopers AG'                        ,'Zürich'                    ,'Revisionsstelle'                            ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 728139   ,'2003-11-20'  ,'+'  ,'Lienert'       ,'Joachim Georg'    ,'Einsiedeln'                          , null                                              ,'Elsau'                     ,$inh                                         , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'-'  ,'Sidler'        ,'Ruth'             ,'Rifferswil und Luzern'               , null                                              ,'Affoltern a.A.'            ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'-'  ,'Messerli'      ,'Rudolf'           ,'Rüeggisberg'                         , null                                              ,'Oberwil BL'                ,'Präsident'                                  , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'-'  ,'Dellagiacoma'  ,'Marlis'           ,'Kriens und Uster'                    , null                                              ,'Kriens'                    ,'Aktuarin'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'-'  ,'Vogel-Ruffieux','Vreni'            ,'Oberurnen'                           , null                                              ,'Allschwil'                 ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Metzger'       ,'Caroline'         ,'Möhlin'                              , null                                              ,'Gossau SG'                 ,'Aktuarin'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Martin'        ,'Stefan'           ,'Pratteln'                            , null                                              ,'Olten'                     ,'Präsident'                                  , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Huber'         ,'Marcel'           ,'Eschenbach LU'                       , null                                              ,'Zug'                       ,'Kassier'                                    , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Jebelean'      ,'Ioan'             ,'Luzern'                              , null                                              ,'Luzern'                    ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Vogel'         ,'Andres'           ,'Oberurnen'                           , null                                              ,'Allschwil'                 ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2005-07-04'  ,'-'  ,NULL            ,NULL               ,NULL                                  ,'Künzler Communications GmbH'                      ,'Bassersdorf'               ,'Gesellschafterin'                           , 'ohne Zeichnungsberechtigung'                         , 'mit einer Stammeinlage von CHF 1\'000.--'             );
  cmp_person_firma($sth, $cnt++, 451407   ,'2005-07-04'  ,'+'  ,'Nyffenegger'   ,'René'             ,'Eriswil'                             ,NULL                                               ,'Zürich'                    ,'Gesellschafter und Geschäftsführer'         , 'mit Einzelunterschrift'                              , 'mit einer Stammeinlage von CHF 20\'000.--'            );
  cmp_person_firma($sth, $cnt++, 823465   ,'2005-12-22'  ,'+'  ,'Rossbacher'    ,'Albert'           ,'Röthenbach bei Herzogenbuchsee'      ,NULL                                               ,'Herrliberg'                ,'Mitglied'                                   , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2005-12-22'  ,'+'  ,NULL            ,NULL               ,NULL                                  ,'Ortag, Organisations-, Revisions- und Treuhand-AG','Zürich'                    ,'Revisionsstelle'                            ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2006-05-16'  ,'-'  ,'Rossbacher'    ,'Albert'           ,'Röthenbach bei Herzogenbuchsee'      ,NULL                                               ,'Herrliberg'                ,'Mitglied'                                   , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2006-05-16'  ,'+'  ,'Hagger'        ,'Joachim Andreas'  ,'Basel'                               ,NULL                                               ,'Zürich'                    ,'Präsident'                                  , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2006-05-16'  ,'+'  ,'Gränicher'     ,'Hans Peter'       ,'Röthenbach bei Herzogenbuchsee'      ,NULL                                               ,'Zürich'                    ,'Mitglied'                                   , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2006-05-16'  ,'+'  ,'Hefti'         ,'Simon'            ,'Thun'                                ,NULL                                               ,'Zürich'                    ,'Mitglied'                                   , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );

  cmp_person_firma($sth, $cnt++, 712087   ,'2007-02-13'  ,'+'  ,'Oderbolz'      ,'Fritz'            ,'Tübach'                              , null                                              ,'Hünenberg'                 ,'Gesellschafter'                             ,'mit Kollektivunterschrift zu zweien'                  ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2007-02-13'  ,'+'  , null           , null              , null                                 ,$varian                                            ,'Zug'                       ,'Gesellschafterin'                           ,'ohne Zeichnungsberechtigung'                          , 'mit einer Stammeinlage von CHF 2\'000\'000.--'        );
  cmp_person_firma($sth, $cnt++, 712087   ,'2007-02-13'  ,'+'  ,'Amstutz'       ,'Martin'           ,'Engelberg'                           , null                                              ,'Döttingen'                 , null                                        ,'mit Kollektivunterschrift zu zweien'                  ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2007-02-13'  ,'+'  ,'Hauri'         ,'Reto'             ,'Niederlenz'                          , null                                              ,'Gränichen'                 , null                                        ,'mit Kollektivunterschrift zu zweien'                  ,  null                                                  );

  cmp_person_firma($sth, $cnt++, 451407   ,'2007-05-07'  ,'+'  ,'Ginnow'        ,'Richard'          ,'Volketswil'                          ,NULL                                               ,'Rüschlikon'                ,'Gesellschafter und Geschäftsführer'         , 'mit Kollektivunterschrift zu zweien'                 , 'mit einer Stammeinlage von CHF 10\'000.--'            );
  cmp_person_firma($sth, $cnt++, 451407   ,'2007-05-07'  ,'+'  ,'Nyffenegger'   ,'René'             ,'Eriswil'                             ,NULL                                               ,'Zürich'                    ,'Gesellschafter und Geschäftsführer'         , 'mit Kollektivunterschrift zu zweien'                 , 'mit einer Stammeinlage von CHF 10\'000.--'            );
  cmp_person_firma($sth, $cnt++, 451407   ,'2008-09-08'  ,'-'  ,'Nyffenegger'   ,'René'             ,'Eriswil'                             ,NULL                                               ,'Zürich'                    ,'Gesellschafter und Geschäftsführer'         , 'mit Kollektivunterschrift zu zweien'                 , 'mit einem Stammanteil von CHF 10\'000.00'             );
  cmp_person_firma($sth, $cnt++, 451407   ,'2008-09-08'  ,'+'  ,'Ginnow'        ,'Richard'          ,'Volketswil'                          ,NULL                                               ,'Rüschlikon'                ,'Gesellschafter und Geschäftsführer'         , 'mit Einzelunterschrift'                              , 'mit 200 Stammanteilen zu je CHF 100.00'               );
  cmp_person_firma($sth, $cnt++, 451407   ,'2008-09-08'  ,'+'  ,'Weber'         ,'Melanie'          ,'Gränichen'                           ,NULL                                               ,'Zell ZH'                   , null                                        , 'mit Einzelprokura'                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-01-28'  ,'+'  ,'Ginnow'        ,'Richard'          ,'Volketswil'                          ,NULL                                               ,'Mettmenstetten'            ,'Präsident des Verwaltungsrates'             , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-01-28'  ,'+'  ,'Kuhn'          ,'Roland'           ,'Illnau-Effretikon'                   ,NULL                                               ,'St. Gallen'                ,'Mitglied des Verwaltungsrates'              , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++,  76284   ,'2009-10-26'  ,'-'  , null           , null              , null                                 ,'Fiduciaire Jean-Maurice Maitre S.A.'              ,'Porrentruy'                , null                                        ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++,  76284   ,'2009-10-26'  ,'+'  , null           , null              , null                                 ,'RéviAjoie Sàrl'                                   ,'Porrentruy'                , null                                        ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Ginnow'        ,'Richard'          ,'Volketswil'                          ,NULL                                               ,'Mettmenstetten'            ,'Präsident des Verwaltungsrates'             , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Kuhn'          ,'Roland'           ,'Illnau-Effretikon'                   ,NULL                                               ,'St. Gallen'                ,'Mitglied des Verwaltungsrates'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Norgate'       ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                               ,'Freienbach'                ,'Mitglied der Geschäftsleitung'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Keller'        ,'Primin'           ,'Altendorf'                           ,NULL                                               ,'Waldkirch'                 ,'Mitglied der Geschäftsleitung'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Weber'         ,'Melanie'          ,'Gränichen'                           ,NULL                                               ,'Zell ZH'                   , null                                        , 'mit Einzelprokura'                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2009-12-03'  ,'+'  ,'Ginnow'        ,'Richard'          ,'Volketswil'                          ,NULL                                               ,'Mettmenstetten'            ,'Gesellschafter und Geschäftsführer'         , 'mit Einzelunterschrift'                              , 'mit 170 Stammanteilen zu je CHF 100.00'               );
  cmp_person_firma($sth, $cnt++, 451407   ,'2009-12-03'  ,'+'  ,'Norgate'       ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                               ,'Freienbach'                ,'Gesellschafter'                             , 'mit Kollektivunterschrift zu zweien'                 , 'mit 30 Stammanteilen zu je CHF 100.00'                );
  cmp_person_firma($sth, $cnt++, 251792   ,'2010-07-07'  ,'-'  ,'Riedmüller'    ,'Josef'            ,'deutscher Staatsangehöriger'         ,NULL                                               ,'Biberach an der Riss (D)'  ,'Gesellschafter und Geschäftsführer'         , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 251792   ,'2010-07-07'  ,'-'  ,'Wüst'          ,'Günter'           ,'Oberriet SG'                         ,NULL                                               ,'Lüchingen (Altstätten)'    ,'Gesellschafter und Geschäftsführer'         , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2011-10-27'  ,'+'  ,'Hefti'         ,'Simon'            ,'Thun'                                ,NULL                                               ,'Zürich'                    ,'Präsident des Verwaltungsrates'             , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2011-10-27'  ,'+'  ,'Hagger'        ,'Joachim Andreas'  ,'Basel'                               ,NULL                                               ,'Zürich'                    ,'Mitglied des Verwaltungsrates'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2011-10-27'  ,'+'  ,'Vckovski'      ,'Andrej'           ,'Zürich'                              ,NULL                                               ,'Zürich'                    ,'Mitglied des Verwaltungsrates'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2011-10-27'  ,'+'  ,'Gränicher'     ,'Hans Peter'       ,'Röthenbach bei Herzogenbuchsee'      ,NULL                                               ,'Zürich'                    ,'Geschäftsführer'                            , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2012-12-05'  ,'+'  ,'Brabec'        ,'Dr. Bernhard'     ,'österreichischer Staatsangehöriger'  ,NULL                                               ,'Zollikon'                  , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2012-12-05'  ,'+'  ,'Rutz'          ,'Candid'           ,'Emmen'                               ,NULL                                               ,'Zürich'                    , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2012-12-05'  ,'+'  ,'Hausmann'      ,'Alexander'        ,'Dietikon'                            ,NULL                                               ,'Dietikon'                  , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2012-12-05'  ,'+'  ,'Stefanakos'    ,'Stamatios'        ,'griechischer Staatsangehöriger'      ,NULL                                               ,'Zürich'                    , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2013-07-29'  ,'-'  ,'Brabec'        ,'Dr. Bernhard'     ,'österreichischer Staatsangehöriger'  ,NULL                                               ,'Zollikon'                  , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2013-07-29'  ,'-'  ,'Hausmann'      ,'Alexander'        ,'Dietikon'                            ,NULL                                               ,'Dietikon'                  , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2013-07-29'  ,'+'  ,NULL            ,NULL               ,NULL                                  ,'ORTAG AG'                                         ,'Zürich'                    ,'Revisionsstelle'                            ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2014-08-13'  ,'-'  ,'Hagger'        ,'Joachim Andreas'  ,'Basel'                               ,NULL                                               ,'Zürich'                    ,'Mitglied des Verwaltungsrates'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2014-08-13'  ,'+'  ,'Franz'         ,'Mike'             ,'Frick'                               ,NULL                                               ,'Gipf-Oberfrick'            ,'Mitglied des Verwaltungsrates'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-10-04'  ,'+'  ,'Ginnow'        ,'Richard'          ,'Volketswil'                          ,NULL                                               ,'Mettmenstetten'            ,"$gs und Vorsitzender der $gf"               , 'mit Einzelunterschrift'                              , 'mit 188 Stammanteilen zu je CHF 100.00'               );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-10-04'  ,'+'  ,'Norgate'       ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                               ,'Freienbach'                ,'Gesellschafter und Geschäftsführer'         , 'mit Einzelunterschrift'                              , 'mit 12 Stammanteilen zu je CHF 100.00'                );
  cmp_person_firma($sth, $cnt++, 934296   ,'2016-12-15'  ,'-'  ,'Kuhn'          ,'Roland'           ,'Illnau-Effretikon'                   ,NULL                                               ,'St. Gallen'                ,'Mitglied des Verwaltungsrates'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2016-12-15'  ,'-'  ,'Keller'        ,'Primin'           ,'Altendorf'                           ,NULL                                               ,'Waldkirch'                 ,'Mitglied der Geschäftsleitung'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2016-12-15'  ,'+'  ,'Norgate'       ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                               ,'Freienbach'                ,'Mitglied des Verwaltungsrates'              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-12-20'  ,'+'  ,'Ginnow'        ,'Richard'          ,'Volketswil'                          ,NULL                                               ,'Mettmenstetten'            ,'Präsident des Verwaltungsrates'             , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-12-20'  ,'+'  ,'Norgate'       ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                               ,'Freienbach'                ,'Mitglied des Verwaltungsrates'              , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-12-20'  ,'+'  ,'Büetiger'      ,'Jan'              ,'Schnottwil'                          ,NULL                                               ,'Gossau ZH'                 , null                                        , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 74461    ,'2016-12-28'  ,'-'  , null           , null              , null                                 ,'Fidea SA'                                         ,'Chiasso'                   , null                                        ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'-'  ,'Martin-Metzger','Caroline'         ,'Pratteln und Möhlin'                 ,null                                               ,'Uster'                     ,'Aktuarin'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'-'  ,'Schmid'        ,'Thomas'           ,'Kaiseraugst'                         ,null                                               ,'Sarnen'                    ,'Vizepräsident'                              , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'-'  ,'Jebelean'      ,'Ioan'             ,'Luzern'                              ,null                                               ,'Luzern'                    ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'-'  ,'Vogel'         ,'Andres'           ,'Oberurnen'                           ,null                                               ,'Allschwil'                 ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'+'  ,'Hostettler'    ,'Martin'           ,'Schwarzenburg'                       ,null                                               ,'Gerlafingen'               ,'Mitglied der Verwaltung'                    , 'mit Kollektivunterschrift zu zweien'                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'+'  ,'Simpson'       ,'Lars'             ,'Schönenwerd'                         ,null                                               ,'Zürich'                    ,'Mitglied der Verwaltung'                    , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'+'  , null           , null              , null                                 ,'Solidis Treuhand AG (<M>CHE107.909.432<E>)'       ,'Olten'                     , $rev                                        ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 1290391  ,'2017-01-10'  ,'+'  ,'Oesch'         ,'Severin'          ,'Embrach'                             ,NULL                                               ,'Kloten'                    ,'Gesellschafter und Geschäftsführer'         , 'mit Kollektivunterschrift zu zweien'                 , 'mit 10 Stammanteilen zu je CHF 1\'000.00'             );
  cmp_person_firma($sth, $cnt++, 1290391  ,'2017-01-10'  ,'+'  ,'Grätzer'       ,'Adrian Willy'     ,'Einsiedeln'                          ,NULL                                               ,'Einsiedeln'                ,"$gs und Vorsitzender der $gf"               , 'mit Kollektivunterschrift zu zweien'                 , 'mit 10 Stammanteilen zu je CHF 1\'000.00'             ); #_}

  echo "person_firma ok\n";

} #_}

function cmp_person_firma($sth, $cnt, $id_firma, $dt_journal, $add_rm, $nachname, $vorname, $von, $bezeichnung, $in_,  #_{
  $funktion, $zeichnung, $stammeinlage) {

  $row = $sth -> fetch();

  if (! eq($row[ 0], $id_firma        )) {throw new Exception("cmp_person_firma (cnt = $cnt) 0 row[0] = $row[0], row[1]=$row[1]  id_firma=$id_firma, dtJournal=$dt_journal"); }
  if (! eq($row[ 1], $dt_journal      )) {throw new Exception("cmp_person_firma (cnt = $cnt) 1, row[1] = $row[1], id_firma=$id_firma, dt_journal=$dt_journal"); }
  if (! eq($row[ 2], $add_rm          )) {throw new Exception("cmp_person_firma (cnt = $cnt) 2"); }
  if (! eq($row[ 3], $nachname        )) {throw new Exception("cmp_person_firma (cnt = $cnt) 3 Nachname found: $row[3], expected: $nachname, id_firma=$id_firma, dt_journal=$dt_journal"); }
  if (! eq($row[ 4], $vorname         )) {throw new Exception("cmp_person_firma (cnt = $cnt) 4 Vorname found: $row[4], expected $vorname"); }
  if (! eq($row[ 5], $von             )) {throw new Exception("cmp_person_firma (cnt = $cnt) 5 von found: $row[5], expected $von"); }
  if (! eq($row[ 6], $bezeichnung     )) {throw new Exception("cmp_person_firma (cnt = $cnt) bezeichnung: " . $row[6] . ' != '  . $bezeichnung); }
  if (! eq($row[ 7], $in_             )) {throw new Exception("cmp_person_firma (cnt = $cnt) 7 journal=$dt_journal, id_firma=$id_firma, in=$in_, row[7]=$row[7]"); }

  $c = 8;

  if (! eq($row[$c], $funktion        )) {throw new Exception("cmp_person_firma (cnt = $cnt) $c dt_journal=$dt_journal, id_firma=$id_firma, funktion=$funktion, row[c]="          . $row[$c]); } $c++;
  if (! eq($row[$c], $zeichnung       )) {throw new Exception("cmp_person_firma (cnt = $cnt) $c dt_journal=$dt_journal, id_firma=$id_firma, zeichnung expected:$zeichnung<     found: row[c]="         . $row[$c]); } $c++;
  if (! eq($row[$c], $stammeinlage    )) {
    
    print "\nMismatch Stammeinlage\n";
    print   bin2hex($stammeinlage). "\n";
    print   bin2hex($row[$c]     ). "\n";
    throw new Exception("cmp_person_firma $c dt_journal=$dt_journal, id_firma=$id_firma, Stammeinlage=$stammeinlage< row[c]="         . $row[$c] . '<'); 
  } $c++;


} #_}

function check_gemeinde($dbh) { #_{

  check_count($dbh, 'gemeinde', 10);

  $sth = db_prep_exec($dbh, 'select * from gemeinde order by id', array());
  cmp_gemeinde($sth,   56, 'Embrach'      );
  cmp_gemeinde($sth,  155, 'Männedorf'    );
  cmp_gemeinde($sth,  261, 'Zürich'       );
  cmp_gemeinde($sth, 1301, 'Einsiedeln'   );
  cmp_gemeinde($sth, 1403, 'Giswil'       );
  cmp_gemeinde($sth, 3251, 'Altstätten'   );
  cmp_gemeinde($sth, 4021, 'Baden'        );
  cmp_gemeinde($sth, 5097, 'Brissago'     );
  cmp_gemeinde($sth, 5250, 'Chiasso'      );
  cmp_gemeinde($sth, 6800, 'Porrentruy'   );

  echo "gemeinde ok\n";
} #_}

function cmp_gemeinde($sth, $id, $gemeinde) { #_{

  $row = $sth -> fetch();

  if (! eq($row[0], $id)) {

    print "Missmatch in cmp_gemeinde:
        id expected: $id ($gemeinde)
        found:       $row[0] ($row[1])
    ";

    throw new Exception ("cmp_gemeinde: $id, $gemeinde, $row[0], $row[1]");
  }
  if (! eq($row[1], $gemeinde)) {
    throw new Exception ("cmp_gemeinde: $id, $gemeinde, $row[0], $row[1]");
  }

} #_}

function check_count($dbh, $table_name, $expected_cnt) { #_{

  $cnt = db_cnt_table($dbh, $table_name);
  
  if ($cnt != $expected_cnt) {
    throw new Exception("$table_name cnt: $cnt");
  }
} #_}

function eq($a, $b) { #_{
  if (is_null($a) && ! is_null($b)) {
    return false;
  }
  if (is_null($b) && ! is_null($a)) {
    return false;
  }
  if (is_null($a) && is_null($a)) {
    return true;
  }
  return $a == $b;
} #_}

?>
