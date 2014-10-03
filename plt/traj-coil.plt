set terminal png enhanced font 'Free Sans Bold,16' size 1920, 1280 lw 2
set output 'plt/coil-1.0-traj.png'

set xrange [-0.1 : 0.1]
set style data lines

plot 'out/coil-1.0-xy.dat' \
    using 4:5 title 'Bx',\
 '' using 4:6 title 'By',\
 '' using 4:7 title 'Bz'

