#!/opt/local/bin/perl

# #########################################################################
#
# die Hauptmenu Scene                  
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package s1_menu;

use strict;
use warnings;

use OpenGL qw(:all);

use lib "lib";
require "glob.pm";
require "tex.pm";
require "obj.pm";
require "licht.pm";
require "shader.pm";

# Variablen fuer die Wuerfel Bewegung
my ($kamera_x,    $kamera_y,   $kamera_z);
my ($kamera_xi,   $kamera_yi,  $kamera_zi);
my ($wuerfel_x,   $wuerfel_y,  $wuerfel_z);
my ($wuerfel_xi,  $wuerfel_yi);
my ($wuerfel_rx,  $wuerfel_ry, $wuerfel_rz);
my ($wuerfel_zrx, $wuerfel_zry);
my ($zx, $zy);

my %menu;
my $menuAuswahl;
my $sceneInit = 0;

#
# Inizialisiere die Scene
#
sub init {

    # Position des Wuerfels
    $wuerfel_x =  0,0;
    $wuerfel_y =  0.0;
    $wuerfel_z = -5.0;

    # Die Rotation und die Zielrotation des Wuerfels
    $wuerfel_rx  = 0,0;
    $wuerfel_ry  = 0.0;
    $wuerfel_rz  = 0.0;
    $wuerfel_zrx = 0.0;
    $wuerfel_zry = 0.0;

    # Die Wuerfel Sinus Bewegung
    $wuerfel_xi = 0.0;
    $wuerfel_yi = 0.0;

    # Position der Kamera
    $kamera_x = 0.0;
    $kamera_y = 0.0;
    $kamera_z = 3.0;

    # die Kamera Sinus Bewegung
    $kamera_xi = 0.0;
    $kamera_yi = 0.0;
    $kamera_zi = 0.0;

    # Bewegung inizialisieren
    &physik();

    #schalte das Licht ein
    licht::licht01();
    
    # erzeuge die Menu Steuerung
    mkMenu();
    $menuAuswahl = "musik";

    # lade den Metal Shader
    # shader::bind( "metal" );

    # tu das alles nur einmal
    $sceneInit = 1;
}

#
# gebe die Auswahl zurueck
#
sub getInfo {

    my $ret = $glob::MENU_AUSWAHL_MUSIK;

    if( $menuAuswahl eq "kamera" ) {
        $ret = $glob::MENU_AUSWAHL_KAMERA;
    }

    if( $menuAuswahl eq "film" ) {
        $ret = $glob::MENU_AUSWAHL_FILM;
    }

    if( $menuAuswahl eq "bilder" ) {
        $ret = $glob::MENU_AUSWAHL_BILDER;
    }

    if( $menuAuswahl eq "radio" ) {
        $ret = $glob::MENU_AUSWAHL_RADIO;
    }

    if( $menuAuswahl eq "schlafen" ) {
        $ret = $glob::MENU_AUSWAHL_SCHLAFEN;
    }

    return( $ret );
}

#
# kann die Scene Aufträge annehmen ?
#
sub isActive {

    my $ret = 0;

    if( ($wuerfel_zrx != $wuerfel_rx) || ($wuerfel_zry != $wuerfel_ry) ) {
        $ret = 1;
    }

    return( $ret );
}

