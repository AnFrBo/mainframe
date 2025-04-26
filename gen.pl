#!/opt/local/bin/perl

# Generiere die Playlisten fuer die Perl Verarbeitung
# Jack 12.7.2012

package gen;

use strict;
use warnings;

# setze die Variablen fuer das Log
# level = error, warn, info, trace
BEGIN {
    use Cwd;
    our $LOG_LEVEL = 'trace';
    our $LOG_DATEI = getcwd() . "/gen.log";
}

# Standartmodule
use Readonly;
use Carp;
use Config::Std { def_sep => '=' };
use Log::StdLog{ level => $gen::LOG_LEVEL, file => $gen::LOG_DATEI, format => \&log_format };
use Storable;

# Loesche das Logfile
if( -e $gen::LOG_DATEI ) {
    unlink $gen::LOG_DATEI;
}

genLog( 'info', "Programm $0 gestartet" );

# meine Konfigurationsdatei
my $workDir = getcwd();
Readonly my $CNF_MAINFRAME  => "$workDir/ini/mainframe.ini";

my %mcnf = cnfLoad( $CNF_MAINFRAME );
my $mp3_dir          = cnfGet( \%mcnf, 'MUSIK', 'MP3_DIR' );
my $playlist_dir     = cnfGet( \%mcnf, 'MUSIK', 'PLAYLIST_DIR' );
my $data_dir         = cnfGet( \%mcnf, 'MUSIK', 'DATA_DIR' );
my $master_file      = cnfGet( \%mcnf, 'MUSIK', 'MASTER_FILE' );

my $akt_playlist     = cnfGet( \%mcnf, 'MUSIK', 'AKT_PLAYLIST' );
my $playlist_trenner = cnfGet( \%mcnf, 'MUSIK', 'PLAYLIST_TRENNER' );

# lege die Verzeichnisstruktur an
$data_dir = $workDir . "/" . $data_dir;
if( ! (-d $data_dir)) {
    mkdir $data_dir;
    genLog( 'trace', 'Neues Data Verzeichnis: ' . $data_dir );
}

my %pl_master;
my $master = 1;     # das erste File ist der Master (alle Lieder sortiert)
my $playlist_sav = "";

# welche Playlisten sollen verarbeitet werden ?
open my $PLAY_LIST, "<", $playlist_dir . "/" . $akt_playlist or die $!;

while( <$PLAY_LIST> ) {

    chomp;

    # Alle Leer und Kommentarzeilen ausfiltern
    next if /^\s*#/;
    next if /^\s*$/;

    my @t = split( /$playlist_trenner/ );

    # führende und schliessende Whitespace entfernen
    foreach (0..$#t) {
        $t[$_] =~ s/^\s*//; $t[$_] =~ s/\s*$//;
    }

    genLog( 'trace', "Playlist: Text: $t[0] File: $t[1]");
    if( $master ) {
        my %pl = ladeMaster( $playlist_dir . "/" . $t[1], $t[0] ); 
        $master_file = $data_dir . "/" . substr($t[1], 0, length($t[1]) -3) . "sto";
        %pl_master = %pl;
    } else {
        my %pl = ladePlaylist( $playlist_dir . "/" . $t[1], $t[0] ); 
        my $pl_tmp = $data_dir . "/" . substr($t[1], 0, length($t[1]) -3) . "sto";
        store( \%pl, $pl_tmp );
        $playlist_sav .= $pl_tmp . $playlist_trenner;
    }

    $master = 0;

}
close $PLAY_LIST;

# loesche den letzten Playlistentrenner
$playlist_sav = substr( $playlist_sav, 0, length($playlist_sav) -1);
$pl_master{'PLAY_LISTEN'} = $playlist_sav;
store( \%pl_master, $master_file );

# Erzeuge die Film Konfiguration
my %film = ladeFilm( $mcnf{'FILM'}{'M3U'} );
store( \%film, $workDir . "/" . $mcnf{'FILM'}{'DATA'} );

