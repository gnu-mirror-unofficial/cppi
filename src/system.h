/* system-dependent definitions; derived from those of coreutils
   Copyright (C) 1989, 1991-2008, 2010-2020 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* Include sys/types.h before this file.  */

#if 2 <= __GLIBC__ && 2 <= __GLIBC_MINOR__
# if ! defined _SYS_TYPES_H
you must include <sys/types.h> before including this file
# endif
#endif

#include <sys/stat.h>

#if HAVE_SYS_PARAM_H
# include <sys/param.h>
#endif

#include <unistd.h>
#include <limits.h>
#include <time.h>
#include <string.h>
#include <errno.h>
#include "configmake.h"

#include <stdbool.h>
#include <stdlib.h>

/* Exit statuses for programs like 'env' that exec other programs.
   EXIT_FAILURE might not be 1, so use EXIT_FAIL in such programs.  */
enum
{
  EXIT_FAIL = 1,
  EXIT_CANNOT_INVOKE = 126,
  EXIT_ENOENT = 127
};

#include "exitfail.h"

/* Redirection and wildcarding when done by the utility itself.
   Generally a noop, but used in particular for native VMS. */
#ifndef initialize_main
# define initialize_main(ac, av)
#endif

#include "stat-macros.h"
#include <inttypes.h>
#include <ctype.h>

#if ! (defined isblank || HAVE_DECL_ISBLANK)
# define isblank(c) ((c) == ' ' || (c) == '\t')
#endif

/* ISDIGIT differs from isdigit, as follows:
   - Its arg may be any int or unsigned int; it need not be an unsigned char
     or EOF.
   - It's typically faster.
   POSIX says that only '0' through '9' are digits.  Prefer ISDIGIT to
   isdigit unless it's important to use the locale's definition
   of `digit' even when the host does not conform to POSIX.  */
#define ISDIGIT(c) ((unsigned int) (c) - '0' <= 9)

/* Convert a possibly-signed character to an unsigned character.  This is
   a bit safer than casting to unsigned char, since it catches some type
   errors that the cast doesn't.  */
static inline unsigned char to_uchar (char ch) { return ch; }

#include <locale.h>

/* Take care of NLS matters.  */

#include "gettext.h"
#if ! ENABLE_NLS
# undef textdomain
# define textdomain(Domainname) /* empty */
# undef bindtextdomain
# define bindtextdomain(Domainname, Dirname) /* empty */
#endif

#define _(msgid) gettext (msgid)
#define N_(msgid) msgid

#define STREQ(a, b) (strcmp ((a), (b)) == 0)

#include "xalloc.h"
#include "verify.h"

#include "unlocked-io.h"

/* Factor out some of the common --help and --version processing code.  */

/* These enum values cannot possibly conflict with the option values
   ordinarily used by commands, including CHAR_MAX + 1, etc.  Avoid
   CHAR_MIN - 1, as it may equal -1, the getopt end-of-options value.  */
enum
{
  GETOPT_HELP_CHAR = (CHAR_MIN - 2),
  GETOPT_VERSION_CHAR = (CHAR_MIN - 3)
};

#define GETOPT_HELP_OPTION_DECL \
  "help", no_argument, NULL, GETOPT_HELP_CHAR
#define GETOPT_VERSION_OPTION_DECL \
  "version", no_argument, NULL, GETOPT_VERSION_CHAR

#define case_GETOPT_HELP_CHAR			\
  case GETOPT_HELP_CHAR:			\
    usage (EXIT_SUCCESS);			\
    break;

/* Program_name must be a literal string.
   Usually it is just PROGRAM_NAME.  */
#define USAGE_BUILTIN_WARNING \
  _("\n" \
"NOTE: your shell may have its own version of %s, which usually supersedes\n" \
"the version described here.  Please refer to your shell's documentation\n" \
"for details about the options it supports.\n")

#define HELP_OPTION_DESCRIPTION \
  _("      --help     display this help and exit\n")
#define VERSION_OPTION_DESCRIPTION \
  _("      --version  output version information and exit\n")

#include "closeout.h"
#include "version-etc.h"

#define case_GETOPT_VERSION_CHAR(Program_name, Authors)			\
  case GETOPT_VERSION_CHAR:						\
    version_etc (stdout, Program_name, PACKAGE_NAME, VERSION, Authors,	\
                 (char *) NULL);					\
    exit (EXIT_SUCCESS);						\
    break;

#ifndef MAX
# define MAX(a, b) ((a) > (b) ? (a) : (b))
#endif

#ifndef MIN
# define MIN(a,b) (((a) < (b)) ? (a) : (b))
#endif

#include "progname.h"
#include "intprops.h"

#ifndef SSIZE_MAX
# define SSIZE_MAX TYPE_MAXIMUM (ssize_t)
#endif

#ifndef OFF_T_MIN
# define OFF_T_MIN TYPE_MINIMUM (off_t)
#endif

#ifndef OFF_T_MAX
# define OFF_T_MAX TYPE_MAXIMUM (off_t)
#endif

#ifndef UID_T_MAX
# define UID_T_MAX TYPE_MAXIMUM (uid_t)
#endif

#ifndef GID_T_MAX
# define GID_T_MAX TYPE_MAXIMUM (gid_t)
#endif

#ifndef PID_T_MAX
# define PID_T_MAX TYPE_MAXIMUM (pid_t)
#endif

/* Use this to suppress gcc's `...may be used before initialized' warnings. */
#ifdef lint
# define IF_LINT(Code) Code
#else
# define IF_LINT(Code) /* empty */
#endif

#ifndef __attribute__
# if __GNUC__ < 2 || (__GNUC__ == 2 && __GNUC_MINOR__ < 8) || __STRICT_ANSI__
#  define __attribute__(x) /* empty */
# endif
#endif

#ifndef ATTRIBUTE_NORETURN
# define ATTRIBUTE_NORETURN __attribute__ ((__noreturn__))
#endif

#ifndef ATTRIBUTE_UNUSED
# define ATTRIBUTE_UNUSED __attribute__ ((__unused__))
#endif
