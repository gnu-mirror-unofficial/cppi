"  string containing otherwise-valid cpp-directive \
#if
"
#if
#error
#else
#include "foo"
#endif

int c = " /* \\";
#if
#error
#else
#include "foo"
#endif

fprintf(out, "#line 1 \"%s\"\n", argv[1]);

#if
#error
#else
#include "foo"
#endif
