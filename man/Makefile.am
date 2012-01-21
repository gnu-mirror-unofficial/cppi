## Process this file with automake to produce Makefile.in -*-Makefile-*-
dist_man_MANS = cppi.1

man_aux = $(dist_man_MANS:.1=.x)
EXTRA_DIST = $(man_aux)
MAINTAINERCLEANFILES = $(man_MANS)

# Depend on .version to get version number changes.
common_dep = $(top_srcdir)/.version

cppi.1:	$(common_dep)	$(srcdir)/cppi.x	../src/cppi.c

SUFFIXES = .x .1

.x.1:
	$(AM_V_GEN)echo "Updating man page $@";			\
	PATH=../src$(PATH_SEPARATOR)$$PATH; export PATH;	\
	$(HELP2MAN)						\
	    --include=$(srcdir)/$*.x				\
	    --output=$@ $*$(EXEEXT)

check-local: check-x-vs-1 check-programs-vs-x

# Sort in traditional ASCII order, regardless of the current locale;
# otherwise we may get into trouble with distinct strings that the
# current locale considers to be equal.
ASSORT = LC_ALL=C sort

# Ensure that for each .x file in this directory, there is a
# corresponding .1 file in the definition of $(dist_man_MANS) above.
.PHONY: check-x-vs-1
check-x-vs-1:
	$(AM_V_GEN)PATH=../src$(PATH_SEPARATOR)$$PATH; export PATH;	\
	t=ls-files.$$$$;						\
	(cd $(srcdir) && ls -1 *.x) | sed 's/\.x$$//' | $(ASSORT) > $$t;\
	echo $(dist_man_MANS) | fmt -w1 | sed 's/\.1$$//' | $(ASSORT)	\
	  | diff - $$t || { rm $$t; exit 1; };				\
	rm $$t

programs =								\
  echo 'spy:;@echo $$(all_programs)'					\
    | MAKEFLAGS= $(MAKE) -s -C .. -f Makefile -f - spy			\
    | fmt -1 | $(ASSORT) -u

.PHONY: check-programs-vs-x
check-programs-vs-x:
	$(AM_V_GEN)for p in `$(programs)`; do		\
	  test -f $(srcdir)/$$p.x			\
	    || { echo missing $$p.x 1>&2; missing=1; };	\
	done;						\
	test "$$missing" = 1 && exit 1 || :
