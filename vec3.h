
/* vec3.h: three-dimensional vector types for gpufield.
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

/* include the standard math header. */
#include <math.h>

/* ensure once-only inclusion. */
#ifndef __VEC3_H__
#define __VEC3_H__

/* vec3: data type for 3-vectors.
 */
typedef struct {
  /* @x: x-coordinate.
   * @y: y-coordinate.
   * @z: z-coordinate.
   */
  float x, y, z;
} vec3;

/* function declarations: */

vec3 vector (float x, float y, float z);

int vcmp (vec3 a, vec3 b);

float len (vec3 v);

float dot (vec3 a, vec3 b);

vec3 cross (vec3 a, vec3 b);

vec3 unit (vec3 v);

vec3 scale (float alpha, vec3 v);

vec3 proj (vec3 v, vec3 u);

vec3 add (vec3 a, vec3 b);

vec3 sub (vec3 a, vec3 b);

vec3 vinterp (vec3 a, vec3 b, float t);

vec3 field (vec3 A, vec3 B, vec3 M, float I);

#endif /* __VEC3_H__ */

