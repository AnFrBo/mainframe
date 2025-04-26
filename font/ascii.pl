#!/opt/local/bin/perl

use strict;
use warnings;
use utf8;

for (32..126) {
    my $c = chr($_);
    print "$_: $c\n";
}

print ord('Ä') . "->127: Ä\n";
print ord('Ö') . "->128: Ö\n";
print ord('Ü') . "->129: Ü\n";
print ord('ä') . "->130: ä\n";
print ord('ö') . "->131: ö\n";
print ord('ü') . "->132: ü\n";
print ord('ß') . "->133: ß\n";

