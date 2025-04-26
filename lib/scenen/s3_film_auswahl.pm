#!/opt/local/bin/perl

# #########################################################################
#
# die Film Auswahl Scene                    
#
# Joachim Bothe 1.7.2012
#
# #########################################################################

package s3_film_auswahl;

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

my ($kamera_x, $kamera_y, $kamera_z);
my $kamera_speed;
my ($akt_x, $akt_y, $ziel_x, $ziel_y);
my ($rot_speed, $dreh_x);

my %film;
my $interpret_nr = 0;
my $film_nr = 0;
my $film_text = "";
my $film_front = "";
my $film_back = "";

my ($old_x, $old_y, $old_z, $old_texFront, $old_texBack, $film_ID);
my $sceneInit = 0;

#
# Inizialisiere die Scene
#
sub init {

    # die Position der Kamera
    $kamera_x = 0.0;
    $kamera_y = 0,0;
    $kamera_z = 13.5;

    $kamera_speed = 0.01;

    $akt_x = 0.0;
    $akt_y = 0.0;
    $ziel_x = 0.0;
    $ziel_y = 0.0;
    $rot_speed = 4.0;
    $dreh_x = 0;

    $old_x = 0;
    $old_y = 0;
    $old_z = 0;
    $old_texFront = "";
    $old_texBack = "";

    #schalte das Licht ein
    licht::licht02();
    
    if( ! $sceneInit ) {
        $film_ID = glGenLists(1);               # Hole eine Displayliste

        # Erzeuge das Steueungshash
        my %mcnf = tool::cnfLoad( $CNF_MAINFRAME );

        # Hole die Film Konfiguration
        my $workDir = getcwd();
        %film = %{ retrieve( $workDir . "/" . tool::cnfGet(\%mcnf, 'FILM', 'DATA')) };

        #text::set3dFont( "Chancery" );
        text::set3dFont( "Futura" );
        #text::set3dFont( "BlackChancery" );
    }

    $film_text  = $film{$interpret_nr}{$film_nr}{'TEXT'};
    $film_front = $film{$interpret_nr}{$film_nr}{'PIC'};
    $film_back  = $film{$interpret_nr}{$film_nr}{'PIC'};

    # starte den Quicktime Player (Work around wegen Apple Event -10000)
    my $doit = qq { osascript osa/start_qt.scpt };
    `$doit`;

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

    return( $film{$interpret_nr}{$film_nr}{'FILM'} );
}

#
# loese die Actionen der Scene aus
#
sub setAction {

    my $action = shift @_;

    if ($action == GLUT_KEY_UP) {

        if( $akt_x == $ziel_x && $akt_y == $ziel_y ) {

            my $old_film_nr = $film_nr;
            $film_nr = 0;
            my $old_interpret_nr = $interpret_nr;
            if( exists( $film{ $interpret_nr +1 } )) {
                $interpret_nr++;
            } else {
                $interpret_nr = 0;
            }

            $film_text  = $film{$interpret_nr}{$film_nr}{'TEXT'};
            $film_front = $film{$old_interpret_nr}{$old_film_nr}{'PIC'};
            $film_back  = $film{$interpret_nr}{$film_nr}{'PIC'};

            $ziel_x = 180;
            $akt_x  = 0;

            $akt_y  = 0;
            $ziel_y = 0;
            $dreh_x = 1;
        }
    }

    elsif ($action == GLUT_KEY_DOWN) {

        if( $akt_x == $ziel_x && $akt_y == $ziel_y ) {


            my $old_film_nr = $film_nr;
            $film_nr = 0;
            my $old_interpret_nr = $interpret_nr;
            if( $interpret_nr != 0 ) {
                $interpret_nr--;
            } else {
                my $i = 1;
                while( exists( $film{$i} )) {
                    $i++;
                }
                $interpret_nr = $i-1;
            }

            $film_text  = $film{$interpret_nr}{$film_nr}{'TEXT'};
            $film_front = $film{$old_interpret_nr}{$old_film_nr}{'PIC'};
            $film_back  = $film{$interpret_nr}{$film_nr}{'PIC'};

            $ziel_x = 180;
            $akt_x  = 360;

            $akt_y  = 0;
            $ziel_y = 0;
            $dreh_x = 1;
        }
    }

    elsif ($action == GLUT_KEY_LEFT) {
        if( $akt_y == $ziel_y && $akt_x == $ziel_x ) {

            my $old_film_nr = $film_nr;
            if( $film_nr != 0 ) {
                $film_nr--;
            } else {
                my $i = 1;
                while( exists( $film{$interpret_nr}{$i} )) {
                    $i++;
                }
                $film_nr = $i-1;
            }

            $film_text  = $film{$interpret_nr}{$film_nr}{'TEXT'};
            $film_front = $film{$interpret_nr}{$old_film_nr}{'PIC'};
            $film_back  = $film{$interpret_nr}{$film_nr}{'PIC'};

            $ziel_y = 180;
            $akt_y  = 360;

            $ziel_x = 0;
            $akt_x  = 0;
            $dreh_x = 0;
        }
    }

    elsif ($action == GLUT_KEY_RIGHT) {
        if( $akt_y == $ziel_y && $akt_x == $ziel_x ) {

            my $old_film_nr = $film_nr;
            if( exists( $film{$interpret_nr}{$film_nr +1} )) {
                $film_nr++;
            } else {
                $film_nr = 0;
            }

            $film_text  = $film{$interpret_nr}{$film_nr}{'TEXT'};
            $film_front = $film{$interpret_nr}{$old_film_nr}{'PIC'};
            $film_back  = $film{$interpret_nr}{$film_nr}{'PIC'};

            $ziel_y = 180;
            $akt_y  = 0;

            $ziel_x = 0;
            $akt_x  = 0;
            $dreh_x = 0;
        }
    }

    elsif ($action == $glob::KEY_ENTER) {
    }
}

