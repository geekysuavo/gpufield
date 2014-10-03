
/* log.cu: logging functions for gpufield.
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

/* include the log header. */
#include "log.h"

/* define a convenience function for verbose logging. */
#define logf(...) logf_fn (__FILE__, __LINE__, __VA_ARGS__)

/* predeclare the core verbose logging function. */
void logf_fn (const char *f, const unsigned int l, const char *format, ...)
  __attribute__ ((format (printf, 3, 4)));

/* logf_fn: verbose logging core function.
 * @f: filename string.
 * @l: line number.
 * @format: printf-style format string.
 * @...: variable-length argument list.
 */
void logf_fn (const char *f, const unsigned int l, const char *format, ...) {
  /* declare the variable-length argument list. */
  va_list vl;

  /* print the first portion of the log string. */
  fprintf (stderr, "%s[%u]: ", f, l);

  /* print the user-controlled portion of the log string. */
  va_start (vl, format);
  vfprintf (stderr, format, vl);
  va_end (vl);

  /* tack on a newline. */
  fprintf (stderr, "\n");
  fflush (stderr);
}