#
# jetzt verarbeite alle Ini Dateien und erzeuge die Master Liste
#
sub ladeMaster {

    my ($dat, $text) = @_;

    my %pl;
    my $interpret_nr  = 0;
    my $album_nr      = 0;
    my $max_lied_nr   = 0;
    my $Nr            = 0;
    my $old_interpret = "";
    my $old_album     = "";

    # Oeffne die Playliste
    open my $LIST, '<', $dat or die $!;
    while( <$LIST> ) {

        chomp;
        next if /^\s*#/;
        next if /^\s*$/;
        s/^\s*//; s/\s*$//;

        my $akt_mp3_datei = $_;
        my @t = split( /\// );

        my $lied_nr = substr( $t[2], 0, 2 ) -1;

        if( $old_interpret eq "" ) {
            $old_interpret = $t[0];
            $old_album = $t[1];
        }

        if( $old_interpret ne $t[0] ) {
            $pl{$interpret_nr}{'MAX_ALBUM'} = $album_nr;
            $pl{$interpret_nr}{$album_nr}{'MAX_LIED'} = $max_lied_nr;
            #genLog( 'trace', "$_ $max_lied_nr");

            $old_interpret = $t[0];
            $interpret_nr++;

            $old_album = $t[1];
            $album_nr = 0;
        }

        if( $old_album ne $t[1] ) {
            $pl{$interpret_nr}{$album_nr}{'MAX_LIED'} = $max_lied_nr;

            $old_album = $t[1];
            $album_nr++;
        }

        my $iniDatei    = $mp3_dir . "/" . $t[0] . "/" . $t[1] . 
                          "/ini/" . substr( $t[2], 0, 2) . ".ini";
        my $txtDatei    = $mp3_dir . "/" . $t[0] . "/" . $t[1] . 
                          "/txt/" . substr( $t[2], 0, 2) . ".txt";
        my $mp3Datei    = $mp3_dir . "/" . $akt_mp3_datei; 
        my $picDir      = $mp3_dir . "/" . $t[0] . "/" . $t[1] .  "/pic/";

        #genLog( 'trace', "lade: iniDatei= $iniDatei");
        #genLog( 'trace', "lade: LiedDatei= $akt_mp3_datei");

        $pl{$interpret_nr}{$album_nr}{'PIC_DIR'} = $picDir;
        $pl{$interpret_nr}{$album_nr}{$lied_nr}{'INI_FILE'} = $iniDatei;
        $pl{$interpret_nr}{$album_nr}{$lied_nr}{'MP3_FILE'} = $mp3Datei;

        # Gibt es eine Text Datei ?
        if( -f $txtDatei ) {
            $pl{$interpret_nr}{$album_nr}{$lied_nr}{'TXT_FILE'} = $txtDatei;
        }

        # Bestimme die Position in der Liste
        $pl{$interpret_nr}{$album_nr}{$lied_nr}{'Nr'} = $Nr++;

        # Daten aus der Ini Datei
        my %icnf = cnfLoad( $iniDatei );

        if( ! exists($pl{$interpret_nr}{'INTERPRET'})) {
            $pl{$interpret_nr}{'INTERPRET'} = $icnf{'Info'}{'Interpret'};
        }
        
        if( ! exists($pl{$interpret_nr}{$album_nr}{'ALBUM'})) {
            $pl{$interpret_nr}{$album_nr}{'ALBUM'} = $icnf{'Info'}{'Album'};
        }

        $pl{$interpret_nr}{$album_nr}{$lied_nr}{'TITEL'} = $icnf{'Info'}{'Titel'};

        my $vol = int($icnf{'Info'}{'RefGain'} + $icnf{'Info'}{'Gain'});
        if( $vol > 100 ) {
            $vol = 100;
        }
        $pl{$interpret_nr}{$album_nr}{$lied_nr}{'VOL'} = $vol;

        $max_lied_nr = $lied_nr;
        
    }
    close $LIST;

    # Sichere die Daten fuer das letzte Album
    $pl{$interpret_nr}{'MAX_ALBUM'} = $album_nr;
    $pl{$interpret_nr}{$album_nr}{'MAX_LIED'} = $max_lied_nr;

    $pl{'MAX_INTERPRET'} = $interpret_nr;
    $pl{'TEXT'} = $text;

    $Nr--;
    genLog( 'trace', "$dat: Interpreten $interpret_nr Nr: $Nr");

    return( %pl );

}

#
# erzeuge die abgestrippten (normalen) Playlisten
#
sub ladePlaylist {

    my ($dat, $text) = @_;

    my %pl;
    my $lied_nr = 0;

    # Oeffne die Playliste
    open my $LIST, '<', $dat or die $!;
    while( <$LIST> ) {

        chomp;
        next if /^\s*#/;
        next if /^\s*$/;
        s/^\s*//; s/\s*$//;

        my $mp3Datei = $mp3_dir . "/" . $_; 

        foreach my $i (0..$pl_master{'MAX_INTERPRET'}) {
            foreach my $j (0..$pl_master{$i}{'MAX_ALBUM'}) {
                foreach my $k (0..$pl_master{$i}{$j}{'MAX_LIED'}) {
                    if( $pl_master{$i}{$j}{$k}{'MP3_FILE'} eq $mp3Datei ) {
                        $pl{$lied_nr}{'INTERPRET_NR'} = $i;
                        $pl{$lied_nr}{'ALBUM_NR'}     = $j; 
                        $pl{$lied_nr}{'LIED_NR'}      = $k; 
                        $pl{$lied_nr}{'MP3_FILE'}     = $mp3Datei; 
                        $pl{$lied_nr}{'VOL'}          = $pl_master{$i}{$j}{$k}{'VOL'}; 
                        $lied_nr++;
                        goto MP3_GEFUNDEN;
                    }
                }
            }
        }
        genLog( 'error', "$mp3Datei nicht gefunden");
        die "$mp3Datei: nicht gefunden";

MP3_GEFUNDEN:
    }
    close $LIST;

    $lied_nr--;
    $pl{'MAX_LIED'} = $lied_nr;
    $pl{'TEXT'} = $text;

    genLog( 'trace', "$dat: Lieder: $lied_nr");

    return( %pl );

}

# ###########################################################################
#
# die Funktionen zum Lesen und erzeugen der Film Konfiguration
#
# ###########################################################################

sub ladeFilm {

    my ($m3u) = @_;
    my (%film, %film_tmp);

    open my $M3U_DATEI, "<", $m3u or die $!;

    while( <$M3U_DATEI> ) {

        %film_tmp = ();

        chomp;

        my @t = split( '/' );
        my @tt = split( '_', $t[$#t] );
        my $film_nr = $tt[0];

        my $pfad = "";
        foreach (0..$#t -1) {
            $pfad .= $t[$_] . "/";
        }

        my $ini_pfad .= $pfad . "ini/" . sprintf( "%02d", $film_nr) . ".ini";
        %film_tmp = cnfLoad( $ini_pfad );
        
        my $interpret_nr = $film_tmp{'INFO'}{'INTERPRET_NR'};
        my $movie_nr     = $film_tmp{'INFO'}{'FILM_NR'};

        $film{$interpret_nr}{$movie_nr}{'TEXT'} = $film_tmp{'INFO'}{'TEXT'};
        $film{$interpret_nr}{$movie_nr}{'PIC'}  = $film_tmp{'INFO'}{'PIC'};
        $film{$interpret_nr}{$movie_nr}{'FILM'} = $film_tmp{'INFO'}{'FILM'};
    }

    close $M3U_DATEI;
     
    return( %film );
}



# ###########################################################################
#
# die Funktionen zum Logging
#
# ###########################################################################

sub genLog   {

    my $i = shift @_;
    my $s = shift @_;

    print {*STDLOG} $i => $s;
    return;
}

sub log_format {

    my ($date, $pid, $level, @message) = @_;
    return "$level ($date): " . join(q{}, @message);
}




# ###########################################################################
#
# die Funktionen zum Lesen und bearbeiten der Konfiguration
#
# ###########################################################################

#
# Lade eine Konfigurationsdatei
#
sub cnfLoad   {

    my $cnf_Datei = shift @_;
    my %rcnf;

    if( -f $cnf_Datei ) { 
        read_config( $cnf_Datei => %rcnf );
        #genLog( 'trace', "cnfLoad: $cnf_Datei" );
    } else {
        genLog( 'error', "cnfLoad: $cnf_Datei" );
        croak "Datei nicht gefunden: $cnf_Datei";
    }

    return(%rcnf);
}

#
# Hole einen Wert aus dem Konfigurations Hash
#
sub cnfGet   {

    my $c           = shift @_;
    my $section     = shift @_;
    my $schluessel  = shift @_;

    if( ! (defined($section && $schluessel))) {
        genLog( "warn", "cnfGet: Section oder Schluessel nicht definiert" );
		return undef;
    }

    genLog( 'trace', "cnfGet: $section, $schluessel = $$c{$section}{$schluessel}" );
	return $$c{$section}{$schluessel}; 

}

1;