#
# loese die Actionen der Scene aus
#
sub setAction {

    my $action = shift @_;

    if ($action == GLUT_KEY_UP) {
      if( $wuerfel_zrx == $wuerfel_rx ) {
          if( $wuerfel_rx == -90 && $wuerfel_ry == 0 ) {          # leer nach Radio
            $wuerfel_zrx = 0; $wuerfel_zry = 180;
          } elsif( $wuerfel_rx == 0 && $wuerfel_ry != 0 ) {       # nach Bilder
            $wuerfel_zrx = 90; $wuerfel_zry = 0;
          } else {
              $wuerfel_zrx -= 90;
          }
          &berechne_z();
          $menuAuswahl = $menu{$menuAuswahl}{GLUT_KEY_UP};
      }
    }
    elsif ($action == GLUT_KEY_DOWN) {
      if( $wuerfel_zrx == $wuerfel_rx ) {
          if( $wuerfel_rx == 90 && $wuerfel_ry == 0 ) {           # Bilder nach Radio
            $wuerfel_zrx = 0; $wuerfel_zry = 180;
          } elsif( $wuerfel_rx == 0 && $wuerfel_ry != 0 ) {       # nach leer
            $wuerfel_zrx = -90; $wuerfel_zry = 0;
          } else {
              $wuerfel_zrx += 90;
          }
          &berechne_z();
          $menuAuswahl = $menu{$menuAuswahl}{GLUT_KEY_DOWN};
      }
    }
    elsif ($action == GLUT_KEY_LEFT) {
      if( $wuerfel_zry == $wuerfel_ry ) {
          if( $wuerfel_rx == 90 && $wuerfel_ry == 0 ) {           # Bilder nach Film
            $wuerfel_zrx = 0; $wuerfel_zry = 90;
          } elsif( $wuerfel_rx == -90 && $wuerfel_ry == 0 ) {     # leer nach Film
            $wuerfel_zrx = 0; $wuerfel_zry = 90;
          } else {
              $wuerfel_zry -= 90;
          }
          &berechne_z();
          $menuAuswahl = $menu{$menuAuswahl}{GLUT_KEY_LEFT};
      }
    }
    elsif ($action == GLUT_KEY_RIGHT) {
      if( $wuerfel_zry == $wuerfel_ry ) {
          if( $wuerfel_rx == 90 && $wuerfel_ry == 0 ) {           # Bilder nach Kamera
              $wuerfel_zrx = 0; $wuerfel_zry = -90;
          } elsif( $wuerfel_rx == -90 && $wuerfel_ry == 0 ) {     # leer nach Kamera
              $wuerfel_zrx = 0; $wuerfel_zry = -90;
          } else {
              $wuerfel_zry += 90;
          }
          &berechne_z();
          $menuAuswahl = $menu{$menuAuswahl}{GLUT_KEY_RIGHT};
      }
    }
}

#
# Berechne die Geschwindigkeit der Bewegungen bei der Menueauswahl
#
sub berechne_z {

    my $dx = abs( $wuerfel_zrx - $wuerfel_rx );
    my $dy = abs( $wuerfel_zry - $wuerfel_ry );
    $zx = 1;
    if( $dx >  90 ) { $zx++; }
    if( $dx > 180 ) { $zx++; }
    $zy= 1;
    if( $dy >  90 ) { $zy++; }
    if( $dy > 180 ) { $zy++; }

}

#
# Bewege den Würfel
#
sub physik {

    # Rotiere den Würfel
    if( $wuerfel_rx != $wuerfel_zrx ) {
        if( $wuerfel_rx > $wuerfel_zrx ) {
            $wuerfel_rx -= $zx; 
        } else {
            $wuerfel_rx += $zx; 
        }
    } else {
        if( abs($wuerfel_rx) == 360 ) {
            $wuerfel_rx = 0;
            $wuerfel_zrx = 0;
        }
    }

    if( $wuerfel_ry != $wuerfel_zry ) {
        if( $wuerfel_ry > $wuerfel_zry ) {
            $wuerfel_ry -= $zy; 
        } else {
            $wuerfel_ry += $zy; 
        }
    } else {
        if( abs($wuerfel_ry) == 360 ) {
            $wuerfel_ry = 0;
            $wuerfel_zry = 0;
        }
    }

    # Bewege den Würfel
    $wuerfel_x = sin( $wuerfel_xi ) * 1.5;
    #$wuerfel_y = sin( $wuerfel_yi );

    $wuerfel_xi += 0.002;
    if( $wuerfel_xi > 628 ) {
        $wuerfel_xi = 0;
    }

    $wuerfel_yi += 0.003;
    if( $wuerfel_yi > 628 ) {
        $wuerfel_yi = 0;
    }

    # Bewege die Kamera
    $kamera_x = sin( $kamera_xi );
    $kamera_y = sin( $kamera_yi );
    $kamera_z = (sin( $kamera_zi )*2) +4;

    $kamera_xi += 0.002;
    if( $kamera_xi > 628 ) {
        $kamera_xi = 0;
    }

    $kamera_yi += 0.003;
    if( $kamera_yi > 628 ) {
        $kamera_yi = 0;
    }

    $kamera_zi += 0.001;
    if( $kamera_zi > 628 ) {
        $kamera_zi = 0;
    }
}

