## Process this file with automake to produce Makefile.in.

AUTOMAKE_OPTIONS = 1.7 gnits

noinst_LIBRARIES = libgnulib.a

libgnulib_a_SOURCES =
libgnulib_a_LIBADD = $(LIBOBJS)
EXTRA_DIST =
BUILT_SOURCES =
SUFFIXES =
MOSTLYCLEANFILES =
CLEANFILES =
DISTCLEANFILES =
MAINTAINERCLEANFILES =

libgnulib_a_SOURCES += closeout.h closeout.c

libgnulib_a_SOURCES += exitfail.h exitfail.c

libgnulib_a_SOURCES += __fpending.h

libgnulib_a_SOURCES += gettext.h

libgnulib_a_SOURCES += quotearg.h quotearg.c

libgnulib_a_SOURCES += unlocked-io.h

libgnulib_a_SOURCES += xalloc.h xmalloc.c xstrdup.c

libgnulib_a_SOURCES += xstrtol.h xstrtol.c xstrtoul.c

libgnulib_a_SOURCES += version-etc.h version-etc.c

libgnulib_a_SOURCES += pathmax.h

libgnulib_a_SOURCES += getopt.h getopt.c getopt1.c

EXTRA_DIST += stdbool_.h

EXTRA_DIST += stdbool_.h
BUILT_SOURCES += $(STDBOOL_H)
MOSTLYCLEANFILES += stdbool.h stdbool.ht
# Create stdbool.h on systems that lack a working one.
stdbool.h: stdbool_.h
	sed -e 's/@''HAVE__BOOL''@/$(HAVE__BOOL)/g' $(srcdir)/stdbool_.h > $@t
	mv $@t $@

EXTRA_DIST += alloca_.h
BUILT_SOURCES += $(ALLOCA_H)
MOSTLYCLEANFILES += alloca.h alloca.h-t
# We need the following in order to create an <alloca.h> when the system
# doesn't have one that works with the given compiler.
alloca.h: alloca_.h
	cp $(srcdir)/alloca_.h $@-t
	mv $@-t $@