#
# Bewege die Objekte
#
sub physik {

    if( $akt_y < $ziel_y ) {
        $akt_y += $rot_speed;
    }

    if( $akt_y > $ziel_y ) {
        $akt_y -= $rot_speed;
    }

    if( $akt_x < $ziel_x ) {
        $akt_x += $rot_speed;
    }

    if( $akt_x > $ziel_x ) {
        $akt_x -= $rot_speed;
    }
}

#
# Zeige die Scene
#
sub show {

    my ($akt_winw, $akt_winh) = @_;

    # Zeichne den Hintergrund
    #tex::bindTex( "s3_hintergrund" );
    #obj::showObj( "objHintergrund" );

    # die Perspektive laeuft auf den Mittelpunkt zu
    glViewport(0, 0, $akt_winw, $akt_winh);              

    # Projection Matrix festlegen
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;

    # Verzerrungswinkel
    gluPerspective(40.0, $akt_winw / $akt_winh, 0.1, 100.0);
    glMatrixMode(GL_MODELVIEW);

    # Zeichenstift auf 0, 0, 0 und die Rotation auf 0
    glLoadIdentity();

    # meine Kamera
    gluLookAt(
        # wo ist die Kamera plaziert
        0.0, 1.0, 8.5, 
        # wohin schaut die Kamera
        0.0, 0.0, 0.0, 
        #  der up Vector (wo ist oben)
        0.0, 1.0, 0.0
    );

    # zeichne das Kino
    obj::showObj( "objKino" );

    # zeige den Beschreibungstext
    glPushMatrix();
    tex::bindTex( "gruen" );
    glLoadIdentity();
    glScalef( 0.045, 0.045, 0.1 );
    glTranslatef( -5.2, 7.4, -12.0 );
    text::print3d( $film_text );
    glPopMatrix();

    # der Bildquarder
    glPushMatrix();
    glTranslatef( 0.0, 0.0, 0.0);
    glRotatef( $akt_y, 0.0, 1.0, 0.0);
    glRotatef( $akt_x, 1.0, 0.0, 0.0);
    &mkBildQuader( 3.2, 3.2, 0.25, $film_front, $film_back );
    glPopMatrix();

    &physik();

}

