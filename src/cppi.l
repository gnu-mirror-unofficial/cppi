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

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <getopt.h>

#include <errno.h>
#ifndef errno
extern int errno;
#endif

#include "fatal.h"
#include "obstack.h"

#define obstack_chunk_alloc malloc
#define obstack_chunk_free free

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

/* NOTE: this use of stmt-expression is another gcc-ism.  */
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
  /* FIXME: Note: This syntax uses a GCC extension.  */
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

#define OPENER_STACK_HEIGHT \
  (obstack_object_size (&opener_stack) / sizeof (struct KL_pair))

/* An entry on the stack of opener (keyword/line_number) specs.  */
struct KL_pair
{
  /* The type of cpp directive opening a block: one of
     EIC_IF, EIC_IFDEF, EIC_IFNDEF.  */
  enum Eic_type opener_type;

  /* The line number of the directive.  */
  unsigned int line_number;
};

/* A stack of cpp-opener-directive-spec/line-number pairs.
   This lets us report the line numbers of any unmatched #if,
   #ifdef, or #ifndef directives.  */
static struct obstack opener_stack;

/* Current nesting level.  */
static int i_depth;

/* Initial indentation nesting depth.  May be negative.
   Use a value of -1 to cause code (usually header files) to be indented
   one level less than otherwise.  This is useful if you don't want file-
   enclosing ifdefs (e.g., #ifdef FOO_H/#define FOO_H/ ... #endif) to
   cause every enclosed cpp directive to have at least one space between
   the `#' and the cpp keyword.  */
static int initial_i_depth;

/* Nonzero means don't generate diagnostics about indentation, and print
   to stdout only the names of files that aren't properly indented.  */
static int list_files_only;

/* Set to non-zero to inhibit non-error output.  */
static int inhibit_output = 0;

static char *default_file_list[] = {"-", NULL};

char *program_name;

/* If nonzero, display usage information and exit.  */
static int show_help;

/* If nonzero, print the version on standard output then exit.  */
static int show_version;

static struct option const long_options[] =
{
  {"cvs", no_argument, NULL, 'C'},
  {"check", no_argument, NULL, 'c'},
  {"list-files-only", no_argument, NULL, 'l'},
  {"help", no_argument, &show_help, 1},
  {"version", no_argument, &show_version, 1},
  {NULL, 0, NULL, 0}
};

static void gobble_define (void);

/* Include gperf-generated hash function.  */
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

static __inline struct KL_pair
kth_entry (int k)
{
  struct KL_pair *s = (struct KL_pair *) obstack_base (&opener_stack);
  assert (0 <= k && k < OPENER_STACK_HEIGHT);
  return s[k];
}

static __inline void
pop (void)
{
  assert (OPENER_STACK_HEIGHT > 0);
  obstack_blank (&opener_stack, -(sizeof (struct KL_pair)));
}

static __inline void
push (struct KL_pair pair)
{
  obstack_grow (&opener_stack, &pair, sizeof (struct KL_pair));
}

static int
emit_or_check (enum Eic_type type, const char *text, const char *other)
{
  int fail = 1;

  if (inhibit_output)
    {
      int n;
      int depth = (i_depth < 0 ? 0 : i_depth);
      if ((text[0] == '#'
	   && (n = strspn (text + 1, " ")) == depth
	   && !isblank (text[1 + n]))
	  /* This allows pragmas to have exactly one space before the `#'.
	     E.g., ` #pragma alloca' or ` #  pragma alloca' .  */
	  || (text[0] == ' '
	      && text[1] == '#'
	      && type == EIC_PRAGMA
	      && (n = strspn (text + 2, " ")) == depth - 1
	      && text[n + 2] == 'p'))
	{
	  fail = 0;
	}
    }
  else
    {
      int i;
      const char *dir = (type == EIC_OTHER ? other : directive[type]);
      int space_first = (type == EIC_PRAGMA && text[0] == ' ');

      if (space_first)
	{
	  fputc (' ', yyout);
	  fputc ('#', yyout);
	  for (i = 0; i < i_depth - 1; i++)
	    fputc (' ', yyout);
	}
      else
	{
	  fputc ('#', yyout);
	  for (i = 0; i < i_depth; i++)
	    fputc (' ', yyout);
	}

      fputs (dir, yyout);

      fail = 0;
    }

  return fail;
}

