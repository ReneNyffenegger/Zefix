#!/usr/bin/perl
use warnings;
use strict;

use Zefix;
use utf8;

Zefix::init('dev');

my $filename = shift or die;
# open (my $f, '<', $filename) or die;

my $zefix_file = Zefix::open_daily_summary_file($filename);

open (my $out, '>:encoding(utf-8)', 'abc.html') or die;
print $out '<!DOCTYPE HTML>
<html><head> <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

  <style>
    tr.del {color:grey}
    td.rest {background-color:#f99}
    .no-pers  {color: red; font-weight: bold}
    .no-space {background-color:#f90}
  </style>

</head><body>';

# while (my $rec = Zefix::read_summary_line($f, $filename)) {
while (my $rec = Zefix::parse_next_daily_summary_line($zefix_file)) {


  my $personen_trs = '<tr>
    <td>Titel</td>
    <td>Nachname</td>
    <td>Vorname</td>
    <td>von</td>
  <!--
    <td>2</td>
    <td>3</td>
    <td>4</td>
    <td>5</td>
    <td>6</td>
    -->
    <td>Bezeichung</td>
    <td>in</td>

    <td>Funktion</td>
    <td>Zeichnung</td>

    <td>Stammeinlage</td>

    <td>Rest</td>

  </tr>
';

  my @personen = Zefix::find_persons_from_daily_summary_rec($rec);

  for my $personen_rec (@personen) { #_{

    print "Rest: $personen_rec->{rest}","\n" if $personen_rec->{rest};

    $personen_trs .= sprintf( #_{
      "<tr class='%s'>
        <td%s>%s</td>   <!-- titel       -->
        <td%s>%s</td>   <!-- nachname    -->
        <td%s>%s</td>   <!-- vorname     -->
        <td%s>%s</td>   <!-- von         -->
        <!-- von 1 .. 6
        <td> s</td>
        <td> s</td>
        <td> s</td>
        <td> s</td>
        <td> s</td>
        -->
        <td%s>%s</td>   <!-- bezeichnung -->
      <!-- ---------- -->
        <td%s>%s</td>   <!-- in           -->
        <td%s>%s</td>   <!-- funktion     -->
        <td%s>%s</td>   <!-- zeichnung    -->
        <td%s>%s</td>   <!-- stammeinlage -->
      <!-- ---------- -->
        <td class='%s'>%s</td> <!-- rest -->
        </tr>\n",
#     $personen_rec->{add_rm},
      $personen_rec->{add_rm} eq '-' ? 'del' : 'add',
      css_class($personen_rec->{titel}   ), $personen_rec->{titel}        // '',
      css_class($personen_rec->{nachname}), $personen_rec->{nachname}     // '',
      css_class($personen_rec->{vorname} ), $personen_rec->{vorname}      // '',
      css_class($personen_rec->{von}     ), $personen_rec->{von}          // '',
#   ${$personen_rec->{von}}[0]      // '',
#   ${$personen_rec->{von}}[1]      // '',
#   ${$personen_rec->{von}}[2]      // '',
#   ${$personen_rec->{von}}[3]      // '',
#   ${$personen_rec->{von}}[4]      // '',
#   ${$personen_rec->{von}}[5]      // '',
      css_class($personen_rec->{bezeichnung} ), $personen_rec->{bezeichnung}  // '',
      css_class($personen_rec->{in}          ), $personen_rec->{in}           // '',

      css_class($personen_rec->{funktion}    ), $personen_rec->{funktion}     // '<i>null</i>',
      css_class($personen_rec->{zeichnung}   ), $personen_rec->{zeichnung}    // '<i>null</i>',
      css_class($personen_rec->{stammeinlage}), $personen_rec->{stammeinlage} // '<i>null</i>',

      $personen_rec->{rest} ? 'rest': '',
      $personen_rec->{rest} // '?'
   ); #_}

  } #_}

# my $personen_br = join "<br>", @personen;

  my $stati = '';
  $stati .= "<br>Neueintrag      ($rec->{neueintrag})" if $rec->{neueintrag};
  $stati .= "<br>Mut Status      ($rec->{mut_status})" if $rec->{mut_status};
  $stati .= "<br>Mut Firma       ($rec->{mut_firma})" if $rec->{mut_firma };
  $stati .= "<br>Mut Rechtsform  ($rec->{mut_rechtsform})" if $rec->{mut_rechtsform};
  $stati .= "<br>Mut Kapital     ($rec->{mut_kapital})" if $rec->{mut_kapital};
  $stati .= "<br>Mut Domizil     ($rec->{mut_domizil})" if $rec->{mut_domizil};
  $stati .= "<br>Mut Zweck       ($rec->{mut_zweck})" if $rec->{mut_zweck};
  $stati .= "<br>Mut Organ       ($rec->{mut_organ})" if $rec->{mut_organ};

  my $text   = $rec->{text};
  $text =~ s/&/&amp;/g;
  $text =~ s/</&lt;/g;
  $text =~ s/>/&gt;/g;

  my $keine_personen ='';
  if (Zefix::are_persons_expected($rec) and not Zefix::registeramt_with_special_wording($rec)) {
    $keine_personen = "<div class='no-pers'>Keine Personen, obwohl welche erwartet</div>" unless @personen;
  }

  print $out <<HTML;

  id_firma: $rec->{id_firma}  (Registeramt: $rec->{registeramt}, Dt Journal: $rec->{dt_journal}
  <br>

  $stati


  <p><b>Personen</b><table border=1>$personen_trs</table>


  $keine_personen

  <p><p>

  text: $text
  <p><p>

  <hr>
HTML

}

sub css_class { #_{
  my $text = shift;
  return '' unless defined $text;
  if ($text =~ /^ / or $text =~ / $/) {
    return " class='no-space'";
  }
  return '';
} #_}

print $out "</body></html>";
close $out;
