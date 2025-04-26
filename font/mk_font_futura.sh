#!/bin/sh

dat_name="futura.pl"

Buchstaben="33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 \
            51 52 53 54 55 56 57 58 59 60 61 62 63 64 \
            65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 \
            84 85 86 87 88 89 90 \
            91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 \
            108 109 110 111 112 113 114 115 116 117 118 119 120 121 \
            122 123 124 125 126 127 128 129 130 131 132 133"

for i in $Buchstaben
do
    obj2opengl.pl -noscale -nomove "FuturaObj/$i.obj" -o "$i.h" -noverbose
done

Buchstaben="34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 \
            51 52 53 54 55 56 57 58 59 60 61 62 63 64 \
            65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 \
            84 85 86 87 88 89 90 \
            91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 \
            108 109 110 111 112 113 114 115 116 117 118 119 120 121 \
            122 123 124 125 126 127 128 129 130 131 132 133"

h2pl.pl -c 33 -d "$dat_name"
for i in $Buchstaben
do
    h2pl.pl -C $i -a -d "$dat_name"
done

# noch eine kosmetische Verschoenerung
sed -e 's/^1;$//' <"$dat_name" >"tmp_$dat_name"
echo "1;" >>"tmp_$dat_name"
mv "tmp_$dat_name" "$dat_name"

# aufraumen
rm *.h

