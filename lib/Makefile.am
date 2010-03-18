## Process this file with automake to produce Makefile.in.

include gnulib.mk

AM_CFLAGS += $(WARNING_CFLAGS) $(WERROR_CFLAGS)

# Allow "make distdir" to succeed before "make all" has run.
dist-hook: $(noinst_LIBRARIES)
.PHONY: dist-hook
