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

dnl Allow maintainer rules under GNU make even in VPATH builds.  This does
dnl not work in autoconf 2.61 or earlier, but we don't want to require
dnl non-maintainers to use unreleased autoconf, hence the version test.
dnl TODO remove the version check once autoconf 2.62 is released.
dnl Meanwhile, we must use a shell variable so that we bypass automake's
dnl attempts to remove the sole copy of GNUmakefile in a non-VPATH build
dnl during 'make distclean'.
dnl TODO avoid the shell variable once automake is fixed.
GNUmakefile=GNUmakefile
m4_if(m4_version_compare([2.61a.100],
	m4_defn([m4_PACKAGE_VERSION])), [1], [],
      [AC_CONFIG_LINKS([$GNUmakefile:$GNUmakefile], [],
	[GNUmakefile=$GNUmakefile])])

AC_CONFIG_FILES(
  Makefile
  lib/Makefile
  po/Makefile
  src/Makefile
  tests/Makefile
  man/Makefile)

AC_OUTPUT
