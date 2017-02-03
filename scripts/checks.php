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


//  Check for at most one Bezeichnung with status=3 and typ=1 per Firma. {
//
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

// }

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

?>
