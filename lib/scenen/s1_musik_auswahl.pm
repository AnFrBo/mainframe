#!/opt/local/bin/perl

# #########################################################################
#
# die Musik Auswahl Scene                  
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package s1_musik_auswahl;

use strict;
use warnings;

use OpenGL qw(:all);

use lib "lib";
require "glob.pm";
require "text.pm";
require "tex.pm";
require "obj.pm";
require "licht.pm";

# Definitionen
use constant {
    ZEILE_START_Y         => 1.0,
    ZEILE_HOME_Z          => -12.0,
    ZEILE_ABSTAND_Y       => 1.4,
    ZEILE_ABSTAND_Z       => -2.0,
    BEWEGUNG_Z            => 0.02,
};

# ein paar gobale
my $aktZeile = 0;
my @textZeile = (
                    "Musik Auswahl",
                    "Abspiel-Listen",
                    "Was geht, Pilger?",
                );
my $maxZeile = $#textZeile;

# Variablen fuer die Zeilen Bewegung
my ($kamera_x, $kamera_y, $kamera_z);
my (@aktp_x, @aktp_y, @aktp_z);
my (@zielp_z);

my $sceneInit = 0;

#
# Inizialisiere die Scene
#
sub init {

    # die Position der Kamera
    $kamera_x = 0.0;
    $kamera_y = 0,0;
    $kamera_z = 0.0;

    # die Position im Zeilen array
    $aktZeile = 0;

    # Inizalisiere die Text Positionen
    
    $aktp_x[0]  = (text::width3dText($textZeile[0]) / 2.0) * (-1);
    $aktp_y[0]  = ZEILE_START_Y;
    $aktp_z[0]  = ZEILE_HOME_Z - rand(10);
    $zielp_z[0] = ZEILE_HOME_Z;

    foreach (1..$maxZeile) {
        $aktp_x[$_]  = (text::width3dText($textZeile[$_]) / 2.0) * (-1);
        $aktp_y[$_]  = $aktp_y[$_-1] - ZEILE_ABSTAND_Y;
        $aktp_z[$_]  = ZEILE_HOME_Z - rand(10);
        $zielp_z[$_] = $zielp_z[$_-1] + ZEILE_ABSTAND_Z;
    }

    #schalte das Licht ein
    licht::licht01();
    
    $sceneInit = 1;
}

#
# gebe die Auswahlinfo zurueck
#
sub getInfo {

    my $ret = $glob::MENU_MUSIK_AUSWAHL_INTERPRET;

    if( $aktZeile == 1 ) {
        $ret = $glob::MENU_MUSIK_AUSWAHL_PLAYLIST;
    }

    if( $aktZeile == 2 ) {
        $ret = $glob::MENU_MUSIK_AUSWAHL_BESITZER;
    }

    return( $ret );

}

#
# kann die Scene Aufträge annehmen ?
#
sub isActive {

    # die Musik Auswahl Scene blockiert nicht !
    return( 0 );
}

#
# loese die Actionen der Scene aus
#
sub setAction {

    my $action = shift @_;

    if ($action == GLUT_KEY_UP) {
        $aktZeile--;
        if( $aktZeile < 0 ) {
            $aktZeile = $maxZeile;
        }
        &berechneZ();
    }

    elsif ($action == GLUT_KEY_DOWN) {
        $aktZeile++;
        if( $aktZeile > $maxZeile ) {
            $aktZeile = 0;
        }
        &berechneZ();
    }

    elsif ($action == GLUT_KEY_LEFT) {
    }

    elsif ($action == GLUT_KEY_RIGHT) {
    }
}

#
# Berechne die Ziel Position der Zeilen
#
sub berechneZ {

    foreach (0..$maxZeile) {
        $zielp_z[$_] = ZEILE_HOME_Z + (ZEILE_ABSTAND_Z * abs($aktZeile - $_));
    }

}

#
# Bewege die Textzeilen
#
sub physik {

    for (0..$maxZeile) {
        if( $aktp_z[$_] != $zielp_z[$_] ) {
            if($aktp_z[$_] > $zielp_z[$_]) {
                $aktp_z[$_] -= BEWEGUNG_Z;
            } else {
                $aktp_z[$_] += BEWEGUNG_Z;
            }
        }
    }
}

#
# Zeige die Scene
#
sub show {

    my ($akt_winw, $akt_winh) = @_;

    # Zeichne den Hintergrund
    #tex::bindTex( "s1_1_hintergrund" );
    #obj::showObj( "objHintergrund" );

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

    foreach (0..$maxZeile) {

        if($aktZeile == $_) {
            tex::bindTex( "silber" );
        } else {
            tex::bindTex( "gold" );
        }

        glLoadIdentity();
        glTranslatef( $aktp_x[$_], $aktp_y[$_], $aktp_z[$_]);
        text::print3d( $textZeile[$_] );
    }

    &physik();

}

1;
