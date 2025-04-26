#!/opt/local/bin/perl

# #########################################################################
#
# die Texturen
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package tex;

use strict;
use warnings;

use OpenGL qw(:all);
use OpenGL::Image;

use lib "lib";

# meine Konstanten fuer Texturen
use constant TEXTUR_PFAD            => "res/";
use constant TEXTUR_TYPE            => ".jpg";

my @texturen = ( "musik", "bilder", "radio", "film", "kamera", "schlafen",
                 "s1_hintergrund", "ozean", "sterne",
                 "ziegel", "s3_hintergrund",
                 "silber", "gold", "welt", "rot", "blau", "gruen", "gelb",
                 "grau", "messing", "papier", "leer", "strasse"
               );

my %tex;
my $texInit = 0;

sub init {

    my $current = glGenLists($#texturen +1);              # Hole ein paar Displaylisten

    # lade die Texturen
    foreach my $i ( @texturen ) {
        $tex{$i} = $current++;
        &ladeTextur( TEXTUR_PFAD . $i . TEXTUR_TYPE, $tex{$i});
        tool::glFehler( "tex init" );
    }

    $texInit = 1;
}

#
# Lade eine Texture
#
sub ladeTextur
{

    my ($dat_name, $tex_ID) = @_;
    my $tex;

    $tex = new OpenGL::Image(engine=>'Magick', source=>$dat_name);
    beende( "Konnte " . $dat_name . " nicht laden" ) if (!$tex);

    # Sage OpenGL das es eine 2D Textur ist
    glBindTexture( GL_TEXTURE_2D, $tex_ID );

    # wie wird die Texture gemapped
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    gluBuild2DMipmaps_c( GL_TEXTURE_2D,
                        3,                      # 3 Farbkanaele
                        $tex->Get('width'),     # Abmessung X
                        $tex->Get('height'),    # Abmessung Y
                        $tex->Get('gl_format'), # Farbmodus z.B. GL_RGB
                        $tex->Get('gl_type'),   # UNSIGNED_BYTE oder so...
                        $tex->Ptr()             # und die eigentlichen Daten
                      );

    # GL_LINEAR_MIPMAP_NEAREST wird für GL_TEXTURE_MIN_FILTER genutzt
    # Der Min Filter regelt das stauchen
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);

    # GL_LINEAR_MIPMAP_NEAREST wird für GL_TEXTURE_MAG_FILTER genutzt
    # Der Mag Filter regelt das dehnen
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

}

#
# binde eine geladene Textur
#
sub bindTex {

    my $texName = shift @_;

    if(! $texInit) {
        &init();
    };

    glBindTexture(GL_TEXTURE_2D, $tex{$texName});

}

#
# Loesche alle Texturen
#
sub beende {

    foreach my $i ( @texturen ) {
        glDeleteTextures_p($tex{$i}) if ($tex{$i});
    }
}

1;
