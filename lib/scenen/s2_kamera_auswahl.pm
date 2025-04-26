#!/opt/local/bin/perl

# #########################################################################
#
# die Kamera Auswahl Scene                  
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package s2_kamera_auswahl;

use strict;
use warnings;

use OpenGL qw(:all);
use Readonly;
use Cwd;

use lib "lib";
require "text.pm";
require "tex.pm";
require "obj.pm";
require "licht.pm";
require "tool.pm";

Readonly my $TEST   => 0;
Readonly my $MODUL  => "s2: ";
Readonly my $CNF_MAINFRAME  => getcwd() . "/ini/mainframe.ini";

Readonly my $INIT_SPEED_RX => 0.0;

my $INIT_SPEED_RY;
if($TEST) {
$INIT_SPEED_RY = 0.0;
} else {
$INIT_SPEED_RY = 0.05;
}

Readonly my $INIT_SPEED_RZ => 0.0;
Readonly my $FLIEGE_FRAMES => 300;
Readonly my $ZOOM_FRAMES   => 150;

Readonly my $DOWN_LIMIT_RZ      => -1.4;
Readonly my $UP_LIMIT_RZ        => -2.5;
Readonly my $ABFLUG_ALARMZEIT   => 10;

Readonly my $TEXT_START_GROESSE => 0.001;
Readonly my $TEXT_ENDE_GROESSE  => 0.015;
Readonly my $TEXT_ANZAHL_FRAMES => 100;

# Meine Bewegugsmodi
Readonly my $MOD_GLOBUS  => 0;
Readonly my $MOD_FLIEGE  => 1;
Readonly my $MOD_INZOOM  => 2;
Readonly my $MOD_OUTZOOM => 3;
Readonly my $MOD_ORT     => 4;
Readonly my $MOD_RESET   => 5;

my $modus;
my $abflug_alarm;

# Konstanten zur Umrechnung
use constant PI => 3.14159265;
use constant DEG_2_RAD => ((PI)/180);
use constant RAD_2_DEG => (180/(PI));

# meine globalen Variablen
my ($kamera_x, $kamera_y, $kamera_z);
my ($akt_rx, $akt_ry, $akt_rz);
my ($home_rx, $home_ry, $home_rz);
my ($ziel_rx, $ziel_ry, $ziel_rz);
my ($speed_rx, $speed_ry, $speed_rz);
my ($textz_akt, $textz_speed);
my ($sav_rx, $sav_ry);
my $akt_frame = 0;
my $ziel;
my $alarm_flag = 0;

my %st;

my $sceneInit = 0;

#
# Inizialisiere die Scene
#
sub init {

    # setzte den Start Modus
    $modus = $MOD_GLOBUS;
    $ziel = "";

    # die Position der Kamera
    $kamera_x = 0.0;
    $kamera_y = 0,0;
    $kamera_z = 2.0;

    # Inizialisiere die Rotation
    $home_rx = -90.0;
    $home_ry = 0.0;
    $home_rz = $UP_LIMIT_RZ;

    $akt_rx = $home_rx;
    $akt_ry = $home_ry;
    $akt_rz = $home_rz;

    # die Geschwindigkeit der Rotation
    $speed_rx = $INIT_SPEED_RX;
    $speed_ry = $INIT_SPEED_RY;
    $speed_rz = $INIT_SPEED_RZ;

    $textz_akt = 0.0;
    $textz_speed = ($TEXT_ENDE_GROESSE - $TEXT_START_GROESSE) / $TEXT_ANZAHL_FRAMES;
    #schalte das Licht ein
    licht::licht01();
    
    # Erzeuge das Steueungshash
    
    my %mcnf = tool::cnfLoad( $CNF_MAINFRAME );
    my %kcnf = tool::cnfLoad( getcwd() . "/" . tool::cnfGet( \%mcnf, 'WEBCAM', 'INI_DATEI' ));

    foreach my $i (keys %kcnf) {
        tool::mfLog( 'trace', 's2: Verarbeite Nadel ' . $i );

        my $schluessel = tool::cnfGet( \%kcnf, $i, 'DIR' );

        $st{$schluessel}{'LON'}     = tool::cnfGet( \%kcnf, $i, 'LON' );
        $st{$schluessel}{'LAT'}     = tool::cnfGet( \%kcnf, $i, 'LAT' );
        $st{$schluessel}{'RX'}      = tool::cnfGet( \%kcnf, $i, 'RX' );
        $st{$schluessel}{'RY'}      = tool::cnfGet( \%kcnf, $i, 'RY' );
        $st{$schluessel}{'RZX'}     = tool::cnfGet( \%kcnf, $i, 'RZX' );
        $st{$schluessel}{'RZY'}     = tool::cnfGet( \%kcnf, $i, 'RZY' );
        $st{$schluessel}{'LAND'}    = tool::cnfGet( \%kcnf, $i, 'LAND' );
        $st{$schluessel}{'ORT'}     = tool::cnfGet( \%kcnf, $i, 'ORT' );
        $st{$schluessel}{'TEXT'}    = tool::cnfGet( \%kcnf, $i, 'TEXT' );
        $st{$schluessel}{'UP'}      = tool::cnfGet( \%kcnf, $i, 'UP' );
        $st{$schluessel}{'DOWN'}    = tool::cnfGet( \%kcnf, $i, 'DOWN' );
        $st{$schluessel}{'LEFT'}    = tool::cnfGet( \%kcnf, $i, 'LEFT' );
        $st{$schluessel}{'RIGHT'}   = tool::cnfGet( \%kcnf, $i, 'RIGHT' );
    }

    if( $TEST ) {
        text::set3dFont( "Futura" );
    } else {
        # text::set3dFont( "Chancery" );
        text::set3dFont( "Futura" );
        #text::set3dFont( "BlackChancery" );
    }

    $sceneInit = 1;
}

