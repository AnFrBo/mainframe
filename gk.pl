#!/opt/local/bin/perl

# Hole und speichere Webcam Bilder
# Jack 1.6.2012

package gk;

use strict;
use warnings;

# setze die Variablen fuer das Log
# level = error, warn, info, trace
BEGIN {
    use Cwd;
    our $LOG_LEVEL = 'trace';
    our $LOG_DATEI = getcwd() . "/gk.log";
}

# Standartmodule
use Time::localtime;
use Readonly;
use Carp;
use Config::Std { def_sep => '=' };
use Log::StdLog{ level => $gk::LOG_LEVEL, file => $gk::LOG_DATEI, format => \&log_format };
use Fcntl qw(:flock);

# Loesche das Logfile
if( -e $gk::LOG_DATEI ) {
    unlink $gk::LOG_DATEI;
}

gkLog( 'info', "Programm $0 gestartet" );

# meine Konfigurationsdatei
my $workDir = getcwd();
Readonly my $CNF_MAINFRAME  => "$workDir/ini/mainframe.ini";

my %mcnf = cnfLoad( $CNF_MAINFRAME );
my %kcnf = cnfLoad( "$workDir/" . cnfGet( \%mcnf, 'WEBCAM', 'INI_DATEI' ));
my $nameZdatei = cnfGet( \%mcnf, 'WEBCAM', 'ZAEHLER_DATEI' );
my $nameLdatei = cnfGet( \%mcnf, 'WEBCAM', 'LOG_DATEI' );
my $namePdatei = cnfGet( \%mcnf, 'WEBCAM', 'PIC_DATEI' );
my $SLEEP_INTERVAL = 5;
my $TIMEOUT = 45;

# lege die Verzeichnisstruktur an
my $kam_dir = $workDir . "/" . cnfGet( \%mcnf, 'WEBCAM', 'DIR' );
if( ! (-d $kam_dir)) {
    mkdir $kam_dir;
    gkLog( 'trace', 'Neues Kamera Verzeichnis: ' . $kam_dir );
}

# Baue die Steuerung auf
my %steuerung;
foreach my $i (keys %kcnf) {
    gkLog( 'trace', 'gk: Verarbeite Webcam ' . $i );

    my $schluessel = cnfGet( \%kcnf, $i, 'DIR' );
    my $pic_dir = $kam_dir . "/" . $schluessel;

    $steuerung{$schluessel}{'PIC_DIR'}          = $pic_dir;
    $steuerung{$schluessel}{'ZAEHLER_DATEI'}    = $pic_dir . "/" . $nameZdatei;
    $steuerung{$schluessel}{'AKT_ZAEHLER'}      = 0;
    $steuerung{$schluessel}{'LOG_DATEI'}        = $pic_dir . "/" . $nameLdatei;
    $steuerung{$schluessel}{'PIC_DATEI'}        = $pic_dir . "/" . $namePdatei;
    $steuerung{$schluessel}{'TYP_DATEI'}        = cnfGet( \%kcnf, $i, 'TYP' );
    $steuerung{$schluessel}{'UPDATE'}           = cnfGet( \%kcnf, $i, 'UPDATE' );
    $steuerung{$schluessel}{'AKT_ZEIT'}         = 0;
    $steuerung{$schluessel}{'ADR'}              = cnfGet( \%kcnf, $i, 'ADR' );
    $steuerung{$schluessel}{'ANZAHL_PIC'}       = cnfGet( \%kcnf, $i, 'ANZAHL_PIC' );
    $steuerung{$schluessel}{'PIC_SIZE'}         = 0;

    if( ! (-d $pic_dir)) {
        mkdir $pic_dir;
        gkLog( 'trace', 'Neues Bilder Verzeichnis: ' . $pic_dir );
    }

    if( -f $steuerung{$schluessel}{'ZAEHLER_DATEI'} ) {

        open my $zDatei, '<', $steuerung{$schluessel}{'ZAEHLER_DATEI'} or croak $!;
        flock( $zDatei, LOCK_SH); # shared lock
        my $zahl = <$zDatei>;
        close $zDatei; #entferne den Lock

        chomp( $zahl );
        $steuerung{$schluessel}{'AKT_ZAEHLER'} = $zahl;

        gkLog( 'trace', 'gk: Akt Bild = ' . $zahl );

    } else {

        open my $zDatei, '>', $steuerung{$schluessel}{'ZAEHLER_DATEI'} or croak $!;
        flock( $zDatei, LOCK_EX); # exclusive lock
        print $zDatei "0";
        close $zDatei;

        gkLog( 'trace', 'gk: Akt Bild = 0' );

    }
}

