#!/opt/local/bin/perl

# #########################################################################
#
# Schreibe in OpenGL mit einem 3D Font
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package text;

use strict;
use warnings;

use utf8;                                       # sonst gibt es keine Umlaute
use OpenGL qw(:all);

use lib "lib";
require "font/futura.pm";
require "font/chancery.pm";
require "font/blackchancery.pm";

use constant FUTURA_SPACING         => 0.09;
use constant CHANCERY_SPACING       => 0.06;
use constant BLACKCHANCERY_SPACING  => 0.06;

use constant FUTURA_SPACE           => 0.2;
use constant CHANCERY_SPACE         => 0.2;
use constant BLACKCHANCERY_SPACE    => 0.2;

# Merke dir den Ausgabefont
my (@font3d, @font3d_width);                    # der aktuell verwendete Font
my (@futura, @futura_width);                    # Futura Font
my (@chancery, @chancery_width);                # Chancery Font
my (@blackchancery, @blackchancery_width);      # Chancery Black Font

my $textInit = 0;

#
# Inizialisiere die Fonts
#
sub init {

    ladeFuturaFont();
    ladeChanceryFont();
    ladeBlackChanceryFont();

    $textInit = 1;

}

#
# Loesche alle Displaylisten
#
sub beende {

    if( $textInit ) {
        foreach (32..133) {
            glDeleteLists( $blackchancery[$_], 1);
        }

        foreach (32..133) {
            glDeleteLists( $chancery[$_], 1);
        }

        foreach (32..133) {
            glDeleteLists( $futura[$_], 1);
        }
    }
}

#
# Lade den Black Chancery Font
#
sub ladeBlackChanceryFont {

    no strict "refs";

    my $current = glGenLists(134);              # Hole ein paar Displaylisten

    # Meine Leerzeichen
    $blackchancery[32] = $current++;
    glNewList($blackchancery[32], GL_COMPILE);
        glTranslatef(BLACKCHANCERY_SPACE, 0.0, 0.0);
    glEndList();
    $blackchancery_width[32] = BLACKCHANCERY_SPACE;

    foreach(33..133) {

        my $prog = "blackchancery::prog" . $_;
        my ($num, $v, $w) = &$prog();

        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer_c(3, GL_FLOAT, 0, $v->ptr());
        $blackchancery[$_] = $current++;
        $blackchancery_width[$_] = $w + BLACKCHANCERY_SPACING;

        glNewList($blackchancery[$_], GL_COMPILE);
            glTexGeni( GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR );
            glTexGeni( GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR );
            glEnable( GL_TEXTURE_GEN_S);                                # Auto Texture
            glEnable( GL_TEXTURE_GEN_T);                                # Auto Texture
            glDrawArrays(GL_TRIANGLES, 0, $num);
            glTranslatef( $blackchancery_width[$_], 0.0, 0.0);
            glDisable( GL_TEXTURE_GEN_T);                               # Auto Texture
            glDisable( GL_TEXTURE_GEN_S);                               # Auto Texture
        glEndList();

        glDisableClientState(GL_VERTEX_ARRAY);
    }

    @font3d       = @blackchancery;
    @font3d_width = @blackchancery_width;

    return;
}

#
# Lade den Chancery Font
#
sub ladeChanceryFont {

    no strict "refs";

    my $current = glGenLists(134);              # Hole ein paar Displaylisten

    # Meine Leerzeichen
    $chancery[32] = $current++;
    glNewList($chancery[32], GL_COMPILE);
        glTranslatef(CHANCERY_SPACE, 0.0, 0.0);
    glEndList();
    $chancery_width[32] = CHANCERY_SPACE;

    foreach(33..133) {

        my $prog = "chancery::prog" . $_;
        my ($num, $v, $w) = &$prog();

        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer_c(3, GL_FLOAT, 0, $v->ptr());
        $chancery[$_] = $current++;
        $chancery_width[$_] = $w + CHANCERY_SPACING;

        glNewList($chancery[$_], GL_COMPILE);
            glTexGeni( GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR );
            glTexGeni( GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR );
            glEnable( GL_TEXTURE_GEN_S);                                # Auto Texture
            glEnable( GL_TEXTURE_GEN_T);                                # Auto Texture
            glDrawArrays(GL_TRIANGLES, 0, $num);
            glTranslatef( $chancery_width[$_], 0.0, 0.0);
            glDisable( GL_TEXTURE_GEN_T);                               # Auto Texture
            glDisable( GL_TEXTURE_GEN_S);                               # Auto Texture
        glEndList();

        glDisableClientState(GL_VERTEX_ARRAY);
    }

    @font3d       = @chancery;
    @font3d_width = @chancery_width;

    return;
}

