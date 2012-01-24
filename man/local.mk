## Process this file with automake to produce Makefile.in -*-Makefile-*-
dist_man1_MANS = man/cppi.1

man_aux = $(dist_man1_MANS:.1=.x)
EXTRA_DIST += $(man_aux)
MAINTAINERCLEANFILES += $(dist_man1_MANS)

# Depend on .version to get version number changes.
common_dep = $(top_srcdir)/.version

man/cppi.1: $(common_dep) $(srcdir)/man/cppi.x src/cppi

SUFFIXES += .x .1

# FIXME: when we depend on GNU make, remove $$prog; use $(*F) in its place
# Also, use a %.1: man/%.x pattern rule and remove the mkdir (required for
# non-srcdir builds).
.x.1:
	$(AM_V_GEN)mkdir -p man;				\
	PATH=src$(PATH_SEPARATOR)$$PATH; export PATH;		\
	prog=`basename $*`;					\
	$(HELP2MAN)						\
	    --include=$(srcdir)/$*.x				\
	    --output=$@ $$prog$(EXEEXT)

check-local: check-x-vs-1 check-programs-vs-x

# Sort in traditional ASCII order, regardless of the current locale;
# otherwise we may get into trouble with distinct strings that the
# current locale considers to be equal.
ASSORT = LC_ALL=C sort

# Ensure that for each .x file in this directory, there is a
# corresponding .1 file in the definition of $(dist_man1_MANS) above.
.PHONY: check-x-vs-1
check-x-vs-1:
	$(AM_V_GEN)t=ls-files.$$$$;					\
	(cd $(srcdir)/man && ls -1 *.x) | sed 's/\.x$$//' | $(ASSORT) > $$t;\
	echo $(dist_man1_MANS) | tr -s ' ' '\015' | sed 's,man/,,;s/\.1$$//' \
          | $(ASSORT) -u | diff - $$t || { rm $$t; exit 1; };		\
	rm $$t

programs =								\
  echo 'spy:;@echo $$(PROGRAMS)'					\
    | MAKEFLAGS= $(MAKE) -s -f Makefile -f - spy			\
    | tr -s ' ' '\015' | sed 's,.*/,,' | $(ASSORT) -u

.PHONY: check-programs-vs-x
check-programs-vs-x:
	$(AM_V_GEN)for p in `$(programs)`; do		\
	  test -f $(srcdir)/man/$$p.x			\
	    || { echo missing $$p.x 1>&2; missing=1; };	\
	done;						\
	test "$$missing" = 1 && exit 1 || :

# This is a kludge to remove man/cppi.1 from a non-srcdir build.
distclean-local:
	test 'x$(srcdir)' = 'x$(builddir)' && : || rm -f $(dist_man1_MANS)
