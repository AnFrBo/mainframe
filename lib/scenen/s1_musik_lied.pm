#!/opt/local/bin/perl

# #########################################################################
#
# die Musik Auswahl Lied Scene       
#
# Joachim Bothe 14.7.2012
#
# #########################################################################

package s1_musik_lied;

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

my %master;

my $interpret_nr;
my $album_nr;

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
    $album_nr = $t[1] *1;

    tool::mfLog( 'trace', "s1_musik_lied: Interpret: $interpret_nr Album: $album_nr" );

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

    # Wieviel Alben gibt es ?
    $max_zeile = $master{$interpret_nr}{$album_nr}{'MAX_LIED'};
    tool::mfLog( 'trace', "s1_musik_lied: $max_zeile" );
    if( $max_zeile > MAX_ZEILE ) {
        $max_zeile = MAX_ZEILE;
        $max_zeile_flag = 1;
    } else {
        $max_zeile_flag = 0;
    }

    &movText();

    # Inizialisiere den Text
    foreach (0..$max_zeile) {

        $zeile_akt_x[$_]  = (text::width3dText($zeile_text[$_]) / 2.0) * (-1);
        $zeile_akt_y[$_] =  ZEILE_START_Y - (ZEILE_ABSTAND_Y * $_);
        $zeile_akt_z[$_] =  ZEILE_HOME_Z  + (ZEILE_ABSTAND_Z * $_);

        $zeile_akt_x[$_]  = (text::width3dText($zeile_text[$_]) / 2.0) * (-1);
        $zeile_ziel_y[$_] =  ZEILE_START_Y - (ZEILE_ABSTAND_Y * $_);
        $zeile_ziel_z[$_] =  ZEILE_HOME_Z  + (ZEILE_ABSTAND_Z * $_);
    }

    &berechneZ();

    #text::set3dFont( "Chancery" );
    text::set3dFont( "Futura" );
    #text::set3dFont( "BlackChancery" );

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

    my $ret = sprintf("%d;%d;%d;data/all.sto", 
                      $interpret_nr, $album_nr, ($akt_pll_zeile + $akt_txt_zeile));
    return( $ret );
}

#
# loese die Actionen der Scene aus
#
sub setAction {

    my $action = shift @_;

    if ($action == GLUT_KEY_UP) {
        $akt_txt_zeile--;
        if( $akt_txt_zeile < 0 ) {
            if( $max_zeile_flag ) {
                $akt_pll_zeile--;
                if( $akt_pll_zeile < 0 ) {
                    $akt_pll_zeile = $master{$interpret_nr}{$album_nr}{'MAX_LIED'};
                }
                $akt_txt_zeile = 0;
            } else {
                $akt_txt_zeile = $max_zeile;
            }
        }
        &berechneZ();
        &movText();
    }

    elsif ($action == GLUT_KEY_DOWN) {
        $akt_txt_zeile++;
        if( $akt_txt_zeile > $max_zeile ) {
            if( $max_zeile_flag ) {
                $akt_pll_zeile++;
                if( $akt_pll_zeile > $master{$interpret_nr}{$album_nr}{'MAX_LIED'} ) {
                    $akt_pll_zeile = 0;
                }
                $akt_txt_zeile = $max_zeile;
            } else {
                $akt_txt_zeile = 0;
            }
        }
        &berechneZ();
        &movText();
    }

    elsif ($action == GLUT_KEY_LEFT) {
    }

    elsif ($action == GLUT_KEY_RIGHT) {
    }

    elsif ($action == $glob::KEY_ENTER) {
    }
}

sub movText {

    my $pl_zeile;

    foreach (0..$max_zeile) {

        $pl_zeile = $_ + $akt_pll_zeile;

        if( $pl_zeile > $master{$interpret_nr}{$album_nr}{'MAX_LIED'}) {
            $pl_zeile -= $master{$interpret_nr}{$album_nr}{'MAX_LIED'} +1;
        }
        if( $pl_zeile < 0) {
            $pl_zeile += $master{$interpret_nr}{$album_nr}{'MAX_LIED'} -1;
        }
        $zeile_text[$_] = $master{$interpret_nr}{$album_nr}{$pl_zeile}{'TITEL'};
        $zeile_akt_x[$_]  = (text::width3dText($zeile_text[$_]) / 2.0) * (-1);
    }
}

#
# Berechne die Ziel Position der Zeilen
#
sub berechneZ {

    foreach (0..$max_zeile) {
        $zeile_ziel_z[$_] = ZEILE_HOME_Z + (ZEILE_ABSTAND_Z * abs($akt_txt_zeile - $_));
    }

}

#
# Bewege die Objekte
#
sub physik {

    for (0..$max_zeile) {
        if( $zeile_akt_z[$_] != $zeile_ziel_z[$_] ) {
            if($zeile_akt_z[$_] > $zeile_ziel_z[$_]) {
                $zeile_akt_z[$_] -= BEWEGUNG_Z;
            } else {
                $zeile_akt_z[$_] += BEWEGUNG_Z;
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
    #tex::bindTex( "strasse" );
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

    foreach (0..$max_zeile) {

        if($akt_txt_zeile == $_) {
            tex::bindTex( "silber" );
        } else {
            tex::bindTex( "gold" );
        }

        glLoadIdentity();
        glTranslatef( $zeile_akt_x[$_], $zeile_akt_y[$_], $zeile_akt_z[$_]);
        text::print3d( $zeile_text[$_] );
    }

    &physik();

}



1;
