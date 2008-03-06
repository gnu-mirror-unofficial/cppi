## Process this file with automake to produce Makefile.in.

SUBDIRS = lib po src tests man

ACLOCAL_AMFLAGS = -I m4

EXTRA_DIST = Makefile.cfg Makefile.maint GNUmakefile \
  .prev-version

gen_start_date = 2008-01-03
.PHONY: gen-ChangeLog
gen-ChangeLog:
	if test -d .git; then						\
	  $(top_srcdir)/build-aux/gitlog-to-changelog			\
	    --since=$(gen_start_date) > $(distdir)/cl-t;		\
	  rm -f $(distdir)/ChangeLog;					\
	  mv $(distdir)/cl-t $(distdir)/ChangeLog;			\
	fi

distcheck-hook:
	$(MAKE) my-distcheck
