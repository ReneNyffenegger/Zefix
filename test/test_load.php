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

  check_count($dbh, 'firma', 27);

  $zuffrey = 'Zufferey Aurélie et Tânia Margarida da Mota Cardoso Kiosque Liberté';
  $fiduc_crans = 'Fiduciaire de Crans-Montana (FCM) SA';

  $sth = db_prep_exec($dbh, 'select * from firma order by id', array());
  #                    id,                                                           code13 ,    hpts,  gem, k apital,   cur, st,  del         ,   shab#,                                     ,                           ,       ,zus.,        pf, plz ,   ort                Rf
  cmp_firma($sth,   74461, 'Guamo SA'                                      , 'CH52430026861',    null,  5250,  200000, 'CHF',  2, null         , 3258589, null                                ,'Via Bossi'                ,  50   ,null,      null,  6830 ,'Chiasso'         , 3);
  cmp_firma($sth,   76284, 'Frédéric Hänni S.A., installations électriques', 'CH67730001455',    null,  6800,  210000, 'CHF',  2, null         , 5320100, null                                ,'rue du Temple'            ,   3   ,null,      null,  2900 ,'Porrentruy'      , 3);
  cmp_firma($sth,  150042, 'Genossenschaft christkatholisches Jugendhaus'  , 'CH14050020797',    null,  1403,    null,  null,  2, null         , 3259371,'c/o Peter von Moos'                 ,'Melchaaweg'               ,   2   ,null,      null,  6074 ,'Giswil'          , 5);
  cmp_firma($sth,  186673, 'Storella AG'                                   , 'CH50930004966',    null,  5097,   50000, 'CHF',  0,'2001-05-09'  ,    null, null                                ,''                         , null  ,null,      null,  null , null             , 3);
  cmp_firma($sth,  251792, 'Storella GmbH'                                 , 'CH32090204910',  468163,  3251,    null,  null,  2, null         , 5723906, null                                ,'Tiefenackerstrasse'       , '49'  ,null,      null, '9450', 'Altstätten'     , 9);
  cmp_firma($sth,  451407, 'ADP Analyse Design Planung AG'                 , 'CH02040197464',    null,   261,  100000, 'CHF',  2, null         , 3242819, null                                ,'Glatttalstrasse'          ,'104 h',null,      null, '8052', 'Zürich'         , 3);
  cmp_firma($sth,  468163, 'Storella Sagl'                                 , 'CH50940068681',    null,  5097,   50000, 'CHF',  2, null         , 2942553, null                                ,'Via Gabbietta'            ,  '3'  ,null,      null, '6614', 'Brissago'       , 4);
  cmp_firma($sth,  712087, 'Varian Medical Systems Imaging Laboratory GmbH', 'CH40040245074',    null,  4021, 2000000, 'CHF',  2, null         , 2185269, null                                ,'Täfernstrasse'            ,  '7'  ,null,      null, '5405', 'Baden-Dättwil'  , 4);
  cmp_firma($sth,  728139, 'Volltext Lienert'                              , 'CH02010440290',    null,   155,    null, null ,  2, null         , 6180656, null                                ,'Bahnhofstrasse'           , '14'  ,null,      null, '8708', 'Männedorf'      , 1);
  cmp_firma($sth,  790603, 'Presenti, Genuss-Hofladen, Ritler'             , 'CH60010123481',    null,  6192,    null, null ,  2, null         , 1091615, null                                ,'Ried'                     , '38'  ,null,      null, '3919', 'Blatten'        , 1);
  cmp_firma($sth,  823465, 'D1 Solutions AG'                               , 'CH02030293815',    null,   261,  100000, 'CHF',  2, null         , 1667155, null                                ,'Zypressenstrasse'         , '71'  ,null,      null, '8004', 'Zürich'         , 3);
  cmp_firma($sth,  934296, 'Akyon AG'                                      , 'CH02030334394',    null,   261,  100000, 'CHF',  2, null         , 3232871,'c/o ADP Analyse Design Planung GmbH','Glatttalstrassse'         ,'104f' ,null,      null, '8052', 'Zürich'         , 3);

  cmp_firma($sth, 1022680, 'Erasols Sàrl'                                  , 'CH64541067320' ,   null,  5749,   20000, 'CHF',  2, null         , 3269925,  null                               ,'Rue de la Cité'           , '21'  , null,     null, '1373', 'Chavornay'      , 4); 
  cmp_firma($sth, 1043245, 'Leo MGE Transports Sàrl'                       , 'CH64541075065' ,   null,  5601,   20000, 'CHF',  2, null         , 3291443,  null                               ,'Chemin de Fleur de Lys'   ,  '1'  , null,     null, '1071', 'Chexbres'       , 4); 
  cmp_firma($sth, 1050881, $zuffrey                                        , 'CH62620141168' ,   null,  6253,    null, null ,  2, null         , 3270557,  null                               ,'Avenue de la Gare'        , '24'  , null, 'CP 433', '3963', 'Crans-Montana'  , 2); 
  cmp_firma($sth, 1263109, 'Grégorio Maïka, SUISSE SABLAGE'                , 'CH62610171082' ,   null,  6253,    null, null ,  2, null         , 3270283, 'c/o Grégorio Maïka'                ,'Rue de la Pavia'          , '46'  , null,     null, '3963', 'Montana Village', 1); 
  cmp_firma($sth, 1268712, 'Pompes Funèbres Daniel Rey et Fils Sàrl'       , 'CH62640171965' ,   null,  6253,   20000, 'CHF',  2, null         , 3270279,  null                               ,'Route de Crans-Montana'   , '24'  , null,     null, '3963', 'Montana'        , 4); 
  cmp_firma($sth, 1271188, 'NOVA LANDO Sagl'                               , 'CH50140213081' ,   null,  5192,   20000, 'CHF',  2, null         , 3269757,  null                               ,'via Francesco Somaini no.',  '5'  , null,     null, '6900', 'Lugano'         , 4); 
  cmp_firma($sth, 1271352, 'Café Restaurant Oliveto Muntoni'               , 'CH62610172445' ,   null,  6253,    null, null ,  2, null         , 3270277,  null                               ,'Place du Marché'          ,  '1'  , null,     null, '3963', 'Crans-Montana'  , 1); 
  cmp_firma($sth, 1271529, 'Jérémie Rey et Fils SA'                        , 'CH62630172077' ,   null,  6253,  200000, 'CHF',  2, null         , 3270275,  null                               ,'Route de Crans-Montana'   , '36'  , null,     null, '3963', 'Crans-Montana'  , 3); 
  cmp_firma($sth, 1279490, 'MetSol AG'                                     , 'CH02030438126' ,   null,    66,  100000, 'CHF',  2, null         , 3268453,  null                               ,'Europa-Strasse'           , '19a' , null,     null, '8152', 'Glattbrugg'     , 3); 
  cmp_firma($sth, 1280835, 'Café de l\'Ouest SA'                           , 'CH62630174341' ,   null,  6253,  100000, 'CHF',  2, null         , 3270271, "c/o $fiduc_crans"                  ,'Rue du Clovelli'          ,  '2'  , null,     null, '3963', 'Crans-Montana'  , 3); 
  cmp_firma($sth, 1282712, 'JUSTIS Sàrl'                                   , 'CH55011703743' ,   null,  5636,   20000, 'CHF',  2, null         , 3269961,  null                               ,'Route de Pallatex'        ,'7 B'  , null,     null, '1163', 'Etoy'           , 4); 
  cmp_firma($sth, 1286613, 'Carcò and Costantino & Co. SNC'                , 'CH03620689137' ,   null,   371,    null, null ,  2, null         , 3268597,  null                               ,'Rue de Büren'             , '82'  , null,     null, '2504', 'Biel/Bienne'    , 2);
  cmp_firma($sth, 1289682, 'MRX CH GmbH'                                   , 'CH02040604036' ,   null,   261,   20000, 'CHF',  2, null         , 3268227, 'c/o Dacuda AG'                     ,'Zollstrasse'              , '62'  , null,     null, '8005', 'Zürich'         , 4);
  cmp_firma($sth, 1290391, 'PUR Luftservice GmbH'                          , 'CH13040238566',    null,  1301,   20000, 'CHF',  2, null         , 3281571, null                                ,'Kornhausstrasse'          , '86'  , null,     null, '8840', 'Einsiedeln'     , 4);
  cmp_firma($sth, 1292466, 'PUR Luftservice GmbH'                          , 'CH02090047847', 1290391,    56,    null, null ,  2, null         , 3315327, null                                ,'Dorfstrasse'              ,'115'  , null,     null, '8424', 'Embrach'        , 9);

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
    throw new Exception("cmp_firma Rechtform $row[17] != $rechtsform, id_firma=$id");
  }

} #_}

