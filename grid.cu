
/* grid.cu: gridded sampling of fields for gpufield.
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

/* include the grid header. */
#include "grid.h"

/* fval: macro to extract the field vector from a grid in row-major form.
 * @G: the grid pointer to operate on.
 * @i: the row index.
 * @j: the column index.
 */
#define fval(G, i, j) ((G)->f[(i) * (G)->n + (j)])

/* xyzval: macro to extract the location from a grid in row-major form.
 * @G: the grid pointer to operate on.
 * @i: the row index.
 * @j: the column index.
 */
#define xyzval(G, i, j) ((G)->xyz[(i) * (G)->n + (j)])

/* grid_exec_gpu_task: gpu kernel for computing the field at a grid point.
 * @a: array of wire starting points.
 * @b: array of wire ending points.
 * @I: array of wire currents.
 * @g: array of grid coordinates.
 * @f: array of field values.
 * @J: number of wires.
 */
__global__ void grid_exec_gpu_task (float *a, float *b, float *I,
                                    float *g, float *f, int J) {
  /* declare all required intermediate variables. */
  float ax, ay, az, bx, by, bz, gx, gy, gz, fx, fy, fz;
  float vABx, vABy, vABz, uABx, uABy, uABz, dAB;
  float vAMx, vAMy, vAMz, uAMx, uAMy, uAMz, dAM;
  float vBMx, vBMy, vBMz, uBMx, uBMy, uBMz, dBM;
  float vLMx, vLMy, vLMz, uLMx, uLMy, uLMz, dLM;
  float vALx, vALy, vALz;
  float c1, c2, prj, c;
  float current;

  /* get the kernel index and declare a wire loop counter. */
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  int j;

  /* get the current grid coordinates. */
  gx = g[3 * i];
  gy = g[3 * i + 1];
  gz = g[3 * i + 2];

  /* initialize the field value. */
  fx = fy = fz = 0.0;

  /* loop for all wires. */
  for (j = 0; j < J; j++) {
    /* get the wire starting point. */
    ax = a[3 * j];
    ay = a[3 * j + 1];
    az = a[3 * j + 2];

    /* get the wire ending point. */
    bx = b[3 * j];
    by = b[3 * j + 1];
    bz = b[3 * j + 2];

    /* get the wire current. */
    current = I[3 * j];

    /* compute the vector between the wire ends. */
    vABx = bx - ax;
    vABy = by - ay;
    vABz = bz - az;

    /* compute the vector between the start and the grid. */
    vAMx = gx - ax;
    vAMy = gy - ay;
    vAMz = gz - az;

    /* compute the vector between the end and the grid. */
    vBMx = gx - bx;
    vBMy = gy - by;
    vBMz = gz - bz;

    /* compute the lengths of AB, AM, and BM. */
    dAB = sqrt (vABx * vABx + vABy * vABy + vABz * vABz);
    dAM = sqrt (vAMx * vAMx + vAMy * vAMy + vAMz * vAMz);
    dBM = sqrt (vBMx * vBMx + vBMy * vBMy + vBMz * vBMz);

    /* compute the unit vector between the wire ends. */
    uABx = vABx / dAB;
    uABy = vABy / dAB;
    uABz = vABz / dAB;

    /* compute the unit vector between the start and the grid. */
    uAMx = vAMx / dAM;
    uAMy = vAMy / dAM;
    uAMz = vAMz / dAM;

    /* compute the unit vector between the end and the grid. */
    uBMx = vBMx / dBM;
    uBMy = vBMy / dBM;
    uBMz = vBMz / dBM;

    /* find the angles from the wire ends to the grid point. */
    c1 = uABx * uAMx + uABy * uAMy + uABz * uAMz;
    c2 = uABx * uBMx + uABy * uBMy + uABz * uBMz;

    /* compute the dot product of AM and AB. */
    prj = vAMx * uABx + vAMy * uABy + vAMz * uABz;

    /* project AM onto AB to yield AL. */
    vALx = uABx * prj;
    vALy = uABy * prj;
    vALz = uABz * prj;

    /* compute the vector between the wire inner point and the grid. */
    vLMx = vAMx - vALx;
    vLMy = vAMy - vALy;
    vLMz = vAMz - vALz;

    /* compute the length of LM. */
    dLM = sqrt (vLMx * vLMx + vLMy * vLMy + vLMz * vLMz);

    /* compute the unit vector between the wire inner point and the grid. */
    uLMx = vLMx / dLM;
    uLMy = vLMy / dLM;
    uLMz = vLMz / dLM;

    /* compute the magnetic field unit vector components. */
    fx = uABy * uLMz - uABz * uLMy;
    fy = uABz * uLMx - uABx * uLMz;
    fz = uABx * uLMy - uABy * uLMx;

    /* compute the magnetic field magnitude and scale
     * the vector components accordingly.
     */
    c = 1.0e-7f * current * (c1 - c2) / dLM;
    fx *= c;
    fy *= c;
    fz *= c;

    /* sum in the current wire's contribution to the field. */
    f[3 * i + 0] += fx;
    f[3 * i + 1] += fy;
    f[3 * i + 2] += fz;
  }
}

