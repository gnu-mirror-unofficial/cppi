## Process this file with automake to produce Makefile.in -*-Makefile-*-
bin_PROGRAMS = cppi

cppi_SOURCES = cppi.l fatal.c getopt.c getopt1.c obstack.c

noinst_HEADERS = fatal.h getopt.h obstack.h

EXTRA_DIST = cpp.gp cpp-indent.pl cppi.l cpp-cond-lookup.c \
  GNUmakefile Makefile.maint

SUBDIRS = tests

MAINTAINERCLEANFILES = cpp-cond-lookup.c

cpp-cond-lookup.c: cpp.gp
	rm -f $@ $@-tmp
	gperf -a -C -N cpp_cond_lookup -n -p -t -s 6 -k '*' $< \
	  | sed 's/str\[/(unsigned char) str[/' > $@-tmp
	chmod a-w $@-tmp
	mv $@-tmp $@

flex_debug = #-d

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

BUILT_SOURCES = cpp-cond-lookup.c
