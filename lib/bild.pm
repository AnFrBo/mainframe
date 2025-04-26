#!/opt/local/bin/perl

# #########################################################################
#
# Funktionen zum Bilder anzeigen
#
# Joachim Bothe 1.6.2012
#
# #########################################################################

package bild;

use strict;
use warnings;
no warnings 'once';

use OpenGL qw(:all);
use OpenGL::Image;
use Readonly;

use lib "lib";
require "glob.pm";
require "tool.pm";

Readonly my $MODULE => "bild: ";
Readonly my $MAX_BILD => 4;

my %bild;
my $bildInit = 0;

sub init {

    my $current_bild = glGenLists($MAX_BILD);              # Hole ein paar Displaylisten
    my $current_obj  = glGenLists($MAX_BILD);              # Hole ein paar Displaylisten

    # verwalte Bilder
    my $i = $MAX_BILD;
    while( $i-- ) {

        $bild{$i}{'Bild_ID'} = $current_bild++;
        $bild{$i}{'Obj_ID'}  = $current_obj++;
        $bild{$i}{'active'}  = $glob::FALSE;

    }

    $bildInit = 1;
}

#
# Lade ein Bild
#
sub ladeBild
{

    my $bild_nr = shift @_;
    my $dat_name = $bild{$bild_nr}{'name'};
    my $b;

    $b = new OpenGL::Image(engine => 'Magick', source => $dat_name);
    if( !$b ) {
        tool::mfLog( 'error', $MODULE . 'Konnte ' . $dat_name . ' nicht laden' );
        return;
    }

    # Sage OpenGL das es eine 2D Textur ist
    glBindTexture( GL_TEXTURE_2D, $bild{$bild_nr}{'Bild_ID'} );

    # Speichere die Bild Dimensionen
    my ($w, $h) = $b->Get( 'width', 'height' );
    $bild{$bild_nr}{'width'}  = $w; 
    $bild{$bild_nr}{'height'} = $h; 

    gluBuild2DMipmaps_c( GL_TEXTURE_2D,
                    3,                    # 3 Farbkanaele
                    $b->Get('width'),     # Abmessung X
                    $b->Get('height'),    # Abmessung Y
                    $b->Get('gl_format'), # Farbmodus z.B. GL_RGB
                    $b->Get('gl_type'),   # UNSIGNED_BYTE oder so...
                    $b->Ptr()             # und die eigentlichen Daten
                  );

    # GL_LINEAR_MIPMAP_NEAREST wird für GL_TEXTURE_MIN_FILTER genutzt
    # Der Min Filter regelt das stauchen
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);

    # GL_LINEAR wird für GL_TEXTURE_MAG_FILTER genutzt
    # Der Mag Filter regelt das dehnen
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);

}

#
# erzeuge und binde eine Texture
#

sub bindTex {

    my ($dat_name, $bild_nr) = @_;

    # ist schon inizialisiert ?
    if( ! $bildInit ) {
        &init();
    }

    if( $bild_nr > $MAX_BILD ) {
        tool::mfLog( 'error', $MODULE . 'Es sind nur ' . $MAX_BILD . " Bilder erlaubt" );
        return;
    }

    # loesche ein eventuell vorhandenes Bild und erzeuge ein neues Bild
    if((! $bild{$bild_nr}{'active'}) || ($bild{$bild_nr}{'name'} ne $dat_name)) {

        if( $bild{$bild_nr}{'active'} ) {
            # Loesche das aktuelle Bild
            tool::mfLog( 'trace', $MODULE . "Loesche Bild: $bild_nr" );

            glDeleteTextures_p($bild{$bild_nr}{'Bild_ID'});
            $bild{$bild_nr}{'active'} = $glob::FALSE;
        }

        tool::mfLog( 'trace', $MODULE . "Erzeuge Bild: $bild_nr" );

        # Speichere den Namen (Dateipfad)
        $bild{$bild_nr}{'name'}  = $dat_name; 

        #lade das Bild als Texture
        &ladeBild( $bild_nr );

        # setze das Bild active
        $bild{ $bild_nr }{'active'} = $glob::TRUE;
    }

    # eine GL_TEXTURE_2D wird festgelegt
    glEnable( GL_TEXTURE_2D );

    # die Textur wird festgelegt
    glBindTexture(GL_TEXTURE_2D, $bild{$bild_nr}{'Bild_ID'});

}