static enum Eic_type
emit_indented_cpp (char const *in_file, unsigned int line_number,
		   char const *text, size_t len, int *fail)
{
  const char *keyword;
  enum Eic_type t = lookup_cpp_keyword (text, len, &keyword);

  *fail = 0;

  switch (t)
    {
    case EIC_IF:
    case EIC_IFDEF:
    case EIC_IFNDEF:
      /* Maintain a stack of (keyword, line number) pairs to better
	 report any `unterminated #if...' errors.  Put a new pair
	 on the stack.  */
      /* FIXME: Note: this initialization syntax uses a GCC extension.  */
      push ((struct KL_pair) {t, line_number});

      *fail = emit_or_check (t, yytext, keyword);
      ++i_depth;
      break;

    case EIC_ELSE:
    case EIC_ELIF:
      if (i_depth <= initial_i_depth)
	{
	  if (!list_files_only)
	    {
	      warn (0, "%s: %s: line %d: found #%s without matching #if",
		    program_name, in_file, line_number, directive[t]);
	    }
	  i_depth = 0;
	  *fail = emit_or_check (t, yytext, keyword);
	  *fail = 2;
	}
      else
	{
	  --i_depth;
	  *fail = emit_or_check (t, yytext, keyword);
	  ++i_depth;
	}
      break;

    case EIC_ENDIF:
      if (i_depth <= initial_i_depth)
	{
	  if (!list_files_only)
	    {
	      warn (0, "%s: %s: line %d: found #%s without matching #if",
		    program_name, in_file, line_number, directive[t]);
	    }
	  i_depth = initial_i_depth + 1;
	  *fail = 2;
	}
      else
	{
	  /* We've just found an #endif.  Pop off and discard the
	     keyword,line-number pair that's on the top of the stack.
	     That pair identifies the matching #if, #ifdef, or #ifndef.  */
	  pop ();
	}

      --i_depth;
      {
	int tf = emit_or_check (t, yytext, keyword);
	if (tf > *fail)
	  *fail = tf;
      }
      break;

    case EIC_PRAGMA:
    case EIC_DEFINE:
    case EIC_OTHER:
      *fail = emit_or_check (t, yytext, keyword);
      break;

    default:
      abort ();
    }

  if (*fail == 1)
    {
      if (!list_files_only)
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
  /* This section contains dcls and code that is local to the
     scanning routine.  */

  /* Current line number -- for diagnostics and errors.  */
  unsigned int lineno = 1;

  int lex_fail = 0;

  obstack_init (&opener_stack);

  initial_i_depth = 0;
  i_depth = initial_i_depth;

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
  int fail;

  t = emit_indented_cpp (in_file, lineno, yytext, yyleng, &fail);

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
	      if (!list_files_only)
		{
		  warn (0, "%s: %s: line %d: not properly formatted\n"
			"There must be exactly one SPACE character after each\n"
			"#if, #elif, and #define directive.",
			program_name, in_file, lineno);
		}
	      if (fail < 1)
		fail = 1;
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
      if (t == EIC_DEFINE)
	{
	  gobble_define ();
	}
    }

  if (fail > lex_fail)
    lex_fail = fail;
}
^[ \t]*#[ \t]*            { MY_ECHO; }
^[ \t]*                   { MY_ECHO; }

\n                        { MY_ECHO; ++lineno; }
.                         { MY_ECHO; }

<<EOF>> {
  if (i_depth != initial_i_depth)
    {
      if (!list_files_only)
	{
	  /* Iterate the opener stack from bottom to top, giving a
	     diagnostic per unterminated #if* directive.
	     Torture this code with a command like this:
	     $ yes '#if FOO' |head -600 |cppi -c */
	  int i;
	  for (i = 0; i < OPENER_STACK_HEIGHT; i++)
	    {
	      struct KL_pair x = kth_entry (i);
	      warn (0, "%s: %s: line %d: unterminated #%s",
		    program_name, in_file, x.line_number,
		    directive[x.opener_type]);
	    }
	}

      lex_fail = 2;
    }

  return lex_fail;
}

%%

