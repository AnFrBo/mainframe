#!/opt/local/bin/perl

# #########################################################################
#
# Lampen
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package licht;

use strict;
use warnings;

use OpenGL qw(:all);

use lib "lib";

# Meine Lampen
my @light_position_01  = (-4.0, 4.0,  0.0,  1.0);
my @light_diffuse_01   = (0.8,  0.7,  0.7,  1.0);
my @light_ambient_01   = (0.8,  0.7,  0.7,  1.0);
my @light_specular_01  = (1.0,  1.0,  1.0,  1.0);

my @light_position_02  = (-2.0, 4.0,  4.0,  1.0);
my @light_diffuse_02   = (0.5,  0.4,  0.4,  1.0);
my @light_ambient_02   = (0.5,  0.4,  0.4,  1.0);
my @light_specular_02  = (1.0,  1.0,  1.0,  1.0);

sub init {


}

#
# erzeuge die Lampen
#
sub licht01 {

    # fast alles auf 0
    glLoadIdentity();

    # die Position der Lampe
    glLightfv_p(GL_LIGHT1, GL_POSITION, @light_position_01);

    # erzeuge die Lampen
    glLightfv_p(GL_LIGHT1, GL_AMBIENT,   @light_ambient_01);
    glLightfv_p(GL_LIGHT1, GL_DIFFUSE,   @light_diffuse_01);
    glLightfv_p(GL_LIGHT1, GL_SPECULAR,  @light_specular_01);

    glDisable(GL_LIGHT2);
    glEnable(GL_LIGHT1);
}

sub licht02 {

    # fast alles auf 0
    glLoadIdentity();

    # die Position der Lampe
    glLightfv_p(GL_LIGHT2, GL_POSITION, @light_position_02);

    # erzeuge die Lampen
    glLightfv_p(GL_LIGHT2, GL_AMBIENT,   @light_ambient_02);
    glLightfv_p(GL_LIGHT2, GL_DIFFUSE,   @light_diffuse_02);
    glLightfv_p(GL_LIGHT2, GL_SPECULAR,  @light_specular_02);

    glDisable(GL_LIGHT1);
    glEnable(GL_LIGHT2);
}


1;
