#!/opt/local/bin/perl

# #########################################################################
#
# das Scenen Template                       
#
# Joachim Bothe 1.7.2012
#
# #########################################################################

package xxx;

use strict;
use warnings;
no warnings 'once';

use OpenGL qw(:all);
use Readonly;
use Cwd;
use Storage;

use lib "lib";
require "glob.pm";
require "tool.pm";
require "licht.pm";

Readonly my $TEST  => 0;
Readonly my $CNF_MAINFRAME  => getcwd() . "/" . $glob::INI_MAINFRAME;

my ($kamera_x, $kamera_y, $kamera_z);

my $sceneInit = 0;

#
# Inizialisiere die Scene
#
sub init {

    # die Position der Kamera
    $kamera_x = 0.0;
    $kamera_y = 0,0;
    $kamera_z = 2.0;

    #schalte das Licht ein
    licht::licht01();
    
    # Erzeuge das Steueungshash
    
    my %mcnf = tool::cnfLoad( $CNF_MAINFRAME );
    my %kcnf = tool::cnfLoad( getcwd() . "/" . tool::cnfGet( \%mcnf, 'WEBCAM', 'INI_DATEI' ));

    foreach my $i (keys %kcnf) {
        tool::mfLog( 'trace', 's2: Verarbeite Nadel ' . $i );

        my $schluessel = tool::cnfGet( \%kcnf, $i, 'DIR' );

        #$st{$schluessel}{'LON'}     = tool::cnfGet( \%kcnf, $i, 'LON' );
    }

    $sceneInit = 1;
}

#
# Kann die Scene schlafen gelegt werden
#
sub isSleepy {

    return(0);
}

#
# kann die Scene Aufträge annehmen ?
#
sub isActive {

    # die Kamera Auswahl Scene blockiert nicht !
    return(0);
}

#
# beende die Scene
#
sub beende {
    
    return(0);
}

#
# liefere Steuerinformationen
#
sub getInfo {

    return(0);
}

#
# loese die Actionen der Scene aus
#
sub setAction {

    my $action = shift @_;

    if ($action == GLUT_KEY_UP) {
    }

    elsif ($action == GLUT_KEY_DOWN) {
    }

    elsif ($action == GLUT_KEY_LEFT) {
    }

    elsif ($action == GLUT_KEY_RIGHT) {
    }

    elsif ($action == $glob::KEY_ENTER) {
    }
}

#
# Bewege die Objekte
#
sub physik {

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
        #  der up Vector (wo ist oben)
        0.0, 1.0, 0.0
    );


    &physik();

}



1;
