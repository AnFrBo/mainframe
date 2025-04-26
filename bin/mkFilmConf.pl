#!/opt/local/bin/perl


use strict;
use warnings;

my $interpret_nr = 0;
my $interpret_alt = "";
my $start = 1;

while( <> ) {

    chomp;

    my $mov_pfad = $_;

    my @t = split( '/' );
    my @tt = split( '_', $t[$#t] );
    my @ttt = split( '\.', $tt[1] );

    my $interpret = $t[$#t -1];
    my $film_nr = $tt[0];
    my $film_name = $ttt[0];

    if( $start ) {
        $start = 0;
        $interpret_alt = $interpret;
    }

    if( $interpret_alt ne $interpret ) {
        $interpret_nr++;
        $interpret_alt = $interpret;
    }

    my $pfad = "";
    foreach (0..$#t -1) {
        $pfad .= $t[$_] . "/";
    }
    my $ini_pfad .= $pfad . "ini/" . sprintf( "%02d", $film_nr) . ".ini";
    my $jpg_pfad .= $pfad . "pic/" . sprintf( "c%02d", $film_nr) . ".jpg";
    my $movie_nr  = $film_nr -1;

    print "$interpret $film_nr $film_name\n$ini_pfad\n$jpg_pfad\n";

    open my $INI_DATEI, ">", $ini_pfad or die $!;
    print $INI_DATEI "# Automatisch generiert von mkFilmConf\n";
    print $INI_DATEI "\n\n[INFO]\n";
    print $INI_DATEI "INTERPRET_NR = $interpret_nr\n";
    print $INI_DATEI "FILM_NR = $movie_nr\n";
    print $INI_DATEI "TEXT = $interpret: $film_name\n";
    print $INI_DATEI "PIC = $jpg_pfad\n";
    print $INI_DATEI "FILM = $mov_pfad\n";
    close $INI_DATEI
}

