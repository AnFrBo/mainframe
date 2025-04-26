#!/opt/local/bin/perl

# #########################################################################
#
# die Kamera Anzeige Scene                  
#
# Joachim Bothe 1.6.2012
#
# #########################################################################

package s2_kamera;

use strict;
use warnings;
no warnings 'once';

use OpenGL qw(:all);
use Readonly;
use Cwd;
use Carp;
use Fcntl qw(:flock);
use Time::HiRes qw( usleep );

use lib "lib";
require "text.pm";
require "tex.pm";
require "obj.pm";
require "licht.pm";
require "tool.pm";

Readonly my $MODULE  => "s21: ";
Readonly my $CNF_MAINFRAME  => getcwd() . "/ini/mainframe.ini";

my ($kamera_x, $kamera_y, $kamera_z);
my ($picDir, $picDatei, $zalDatei);
my ($picTyp, $picMax, $picAkt);
my ($picDatei_akt, $pic_ID, $picPause);

my ($modus, $picLast);
Readonly my $MOD_AKTUEL  => 1;
Readonly my $MOD_FILM    => 2;

my $sceneInit = 0;

#
# Inizialisiere die Scene
#
sub init {

    $picDir = shift @_;
    tool::mfLog( 'trace', $MODULE . 'Bild Verzeichnis: ' . $picDir );

    $modus = $MOD_AKTUEL;
    $picDatei_akt = "";
    $pic_ID = 0;

    # die Position der Kamera
    $kamera_x = 0.0;
    $kamera_y = 0,0;
    $kamera_z = 2.0;

    #schalte das Licht ein
    licht::licht01();
    
    # Erzeuge die Steuerungsvariablen
    my %mcnf = tool::cnfLoad( $CNF_MAINFRAME );
    my $d = getcwd() . "/" . tool::cnfGet( \%mcnf, 'WEBCAM', 'DIR' ) . "/" . $picDir;
    $picDatei = $d . "/"   . tool::cnfGet( \%mcnf, 'WEBCAM', 'PIC_DATEI');
    $zalDatei = $d . "/"   . tool::cnfGet( \%mcnf, 'WEBCAM', 'ZAEHLER_DATEI');
    $picPause = tool::cnfGet( \%mcnf, 'WEBCAM', 'BILD_WECHSEL_PAUSE') * 1000;

    my %kcnf = tool::cnfLoad( getcwd() . "/" . tool::cnfGet( \%mcnf, 'WEBCAM', 'INI_DATEI' ));

    my $schluessel;
    foreach my $i (keys %kcnf) {
        $schluessel = $i;
        last if( tool::cnfGet( \%kcnf, $i, 'DIR' ) eq $picDir );
    }

    $picTyp  = tool::cnfGet( \%kcnf, $schluessel, 'TYP' );
    $picMax  = tool::cnfGet( \%kcnf, $schluessel, 'ANZAHL_PIC' );

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
# RETURN wird angenommen
#
sub getInfo {

    return(1);
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

        if( $modus == $MOD_AKTUEL ) {
            $modus = $MOD_FILM;
            if( -s $picDatei . sprintf( "%05d", $picMax ) . $picTyp ) {
                $picLast = $picAkt;
                $picAkt++;
            } else {
                $picLast = $picAkt -1;
                if( $picLast < 0 ) {
                    $picLast = 0;
                }
                $picAkt = -1;
            }
        }
    }

    elsif ($action == GLUT_KEY_RIGHT) {
        $modus = $MOD_AKTUEL;
    }

    elsif ($action == $glob::KEY_RETURN) {
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


    $pic_ID = 0;
    $picDatei_akt = &mkBildname();

    if( $picDatei_akt ) {
        glTranslatef( 0.0, 0.0, -1.15 );
        bild::showBild( $picDatei_akt, $pic_ID );
    }

    &physik();

}

#
# erzeuge den Namen der aktuellen Bilddatei
#
sub mkBildname {

    if( $modus == $MOD_AKTUEL ) {
          
        open my $zDatei, '<', $zalDatei or croak $!;
        flock( $zDatei, LOCK_SH); # shared lock
        $picAkt = <$zDatei>;
        close $zDatei; # entferne den Lock
        chomp( $picAkt );

        $picAkt--;
        if( $picAkt < 0 ) {
            if( -s $picDatei . sprintf( "%05d", $picMax ) . $picTyp ) {
                tool::mfLog( 'trace', $MODULE . 'Wrap around: ' . $picAkt );
                $picAkt = $picMax;
            } else {
                tool::mfLog( 'trace', $MODULE . 'Keine Bilddatei vorhanden');
                return(0);
            }
        }
    } else {

        usleep( $picPause );

        $picAkt++;

        tool::mfLog( 'trace', $MODULE . "picAkt: $picAkt, picLast: $picLast" );

        if( $picAkt > $picMax ) {
            $picAkt = 0;
        }
        if( $picAkt == $picLast ) {
            $modus = $MOD_AKTUEL;
        }
    }

    return( $picDatei . sprintf( "%05d", $picAkt ) . $picTyp );

}



1;
