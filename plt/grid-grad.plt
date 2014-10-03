set terminal png enhanced font 'Free Sans Bold,22' size 3840, 1280 lw 2
set output 'plt/grad' . gdim . '-1.0-grid-' . dim . '.png'

if (dim eq 'x') \
  a = 3; \
  b = 4; \
  xl = 'Y'; \
  yl = 'Z'; \
else if (dim eq 'y') \
  a = 2; \
  b = 4; \
  xl = 'X'; \
  yl = 'Z'; \
else \
  a = 2; \
  b = 3; \
  xl = 'X'; \
  yl = 'Y'

unset key
set pm3d map
set cbrange [-2e-5 : 2e-5]
set palette rgbformula 33, 13, 10

set multiplot layout 1, 3 offset -0.015, 0

set xtics format ''
set ylabel yl . ' / cm'

set title 'B_x / T' font 'Free Sans Bold,48' offset 0, 2
splot 'out/grad' . gdim . '-1.0-' . dim . '.dat' \
  using (column(a)*100):(column(b)*100):5 with image

set xlabel xl . ' / cm'
set xtics 2 format '%.0f'

unset ylabel
set ytics format ''

set title 'B_y / T' font 'Free Sans Bold,48' offset 0, 2
splot 'out/grad' . gdim . '-1.0-' . dim . '.dat' \
  using (column(a)*100):(column(b)*100):6 with image

unset xlabel
set xtics format ''

set title 'B_z / T' font 'Free Sans Bold,48' offset 0, 2
splot 'out/grad' . gdim . '-1.0-' . dim . '.dat' \
  using (column(a)*100):(column(b)*100):7 with image

unset multiplot
