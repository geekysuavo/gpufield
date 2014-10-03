
/* grid.h: gridded sampling of fields for gpufield.
 * Copyright (C) 2014 Bradley Worley.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the
 *
 *     Free Software Foundation, Inc.
 *     59 Temple Place, Suite 330
 *     Boston, MA 02111-1307 USA
 */

/* include standard c-library headers. */
#include <stdio.h>
#include <stdlib.h>

/* include cuda runtime headers. */
#include <cuda.h>
#include <cuda_runtime.h>

/* include gpufield custom headers. */
#include "log.h"
#include "vec3.h"
#include "wires.h"

/* ensure once-only inclusion. */
#ifndef __GRID_H__
#define __GRID_H__

/* grid: data type for gridded magnetic field values.
 */
typedef struct {
  /* @m: number of first-dimension grid points.
   * @n: number of second-dimension grid points.
   * @xyz: array of grid coordinates.
   * @f: array of field values.
   */
  unsigned int m, n;
  vec3 *xyz;
  vec3 *f;
} grid;

/* function declarations: */

grid *grid_alloc_segment (unsigned int n, vec3 A, vec3 B,
                          wirelist *wires);

grid *grid_alloc_surface (unsigned int m, unsigned int n,
                          vec3 origin, float u, float v,
                          char dim, wirelist *wires);

void grid_free (grid *G);

int grid_write (grid *G, const char *filename);

#endif /* __GRID_H__ */

