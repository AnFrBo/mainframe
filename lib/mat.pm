#!/opt/local/bin/perl

# #########################################################################
#
# meine Materialien
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package mat;

use strict;
use warnings;

use OpenGL qw(:all);

use lib "lib";

my @lmodel_ambient = ( 0.4, 0.4, 0.4, 1.0 );
my @local_view = ( 0.0 );

my %mat;
my $matInit = 0;

sub init {

    my $current = glGenLists(16);              # Hole ein paar Displaylisten

    $mat{'plastikRot'} = $current++;
    glNewList($mat{'plastikRot'}, GL_COMPILE);
        &plastikRot();
    glEndList();

    # Schalte das Material ein
    glLightModelfv_p( GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient );
    glLightModelfv_p( GL_LIGHT_MODEL_LOCAL_VIEWER, @local_view );

    $matInit = 1;
}

#
# Loesche alle Objekte
#
sub beende {

    foreach my $i (values %mat) {
        glDeleteLists( $i, 1);
    }
}

#
# hole ein Material
#
sub showMat {

    my $matName = shift @_;

    if(! $matInit) {
        &init();
    };


    glCallList( $mat{$matName} );
    #plastikRot();

}

#
# Rotes Plastik Material
#
sub plastikRot {

    my @mat_no_mat          = (0.0, 0.0, 0.0, 1.0);
    my @mat_ambient         = (0.7, 0.7, 0.7, 1.0);
    my @mat_ambient_color   = (0.8, 0.2, 0.2, 1.0);
    my @mat_diffuse         = (0.8, 0.5, 0.1, 1.0);
    my @mat_specular        = (1.0, 1.0, 1.0, 1.0);
    my @mat_no_shininess    = (0.0);
    my @mat_low_shininess   = (5.0);
    my @mat_high_shininess  = (100.0);
    my @mat_emission        = (0.3, 0.1, 0.1, 0.0);

    glLightModelfv_p( GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient );
    glLightModelfv_p( GL_LIGHT_MODEL_LOCAL_VIEWER, @local_view );

    glMaterialfv_p(GL_FRONT_AND_BACK, GL_AMBIENT,    @mat_no_mat);
    glMaterialfv_p(GL_FRONT_AND_BACK, GL_DIFFUSE,    @mat_diffuse);
    glMaterialfv_p(GL_FRONT_AND_BACK, GL_SPECULAR,   @mat_specular);
    glMaterialfv_p(GL_FRONT_AND_BACK, GL_SHININESS,  @mat_high_shininess);
    glMaterialfv_p(GL_FRONT_AND_BACK, GL_EMISSION,   @mat_no_mat);

}


1;
