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

//br("Topic: $topic");

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
    return;
  } #_}

  if (preg_match('/g(\d+)/', $topic,  $id_gemeinde_m)) { #_{
    $id_gemeinde = $id_gemeinde_m[1];
    print_gemeinde($db, $id_gemeinde);
    return;
  } #_}

  if (preg_match('/Stichwort-(.+)/', $topic,  $stichwort_m)) { #_{
    $stichwort_name = $stichwort_m[1];
    print_stichwort($db, $stichwort_name);
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

  $firma_bezeichnung = $firma['bezeichnung'];
  if ($firma['status'] == 0) {
    $firma_bezeichnung .= ' (gelöscht)';
  }
  elseif ($firma['status'] == 3) {
    $firma_bezeichnung .= ' (in Auflösung)';
  }


  print_html_start($firma_bezeichnung);
# printf ("<h1>%s</h1>\n", $firma['bezeichnung']);

  print $firma['rechtsform_bezeichnung']. "<p>";

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


    # zweck-reduktion, vgl f401976
    if (is_tq84()) {
      $zweck = preg_replace('((Die|; die) Gesellschaft kann .*|; (sie )?kann .*|\. Kann .*|Sie kann .*)', "\n<br><span style=\"color:grey\">$0</span>", $zweck);
    }
    else {
      $zweck = preg_replace('((Die|; die) Gesellschaft kann .*|; (sie )?kann .*|\. Kann .*|Sie kann .*)', ''                                          , $zweck);
    }

    print ($zweck);
  }



  print "\n<hr>";

  $stichwort_shown = 0;
  $res = db_prep_exec_fetchall($db, 
    'select
      s.stichwort
    from
      stichwort_firma   sf    join
      stichwort         s
    on
      sf.id_stichwort = s.id
    where
      sf.id_firma = ?
    order by
      s.stichwort
    ', array($id_firma));

  foreach ($res as $row) {
    if (! $stichwort_shown) {
      print "Die Firma erscheint unter den folgenden " . link_stichwoerter("Stichwörtern") . "<ul>\n";
      $stichwort_shown = 1;
    }
    printf ("  <li><a href='Stichwort-%s'>%s</a>\n", $row['stichwort'], $row['stichwort']);
  }
  if ($stichwort_shown) {
    print "</ul><hr>\n";
  }

  printf ("Weitere Firmen in <a href='g%d'>%s</a>", $firma['id_gemeinde'], gemeinde_name($db, $firma['id_gemeinde']));

  printf("<p><a href='.'>Hauptseite</a>");


} #_}

function print_gemeinde($db, $id_gemeinde) { #_{

  print_html_start("Firmen in " . gemeinde_name($db, $id_gemeinde));

  info("id_gemeinde: $id_gemeinde");

# $db->exec('analyze sqlite_master');

  $res = db_prep_exec_fetchall($db, 

    #  'explain query plan 
   "select
      f.id                 id_firma,
      f.bezeichnung,
      s.stichwort
    from
      firma           f                               left join 
      stichwort_firma sf   on f.id = sf.id_firma      left join
      stichwort       s    on s.id = sf.id_stichwort
    where
      f.status != 0          and
      f.id_hauptsitz is null and
      f.id_gemeinde = $id_gemeinde
    order
      by s.stichwort is null, s.stichwort", array() # $id_gemeinde)

  );

  $last_stichwort = '';
  foreach ($res as $row) {
    if ($last_stichwort != $row['stichwort']) {
      printf ("<h2>Stichwort: <a href='Stichwort-%s'>%s</a></h2>\n", $row['stichwort'], $row['stichwort']);
      $last_stichwort = $row['stichwort'];
    }
    printf ("<br><a href='f%d'>%s</a>", $row['id_firma'], tq84_enc($row['bezeichnung']));
  }

# $res = db_prep_exec_fetchall($db, 'select id, bezeichnung from firma where status != 0 and id_hauptsitz is null and id_gemeinde = ?', array($id_gemeinde));

# foreach ($res as $row) {
#   printf ("<br><a href='f%d'>%s</a>", $row['id'], tq84_enc($row['bezeichnung']));
# }

  print "<p><hr><p><a href='.'>Hauptseite</a>";
} #_}

function print_gemeinden($db) { #_{

  print_html_start("Gemeinden der Schweiz");

  $res = db_prep_exec_fetchall($db, 'select id, name from gemeinde order by name');

  foreach ($res as $row) {
    printf ("<a href='g%d'>%s</a> - ", $row['id'], tq84_enc($row['name']));
  }

  print_html_end();

} #_}

function print_stichwort($db, $stichwort_name) { #_{

  print_html_start("Stichwort: $stichwort_name"); #  . stichwort_name($db, $id_stichwort));

  if (is_tq84()) {
    print 'id_stichwort: ' . db_sel_1_row_1_col($db, 'select id from stichwort where stichwort = ?', array($stichwort_name));
  }

  $res = db_prep_exec_fetchall($db, 
    'select
       sf.id_firma,
       f.bezeichnung,
       f.id_gemeinde,
       g.name          name_gemeinde
     from
       stichwort       s                            join
       stichwort_firma sf on s.id = sf.id_stichwort join
       firma           f  on f.id = sf.id_firma     join
       gemeinde        g  on g.id = f .id_gemeinde
     where
       s.stichwort = ?
     order by
       g.name', array($stichwort_name));

  foreach ($res as $row) {
    printf ("<br><a href='f%d'>%s</a> - <a href='g%d'>%s</a>", $row['id_firma'], tq84_enc($row['bezeichnung']), $row['id_gemeinde'], $row['name_gemeinde']);
  }

  print "<hr>
    " . link_stichwoerter("Weitere Stichwörter") . "<br>
    <a href='.'>Index</a>";
  print_html_end();
} #_}

function print_index($db) { #_{
  print_html_start("Firmen der Schweiz");

  print "<h1 id='stichwoerter'>Stichwörter</h1>\n";

  $res = db_prep_exec_fetchall($db, 'select id, stichwort from stichwort order by stichwort');
  foreach ($res as $row) {

    printf ("<a href='Stichwort-%s'>%s</a><br>", $row['stichwort'], $row['stichwort']);

  }

  print "<hr>";
  print "<a href='gemeinden'>Gemeinden der Schweiz</a>";

  print_html_end();
} #_}

function link_stichwoerter($link_text) { #_{
  return "<a href='.#stichwoerter'>$link_text</a>";
} #_}

function br($text) { #_{
  print "$text<br>\n";
} #_}

function info($text) { #_{
  if (is_tq84()) {
    br($text);
  }

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
  print "<div style='height:2000px'></div></body></html>";
} #_}

function is_tq84() { #_{
  return $_SERVER['HTTP_USER_AGENT'] == 'Mozilla/5.0 (TQ)';
} #_}

?>
