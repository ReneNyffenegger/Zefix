<?php

include (getenv('github_root') . 'Zefix/web/php/db.php');
include (getenv('github_root') . 'Zefix/web/php/zefix.php');

$id_firma = $argv[1];

$db = db_connect('dev');

$firma = firma_info($db, $argv[1]);

printf("\n");
printf("  %s\n"   , $firma['bezeichnung']);
if ($firma['care_of']) {
printf("c/o:        %s\n"     , $firma['care_of']);
}

printf("  %s %s\n", $firma['strasse'], $firma['hausnummer']);

if ($firma['address_zusatz']) {
printf("  %s\n"   , $firma['address_zusatz']);
}

if ($firma['postfach']) {
printf("  %s\n"   , $firma['postfach']);
}

printf("  %s %s\n", $firma['plz'], $firma['ort']);
printf("\n");

printf("code13:     %s\n"     , $firma['code13']);
printf("Gemeinde:   %s (%d)\n", $firma['gemeinde'], $firma['id_gemeinde']);

if ($firma['id_hauptsitz']) {
printf("Hauptsitz:  %d\n"     , $firma['id_hauptsitz']);
}

if ($firma['kapital']) {
printf("Kapital:    %d %s\n"  , $firma['kapital'], $firma['currency']);
}


if ($firma['zweck']) {
  print "\n";
  print ($firma['zweck']);
}


?>
