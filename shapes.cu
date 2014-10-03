
/* shapes.cu: generation of useful wire shapes for gpufield.
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

/* include the shapes header. */
#include "shapes.h"

/* shapes_checkdir: checks the direction string for validity.
 * @dir: the direction stirng to check.
 */
int shapes_checkdir (const char *dir) {
  /* check for a valid direction string. */
  if (!dir ||
      strlen (dir) != 2 ||
      (dir[0] != '+' && dir[0] != '-') ||
      (dir[1] != 'x' && dir[1] != 'y' && dir[1] != 'z'))
    return 0;

  /* otherwise... */
  return 1;
}

/* shapes_arc: adds an arc wire shape into a wire list.
 * @wires: the wire list to add the arc to.
 * @origin: the center of the arc.
 * @radius: the radius of the arc.
 * @t1: the starting angle of the arc.
 * @t2: the ending angle of the arc.
 * @n: the number of segments in the arc.
 * @dir: the normal axis of the arc.
 * @I: the current flowing through the arc.
 */
int shapes_arc (wirelist *wires, vec3 origin,
                float radius, float t1, float t2,
                unsigned int n, char *dir, float I) {
  /* declare required variables. */
  float t, v1, v2;
  unsigned int i;
  vec3 a, b;

  /* check the direction string. */
  if (!shapes_checkdir (dir)) return 0;

  /* begin at the origin. */
  a = b = origin;

  /* loop through the arc segments. */
  for (i = 0; i < n; i++) {
    /* compute the angle value. */
    t = t1 + (t2 - t1) * (((float) i) / ((float) (n - 1)));

    /* compute the helix coordinates in principal axis space. */
    v1 = radius * cos (t * M_PI / 180.0);
    v2 = radius * sin (t * M_PI / 180.0);

    /* begin at the origin. */
    b = origin;

    /* work based on the normal vector. */
    if (dir[1] == 'x') {
      /* run the arc about the x-axis. */
      b.y += v1;
      b.z += v2;
    }
    else if (dir[1] == 'y') {
      /* run the arc about the y-axis. */
      b.x += v2;
      b.z += v1;
    }
    else if (dir[1] == 'z') {
      /* run the arc about the z-axis. */
      b.x += v1;
      b.y += v2;
    }

    /* see what we should do. */
    if (i > 0) {
      /* add the current segment into the wire list. */
      wires_add (wires, a, b, I);
    }

    /* move the start point to the end point for the next segment. */
    a = b;
  }

  /* return successfully. */
  return 1;
}

/* shapes_circle: adds a circular wire shape into a wire list.
 * @wires: the wire list to add the circle to.
 * @origin: the center of the circle.
 * @radius: the radius of the circle.
 * @n: the number of segments in the circle.
 * @dir: the normal axis of the circle.
 * @I: the current flowing through the circle.
 */
int shapes_circle (wirelist *wires, vec3 origin,
                   float radius, unsigned int n, char *dir, float I) {
  /* use the arc subroutine. */
  return shapes_arc (wires, origin, radius, 0.0, 360.0, n, dir, I);
}

/* shapes_helix: adds a helical wire shape into a wire list.
 * @wires: the wire list to add the helix to.
 * @origin: the starting point of the helix.
 * @radius: the radius of the helix.
 * @pitch: the pitch of the helix.
 * @turns: the number of helical turns.
 * @n: the number of segments in the helix.
 * @dir: a string denoting the helix direction.
 * @I: the current that the helix will carry.
 */
