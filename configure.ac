# Process this file with autoconf to produce a configure script.
AC_INIT([GNU cppi],[1.12],[bug-cppi@gnu.org])
AC_CONFIG_SRCDIR(src/cppi.l)

AC_CONFIG_AUX_DIR(config)
AM_CONFIG_HEADER(config.h:config.hin)

AM_INIT_AUTOMAKE([1.6b gnits dist-bzip2])

AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AM_PROG_LEX
AC_PROG_RANLIB

AC_GNU_SOURCE
gl_USE_SYSTEM_EXTENSIONS

gl_CLOSEOUT

gl_ERROR

gl_EXITFAIL

gl_FATAL

jm_FUNC_FPENDING

AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION(0.11.5)

jm_FUNC_MALLOC
jm_CHECK_DECLS

gl_OBSTACK

gl_QUOTEARG

gl_GETOPT

jm_FUNC_REALLOC

jm_FUNC_GLIBC_UNLOCKED_IO

gl_XALLOC

gl_XSTRTOL

gl_FUNC_ALLOCA

AM_STDBOOL_H


AC_OUTPUT([Makefile lib/Makefile m4/Makefile po/Makefile
	   src/Makefile tests/Makefile])
