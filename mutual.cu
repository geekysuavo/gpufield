
/* mutual.cu: Mutual inductance calculator for GPUfield-generated wire list.
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

/* include the gpufield header. */
#include "gpufield.h"

/* main: application entry point.
 * @argc: number of command-line arguments.
 * @argv: command-line argument string array.
 */
int main (int argc, char **argv) {
  /* ensure the argument count is correct. */
  if (argc != 3) return 1;

  /* initialize the first wire list. */
  wirelist *wa = wires_read (argv[1]);
  if (!wa) return 1;

  /* initialize the second wire list. */
  wirelist *wb = wires_read (argv[2]);
  if (!wb) return 1;

  /* compute the mutual inductance. */
  float L = wires_mutual_inductance (wa, wb);
  printf ("%e\n", L);

  /* free the wire lists. */
  wires_free (wa);
  wires_free (wb);

  /* return successfully. */
  return 0;
}

