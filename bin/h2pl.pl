#!/opt/local/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $zeichen = "nicht definiert";
my $append  = 0;
my $dat_name= "";

GetOptions (
    "character=s"   => \$zeichen,
    "append"        => \$append,
    "dateiname=s"   => \$dat_name
           );

if($zeichen eq "nicht definiert") {
    print "Usage: h2pl -character character [-dateiname Dateiname -append]\n";
    exit;
}


my $h_dat   = "$zeichen.h";
my $pl_dat  = "$zeichen.pl";
my $p_datei;
my $h_datei;

open $h_datei, '<', $h_dat
            or die "Kann $h_dat nicht oeffnen $!\n";

if( $append ) {
    open $p_datei, '>>', $dat_name
                or die "Kann $dat_name nicht oeffnen $!\n";
} else {
    if( $dat_name eq "" ) {
        open $p_datei, '>', $pl_dat
                    or die "Kann $pl_dat nicht oeffnen $!\n";
    } else {
        open $p_datei, '>', $dat_name
                    or die "Kann $dat_name nicht oeffnen $!\n";
    }
}

my $start_output = 0;
my $calc_width = 0;
my $xmin = 0;
my $xmax = 0;
my @var_cache;
my $var_cache_i = 0;

while(<$h_datei>) {
    chomp;

    if(/unsigned int/ && !$start_output && !$append) {
        $start_output = 1;
        if( $dat_name eq "" ) {
            print $p_datei "package p_$zeichen;\n\n";
        } else {
            $dat_name =~ /(.*).pl/;
            my $package_name = $1;
            print $p_datei "package $package_name;\n\n";
        }
        print $p_datei "use strict;\nuse warnings;\n\n";
        print $p_datei "use OpenGL qw(:all);\n\n";
    }

    if(s/unsigned int (\Q$zeichen\E)(.*) = (\d*)/my \$$2$1 = $3/) {
        $start_output = 1;
        $var_cache[$var_cache_i++] = "\$$2$1";
        print $p_datei "sub prog$zeichen {\n\n";
        print $p_datei  "\t$_\n";
        next;
    }

    if(s/float (\Q$zeichen\E)(.*) \[.*/my \@$2$1 = \(/) {
        $var_cache[$var_cache_i++] = "\@$2$1";
        print $p_datei  "\t$_\n";
        if( $2 eq "Verts" ) {
            $calc_width = 1;
        }
        next;
    }

    if( $start_output ) {
        s/\/\/(.*)/# $1/;
        if( s/\};/\);/ && $calc_width) {
            $calc_width = 0;
            my $xdiff = ($xmax - $xmin);
            $var_cache[$var_cache_i++] = "\$Width$zeichen";
            print $p_datei  "\t$_\n\n";
            print $p_datei  "\tmy \$Width$zeichen = $xdiff;\n";
            next;
        };
        if( $calc_width ) {
            if( /([-+]?[0-9]*\.?[0-9]+), ([-+]?[0-9]*\.?[0-9]+), ([-+]?[0-9]*\.?[0-9]+)/ ) {
                #print "X: $1\n";
                if( $xmin == 0 && $xmax == 0 ) {
                    $xmin = $1;
                    $xmax = $1;
                }
                if ($1 < $xmin) {
                    $xmin = $1;
                } elsif ($1 > $xmax) {
                    $xmax = $1;
                }
            }
        }
        print $p_datei  "\t$_\n";
    }
}

print $p_datei  "\treturn( \n";
my $j = 0;
foreach (@var_cache) {

    # Schicke Arrays als opengl Array
    if( /^\@/ ) {
        print $p_datei "\t\tOpenGL::Array->new_list( GL_FLOAT, $_ )";
    } else {
        print $p_datei "\t\t$_";
    }
    $j++;
    if( $j != scalar(@var_cache) ) {
        print $p_datei ",\n";
    }
}
print $p_datei  ");\n\n";

print $p_datei  "}\n\n1;\n\n";

close $h_datei;
close $p_datei;
