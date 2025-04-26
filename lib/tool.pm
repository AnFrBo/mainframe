#!/opt/local/bin/perl

# #########################################################################
#
# meine kleinen Helferchen
#
# Joachim Bothe 1.6.2012
#
# #########################################################################

package tool;

use strict;
use warnings;

use OpenGL qw(:all);

# setze die Variablen fuer das Log
# level = error, warn, info, trace
BEGIN {
    use Cwd;
    our $LOG_LEVEL = 'trace';
    our $LOG_DATEI = getcwd() . "/mf.log";
}

# Standartmodule
use Readonly;
use Carp;
use Config::Std { def_sep => '=' };
use Log::StdLog{ level => $tool::LOG_LEVEL, file => $tool::LOG_DATEI, format => \&log_format };

# Loesche das Logfile
if( -e $tool::LOG_DATEI ) {
    unlink $tool::LOG_DATEI;
}

# ###########################################################################
#
# die Funktionen zum Logging
#
# ###########################################################################

sub mfLog   {

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
        mfLog( 'trace', "cnfLoad: $cnf_Datei" );
    } else {
        mfLog( 'error', "cnfLoad: $cnf_Datei" );
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
        mfLog( "warn", "cnfGet: Section oder Schluessel nicht definiert" );
		return undef;
    }

    mfLog( 'trace', "cnfGet: $section, $schluessel = $$c{$section}{$schluessel}" );
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

    mfLog( 'trace', "cnfSet: $section, $schluessel, $wert" );

    if( ! (defined($section && $schluessel))) {
        mfLog( "warn", "cnfSet: Section oder Schluessel nicht definiert" );
		return undef;
    }

	$$c{$section}{$schluessel} = $wert;
    return $wert;

}

#
# meine gl Fehlerroutine
#
sub glFehler {

    my ($t) = @_;
    my $errCode = glGetError();

    if( $errCode ) {
        my $errString = gluErrorString($errCode);
        mfLog( 'error', "glFehler: $t, $errString" );
    }
}


1;
