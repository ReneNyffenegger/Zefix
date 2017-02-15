<?php

function firma_info($dbh, $id) { #_{

  $firma = db_sel_1_row($dbh, 'select * from firma where id = :1', array($id));

  $firma['zweck'      ] = tq84_enc(db_sel_1_row_1_col($dbh, 'select zweck from zweck where id_firma = :1', array($id)));
  $firma['gemeinde'   ] = gemeinde_name($dbh, $firma['id_gemeinde']);
  $firma['bezeichnung'] = tq84_enc(db_sel_1_row_1_col($dbh, 'select bezeichnung from firma_bez where id_firma = :1 and status = 3 and typ = 1', array($id)));

  switch($firma['rechtsform']) {
    case  1: $firma['rechtsform_bezeichnung'] = 'Einzelfirma'; break;
    case  2: $firma['rechtsform_bezeichnung'] = 'Kollektivgesellschaft'; break;
    case  3: $firma['rechtsform_bezeichnung'] = 'Aktiengesellschaft'; break;
    case  4: $firma['rechtsform_bezeichnung'] = 'GmbH'; break;
    case  5: $firma['rechtsform_bezeichnung'] = 'Genossenschaft'; break;
    case  6: $firma['rechtsform_bezeichnung'] = 'Verein'; break;
    case  7: $firma['rechtsform_bezeichnung'] = 'Stiftung'; break;
    case  8: $firma['rechtsform_bezeichnung'] = '8 (Besondere Rechtsform)'; break;
    case  9: $firma['rechtsform_bezeichnung'] = 'Zweigniederlassung'; break;
    case 10: $firma['rechtsform_bezeichnung'] = 'Kommanditgesellschaft'; break;
    case 11: $firma['rechtsform_bezeichnung'] = 'Kommanditaktiengesellschaft'; break;
    case 84: $firma['rechtsform_bezeichnung'] = 'Gemeinderschaft'; break;
    case 85: $firma['rechtsform_bezeichnung'] = 'Institut'; break;
    case 86: $firma['rechtsform_bezeichnung'] = 'Nichtkaufmännische Prokura'; break;
    case 92: $firma['rechtsform_bezeichnung'] = 'Ausländische Zweigniederlassung'; break;
    default: $firma['rechtsform_bezeichnung'] = "??? (" . $firma['rechtsform'] . ")"; break;


  }



  return $firma;

} #_}

function gemeinde_name($dbh, $id_gemeinde) { #_{
  return tq84_enc(db_sel_1_row_1_col($dbh, 'select name from gemeinde where id = :1', array($id_gemeinde)));
} #_}

# function stichwort_name($dbh, $id_stichwort) { #_{
#   return tq84_enc(db_sel_1_row_1_col($dbh, 'select stichwort from stichwort where id = :1', array($id_stichwort)));
# } #_}

function tq84_enc($str) { #_{
  return $str;
//return utf8_encode($str);
} #_}

?>
