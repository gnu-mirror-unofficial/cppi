## Process this file with automake to produce Makefile.in.

AUTOMAKE_OPTIONS = 1.5 gnits no-dependencies

noinst_LIBRARIES = libgnulib.a

gnulib_SOURCES =
gnulib_LIBADD = $(LIBOBJS)
#gnulib_LIBADD = $(LTLIBOBJS)
EXTRA_DIST =
BUILT_SOURCES =
SUFFIXES =
MOSTLYCLEANFILES =
CLEANFILES =
DISTCLEANFILES =
MAINTAINERCLEANFILES =
gnulib_SOURCES += closeout.h closeout.c

gnulib_SOURCES += exitfail.h exitfail.c

gnulib_SOURCES += __fpending.h

gnulib_SOURCES += gettext.h

gnulib_SOURCES += quotearg.h quotearg.c

gnulib_SOURCES += unlocked-io.h

gnulib_SOURCES += xalloc.h xmalloc.c xstrdup.c

gnulib_SOURCES += xstrtol.h xstrtol.c xstrtoul.c

gnulib_SOURCES += version-etc.h version-etc.c

gnulib_SOURCES += pathmax.h

EXTRA_DIST += stdbool_.h

BUILT_SOURCES += $(STDBOOL_H)
EXTRA_DIST += stdbool_.h
MOSTLYCLEANFILES += stdbool.h stdbool.ht
# Create stdbool.h on systems that lack a working one.
stdbool.h: stdbool_.h
	sed -e 's/@''HAVE__BOOL''@/$(HAVE__BOOL)/g' $(srcdir)/stdbool_.h > $@t
	mv $@t $@

EXTRA_DIST += alloca_.h

BUILT_SOURCES += $(ALLOCA_H)
EXTRA_DIST += alloca_.h
MOSTLYCLEANFILES += alloca.h alloca.h-t
# We need the following in order to create an <alloca.h> when the system
# doesn't have one that works with the given compiler.
alloca.h: alloca_.h
	cp $(srcdir)/alloca_.h $@-t
	mv $@-t $@
