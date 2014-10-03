# gpufield

A CUDA-accelerated electromagnetostatics solver.

## About GPUfield

GPUfield is a small CUDA C program for calculating magnetic fields around
direct current electromagnets.

GPUfield reads a pretty terse yet flexible scripting language that allows the
user to define coil geometries in 3D space, and then take 2D slices of the
resulting magnetic fields. It's pretty quick and dirty, but useful enough
for designing coil geometries for earth's field NMR spectroscopy (EFNMR).

As an example, the following gpufield script computes the magnetic field around
an 'infinitely' long wire:

```
current 1
moveto 0 0 -1e6
lineto 0 0 1e6
moveto 0 0 0
file 'field.dat'
grid z 1 1 256 256
clear
end
```

The resulting file `field.dat` will contain nine columns of data:

```
i x y z Bx By Bz |B|
```

where the indices `i` and `j` will run from 0 to 255, `x` and `y` will run
from -0.5 to 0.5, and `z` will equal 0. The components of the magnetic field
will be stored in `Bx`, `By` and `Bz`, and the magnitude of the field will be
stored in `|B|`. (This is just a simple example, of course)

## Inspiration for GPUfield

The GPUfield program was spawned out of my search for a faster way to compute
magnetic fields of direct current electromagnets than from the magnetic
scalar potential. Finally, I ran across this paper:

> Rashdi Shah Ahmad, Amiruddin Bin Shaari, Chew Teong Han, _Magnetic Field
> Simulation of Golay Coil_, Journal of Fundamental Sciences, 2008.

After seeing how much faster and simpler the computations could be, I had to
write my own program. However, there's really no reason to burn CPU cycles on
such an embarrassingly parallel problem, so I hooked into the NVIDIA CUDA API
to accelerate the computations.

## Valid commands in GPUfield

### `current`

Sets the current for subsequent wires to 'i', in Amperes.

```
current [i]
```

### `file`

Sets the filename for subsequent writes.

```
file '[filename]'
```

### `moveto`

Moves the wire tracer to (x,y,z).

```
moveto [x] [y] [z]
```

### `lineto`

Traces a line from the current location to (x,y,z).

```
lineto [x] [y] [z]
```

### `circle`

Draws a circle of 'n' segments along 'dir'.

```
circle [dir] [radius] [n]
```

### `arc`

Draws an arc of 'n' segments from angles 't1' to 't2' along 'dir'.

```
arc [dir] [radius] [t1] [t2] [n]
```

### `solenoid`

Draws a solenoid of 'n' line segments along 'dir'.

```
solenoid [dir] [radius] [pitch] [turns] [n]
```

### `helmholtz`

Draws a helmholtz coil pair of 'n' segments along 'dir'.

```
helmholtz [dir] [radius] [pitch] [turns] [n]
```

### `maxwell`

Draws a maxwell coil triple of 'n' segments along 'dir'.

```
maxwell [dir] [radius] [pitch] [turns] [n]
```

### `golay`

Draws a golay coil of 'n' segments per arc with longitudinal axis +z and
gradient axis 'dir'.

```
golay [dir] [a] [b] [c] [theta] [radius] [pitch] [turns] [n]
```

### `traj`

Computes the field along a straight line from the current point to (x,y,z),
with 'n' equally spaced points along the line.

```
traj [x] [y] [z] [n]
```

### `grid`

Computes the field over a two-way grid having constant-dimension 'dim'
and second- and third- dimension extents (u,v) and counts (unum,vnum).

```
grid [dim] [u] [v] [unum] [vnum]
```

### `wires`

Writes the current wire list to the current filename.

```
wires
```

### `clear`

Clears the wire list.

```
clear
```

### `verbose`

Turns on verbose messages.

```
verbose
```

### `quiet`

Turns off verbose messages.

```
quiet
```

### `end`

Quits the application.

```
end
stop
quit
halt
```

