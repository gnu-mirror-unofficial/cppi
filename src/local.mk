bin_PROGRAMS = src/cppi
src_cppi_SOURCES = \
  src/cppi.l \
  src/system.h

# Tell the linker to omit references to unused shared libraries.
AM_LDFLAGS = $(IGNORE_UNUSED_LIBRARIES_CFLAGS)

EXTRA_DIST +=		\
  src/cpp.gp		\
  src/cpp-indent.pl	\
  src/cppi.l		\
  src/cpp-cond.c

MAINTAINERCLEANFILES += src/cpp-cond.c
DISTCLEANFILES += src/cpp.h src/lex.backup

GPERF = gperf

AM_CPPFLAGS += -I$(top_srcdir)/lib -Isrc -I$(top_srcdir)/src

LDADD = $(top_builddir)/lib/libcppi.a $(LIBINTL) $(top_builddir)/lib/libcppi.a

GPERF_OPTIONS = \
  -C -N cpp_cond_lookup -n -t -s 6 -k '*' --language=ANSI-C

src/cpp-cond.c: src/cpp.gp
	$(AM_V_GEN)rm -f $@ $@-tmp
	$(AM_V_at)$(GPERF) $(GPERF_OPTIONS) $< \
	  | perl -ne '/__GNUC_STDC_INLINE__/ and print "static\n"; print' \
	  > $@-tmp
	$(AM_V_at)chmod a-w $@-tmp
	$(AM_V_at)mv $@-tmp $@

localedir = $(datadir)/locale
BUILT_SOURCES += src/localedir.h
DISTCLEANFILES += src/localedir.h
src/localedir.h: src/local.mk
	$(AM_V_GEN)rm -f $@-t
	$(AM_V_at)mkdir -p src
	$(AM_V_at)echo '#define LOCALEDIR "$(localedir)"' >$@-t
	$(AM_V_at)chmod a-w $@-t
	$(AM_V_at)cmp $@-t $@ > /dev/null 2>&1 && rm -f $@-t \
	  || { rm -f $@; mv $@-t $@; }

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
src/cppi.c: src/cppi.l
	$(AM_V_GEN)rm -f $@
	$(AM_V_at)mkdir -p src
	$(AM_V_at)$(LEXCOMPILE) $(top_srcdir)/src/cppi.l
	$(AM_V_at)chmod a-w $(LEX_OUTPUT_ROOT).c
	$(AM_V_at)mv $(LEX_OUTPUT_ROOT).c $@

src/cpp.h: src/cpp.gp src/local.mk
	$(AM_V_GEN)rm -f $@-tmp $@
	$(AM_V_at)mkdir -p src
	$(AM_V_at)(							\
	 echo '/* This file is generated automatically from cpp.gp.  */'; \
	 echo;								\
	 echo 'enum Eic_type';						\
	 echo '{';							\
	 sed -n '/.*, /{s///;s/.*/  &,/;p;};' $(srcdir)/src/cpp.gp;	\
	 echo '  EIC_OTHER';						\
	 echo '};';							\
	 echo;								\
	 echo 'static char const *const directive[] =';			\
	 echo '{';							\
	 sed -n '/,.*/{s///;s/.*/  "&",/;p;};' $(srcdir)/src/cpp.gp;	\
	 echo '  ""';							\
	 echo '};';							\
	)								\
	  > $@-tmp
	$(AM_V_at)chmod -w $@-tmp
	$(AM_V_at)mv $@-tmp $@

# This is required because we have broken inter-directory dependencies:
# in order to generate all man pages, require that cppi be built at
# distribution time.
dist-hook: src/cppi
.PHONY: dist-hook

BUILT_SOURCES += src/cpp-cond.c src/cpp.h
