%{ /* -*- C -*- */

/* When output is inhibited, exit with status:
   0 if all's ok
   1 if indentation is wrong
   2 if #if/#endif mismatch
   3 if file error
   */

#ifndef FLEX_SCANNER
# error This scanner must be made using flex, not lex.
#endif

#ifndef __GNUC__
# error This scanner must be compiled with gcc.
#endif

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <errno.h>
#ifndef errno
extern int errno;
#endif

#include "fatal.h"

#ifndef EXIT_FAILURE
# define EXIT_FAILURE 1
#endif

#ifndef EXIT_SUCCESS
# define EXIT_SUCCESS 0
#endif

#ifdef MY_DEBUG
# define PUT2(x,y) do { putchar (x); putchar (y); } while (0)
#else
# define PUT2(x,y) /* empty */
#endif

#define STREQ(A,B) (strcmp ((A), (B)) == 0)

#undef YY_DECL
#define YY_DECL static int cpp_i (const char *in_file)

#define INPUT_AND_ECHO()			\
 ({						\
   int _c_ = input ();				\
   if (_c_ != EOF && !inhibit_output)		\
     fputc (_c_, yyout);			\
   _c_;						\
 })

#ifndef isblank
# define isblank(c) ((c) == ' ' || (c) == '\t')
#endif

/* This is the maximum ifdef nesting level.  */
/* FIXME: remove this limitation, someday.  */
#define MAX_DEPTH 40

#define MY_ECHO do { if (!inhibit_output) ECHO; } while (0)

enum Eic_type
{
  EIC_IF,
  EIC_IFDEF,
  EIC_IFNDEF,
  EIC_ELSE,
  EIC_ELIF,
  EIC_ENDIF,
  EIC_PRAGMA,
  EIC_DEFINE,
  EIC_OTHER
};

static char const *const directive[] =
{
  [EIC_IF]	"if",
  [EIC_IFDEF]	"ifdef",
  [EIC_IFNDEF]	"ifndef",
  [EIC_ELSE]	"else",
  [EIC_ELIF]	"elif",
  [EIC_ENDIF]	"endif",
  [EIC_PRAGMA]	"pragma",
  [EIC_DEFINE]	"define",
  [EIC_OTHER]	""
};

struct Stack
{
  int vec[MAX_DEPTH];
  int top;
};

/* The maximum exit status.  */
static int g_fail = 0;

/* Current nesting level.  */
static int i_depth;

/* Set to non-zero to inhibit non-error output.  */
static int inhibit_output = 0;

static char *default_file_list[] = {"-", NULL};

char *program_name;

#include "cpp-cond-lookup.c"

/* PREFIX is the cpp line from beginning of line to end of the keyword
   following the `#'.  */

enum Eic_type
lookup_cpp_keyword (const char *prefix, size_t len, const char **kw)
{
  /* Find the beginning of the keyword.  */
  const char *p;
  for (p = prefix; ; ++p, --len)
    {
      switch (*p)
	{
	case '#':
	case ' ':
	case '\t':
	  break;

	default:
	  {
	    struct KW const *ent = cpp_cond_lookup (p, len);
	    *kw = p;
	    return (ent ? ent->code : EIC_OTHER);
	  }
	}
      assert (len > 0);
    }
}

int
yywrap (void)
{
  return 1;
}

static int
kl_pack (enum Eic_type t, unsigned int line_number)
{
  assert (t == EIC_IF
	  || t == EIC_IFDEF
	  || t == EIC_IFNDEF);
  assert (0 <= (int) t && (int) t <= 2);
  return ((line_number << 2) | (unsigned int) t);
}

static void
kl_unpack (int kl_pair, enum Eic_type *t, unsigned int *line_number)
{
  *t = (enum Eic_type) (kl_pair & 0x3);
  *line_number = ((unsigned int) kl_pair >> 2);
}

static int
pop (struct Stack *s)
{
  assert (s->top > 0);
  return s->vec[--(s->top)];
}

static void
push (struct Stack *s, int packed_pair)
{
  assert (s->top < MAX_DEPTH);
  s->vec[s->top++] = packed_pair;
}

static int
emit_or_check (enum Eic_type type, const char *text, const char *other)
{
  int fail = 1;

  if (inhibit_output)
    {
      int n;
      if ((text[0] == '#'
	   && (n = strspn (text + 1, " ")) == i_depth
	   && !isblank (text[1 + n]))
	  /* This allows pragmas to have at least one space before the `#'.
	     E.g., ` #pragma alloca'.  */
	  || (text[0] == ' '
	      && type == EIC_PRAGMA
	      && (n = strspn (text + 1, " ")) == i_depth - 1
	      && text[n + 1] == '#'
	      && text[n + 2] == 'p'))
	{
	  fail = 0;
	}
    }
  else
    {
      int i;
      const char *dir = (type == EIC_OTHER ? other : directive[type]);
      int spaces_first = (type == EIC_PRAGMA && text[0] == ' ');

      if (!spaces_first)
	fputc ('#', yyout);
      for (i = 0; i < i_depth; i++)
	fputc (' ', yyout);
      if (spaces_first)
	fputc ('#', yyout);
      fputs (dir, yyout);

      fail = 0;
    }

  return fail;
}

static enum Eic_type
emit_indented_cpp (char const *in_file, unsigned int line_number,
		   char const *text, size_t len,
		   struct Stack *s, int *exit_status)
{
  int fail;
  const char *keyword;
  enum Eic_type t = lookup_cpp_keyword (text, len, &keyword);

  switch (t)
    {
    case EIC_IF:
    case EIC_IFDEF:
    case EIC_IFNDEF:
      /* Maintain a stack of (keyword, line number) pairs to better
	 report any `unterminated #if...' errors.  Put a new pair
	 on the stack.  */
      push (s, kl_pack (t, line_number));

      fail = emit_or_check (t, yytext, keyword);
      ++i_depth;
      break;

    case EIC_ELSE:
    case EIC_ELIF:
      if (i_depth <= 0)
	{
	  warn (0, "%s: %s: line %d: found #%s without matching #if",
	    program_name, in_file, line_number, directive[t]);
	  i_depth = 0;
	  fail = emit_or_check (t, yytext, keyword);
	  *exit_status = 2;
	}
      else
	{
	  --i_depth;
	  fail = emit_or_check (t, yytext, keyword);
	  ++i_depth;
	}
      break;

    case EIC_ENDIF:
      if (i_depth <= 0)
	{
	  warn (0, "%s: %s: line %d: found #%s without matching #if",
	    program_name, in_file, line_number, directive[t]);
	  i_depth = 1;
	  *exit_status = 2;
	}
      else
	{
	  /* We've just found an #endif.  Pop off and discard the
	     keyword,line-number pair that's on the top of the stack.
	     That pair identifies the matching #if, #ifdef, or #ifndef.  */
	  pop (s);
	}

      --i_depth;
      fail = emit_or_check (t, yytext, keyword);
      break;

    case EIC_PRAGMA:
    case EIC_DEFINE:
    case EIC_OTHER:
      fail = emit_or_check (t, yytext, keyword);
      break;

    default:
      abort ();
    }

  if (fail)
    {
      if (*exit_status == 0)
	*exit_status = 1;
      warn (0, "%s: %s: line %d: not properly indented",
	    program_name, in_file, line_number);
    }

  return t;
}

%}