int shapes_helix (wirelist *wires, vec3 origin,
                  float radius, float pitch, float turns,
                  unsigned int n, char *dir, float I) {
  /* declare required variables. */
  vec3 a = {0.0, 0.0, 0.0};
  vec3 b = {0.0, 0.0, 0.0};
  float t, v1, v2, v3;
  unsigned int i;

  /* check the direction string. */
  if (!shapes_checkdir (dir)) return 0;

  /* begin at the origin. */
  a = b = origin;

  /* loop through the segments of the helix. */
  for (i = 0; i < n; i++) {
    /* compute the parameter variable. */
    t = (2.0 * M_PI * turns) * (((float) i) / ((float) (n - 1)));

    /* compute the helix coordinates in principal axis space. */
    v1 = radius * cos (t);
    v2 = radius * sin (t);
    v3 = (pitch * t) / (2.0 * M_PI);

    /* reflect the helix along its principal axis if a negative direction
     * was requested.
     */
    if (dir[0] == '-')
      v3 = -v3;

    /* begin at the origin. */
    b = origin;

    /* add the coordinates into the origin based on the directionality. */
    if (dir[1] == 'x') {
      /* extend along +x or -x. */
      b.x += v3;
      b.y += v1;
      b.z += v2;
    }
    else if (dir[1] == 'y') {
      /* extend along +y or -y. */
      b.x += v2;
      b.y += v3;
      b.z += v1;
    }
    else if (dir[1] == 'z') {
      /* extend along +z or -z. */
      b.x += v1;
      b.y += v2;
      b.z += v3;
    }

    /* see what we should do. */
    if (i > 0) {
      /* add the current segment into the wire list. */
      wires_add (wires, a, b, I);
    }

    /* move the start point to the end point for the next segment. */
    a = b;
  }

  /* return successfully. */
  return 1;
}

/* shapes_helmholtz: adds a helmholtz wire shape into a wire list.
 * (this takes the same arguments as shapes_helix)
 */
int shapes_helmholtz (wirelist *wires, vec3 origin,
                      float radius, float pitch, float turns,
                      unsigned int n, char *dir, float I) {
  /* declare required variables. */
  vec3 off1, off2;
  float Radj, Iadj;

  /* check the direction string. */
  if (!shapes_checkdir (dir)) return 0;

  /* initialize the offsets. */
  off1 = origin;
  off2 = origin;

  /* define a more precise starting point for the helices. */
  Radj = (pitch * turns) / 2.0;

  /* set the current based on helmholtz directionality. */
  Iadj = I;
  if (dir[0] == '-')
    Iadj = -Iadj;

  /* determine the directionality of the helices. */
  if (dir[1] == 'x') {
    /* arrange the helices along x. */
    off1.x += radius - Radj;
    off2.x -= radius + Radj;
  }
  else if (dir[1] == 'y') {
    /* arrange the helices along y. */
    off1.y += radius - Radj;
    off2.y -= radius + Radj;
  }
  else if (dir[1] == 'z') {
    /* arrange the helices along z. */
    off1.z += radius - Radj;
    off2.z -= radius + Radj;
  }

  /* try to add the first helix. */
  if (!shapes_helix (wires, off1, radius, pitch, turns, n, dir, Iadj))
    return 0;

  /* try to add the second helix. */
  if (!shapes_helix (wires, off2, radius, pitch, turns, n, dir, Iadj))
    return 0;

  /* return successfully. */
  return 1;
}

/* shapes_maxwell: adds a maxwell wire shape into a wire list.
 * (this takes the same arguments as shapes_helix)
 */