/* grid_exec_gpu: computes the gridded field values using the gpu.
 * @G: the grid to compute field values for.
 * @wires: the wire list.
 */
void grid_exec_gpu (grid *G, wirelist *wires) {
  /* declare host arrays. */
  float *wmem, *gmem;
  
  /* declare device arrays. */
  float *a, *b, *i, *g, *f;

  /* declare array size variables. */
  unsigned int nw, ng, m, n;

  /* declare a loop index. */
  unsigned int k;

  /* compute the array sizes. */
  nw = 3 * wires->n;
  ng = 3 * G->m * G->n;

  /* allocate the host arrays. */
  wmem = (float *) calloc (nw, sizeof (float));
  gmem = (float *) calloc (ng, sizeof (float));

  /* fill the nw-length host array with information for 'a'. */
  for (k = 0; k < wires->n; k++) {
    wmem[3 * k + 0] = wires->A[k].x;
    wmem[3 * k + 1] = wires->A[k].y;
    wmem[3 * k + 2] = wires->A[k].z;
  }

  /* allocate the device 'a' array and copy the host array into it. */
  cudaMalloc ((void **) &a, nw * sizeof (float));
  cudaMemcpy (a, wmem, nw * sizeof (float), cudaMemcpyHostToDevice);

  /* fill the nw-length host array with information for 'b'. */
  for (k = 0; k < wires->n; k++) {
    wmem[3 * k + 0] = wires->B[k].x;
    wmem[3 * k + 1] = wires->B[k].y;
    wmem[3 * k + 2] = wires->B[k].z;
  }

  /* allocate the device 'b' array and copy the host array into it. */
  cudaMalloc ((void **) &b, nw * sizeof (float));
  cudaMemcpy (b, wmem, nw * sizeof (float), cudaMemcpyHostToDevice);

  /* fill the nw-length host array with information for 'i'. */
  for (k = 0; k < wires->n; k++) {
    wmem[3 * k + 0] = wires->i[k];
    wmem[3 * k + 1] = wires->i[k];
    wmem[3 * k + 2] = wires->i[k];
  }

  /* allocate the device 'i' array and copy the host array into it. */
  cudaMalloc ((void **) &i, nw * sizeof (float));
  cudaMemcpy (i, wmem, nw * sizeof (float), cudaMemcpyHostToDevice);

  /* fill the ng-length host array with information for 'g'. */
  for (k = 0; k < G->m * G->n; k++) {
    gmem[3 * k + 0] = G->xyz[k].x;
    gmem[3 * k + 1] = G->xyz[k].y;
    gmem[3 * k + 2] = G->xyz[k].z;
  }

  /* allocate the device 'g' array and copy the host array into it. */
  cudaMalloc ((void **) &g, ng * sizeof (float));
  cudaMemcpy (g, gmem, ng * sizeof (float), cudaMemcpyHostToDevice);

  /* fill the ng-length host array with information for 'f'. */
  for (k = 0; k < ng; k++)
    gmem[k] = 0.0;

  /* allocate the device 'f' array and copy the host array into it. */
  cudaMalloc ((void **) &f, ng * sizeof (float));
  cudaMemcpy (f, gmem, ng * sizeof (float), cudaMemcpyHostToDevice);

  /* initialize the kernel block and thread sizes. */
  m = G->m;
  n = G->n;

  /* check if we can fix up the thread size. */
  while (n > 1024) {
    m *= 2;
    n /= 2;
  }

  /* execute the gpu kernel. */
  grid_exec_gpu_task<<<m, n>>> (a, b, i, g, f, wires->n);

  /* copy back the result from the gpu into the ng-length host array. */
  cudaMemcpy (gmem, f, ng * sizeof (float), cudaMemcpyDeviceToHost);

  /* extract back information from the ng-length host array
   * into the grid structure.
   */
  for (k = 0; k < G->m * G->n; k++) {
    G->f[k].x = gmem[3 * k + 0];
    G->f[k].y = gmem[3 * k + 1];
    G->f[k].z = gmem[3 * k + 2];
  }

  /* free the device arrays. */
  cudaFree (a);
  cudaFree (b);
  cudaFree (i);
  cudaFree (g);
  cudaFree (f);

  /* free the host arrays. */
  free (wmem);
  free (gmem);
}

