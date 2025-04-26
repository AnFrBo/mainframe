#!/opt/local/bin/perl

# Mainframe mit OpenGL
# Jack 1.4.2012

use strict;
use warnings;
no warnings 'once';

use OpenGL qw(:all);
use Time::HiRes qw( usleep );
use Readonly;
use Cwd;

# meine Module
use lib "lib";
require "glob.pm";
require "scene.pm";
require "text.pm";
require "tex.pm";
require "obj.pm";
require "mat.pm";
require "tool.pm";
require "bild.pm";
require "shader.pm";
require "player.pm";

tool::mfLog( 'info', "Programm $0 gestartet" );

# allgemeine Konstanten
use constant TRUE                   => 1;
use constant FALSE                  => 0;

# meine Konstanten um das Fenster zu inizialisieren
use constant INIT_FENSTER_BREITE    => 1024;
use constant INIT_FENSTER_HOEHE     => 768;
use constant INIT_FENSTER_POSX      => 50;
use constant INIT_FENSTER_POSY      => 80;
use constant FENSTER_TITEL          => "Mainframe";
 
# die Scene Typen
Readonly my $MENU_AUSWAHL       => 0;
Readonly my $MENU_ANZEIGE       => 1;
Readonly my $MENU_PARAMETER     => 2;

# Globale Variablen
my $window;
my ($akt_winw, $akt_winh, $sav_winw, $sav_winh, $sav_posx, $sav_posy);
my $licht = 1;
my $material = 1;                   # Material Beleuchtung
my $fullscreen = 1;
my $hideWindow = 0;

# fuer das Menu
my %mBaum;
my @aufrufStack;
my @aufrufStackParameter;
my $aktScene;

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

# Inizialisiere GLUT
glutInit;  
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);  

glutInitWindowSize(INIT_FENSTER_BREITE, INIT_FENSTER_HOEHE);  
glutInitWindowPosition(INIT_FENSTER_POSX, INIT_FENSTER_POSY);  

# Oeffne das Fenster
$window = glutCreateWindow( FENSTER_TITEL );

# Inizialisiere das Fenster
InitGL(INIT_FENSTER_BREITE, INIT_FENSTER_HOEHE);

# meine Callbacks
glutDisplayFunc(\&display);  
glutReshapeFunc(\&resize);
glutIdleFunc(\&herzschlag );
glutKeyboardFunc(\&nkey);
glutSpecialFunc(\&skey);
glutMouseFunc(\&mouse);
  
# OpenGL uebernimmt
glutMainLoop;  

return TRUE;

# -----------------------------------------------------------------------------
# Ende von Main
# -----------------------------------------------------------------------------


#
# Hier wird das Fenster inizialisiert
#
sub InitGL {

    ($akt_winw, $akt_winh) = @_;

    # erzeuge die Menu Steuerung
    &mkMenu();
    $aktScene = $glob::MENU;

    # Inizialisiere die erste Scene
    scene::init( $aktScene, (-1) );
    bild::init();

    # schalte Antialias ein
    #glEnable( GL_BLEND );
    #glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    #glEnable( GL_POINT_SMOOTH );
    #glEnable( GL_LINE_SMOOTH );

    # aktiviere das Textur Mapping
    glEnable( GL_TEXTURE_2D );

    # schwarz
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glShadeModel(GL_SMOOTH);   
  
    # der Tiefenbuffer
    glClearDepth( 1.0 );
    glEnable( GL_DEPTH_TEST );
    glDepthFunc( GL_LEQUAL );

    # wie wird die Perspektive angezeigt ?
    glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );

    # schalte das Licht ein
    #licht::licht01();
    glEnable(GL_LIGHTING);
    glEnable(GL_COLOR_MATERIAL);

    return( TRUE );
}

