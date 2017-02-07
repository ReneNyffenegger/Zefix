<?php

include (getenv('github_root') . 'Zefix/web/php/db.php');

$dbh = db_connect('dev');


$cnt_firma      = db_cnt_table($dbh, 'firma');
$cnt_zweck      = db_cnt_table($dbh, 'zweck');
$cnt_firma_bez  = db_cnt_table($dbh, 'firma_bez');


printf("Firmen: %8d\n", $cnt_firma    );
printf("Zwecke: %8d\n", $cnt_zweck    );
printf("   bez: %8d\n", $cnt_firma_bez);

if ($cnt_firma != $cnt_zweck) {
  throw new Exception("cnt_firma != cnt_zweck");
}
if ($cnt_firma < 1110000) {
  throw new Exception("cnt_firma < 1110000");
}
if ($cnt_firma_bez < 1540000) {
  throw new Exception("cnt_firma_bez < 1540000");
}


id_ne_id_hauptsitz($dbh);
at_most_one_bezeichnung_with_status_3_and_typ_1_per_firma($dbh);
firma_without_bezeichnung_status_3_and_typ_1 ($dbh);
id_hauptsitz_implies_rechtsform_9($dbh);
rechtsform_9_implies_id_hauptsitz($dbh);
rekursive_firmen_3_levels($dbh);
rekursive_firmen_4_levels($dbh);


function id_ne_id_hauptsitz($dbh) { // Check id != id_hauptsitz {


  $cnt = db_sel_1_row_1_col($dbh, '
    select
      count(*)
    from
      firma
    where
      id = id_hauptsitz
  ');
  
  if ($cnt > 0) {
    throw new Exception("Firmen mit id = id_hauptsitz: $cnt");
  }

} // }

function at_most_one_bezeichnung_with_status_3_and_typ_1_per_firma($dbh) { // {

  $cnt = db_sel_1_row_1_col($dbh, '
     select count(*) from (
         select
           id_firma,
           count(*)
         from
           firma_bez
         where
           status = 3 and
           typ    = 1
         group by
           id_firma
         having
           count(*) > 1
      )');
  
  if ($cnt > 0) {
    throw new Exception("status = 3, typ = 1, cnt=$cnt");
  }
} // }

function firma_without_bezeichnung_status_3_and_typ_1($dbh) { // {

  $cnt = db_sel_1_row_1_col($dbh, '
     select
      count(*)
    from
      firma
    where
      id not in (select id_firma from firma_bez where status = 3 and typ = 1)');
  
  if ($cnt > 0) {
    throw new Exception("Firmas without bezeichnung: cnt=$cnt");
  }
} // }

function id_hauptsitz_implies_rechtsform_9($dbh) { // {


  $cnt = db_sel_1_row_1_col($dbh, 'select count(*) from firma where id_hauptsitz is not null and rechtsform != 9');

  if ($cnt > 10) {
    throw new Exception("id_hauptsitz is not null but rechtsform !=9: cnt=$cnt");
  }
  print "id_hauptsitz_implies_rechtsform_9: $cnt\n";
  

} // }

function rechtsform_9_implies_id_hauptsitz ($dbh) { // {

  $cnt = db_sel_1_row_1_col($dbh, 'select count(*) from firma where rechtsform = 9 and id_hauptsitz is null');

  if ($cnt > 50) {
    throw new Exception("rechtsform =9 but id_hauptsitz null: cnt=$cnt");
  }
  print "rechtsform_9_implies_id_hauptsitz: $cnt\n";
  

} // }

function rekursive_firmen_3_levels($dbh) { // {

  $cnt = db_sel_1_row_1_col($dbh,'select count(*) from                                             firma where id_hauptsitz in (select id id_level_2 from firma where id_hauptsitz is not null )');

  print "rekursive_firmen_3_levels: $cnt\n";


} // }

function rekursive_firmen_4_levels($dbh) { // {

  $cnt = db_sel_1_row_1_col($dbh,'select count(*) from firma where id_hauptsitz in (select id id_level_3 from firma where id_hauptsitz in (select id id_level_2 from firma where id_hauptsitz is not null))');

  if ($cnt > 0) {
    throw new Exception("4 levels of recursion");
  }

} // }

?>
