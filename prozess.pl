#!/opt/local/bin/perl

# Finde Zombie Prozesse
# Jack 20.7.2012

use utf8;

my $loop = 100;
my $old_zeile = "";

while( $loop ) {

	my @t = `ps aux`;
	my @tt;
	my @q;
	my ($i, $j);
	my $k = 0;
	foreach $i (0..$#t) {
		@tt = split( /\s/, $t[$i] );
		$k = 0;
		foreach $j (0..$#tt) {
			if( ord( $tt[$j] ) != 0 ) {
				$q[$k++] = $tt[$j];
			}
		}
		if( $q[7] eq 'Z' || $q[7] eq 'U' ) {
			if( $old_zeile ne  $t[$i] ) {
				print $t[$i] . "\n";
				if( $loop ) {
					$loop--;
				}
			}
			$old_zeile = $t[$i];
		}
	}
}


