<?php

function db_connect($env) {


  if ($env == 'test') {
    $db_path = getenv('github_root') . 'Zefix/test/zefix.db';
  }
  elseif ($env == 'dev') {
    $db_path = getenv('digitales_backup') . 'Zefix/zefix.db';
  }
  else {
    throw new Exception("Invalid env $env");
  }

  if (! file_exists($db_path)) {
   throw new Exception("DB does not exist!");
  }


  $db = new PDO("sqlite:$db_path"); 
  $db -> setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  return $db;
}

function db_sel_1_row($dbh, $sql, $params = array()) {


  $sth = $dbh->prepare($sql);
  $sth->execute($params);
  $row=$sth->fetch(); // PDO::FETCH_ASSOC);

  if ($sth->fetch()) {
    throw new Exception("db_sel_1_row selected more than one row! sql = $sql");
  }
  return $row;
}

function db_sel_1_row_1_col($dbh, $sql, $params = array()) {
  $row = db_sel_1_row($dbh, $sql, $params);
//if (count($row) != 1) {
//  throw new Exception("db_sel_1_row_1_col selected more than one column! sql = $sql");
//}
  return $row[0];
}

function db_cnt_table($dbh, $table_name) {
  return db_sel_1_row_1_col($dbh, "select count(*) from $table_name");
}

function db_prep_exec($dbh, $sql, $params = array()) {

  $sth = $dbh -> prepare ($sql);
  $sth -> execute($params);

  return $sth;

}

?>
