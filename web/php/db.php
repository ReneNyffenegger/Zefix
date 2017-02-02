<?php

function db_connect() {

  if ('test') {
    $db_path = getenv('github_root') . 'Zefix/test/zefix.db';
  }
  else {

  }

  if (! file_exists($db_path)) {
    echo "DB does not exist!";
  }


  $db = new PDO("sqlite:$db_path"); 
  $db -> setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  return $db;
}


function db_sel_1_row($dbh, $sql) {


  $sth = $dbh->prepare($sql);
  $sth->execute();
  $row=$sth->fetch(); // PDO::FETCH_ASSOC);

//$sth->fetch();
  if ($sth->fetch()) {
    throw new Exception("db_sel_1_row selected more than one row! sql = $sql");
  }
//$row = null;
  return $row;
}

function db_sel_1_row_1_col($dbh, $sql) {
  $row = db_sel_1_row($dbh, $sql);
//if (count($row) != 1) {
//  throw new Exception("db_sel_1_row_1_col selected more than one column! sql = $sql");
//}
  return $row[0];
}

function db_cnt_table($dbh, $table_name) {
  return db_sel_1_row_1_col($dbh, "select count(*) from $table_name");
}

function db_prep_exec($dbh, $sql, $params) {

  $sth = $dbh -> prepare ($sql);
  $sth -> execute($params);

  return $sth;

}

?>
