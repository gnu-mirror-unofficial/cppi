## Process this file with automake to produce Makefile.in -*-Makefile-*-
AUTOMAKE_OPTIONS = gnits 1.4

bin_PROGRAMS = cppi

cppi_SOURCES = cppi.l

noinst_LIBRARIES = libcppi.a
libcppi_a_SOURCES = \
  closeout.c closeout.h \
  fatal.c getopt.c getopt1.c obstack.c xstrtol.c \
  xstrtoul.c

libcppi_a_LIBADD = @LIBOBJS@
libcppi_a_DEPENDENCIES = $(libcppi_a_LIBADD)
LDADD = libcppi.a

noinst_HEADERS = fatal.h getopt.h obstack.h xstrtol.h

EXTRA_DIST = cpp.gp cpp-indent.pl cppi.l cpp-cond.c \
  GNUmakefile Makefile.cfg Makefile.maint .prev-version

SUBDIRS = . m4 tests po

MAINTAINERCLEANFILES = cpp-cond.c
CLEANFILES = cpp.h lex.backup

PERL = @PERL@
GPERF = gperf

ACLOCAL_AMFLAGS = -I m4

cpp-cond.c: cpp.gp
	rm -f $@ $@-tmp
	$(GPERF) -a -C -N cpp_cond_lookup -n -p -t -s 6 -k '*' $< \
	  > $@-tmp
	chmod a-w $@-tmp
	mv $@-tmp $@

# flex_debug = #-d
flex_debug = # -L # suppress #line directives

# This is required to avoid an infloop on certain 8-bit inputs.
# Without this option, the generated scanner would infloop on e.g.,
#   perl -e 'print "\300"' |./cppi
flex_8_bit = -8

flex_optimize = -Cfr -p -b
AM_LFLAGS = $(flex_debug) $(flex_optimize) $(flex_8_bit)

# Don't use automake's default .l.c rule.
# I prefer to make generated .c files unwritable.
cppi.c: cppi.l
	rm -f $@
	$(LEXCOMPILE) $(srcdir)/cppi.l
	chmod a-w $(LEX_OUTPUT_ROOT).c
	mv $(LEX_OUTPUT_ROOT).c $@

cpp.h: cpp.gp Makefile.am
	@rm -f $@-tmp $@
	@(								\
	 echo '/* This file is generated automatically from cpp.gp.  */'; \
	 echo;								\
	 echo 'enum Eic_type';						\
	 echo '{';							\
	 sed -n '/.*, /{s///;s/.*/  &,/;p;};' $(srcdir)/cpp.gp;		\
	 echo '  EIC_OTHER';						\
	 echo '};';							\
	 echo;								\
	 echo 'static char const *const directive[] =';			\
	 echo '{';							\
	 sed -n '/,.*/{s///;s/.*/  "&",/;p;};' $(srcdir)/cpp.gp;	\
	 echo '  ""';							\
	 echo '};';							\
	)								\
	  > $@-tmp
	@chmod -w $@-tmp
	@mv $@-tmp $@

BUILT_SOURCES = cpp-cond.c cpp.h
Makefile: $(BUILT_SOURCES)

distcheck-hook:
	$(MAKE) my-distcheck
