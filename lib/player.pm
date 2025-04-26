#!/opt/local/bin/perl

package mp3Player;

use strict;
use warnings;

use IPC::Open2;
use Storable;
use File::Copy;
use Cwd;

use lib "lib";
require "tool.pm";

# #####################################
#
# meine Konfiguration
#
# #####################################

my $mp3Prog    = "/usr/local/bin/mpg123";
#my $mp3_status = "/Volumes/ramdisk/mp3_stat.txt";
my $mp3_status = "./mp3_stat.txt";
#my $mp3_tmp    = "/Volumes/ramdisk/t.mp3";

use constant {
             PL_STOP         => 0,
             PL_PAUSE        => 1,
             PL_PLAY         => 2,
             };

# #####################################
#
# globale Variablen
#
# #####################################

my ($Reader, $Writer);

my $pid;
my $akt_sec = 0;
my $status  = PL_STOP;
my @t;
my %pl;

my ($playlist, $lied_nr);

# #####################################
#
# ueberpruefe ob es eine Ramdisk gibt
#
# #####################################

#if( ! (-d "/Volumes/ramdisk" )) {
#    &mkRamdisk( "ramdisk", 100 );
#}

# #####################################
#
# STDOUT soll unbuffered sein
#
# #####################################

select STDOUT;
$| = 1;

# #####################################
#
# starte den Player
#
# #####################################

sub spieleMp3 {

    my( $mp3Datei, $vol ) = @_;

    if( $status ) {
        &beende_lied();
    }

#    copy( $mp3Datei, $mp3_tmp );

    $pid = open2($Reader, $Writer, "$mp3Prog -R >$mp3_status 2>/dev/null");
    close( $Reader );       # den Reader brauche ich nicht
    tool::mfLog( 'trace', "s1_player: PID $mp3Prog: $pid" );

    print $Writer "VOLUME $vol\n";
    print $Writer "LOAD $mp3Datei\n";

    $akt_sec = 0;
    $status  = PL_PLAY;

}

# #####################################
#
# steuere den Player
#
# #####################################

sub setPlayer {

    my ($cmd, $para) = @_;

    if( $cmd eq "PLAYLIST" ) {
        $playlist = $para;
        %pl = %{ retrieve( $playlist ) };
    }

    if( $cmd eq "PLAY" ) {
        $lied_nr = $para;
        tool::mfLog( 'trace', "s1_player: LiedNr.: $lied_nr" );
        &spieleMp3( $pl{$lied_nr}{'MP3_FILE'}, $pl{$lied_nr}{'VOL'} );
    }

    if( $cmd eq "PAUSE" ) {
        tool::mfLog( 'trace', "s1_player: Pause" );
        if( $status == PL_PLAY ) {
            $status = PL_PAUSE;
            print $Writer "PAUSE\n";
        } elsif( $status == PL_PAUSE ) {
            $status = PL_PLAY;
            print $Writer "PAUSE\n";
        }
    }

    if( $cmd eq "BACK" ) {
        $lied_nr--;
        if( $lied_nr < 0 ) {
            $lied_nr = $pl{'MAX_LIED'};
        }
        &spieleMp3( $pl{$lied_nr}{'MP3_FILE'}, $pl{$lied_nr}{'VOL'} );
    }

    if( $cmd eq "NEXT" ) {
        $lied_nr++;
        if( $lied_nr > $pl{'MAX_LIED'} ) {
            $lied_nr = 0;
        }
        &spieleMp3( $pl{$lied_nr}{'MP3_FILE'}, $pl{$lied_nr}{'VOL'} );
    }

    if( $cmd eq "QUIT" ) {
        &beende_lied();
    }
}

# #####################################
#
# halte den Player am laufen
#
# #####################################

sub run {

    if( $status ) {
        &getMp3Status();
    }
}

# #####################################
#
# liefere Status Informationen
#
# #####################################

sub getStatus {

    return($status, $akt_sec);

}

# #####################################
#
# der Liedstatus und die Tasten Eingabe
#
# #####################################

sub getMp3Status {

    # Lese die letzte Zeile der Datei
    # die @F Zeile ist so ungefaehr 25 Byte lang
    open my $STATUS_DATEI, "<", $mp3_status || die();
    seek( $STATUS_DATEI, -64, 2 );
    @t = <$STATUS_DATEI>;
    close $STATUS_DATEI;

    if( @t ) {

        chomp( $t[$#t] );

        if( $t[$#t] eq '@P 0' ) {
            &setPlayer( "NEXT" );
        } else {
            @t = split( /\s/, $t[$#t] );
            if( $t[0] eq '@F' ) {
                $akt_sec = int($t[3]);
            }
        }
    }
}

# #####################################
#
# beende das aktuelle Lied
#
# #####################################

sub beende_lied {

    print $Writer "QUIT\n";
    close( $Writer );
    $status  = PL_STOP;
    waitpid( $pid, 0 );     #damit es keine Zombies gibt

}

# #####################################
#
# eine Ramdisk wird erzeugt
#
# #####################################

sub mkRamdisk {

    my ($ramdisk_name, $ramdisk_size_mb) = @_;

    my $ramdisk_size = $ramdisk_size_mb * 2000;

    system( "diskutil erasevolume HFS+ $ramdisk_name " . 
            "`hdiutil attach -nomount ram://$ramdisk_size`" .
            " >/dev/null 2>/dev/null" );

}


1;
