## Process this file with automake to produce Makefile.in -*-Makefile-*-
bin_PROGRAMS = cppi

cppi_SOURCES = cppi.l fatal.c getopt.c getopt1.c obstack.c

noinst_HEADERS = fatal.h getopt.h obstack.h

EXTRA_DIST = cpp.gp cpp-indent.pl cppi.l cpp-cond-lookup.c

SUBDIRS = tests

MAINTAINERCLEANFILES = cpp-cond-lookup.c

cpp-cond-lookup.c: cpp.gp
	gperf -a -C -E -N cpp_cond_lookup -n -p -t -s 6 -k '*' $< \
	  | sed 's/str\[/(unsigned char) str[/' > $@-tmp
	mv $@-tmp $@

flex_debug = #-d
flex_optimize = -Cfr -p -b
LFLAGS = $(flex_debug) $(flex_optimize)

BUILT_SOURCES = cpp-cond-lookup.c
