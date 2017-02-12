<?php

function firma_info($dbh, $id) { #_{

  $firma = db_sel_1_row($dbh, 'select * from firma where id = :1', array($id));

  $firma['zweck'      ] = tq84_enc(db_sel_1_row_1_col($dbh, 'select zweck from zweck where id_firma = :1', array($id)));
  $firma['gemeinde'   ] = gemeinde_name($dbh, $firma['id_gemeinde']);
  $firma['bezeichnung'] = tq84_enc(db_sel_1_row_1_col($dbh, 'select bezeichnung from firma_bez where id_firma = :1 and status = 3 and typ = 1', array($id)));

  return $firma;

} #_}

function gemeinde_name($dbh, $id_gemeinde) { #_{
  return tq84_enc(db_sel_1_row_1_col($dbh, 'select name from gemeinde where id = :1', array($id_gemeinde)));
} #_}

function stichwort_name($dbh, $id_stichwort) { #_{
  print "stichwort_name: $id_stichwort<br>";
  return tq84_enc(db_sel_1_row_1_col($dbh, 'select stichwort from stichwort where id = :1', array($id_stichwort)));
} #_}

function tq84_enc($str) { #_{
  return $str;
//return utf8_encode($str);
} #_}

?>
