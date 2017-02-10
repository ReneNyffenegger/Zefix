<?php

$V_or_F = substr($_SERVER['REQUEST_URI'], 1, 1);

if ($V_or_F == 'V') {
  $test_or_prod = 'test';
}
elseif ($V_or_F == 'F') {
  $test_or_prod = 'prod';
}
else {
#   $db = db_connect('prod');
  throw new Exception("V_or_F neither V nor F, but: >$V_or_F<");
}

include($_SERVER[DOCUMENT_ROOT] . "/../$test_or_prod/php/db.php");
include($_SERVER[DOCUMENT_ROOT] . "/../$test_or_prod/php/zefix.php");

$db = db_connect("web-$test_or_prod");

main($db);

function main($db) { // {


  $topic = urldecode(substr($_SERVER['REQUEST_URI'], 8));


// br("Topic: $topic");

  if ($topic == 'gemeinden') {
    print_gemeinden($db);
    return;
  }


  if (preg_match('/f(\d+)/', $topic,  $id_firma_m)) {
    $id_firma = $id_firma_m[1];
    print_firma($db, $id_firma);
#   br("matched firma $id_firma");
    return;
  }

  if (preg_match('/g(\d+)/', $topic,  $id_gemeinde_m)) {
    $id_gemeinde = $id_gemeinde_m[1];
    print_gemeinde($db, $id_gemeinde);
#   br("matched firma $id_firma");
    return;
  }

  /*
  br('REQUEST_URI: ' . $_SERVER['REQUEST_URI']);
  br('basename(REQUEST_URI): ' . basename($_SERVER['REQUEST_URI']));
  br('urldecode(basename(REQUEST_URI)): ' . urldecode(basename($_SERVER['REQUEST_URI'])));
   */


} // }

function print_firma($db, $id_firma) { // {

  $firma = firma_info($db, $id_firma);

  printf ("<h1>%s</h1>\n", $firma['bezeichnung']);

  printf("%s %s<br>\n", tq84_enc($firma['strasse']), tq84_enc($firma['hausnummer']));
  if ($firma['care_of'       ]) { printf("  %s<br>\n"   , tq84_enc($firma['care_of'])); }
  if ($firma['address_zusatz']) { printf("  %s<br>\n"   , tq84_enc($firma['address_zusatz'])); }
  if ($firma['postfach'])       { printf("  %s<br>\n"   , tq84_enc($firma['postfach'      ])); }
  printf("  %s %s<br>\n", $firma['plz'], tq84_enc($firma['ort']));

  if ($firma['kapital']) {
    $kapital = $firma['kapital'];

    if ($kapital >= 1000000) {
       $kapital = preg_replace('/(\d\d\d)(\d\d\d)$/', '\'\1\'\2', $kapital);
    }
    elseif ($kapital >= 10000) {
       $kapital = preg_replace('/(\d\d\d)$/', '\'\1', $kapital);
    }

    printf("<p>Kapital: %s %s<br>\n" , $kapital, $firma['currency']);
  }

  if ($firma['zweck']) {
    print "<p>\n";
    print ($firma['zweck']);
  }

  print "<hr>";

  printf ("Weitere Firmen in <a href='g%d'>%s</a>", $firma['id_gemeinde'], gemeinde_name($db, $firma['id_gemeinde']));

} // }

function print_gemeinde($db, $id_gemeinde) { // {

  print_html_start("Firmen in " . gemeinde_name($db, $id_gemeinde));
  $res = db_prep_exec_fetchall($db, 'select id, bezeichnung from firma where status != 0 and id_hauptsitz is null and id_gemeinde = ?', array($id_gemeinde));

  foreach ($res as $row) {
    printf ("<br><a href='f%d'>%s</a>", $row['id'], tq84_enc($row['bezeichnung']));
  }
} // }

function print_gemeinden($db) { // {

  print_html_start("Gemeinden der Schweiz");
# br('function print_gemeinden');

  $res = db_prep_exec_fetchall($db, 'select id, name from gemeinde order by name');

  foreach ($res as $row) {
    printf ("<a href='g%d'>%s</a> - ", $row['id'], tq84_enc($row['name']));
  }

  print_html_end();

} // }

function br($text) { // {
  print "2017-02-06 $text<br>\n";
} // }

function print_html_start($title) { // {

print "<!DOCTYPE html>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
<title>$title</title>
</head>
<body>
  <h1>$title</h1>
";
} // }

function print_html_end() { // {
  print "</body></html>";
} // }


?>