#
# kann die Scene Aufträge annehmen ?
#
sub isActive {

    # die Kamera Auswahl Scene blockiert nicht !
    return( 0 );
}

#
# liefere das Directory fuer die Bilddaten zurueck
#
sub getInfo {

    if( $ziel eq "" ) {
        return(0);
    } else {
        return( $ziel );
    }
}

#
# loese die Actionen der Scene aus
#
sub setAction {

    my $action = shift @_;

    if( ! $TEST ) {
        &findZiel( $action );

        $sav_rx = $akt_rx;
        $sav_ry = $akt_ry;

        $ziel_rx = $st{$ziel}{'RX'};
        $ziel_ry = $st{$ziel}{'RY'};

        $speed_rx = ($ziel_rx - $akt_rx) / $FLIEGE_FRAMES;
        $speed_ry = ($ziel_ry - $akt_ry) / $FLIEGE_FRAMES;

        $akt_frame = $FLIEGE_FRAMES;

        if( $modus == $MOD_RESET || $modus == $MOD_GLOBUS ) {
            $modus = $MOD_FLIEGE;
        } else {
            $modus = $MOD_OUTZOOM;
            $alarm_flag = 0;
            $sav_rx = $ziel_rx;
            $sav_ry = $ziel_ry;
            $speed_rz = (($akt_rz - $UP_LIMIT_RZ) / $ZOOM_FRAMES) * -1;
            $akt_frame = $ZOOM_FRAMES;
        }
    }

    if( $TEST ) {

        if ($action == GLUT_KEY_UP) {

            tool::mfLog( 'trace', 's2: KEY_UP akt_rx = ' . $akt_rx );
            $akt_rx -= 0.5;
        }

        elsif ($action == GLUT_KEY_DOWN) {
            tool::mfLog( 'trace', 's2: KEY_DOWN akt_rx = ' . $akt_rx );
            $akt_rx += 0.5;
        }

        elsif ($action == GLUT_KEY_LEFT) {

            tool::mfLog( 'trace', 's2: KEY_LEFT akt_ry = ' . $akt_ry );
            $akt_ry += 0.5;
        }

        elsif ($action == GLUT_KEY_RIGHT) {
            tool::mfLog( 'trace', 's2: KEY_RIGHT akt_ry = ' . $akt_ry );
            $akt_ry -= 0.5;
        }
    }
}