#
# zeige ein Bild
# 
sub showBild {

    my ($dat_name, $bild_nr) = @_;

    # ist schon inizialisiert ?
    if( ! $bildInit ) {
        &init();
    }

    if( $bild_nr > $MAX_BILD ) {
        tool::mfLog( 'error', $MODULE . 'Es sind nur ' . $MAX_BILD . " Bilder erlaubt" );
        return;
    }

    # loesche ein eventuell vorhandenes Bild und erzeuge ein neues Bild
    if((! $bild{$bild_nr}{'active'}) || ($bild{$bild_nr}{'name'} ne $dat_name)) {

        if( $bild{$bild_nr}{'active'} ) {
            # Loesche das aktuelle Bild
            # tool::mfLog( 'trace', $MODULE . "Loesche Bild: $bild_nr" );
            glDeleteTextures_p($bild{$bild_nr}{'Bild_ID'});
            glDeleteLists( $bild{$bild_nr}{'Obj_ID'}, 1);
            $bild{$bild_nr}{'active'} = $glob::FALSE;
        }

        # tool::mfLog( 'trace', $MODULE . "Erzeuge Bild: $bild_nr" );

        # Speichere den Namen (Dateipfad)
        $bild{$bild_nr}{'name'}  = $dat_name; 

        #lade das Bild als Texture
        &ladeBild( $bild_nr );

        # erzeuge das Bildobject und packe es in eine Displayliste
        # ohne Displayliste blitzt der Bildschirm
        glNewList($bild{$bild_nr}{'Obj_ID'}, GL_COMPILE);
            &mkBildObj( $bild_nr );
        glEndList();

        # setze das Bild active
        $bild{ $bild_nr }{'active'} = $glob::TRUE;
    }

    glCallList( $bild{$bild_nr}{'Obj_ID'} );
}

#
# erzeuge ein Bild Object
#
sub mkBildObj {

    my $bild_nr = shift @_;

    # bestimme die x Groesse
    my $x = $bild{$bild_nr}{'width'} / $bild{$bild_nr}{'height'}; 
    tool::mfLog( 'trace', $MODULE . "X-Dimension: " . $x .
                 ' width: '  . $bild{$bild_nr}{'width'} .
                 ' height: ' . $bild{$bild_nr}{'height'} );

    # eine GL_TEXTURE_2D wird festgelegt
    glEnable( GL_TEXTURE_2D );

    # die Textur wird festgelegt
    glBindTexture(GL_TEXTURE_2D, $bild{$bild_nr}{'Bild_ID'});

    # und immer schoen auf die Rotationsachsen achten
    glBegin( GL_QUADS );
        # Das vordere QUAD (zeigt zum Betrachter)
        glNormal3f(0.0, 0.0, 1.0);
        glTexCoord2f(0.0, 0.0); glVertex3f($x * (-1.0), -1.0, 1.0); 
        # unten links an der Form und der Textur
        glTexCoord2f(1.0, 0.0); glVertex3f( $x, -1.0, 1.0); 
        # unten rechts an der Form und der Textur
        glTexCoord2f(1.0, 1.0); glVertex3f( $x, 1.0, 1.0); 
        # oben rechts an der Form und der Textur
        glTexCoord2f(0.0, 1.0); glVertex3f($x * (-1.0), 1.0, 1.0); 
        # oben links an der Form und der Textur
    glEnd();

}

#
# Loesche alle Bilder
#
sub beende {

    my $i = $MAX_BILD;

    if($bildInit) {
        while( $i-- ) {
            if( $bild{$i}{'active'} ) {
                glDeleteTextures_p($bild{$i}{'Bild_ID'});
                glDeleteLists( $bild{$i}{'Obj_ID'}, 1);
                $bild{$i}{'active'} = $glob::FALSE;
            }
        }
    }
}

1;
