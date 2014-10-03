
/* shapes.h: generation of useful wire shapes for gpufield.
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
#include <stdlib.h>

/* include the gpufield custom header. */
#include "wires.h"
#include "vec3.h"

/* ensure once-only inclusion. */
#ifndef __SHAPES_H__
#define __SHAPES_H__

/* function declarations: */

int shapes_arc (wirelist *wires, vec3 origin,
                float radius, float t1, float t2,
                unsigned int n, char *dir, float I);

int shapes_circle (wirelist *wires, vec3 origin,
                   float radius, unsigned int n, char *dir, float I);

int shapes_helix (wirelist *wires, vec3 origin,
                  float radius, float pitch, float turns,
                  unsigned int n, char *dir, float I);

int shapes_helmholtz (wirelist *wires, vec3 origin,
                      float radius, float pitch, float turns,
                      unsigned int n, char *dir, float I);

int shapes_maxwell (wirelist *wires, vec3 origin,
                    float radius, float pitch, float turns,
                    unsigned int n, char *dir, float I);

int shapes_golay (wirelist *wires, vec3 origin,
                  float a, float b, float c, float theta,
                  float radius, float pitch, unsigned int turns,
                  unsigned int n, char *dir, float I);

int shapes_squarespiral (wirelist *wires, vec3 origin,
                         float width, float pitch, unsigned int turns,
                         float I);

#endif /* __SHAPES_H__ */

