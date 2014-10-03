
/* cmd.cu: command-parsing functions for gpufield.
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

/* include the cmd header. */
#include "cmd.h"

/* cmd_parse_metric: parses metric-suffixed floating point numbers.
 * @str: the string to parse.
 */
float cmd_parse_metric (const char *str) {
  /* declare required variables. */
  unsigned int i;
  float val;

  /* convert the first part of the response string to a number. */
  val = atof (str);

  /* loop until a suitable last character is found. */
  i = 0; while (str[i] != ' ' && str[i] != '\n' && str[i] != '\0') i++;

  /* see if the number was suffixed with a metric prefix. */
  switch (str[i - 1]) {
    /* exa. */
    case 'E':
      val *= 1e+18;
      break;

    /* peta. */
    case 'P':
      val *= 1e+15;
      break;

    /* tera. */
    case 'T':
      val *= 1e+12;
      break;

    /* giga. */
    case 'G':
      val *= 1e+09;
      break;

    /* mega. */
    case 'M':
      val *= 1e+06;
      break;

    /* kilo. */
    case 'k':
      val *= 1e+03;
      break;

    /* centi. */
    case 'c':
      val *= 1e-02;
      break;

    /* milli. */
    case 'm':
      val *= 1e-03;
      break;

    /* micro. */
    case 'u':
      val *= 1e-06;
      break;

    /* nano. */
    case 'n':
      val *= 1e-09;
      break;

    /* pico. */
    case 'p':
      val *= 1e-12;
      break;

    /* femto. */
    case 'f':
      val *= 1e-15;
      break;

    /* atto. */
    case 'a':
      val *= 1e-18;
      break;

    /* anything else... */
    default:
      break;
  }

  /* return the parsed value. */
  return val;
}

/* cmd_parse: parses a string for possible commands.
 * @str: the input string to parse.
 * @cmd: the command name to check.
 * @n: the number of arguments to parse.
 * @...: (type, pointer) pairs, one per argument.
 */
int cmd_parse (const char *str, const char *cmd, unsigned int n, ...) {
  /* declare required variables. */
  unsigned int i, arg_type;
  char *pstr, *poff;
  void *arg_ptr;
  va_list vl;

  /* set the current location pointer. */
  pstr = (char *) str;

  /* loop until we find a non-whitespace character. */
  while ((*pstr == ' ' || *pstr == '\n') && *pstr != '\0')
    pstr++;

  /* check the string against the expected command. */
  if (strlen (pstr) < strlen (cmd) || strncmp (pstr, cmd, strlen (cmd)))
    return 0;

  /* loop until we find a whitespace character. */
  while (*pstr != ' ' && *pstr != '\n' && *pstr != '\0')
    pstr++;

  /* start parsing the argument list. */
  va_start (vl, n);

  /* loop for every expected argument. */
  for (i = 0; i < n; i++) {
    /* loop until we find a non-whitespace character. */
    while ((*pstr == ' ' || *pstr == '\n') && *pstr != '\0')
      pstr++;

    /* check that we're not at the end. */
    if (!strlen (pstr)) {
      /* end parsing the argument list and return failure. */
      va_end (vl);
      return 0;
    }

    /* get the argument type and pointer. */
    arg_type = va_arg (vl, unsigned int);
    arg_ptr = va_arg (vl, void *);

    /* act based on the argument type. */
    switch (arg_type) {
      /* null */
      case ARG_NULL:
        continue;

      /* %d */
      case ARG_INT:
        *((int *) arg_ptr) = atoi (pstr);
        break;

      /* %u */
      case ARG_UINT:
        *((unsigned int *) arg_ptr) = atoi (pstr);
        break;

      /* %c */
      case ARG_CHAR:
        *((char *) arg_ptr) = *pstr;
        break;

      /* %[^ ] */
      case ARG_STR:
        /* initialize the offset pointer. */
        poff = pstr;

        /* loop until we find a whitespace character. */
        while (*poff != ' ' && *poff != '\n' && *poff != '\0')
          poff++;

        /* copy the string over. */
        strncpy ((char *) arg_ptr, pstr, poff - pstr);
        ((char *) arg_ptr)[poff - pstr] = '\0';

        /* break parsing. */
        break;

      /* %f, extended. */
      case ARG_FLT:
        *((float *) arg_ptr) = cmd_parse_metric (pstr);
        break;
    }

    /* loop until we find a whitespace character. */
    while (*pstr != ' ' && *pstr != '\n' && *pstr != '\0')
      pstr++;
  }

  /* end parsing the argument list. */
  va_end (vl);

  /* return success. */
  return 1;
}