#
# Lade den Futura Font
#
sub ladeFuturaFont {

    no strict "refs";

    my $current = glGenLists(134);              # Hole ein paar Displaylisten

    # Meine Leerzeichen
    $futura[32] = $current++;
    glNewList($futura[32], GL_COMPILE);
        glTranslatef(FUTURA_SPACE, 0.0, 0.0);
    glEndList();
    $futura_width[32] = FUTURA_SPACE;

    foreach(33..133) {

        my $prog = "futura::prog" . $_;
        my ($num, $v, $w) = &$prog();

        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer_c(3, GL_FLOAT, 0, $v->ptr());
        $futura[$_] = $current++;
        $futura_width[$_] = $w + FUTURA_SPACING;

        glNewList($futura[$_], GL_COMPILE);
            glTexGeni( GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR );
            glTexGeni( GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR );
            glEnable( GL_TEXTURE_GEN_S);                                # Auto Texture
            glEnable( GL_TEXTURE_GEN_T);                                # Auto Texture
            glDrawArrays(GL_TRIANGLES, 0, $num);
            glTranslatef( $futura_width[$_], 0.0, 0.0);
            glDisable( GL_TEXTURE_GEN_T);                               # Auto Texture
            glDisable( GL_TEXTURE_GEN_S);                               # Auto Texture
        glEndList();

        glDisableClientState(GL_VERTEX_ARRAY);
    }

    @font3d       = @futura;
    @font3d_width = @futura_width;

    return;
}

#
# setze einen Font
#
sub set3dFont {

    my $font = shift @_;

    if(! $textInit) {
        &init();
    };

    if( $font eq "Futura" ) {
        @font3d       = @futura;
        @font3d_width = @futura_width;
    }

    if( $font eq "Chancery" ) {
        @font3d       = @chancery;
        @font3d_width = @chancery_width;
    }

    if( $font eq "BlackChancery" ) {
        @font3d       = @blackchancery;
        @font3d_width = @blackchancery_width;
    }
}

#
# meine 3d Print Routine
#
sub print3d {

    my $out  = shift @_;

    if(! $textInit) {
        &init();
    };

    foreach my $c (split('', $out)) {

        my $i = ord($c);
        $i = mapUmlaute( $i );
        glCallList( $font3d[$i] );
    }
}

#
# bestimme die Breite eines Strings
#
sub width3dText {

    my $s = shift @_;
    my $w = 0;

    if(! $textInit) {
        &init();
    };

    foreach my $c (split('', $s)) {

        my $i = ord($c);
        $i = mapUmlaute( $i );
        $w += $font3d_width[$i];
    }

    return( $w );
}

#
# meine Umlaut Map
#
sub mapUmlaute {

    my $i = shift @_;

    if( $i > 133 ) {
        if( $i == 196 ) {
            $i = 127;
        } elsif ( $i == 214 ) {
            $i = 128;
        } elsif ( $i == 220 ) {
            $i = 129;
        } elsif ( $i == 228 ) {
            $i = 130;
        } elsif ( $i == 246 ) {
            $i = 131;
        } elsif ( $i == 252 ) {
            $i = 132;
        } elsif ( $i == 223 ) {
            $i = 133;
        } elsif ( $i == 232 ) {
            $i = ord('e');
        } elsif ( $i == 233 ) {
            $i = ord('e');
        } else {
            if( $i > 133 && $i != 196 ) {
                #tool::mfLog( 'error', "text.pm: mapUmlaute: $i" );
                $i = ord('*');
            }
        }
    }

    return( $i );
}

1;
