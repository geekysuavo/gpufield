
/* wires.cu: wire lists for gpufield.
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

/* include the wires header. */
#include "wires.h"

/* wires_alloc: allocates a wire list.
 */
wirelist *wires_alloc (void) {
  /* declare the output wire list pointer. */
  wirelist *wires;

  /* allocate the wire list pointer. */
  wires = (wirelist *) malloc (sizeof (wirelist));
  if (!wires) return NULL;

  /* initialize the number of wires to zero. */
  wires->n = 0;

  /* initialize the data arrays. */
  wires->A = NULL;
  wires->B = NULL;
  wires->i = NULL;

  /* return the initialized wire list. */
  return wires;
}

/* wires_free: frees an allocated wire list.
 * @wires: the wire list to free.
 */
void wires_free (wirelist *wires) {
  /* don't free a null pointer. */
  if (!wires) return;

  /* check if wires exist to be freed. */
  if (wires->n > 0) {
    /* yes. free the data arrays. */
    free (wires->A);
    free (wires->B);
    free (wires->i);

    /* set the number of wires to zero. */
    wires->n = 0;
  }

  /* free the wire list pointer. */
  free (wires);
}

/* wires_add: adds a wire to a wire list.
 * @wires: the wire list to add the wire to.
 * @A: the wire starting point.
 * @B: the wire ending point.
 * @i: the wire current.
 */
void wires_add (wirelist *wires, vec3 A, vec3 B, float i) {
  /* increment the wire count. */
  wires->n++;

  /* check if the data arrays need to be allocated or reallocated. */
  if (wires->n > 1) {
    /* reallocate the data arrays. */
    wires->A = (vec3 *) realloc (wires->A, sizeof (vec3) * wires->n);
    wires->B = (vec3 *) realloc (wires->B, sizeof (vec3) * wires->n);
    wires->i = (float *) realloc (wires->i, sizeof (float) * wires->n);
  }
  else {
    /* allocate the data arrays. */
    wires->A = (vec3 *) malloc (sizeof (vec3));
    wires->B = (vec3 *) malloc (sizeof (vec3));
    wires->i = (float *) malloc (sizeof (float));
  }

  /* store the starting point into the data array. */
  wires->A[wires->n - 1].x = A.x;
  wires->A[wires->n - 1].y = A.y;
  wires->A[wires->n - 1].z = A.z;

  /* store the ending point into the data array. */
  wires->B[wires->n - 1].x = B.x;
  wires->B[wires->n - 1].y = B.y;
  wires->B[wires->n - 1].z = B.z;

  /* store the current into the data array. */
  wires->i[wires->n - 1] = i;
}

/* wires_write: wires a wire list to a text-format file.
 * @wires: the wire list to operate on.
 * @filename: the output filename.
 */
int wires_write (wirelist *wires, const char *filename) {
  /* declare required variables. */
  vec3 A, B, delta;
  unsigned int i;
  FILE *fh;
  float I;

  /* check if an actual filename was passed. */
  if (strcmp (filename, "")) {
    /* yes. open the output file for writing. */
    fh = fopen (filename, "wb");
    if (!fh) return 0;
  }

  /* loop through the wires. */
  for (i = 0; i < wires->n; i++) {
    /* get the current wire ends. */
    A = wires->A[i];
    B = wires->B[i];

    /* get the current... current. */
    I = wires->i[i];

    /* get the difference between the wire ends. */
    delta = sub (B, A);

    /* print the current wire starting point. */
    if (strcmp (filename, "")) {
      /* print to the output file handle. */
      fprintf (fh, "%u %e %e %e %e %e %e %e\n",
               i, A.x, A.y, A.z, delta.x, delta.y, delta.z, I);
    }
    else {
      /* print to standard output. */
      fprintf (stdout, "%u %e %e %e %e %e %e %e\n",
               i, A.x, A.y, A.z, delta.x, delta.y, delta.z, I);
    }
  }

  /* close the output file. */
  if (strcmp (filename, ""))
    fclose (fh);

  /* return success. */
  return 1;
}

/* wires_read: reads a wire list from a text-format file.
 * @filename: the input filename.
 */
wirelist *wires_read (const char *filename) {
  /* declare required variables. */
  wirelist *wires;
  char buf[1024];
  FILE *fh;

  /* declare some parsing variables. */
  float x, y, z, dx, dy, dz, I;
  vec3 a, b;

  /* open the input file for reading. */
  fh = fopen (filename, "rb");
  if (!fh) return NULL;

  /* allocate the wire list. */
  wires = wires_alloc ();
  if (!wires) {
    /* close the file and return nothing. */
    fclose (fh);
    return NULL;
  }

  /* loop through the lines of the input file. */
  while (!feof (fh)) {
    /* read a line from the file. */
    if (fgets (buf, 1024, fh)) {
      /* try to parse data from the line. */
      if (sscanf (buf, "%*u %e %e %e %e %e %e %e ",
                  &x, &y, &z, &dx, &dy, &dz, &I) == 7) {
        /* create the wire end vectors. */
        a = vector (x, y, z);
        b = vector (x + dx, y + dy, z + dz);

        /* add the wire into the wire list. */
        wires_add (wires, a, b, I);
      }
    }
  }

  /* close the input file. */
  fclose (fh);

  /* return the wire list. */
  return wires;
}

/* wires_mutual_inductance: computes the mutual inductance of two wire lists.
 * @wa: the first wire list.
 * @wb: the second wire list.
 */
float wires_mutual_inductance (wirelist *wa, wirelist *wb) {
  /* declare required variables. */
  vec3 Ai, Bi, Aj, Bj, xi, xj, Mi, Mj;
  unsigned int i, j;
  float L;

  /* initialize the output value. */
  L = 0.0;

  /* loop over the first wire list. */
  for (i = 0; i < wa->n; i++) {
    /* get the first wire ends. */
    Ai = wa->A[i];
    Bi = wa->B[i];

    /* compute the segment and midpoint vectors. */
    Mi = scale (0.5, add (Ai, Bi));
    xi = sub (Bi, Ai);

    /* loop over the second wire list. */
    for (j = 0; j < wb->n; j++) {
      /* get the second wire ends. */
      Aj = wb->A[j];
      Bj = wb->B[j];

      /* compute the segment and midpoint vectors. */
      Mj = scale (0.5, add (Aj, Bj));
      xj = sub (Bj, Aj);

      /* add the current contribution to the output value. */
      L += dot (xi, xj) / len (sub (Mj, Mi));
    }
  }

  /* scale the computed value. */
  L *= 1.0e-7;

  /* return the computed value. */
  return L;
}

