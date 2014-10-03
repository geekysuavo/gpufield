set terminal png enhanced font 'Free Sans Bold,22' size 2048, 1920 lw 2
set output 'plt/threed-ex.png'

unset key
set view 72, 14
set palette rgbformula 33, 13, 10

set xlabel 'X / cm'
set ylabel 'Y / cm'
set zlabel 'Z / cm'

set xrange [-10 : 10]
set yrange [-10 : 10]
set zrange [-10 : 10]
set cbrange [-2e-5 : 2e-5]

s(idx) = column(idx) * 100

splot \
 'out/gradx-1.0-y.dat' using (s(2)):(s(3)):(s(4)):5:5:5 w image, \
 'out/gradx-1.0-w.dat' using (s(2)):(s(3)):(s(4)):(s(5)):(s(6)):(s(7)) w vec \
  lt rgb 'black'