w [a-zA-Z_]
b [^a-zA-Z_\n]

%%

%{

  /* Stack of (opening-keyword, line number) pairs.  This lets us report
     the line numbers of any unmatched #if, #ifdef, or #ifndef directives.  */
  struct Stack kl_stack;

  /* Current line number -- for diagnostics and errors.  */
  unsigned int lineno = 1;

  kl_stack.top = 0;
  i_depth = 0;

%}

"/*"        {
  register int c;
  int start_lineno = lineno;

  PUT2 ('[', '\0');
  MY_ECHO;
  for ( ; ; )
    {
      while ((c = INPUT_AND_ECHO ()) != '*' && c != EOF)
	{
	  if (c == '\n')
	    ++lineno;
	}

      if (c == '*')
	{
	  while ((c = INPUT_AND_ECHO ()) == '*')
	    ;
	  if (c == '/')
	    break;    /* found the end */
	  if (c == '\n')
	    ++lineno;
	}

      if (c == EOF)
	{
	  fatal (2, 0, "%s: %s: line %d: EOF in comment",
		 program_name, in_file, start_lineno);
	  break;
	}
    }
  PUT2 ('\0', ']');
}

"'"\\?"\"'" {
  /* We need this rule so that the double quote in the character literal,
     '"' (also written as '\"'), is not interpreted as a string opener.  */
  MY_ECHO;
}