/* grid_exec_cpu: computes the gridded field values using a single cpu core.
 * @G: the grid to compute field values for.
 * @wires: the wire list.
 */
void grid_exec_cpu (grid *G, wirelist *wires) {
  /* declare looping variables. */
  unsigned int i, j;

  /* loop over the grid array index. */
  for (i = 0; i < G->m * G->n; i++) {
    /* loop over the wire list array index. */
    for (j = 0; j < wires->n; j++) {
      /* add in the j-th wire's contribution to the i-th grid point. */
      G->f[i] = add (G->f[i], field (wires->A[j], wires->B[j], G->xyz[i],
                                     wires->i[j]));
    }
  }
}

/* grid_alloc: allocates a certain size grid.
 * @m: the number of first-dim points.
 * @n: the number of second-dim points.
 */
grid *grid_alloc (unsigned int m, unsigned int n) {
  /* allocate the grid pointer. */
  grid *G = (grid *) malloc (sizeof (grid));
  if (!G) return NULL;

  /* check the grid size. */
  if ((n & (n - 1)) != 0) {
    /* print an error message and return nothing. */
    logf ("grid second dimension must be a power of two");
    return NULL;
  }

  /* store the grid size into the pointer. */
  G->m = m;
  G->n = n;

  /* allocate the grid coordinates array. */
  G->xyz = (vec3 *) calloc (G->m * G->n, sizeof (vec3));
  if (!G->xyz) return NULL;

  /* allocate the field values array. */
  G->f = (vec3 *) calloc (G->m * G->n, sizeof (vec3));
  if (!G->f) return NULL;

  /* return the grid pointer. */
  return G;
}

/* grid_alloc_segment: allocates a grid segment and computes its values.
 * @n: the number of grid segment points.
 * @A: the starting point of the segment.
 * @B: the ending point of the segment.
 * @wires: the wire list to use during calculation.
 */
grid *grid_alloc_segment (unsigned int n, vec3 A, vec3 B,
                          wirelist *wires) {
  /* declare loop variables and the output grid pointer. */
  unsigned int i;
  grid *G;

  /* allocate the grid pointer. */
  G = grid_alloc (1, n);
  if (!G) return NULL;

  /* loop through the grid elements. */
  for (i = 0; i < n; i++) {
    /* interpolate between the two points. */
    G->xyz[i] = vinterp (A, B, ((float) i) / ((float) (n - 1)));
  }

  /* use the gpu to calculate the field values at the grid coordinates. */
  grid_exec_gpu (G, wires);

  /* return the allocated grid pointer. */
  return G;
}

/* grid_alloc_surface: allocates a grid surface and computes its values.
 * @m: the number of first-dimension grid points.
 * @n: the number of second-dimension grid points.
 * @origin: the origin of the grid.
 * @u: the first-dimension extents.
 * @v: the second-dimension extents.
 * @dim: the dimension to keep constant.
 * @wires: the wire list to use during calculation.
 */
