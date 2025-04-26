#!/opt/local/bin/perl

# #########################################################################
#
# zeige eine Film                           
#
# Joachim Bothe 1.7.2012
#
# #########################################################################

package s3_film;

use strict;
use warnings;
no warnings 'once';

use OpenGL qw(:all);
use Readonly;

use lib "lib";
require "glob.pm";
require "tool.pm";
require "player.pm";

#
# Inizialisiere die Scene
#
sub init {

    my ($film) = @_;
    my ($status, $zeit);
    tool::mfLog( 'trace', 's3_Film: ' . $film );

    # Stoppe den Player
    ($status, $zeit) = &mp3Player::getStatus();
    if( $status == 2 ) {
        mp3Player::setPlayer( "PAUSE" );
    }

    # spiele eine Film und kehre zurueck
    my $doit = qq { osascript osa/play_qt.scpt "$film" };
    `$doit`;

    ($status, $zeit) = &mp3Player::getStatus();
    if( $status == 1 ) {
        mp3Player::setPlayer( "PAUSE" );
    }

    # eine Scene zurueck
    main::nkey( 32, 0, 0 ); 

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

    return(0);
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
    }
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

}



1;
