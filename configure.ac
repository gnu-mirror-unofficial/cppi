# Process this file with autoconf to produce a configure script.
AC_PREREQ(2.60)
AC_INIT([GNU cppi], m4_esyscmd([build-aux/git-version-gen .tarball-version]),
	[bug-cppi@gnu.org])
AC_CONFIG_SRCDIR(src/cppi.l)

AC_CONFIG_AUX_DIR(build-aux)
AM_CONFIG_HEADER([lib/config.h:config.hin])

AM_INIT_AUTOMAKE([1.10.1 dist-lzma])

AM_MISSING_PROG(HELP2MAN, help2man)
AC_PROG_CC
gl_EARLY
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AM_PROG_LEX
AC_PROG_RANLIB

gl_INIT

AC_C_INLINE
AC_HEADER_DIRENT

AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.15])

AC_CONFIG_FILES(
  Makefile
  lib/Makefile
  po/Makefile
  src/Makefile
  tests/Makefile
  man/Makefile)

AC_OUTPUT