"'\\"/"\"" {
  /* This rule is included to make flex's scanner more efficient
     by avoiding backup states.  */
  MY_ECHO;
}
"'\\"    { /* Likewise.  */ MY_ECHO;}
"'"/"\"" { /* Likewise.  */ MY_ECHO; }

"\"" {
  register int c;
  int start_lineno = lineno;

  /* Count consecutive backslashes.  We'll need this number when
     a string of them immediately precedes a double quote.  */
  int n_backslashes = 0;

  PUT2 ('[', '\0');
  MY_ECHO;

  while (1)
    {
      c = INPUT_AND_ECHO ();

      if (c == EOF)
	{
	  fatal (2, 0, "%s: %s: line %d: EOF in string",
		 program_name, in_file, start_lineno);
	}

      /* If the number of preceding backslashes is even, then this is
	 an unescaped double quote, and it marks the end of the string.  */
      if (c == '"' && n_backslashes % 2 == 0)
	break;

      n_backslashes = (c == '\\' ? n_backslashes + 1 : 0);
      if (c == '\n')
	++lineno;
    }
  PUT2 ('\0', ']');
}

^[ \t]*#[ \t]*[a-zA-Z0-9_]+   {
  enum Eic_type t;
  t = emit_indented_cpp (in_file, lineno, yytext, yyleng, &kl_stack, &g_fail);

  if (t == EIC_IF || t == EIC_ELIF || t == EIC_DEFINE)
    {
      int c;
      if (inhibit_output)
	{
	  /* Make sure there's exactly one space after this #if or #elif
	     directive.  */
	  c = input ();
	  if (c != ' ' || ((c = input ()) == ' ' || c == '\t' || c == EOF))
	    {
	      warn (0, "%s: %s: line %d: not properly formatted\n"
		    "There must be exactly one SPACE character after each\n"
		    "#if, #elif, and #define directive.",
		    program_name, in_file, lineno);
	      if (g_fail < 1)
		g_fail = 1;
	    }
	}
      else
	{
	  /* Squeeze multiple spaces and tabs after an #if or #elif
	     directive to a single space.  */
	  fputc (' ', yyout);
	  while ((c = input ()) == ' ' || c == '\t')
	    {
	      /* empty */
	    }
	}
      unput (c);
    }
}
^[ \t]*#[ \t]*            { MY_ECHO; }
^[ \t]*                   { MY_ECHO; }

\n                        { MY_ECHO; ++lineno; }
.                         { MY_ECHO; }

<<EOF>> {
  if (i_depth != 0)
    {
      /* Iterate the opener stack from bottom to top, giving a
	 diagnostic per unterminated #if* directive.  */
      int i;
      for (i = 0; i < kl_stack.top; i++)
	{
	  enum Eic_type t;
	  unsigned int line_number;

	  kl_unpack (kl_stack.vec[i], &t, &line_number);
	  warn (0, "%s: %s: line %d: unterminated #%s",
		program_name, in_file, line_number, directive[t]);
	}

      g_fail = 2;
    }

  return g_fail;
}