#
# Erzeuge den Bildquader
#
sub mkBildQuader {

    my ($x, $y, $z, $texFront, $texBack ) = @_;

    if( $x != $old_x || $y != $old_y || $z != $old_z 
        || $texFront ne $old_texFront || $texBack ne $old_texBack ) {

        tool::mfLog( 'trace', "s3_film_auswahl: mkBildQuarder neu film_ID: $film_ID" );

        $old_x = $x;
        $old_y = $y;
        $old_z = $z;
        $old_texBack = $texBack;
        $old_texFront = $texFront;

        glDeleteLists( $film_ID, 1 );
        glNewList( $film_ID, GL_COMPILE );

        $x /= 2; my $xm = $x * (-1);
        $y /= 2; my $ym = $y * (-1);
        $z /= 2; my $zm = $z * (-1);
        
        # eine GL_TEXTURE_2D wird festgelegt
        glEnable( GL_TEXTURE_2D );

        # die Textur wird festgelegt
        bild::bindTex( $texFront, 0 );

        # und immer schoen auf die Rotationsachsen achten
        glBegin( GL_QUADS );
            # Das vordere QUAD (zeigt zum Betrachter)
            glNormal3f(0.0, 0.0, 1.0);
            glTexCoord2f(0.0, 0.0); glVertex3f( $xm, $ym, $z); 
            # unten links an der Form und der Textur
            glTexCoord2f(1.0, 0.0); glVertex3f( $x,  $ym, $z); 
            # unten rechts an der Form und der Textur
            glTexCoord2f(1.0, 1.0); glVertex3f( $x,  $y,  $z); 
            # oben rechts an der Form und der Textur
            glTexCoord2f(0.0, 1.0); glVertex3f( $xm, $y,  $z); 
            # oben links an der Form und der Textur
        glEnd();

        bild::bindTex( $texBack, 1 );

        if( $dreh_x ) {
            glBegin( GL_QUADS );
                # Das hintere QUAD auf dem Kopf (zeigt vom Betrachter weg)
                glNormal3f(0.0, 0.0, -1.0);
                glTexCoord2f(0.0, 1.0); glVertex3f($xm, $ym, $zm);
                # unten rechts an der Form und der Textur
                glTexCoord2f(0.0, 0.0); glVertex3f($xm, $y, $zm);
                # oben rechts an der Form und der Textur
                glTexCoord2f(1.0, 0.0); glVertex3f( $x, $y, $zm);
                # oben links an der Form und der Textur
                glTexCoord2f(1.0, 1.0); glVertex3f( $x, $ym, $zm);
                # unten links an der Form und der Textur
            glEnd();
        } else {
            glBegin( GL_QUADS );
                # Das hintere QUAD (zeigt vom Betrachter weg)
                glNormal3f(0.0, 0.0, -1.0);
                glTexCoord2f(1.0, 0.0); glVertex3f($xm, $ym, $zm);
                # unten rechts an der Form und der Textur
                glTexCoord2f(1.0, 1.0); glVertex3f($xm, $y, $zm);
                # oben rechts an der Form und der Textur
                glTexCoord2f(0.0, 1.0); glVertex3f( $x, $y, $zm);
                # oben links an der Form und der Textur
                glTexCoord2f(0.0, 0.0); glVertex3f( $x, $ym, $zm);
                # unten links an der Form und der Textur
            glEnd();
        }

        tex::bindTex( "messing" );

        glBegin( GL_QUADS );
            # Das obere QUAD
            glNormal3f(0.0, 1.0, 0.0);
            glTexCoord2f(0.0, 1.0); glVertex3f($xm, $y, $zm); 
            # oben links an der Form und der Textur
            glTexCoord2f(0.0, 0.0); glVertex3f($xm, $y, $z); 
            # unten links an der Form und der Textur
            glTexCoord2f(1.0, 0.0); glVertex3f( $x, $y, $z); 
            # unten rechts an der Form und der Textur
            glTexCoord2f(1.0, 1.0); glVertex3f( $x, $y, $zm); 
            # oben rechts an der Form und der Textur
        glEnd();

        glBegin( GL_QUADS );
            # Das untere QUAD
            glNormal3f(0.0, -1.0, 0.0);
            glTexCoord2f(1.0, 1.0); glVertex3f($xm, $ym, $zm); 
            # oben rechts an der Form und der Textur
            glTexCoord2f(0.0, 1.0); glVertex3f( $x, $ym, $zm);
            # oben links an der Form und der Textur
            glTexCoord2f(0.0, 0.0); glVertex3f( $x, $ym, $z); 
            # unten links an der Form und der Textur
            glTexCoord2f(1.0, 0.0); glVertex3f($xm, $ym, $z); 
            # unten rechts an der Form und der Textur
        glEnd();

        glBegin( GL_QUADS );
            # Das rechte QUAD
            glNormal3f(1.0, 0.0, 0.0);
            glTexCoord2f(1.0, 0.0); glVertex3f( $x, $ym, $zm); 
            # unten rechts an der Form und der Textur
            glTexCoord2f(1.0, 1.0); glVertex3f( $x, $y, $zm); 
            # oben rechts an der Form und der Textur
            glTexCoord2f(0.0, 1.0); glVertex3f( $x, $y, $z); 
            # oben links an der Form und der Textur
            glTexCoord2f(0.0, 0.0); glVertex3f( $x, $ym, $z); 
            # unten links an der Form und der Textur
        glEnd();

        glBegin( GL_QUADS );
            # Das linke QUAD
            glNormal3f(-1.0, 0.0, 0.0);
            glTexCoord2f(0.0, 0.0); glVertex3f($xm, $ym, $zm); 
            # unten links an der Form und der Textur
            glTexCoord2f(1.0, 0.0); glVertex3f($xm, $ym, $z); 
            # unten rechts an der Form und der Textur
            glTexCoord2f(1.0, 1.0); glVertex3f($xm, $y, $z); 
            # oben rechts an der Form und der Textur
            glTexCoord2f(0.0, 1.0); glVertex3f($xm, $y, $zm); 
            # oben links an der Form und der Textur
        glEnd(); # Zeichenaktion beenden

        glEndList();
    }

    glCallList( $film_ID );

}



1;
