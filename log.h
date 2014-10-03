
/* log.h: logging functions for gpufield.
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

/* ensure once-only inclusion. */
#ifndef __LOG_H__
#define __LOG_H__

/* define a convenience function for verbose logging. */
#define logf(...) logf_fn (__FILE__, __LINE__, __VA_ARGS__)

/* predeclare the core verbose logging function. */
void logf_fn (const char *f, const unsigned int l, const char *format, ...)
  __attribute__ ((format (printf, 3, 4)));

#endif /* __LOG_H__ */

