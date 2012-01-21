# Process this file with autoconf to produce a configure script.
AC_PREREQ(2.63.240)
AC_INIT([GNU cppi], m4_esyscmd([build-aux/git-version-gen .tarball-version]),
        [bug-cppi@gnu.org])
AC_CONFIG_SRCDIR(src/cppi.l)

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_HEADERS([lib/config.h:config.hin])

AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz color-tests parallel-tests])
AM_SILENT_RULES([yes]) # make --enable-silent-rules the default.

AM_MISSING_PROG([HELP2MAN], [help2man])
AM_PROG_CC_C_O
gl_EARLY
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AM_PROG_LEX
AC_PROG_RANLIB

gl_INIT

AC_ARG_ENABLE([gcc-warnings],
  [AS_HELP_STRING([--enable-gcc-warnings],
                  [turn on lots of GCC warnings (for developers)])],
  [case $enableval in
     yes|no) ;;
     *)      AC_MSG_ERROR([bad value $enableval for gcc-warnings option]) ;;
   esac
   gl_gcc_warnings=$enableval],
  [gl_gcc_warnings=no]
)

if test "$gl_gcc_warnings" = yes; then
  gl_WARN_ADD([-Werror], [WERROR_CFLAGS])
  AC_SUBST([WERROR_CFLAGS])

  # Add many warnings, except some...
  nw="$nw -Wdeclaration-after-statement" # too useful to forbid
  nw="$nw -Waggregate-return"       # anachronistic
  nw="$nw -Wlong-long"              # C90 is anachronistic
  nw="$nw -Wc++-compat"             # We don't care about C++ compilers
  nw="$nw -Wundef"                  # Warns on '#if GNULIB_FOO' etc in gnulib
  nw="$nw -Wtraditional"            # Warns on #elif which we use often
  nw="$nw -Wcast-qual"              # Too many warnings for now
  nw="$nw -Wconversion"             # Too many warnings for now
  nw="$nw -Wsystem-headers"         # Don't let system headers trigger warnings
  nw="$nw -Wsign-conversion"        # Too many warnings for now
  nw="$nw -Wtraditional-conversion" # Too many warnings for now
  nw="$nw -Wunreachable-code"       # Too many false positives
  nw="$nw -Wpadded"                 # Our structs are not padded
  nw="$nw -Wredundant-decls"        # warnings in flex-generated code (isatty)
  nw="$nw -Wlogical-op"             # any use of fwrite provokes this
  nw="$nw -Wvla"                    # warnings in gettext.h
  nw="$nw -Wswitch-default"         # Too many warnings for now
  nw="$nw -Wformat-y2k"             # Too many warnings for now
  nw="$nw -Wunused-macros"          # warnings in flex-generated code
  nw="$nw -Wstrict-prototypes"      # warnings in gperf-generated code
  nw="$nw -Wmissing-noreturn"       # warning in flex-generated code yy_fatal_error
  gl_MANYWARN_ALL_GCC([ws])
  gl_MANYWARN_COMPLEMENT([ws], [$ws], [$nw])
  for w in $ws; do
    gl_WARN_ADD([$w])
  done
  gl_WARN_ADD([-Wno-missing-field-initializers]) # We need this one
  gl_WARN_ADD([-Wno-sign-compare])     # Too many warnings for now
  gl_WARN_ADD([-Wno-pointer-sign])     # Too many warnings for now
  gl_WARN_ADD([-Wno-unused-parameter]) # Too many warnings for now
  gl_WARN_ADD([-fdiagnostics-show-option])

  AC_SUBST([WARN_CFLAGS])

  AC_DEFINE([lint], [1], [Define to 1 if the compiler is checking for lint.])
  AC_DEFINE([_FORTIFY_SOURCE], [2],
    [enable compile-time and run-time bounds-checking, and some warnings])
  AC_DEFINE([GNULIB_PORTCHECK], [1], [enable some gnulib portability checks])
fi

AC_C_INLINE
AC_HEADER_DIRENT
AC_HEADER_ASSERT

AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.17])

AC_CONFIG_FILES(
  Makefile
  po/Makefile.in)

AC_OUTPUT