int shapes_maxwell (wirelist *wires, vec3 origin,
                    float radius, float pitch, float turns,
                    unsigned int n, char *dir, float I) {
  /* declare required variables. */
  vec3 off1, off2, off3;
  float d12, R12, Radj, Iadj;

  /* check the direction string. */
  if (!shapes_checkdir (dir)) return 0;

  /* initialize the offsets. */
  off1 = origin;
  off2 = origin;
  off3 = origin;

  /* define a more precise starting point for the helices. */
  Radj = (pitch * turns) / 2.0;
  d12 = sqrt (3.0 / 7.0) * radius;
  R12 = sqrt (4.0 / 7.0) * radius;

  /* set the current based on helmholtz directionality. */
  Iadj = I;
  if (dir[0] == '-')
    Iadj = -Iadj;

  /* determine the directionality of the helices. */
  if (dir[1] == 'x') {
    /* arrange the helices along x. */
    off1.x += d12 - Radj;
    off2.x -= d12 + Radj;
    off3.x -= Radj;
  }
  else if (dir[1] == 'y') {
    /* arrange the helices along y. */
    off1.y += d12 - Radj;
    off2.y -= d12 + Radj;
    off3.y -= Radj;
  }
  else if (dir[1] == 'z') {
    /* arrange the helices along z. */
    off1.z += d12 - Radj;
    off2.z -= d12 + Radj;
    off3.z -= Radj;
  }

  /* try to add the first helix. */
  if (!shapes_helix (wires, off1, R12, pitch, turns, n, dir, Iadj))
    return 0;

  /* try to add the second helix. */
  if (!shapes_helix (wires, off2, R12, pitch, turns, n, dir, Iadj))
    return 0;

  /* try to add the third helix. */
  if (!shapes_helix (wires, off3, radius, pitch, turns, n, dir, Iadj))
    return 0;

  /* return successfully. */
  return 1;
}

/* shapes_golay: adds a golay wire shape into a wire list.
 * @wires: the wire list to add the golay coil to.
 * @origin: the center point of the coil arrangement.
 * @a: the z-distance between the two coil pairs.
 * @b: the total z-axis length of the arrangement.
 * @c: the total 'dir'-axis length of the arrangement.
 * @theta: the arc angle of the saddle coils.
 * @radius: the radius of the coil arrangement.
 * @pitch: the winding pitch of the coil arrangement..
 * @turns: the number of windings in the coil arrangement..
 * @n: the number of segments per arc in the arrangement..
 * @dir: a string denoting the gradient direction.
 * @I: the current that the coil will carry.
 */