#
# Bewege die Weltkugel
#
sub physik {

    if( $modus == $MOD_ORT ) {
        if( time >= $abflug_alarm ) {
            $alarm_flag = 1;
            $modus = $MOD_OUTZOOM;
            $akt_frame = $ZOOM_FRAMES;
            $speed_rz = (($akt_rz - $UP_LIMIT_RZ) / $ZOOM_FRAMES) * -1;
        }
    }

    if( $modus == $MOD_RESET ) {
        $akt_frame--;
        if( $akt_frame <= 0 ) {
            $modus = $MOD_GLOBUS;
            $ziel = "";

            $speed_rx = $INIT_SPEED_RX;
            $speed_ry = $INIT_SPEED_RY;
            
            $akt_rx = $ziel_rx;
            $akt_ry = $ziel_ry;

            tool::mfLog( 'trace', 's2: akt_ry = ' . $akt_ry . " ziel_ry = " . $ziel_ry );
            tool::mfLog( 'trace', 's2: akt_rx = ' . $akt_rx . " ziel_rx = " . $ziel_rx );
        }
    }

    if( $modus == $MOD_FLIEGE ) {
        $akt_frame--;
        if( $akt_frame <= 0 ) {
            $modus = $MOD_INZOOM;

            $speed_rx = ($ziel_rx - $akt_rx) / $ZOOM_FRAMES;
            $speed_ry = ($ziel_ry - $akt_ry) / $ZOOM_FRAMES;
            $speed_rz = (($akt_rz - $DOWN_LIMIT_RZ) / $ZOOM_FRAMES) * -1;

            $akt_frame = $ZOOM_FRAMES;
            tool::mfLog( 'trace', 's2: akt_ry = ' . $akt_ry . " ziel_ry = " . $ziel_ry );
            tool::mfLog( 'trace', 's2: akt_rx = ' . $akt_rx . " ziel_rx = " . $ziel_rx );
        }
    }

    if( $modus == $MOD_INZOOM ) {
        $akt_frame--;

        # Stoppe die Rotation
        if( $akt_frame == 1 ) {
            $akt_rx = $ziel_rx;
            $akt_ry = $ziel_ry;
            $speed_rx = 0;
            $speed_ry = 0;
        }

        if( $akt_frame <= 0 ) {
            $modus = $MOD_ORT;
            $abflug_alarm = time + $ABFLUG_ALARMZEIT;

            $textz_akt = $TEXT_START_GROESSE;

            tool::mfLog( 'trace', 's2: akt_ry = ' . $akt_ry . " ziel_ry = " . $ziel_ry );
            tool::mfLog( 'trace', 's2: akt_rx = ' . $akt_rx . " ziel_rx = " . $ziel_rx );
        }
    }

    if( $modus == $MOD_ORT ) {

        if( $textz_akt < $TEXT_ENDE_GROESSE ) {
            $textz_akt += $textz_speed;
        }
    }

    if( $modus == $MOD_OUTZOOM ) {
        $akt_frame--;

        if( $akt_frame <= 0 ) {

            if( $alarm_flag ) {
                $modus = $MOD_RESET;
                $alarm_flag = 0;
                $sav_rx = $home_rx;
            } else {
                $modus = $MOD_FLIEGE;
            }

            $ziel_rx = $sav_rx;
            $ziel_ry = $sav_ry;

            $speed_rx = ($ziel_rx - $akt_rx) / $FLIEGE_FRAMES;
            $speed_ry = ($ziel_ry - $akt_ry) / $FLIEGE_FRAMES;
            $speed_rz = 0;

            $akt_frame = $FLIEGE_FRAMES;
        }
    }

    if( $modus != $MOD_ORT ) {
        $akt_rx = ($akt_rx + $speed_rx);
        if( $akt_rx >= 360 ) { 
            $akt_rx = 0;
        }

        $akt_ry = ($akt_ry + $speed_ry);
        if( $akt_ry >= 360 ) { 
            $akt_ry = 0;
        }

        $akt_rz = ($akt_rz + $speed_rz);
    }
}