# -----------------------------------------------------------------------------
#
# eine Endlos Schleife 
#
# -----------------------------------------------------------------------------
while(1) {
    foreach my $i (keys %steuerung) {

        $steuerung{$i}{'AKT_ZEIT'} -= $SLEEP_INTERVAL;
        if( $steuerung{$i}{'AKT_ZEIT'} <= 0 ) {

            #Setze das Zeitinterval zurueck
            $steuerung{$i}{'AKT_ZEIT'} = $steuerung{$i}{'UPDATE'};

            #erzeuge den Dateinamen
            my $dat_name = $steuerung{$i}{'PIC_DATEI'} . 
                           sprintf( "%05d", $steuerung{$i}{'AKT_ZAEHLER'} ) .
                           $steuerung{$i}{'TYP_DATEI'};

            #Speichere den Dateinamen Zaehler
            $steuerung{$i}{'AKT_ZAEHLER'} += 1;
            if( $steuerung{$i}{'AKT_ZAEHLER'} > $steuerung{$i}{'ANZAHL_PIC'} ) {
                $steuerung{$i}{'AKT_ZAEHLER'} = 0;
                gkLog( 'info', "gk: Dateinamen Zaehler auf 0 gesetzt" );
            }


            # Hole das Bild aus dem weltweiten Netz
            my $ret;
            my $zeit = time;

            $ret = system( "curl " .
                            "-s "  .                            # silent
                            "-S "  .                            # zeige Fehlermeldungen
                            "-f "  .                            # fail silent
                            "-R "  .                            # use remote timestamp
                            "-m $TIMEOUT " .                    # timeout
                            "--url \"$steuerung{$i}{'ADR'}\" " .
                            "--stderr $steuerung{$i}{'LOG_DATEI'} " .
                            "-o $dat_name "
                         );

            $zeit = time - $zeit;
            gkLog( 'trace', "gk: Bild $dat_name" );
            gkLog( 'trace', "gk: Zeit: $zeit, Ret = $ret" );

            # Uebertrage die Fehlermeldungen von Curl ins Log
            if( $ret && (-s $steuerung{$i}{'LOG_DATEI'})) {
                open my $lDatei, '<', $steuerung{$i}{'LOG_DATEI'} or croak $!;
                gkLog( 'info', "---- LOG DATEI CURL -------" );
                while( <$lDatei> ) {
                    chomp;
                    gkLog( 'info', "$_" );
                }
                gkLog( 'info', "---- LOG DATEI CURL -------" );
                close $lDatei;
            }

            # wenn die Groesse der Datei gleich der Vorgängerdatei ist dann loesche
            if( ! $ret && (-s $dat_name)) {
                my $s = (-s $dat_name);
                gkLog( 'trace', "gk: Dateigroesse $s" );
                if( $steuerung{$i}{'PIC_SIZE'} == $s ) {
                    $ret = 1;
                    gkLog( 'info', "gk: Vorgaengerdatei hat gleiche Groesse" );
                } else {
                    $steuerung{$i}{'PIC_SIZE'} = $s;
                }
            }

            # wenn es Fehler gegeben hat loesche die Bilddatei
            # ansonsten speichere den neuen Zaehler
            if( $ret ) {

                $steuerung{$i}{'AKT_ZAEHLER'} -= 1;
                gkLog( 'info', "gk: Datei Zaehler zurueckgesetzt" );
                
                if( -e $dat_name ) {
                    unlink $dat_name;
                    gkLog( 'info', "gk: geloescht $dat_name" );
                }
            } else { 

                # Speichere die Bild Nummer
                # Oeffne das File im Read/Write Mode damit es nicht gleich geloescht wird 
                open my $zDatei, '+<', $steuerung{$i}{'ZAEHLER_DATEI'} or croak $!;
                flock( $zDatei, LOCK_EX); # lock, exclusive
                seek( $zDatei, 0, 0 ); truncate( $zDatei, 0 ); # loesche das File
                print $zDatei $steuerung{$i}{'AKT_ZAEHLER'};
                close $zDatei; # entfernt auch den Lock
            }
        }
    }
    sleep $SLEEP_INTERVAL;
}

exit;

# ###########################################################################
#
# die Funktionen zum Logging
#
# ###########################################################################

sub gkLog   {

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
        gkLog( 'trace', "cnfLoad: $cnf_Datei" );
    } else {
        gkLog( 'error', "cnfLoad: $cnf_Datei" );
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
        gkLog( "warn", "cnfGet: Section oder Schluessel nicht definiert" );
		return undef;
    }

    gkLog( 'trace', "cnfGet: $section, $schluessel = $$c{$section}{$schluessel}" );
	return $$c{$section}{$schluessel}; 

}

#
# Schreibe einen Wert in das Konfigurations Hash
#
sub cnfSet   {

    my $c           = shift @_;
    my $section     = shift @_;
    my $schluessel  = shift @_;
    my $wert        = shift @_;

    gkLog( 'trace', "cnfSet: $section, $schluessel, $wert" );

    if( ! (defined($section && $schluessel))) {
        gkLog( "warn", "cnfSet: Section oder Schluessel nicht definiert" );
		return undef;
    }

	$$c{$section}{$schluessel} = $wert;
    return $wert;

}

# ###########################################################################
#
# die Funktionen fuer die Zeit Bearbeitung
#
# ###########################################################################

#
# Erzeuge aus einem Unix Timestamp Stunden und Minuten und Sekunden
#
sub stamp2zeit { 

	my $tm = localtime(shift @_);

    return(sprintf("%d:%02d:%02d",  $tm->hour, $tm->min, $tm->sec));

}
