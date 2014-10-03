
/* gpufield.cu: GPU-accelerated magnetostatics calculations via Biot Savart.
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
  /* declare required variables. */
  char buf[256], prompt[32], *pbuf;
  unsigned int kcmd;
  FILE *fh;
  int ret;

  /* see if the user passed a script filename on the command-line. */
  if (argc == 2) {
    /* open the input file. */
    fh = fopen (argv[1], "rb");
    if (!fh) {
      /* error out. */
      logf ("failed to open file '%s'", argv[1]);
      return 1;
    }

    /* loop while lines are available. */
    while (fgets (buf, sizeof (buf), fh)) {
      /* interpret the line. */
      ret = cmd_interpret (buf);

      /* see if execution was successful. */
      if (ret <= 0) {
        fclose (fh);
        return 1;
      }
    }

    /* close the input file. */
    fclose (fh);
  }
  else if (isatty (fileno (stdin))) {
    /* initialize the command counter. */
    kcmd = 1;

    /* loop until the session ends. */
    while (1) {
      /* build the prompt string. */
      snprintf (prompt, 32, "gpufield:%u> ", kcmd);
      pbuf = readline (prompt);

      /* end the session if no more input is available. */
      if (!pbuf)
        break;

      /* add the statement to the command history. */
      add_history (pbuf);

      /* interpret the line. */
      ret = cmd_interpret (pbuf);

      /* see if execution was successful. */
      if (ret < 0)
        break;

      /* increment the command counter for real commands. */
      if (strcmp (pbuf, ""))
        kcmd++;
    }
  }
  else {
    /* standard-input script mode. loop while lines are available. */
    while (fgets (buf, sizeof (buf), stdin)) {
      /* interpret the line. */
      ret = cmd_interpret (buf);

      /* see if execution was successful. */
      if (ret == 0)
        return 1;
      else if (ret < 0)
        break;
    }
  }

  /* return successfully. */
  return 0;
}

