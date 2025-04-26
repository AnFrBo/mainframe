#!/opt/local/bin/perl

# #########################################################################
#
# meine Globals fuer den Mainframe
#
# Joachim Bothe 1.5.2012
#
# #########################################################################

package glob;

use strict;
use warnings;

use Readonly;

# meine zentrale Ini Datei
Readonly our $INI_MAINFRAME                 => "ini/mainframe.ini";

# Sonstige Definitionen
Readonly our $FALSE                         =>  0;
Readonly our $TRUE                          =>  1;

# Tasten Beschreibung
Readonly our $KEY_ENTER                     =>  13;
Readonly our $KEY_ESCAPE                    =>  27;
Readonly our $KEY_SPACE                     =>  32;

# Steuerung

# Menu
Readonly our $MENU                          =>  1;

# Hauptmenu Auswahl
Readonly our $MENU_AUSWAHL_MUSIK            =>  2;
Readonly our $MENU_AUSWAHL_KAMERA           =>  3;
Readonly our $MENU_AUSWAHL_FILM             =>  4;
Readonly our $MENU_AUSWAHL_BILDER           =>  5;
Readonly our $MENU_AUSWAHL_RADIO            =>  6;
Readonly our $MENU_AUSWAHL_SCHLAFEN         =>  7;

# Musik
Readonly our $MENU_MUSIK_AUSWAHL            => 10;

# MUSIK AUSWAHL
Readonly our $MENU_MUSIK_AUSWAHL_INTERPRET  => 11;
Readonly our $MENU_MUSIK_AUSWAHL_PLAYLIST   => 12;
Readonly our $MENU_MUSIK_AUSWAHL_BESITZER   => 13;

Readonly our $MENU_MUSIK_INTERPRET          => 14;
Readonly our $MENU_MUSIK_PLAYLIST           => 15;
Readonly our $MENU_MUSIK_BESITZER           => 16;
Readonly our $MENU_MUSIK_ALBUM              => 17;
Readonly our $MENU_MUSIK_LIED               => 18;
Readonly our $MENU_MUSIK_PLAY               => 19;

# Kamera
Readonly our $MENU_KAMERA_AUSWAHL           => 30;
Readonly our $MENU_KAMERA                   => 31;

# Film
Readonly our $MENU_FILM_AUSWAHL             => 40;
Readonly our $MENU_FILM                     => 41;





1;