%%

static int
cpp_indent (const char *in_file)
{
  FILE *in = NULL;
  int fail;

  if (STREQ (in_file, "-"))
    {
      yyin = stdin;
      in_file = "standard input";
    }
  else
    {
      if ((in = fopen (in_file, "r")) == NULL)
	fatal (3, errno, "%s: %s", program_name, in_file);
      yyin = in;
    }

  fail = cpp_i (in_file);

  if (in && fclose (in) == EOF)
    fatal (3, errno, "%s: %s", program_name, in_file);

  return fail;
}

static void
usage (int status)
{
  if (status != 0)
    {
      fprintf (stderr, "Try `%s --help' for more information.\n",
	       program_name);
    }
  else
    {
      printf ("\
Usage: %s [FILE]\n\
  or:  %s [-c] [FILE]...\n\
Indent the C preprocessor directives in FILE to reflect their\n\
nesting, and write the result to standard output.  With no FILE,\n\
or when FILE is -, read standard input.\n\
\n\
With the -c option, don't write to stdout.  Instead, check the\n\
indentation of the specified files giving diagnostics for preprocessor\n\
lines that aren't properly indented or are otherwise invalid.\n\
\n\
The exit code will be one of these:\n\
  0 all directives properly indented\n\
  1 some cpp directive(s) improperly indented\n\
  2 #if/#endif mismatch\n\
  3 file (e.g. read/write) error\n\
Set the `DISABLE_CPP_INDENT_CHECK' environment variable to disable\n\
all checks.  It is useful only with -c.\n\
",
	      program_name, program_name);
    }
  exit (status == 0 ? EXIT_SUCCESS : EXIT_FAILURE);
}

int
main (int argc, char** argv)
{
  int i;
  int fail;
  char **file_list;

  /* Make `cppi -C' usable directly via CVS's commitinfo (see below).  */
  int cvs_mode = 0;

  program_name = argv[0];

  if (argc >= 2 && (STREQ (argv[1], "-h") || STREQ (argv[1], "-help")))
    {
      usage (0);
    }

  if (argc >= 2 && STREQ (argv[1], "-c"))
    {
      inhibit_output = 1;
      ++argv;
      --argc;
    }
  else if (argc >= 2 && STREQ (argv[1], "-C"))
    {
      inhibit_output = 1;
      cvs_mode = 1;
      ++argv;
      --argc;
    }

  if (!inhibit_output && argc > 2)
    {
      warn (0, "too many arguments");
      usage (1);
    }

  /* This is the back door.  Set this environment variable to disable
     all checks.  It is useful only with -c.  */
  if (inhibit_output && getenv ("DISABLE_CPP_INDENT_CHECK"))
    exit (0);

  file_list = (argc == 1 ? default_file_list : argv + 1);

  /* Make `cppi -C' usable directly via CVS's commitinfo.
     Ignore the first command line argument if it is a directory and
     there is at least one other argument.  Also, process only files
     ending in .c and .h.  */

  if (argc >= 3 && cvs_mode)
    {
      struct stat stats;
      if (stat (file_list[0], &stats) == 0 && S_ISDIR (stats.st_mode))
	++file_list;
    }

  fail = 0;
  for (i = 0; file_list[i]; i++)
    {
      int err;
      char *p;

      /* Skip files that don't match *.[ch].  */
      if (cvs_mode && ! ((p = strrchr (file_list[i], '.')) != NULL
			 && (p[1] == 'c' || p[1] == 'h')
			 && p[2] == '\0'))
	continue;

      err = cpp_indent (file_list[i]);
      if (err > fail)
	fail = err;
    }

  if (fclose (stdout) == EOF)
    {
      fatal (3, errno, "%s: write error", program_name);
    }

  exit (fail);
}
