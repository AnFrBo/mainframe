#!/opt/local/bin/perl

# #########################################################################
#
# der Scenen Master                  
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package scene;

use strict;
use warnings;

use OpenGL qw(:all);

use lib "lib";
require "glob.pm";

require "scenen/s1_menu.pm";
require "scenen/s1_musik_auswahl.pm";
require "scenen/s1_musik_interpret.pm";
require "scenen/s1_musik_album.pm";
require "scenen/s1_musik_lied.pm";
require "scenen/s1_musik_play.pm";
require "scenen/s2_kamera_auswahl.pm";
require "scenen/s2_kamera.pm";
require "scenen/s3_film_auswahl.pm";
require "scenen/s3_film.pm";

# die aktuelle Fenstergroesse brauchen die Scenen
my ($akt_winw, $akt_winh);

#
# merke Dir die Fenstergroesse
#
sub setWindowSize {

    ($akt_winw, $akt_winh) = @_;
}

#
# beende die Scene
#
sub beende {
}

#
# hole die Scenen Informationen (Auswahl oder Parameter)
#
sub getInfo {

    my $aktScene = shift @_;
    my $ret = 0;

    if( $aktScene == $glob::MENU ) {
        $ret = s1_menu::getInfo();
    }

    if( $aktScene == $glob::MENU_MUSIK_AUSWAHL ) {
        $ret = s1_musik_auswahl::getInfo();
    }

    if( $aktScene == $glob::MENU_MUSIK_INTERPRET ) {
        $ret = s1_musik_interpret::getInfo();
    }

    if( $aktScene == $glob::MENU_MUSIK_ALBUM ) {
        $ret = s1_musik_album::getInfo();
    }

    if( $aktScene == $glob::MENU_MUSIK_LIED ) {
        $ret = s1_musik_lied::getInfo();
    }

    if( $aktScene == $glob::MENU_MUSIK_PLAY ) {
        $ret = s1_musik_play::getInfo();
    }

    if( $aktScene == $glob::MENU_KAMERA_AUSWAHL ) {
        $ret = s2_kamera_auswahl::getInfo();
    }

    if( $aktScene == $glob::MENU_KAMERA ) {
        $ret = s2_kamera::getInfo();
    }

    if( $aktScene == $glob::MENU_FILM_AUSWAHL ) {
        $ret = s3_film_auswahl::getInfo();
    }

    tool::mfLog( 'trace', "scene getInfo: $aktScene, $ret" );

    return( $ret );
}

#
# kann die Scene schlafen gelegt werden ?
#
sub isSleepy {
}

#
# kann die aktuelle Scene neue Aufträge annehmen ?
#
sub isActive {

    my $aktScene = shift @_;
    my $ret = 0;

    if( $aktScene == $glob::MENU ) {
        $ret = s1_menu::isActive();
    }

    if( $aktScene == $glob::MENU_MUSIK_AUSWAHL ) {
        $ret = s1_musik_auswahl::isActive();
    }

    if( $aktScene == $glob::MENU_MUSIK_INTERPRET ) {
        $ret = s1_musik_interpret::isActive();
    }

    if( $aktScene == $glob::MENU_MUSIK_ALBUM ) {
        $ret = s1_musik_album::isActive();
    }

    if( $aktScene == $glob::MENU_MUSIK_LIED ) {
        $ret = s1_musik_lied::isActive();
    }

    if( $aktScene == $glob::MENU_MUSIK_PLAY ) {
        $ret = s1_musik_play::isActive();
    }

    if( $aktScene == $glob::MENU_KAMERA_AUSWAHL ) {
        $ret = s2_kamera_auswahl::isActive();
    }

    if( $aktScene == $glob::MENU_KAMERA ) {
        $ret = s2_kamera::isActive();
    }

    if( $aktScene == $glob::MENU_FILM_AUSWAHL ) {
        $ret = s3_film_auswahl::isActive();
    }

    if( $aktScene == $glob::MENU_FILM ) {
        $ret = s3_film::isActive();
    }

    return( $ret );
}

