<?php


main();




function main() {

  $topic = urldecode(substr($_SERVER['REQUEST_URI'], 8));

  br("Topic: $topic");

  /*
  br('REQUEST_URI: ' . $_SERVER['REQUEST_URI']);
  br('basename(REQUEST_URI): ' . basename($_SERVER['REQUEST_URI']));
  br('urldecode(basename(REQUEST_URI)): ' . urldecode(basename($_SERVER['REQUEST_URI'])));
   */


}

function br($text) {
  print "$text<br>\n";
}

?>