int shapes_golay (wirelist *wires, vec3 origin,
                  float a, float b, float c, float theta,
                  float radius, float pitch, unsigned int turns,
                  unsigned int n, char *dir, float I) {
  /* declare required variables. */
  float z1, z2, z3, z4, t, t1, t2, t3, t4, d1, d2, dx, dy;
  vec3 off1, off2, A, B;
  unsigned int i;

  /* check the direction string. */
  if (!shapes_checkdir (dir) || dir[1] == 'z')
    return 0;

  /* compute the z-axis offsets. */
  z1 = origin.z - b / 2.0;
  z2 = origin.z - a / 2.0;
  z3 = origin.z + a / 2.0;
  z4 = origin.z + b / 2.0;

  /* loop through the turns. */
  for (i = 0, t = theta; i < turns; i++) {
    /* compute the x/y offsets. */
    d1 = radius * cos (t / 2.0 * M_PI / 180.0) + c / 2.0;
    d2 = radius * sin (t / 2.0 * M_PI / 180.0);

    /* initialize the offsets. */
    off1 = off2 = origin;

    /* compute the offsets based on the gradient direction. */
    if (dir[1] == 'x') {
      /* compute for an x-gradient. */
      off1.x += c / 2.0;
      off2.x -= c / 2.0;

      /* compute the arc angles as well. */
      t1 = 0.0 - t / 2.0;
      t2 = 0.0 + t / 2.0;
      t3 = 180.0 - t / 2.0;
      t4 = 180.0 + t / 2.0;

      /* compute the x and y values. */
      dx = d1;
      dy = d2;
    }
    else if (dir[1] == 'y') {
      /* compute for a y-gradient. */
      off1.y += c / 2.0;
      off2.y -= c / 2.0;

      /* compute the arc angles as well. */
      t1 = 90.0 - t / 2.0;
      t2 = 90.0 + t / 2.0;
      t3 = 270.0 - t / 2.0;
      t4 = 270.0 + t / 2.0;

      /* compute the x and y values. */
      dx = d2;
      dy = d1;
    }

    /* draw the arcs of the first ring. */
    off1.z = off2.z = z1;
    shapes_arc (wires, off1, radius, t1, t2, n, "+z", I);
    shapes_arc (wires, off2, radius, t4, t3, n, "+z", I);

    /* draw the arcs of the second ring. */
    off1.z = off2.z = z2;
    shapes_arc (wires, off2, radius, t3, t4, n, "+z", I);
    shapes_arc (wires, off1, radius, t2, t1, n, "+z", I);

    /* draw the arcs of the third ring. */
    off1.z = off2.z = z3;
    shapes_arc (wires, off2, radius, t3, t4, n, "+z", I);
    shapes_arc (wires, off1, radius, t2, t1, n, "+z", I);

    /* draw the arcs of the fourth ring. */
    off1.z = off2.z = z4;
    shapes_arc (wires, off1, radius, t1, t2, n, "+z", I);
    shapes_arc (wires, off2, radius, t4, t3, n, "+z", I);

    /* draw the lower first wire. */
    A = vector (dx, -dy, z2);
    B = vector (dx, -dy, z1);
    wires_add (wires, A, B, I);

    /* draw the lower second wire. */
    A = vector (dx, dy, z1);
    B = vector (dx, dy, z2);
    wires_add (wires, A, B, I);

    /* draw the lower third wire. */
    A = vector (-dx, dy, z1);
    B = vector (-dx, dy, z2);
    wires_add (wires, A, B, I);

    /* draw the lower fourth wire. */
    A = vector (-dx, -dy, z2);
    B = vector (-dx, -dy, z1);
    wires_add (wires, A, B, I);

    /* draw the upper first wire. */
    A = vector (dx, -dy, z3);
    B = vector (dx, -dy, z4);
    wires_add (wires, A, B, I);

    /* draw the upper second wire. */
    A = vector (dx, dy, z4);
    B = vector (dx, dy, z3);
    wires_add (wires, A, B, I);

    /* draw the upper third wire. */
    A = vector (-dx, dy, z4);
    B = vector (-dx, dy, z3);
    wires_add (wires, A, B, I);

    /* draw the upper fourth wire. */
    A = vector (-dx, -dy, z3);
    B = vector (-dx, -dy, z4);
    wires_add (wires, A, B, I);

    /* adjust the z-axis extents of the next turn. */
    z1 += pitch;
    z2 -= pitch;
    z3 += pitch;
    z4 -= pitch;

    /* adjust the angle of the next turn. */
    t -= ((pitch / radius) * (180.0 / M_PI));
  }

  /* return successfully. */
  return 1;
}

/* shapes_squarespiral: winds a square planar spiral curve into a wire list.
 * @wires: the wire list to add the curve to.
 * @origin: the center of the spiral.
 * @width: the width of the spiral.
 * @turns: the number of spiral turns.
 * @I: the spiral current.
 */
int shapes_squarespiral (wirelist *wires, vec3 origin,
                         float width, float pitch, unsigned int turns,
                         float I) {
  /* declare required variables. */
  unsigned int i;
  vec3 a, b;
  float w;

  /* initialize the points. */
  a = b = vector (origin.x + width / 2.0, origin.y + width / 2.0, origin.z);

  /* loop through the turns. */
  for (i = 0, w = width; i < turns; i++) {
    /* make the first line. */
    b.x -= w;
    wires_add (wires, a, b, I);
    a = b;

    /* make the second line. */
    b.y -= w;
    wires_add (wires, a, b, I);
    a = b;

    /* change the length of the next two movements. */
    w -= pitch;

    /* make the third line. */
    b.x += w;
    wires_add (wires, a, b, I);
    a = b;

    /* make the fourth line. */
    b.y += w;
    wires_add (wires, a, b, I);
    a = b;

    /* change the length of the next two movements. */
    w -= pitch;
  }

  /* return successfully. */
  return 1;
}