#
# zeige die aktuelle Scene
#
sub show {

    my $aktScene = shift @_;

    if( $aktScene == $glob::MENU ) {
        s1_menu::show($akt_winw, $akt_winh);
    }

    if( $aktScene == $glob::MENU_MUSIK_AUSWAHL ) {
        s1_musik_auswahl::show($akt_winw, $akt_winh);
    }

    if( $aktScene == $glob::MENU_MUSIK_INTERPRET ) {
        s1_musik_interpret::show($akt_winw, $akt_winh);
    }

    if( $aktScene == $glob::MENU_MUSIK_ALBUM ) {
        s1_musik_album::show($akt_winw, $akt_winh);
    }

    if( $aktScene == $glob::MENU_MUSIK_LIED ) {
        s1_musik_lied::show($akt_winw, $akt_winh);
    }

    if( $aktScene == $glob::MENU_MUSIK_PLAY ) {
        s1_musik_play::show($akt_winw, $akt_winh);
    }

    if( $aktScene == $glob::MENU_KAMERA_AUSWAHL ) {
        s2_kamera_auswahl::show($akt_winw, $akt_winh);
    }

    if( $aktScene == $glob::MENU_KAMERA ) {
        s2_kamera::show($akt_winw, $akt_winh);
    }

    if( $aktScene == $glob::MENU_FILM_AUSWAHL ) {
        s3_film_auswahl::show($akt_winw, $akt_winh);
    }

    if( $aktScene == $glob::MENU_FILM ) {
        s3_film::show($akt_winw, $akt_winh);
    }

}

#
# uebermittle die Ereignisse
#
sub setAction {

    my ($aktScene, $action) = @_;

    tool::mfLog( 'trace', "scene setAction: $aktScene, $action" );

    if( $aktScene == $glob::MENU ) {
        s1_menu::setAction($action);
    }

    if( $aktScene == $glob::MENU_MUSIK_AUSWAHL ) {
        s1_musik_auswahl::setAction($action);
    }

    if( $aktScene == $glob::MENU_MUSIK_INTERPRET ) {
        s1_musik_interpret::setAction($action);
    }

    if( $aktScene == $glob::MENU_MUSIK_ALBUM ) {
        s1_musik_album::setAction($action);
    }

    if( $aktScene == $glob::MENU_MUSIK_LIED ) {
        s1_musik_lied::setAction($action);
    }

    if( $aktScene == $glob::MENU_MUSIK_PLAY ) {
        s1_musik_play::setAction($action);
    }

    if( $aktScene == $glob::MENU_KAMERA_AUSWAHL ) {
        s2_kamera_auswahl::setAction($action);
    }

    if( $aktScene == $glob::MENU_KAMERA ) {
        s2_kamera::setAction($action);
    }

    if( $aktScene == $glob::MENU_FILM_AUSWAHL ) {
        s3_film_auswahl::setAction($action);
    }

    if( $aktScene == $glob::MENU_FILM ) {
        s3_film::setAction($action);
    }

}

#
# inizialisiere die aktuelle Scene
#
sub init {

    my ($aktScene, $parameter) = @_;

    tool::mfLog( 'trace', "scene init: $aktScene, $parameter" );

    if( $aktScene == $glob::MENU ) {
        s1_menu::init( $parameter );
    }

    if( $aktScene == $glob::MENU_MUSIK_AUSWAHL ) {
        s1_musik_auswahl::init( $parameter );
    }

    if( $aktScene == $glob::MENU_MUSIK_INTERPRET ) {
        s1_musik_interpret::init( $parameter );
    }

    if( $aktScene == $glob::MENU_MUSIK_ALBUM ) {
        s1_musik_album::init( $parameter );
    }

    if( $aktScene == $glob::MENU_MUSIK_LIED ) {
        s1_musik_lied::init( $parameter );
    }

    if( $aktScene == $glob::MENU_MUSIK_PLAY ) {
        s1_musik_play::init( $parameter );
    }

    if( $aktScene == $glob::MENU_KAMERA_AUSWAHL ) {
        s2_kamera_auswahl::init( $parameter );
    }

    if( $aktScene == $glob::MENU_KAMERA ) {
        s2_kamera::init( $parameter );
    }

    if( $aktScene == $glob::MENU_FILM_AUSWAHL ) {
        s3_film_auswahl::init( $parameter );
    }

    if( $aktScene == $glob::MENU_FILM ) {
        s3_film::init( $parameter );
    }
}

1;
