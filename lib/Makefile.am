## Process this file with automake to produce Makefile.in.

AUTOMAKE_OPTIONS = 1.5 gnits no-dependencies

noinst_LIBRARIES = libgnulib.a

libgnulib_a_SOURCES =
libgnulib_a_LIBADD = $(LIBOBJS)
#libgnulib_la_LIBADD = $(LTLIBOBJS)
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
all-local $(lib_OBJECTS): $(ALLOCA_H)
alloca.h: alloca_.h
	cp $(srcdir)/alloca_.h $@-t
	mv $@-t $@
