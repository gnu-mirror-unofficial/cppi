"  string containing otherwise-valid cpp-directive \
#if
"
#if 1
#error
#else
#include "foo"
#endif

int c = '"';
char *s = " /* \\";
#if 1
#error
#else
#include "foo"
#endif

fprintf(out, "#line 1 \"%s\"\n", argv[1]);

#if 1
#error
#else
#include "foo"
#endif

char *s = "\"";

#if 1
#        error
#else
#include "foo"
#endif
