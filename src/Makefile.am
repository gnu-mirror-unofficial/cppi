## Process this file with automake to produce Makefile.in -*-Makefile-*-

bin_PROGRAMS = cppi
cppi_SOURCES = \
  cppi.l \
  system.h \
  sys2.h

EXTRA_DIST = cpp.gp cpp-indent.pl cppi.l cpp-cond.c
MAINTAINERCLEANFILES = cpp-cond.c
CLEANFILES = cpp.h lex.backup

GPERF = gperf

AM_CPPFLAGS = -I.. -I$(srcdir) -I$(top_srcdir)/lib -I../lib

LDADD = ../lib/libgnulib.a $(LIBINTL) ../lib/libgnulib.a

cpp-cond.c: cpp.gp
	rm -f $@ $@-tmp
	$(GPERF) -a -C -N cpp_cond_lookup -n -p -t -s 6 -k '*' $< \
	  > $@-tmp
	chmod a-w $@-tmp
	mv $@-tmp $@

localedir = $(datadir)/locale
BUILT_SOURCES = localedir.h
DISTCLEANFILES = localedir.h
localedir.h: Makefile
	@rm -f $@-t
	echo '#define LOCALEDIR "$(localedir)"' >$@-t
	@chmod a-w $@-t
	cmp $@-t $@ > /dev/null 2>&1 && rm -f $@-t || { rm -f $@; mv $@-t $@; }

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

BUILT_SOURCES += cpp-cond.c cpp.h
