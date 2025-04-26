#!/opt/local/bin/perl

# #########################################################################
#
# die Musik Auswahl Play Scene       
#
# Joachim Bothe 14.7.2012
#
# #########################################################################

package s1_musik_play;

use strict;
use warnings;
no warnings 'once';

use OpenGL qw(:all);
use Readonly;
use Cwd;
use Storable;

use lib "lib";
require "glob.pm";
require "tool.pm";
require "licht.pm";
require "player.pm";

Readonly my $TEST  => 0;
Readonly my $CNF_MAINFRAME  => getcwd() . "/" . $glob::INI_MAINFRAME;

# Definitionen
use constant {
    ZEILE_START_X         => -5.0,
    ZEILE_START_Y         => 3.0,
    ZEILE_HOME_Z          => -10.0,
    ZEILE_ABSTAND_Y       => 1.2,
    ZEILE_ABSTAND_Z       => -1.0,
    BEWEGUNG_Z            => 0.02,

    MAX_ZEILE             => 6,
};

my $max_zeile;
my $max_zeile_flag;

my ($kamera_x, $kamera_y, $kamera_z);

my (%master, %pl);

my $interpret_nr;
my $album_nr;
my $lied_nr;
my $playlist;

my $akt_pll_zeile = 0;
my $akt_txt_zeile = 0;

my @zeile_text;
my @zeile_akt_x;
my @zeile_akt_y;
my @zeile_akt_z;
my @zeile_ziel_x;
my @zeile_ziel_y;
my @zeile_ziel_z;

my $sceneInit = 0;

#
# Inizialisiere die Scene
#
sub init {

    my $tmp = shift @_;
    my @t = split( /;/, $tmp );

    $interpret_nr = $t[0] *1;
    $album_nr     = $t[1] *1;
    $lied_nr      = $t[2] *1;
    $playlist     = $t[3];

    tool::mfLog( 'trace', "s1_musik_play: Interpret: $interpret_nr Album: $album_nr" );
    tool::mfLog( 'trace', "s1_musik_play: Lied Nr.: $lied_nr Playlist: $playlist" );

    $akt_pll_zeile = 0;
    $akt_txt_zeile = 0;

    # die Position der Kamera
    $kamera_x = 0.0;
    $kamera_y = 0,0;
    $kamera_z = 2.0;

    #schalte das Licht ein
    licht::licht01();
    
    # Erzeuge das Steueungshash
    my %mcnf = tool::cnfLoad( $CNF_MAINFRAME );

    # Hole die mp3 Konfiguration
    %master = %{ retrieve( getcwd() . "/" . tool::cnfGet(\%mcnf, 'MUSIK', 'MASTER_FILE')) };

    my $lied_pos  = $master{$interpret_nr}{$album_nr}{$lied_nr}{'Nr'};

    # Starte den Player
    mp3Player::setPlayer( "PLAYLIST", $playlist );
    mp3Player::setPlayer( "PLAY", $lied_pos );
    
    #text::set3dFont( "Chancery" );
    #text::set3dFont( "Futura" );
    text::set3dFont( "BlackChancery" );

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

    my $ret = sprintf("%d;%d;%d", $interpret_nr, $album_nr, ($akt_pll_zeile + $akt_txt_zeile));
    return( $ret );
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
        mp3Player::setPlayer( "PAUSE" );
    }
}

sub movText {
}

#
# Berechne die Ziel Position der Zeilen
#
sub berechneZ {
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
    tex::bindTex( "strasse" );
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

    #&mp3Player::getStatus();
    &physik();

}



1;
