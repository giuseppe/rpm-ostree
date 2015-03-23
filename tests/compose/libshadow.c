/* -*- mode: C; c-file-style: "gnu"; indent-tabs-mode: nil; -*-
 *
 * Copyright (C) 2015 Red Hat Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 2 of the licence or (at
 * your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#define _GNU_SOURCE

#include <stdio.h>
#include <dlfcn.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>

int unshare (int flags);
int mount (const char *source, const char *target,
           const char *filesystemtype, unsigned long mountflags,
           const void *data);
pid_t fork ();

int
unshare (int flags)
{
  return 0;
}

int
mount (const char *source, const char *target,
       const char *filesystemtype, unsigned long mountflags,
       const void *data)
{
  errno = EINVAL;
  return -1;
}

pid_t
fork ()
{
  pid_t ret;
  static int n_forks = 0;
  static int (*next_fork)() = NULL;
  if (next_fork == NULL)
    {
      char *msg;
      next_fork = dlsym (RTLD_NEXT, "fork");
      msg = dlerror ();
      if (msg != NULL)
        {
          fprintf (stderr, "dlopen error : %s\n", msg);
          exit (EXIT_FAILURE);
        }
    }
  /* Hack to permit the first fork to go through and block
     all the succesive ones.  */
  n_forks++;
  ret = next_fork ();
  if (ret)
    return ret;

  if (n_forks > 1)
    _exit (0);

  return 0;
}