function check_firma_bez($dbh) { #_{

  check_count($dbh, 'firma_bez', 43);


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
  cmp_firma_bez($sth,  468163, '940', 2, 'FR',  3, 'Storella GmbH'                                                             , '1999-12-04', '9999-12-31');
  cmp_firma_bez($sth,  712087, '990', 1, 'DE',  3, 'Varian Medical Systems Imaging Laboratory GmbH'                            , '2003-07-03', '9999-12-31');
  cmp_firma_bez($sth,  728139, '990', 1, 'DE',  3, 'Volltext Lienert'                                                          , '2003-11-26', '9999-12-31');
  cmp_firma_bez($sth,  790603, '990', 1, 'DE', -1, 'Presenti, Blumen und Geschenke, Karin Ritler'                              , '2005-05-04', '2011-06-23');
  cmp_firma_bez($sth,  790603, '980', 1, 'DE', -1, 'Presenti, Hofladen, Karin Ritler'                                          , '2011-06-24', '2013-09-23');
  cmp_firma_bez($sth,  790603, '970', 1, 'DE',  3, 'Presenti, Genuss-Hofladen, Ritler'                                         , '2013-09-24', '9999-12-31');
  cmp_firma_bez($sth,  823465, '990', 1, 'DE', -1, 'd1 solutions ag'                                                           , '2005-12-28', '2011-10-31');
  cmp_firma_bez($sth,  823465, '980', 1, 'DE',  3, 'D1 Solutions AG'                                                           , '2011-11-01', '9999-12-31');
  cmp_firma_bez($sth,  934296, '990', 1, 'DE', -1, 'CBC Core Banking Competence Center AG'                                     , '2009-02-02', '2009-11-11');
  cmp_firma_bez($sth,  934296, '980', 1, 'DE',  3, 'Akyon AG'                                                                  , '2009-11-12', '9999-12-31');
  cmp_firma_bez($sth,  934296, '980', 2, 'EN',  3, 'Akyon Ltd.'                                                                , '2009-11-12', '9999-12-31');
  cmp_firma_bez($sth,  934296, '980', 2, 'FR',  3, 'Akyon SA'                                                                  , '2009-11-12', '9999-12-31');

  cmp_firma_bez($sth, 1022680, '990', 1, 'DE', 3, 'Erasols Sàrl'                                                               , '2011-06-10', '9999-12-31');
  cmp_firma_bez($sth, 1043245, '990', 1, 'DE', 3, 'Leo MGE Transports Sàrl'                                                    , '2011-12-21', '9999-12-31');
  cmp_firma_bez($sth, 1050881, '990', 1, 'DE', 3, 'Zufferey Aurélie et Tânia Margarida da Mota Cardoso Kiosque Liberté'        , '2012-02-28', '9999-12-31');
  cmp_firma_bez($sth, 1263109, '990', 1, 'FR', 3, 'Grégorio Maïka, SUISSE SABLAGE'                                             , '2016-05-12', '9999-12-31');
  cmp_firma_bez($sth, 1268712, '990', 1, 'FR', 3, 'Pompes Funèbres Daniel Rey et Fils Sàrl'                                    , '2016-06-28', '9999-12-31');
  cmp_firma_bez($sth, 1271188, '990', 1, 'IT', 3, 'NOVA LANDO Sagl'                                                            , '2016-07-15', '9999-12-31');
  cmp_firma_bez($sth, 1271352, '990', 1, 'FR', 3, 'Café Restaurant Oliveto Muntoni'                                            , '2016-07-18', '9999-12-31');
  cmp_firma_bez($sth, 1271529, '990', 1, 'FR', 3, 'Jérémie Rey et Fils SA'                                                     , '2016-07-19', '9999-12-31');
  cmp_firma_bez($sth, 1279490, '990', 1, 'DE', 3, 'MetSol AG'                                                                  , '2016-10-10', '9999-12-31');
  cmp_firma_bez($sth, 1279490, '990', 2, 'EN', 3, 'MetSol Ltd'                                                                 , '2016-10-10', '9999-12-31');
  cmp_firma_bez($sth, 1279490, '990', 2, 'FR', 3, 'MetSol SA'                                                                  , '2016-10-10', '9999-12-31');
  cmp_firma_bez($sth, 1280835, '990', 1, 'FR', 3, 'Café de l\'Ouest SA'                                                        , '2016-10-21', '9999-12-31');
  cmp_firma_bez($sth, 1282712, '990', 1, 'FR', 3, 'JUSTIS Sàrl'                                                                , '2016-11-09', '9999-12-31');
  cmp_firma_bez($sth, 1282712, '990', 2, 'de', 3, 'JUSTIS GmbH'                                                                , '2016-11-09', '9999-12-31');
  cmp_firma_bez($sth, 1282712, '990', 2, 'en', 3, 'JUSTIS LLC'                                                                 , '2016-11-09', '9999-12-31');
  cmp_firma_bez($sth, 1282712, '990', 2, 'it', 3, 'JUSTIS Sagl'                                                                , '2016-11-09', '9999-12-31');
  cmp_firma_bez($sth, 1286613, '990', 1, 'DE', 3, 'Carcò and Costantino & Co. SNC'                                             , '2016-12-12', '9999-12-31');
  cmp_firma_bez($sth, 1289682, '990', 1, 'DE', 3, 'MRX CH GmbH'                                                                , '2017-01-06', '9999-12-31');
  cmp_firma_bez($sth, 1289682, '990', 2, 'EN', 3, 'MRX CH LLC'                                                                 , '2017-01-06', '9999-12-31');
  cmp_firma_bez($sth, 1289682, '990', 2, 'FR', 3, 'MRX CH Sàrl'                                                                , '2017-01-06', '9999-12-31');


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

  check_count($dbh, 'zweck', 27);

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
  cmp_zweck($sth,  790603, 'Handel mit und Verkauf von Blumen, Geschenken und landwirtschaftlichen Produkten aus der Region und damit zusammenhängende Tätigkeiten sowie Catering.');
  cmp_zweck($sth,  823465, 'Zweck der Gesellschaft ist die Erbringung von Dienstleistungen in den Bereichen Unternehmensberatung, Organisation und Coaching. Die Gesellschaft kann Tochtergesellschaften und Zweigniederlassungen im In- und Ausland errichten, Vertretungen übernehmen und alle Geschäfte eingehen, die den Gesellschaftszweck direkt oder indirekt fördern. Sie kann sich auch an anderen Unternehmungen beteiligen, Darlehen aufnehmen sowie Grundstücke erwerben, verwalten und veräussern.');
  cmp_zweck($sth,  934296, 'Die Gesellschaft bezweckt die Beratung und Schulung von Unternehmen in allen wirtschaftlichen, organisatorischen und technischen Belangen, insbesondere der Analyse, Konzeption, Planung und Projektierung sowie Entwicklung, Lieferung und Unterhalt von IT-Software und Infrastruktur. Die Gesellschaft kann Zweigniederlassungen und Tochtergesellschaften im In- und Ausland errichten und sich an anderen Unternehmen im In- und Ausland beteiligen sowie alle Geschäfte tätigen, die direkt oder indirekt mit ihrem Zweck in Zusammenhang stehen. Die Gesellschaft kann im In- und Ausland Grundeigentum erwerben, belasten, veräussern und verwalten. Sie kann auch Finanzierungen für eigene oder fremde Rechnung vornehmen sowie Garantien und Bürgschaften für Tochtergesellschaften und Dritte eingehen.');


  cmp_zweck($sth, 1022680, 'Commerce de parquets, revêtements de sols, lambris et accessoires pour l\'aménagement intérieur et extérieur (pour but complet, cf. statuts).');
  cmp_zweck($sth, 1043245, 'Transports suisses et internationaux; entreposage, conditionnement, manutention de tous objets et marchandises; logistique, dédouannement; et autres moyens et dispositifs de transport (pour but complet, cf. statuts).');
  cmp_zweck($sth, 1050881, 'L\'exploitation d\'un kiosque');
  cmp_zweck($sth, 1263109, 'Sablage, décapage, aérogommage');
  cmp_zweck($sth, 1268712, 'L\'exploitation d\'une entreprise de services funèbres (cf. statuts pour but complet)');
  cmp_zweck($sth, 1271188, 'La fornitura di prestazioni, servizi e consulenza, segnatamente nel settore del marketing e dello sviluppo di business. Trading ed intermediazione in genere. Lo studio, lo sviluppo e la commercializzazione di soluzioni informatiche e di nuove tecnologie ITC. La società può creare filiali e/o succursali sia in Svizzera che all\'estero nonché partecipare a qualsiasi attività commerciale in Svizzera o all\'estero. Essa potrà compiere tutte le operazioni commerciali, industriali, finanziarie, mobiliari ed immobiliari direttamente od indirettamente connesse con lo scopo sociale nonché assumere interessenze e partecipazioni in altre imprese sia in Svizzera che all\'estero.');
  cmp_zweck($sth, 1271352, 'Exploitation d\'un café-restaurant');
  cmp_zweck($sth, 1271529, 'L\'exploitation d\'une entreprise de serrurerie, fers forgés, constructions métalliques (cf. statuts pour but complet)');
  cmp_zweck($sth, 1279490, 'Zweck der Gesellschaft ist die Entwicklung, die Herstellung und der Vertrieb von Komponenten und Systemen zur Reduktion des Energieverbrauchs bei der Herstellung von Primäraluminium sowie die Erbringung von damit zusammenhängenden Dienstleistungen. Die Gesellschaft kann Zweigniederlassungen in der Schweiz und im Ausland errichten, sich an anderen Unternehmungen des In- und des Auslandes beteiligen, gleichartige oder verwandte Unternehmen erwerben oder sich mit solchen zusammenschliessen sowie alle Geschäfte eingehen und Verträge abschliessen, die geeignet sind, den Zweck der Gesellschaft zu fördern oder die direkt oder indirekt damit im Zusammenhang stehen. Sie kann Grundstücke, Immaterialgüterrechte und Lizenzen aller Art erwerben, verwalten, belasten und veräussern.');
  cmp_zweck($sth, 1280835, 'L\'exploitation, y compris la location, de cafés, restaurants, dancings, discothèques, salles de jeux et autres établissements publics (cf. statuts pour but complet)');
  cmp_zweck($sth, 1282712, 'la société a pour but la distrubution, la gestion et l\'administration d\'assurances, produits, prestations et services en relation avec le domaine de la protection juridique, de l\'accès au droit, de la défense des droits individuels et collectifs, ainsi qu\'avec le renseignement et le conseil juridiques (pour but complet cf. statuts).');
  cmp_zweck($sth, 1286613, 'La société a pour but la gérance, l\'achat, la vente d\'immeubles et la mise à disposition de locaux à des personnes indépendantes.');
  cmp_zweck($sth, 1289682, 'Die Gesellschaft bezweckt die Forschung und Entwicklung von Software- und Hardwarelösungen, deren Vertrieb sowie das Anbieten anderer Dienstleistungen im Zusammenhang mit der erwähnten Tätigkeit. Die Gesellschaft kann überdies alle kommerziellen, finanziellen oder anderen Geschäfte tätigen, die geeignet sind, den Zweck der Gesellschaft zu fördern. Die Gesellschaft kann Zweigniederlassungen und Tochtergesellschaften im In- und Ausland errichten. Sie kann sich an anderen Gesellschaften im In- und Ausland beteiligen. Die Gesellschaft kann Immaterialgüterrechte erwerben, verkaufen, verwalten, gestalten, entwickeln, verwerten und lizenzieren. Die Gesellschaft kann nahestehenden Gesellschaften, d.h. direkten oder indirekten Tochtergesellschaften, direkten oder indirekten Schwestergesellschaften, oder direkten oder indirekten Muttergesellschaften, Finanzierungen und ähnliche Leistungen gewähren, sei es mittels Darlehen, Vorschüssen, Garantien oder anderen Sicherheiten jeglicher Art, ob gegen Entgelt oder nicht.');
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

  $gs='Gesellschafter';
  $vors='Vorsitzender';
  $praes='Präsident';
  $gf='Geschäftsführung';
  $vrs='Verwaltungsrates';
  $gfr='Geschäftsführer';
  $del='Delegierter';
  $gs_gf="Gesellschafter und Geschäftsführer";
  $gl_mg="Mitglied der Geschäftsleitung";
  $vr_mg="Mitglied des Verwaltungsrates";
  $rev='Revisionsstelle';
  $inh='Inhaber';
  $inhin='Inhaberin';

  $eu='mit Einzelunterschrift';
  $ku2='mit Kollektivunterschrift zu zweien';
  $kp2='mit Kollektivprokura zu zweien';
  $sig_inv='avec signature individuelle';
  $sig_c2='avec signature collective à deux';
  
  $varian='Varian Medical Systems International AG';
  $tro_typo='TRO Teuhand & Revisions AG (<M>CHE107.909.432<E>)';
  $ortag='Ortag, Organisations-, Revisions- und Treuhand-AG';
  $luech_com_alt='Lüchingen (comune Altstätten)';
  $fabien = 'François Fabien, dit Fabien';
  $jeremie= 'Jean Vincent Jérémie, dit Jérémie';
  $new_horiz = 'NEW HORIZON MANAGEMENT SA (<M>CHE342.773.049<E>)';
  $das_rechts = 'DAS Rechtsschutz-Versicherungs-AG (<M>CHE106.111.319<E>)';

  $stang = 'Staatsangehörige';
  $stangr = 'Staatsangehöriger';

  check_count($dbh, 'person_firma', 126);
  $sth = db_prep_exec($dbh, 'select * from person_firma order by dt_journal, id_firma');

  $cnt=1;

  cmp_person_firma($sth, $cnt++, 468163   ,'2001-01-23'  ,'-'  ,'Dettwiler'        ,'Werner'           ,'Reigoldswil'                         ,NULL                                        ,'Eichberg'                  ,'socio e gerente'                            , 'con firma individuale'                               , 'con una quota da CHF 1\'000.--'                       ); #_{
  cmp_person_firma($sth, $cnt++, 468163   ,'2001-01-23'  ,'+'  ,'Wüst'             ,'Günter'           ,'Oberriet SG'                         , null                                       ,$luech_com_alt              ,'socio e gerente'                            , 'con firma individuale'                               , 'con una quota da CHF 1\'000.--'                       );
  cmp_person_firma($sth, $cnt++, 251792   ,'2001-07-30'  ,'-'  ,'Dettwiler'        ,'Werner'           ,'Reigoldswil'                         ,NULL                                        ,'Eichberg'                  ,$gs_gf                                       , 'mit Einzelunterschrift'                              ,  NULL                                                  );
  cmp_person_firma($sth, $cnt++, 251792   ,'2001-07-30'  ,'+'  ,'Wüst'             ,'Günter'           ,'Oberriet SG'                         ,NULL                                        ,'Lüchingen (Altstätten)'    ,$gs_gf                                       , 'mit Einzelunterschrift'                              ,  NULL                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2002-04-30'  ,'+'  ,'Huber'            ,'Marcel'           ,'Eschenbach LU'                       ,NULL                                        ,'Eschenbach LU'             ,'Kassier'                                    ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2003-06-30'  ,'+'  , null              , null              , null                                 ,$varian                                     ,'Zug'                       ,'Gesellschafterin'                           , 'ohne Zeichnungsberechtigung'                         , 'mit einer Stammeinlage von CHF 1\'999\'000.--'        );
  cmp_person_firma($sth, $cnt++, 712087   ,'2003-06-30'  ,'+'  ,'Oderbolz'         ,'Fritz'            ,'Tübach'                              , null                                       ,'Hünenberg'                 ,'Gesellschafter'                             , 'ohne Zeichnungsberechtigung'                         , 'mit einer Stammeinlage von CHF 1\'000.--'             );
  cmp_person_firma($sth, $cnt++, 712087   ,'2003-06-30'  ,'+'  ,'Vogt'             ,'Heinz'            ,'Lauwil'                              , null                                       ,'Baldingen'                 ,'Geschäftsführer'                            , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2003-06-30'  ,'+'  , null              , null              , null                                 ,'PricewaterhouseCoopers AG'                 ,'Zürich'                    ,'Revisionsstelle'                            ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 728139   ,'2003-11-20'  ,'+'  ,'Lienert'          ,'Joachim Georg'    ,'Einsiedeln'                          , null                                       ,'Elsau'                     ,$inh                                         , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 790603   ,'2005-04-29'  ,'+'  ,'Ritler-Faisthuber','Karin'            ,"österreichische $stang"              , null                                       ,'Blatten'                   ,$inhin                                       ,$eu                                                    ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'-'  ,'Sidler'           ,'Ruth'             ,'Rifferswil und Luzern'               , null                                       ,'Affoltern a.A.'            ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'-'  ,'Messerli'         ,'Rudolf'           ,'Rüeggisberg'                         , null                                       ,'Oberwil BL'                ,'Präsident'                                  ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'-'  ,'Dellagiacoma'     ,'Marlis'           ,'Kriens und Uster'                    , null                                       ,'Kriens'                    ,'Aktuarin'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'-'  ,'Vogel-Ruffieux'   ,'Vreni'            ,'Oberurnen'                           , null                                       ,'Allschwil'                 ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Metzger'          ,'Caroline'         ,'Möhlin'                              , null                                       ,'Gossau SG'                 ,'Aktuarin'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Martin'           ,'Stefan'           ,'Pratteln'                            , null                                       ,'Olten'                     ,'Präsident'                                  ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Huber'            ,'Marcel'           ,'Eschenbach LU'                       , null                                       ,'Zug'                       ,'Kassier'                                    ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Jebelean'         ,'Ioan'             ,'Luzern'                              , null                                       ,'Luzern'                    ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2005-06-09'  ,'+'  ,'Vogel'            ,'Andres'           ,'Oberurnen'                           , null                                       ,'Allschwil'                 ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2005-07-04'  ,'-'  ,NULL               ,NULL               ,NULL                                  ,'Künzler Communications GmbH'               ,'Bassersdorf'               ,'Gesellschafterin'                           , 'ohne Zeichnungsberechtigung'                         , 'mit einer Stammeinlage von CHF 1\'000.--'             );
  cmp_person_firma($sth, $cnt++, 451407   ,'2005-07-04'  ,'+'  ,'Nyffenegger'      ,'René'             ,'Eriswil'                             ,NULL                                        ,'Zürich'                    ,$gs_gf                                       , 'mit Einzelunterschrift'                              , 'mit einer Stammeinlage von CHF 20\'000.--'            );
  cmp_person_firma($sth, $cnt++, 823465   ,'2005-12-22'  ,'+'  ,'Rossbacher'       ,'Albert'           ,'Röthenbach bei Herzogenbuchsee'      ,NULL                                        ,'Herrliberg'                ,'Mitglied'                                   , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2005-12-22'  ,'+'  ,NULL               ,NULL               ,NULL                                  ,$ortag                                      ,'Zürich'                    ,'Revisionsstelle'                            ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2006-05-16'  ,'-'  ,'Rossbacher'       ,'Albert'           ,'Röthenbach bei Herzogenbuchsee'      ,NULL                                        ,'Herrliberg'                ,'Mitglied'                                   , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2006-05-16'  ,'+'  ,'Hagger'           ,'Joachim Andreas'  ,'Basel'                               ,NULL                                        ,'Zürich'                    ,'Präsident'                                  ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2006-05-16'  ,'+'  ,'Gränicher'        ,'Hans Peter'       ,'Röthenbach bei Herzogenbuchsee'      ,NULL                                        ,'Zürich'                    ,'Mitglied'                                   ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2006-05-16'  ,'+'  ,'Hefti'            ,'Simon'            ,'Thun'                                ,NULL                                        ,'Zürich'                    ,'Mitglied'                                   ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2007-02-13'  ,'+'  ,'Oderbolz'         ,'Fritz'            ,'Tübach'                              , null                                       ,'Hünenberg'                 ,'Gesellschafter'                             ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2007-02-13'  ,'+'  , null              , null              , null                                 ,$varian                                     ,'Zug'                       ,'Gesellschafterin'                           ,'ohne Zeichnungsberechtigung'                          , 'mit einer Stammeinlage von CHF 2\'000\'000.--'        );
  cmp_person_firma($sth, $cnt++, 712087   ,'2007-02-13'  ,'+'  ,'Amstutz'          ,'Martin'           ,'Engelberg'                           , null                                       ,'Döttingen'                 , null                                        ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2007-02-13'  ,'+'  ,'Hauri'            ,'Reto'             ,'Niederlenz'                          , null                                       ,'Gränichen'                 , null                                        ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2007-02-20'  ,'+'  ,'Oderbolz'         ,'Fritz'            ,'Tübach'                              , null                                       ,'Hünenberg'                 , null                                        ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2007-05-07'  ,'+'  ,'Ginnow'           ,'Richard'          ,'Volketswil'                          ,NULL                                        ,'Rüschlikon'                ,$gs_gf                                       ,$ku2                                                   , 'mit einer Stammeinlage von CHF 10\'000.--'            );
  cmp_person_firma($sth, $cnt++, 451407   ,'2007-05-07'  ,'+'  ,'Nyffenegger'      ,'René'             ,'Eriswil'                             ,NULL                                        ,'Zürich'                    ,$gs_gf                                       ,$ku2                                                   , 'mit einer Stammeinlage von CHF 10\'000.--'            );
  cmp_person_firma($sth, $cnt++, 451407   ,'2008-09-08'  ,'-'  ,'Nyffenegger'      ,'René'             ,'Eriswil'                             ,NULL                                        ,'Zürich'                    ,$gs_gf                                       ,$ku2                                                   , 'mit einem Stammanteil von CHF 10\'000.00'             );
  cmp_person_firma($sth, $cnt++, 451407   ,'2008-09-08'  ,'+'  ,'Ginnow'           ,'Richard'          ,'Volketswil'                          ,NULL                                        ,'Rüschlikon'                ,$gs_gf                                       , 'mit Einzelunterschrift'                              , 'mit 200 Stammanteilen zu je CHF 100.00'               );
  cmp_person_firma($sth, $cnt++, 451407   ,'2008-09-08'  ,'+'  ,'Weber'            ,'Melanie'          ,'Gränichen'                           ,NULL                                        ,'Zell ZH'                   , null                                        , 'mit Einzelprokura'                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2008-11-04'  ,'-'  ,'Vogt'             ,'Heinz'            ,'Lauwil'                              , null                                       ,'Baldingen'                 ,'Geschäftsführer'                            , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2008-11-04'  ,'+'  ,'Oderbolz'         ,'Fritz'            ,'Tübach'                              , null                                       ,'Hünenberg'                 ,"$gs und $vors der $gf"                      ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2008-11-04'  ,'+'  ,'Amstutz'          ,'Martin'           ,'Engelberg'                           , null                                       ,'Döttingen'                 , $gfr                                        ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2008-11-12'  ,'+'  ,'Oderbolz'         ,'Fritz'            ,'Tübach'                              , null                                       ,'Hünenberg'                 ,"$vors der $gf"                              ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-01-28'  ,'+'  ,'Ginnow'           ,'Richard'          ,'Volketswil'                          ,NULL                                        ,'Mettmenstetten'            ,'Präsident des Verwaltungsrates'             , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-01-28'  ,'+'  ,'Kuhn'             ,'Roland'           ,'Illnau-Effretikon'                   ,NULL                                        ,'St. Gallen'                ,$vr_mg                                       , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2009-07-17'  ,'-'   ,'Bürgin'          ,'Werner'           ,'Basel'                               , null                                       ,'Basel'                     ,'Mitglied'                                   ,'ohne Zeichnungsberechtigung'                          , null                                                   );
  cmp_person_firma($sth, $cnt++, 150042   ,'2009-07-17'  ,'+'   ,'Abry'            ,'Pierre'           ,'Weggis'                              , null                                       ,'Weggis'                    ,'Mitglied'                                   ,'ohne Zeichnungsberechtigung'                          , null                                                   );
  cmp_person_firma($sth, $cnt++, 150042   ,'2009-07-17'  ,'+'   ,'Huber'           ,'Marcel'           ,'Eschenbach LU'                       , null                                       ,'Eschenbach LU'             ,'Kassier'                                    ,$ku2                                                   , null                                                   );
  cmp_person_firma($sth, $cnt++, 150042   ,'2009-07-17'  ,'+'   ,'Metzger'         ,'Caroline'         ,'Möhlin'                              , null                                       ,'Uster'                     ,'Aktuarin'                                   ,'ohne Zeichnungsberechtigung'                          , null                                                   );
  cmp_person_firma($sth, $cnt++,  76284   ,'2009-10-26'  ,'-'  , null              , null              , null                                 ,'Fiduciaire Jean-Maurice Maitre S.A.'       ,'Porrentruy'                ,'organe de révision'                         ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++,  76284   ,'2009-10-26'  ,'+'  , null              , null              , null                                 ,'RéviAjoie Sàrl'                            ,'Porrentruy'                ,'organe de révision'                         ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Ginnow'           ,'Richard'          ,'Volketswil'                          ,NULL                                        ,'Mettmenstetten'            ,'Präsident des Verwaltungsrates'             ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Kuhn'             ,'Roland'           ,'Illnau-Effretikon'                   ,NULL                                        ,'St. Gallen'                ,$vr_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Norgate'          ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                        ,'Freienbach'                ,$gl_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Keller'           ,'Primin'           ,'Altendorf'                           ,NULL                                        ,'Waldkirch'                 ,$gl_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2009-11-06'  ,'+'  ,'Weber'            ,'Melanie'          ,'Gränichen'                           ,NULL                                        ,'Zell ZH'                   , null                                        , 'mit Einzelprokura'                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2009-12-03'  ,'+'  ,'Ginnow'           ,'Richard'          ,'Volketswil'                          ,NULL                                        ,'Mettmenstetten'            ,$gs_gf                                       , 'mit Einzelunterschrift'                              , 'mit 170 Stammanteilen zu je CHF 100.00'               );
  cmp_person_firma($sth, $cnt++, 451407   ,'2009-12-03'  ,'+'  ,'Norgate'          ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                        ,'Freienbach'                ,'Gesellschafter'                             ,$ku2                                                   , 'mit 30 Stammanteilen zu je CHF 100.00'                );
  cmp_person_firma($sth, $cnt++, 251792   ,'2010-07-07'  ,'-'  ,'Riedmüller'       ,'Josef'            ,'deutscher Staatsangehöriger'         ,NULL                                        ,'Biberach an der Riss (D)'  ,$gs_gf                                       , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 251792   ,'2010-07-07'  ,'-'  ,'Wüst'             ,'Günter'           ,'Oberriet SG'                         ,NULL                                        ,'Lüchingen (Altstätten)'    ,$gs_gf                                       , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 728139   ,'2011-05-23'  ,'+'  ,'Lienert'          ,'Joachim Georg'    ,'Einsiedeln'                          , null                                       ,'Stäfa'                     ,$inh                                         , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2011-10-27'  ,'+'  ,'Hefti'            ,'Simon'            ,'Thun'                                ,NULL                                        ,'Zürich'                    ,'Präsident des Verwaltungsrates'             ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2011-10-27'  ,'+'  ,'Hagger'           ,'Joachim Andreas'  ,'Basel'                               ,NULL                                        ,'Zürich'                    ,$vr_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2011-10-27'  ,'+'  ,'Vckovski'         ,'Andrej'           ,'Zürich'                              ,NULL                                        ,'Zürich'                    ,$vr_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2011-10-27'  ,'+'  ,'Gränicher'        ,'Hans Peter'       ,'Röthenbach bei Herzogenbuchsee'      ,NULL                                        ,'Zürich'                    ,'Geschäftsführer'                            ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2012-04-27'  ,'-'  ,'Bolliger'         ,'Walter'           ,'Basel'                               ,null                                        ,'Magden'                    ,'Vizepräsident'                              ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2012-04-27'  ,'+'  ,'Schmid'           ,'Thomas'           ,'Kaiseraugst'                         ,null                                        ,'Sarnen'                    ,'Vizepräsident'                              ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2012-04-27'  ,'+'  ,'Martin-Metzger'   ,'Caroline'         ,'Möhlin und Pratteln'                 ,null                                        ,'Uster'                     ,'Aktuarin'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2012-12-05'  ,'+'  ,'Brabec'           ,'Dr. Bernhard'     ,'österreichischer Staatsangehöriger'  ,NULL                                        ,'Zollikon'                  , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2012-12-05'  ,'+'  ,'Rutz'             ,'Candid'           ,'Emmen'                               ,NULL                                        ,'Zürich'                    , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2012-12-05'  ,'+'  ,'Hausmann'         ,'Alexander'        ,'Dietikon'                            ,NULL                                        ,'Dietikon'                  , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2012-12-05'  ,'+'  ,'Stefanakos'       ,'Stamatios'        ,'griechischer Staatsangehöriger'      ,NULL                                        ,'Zürich'                    , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2013-01-21'  ,'-'  ,'Amstutz'          ,'Martin'           ,'Engelberg'                           , null                                       ,'Döttingen'                 , $gfr                                        ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2013-01-21'  ,'-'  ,'Oderbolz'         ,'Fritz'            ,'Tübach'                              , null                                       ,'Hünenberg'                 ,"$vors der $gf"                              ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2013-01-21'  ,'+'  ,'Fässler'          ,'Jörg'             ,'Arth'                                , null                                       ,'Baar'                      ,"$vors der $gf"                              ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2013-01-21'  ,'+'  ,'Kunz'             ,'Patrik'           ,'Reinach BL'                          , null                                       ,'Baden'                     , $gfr                                        ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2013-01-21'  ,'+'  ,'Balmer'           ,'Ralph'            ,'Wilderswil'                          , null                                       ,'Bern'                      , null                                        ,$kp2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2013-07-29'  ,'-'  ,'Brabec'           ,'Dr. Bernhard'     ,'österreichischer Staatsangehöriger'  ,NULL                                        ,'Zollikon'                  , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2013-07-29'  ,'-'  ,'Hausmann'         ,'Alexander'        ,'Dietikon'                            ,NULL                                        ,'Dietikon'                  , null                                        , 'mit Kollektivprokura zu zweien'                      ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2013-07-29'  ,'+'  ,NULL               ,NULL               ,NULL                                  ,'ORTAG AG'                                  ,'Zürich'                    ,'Revisionsstelle'                            ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2013-08-28'  ,'+'  , null              , null              , null                                 ,$tro_typo                                   ,'Olten'                     ,'Revisionsstelle'                            ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2014-02-24'  ,'-'  ,'Balmer'           ,'Ralph'            ,'Wilderswil'                          , null                                       ,'Bern'                      , null                                        ,$kp2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2014-02-24'  ,'+'  ,'Cavallari'        ,'Mario'            ,'Alpnach'                             , null                                       ,'Alpnach'                   , null                                        ,$kp2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2014-02-24'  ,'+'  ,'Hauri'            ,'Reto'             ,'Niederlenz'                          , null                                       ,'Gränichen'                 , null                                        ,$kp2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2014-06-02'  ,'-'  ,'Cavallari'        ,'Mario'            ,'Alpnach'                             , null                                       ,'Alpnach'                   , null                                        ,$kp2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2014-08-13'  ,'-'  ,'Hagger'           ,'Joachim Andreas'  ,'Basel'                               ,NULL                                        ,'Zürich'                    ,$vr_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 823465   ,'2014-08-13'  ,'+'  ,'Franz'            ,'Mike'             ,'Frick'                               ,NULL                                        ,'Gipf-Oberfrick'            ,$vr_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2014-09-26'  ,'+'  ,'Hübner'           ,'Ernst'            ,'deutscher Staatsangehöriger'         , null                                       ,'Ingenbohl'                 , null                                        ,$kp2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 712087   ,'2015-05-29'  ,'-'  ,'Hauri'            ,'Reto'             ,'Niederlenz'                          , null                                       ,'Gränichen'                 , null                                        ,$kp2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++,1263109   ,'2016-05-10'  ,'+'  ,'Maïka'            ,'Grégorio'         ,'ressortissant français'              , null                                       ,'Montana'                   ,'titulaire'                                  ,'avec signature individuelle'                          ,  null                                                  );
  cmp_person_firma($sth, $cnt++,1268712   ,'2016-06-24'  ,'+'  ,'Rey'              ,$fabien            ,'Montana'                             , null                                       ,'Montana'                   ,'associé et gérant'                          ,'avec signature individuelle'                          , 'pour 200 parts sociales de CHF 100.00'                );
  cmp_person_firma($sth, $cnt++, 468163   ,'2016-07-05'  ,'+'  ,'Riedmüller'       ,'Josef'            ,'cittadino germanico'                 ,NULL                                        ,'Brissago'                  ,'socio e gerente'                            ,'con firma individuale'                                , 'con 1 quota da CHF 49\'000.00'                        );
  cmp_person_firma($sth, $cnt++, 1271188  ,'2016-07-13'  ,'+'  , null              , null              , null                                 , $new_horiz                                 ,'Lugano'                    ,'socia'                                      , null                                                  ,'con 102 quote da CHF 100.00'                           );
  cmp_person_firma($sth, $cnt++, 1271188  ,'2016-07-13'  ,'+'  ,'Jurkovic'         ,'Antonio'          ,'cittadino italiano'                  , null                                       ,'Lagos Island (NG)'         ,'socio'                                      ,'senza diritto di firma'                               ,'con 58 quote da CHF 100.00'                            );
  cmp_person_firma($sth, $cnt++, 1271188  ,'2016-07-13'  ,'+'  ,'Jurkovic'         ,'Nicola'           ,'cittadino italiano'                  , null                                       ,'Lecco (IT)'                ,'socio'                                      ,'senza diritto di firma'                               ,'con 40 quote da CHF 100.00'                            );
  cmp_person_firma($sth, $cnt++, 1271188  ,'2016-07-13'  ,'+'  ,'Pumilia'          ,'Alessandro'       ,'cittadino italiano'                  , null                                       ,'Viganello (Lugano)'        ,'gerente'                                    , null                                                  , null                                                   );
  cmp_person_firma($sth, $cnt++,1271352   ,'2016-07-14'  ,'+'  ,'Muntoni'          ,'Federico'         ,'Randogne'                            , null                                       ,'Montana'                   ,'titulaire'                                  ,$sig_inv                                               ,  null                                                  );
  cmp_person_firma($sth, $cnt++,1271529   ,'2016-07-15'  ,'+'  ,'Rey'              ,$jeremie           ,'Montana'                             , null                                       ,'Montana'                   ,'président'                                  ,$sig_inv                                               ,  null                                                  ); 
  cmp_person_firma($sth, $cnt++,1271529   ,'2016-07-15'  ,'+'  ,'Rey'              ,'Jean Vincent'     ,'Montana'                             , null                                       ,'Montana'                   ,'administrateur et secrétaire'               ,$sig_inv                                               ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-10-04'  ,'+'  ,'Ginnow'           ,'Richard'          ,'Volketswil'                          ,NULL                                        ,'Mettmenstetten'            ,"$gs und Vorsitzender der $gf"               , 'mit Einzelunterschrift'                              , 'mit 188 Stammanteilen zu je CHF 100.00'               );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-10-04'  ,'+'  ,'Norgate'          ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                        ,'Freienbach'                ,$gs_gf                                       , 'mit Einzelunterschrift'                              , 'mit 12 Stammanteilen zu je CHF 100.00'                );
  cmp_person_firma($sth, $cnt++, 1279490  ,'2016-10-06'  ,'+'  ,'Schwarz'          ,'Andreas Christian','Weinfelden'                          , null                                       ,'Fällanden'                 ,"$praes des $vrs"                            ,$eu                                                    ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 1279490  ,'2016-10-06'  ,'+'  ,'Kazadi'           ,'Joe'              ,"amerikanischer $stangr"              , null                                       ,'Poolesville (MD/US)'       ,"$del des $vrs und $gfr"                     ,$eu                                                    ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 1280835  ,'2016-10-19'  ,'+'  ,'Cordonier'        ,'Georges Elie'     ,'Montana'                             , null                                       ,'Martigny'                  ,'président'                                  ,$sig_c2                                                ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 1280835  ,'2016-10-19'  ,'+'  ,'Cordonier'        ,'Patrick Christian','Montana'                             , null                                       ,'Montana'                   ,'administrateur'                             ,$sig_c2                                                ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 1280835  ,'2016-10-19'  ,'+'  ,'Cordonier'        ,'Denis Dominique'  ,'Montana'                             , null                                       ,'Montana'                   ,'administrateur'                             ,$sig_c2                                                ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 1280835  ,'2016-10-19'  ,'+'  ,'Cordonier'        ,'Gratien Benoît'   ,'Montana'                             , null                                       ,'Montana'                   ,'administrateur'                             ,$sig_c2                                                ,  null                                                  );

  cmp_person_firma($sth, $cnt++, 1282712  ,'2016-11-07'  ,'+'  , null              , null              , null                                 ,$das_rechts                                 ,'Lucerne'                   ,'Associée'                                   , null                                                  , 'avec 20 parts de CHF 1\'000'                          );
  cmp_person_firma($sth, $cnt++, 1282712  ,'2016-11-07'  ,'+'  ,'Allemann'         ,'Kim'              ,'Berne'                               , null                                       ,'Wiedlisbach'               ,'gérant'                                     , null                                                  ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 1282712  ,'2016-11-07'  ,'+'  ,'Burkhalter'       ,'Karin'            ,'Vuisternens-dev-Romont'              , null                                       ,'Walperswil'                ,'présidente et gérante'                      , null                                                  ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 1282712  ,'2016-11-07'  ,'+'  ,'Gösele'           ,'Roger'            ,'Zandvoort (Pays-Bas)'                , null                                       ,'Sursee'                    ,'gérant'                                     , null                                                  ,  null                                                  );

  cmp_person_firma($sth, $cnt++, 934296   ,'2016-12-15'  ,'-'  ,'Kuhn'             ,'Roland'           ,'Illnau-Effretikon'                   ,NULL                                        ,'St. Gallen'                ,$vr_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2016-12-15'  ,'-'  ,'Keller'           ,'Primin'           ,'Altendorf'                           ,NULL                                        ,'Waldkirch'                 ,$gl_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 934296   ,'2016-12-15'  ,'+'  ,'Norgate'          ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                        ,'Freienbach'                ,$vr_mg                                       ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-12-20'  ,'+'  ,'Ginnow'           ,'Richard'          ,'Volketswil'                          ,NULL                                        ,'Mettmenstetten'            ,'Präsident des Verwaltungsrates'             , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-12-20'  ,'+'  ,'Norgate'          ,'Thomas Aylwin'    ,'britischer Staatsangehöriger'        ,NULL                                        ,'Freienbach'                ,$vr_mg                                       , 'mit Einzelunterschrift'                              ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 451407   ,'2016-12-20'  ,'+'  ,'Büetiger'         ,'Jan'              ,'Schnottwil'                          ,NULL                                        ,'Gossau ZH'                 , null                                        ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 74461    ,'2016-12-28'  ,'-'  , null              , null              , null                                 ,'Fidea SA'                                  ,'Chiasso'                   , null                                        ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'-'  ,'Martin-Metzger'   ,'Caroline'         ,'Pratteln und Möhlin'                 ,null                                        ,'Uster'                     ,'Aktuarin'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'-'  ,'Schmid'           ,'Thomas'           ,'Kaiseraugst'                         ,null                                        ,'Sarnen'                    ,'Vizepräsident'                              ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'-'  ,'Jebelean'         ,'Ioan'             ,'Luzern'                              ,null                                        ,'Luzern'                    ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'-'  ,'Vogel'            ,'Andres'           ,'Oberurnen'                           ,null                                        ,'Allschwil'                 ,'Mitglied'                                   , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'+'  ,'Hostettler'       ,'Martin'           ,'Schwarzenburg'                       ,null                                        ,'Gerlafingen'               ,'Mitglied der Verwaltung'                    ,$ku2                                                   ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'+'  ,'Simpson'          ,'Lars'             ,'Schönenwerd'                         ,null                                        ,'Zürich'                    ,'Mitglied der Verwaltung'                    , 'ohne Zeichnungsberechtigung'                         ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 150042   ,'2016-12-29'  ,'+'  , null              , null              , null                                 ,'Solidis Treuhand AG (<M>CHE107.909.432<E>)','Olten'                     , $rev                                        ,  null                                                 ,  null                                                  );
  cmp_person_firma($sth, $cnt++, 1290391  ,'2017-01-10'  ,'+'  ,'Oesch'            ,'Severin'          ,'Embrach'                             ,NULL                                        ,'Kloten'                    ,$gs_gf                                       ,$ku2                                                   , 'mit 10 Stammanteilen zu je CHF 1\'000.00'             );
  cmp_person_firma($sth, $cnt++, 1290391  ,'2017-01-10'  ,'+'  ,'Grätzer'          ,'Adrian Willy'     ,'Einsiedeln'                          ,NULL                                        ,'Einsiedeln'                ,"$gs und Vorsitzender der $gf"               ,$ku2                                                   , 'mit 10 Stammanteilen zu je CHF 1\'000.00'             ); #_}

  echo "person_firma ok\n";

} #_}

function cmp_person_firma($sth, $cnt, $id_firma, $dt_journal, $add_rm, $nachname, $vorname, $von, $bezeichnung, $in_,  #_{
  $funktion, $zeichnung, $stammeinlage) {

  $row = $sth -> fetch();

  if (! eq($row[ 0], $id_firma        )) {throw new Exception("cmp_person_firma (cnt = $cnt) id_firma differs row[0] = $row[0] but $id_firma expected row[1]=$row[1]  dtJournal=$dt_journal"); }
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

  check_count($dbh, 'gemeinde', 18);

  $sth = db_prep_exec($dbh, 'select * from gemeinde order by id', array());
  cmp_gemeinde($sth,   56, 'Embrach'            );
  cmp_gemeinde($sth,   66, 'Opfikon'            );
  cmp_gemeinde($sth,  155, 'Männedorf'          );
  cmp_gemeinde($sth,  261, 'Zürich'             );
  cmp_gemeinde($sth,  371, 'Biel/Bienne'        );
  cmp_gemeinde($sth, 1301, 'Einsiedeln'         );
  cmp_gemeinde($sth, 1403, 'Giswil'             );
  cmp_gemeinde($sth, 3251, 'Altstätten'         );
  cmp_gemeinde($sth, 4021, 'Baden'              );
  cmp_gemeinde($sth, 5097, 'Brissago'           );
  cmp_gemeinde($sth, 5192, 'Lugano'             );
  cmp_gemeinde($sth, 5250, 'Chiasso'            );
  cmp_gemeinde($sth, 5601, 'Chexbres'           );
  cmp_gemeinde($sth, 5636, 'Etoy'               );
  cmp_gemeinde($sth, 5749, 'Chavornay'          );
  cmp_gemeinde($sth, 6192, 'Blatten'            );
  cmp_gemeinde($sth, 6253, 'Crans-Montana'      );
  cmp_gemeinde($sth, 6800, 'Porrentruy'         );

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
