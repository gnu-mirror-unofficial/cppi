## Process this file with automake to produce Makefile.in -*-Makefile-*-
AUTOMAKE_OPTIONS = gnits 1.4

bin_PROGRAMS = cppi

cppi_SOURCES = cppi.l fatal.c getopt.c getopt1.c obstack.c

noinst_HEADERS = fatal.h getopt.h obstack.h

EXTRA_DIST = cpp.gp cpp-indent.pl cppi.l cpp-cond.c \
  GNUmakefile Makefile.maint

SUBDIRS = tests

MAINTAINERCLEANFILES = cpp-cond.c
CLEANFILES = cpp.h lex.backup

PERL = @PERL@
GPERF = gperf

cpp-cond.c: cpp.gp
	rm -f $@ $@-tmp $@-t2
	$(GPERF) -a -C -N cpp_cond_lookup -n -p -t -s 6 -k '*' $< \
	  > $@-tmp
	sed 's/str\[/(unsigned char) str[/' $@-tmp > $@-t2
	rm -f $@-tmp
	chmod a-w $@-t2
	mv $@-t2 $@

flex_debug = #-d
flex_debug = # -L # suppress #line directives

# This is required to avoid an infloop on certain 8-bit inputs.
# Without this option, the generated scanner would infloop on e.g.,
#   perl -e 'print "\300"' |./cppi
flex_8_bit = -8

flex_optimize = -Cfr -p -b
LFLAGS = $(flex_debug) $(flex_optimize) $(flex_8_bit)

# Don't use automake's default .l.c rule.
# I prefer to make generated .c files unwritable.
cppi.c: cppi.l
	rm -f $@
	$(LEX) $(LFLAGS) $(srcdir)/cppi.l
	chmod a-w $(LEX_OUTPUT_ROOT).c
	mv $(LEX_OUTPUT_ROOT).c $@

cpp.h: cpp.gp Makefile.am
	@rm -f $@-tmp $@
	@(								\
	 echo '/* This file is generated automatically from $<.  */';	\
	 echo;								\
	 echo 'enum Eic_type';						\
	 echo '{';							\
	 sed -n '/.*, /{s///;s/.*/  &,/;p;};' $<;			\
	 echo '  EIC_OTHER';						\
	 echo '};';							\
	 echo;								\
	 echo 'static char const *const directive[] =';			\
	 echo '{';							\
	 sed -n '/,.*/{s///;s/.*/  "&",/;p;};' $<;			\
	 echo '  ""';							\
	 echo '};';							\
	)								\
	  > $@-tmp
	@chmod -w $@-tmp
	@mv $@-tmp $@

BUILT_SOURCES = cpp-cond.c cpp.h

distcheck-hook:
	$(MAKE) my-distcheck
