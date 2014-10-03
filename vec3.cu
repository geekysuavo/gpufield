
/* vec3.cu: three-dimensional vector types for gpufield.
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

/* include the vec3 header. */
#include "vec3.h"

/* define the permittivity of vacuum. */
#define MU_0 (4.0 * M_PI * 1.0e-7)

/* vector: create a 3-vector.
 * @x: the x-component.
 * @y: the y-component.
 * @z: the z-component.
 */
vec3 vector (float x, float y, float z) {
  /* declare the output vector. */
  vec3 v;

  /* set the vector components. */
  v.x = x;
  v.y = y;
  v.z = z;

  /* return the vector. */
  return v;
}

/* vcmp: compare two 3-vectors.
 * @a: the first vector.
 * @b: the second vector.
 */
int vcmp (vec3 a, vec3 b) {
  /* compute and return equality. */
  return ((a.x == b.x) && (a.y == b.y) && (a.z == b.z));
}

/* len: compute the length (euclidean norm) of a 3-vector.
 * @v: the vector to compute.
 */
float len (vec3 v) {
  /* compute and return the length. */
  return sqrt (v.x * v.x + v.y * v.y + v.z * v.z);
}

/* dot: compute the dot product of two 3-vectors.
 * @a: the first vector in the product.
 * @b: the second vector in the product.
 */
float dot (vec3 a, vec3 b) {
  /* compute and return the dot product. */
  return (a.x * b.x + a.y * b.y + a.z * b.z);
}

/* cross: compute the cross product of two 3-vectors.
 * @a: the first vector in the product.
 * @b: the second vector in the product.
 */
vec3 cross (vec3 a, vec3 b) {
  /* declare the output vector. */
  vec3 c;

  /* compute the elements of the output vector. */
  c.x = a.y * b.z - a.z * b.y;
  c.y = a.z * b.x - a.x * b.z;
  c.z = a.x * b.y - a.y * b.x;

  /* return the output vector. */
  return c;
}

/* unit: compute the unit 3-vector of a 3-vector.
 * @v: the vector to compute.
 */
vec3 unit (vec3 v) {
  /* declare the output vector. */
  float l;
  vec3 u;

  /* compute the input vector length. */
  l = len (v);

  /* compute the components of the output vector. */
  u.x = v.x / l;
  u.y = v.y / l;
  u.z = v.z / l;

  /* return the output vector. */
  return u;
}

/* scale: scale a 3-vector by a scalar value.
 * @alpha: the scalar value.
 * @v: the vector to scale.
 */
vec3 scale (float alpha, vec3 v) {
  /* declare the output vector. */
  vec3 s;

  /* compute the elements of the output vector. */
  s.x = alpha * v.x;
  s.y = alpha * v.y;
  s.z = alpha * v.z;

  /* return the output vector. */
  return s;
}

/* proj: project a 3-vector onto another unit 3-vector.
 * @v: the 3-vector to compute.
 * @u: the unit 3-vector to project @v onto.
 */
vec3 proj (vec3 v, vec3 u) {
  /* compute and return the projection. */
  return scale (dot (v, u), u);
}

/* add: add two 3-vectors.
 * @a: the first vector.
 * @b: the second vector.
 */
vec3 add (vec3 a, vec3 b) {
  /* declare the output vector. */
  vec3 c;

  /* compute the elements of the output vector. */
  c.x = a.x + b.x;
  c.y = a.y + b.y;
  c.z = a.z + b.z;

  /* return the output vector. */
  return c;
}

/* sub: subtract two 3-vectors.
 * @a: the first vector.
 * @b: the second vector.
 */
vec3 sub (vec3 a, vec3 b) {
  /* declare the output vector. */
  vec3 c;

  /* compute the elements of the output vector. */
  c.x = a.x - b.x;
  c.y = a.y - b.y;
  c.z = a.z - b.z;

  /* return the output vector. */
  return c;
}

/* vinterp: interpolates between two 3-vectors.
 * @a: the starting vector.
 * @b: the ending vector.
 * @t: the interpolation factor.
 */
vec3 vinterp (vec3 a, vec3 b, float t) {
  /* compute and return the output vector. */
  return add (a, scale (t, sub (b, a)));
}

/* field: compute the magnetic field vector at a point M due to an
 * infinitely narrow wire along segment AB carrying current I.
 */
vec3 field (vec3 A, vec3 B, vec3 M, float I) {
  /* declare required variables. */
  float c1, c2, dLM, mag;
  vec3 vAB, vAM, vBM, vLM;
  vec3 uAB, uAM, uBM, uLM;
  vec3 f;

  /* compute the vector between the endpoints of the wire. */
  vAB = sub (B, A);
  uAB = unit (vAB);

  /* compute the vector from the start point to the calculation point. */
  vAM = sub (M, A);
  uAM = unit (vAM);

  /* compute the vector from the end point to the calculation point. */
  vBM = sub (M, B);
  uBM = unit (vBM);

  /* find the angles from the wire ends to the calculation point. */
  c1 = dot (uAB, uAM);
  c2 = dot (uAB, uBM);

  /* compute a vector from the wire to the calculation point, such that
   * the vector is perpindicular to the wire.
   */
  vLM = sub (vAM, proj (vAM, uAB));
  uLM = unit (vLM);
  dLM = len (vLM);

  /* compute the magnitude of the field vector. */
  mag = ((MU_0 * I) / (4.0 * M_PI * dLM)) * (c1 - c2);

  /* compute the direction (and scale it) of the field vector. */
  f = cross (uAB, uLM);
  f = scale (mag, f);

  /* return the computed field value. */
  return f;
}

