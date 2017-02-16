#!/usr/bin/perl
use warnings;
use strict;

use Zefix;

Zefix::init('dev');

my $filename = shift or die;
# open (my $f, '<', $filename) or die;

my $zefix_file = Zefix::open_daily_summary_file($filename);

open (my $out, '>', 'abc.html') or die;
print $out '<!DOCTYPE HTML>
<html><head> <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

  <style>
    tr.del {color:grey}
    td.rest {background-color:#f99}
  </style>

</head><body>';

# while (my $rec = Zefix::read_summary_line($f, $filename)) {
while (my $rec = Zefix::parse_next_daily_summary_line($zefix_file)) {


  my $personen_trs = '<tr>
<!--      <td>+/-</td> -->
    <td>Nachname</td>
    <td>Vorname</td>
    <td>von</td>
    <td>Bezeichung</td>
    <td>in</td>

    <td>Details</td>

    <td>Vors GF</td>
    <td>Präs</td>
    <td>Dir</td>
    <td>Mitgl</td>
    <td>Mitgl VR</td>
  <!--  ----- -->
    <td>EU</td>
    <td>EP</td>
    <td>KU2</td>
    <td>KP2</td>
  <!--  ----- -->
    <td>St Einl</td>
    <td>St Ant</td>



    <td>G</td>
    <td>R</td>
    <td>L</td>


    <td>B: Vors GF</td>
    <td>B: Präs</td>
    <td>B: Dir</td>
    <td>B: Mitgl</td>
    <td>B: Mitgl VR</td>
  <!--  ----- -->
    <td>B: EU</td>
    <td>B: EP</td>
    <td>B: KU2</td>
    <td>B: KP2</td>
  <!--  ----- -->
    <td>B: St Einl</td>
    <td>B: St Ant</td>

  <!-- ---- -->
    <td>Rest</td>

  </tr>';

  my @personen = Zefix::find_persons_from_daily_summary_rec($rec);



  for my $personen_rec (@personen) {

    my $funkt_text = '';

    if ($personen_rec->{koll_prok_2}) { $funkt_text .= 'Koll. Prok. zu 2 <br> '; }
    if ($personen_rec->{gesellschafter}) { $funkt_text .= 'Gesellschafter <br> '; }
    if ($personen_rec->{vr_praes} ) { $funkt_text .= 'Präsident des Verwaltungsrates<br>'; }
    if ($personen_rec->{praes} ) { $funkt_text .= 'Präsident<br>'; }
    if ($personen_rec->{dir}  ) { $funkt_text .= 'Direktor des Verwaltungsrates<br>'; }
    if ($personen_rec->{vr_mg}  ) { $funkt_text .= 'Mitglied des Verwaltungsrates<br>'; }
    if ($personen_rec->{gl_mg}  ) { $funkt_text .= 'Mitglied der Geschäftsleitung<br>'; }
    if ($personen_rec->{mg}    ) { $funkt_text .= 'Mitglied<br>'; }
    if ($personen_rec->{gf_vors} ) { $funkt_text .= 'Vorsitzender der Geschäftsführung<br>'; }
    if ($personen_rec->{gf} ) { $funkt_text .= 'Geschäftsführer<br>'; }
    if ($personen_rec->{eu} ) { $funkt_text .= 'Einzelunterschrift<br>'; }
    if ($personen_rec->{ep} ) { $funkt_text .= 'Einzelprokura<br>'; }
    if ($personen_rec->{ku2}) { $funkt_text .= 'Kollektivunterschrift zu zweien<br>'; }
    if ($personen_rec->{oz}    ) { $funkt_text .= 'Ohne Zeichnungsberechtigung<br>'; }

    $personen_trs .= sprintf("<tr class='%s'>
<!--    <td>s</td>  +- -->
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
      <!-- ---------- -->
        <td>%s</td>
      <!-- ---------- -->
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
      <!-- ---------- -->
        <td>%d</td>
        <td>%d</td>
        <td>%d</td>
      <!-- ---------- -->
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
        <td>%s</td>
      <!-- ---------- -->
        <td class='%s'>%s</td>
        </tr>",
#     $personen_rec->{add_rm},
      $personen_rec->{add_rm} eq '-' ? 'del' : 'add',
      $personen_rec->{nachname} //'',
      $personen_rec->{vorname} //'',
      $personen_rec->{von} //'',
      $personen_rec->{bezeichnung} // '',
      $personen_rec->{in} //'',
      $funkt_text,

      $personen_rec->{vorsitzender_gf        } // '?',
      $personen_rec->{praesident             } // '?',
      $personen_rec->{direktor               } // '?',
#     $personen_rec->{gesellschafter         } // '?',
      $personen_rec->{mitglied_vr            } // '?',
      $personen_rec->{einzelprokura          } // '?',
#     $personen_rec->{kollektivprokura_2     } // '?',
      $personen_rec->{stammeinlage           } // '?',
      $personen_rec->{stammanteile           } // '?',

      $personen_rec->{gesellschafterin} // 0,
      $personen_rec->{revisionsstelle } // 0,
      $personen_rec->{liquidatorin    } // 0,

      $personen_rec->{bisher_vorsitzender_gf        } // '?',
      $personen_rec->{bisher_praesident             } // '?',
      $personen_rec->{bisher_direktor               } // '?',
#     $personen_rec->{bisher_gesellschafter         } // '?',
      $personen_rec->{bisher_mitglied_vr            } // '?',
      $personen_rec->{bisher_einzelprokura          } // '?',
#     $personen_rec->{bisher_kollektivprokura_2     } // '?',
      $personen_rec->{bisher_stammeinlage           } // '?',
      $personen_rec->{bisher_stammanteile           } // '?',
#     --
      $personen_rec->{rest} ? 'rest': '',
      $personen_rec->{rest} // '?'
   );
  }

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


  print $out <<HTML;

  id_firma: $rec->{id_firma}
  <br>
  $stati


  <p><b>Personen</b><table border=1>$personen_trs</table>


  <p><p>

  text: $text
  <p><p>

  <hr>
HTML

}

print $out "</body></html>";
close $out;