static int
cpp_indent (const char *in_file, int cvs_mode)
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
	{
	  if (cvs_mode && errno == ENOENT)
	    {
	      /* In CVS mode, it's ok if IN_FILE doesn't exist.  That
		 happens when you commit a file after cvs-deleting it.  */
	      return 0;
	    }

	  fatal (3, errno, "%s: %s", program_name, in_file);
	}
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
  or:  %s -c [OPTION] [FILE]...\n\
\n\
Indent the C preprocessor directives in FILE to reflect their nesting\n\
and ensure that there is exactly one space character between each #if,\n\
#elif, #define directive and the following token, and write the result\n\
to standard output.  With no FILE, or when FILE is -, read standard input.\n\
\n\
  -c, --check            set exit code, but don't produce any output\n\
  -l, --list-files-only  don't generate diagnostics about indentation;\n\
			   print to stdout only the names of files that\n\
			   are not properly indented\n\
      --help             print this help, then exit\n\
      --version          print tar program version number, then exit\n\
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
\n\
Set the `DISABLE_CPP_INDENT_CHECK' environment variable to disable\n\
all checks.  It is useful only with -c.\n\
\n\
Pragma directives may have their `#' indented.\n\
",
	      program_name, program_name);
    }
  exit (status == 0 ? EXIT_SUCCESS : EXIT_FAILURE);
}

/* Read the body of a #define directive (echoing or not, as appropriate).
   That is, read up to and including the first unescaped newline (or EOF).
   This is necessary because otherwise, we could mistakenly interpret the
   stringification of a macro argument as a cpp directive.  */

static void
gobble_define (void)
{
  int c;
  int backslash_count = 0;
  while ((c = INPUT_AND_ECHO ()) != EOF)
    {
      if (c == '\n' && backslash_count % 2 == 0)
	break;

      if (c == '\\')
	++backslash_count;
      else
	backslash_count = 0;
    }
}

int
main (int argc, char** argv)
{
  int i;
  int max_err;
  char **file_list;
  int c;

  /* Make `cppi -C' usable directly via CVS's commitinfo (see below).  */
  int cvs_mode = 0;

  program_name = argv[0];

  while ((c = getopt_long (argc, argv, "cCl", long_options, NULL)) != -1)
    {
      switch (c)
	{
	case 0:
	  break;

	case 'c':
	  inhibit_output = 1;
	  break;

	case 'C':
	  inhibit_output = 1;
	  cvs_mode = 1;
	  break;

	case 'l':
	  inhibit_output = 1;
	  list_files_only = 1;
	  break;

	default:
	  usage (2);
	  break;
	}
    }

  if (show_version)
    {
      printf ("cppi %s\n", VERSION);
      exit (EXIT_SUCCESS);
    }

  if (show_help)
    usage (0);

  if (!inhibit_output && argc > 2)
    {
      warn (0, "too many arguments");
      usage (1);
    }

  /* This is the back door.  Set this environment variable to disable
     all checks.  It is useful only with -c or -C.  */
  if (inhibit_output && getenv ("DISABLE_CPP_INDENT_CHECK"))
    exit (0);

  file_list = (optind == argc ? default_file_list : argv + optind);

  /* Make `cppi -C' usable directly via CVS's commitinfo.
     Ignore the first command line argument if it is a directory and
     there is at least one other argument.  Also, process only files
     ending in .c and .h.
     FIXME: this whole -C option is a gross kludge -- remove it */

  if (argc >= 3 && cvs_mode)
    {
      struct stat stats;
      if (stat (file_list[0], &stats) == 0 && S_ISDIR (stats.st_mode))
	++file_list;
    }

  max_err = 0;
  for (i = 0; file_list[i]; i++)
    {
      int err;
      char *p;

      /* Skip files that don't match *.[ch].  */
      if (cvs_mode && ! ((p = strrchr (file_list[i], '.')) != NULL
			 && (p[1] == 'c' || p[1] == 'h')
			 && p[2] == '\0'))
	continue;

      err = cpp_indent (file_list[i], cvs_mode);
      if (err > max_err)
	max_err = err;

      if (err && list_files_only)
	puts (file_list[i]);
    }

  if (fclose (stdout) == EOF)
    {
      fatal (3, errno, "%s: write error", program_name);
    }

  exit (max_err);
}
