
/* cmd.h: command-parsing functions for gpufield.
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
#include <stdarg.h>
#include <string.h>

/* include the gpufield custom headers. */
#include "log.h"
#include "vec3.h"
#include "wires.h"
#include "grid.h"
#include "shapes.h"

/* ensure once-only inclusion. */
#ifndef __CMD_H__
#define __CMD_H__

/* define all recognized commands for the gpufield program. */
#define CMD_CURRENT     "current"
#define CMD_FILE        "file"
#define CMD_NOFILE      "nofile"
#define CMD_MOVETO      "moveto"
#define CMD_LINETO      "lineto"
#define CMD_CIRCLE      "circle"
#define CMD_ARC         "arc"
#define CMD_SOLENOID    "solenoid"
#define CMD_HELMHOLTZ   "helmholtz"
#define CMD_MAXWELL     "maxwell"
#define CMD_GOLAY       "golay"
#define CMD_SQSPIRAL    "squarespiral"
#define CMD_TRAJ        "traj"
#define CMD_GRID        "grid"
#define CMD_WIRES       "wires"
#define CMD_CLEAR       "clear"
#define CMD_VERBOSE     "verbose"
#define CMD_QUIET       "quiet"
#define CMD_END         "end"

/* define all recognized argument types for gpufield. */
#define ARG_NULL  0
#define ARG_INT   1
#define ARG_UINT  2
#define ARG_CHAR  3
#define ARG_STR   4
#define ARG_FLT   5

/* function declarations: */

int cmd_parse (const char *str, const char *cmd, unsigned int n, ...);

int cmd_interpret (char *line);

#endif /* __CMD_H__ */

