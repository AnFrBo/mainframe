#!/opt/local/bin/perl

# #########################################################################
#
# alle Glu und Obj Objecte werden verwaltet
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package obj;

use strict;
use warnings;


use OpenGL qw(:all);

use lib "lib";
require "tex.pm";
require "mat.pm";

use constant {
    HINTERGRUND         => 'objHintergrund',
    WUERFEL             => 'objWuerfel',
    EARTH               => 'objEarth',
};

my %obj;
my $objInit = 0;

sub init {

    my $current = glGenLists(64);              # Hole ein paar Displaylisten

    # Mein Hintergrundbild
    $obj{'objHintergrund'} = $current++;
    glNewList($obj{'objHintergrund'}, GL_COMPILE);
        &mkHintergrund();
    glEndList();

    # der Wuerfel fuer das Hauptmenu
    $obj{'objWuerfel'} = $current++;
    glNewList($obj{'objWuerfel'}, GL_COMPILE);
        &mkWuerfel();
    glEndList();

    # der Kinosaal
    $obj{'objKino'} = $current++;
    glNewList($obj{'objKino'}, GL_COMPILE);
        &mkKino();
    glEndList();

    # eine Weltkugel
    $obj{'objWeltkugel'} = $current++;
    glNewList($obj{'objWeltkugel'}, GL_COMPILE);
        &mkWeltkugel();
    glEndList();

    # eine rote Nadel
    $obj{'objNadelRot'} = $current++;
    glNewList($obj{'objNadelRot'}, GL_COMPILE);
        &mkNadelRot();
    glEndList();

    # eine gruene Nadel
    $obj{'objNadelGruen'} = $current++;
    glNewList($obj{'objNadelGruen'}, GL_COMPILE);
        &mkNadelGruen();
    glEndList();

    $objInit = 1;
}

#
# Loesche alle Objekte
#
sub beende {

    foreach my $i (values %obj) {
        glDeleteLists( $i, 1);
    }
}

#
# zeichne ein Object in den aktuellen Kontext
#
sub showObj {

    my $objName = shift @_;

    if(! $objInit) {
        &init();
    };

    glCallList( $obj{$objName} );

}

#
# Erzeuge das Objekt fuer den Hintergrund
#
sub mkHintergrund {

    # zeichne das Hintergrundbild
    glDisable(GL_DEPTH_TEST);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    glOrtho(0.0,    # left
            1.0,    # right
            1.0,    # bottom
            0.0,    # top
           -0.1,    # near
            1.0     # far
           );

    glBegin(GL_QUADS);

        glNormal3f(0.0, 0.0, 1.0);
        glTexCoord2f(0.0, 1.0); glVertex2f( 0.0, 0.0); 
        glTexCoord2f(1.0, 1.0); glVertex2f( 1.0, 0.0); 
        glTexCoord2f(1.0, 0.0); glVertex2f( 1.0, 1.0); 
        glTexCoord2f(0.0, 0.0); glVertex2f( 0.0, 1.0); 

    glEnd();

    glEnable(GL_DEPTH_TEST);
    glClear(GL_DEPTH_BUFFER_BIT);

}

#
# Erzeuge das Objekt fuer den Wuerfel
#
sub mkWuerfel {

    # eine GL_TEXTURE_2D wird festgelegt
    glEnable( GL_TEXTURE_2D );

    # die Textur wird festgelegt
    tex::bindTex( "musik" );

    # und immer schoen auf die Rotationsachsen achten
    glBegin( GL_QUADS );
        # Das vordere QUAD (zeigt zum Betrachter)
        glNormal3f(0.0, 0.0, 1.0);
        glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, 1.0); 
        # unten links an der Form und der Textur
        glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, 1.0); 
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f( 1.0, 1.0, 1.0); 
        # oben rechts an der Form und der Textur
        glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, 1.0); 
        # oben links an der Form und der Textur
    glEnd();

    tex::bindTex( "radio" );

    glBegin( GL_QUADS );
        # Das hintere QUAD (zeigt vom Betrachter weg)
        glNormal3f(0.0, 0.0, -1.0);
        glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, 1.0, -1.0);
        # oben rechts an der Form und der Textur
        glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, 1.0, -1.0);
        # oben links an der Form und der Textur
        glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);
        # unten links an der Form und der Textur
    glEnd();

    tex::bindTex( "bilder" );

    glBegin( GL_QUADS );
        # Das obere QUAD
        glNormal3f(0.0, 1.0, 0.0);
        glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, -1.0); 
        # oben links an der Form und der Textur
        glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, 1.0, 1.0); 
        # unten links an der Form und der Textur
        glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, 1.0, 1.0); 
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f( 1.0, 1.0, -1.0); 
        # oben rechts an der Form und der Textur
    glEnd();

    tex::bindTex( "schlafen" );

    glBegin( GL_QUADS );
        # Das untere QUAD
        glNormal3f(0.0, -1.0, 0.0);
        glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0); 
        # oben rechts an der Form und der Textur
        glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0);
        # oben links an der Form und der Textur
        glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, 1.0); 
        # unten links an der Form und der Textur
        glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, 1.0); 
        # unten rechts an der Form und der Textur
    glEnd();

    tex::bindTex( "kamera" );

    glBegin( GL_QUADS );
        # Das rechte QUAD
        glNormal3f(1.0, 0.0, 0.0);
        glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0); 
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f( 1.0, 1.0, -1.0); 
        # oben rechts an der Form und der Textur
        glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, 1.0, 1.0); 
        # oben links an der Form und der Textur
        glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, 1.0); 
        # unten links an der Form und der Textur
    glEnd();

    tex::bindTex( "film" );

    glBegin( GL_QUADS );
        # Das linke QUAD
        glNormal3f(-1.0, 0.0, 0.0);
        glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0); 
        # unten links an der Form und der Textur
        glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, 1.0); 
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, 1.0, 1.0); 
        # oben rechts an der Form und der Textur
        glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, -1.0); 
        # oben links an der Form und der Textur
    glEnd(); # Zeichenaktion beenden

}