#
# Zeige die Scene
#
sub show {

    my ($akt_winw, $akt_winh) = @_;

    # Zeichne den Hintergrund
    tex::bindTex( "s1_hintergrund" );
    tool::glFehler( "s1_show Hintergrund bindTex" );
    obj::showObj( "objHintergrund" );
    tool::glFehler( "s1_show Hintergrund showObj" );

    # die Perspektive laeuft auf den Mittelpunkt zu
    glViewport(0, 0, $akt_winw, $akt_winh);              

    # Projection Matrix festlegen
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;

    # Verzerrungswinkel
    gluPerspective(50.0, $akt_winw / $akt_winh, 0.1, 100.0);
    glMatrixMode(GL_MODELVIEW);

    # Zeichenstift auf 0, 0, 0 und die Rotation auf 0
    glLoadIdentity();

    # meine Kamera
    gluLookAt(
        # wo ist die Kamera plaziert
        $kamera_x, $kamera_y, $kamera_z, 
        # wohin schaut die Kamera
        0.0, 0.0, 0.0, 
        # der up Vector (wo ist oben)
        0.0, 1.0, 0.0
    );

    # Lege die Zeichenposition fest
    glTranslatef( ($kamera_x*(-1)) + $wuerfel_x, 
                  ($kamera_y*(-1)) + $wuerfel_y, 
                   $kamera_z*(-1));

    # Jetzt die Rotation
    glRotatef( $wuerfel_rx, 1.0, 0.0, 0.0);
    glRotatef( $wuerfel_ry, 0.0, 1.0, 0.0);
    glRotatef( $wuerfel_rz, 0.0, 0.0, 1.0);

    #glEnable(GL_VERTEX_PROGRAM_ARB);
    #glEnable(GL_FRAGMENT_PROGRAM_ARB);

    # zeichne einen Wuerfel
    obj::showObj( "objWuerfel" );
    tool::glFehler( "s1_show objWuerfel " );

    #glDisable(GL_FRAGMENT_PROGRAM_ARB);
    #glDisable(GL_VERTEX_PROGRAM_ARB);

    &physik();

}

#
# erzeuge das Menu für die Wuerfelbewegung
#
sub mkMenu {

  $menu{'musik'}{GLUT_KEY_UP}       = 'schlafen';
  $menu{'musik'}{GLUT_KEY_DOWN}     = 'bilder';
  $menu{'musik'}{GLUT_KEY_LEFT}     = 'kamera';
  $menu{'musik'}{GLUT_KEY_RIGHT}    = 'film';

  $menu{'schlafen'}{GLUT_KEY_UP}    = 'radio';
  $menu{'schlafen'}{GLUT_KEY_DOWN}  = 'musik';
  $menu{'schlafen'}{GLUT_KEY_LEFT}  = 'film';
  $menu{'schlafen'}{GLUT_KEY_RIGHT} = 'kamera';

  $menu{'radio'}{GLUT_KEY_UP}       = 'bilder';
  $menu{'radio'}{GLUT_KEY_DOWN}     = 'schlafen';
  $menu{'radio'}{GLUT_KEY_LEFT}     = 'film';
  $menu{'radio'}{GLUT_KEY_RIGHT}    = 'kamera';

  $menu{'bilder'}{GLUT_KEY_UP}      = 'musik';
  $menu{'bilder'}{GLUT_KEY_DOWN}    = 'radio';
  $menu{'bilder'}{GLUT_KEY_LEFT}    = 'film';
  $menu{'bilder'}{GLUT_KEY_RIGHT}   = 'kamera';

  $menu{'kamera'}{GLUT_KEY_UP}      = 'bilder';
  $menu{'kamera'}{GLUT_KEY_DOWN}    = 'schlafen';
  $menu{'kamera'}{GLUT_KEY_LEFT}    = 'radio';
  $menu{'kamera'}{GLUT_KEY_RIGHT}   = 'musik';

  $menu{'film'}{GLUT_KEY_UP}        = 'bilder';
  $menu{'film'}{GLUT_KEY_DOWN}      = 'schlafen';
  $menu{'film'}{GLUT_KEY_LEFT}      = 'musik';
  $menu{'film'}{GLUT_KEY_RIGHT}     = 'radio';

}

1;