#
# mein Resize
#
sub resize {

    # hole die Breite und die Hoehe
    ($akt_winw, $akt_winh) = @_;

    # verhindert Division durch 0 Fehler
    if ($akt_winh == 0) { $akt_winh = 1; }

    # Melde die Fenstergroesse an die Scenen
    scene::setWindowSize( $akt_winw, $akt_winh );

    # passe den Viewport an
    # die Perspektive laeuft auf den Mittelpunkt zu
    glViewport(0, 0, $akt_winw, $akt_winh);              

    # Projection Matrix festlegen
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;

    # Verzerrungswinkel
    gluPerspective(50.0, $akt_winw/$akt_winh, 0.1, 100.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
}

#
# meine zeichen Funktion
#
sub display {

    # Loesche das aktuelle Bild
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();

    # Baue die Scene auf
    scene::show( $aktScene );
    tool::glFehler( "MF: " . $aktScene );

    # Zeige die Scene
    glutSwapBuffers;

}

#
# Tastatur (Spezial Tasten)
#
sub skey {

    my $key = shift;

    if( ! scene::isActive($aktScene) ) {
        if ($key == GLUT_KEY_UP) {
          scene::setAction( $aktScene, $key);
        } elsif ($key == GLUT_KEY_DOWN) {
          scene::setAction( $aktScene, $key);
        } elsif ($key == GLUT_KEY_LEFT) {
          scene::setAction( $aktScene, $key);
        } elsif ($key == GLUT_KEY_RIGHT) {
          scene::setAction( $aktScene, $key);
        }
    }
}

#
# Tastatur (normale Tasten)
#
sub nkey {

    my ($key, $x, $y) = @_;
   
    # Material
    if( $key == ord('m')) {
        $material = !$material;
        if( $material ) {
            glEnable( GL_COLOR_MATERIAL );
        } else {
            glDisable( GL_COLOR_MATERIAL );
        }
    }

    # Licht
    if( $key == ord('l')) {
        $licht = !$licht;
        if( $licht ) {
            glEnable( GL_LIGHTING );
        } else {
            glDisable( GL_LIGHTING );
        }
    }

    # Hide Window
    if ($key == ord('h')) {

        $hideWindow = !$hideWindow;
        if( $hideWindow ) {
            glutHideWindow();
        } else {
            glutShowWindow();
        }
    }

    # Fullscreen
    if ($key == ord('f')) {

        $fullscreen = !$fullscreen;
        if( $fullscreen ) {
            glutPositionWindow($sav_posx, $sav_posy);
            glutReshapeWindow($sav_winw, $sav_winh);
        } else {
            $sav_winw = $akt_winw;
            $sav_winh = $akt_winh;
            $sav_posx = glutGet( GLUT_WINDOW_X );
            $sav_posy = glutGet( GLUT_WINDOW_Y );
            glutFullScreen();
        }
    }

    # Scenen Wechsel
    if($key == $glob::KEY_ENTER && scene::getInfo($aktScene)) {
        if( $mBaum{$aktScene}{'typ'} == $MENU_AUSWAHL ) {
            push( @aufrufStack, $aktScene );
            push( @aufrufStackParameter, scene::getInfo( $aktScene ));
            $aktScene = $mBaum{$aktScene}{scene::getInfo( $aktScene )};
            scene::init( $aktScene, (-1) );
        } elsif( $mBaum{$aktScene}{'typ'} == $MENU_PARAMETER ) {
            push( @aufrufStack, $aktScene );
            push( @aufrufStackParameter, scene::getInfo( $aktScene ));
            my $parameter = scene::getInfo( $aktScene );
            $aktScene = $mBaum{$aktScene}{ $MENU_PARAMETER };
            scene::init( $aktScene, $parameter );
        } elsif( $mBaum{$aktScene}{'typ'} == $MENU_ANZEIGE ) {
            scene::setAction( $aktScene, $glob::KEY_ENTER );
        }
    }

    # eine Scene zurueck
    if($key == $glob::KEY_SPACE) {
        if($aktScene != $glob::MENU) {
            $aktScene = pop( @aufrufStack );
            scene::init( $aktScene, pop( @aufrufStackParameter ));
        }
    }

    # beenden
    if($key == $glob::KEY_ESCAPE || $key == ord('q')) { 
        # Shut down our window 
        beende("Schau, schau...");
    }
}


#
# Beende das Programm
#
sub beende
{

    my $s = shift @_;

    glutHideWindow();

    # Loesche die Callbacks
    glutKeyboardFunc( undef );
    glutSpecialFunc ( undef );
    glutMouseFunc   ( undef );
    glutIdleFunc    ( undef );
    glutReshapeFunc ( undef );

    # Loesche die Fonts Displaylisten
    text::beende();

    # Loesche die Objekte
    obj::beende();

    # Loesche die Texturen
    tex::beende();

    # Loesche die Bilder
    bild::beende();

    # Loesche die Materialien
    mat::beende();

    # Loesche die Shader
    shader::beende();

    # beende den mp3Player
    my ($status, $aktSec) = &mp3Player::getStatus();
    if( $status ) {
        &mp3Player::setPlayer( "QUIT" );
    }

    # das wars
    glutDestroyWindow($window);

    print("$s\n");

    exit FALSE;
}

#
# die Maus
#
sub mouse {

    my  ($button, $state, $x, $y) = @_;

    if( $button == GLUT_LEFT_BUTTON && $state == GLUT_DOWN ) {
        #glutIdleFunc( undef );
    }

    if( $button == GLUT_MIDDLE_BUTTON && $state == GLUT_DOWN ) {
        #glutIdleFunc( undef );
    }

    if( $button == GLUT_RIGHT_BUTTON && $state == GLUT_DOWN ) {
        beende( "Tschüss von der Maus" );
    }
}


#
# hier wird die Steuerung umgesetzt
#
sub herzschlag {

    # 10 Milli Sekunden, 100 Bilder pro Sekunde (theoretisch!)
     usleep( 10000 );

    # lasse den MP3 Player laufen
    &mp3Player::run();

    # und weiter gehts
    glutPostRedisplay();

}

#
# baue den Menubaum auf
#
sub mkMenu {

    # Hauptmenu
    $mBaum{$glob::MENU}{'typ'} = $MENU_AUSWAHL;
    $mBaum{$glob::MENU}{$glob::MENU_AUSWAHL_MUSIK}      = $glob::MENU_MUSIK_AUSWAHL;
    $mBaum{$glob::MENU}{$glob::MENU_AUSWAHL_KAMERA}     = $glob::MENU_KAMERA_AUSWAHL;
    $mBaum{$glob::MENU}{$glob::MENU_AUSWAHL_FILM}       = $glob::MENU_FILM_AUSWAHL;
    $mBaum{$glob::MENU}{$glob::MENU_AUSWAHL_BILDER}     = $glob::MENU_BILDER_AUSWAHL;
    $mBaum{$glob::MENU}{$glob::MENU_AUSWAHL_RADIO}      = $glob::MENU_RADIO_AUSWAHL;
    $mBaum{$glob::MENU}{$glob::MENU_AUSWAHL_SCHLAFEN}   = $glob::MENU_SCHLAFEN_AUSWAHL;

    # Musik
    $mBaum{$glob::MENU_MUSIK_AUSWAHL}{'typ'} = $MENU_AUSWAHL;
    $mBaum{$glob::MENU_MUSIK_AUSWAHL}{$glob::MENU_MUSIK_AUSWAHL_INTERPRET} = 
           $glob::MENU_MUSIK_INTERPRET;

    $mBaum{$glob::MENU_MUSIK_AUSWAHL}{$glob::MENU_MUSIK_AUSWAHL_PLAYLIST} = 
           $glob::MENU_MUSIK_PLAYLIST;

    $mBaum{$glob::MENU_MUSIK_AUSWAHL}{$glob::MENU_MUSIK_AUSWAHL_BESITZER} = 
           $glob::MENU_MUSIK_BESITZER;

    # Musik Auswahl ueber Interpret
    $mBaum{$glob::MENU_MUSIK_INTERPRET}{'typ'} = $MENU_PARAMETER;
    $mBaum{$glob::MENU_MUSIK_INTERPRET}{$MENU_PARAMETER} = $glob::MENU_MUSIK_ALBUM;

    $mBaum{$glob::MENU_MUSIK_ALBUM}{'typ'} = $MENU_PARAMETER;
    $mBaum{$glob::MENU_MUSIK_ALBUM}{$MENU_PARAMETER} = $glob::MENU_MUSIK_LIED;

    $mBaum{$glob::MENU_MUSIK_LIED}{'typ'} = $MENU_PARAMETER;
    $mBaum{$glob::MENU_MUSIK_LIED}{$MENU_PARAMETER} = $glob::MENU_MUSIK_PLAY;

    $mBaum{$glob::MENU_MUSIK_PLAY}{'typ'} = $MENU_ANZEIGE;

    # Kamera
    $mBaum{$glob::MENU_KAMERA_AUSWAHL}{'typ'} = $MENU_PARAMETER;
    $mBaum{$glob::MENU_KAMERA_AUSWAHL}{$MENU_PARAMETER} = $glob::MENU_KAMERA;

    $mBaum{$glob::MENU_KAMERA}{'typ'} = $MENU_ANZEIGE;

    # Film
    $mBaum{$glob::MENU_FILM_AUSWAHL}{'typ'} = $MENU_PARAMETER;
    $mBaum{$glob::MENU_FILM_AUSWAHL}{$MENU_PARAMETER} = $glob::MENU_FILM;

    $mBaum{$glob::MENU_FILM}{'typ'} = $MENU_ANZEIGE;
}
