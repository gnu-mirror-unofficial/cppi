## Process this file with automake to produce Makefile.in.

SUBDIRS = lib po src tests man

ACLOCAL_AMFLAGS = -I m4

EXTRA_DIST = cfg.mk maint.mk .prev-version .version dist-check.mk

# Arrange so that .tarball-version appears only in the distribution
# tarball, and never in a checked-out repository.
dist-hook: gen-ChangeLog
	echo $(VERSION) > $(distdir)/.tarball-version

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