#
# Zeige die Scene
#
sub show {

    my ($akt_winw, $akt_winh) = @_;

    # Zeichne den Hintergrund
    tex::bindTex( "sterne" );
    obj::showObj( "objHintergrund" );

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


    glLoadIdentity();

    if( $TEST ) {
        glPushMatrix();

        glBegin(GL_LINES);
        glVertex3f( -4.0, 0.0, -1.0);
        glVertex3f( 4.0,  0.0, -1.0);
        glEnd( );

        glBegin(GL_LINES);
        glVertex3f( 0.0,  -4.0, -1.0);
        glVertex3f( 0.0,   4.0, -1.0);
        glEnd( );

        tex::bindTex( "gruen" );
        glTranslatef( -12.0, 8.0, -20.0 );
        text::print3d( "RX: $akt_rx" );
        glLoadIdentity();
        glTranslatef( -12.0, 7.0, -20.0 );
        text::print3d( "RY: $akt_ry" );
        glPopMatrix();
    }


    glLoadIdentity();

    if( $TEST ) {
        glTranslatef( 0.0, 0.0, -2.0);
    } else {
        glTranslatef( 0.0, 0.0, $akt_rz);
    }

    glRotatef( $akt_ry, 0.0, 1.0, 0.0);
    glRotatef( $akt_rx, 1.0, 0.0, 0.0);

    # zeichne einen Globus
    obj::showObj( "objWeltkugel" );

    # zeichne die Nadeln
    my ($x, $y, $z);
    foreach my $i (keys %st) {

        glPushMatrix();
        ($x, $y, $z) = welt2xyz( $st{$i}{'LON'}, $st{$i}{'LAT'} -90, 1.05);
        glTranslatef( $x, $y, $z);

        if( $st{$i}{'LON'} > 0 ) {
            glRotatef( 90 + $st{$i}{'LON'}, 0.0, 1.0, 0.0 );
        } else {
            glRotatef( 90 + $st{$i}{'LON'}, 1.0, 0.0, 0.0 );
        }

        obj::showObj( "objNadelRot" );
        glPopMatrix();

    }
    
    # zeichne den Beschreibungstext
    if( $modus == $MOD_ORT ) {
        glPushMatrix();

        tex::bindTex( "gold" );

        glLoadIdentity();
        glScalef( $textz_akt, $textz_akt, 0.1 );
        glTranslatef( 1.0, 1.0, -2.0 );
        text::print3d( "$st{$ziel}{'LAND'}" );

        glLoadIdentity();
        glScalef( $textz_akt, $textz_akt, 0.1 );
        glTranslatef( 1.0, 0.0, -2.0 );
        text::print3d( "$st{$ziel}{'ORT'}" );

        glLoadIdentity();
        glScalef( $textz_akt, $textz_akt, 0.1 );
        glTranslatef( 1.0, -1.0, -2.0 );
        text::print3d( "$st{$ziel}{'TEXT'}" );

        glPopMatrix();
    }


    &physik();

}

#
# erzeuge aus latitude/longitude Koordinaten 3D Koordinaten
#
sub welt2xyz {

    my ($lat, $lon, $radius) = @_;

    $lat *= DEG_2_RAD;
    $lon *= DEG_2_RAD;

    my $cos_lat = $radius * cos($lat);

    my $x = $cos_lat * cos($lon);
    my $y = $cos_lat * sin($lon);
    my $z = $radius  * sin($lat);

    return( $x, $y, $z );
}

#
# finde ein Ziel auf der Karte
#
sub findZiel {

    my $action = shift @_;

    tool::mfLog( 'trace', 's2: findZiel akt_ry = ' . $akt_ry );
    tool::mfLog( 'trace', 's2: findZiel akt_rx = ' . $akt_rx );

    if( $akt_rx == $home_rx ) {

        if( $action == GLUT_KEY_LEFT && ($akt_ry <= 76)) {
            $ziel = "miraflores";
        }

        if( $action == GLUT_KEY_LEFT && ($akt_ry > 76)) {
            $ziel = "sydney";
        }

        if( $action == GLUT_KEY_RIGHT && ($akt_ry <= 76)) {
            $ziel = "sydney";
        }

        if( $action == GLUT_KEY_RIGHT && ($akt_ry > 76)) {
            $ziel = "miraflores";
        }

        if( $action == GLUT_KEY_UP && ($akt_ry <= 50 )) {
            $ziel = "halifax";
        }

        if( $action == GLUT_KEY_UP && ($akt_ry > 50 )) {
            $ziel = "yellowstone";
        }

        if( $action == GLUT_KEY_DOWN && ($akt_ry <= 76)) {
            $ziel = "miraflores";
        }

        if( $action == GLUT_KEY_DOWN && ($akt_ry > 76)) {
            $ziel = "sydney";
        }

    } else {
        if( $action == GLUT_KEY_LEFT )  { $ziel = $st{$ziel}{'LEFT'}; }
        if( $action == GLUT_KEY_RIGHT ) { $ziel = $st{$ziel}{'RIGHT'}; }
        if( $action == GLUT_KEY_UP )    { $ziel = $st{$ziel}{'UP'}; }
        if( $action == GLUT_KEY_DOWN )  { $ziel = $st{$ziel}{'DOWN'}; }
    }

    tool::mfLog( 'trace', 's2: findZiel ziel = ' . $ziel );
}





1;