grid *grid_alloc_surface (unsigned int m, unsigned int n,
                          vec3 origin, float u, float v,
                          char dim, wirelist *wires) {
  /* declare loop variables and the output grid pointer. */
  unsigned int i, j;
  grid *G;

  /* allocate the grid pointer. */
  G = grid_alloc (m, n);
  if (!G) return NULL;

  /* determine the grid constant dimension. */
  if (dim == 'x' || dim == 'X') {
    /* loop through the y-dimension grid points. */
    for (i = 0; i < m; i++) {
      /* loop through the z-dimension grid points. */
      for (j = 0; j < n; j++) {
        /* compute the grid coordinate at (i,j). */
        xyzval (G, i, j) = origin;
        xyzval (G, i, j).y += u * ((float) i / (float) m) - (u / 2.0);
        xyzval (G, i, j).z += v * ((float) j / (float) n) - (v / 2.0);
      }
    }
  }
  else if (dim == 'y' || dim == 'Y') {
    /* loop through the x-dimension grid points. */
    for (i = 0; i < m; i++) {
      /* loop through the z-dimension grid points. */
      for (j = 0; j < n; j++) {
        /* compute the grid coordinate at (i,j). */
        xyzval (G, i, j) = origin;
        xyzval (G, i, j).x += u * ((float) i / (float) m) - (u / 2.0);
        xyzval (G, i, j).z += v * ((float) j / (float) n) - (v / 2.0);
      }
    }
  }
  else if (dim == 'z' || dim == 'Z') {
    /* loop through the x-dimension grid points. */
    for (i = 0; i < m; i++) {
      /* loop through the y-dimension grid points. */
      for (j = 0; j < n; j++) {
        /* compute the grid coordinate at (i,j). */
        xyzval (G, i, j) = origin;
        xyzval (G, i, j).x += u * ((float) i / (float) m) - (u / 2.0);
        xyzval (G, i, j).y += v * ((float) j / (float) n) - (v / 2.0);
      }
    }
  }
  else {
    /* invalid constant dimension. */
    return NULL;
  }

  /* use the gpu to calculate the field values at the grid coordinates. */
  grid_exec_gpu (G, wires);

  /* return the allocated grid pointer. */
  return G;
}

/* grid_free: frees an allocated grid pointer.
 * @G: the grid pointer to free.
 */
void grid_free (grid *G) {
  /* don't free a null pointer. */
  if (!G) return;

  /* check if there are grid elements to free. */
  if (G->m > 0 || G->n > 0) {
    /* free the grid coordinate and field arrays. */
    free (G->xyz);
    free (G->f);

    /* set the grid sizes to zero. */
    G->m = 0;
    G->n = 0;
  }

  /* free the grid pointer. */
  free (G);
}

/* grid_write: writes a grid's data to a text-format file.
 * @G: the grid to extract data from.
 * @filename: the output filename.
 */
int grid_write (grid *G, const char *filename) {
  /* declare output variables. */
  unsigned int i;
  vec3 xyz, f;
  FILE *fh;

  /* check if an actual filename was passed. */
  if (strcmp (filename, "")) {
    /* yes. open the output file for writing. */
    fh = fopen (filename, "wb");
    if (!fh) return 0;
  }

  /* loop through the grid array elements. */
  for (i = 0; i < G->m * G->n; i++) {
    /* extract the grid coordinate and field value. */
    xyz = G->xyz[i];
    f = G->f[i];

    /* print the coordinate and field value to the output file. */
    if (strcmp (filename, "")) {
      /* print to the output file handle. */
      fprintf (fh, "%u %e %e %e %e %e %e %e\n", i,
               xyz.x, xyz.y, xyz.z,
               f.x, f.y, f.z,
               len (f));
     }
     else {
      /* print to standard output. */
      fprintf (stdout, "%u %e %e %e %e %e %e %e\n", i,
               xyz.x, xyz.y, xyz.z,
               f.x, f.y, f.z,
               len (f));
    }
  }

  /* close the output file. */
  if (strcmp (filename, ""))
    fclose (fh);

  /* return success. */
  return 1;
}

