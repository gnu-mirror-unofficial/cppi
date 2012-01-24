## Process this file with automake to produce Makefile.in.

AUTOMAKE_OPTIONS = subdir-objects
SUBDIRS = po .

ACLOCAL_AMFLAGS = -I m4

EXTRA_DIST = cfg.mk maint.mk .prev-version .version dist-check.mk

# Arrange so that .tarball-version appears only in the distribution
# tarball, and never in a checked-out repository.
dist-hook: gen-ChangeLog do-not-require-help2man
	echo $(VERSION) > $(distdir)/.tarball-version

# By default (i.e., with initial timestamps), do not run help2man when
# building from a distribution tarball.  Normally, cppi.1 must depend
# on src/cppi, but when building from a distribution tarball, we don't
# want that, to avoid depending on help2man then.  Here is the offending
# dependency:
#   man/cppi.1: $(common_dep) $(srcdir)/man/cppi.x src/cppi
# The trick is simply to s,src/cppi,src/cppi.c/ in the $(distdir)
# we're about to tar and compress.
.PHONY: do-not-require-help2man
do-not-require-help2man:
	perl -pi -e 's,^(man/cppi\.1:.*src/cppi)$$,$$1.c,' \
          $(distdir)/Makefile.in

gen_start_date = 2008-01-03
.PHONY: gen-ChangeLog
gen-ChangeLog:
	if test -d .git; then						\
	  $(top_srcdir)/build-aux/gitlog-to-changelog			\
	    --since=$(gen_start_date) > $(distdir)/cl-t;		\
	  rm -f $(distdir)/ChangeLog;					\
	  mv $(distdir)/cl-t $(distdir)/ChangeLog;			\
	fi

BUILT_SOURCES = .version
.version:
	echo $(VERSION) > $@-t && mv $@-t $@

distcheck-hook:
	$(MAKE) my-distcheck

###############################################
# Initialization before completion by local.mk's.
AM_CFLAGS = $(WARNING_CFLAGS) $(WERROR_CFLAGS)
AM_CPPFLAGS =
CLEANFILES =
DISTCLEANFILES =
MAINTAINERCLEANFILES =
MOSTLYCLEANFILES =
noinst_LIBRARIES =
SUFFIXES =

include lib/local.mk
include src/local.mk
include man/local.mk
include tests/local.mk
