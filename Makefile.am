## Process this file with automake to produce Makefile.in.

AUTOMAKE_OPTIONS = 1.5 foreign

SUBDIRS = lib m4 po src tests

ACLOCAL_AMFLAGS = -I m4

EXTRA_DIST = Makefile.cfg Makefile.maint GNUmakefile \
  .prev-version announce-gen

distcheck-hook:
	$(MAKE) my-distcheck
