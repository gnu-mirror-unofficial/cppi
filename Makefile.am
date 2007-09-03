## Process this file with automake to produce Makefile.in.

SUBDIRS = lib po src tests man

ACLOCAL_AMFLAGS = -I m4

EXTRA_DIST = Makefile.cfg Makefile.maint GNUmakefile \
  .prev-version

distcheck-hook:
	$(MAKE) my-distcheck