/* cmd_interpret: main command interpretation function.
 * @line: the command string to interpret.
 */
int cmd_interpret (char *line) {
  /* @a: starting location of wires / origin of grids.
   * @b: ending location of wires.
   */
  static vec3 a, b;

  /* @i: wire currents.
   * @x: parsing storage for x-values.
   * @y: parsing storage for y-values.
   * @z: parsing storage for z-values.
   */
  static float i;
  float x, y, z;

  /* @width: grid first-dimension extents and square spiral width.
   * @height: grid second-dimension extents.
   * @m: grid first-dimension divisions.
   * @n: grid second-dimension divisions.
   * @dim: dimension mode for grids.
   */
  float width, height;
  unsigned int m, n;
  char dim;

  /* @radius: radius of solenoids, arcs, circles, etc.
   * @pitch: wire diameter or winding pitch for multiturn structures.
   */
  float radius, pitch;

  /* @t: angle of arc for golay coil structures.
   * @t1: starting angle for arc structures.
   * @t2: ending angle for arc structures.
   */
  float t, t1, t2;

  /* @ga: 'a'-parameter (saddle separation) for golay coils.
   * @gb: 'b'-parameter (total length) for golay coils.
   * @gc: 'c'-parameter (radial saddle separation) for golay coils.
   */
  static float ga, gb, gc;

  /* @uturns: integral turn count.
   * @fturns: non-integral turn count.
   */
  unsigned int uturns;
  float fturns;

  /* @dir: direction string for solenoids, arcs, circles, etc.
   * @fname: output filename, or blank for standard output.
   */
  static char fname[256];
  char dir[256];

  /* @verb: verbosity flag.
   */
  static int verb = 0;

  /* declare pointers to a wire list and a grid. */
  static wirelist *wires;
  static grid *G;

  /* initialize the wire list. */
  if (!wires)
    wires = wires_alloc ();

  /* strip the newline from the end of the line buffer string. */
  if (line[strlen (line) - 1] == '\n')
    line[strlen (line) - 1] = '\0';

  /* skip parsing of empty lines. */
  if (strlen (line) <= 0)
    return 1;

  /* skip parsing of commented lines. */
  if (strlen (line) > 0 && line[0] == '#')
    return 1;

  /* parse the line buffer for command content. */
  if (cmd_parse (line, CMD_CURRENT, 1, ARG_FLT, &i)) {
    /* print a log message. */
    if (verb) logf ("set I = %.2e", i);
  }
  else if (cmd_parse (line, CMD_FILE, 1, ARG_STR, fname)) {
    /* print a log message. */
    if (verb) logf ("set file = '%s'", fname);
  }
  else if (cmd_parse (line, CMD_NOFILE, 0)) {
    /* set the file string. */
    strcpy (fname, "");

    /* print a log message. */
    if (verb) logf ("set file => stdout");
  }
  else if (cmd_parse (line, CMD_MOVETO, 3,
                      ARG_FLT, &x,
                      ARG_FLT, &y,
                      ARG_FLT, &z)) {
    /* move both endpoints to the new location. */
    a = b = vector (x, y, z);
  }
  else if (cmd_parse (line, CMD_LINETO, 3,
                      ARG_FLT, &x,
                      ARG_FLT, &y,
                      ARG_FLT, &z)) {
    /* move the end vector to the new location. */
    b = vector (x, y, z);

    /* add a wire between the start and end points. */
    wires_add (wires, a, b, i);

    /* move the start vector to the new location. */
    a = b;
  }
  else if (cmd_parse (line, CMD_CIRCLE, 3,
                      ARG_STR,  dir,
                      ARG_FLT,  &radius,
                      ARG_UINT, &n)) {
    /* try to build a circle. */
    if (!shapes_circle (wires, a, radius, n, dir, i))
      logf ("failed to build circle");
  }
  else if (cmd_parse (line, CMD_ARC, 5,
                      ARG_STR,  dir,
                      ARG_FLT,  &radius,
                      ARG_FLT,  &t1,
                      ARG_FLT,  &t2,
                      ARG_UINT, &n)) {
    /* try to build an arc. */
    if (!shapes_arc (wires, a, radius, t1, t2, n, dir, i))
      logf ("failed to build arc");
  }
  else if (cmd_parse (line, CMD_SOLENOID, 5,
                      ARG_STR,  dir,
                      ARG_FLT,  &radius,
                      ARG_FLT,  &pitch,
                      ARG_FLT,  &fturns,
                      ARG_UINT, &n)) {
    /* try to build a helix. */
    if (!shapes_helix (wires, a, radius, pitch, fturns, n, dir, i))
      logf ("failed to build solenoid");
  }
  else if (cmd_parse (line, CMD_HELMHOLTZ, 5,
                      ARG_STR,  dir,
                      ARG_FLT,  &radius,
                      ARG_FLT,  &pitch,
                      ARG_FLT,  &fturns,
                      ARG_UINT, &n)) {
    /* try to build a helmholtz arrangement. */
    if (!shapes_helmholtz (wires, a, radius, pitch, fturns, n, dir, i))
      logf ("failed to build helmholtz");
  }
  else if (cmd_parse (line, CMD_MAXWELL, 5,
                      ARG_STR,  dir,
                      ARG_FLT,  &radius,
                      ARG_FLT,  &pitch,
                      ARG_FLT,  &fturns,
                      ARG_UINT, &n)) {
    /* try to build a maxwell arrangement. */
    if (!shapes_maxwell (wires, a, radius, pitch, fturns, n, dir, i))
      logf ("failed to build maxwell");
  }
  else if (cmd_parse (line, CMD_GOLAY, 9,
                      ARG_STR,  dir,
                      ARG_FLT,  &ga,
                      ARG_FLT,  &gb,
                      ARG_FLT,  &gc,
                      ARG_FLT,  &t,
                      ARG_FLT,  &radius,
                      ARG_FLT,  &pitch,
                      ARG_UINT, &uturns,
                      ARG_UINT, &n)) {
    /* try to build a golay arrangement. */
    if (!shapes_golay (wires, a, ga, gb, gc, t,
                       radius, pitch, uturns,
                       n, dir, i))
      logf ("failed to build golay");
  }
  else if (cmd_parse (line, CMD_SQSPIRAL, 3,
                      ARG_FLT,  &width,
                      ARG_FLT,  &pitch,
                      ARG_UINT, &uturns)) {
    /* try to build a square planar spiral. */
    if (!shapes_squarespiral (wires, a, width, pitch, uturns, i))
      logf ("failed to build square planar spiral");
  }
  else if (cmd_parse (line, CMD_TRAJ, 4,
                      ARG_FLT,  &x,
                      ARG_FLT,  &y,
                      ARG_FLT,  &z,
                      ARG_UINT, &n)) {
    /* set the trajectory end point. */
    b = vector (x, y, z);

    /* check if verbose logging is enabled. */
    if (verb) {
      /* print a log message. */
      logf ("set A = { %.2e, %.2e, %.2e }", a.x, a.y, a.z);
      logf ("set B = { %.2e, %.2e, %.2e }", b.x, b.y, b.z);
      logf ("sample trajectory ( A -> B )");
    }

    /* allocate a grid and compute the field at its points. */
    G = grid_alloc_segment (n, a, b, wires);

    /* ensure the grid was successfully built. */
    if (!G) {
      /* nope. print a warning message and move along. */
      logf ("failed to compute field at grid coordinates");
      return 0;
    }

    /* write a log message. */
    if (verb) {
      if (strcmp (fname, "") == 0)
        logf ("write grid => stdout");
      else
        logf ("write grid => '%s'", fname);
    }

    /* try to write the grid to a file. */
    if (!grid_write (G, fname)) {
      /* failure. print a warning message and move along. */
      logf ("failed to write grid to '%s'", fname);
    }

    /* free the grid. */
    grid_free (G);

    /* set the new starting point. */
    a = b;
  }
  else if (cmd_parse (line, CMD_GRID, 5,
                      ARG_CHAR, &dim,
                      ARG_FLT,  &width,
                      ARG_FLT,  &height,
                      ARG_UINT, &m,
                      ARG_UINT, &n)) {
    /* ensure the dimension mode is valid. */
    if (dim != 'x' && dim != 'y' && dim != 'z') {
      /* invalid mode. print a warning message and move along. */
      logf ("invalid dimension '%c'", dim);
      return 0;
    }

    /* check if verbose logging is enabled. */
    if (verb) {
      /* yes, it is. print a log message. */
      logf ("set A = { %.2e, %.2e, %.2e }", a.x, a.y, a.z);
      logf ("sample ( d%c: %.2e, d%c: %.2e )",
            dim == 'x' ? 'y' : dim == 'y' ? 'x' : 'x', width,
            dim == 'x' ? 'z' : dim == 'y' ? 'z' : 'y', height);
    }

    /* allocate a grid and compute the field at its points. */
    G = grid_alloc_surface (m, n, a, width, height, dim, wires);

    /* ensure the grid was successfully built. */
    if (!G) {
      /* nope. print a warning message and move along. */
      logf ("failed to compute field at grid coordinates");
      return 0;
    }

    /* write a log message. */
    if (verb) {
      if (strcmp (fname, "") == 0)
        logf ("write grid => stdout");
      else
        logf ("write grid => '%s'", fname);
    }

    /* try to write the grid to a file. */
    if (!grid_write (G, fname)) {
      /* failure. print a warning message and move along. */
      logf ("failed to write grid to '%s'", fname);
    }

    /* free the grid. */
    grid_free (G);
  }
  else if (cmd_parse (line, CMD_WIRES, 0)) {
    /* print a log message. */
    if (verb) {
      if (strcmp (fname, "") == 0)
        logf ("write wires => stdout");
      else
        logf ("write wires => '%s'", fname);
    }

    /* try to write the wires to a file. */
    if (!wires_write (wires, fname)) {
      /* failure. print a warning message and move along. */
      logf ("failed to write wires to '%s'", fname);
    }
  }
  else if (cmd_parse (line, CMD_CLEAR, 0)) {
    /* print a log message. */
    if (verb) logf ("clearing wire list");

    /* free and re-initialize the wire list. */
    wires_free (wires);
    wires = wires_alloc ();

    /* ensure the wire list was re-initialized successfully. */
    if (!wires) {
      /* print an error message and exit. */
      logf ("failed to clear wire list");
      return 0;
    }

    /* reset the parsing state variables. */
    a = b = vector (0.0, 0.0, 0.0);
    i = 0.0;
  }
  else if (cmd_parse (line, CMD_END, 0)) {
    /* break the parsing loop to end execution. */
    if (verb) logf ("exiting...");
    return -1;
  }
  else if (cmd_parse (line, CMD_VERBOSE, 0)) {
    /* enable verbose logging. */
    logf ("verbose logging => on");
    verb = 1;
  }
  else if (cmd_parse (line, CMD_QUIET, 0)) {
    /* print a message. */
    if (verb) logf ("verbose logging => off");

    /* disable verbose logging. */
    verb = 0;
  }
  else {
    /* print a warning message. */
    logf ("unrecognized command '%s'", line);
  }

  /* return success. */
  return 1;
}

