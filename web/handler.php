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

function main($db) { #_{

  $topic = urldecode(substr($_SERVER['REQUEST_URI'], 8));


   br("Topic: $topic");
   if ($topic == '') { #_{

    print_index($db);
    return;

  } #_}

  if ($topic == 'gemeinden') { #_{
    print_gemeinden($db);
    return;
  } #_}

  if (preg_match('/f(\d+)/', $topic,  $id_firma_m)) { #_{
    $id_firma = $id_firma_m[1];
    print_firma($db, $id_firma);
#   br("matched firma $id_firma");
    return;
  } #_}

  if (preg_match('/g(\d+)/', $topic,  $id_gemeinde_m)) { #_{
    $id_gemeinde = $id_gemeinde_m[1];
    print_gemeinde($db, $id_gemeinde);
#   br("matched firma $id_firma");
    return;
  } #_}

  if (preg_match('/s(\w+)/', $topic,  $id_stichwort_m)) { #_{
    br('matched s');
    $id_stichwort = $id_stichwort_m[1];
    br("id_stichwort = $id_stichwort");
    print_stichwort($db, $id_stichwort);
    return;
  } #_}

  /*
  br('REQUEST_URI: ' . $_SERVER['REQUEST_URI']);
  br('basename(REQUEST_URI): ' . basename($_SERVER['REQUEST_URI']));
  br('urldecode(basename(REQUEST_URI)): ' . urldecode(basename($_SERVER['REQUEST_URI'])));
   */

} #_}

function print_firma($db, $id_firma) { #_{

  $firma = firma_info($db, $id_firma);

  print_html_start($firma['bezeichnung']);
# printf ("<h1>%s</h1>\n", $firma['bezeichnung']);

  if ($firma['care_of'       ]) { printf("  %s<br>\n"   , tq84_enc($firma['care_of'])); }
  printf("%s %s<br>\n", tq84_enc($firma['strasse']), tq84_enc($firma['hausnummer']));
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
    $zweck = $firma['zweck'];

    if (is_tq84()) {
      $zweck = preg_replace('(Die Gesellschaft kann .*|; (sie )?kann .*)', "\n<br><span style=\"color:grey\">$0</span>", $zweck);
    }
    else {
#     br('HTTP_USER_AGENT: ' .  $_SERVER['HTTP_USER_AGENT']) ;
      $zweck = preg_replace('(Die Gesellschaft kann .*|; kann .*)', '', $zweck);
    }

    print ($zweck);
  }

  print "\n<hr>";

  printf ("Weitere Firmen in <a href='g%d'>%s</a>", $firma['id_gemeinde'], gemeinde_name($db, $firma['id_gemeinde']));

} #_}

function print_gemeinde($db, $id_gemeinde) { #_{

  print_html_start("Firmen in " . gemeinde_name($db, $id_gemeinde));
  $res = db_prep_exec_fetchall($db, 'select id, bezeichnung from firma where status != 0 and id_hauptsitz is null and id_gemeinde = ?', array($id_gemeinde));

  foreach ($res as $row) {
    printf ("<br><a href='f%d'>%s</a>", $row['id'], tq84_enc($row['bezeichnung']));
  }
} #_}

function print_gemeinden($db) { #_{

  print_html_start("Gemeinden der Schweiz");

  $res = db_prep_exec_fetchall($db, 'select id, name from gemeinde order by name');

  foreach ($res as $row) {
    printf ("<a href='g%d'>%s</a> - ", $row['id'], tq84_enc($row['name']));
  }

  print_html_end();

} #_}

function print_stichwort($db, $id_stichwort) { #_{

  print_html_start("Stichwort: " . stichwort_name($db, $id_stichwort));

  print "foo<br>";

  $res = db_prep_exec_fetchall($db, 'select sf.id_firma, f.bezeichnung from stichwort_firma sf join firma f on sf.id_firma =f.id where sf.id_stichwort = ?', array($id_stichwort));

  foreach ($res as $row) {
    printf ("<br><a href='f%d'>%s</a>", $row['id_firma'], tq84_enc($row['bezeichnung']));
  }

  print "<hr><a href='.'>Index</a>";
  print_html_end();
} #_}

function print_index($db) { #_{
  print_html_start("Firmen der Schweiz");

  print "<h1>Stichwörter</h1>\n";

  $res = db_prep_exec_fetchall($db, 'select id, stichwort from stichwort order by stichwort');
  foreach ($res as $row) {

    printf ("<a href='s%d'>%s</a><br>", $row['id'], $row['stichwort']);

  }

  print "<hr>";
  print "<a href='gemeinden'>Gemeinden der Schweiz</a>";

  print_html_end();
} #_}

function br($text) { #_{
  print "2017-02-06 $text<br>\n";
} #_}

function print_html_start($title) { #_{

print "<!DOCTYPE html>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
<title>$title</title>
</head>
<body>
  <h1>$title</h1>
";
} #_}

function print_html_end() { #_{
  print "</body></html>";
} #_}

function is_tq84() { #_{
  return $_SERVER['HTTP_USER_AGENT'] == 'Mozilla/5.0 (TQ)';
} #_}

?>
