"  string containing otherwise-valid cpp-directive \
#if
"
#if
# error
#else
# include "foo"
#endif

int c = " /* \\";
#if
# error
#else
# include "foo"
#endif
