
/* gpufield.h: GPU-accelerated magnetostatics calculations via Biot Savart.
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
#include <stdarg.h>
#include <string.h>
#include <math.h>

/* include linux headers. */
#include <unistd.h>

/* include readline and history headers. */
#include <readline/readline.h>
#include <readline/history.h>

/* include gpufield custom headers. */
#include "log.h"
#include "cmd.h"
#include "vec3.h"
#include "wires.h"
#include "shapes.h"
#include "grid.h"