#
# Erzeuge einen Quader
#
sub mkQuader {

    my ($x, $y, $z, $tex) = @_;

    $x /= 2; my $xm = $x * (-1);
    $y /= 2; my $ym = $y * (-1);
    $z /= 2; my $zm = $z * (-1);
    
    # eine GL_TEXTURE_2D wird festgelegt
    glEnable( GL_TEXTURE_2D );

    # die Textur wird festgelegt
    tex::bindTex( $tex );

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

}

#
# meine Kugel
#
sub mkKugel {
    
    my ($groesse, $aufloesung, $tex) = @_;

    my $quad = gluNewQuadric();
    gluQuadricNormals($quad, GLU_SMOOTH);
    gluQuadricTexture($quad, GL_TRUE);

    tex::bindTex( $tex );

    gluSphere($quad, $groesse, $aufloesung, $aufloesung);
    gluDeleteQuadric($quad);

}

#
# mein Globus
#
sub mkWeltkugel {
    

    my $quad = gluNewQuadric();
    gluQuadricNormals($quad, GLU_SMOOTH);
    gluQuadricTexture($quad, GL_TRUE);

    tex::bindTex( "welt" );

    gluSphere($quad, 1.0, 64, 64);
    gluDeleteQuadric($quad);

}

#
# eine gruene Positionsnadel fuer meinen Globus
#
sub mkNadelGruen {

    tex::bindTex( "gruen" );
    &mkNadel();

}

#
# eine rote Positionsnadel fuer meinen Globus
#
sub mkNadelRot {

    tex::bindTex( "rot" );
    &mkNadel();

}

#
# eine Positionsnadel fuer meinen Globus
#
sub mkNadel {
    
    my $quad;

    glScalef( 0.02, 0.02, 0.02 );

    $quad = gluNewQuadric();
    gluQuadricDrawStyle($quad, GLU_FILL);
    gluQuadricNormals($quad, GLU_SMOOTH);
    gluQuadricOrientation($quad, GLU_OUTSIDE);
    gluQuadricTexture($quad, GL_TRUE);

    gluSphere($quad, 0.8, 32, 32);
    gluDeleteQuadric($quad);

    $quad = gluNewQuadric();
    gluQuadricDrawStyle($quad, GLU_FILL);
    gluQuadricNormals($quad, GLU_SMOOTH);
    gluQuadricOrientation($quad, GLU_OUTSIDE);
    gluQuadricTexture($quad, GL_TRUE);

    tex::bindTex( "silber" );

    gluCylinder($quad, 0.15, 0.15, 4.0, 16, 16);
    gluDeleteQuadric($quad);
}

