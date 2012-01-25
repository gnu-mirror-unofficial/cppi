
TESTS = \
  tests/help-version	\
  tests/version-check	\
  tests/d1	\
  tests/d2	\
  tests/d3	\
  tests/d4	\
  tests/d5	\
  tests/e1	\
  tests/e2	\
  tests/e3	\
  tests/e4	\
  tests/e5	\
  tests/e6	\
  tests/e7	\
  tests/e8	\
  tests/e9	\
  tests/f1	\
  tests/f2	\
  tests/f3	\
  tests/f4	\
  tests/f5	\
  tests/f7	\
  tests/f8	\
  tests/f9	\
  tests/stringify-1	\
  tests/stringify-2	\
  tests/stringify-3	\
  tests/stringify-4	\
  tests/8-bit	\
  tests/ansi-1	\
  tests/ansi-2	\
  tests/ansi-3	\
  tests/ansi-4	\
  tests/ansi-5	\
  tests/ansi-6	\
  tests/ansi-7	\
  tests/ansi-8	\
  tests/cxx-1	\
  tests/cxx-2	\
  tests/cxx-3

$(TEST_LOGS): $(bin_PROGRAMS)

EXTRA_DIST += tests/test-common tests/init.sh $(TESTS)
TESTS_ENVIRONMENT =				\
  export					\
  srcdir=$(srcdir)				\
  top_srcdir=$(top_srcdir)			\
  EXEEXT=$(EXEEXT)				\
  built_programs="`basename $(bin_PROGRAMS)`"	\
  VERSION='$(VERSION)'				\
  PACKAGE_BUGREPORT='$(PACKAGE_BUGREPORT)'	\
  PATH=src$(PATH_SEPARATOR)$$PATH		\
  ; 9>&2
