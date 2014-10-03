
/* wires.h: wire lists for gpufield.
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

/* include the standard library header. */
#include <stdio.h>
#include <stdlib.h>

/* include the 3-vector header. */
#include "vec3.h"

/* ensure once-only inclusion. */
#ifndef __WIRES_H__
#define __WIRES_H__

typedef struct {
  unsigned int n;
  vec3 *A, *B;
  float *i;
} wirelist;

/* function declarations: */

wirelist *wires_alloc (void);

void wires_free (wirelist *wires);

void wires_add (wirelist *wires, vec3 A, vec3 B, float i);

int wires_write (wirelist *wires, const char *filename);

wirelist *wires_read (const char *filename);

float wires_mutual_inductance (wirelist *wa, wirelist *wb);

#endif /* __WIRES_H__ */

