<?php

function db_connect($env) { #_{


  if ($env == 'test') {
    $db_path = getenv('github_root') . 'Zefix/test/zefix.db';
  }
  elseif ($env == 'dev') {
    $db_path = getenv('digitales_backup') . 'Zefix/zefix.db';
  }
  elseif ($env == 'web-prod') {
    $db_path = $_SERVER[DOCUMENT_ROOT] . '/../prod/db/zefix.db';
  }
  elseif ($env == 'web-test') {
    $db_path = $_SERVER[DOCUMENT_ROOT] . '/../test/db/zefix.db';
  }
  else {
    throw new Exception("Invalid env $env");
  }

  if (! file_exists($db_path)) {
   throw new Exception("DB does not exist env=$env, db_path=$db_path!");
  }


  $db = new PDO("sqlite:$db_path"); 
  $db -> setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  return $db;
} #_}

function db_sel_1_row($dbh, $sql, $params = array()) { #_{


  $sth = $dbh->prepare($sql);
  $sth->execute($params);
  $row=$sth->fetch(); // PDO::FETCH_ASSOC);

  if ($sth->fetch()) {
    throw new Exception("db_sel_1_row selected more than one row! sql = $sql");
  }
  return $row;
} #_}

function db_sel_1_row_1_col($dbh, $sql, $params = array()) { #_{
  $row = db_sel_1_row($dbh, $sql, $params);
  return $row[0];
} #_}

function db_cnt_table($dbh, $table_name) { #_{
  return db_sel_1_row_1_col($dbh, "select count(*) from $table_name");
} #_}

function db_prep_exec($dbh, $sql, $params = array()) { #_{

  $sth = $dbh -> prepare ($sql);
  $sth -> execute($params);

  return $sth;

} #_}

function db_prep_exec_fetchall($dbh, $sql, $params = array()) { #_{

  $sth = db_prep_exec($dbh, $sql, $params);

  return $sth -> fetchAll();

} #_}

?>
