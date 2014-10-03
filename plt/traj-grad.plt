set terminal png enhanced font 'Free Sans Bold,16' size 1920, 1280 lw 2
set output 'plt/grad' . dim . '-1.0-traj.png'

set xrange [-0.05 : 0.05]
set style data lines
set multiplot layout 3, 1

plot 'out/grad' . dim . '-1.0-yz.dat' \
    using 2:5 title 'Bx',\
 '' using 2:6 title 'By',\
 '' using 2:7 title 'Bz'

plot 'out/grad' . dim . '-1.0-xz.dat' \
    using 3:5 title 'Bx',\
 '' using 3:6 title 'By',\
 '' using 3:7 title 'Bz'

plot 'out/grad' . dim . '-1.0-xy.dat' \
    using 4:5 title 'Bx',\
 '' using 4:6 title 'By',\
 '' using 4:7 title 'Bz'

unset multiplot
