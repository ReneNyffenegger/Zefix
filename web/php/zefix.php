<?php

function firma_info($dbh, $id) {

  $firma = db_sel_1_row($dbh, 'select * from firma where id = :1', array($id));

  $firma['zweck'      ] = db_sel_1_row_1_col($dbh, 'select zweck from zweck where id_firma = :1', array($id));
  $firma['gemeinde'   ] = db_sel_1_row_1_col($dbh, 'select name from gemeinde where id = :1', array($firma['id_gemeinde']));
  $firma['bezeichnung'] = db_sel_1_row_1_col($dbh, 'select bezeichnung from firma_bez where id_firma = :1', array($id));

  return $firma;


}

?>