sub mkKino {

    my $mauer_hoehe  = 5.0;
    my $mauer_breite = 6.0;
    my $mauer_laenge = 9.0;
    my $mauer_y      = 2.5;

    glPushMatrix();
    tex::bindTex( "strasse" );
    glTranslatef( 0.0, -$mauer_y, 0.0);

    # Die Strasse
    glBegin( GL_QUADS );

        glNormal3f(0.0, 1.0, 0.0);

        glTexCoord2f(0.0, 1.0); glVertex3f(-$mauer_breite, 0.0, -$mauer_laenge); 
        # oben links an der Form und der Textur
        glTexCoord2f(0.0, 0.0); glVertex3f(-$mauer_breite, 0.0, $mauer_laenge); 
        # unten links an der Form und der Textur
        glTexCoord2f(1.0, 0.0); glVertex3f( $mauer_breite, 0.0, $mauer_laenge); 
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f( $mauer_breite, 0.0, -$mauer_laenge); 
        # oben rechts an der Form und der Textur

    glEnd();
    glPopMatrix();

    glPushMatrix();
    tex::bindTex( "ziegel" );
    glTranslatef( -$mauer_breite, $mauer_y, 0.0);

    glBegin( GL_QUADS );
        # Die linke Wand
        glNormal3f(1.0, 0.0, 0.0);

        glTexCoord2f(1.0, 0.0); glVertex3f( 0.0, -$mauer_hoehe, -$mauer_laenge); 
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f( 0.0, $mauer_hoehe, -$mauer_laenge); 
        # oben rechts an der Form und der Textur
        glTexCoord2f(0.0, 1.0); glVertex3f( 0.0, $mauer_hoehe, $mauer_laenge); 
        # oben links an der Form und der Textur
        glTexCoord2f(0.0, 0.0); glVertex3f( 0.0, -$mauer_hoehe, $mauer_laenge); 
        # unten links an der Form und der Textur
    glEnd();

    glPopMatrix();

    glPushMatrix();
    tex::bindTex( "ziegel" );
    glTranslatef( $mauer_breite, $mauer_y, 0.0);

    glBegin( GL_QUADS );
        # Die rechte Wand
        glNormal3f(-1.0, 0.0, 0.0);

        glTexCoord2f(0.0, 0.0); glVertex3f(0.0, -$mauer_hoehe, -$mauer_laenge); 
        # unten links an der Form und der Textur
        glTexCoord2f(1.0, 0.0); glVertex3f(0.0, -$mauer_hoehe, $mauer_laenge); 
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f(0.0, $mauer_hoehe, $mauer_laenge); 
        # oben rechts an der Form und der Textur
        glTexCoord2f(0.0, 1.0); glVertex3f(0.0, $mauer_hoehe, -$mauer_laenge); 
        # oben links an der Form und der Textur
    glEnd(); # Zeichenaktion beenden

    glPopMatrix();

    glPushMatrix();
    tex::bindTex( "ziegel" );
    glTranslatef( 0.0, $mauer_y, -$mauer_laenge);

    glBegin( GL_QUADS );
        # Das hintere Wand
        glNormal3f(0.0, 0.0, -1.0);
        glTexCoord2f(1.0, 0.0); glVertex3f(-$mauer_breite, -$mauer_hoehe, 0.0);
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f(-$mauer_breite, $mauer_hoehe, 0.0);
        # oben rechts an der Form und der Textur
        glTexCoord2f(0.0, 1.0); glVertex3f( $mauer_breite, $mauer_hoehe, 0.0);
        # oben links an der Form und der Textur
        glTexCoord2f(0.0, 0.0); glVertex3f( $mauer_breite, -$mauer_hoehe, 0.0);
        # unten links an der Form und der Textur
    glEnd();

    glPopMatrix();

    # der Filmauswaehler
    glPushMatrix();
    glTranslatef( -2.0, 0.0, 0.0 );
    mkQuader( 0.25, 3.75, 0.25, "messing" );
    glPopMatrix();

    glPushMatrix();
    glTranslatef( 2.0, 0.0, 0.0 );
    mkQuader( 0.25, 3.75, 0.25, "messing" );
    glPopMatrix();

    glPushMatrix();
    glTranslatef( 0.0, 2.0, 0.0 );
    glRotatef( 90.0, 0.0, 0.0, 1.0);
    mkQuader( 0.25, 4.25, 0.25, "messing" );
    glPopMatrix();

    glPushMatrix();
    glTranslatef( 0.0, -2.0, 0.0 );
    glRotatef( 90.0, 0.0, 0.0, 1.0);
    mkQuader( 0.25, 4.25, 0.25, "messing" );
    glPopMatrix();

    glPushMatrix();
    glTranslatef( 0.0, 2.75, 0.0 );
    glRotatef( 90.0, 0.0, 0.0, 1.0);
    mkQuader( 0.25, 4.25, 0.25, "messing" );
    glPopMatrix();

    glPushMatrix();
    glTranslatef( 1.875, 2.375, 0.0 );
    glRotatef( 90.0, 0.0, 0.0, 1.0);
    mkQuader( 0.50, 0.50, 0.25, "leer" );
    glPopMatrix();

    glPushMatrix();
    glTranslatef( -1.875, 2.375, 0.0 );
    glRotatef( 90.0, 0.0, 0.0, 1.0);
    mkQuader( 0.50, 0.50, 0.25, "leer" );
    glPopMatrix();

    glPushMatrix();
    glTranslatef( 0.0, 2.375, 0.0 );
    glRotatef( 90.0, 0.0, 0.0, 1.0);
    mkQuader( 0.40, 3.25, 0.01, "papier" );
    glPopMatrix();

    glPushMatrix();
    glTranslatef( -1.5, -2.375, 0.0 );
    glRotatef( 90.0, 0.0, 0.0, 1.0);
    mkQuader( 0.50, 0.25, 0.25, "leer" );
    glPopMatrix();

    glPushMatrix();
    glTranslatef( 1.5, -2.375, 0.0 );
    glRotatef( 90.0, 0.0, 0.0, 1.0);
    mkQuader( 0.50, 0.25, 0.25, "leer" );
    glPopMatrix();

}


1;
