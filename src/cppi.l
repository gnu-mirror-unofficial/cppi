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

/* Suppress generation of unused yyunput function.  */
#define YY_NO_UNPUT

#undef YY_DECL
#define YY_DECL static int cpp_i (const char *in_file)

#define INPUT_AND_ECHO()			\
 ({						\
   int _c_ = input ();				\
   if (_c_ != EOF && !inhibit_output)		\
     fputc (_c_, yyout);			\
   _c_;						\
 })

#define EMIT(T)								\
  do									\
    {									\
      if (inhibit_output)						\
	{								\
	  int n;							\
	  if (text[0] == '#'						\
	      && (n = strspn (text + 1, " ")) == i_depth		\
	      && ((T == EIC_OTHER && text[1 + n] == '\0') ||		\
		  text[1 + n] == 'e' || text[1 + n] == 'i'))		\
	    {								\
	      ok = 1;							\
	    }								\
	}								\
      else								\
	{								\
	  ok = 1;							\
	  fputc ('#', out);						\
	  assert (0 <= i_depth && i_depth <= MAX_DEPTH);		\
	  blanks[i_depth] = '\0';					\
	  fputs (blanks, out);						\
	  blanks[i_depth] = ' ';					\
	  fputs (directive[T], out);					\
	}								\
    }									\
  while (0)

/* This is the maximum ifdef nesting level.  */
/* FIXME: remove this limitation, someday.  */
#define MAX_DEPTH 40

#define MY_ECHO do { if (!inhibit_output) ECHO; } while (0)

#define EMIT_DIR(Tok) emit_indented_cpp (yyout, (Tok), yytext, in_file)

enum eic_type
{
  EIC_IF,
  EIC_IFDEF,
  EIC_IFNDEF,
  EIC_ELSE,
  EIC_ELIF,
  EIC_ENDIF,
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
  [EIC_OTHER]	""
};

struct Stack
{
  int vec[MAX_DEPTH];
  int top;
};

/* Stack of (opening-keyword, line number) pairs.  This lets us report
   the line numbers of any unmatched #if, #ifdef, or #ifndef directives.  */
static struct Stack kl_stack;

/* Current line number -- for diagnostics and errors.  */
static unsigned int lineno = 1;

/* Current nesting level.  */
static int i_depth = 0;

/* Set to non-zero to inhibit non-error output.  */
static int inhibit_output = 0;

/* The maximum exit status.  */
static int g_fail = 0;

static char *default_file_list[] = {"-", NULL};

char *program_name;

int
yywrap (void)
{
  return 1;
}

static int
kl_pack (enum eic_type t, unsigned int line_number)
{
  assert (t == EIC_IF
	  || t == EIC_IFDEF
	  || t == EIC_IFNDEF);
  assert (0 <= (int) t && (int) t <= 2);
  return ((line_number << 2) | (unsigned int) t);
}

static void
kl_unpack (int kl_pair, enum eic_type *t, unsigned int *line_number)
{
  *t = (enum eic_type) (kl_pair & 0x3);
  *line_number = ((unsigned int) kl_pair >> 2);
}

static int
pop (void)
{
  assert (kl_stack.top > 0);
  return kl_stack.vec[--kl_stack.top];
}

static void
push (int packed_pair)
{
  assert (kl_stack.top < MAX_DEPTH);
  kl_stack.vec[kl_stack.top++] = packed_pair;
}

static void
emit_indented_cpp (FILE *out, enum eic_type t, char const *text,
		   char const *in_file)
{
  static char blanks[] = { [0 ... MAX_DEPTH] = ' ' };
  int ok = 0;

  switch (t)
    {
    case EIC_IF:
    case EIC_IFDEF:
    case EIC_IFNDEF:
      /* Maintain a stack of (keyword, line number) pairs to better
	 report any `unterminated #if...' errors.  Put a new pair
	 on the stack.  */
      push (kl_pack (t, lineno));

      EMIT (t);
      ++i_depth;
      break;

    case EIC_ELSE:
    case EIC_ELIF:
      if (i_depth <= 0)
	{
	  warn (0, "%s: %s: line %d: found #%s without matching #if",
	    program_name, in_file, lineno, directive[t]);
	  i_depth = 0;
	  g_fail = 2;
	  EMIT (t);
	}
      else
	{
	  --i_depth;
	  EMIT (t);
	  ++i_depth;
	}
      break;

    case EIC_ENDIF:
      if (i_depth <= 0)
	{
	  warn (0, "%s: %s: line %d: found #%s without matching #if",
	    program_name, in_file, lineno, directive[t]);
	  i_depth = 1;
	  g_fail = 2;
	}
      else
	{
	  /* Pop the keyword,line-number stack and discard the result.  */
	  pop ();
	}

      --i_depth;
      EMIT (t);
      break;

    case EIC_OTHER:
      EMIT (t);
      break;

    default:
      abort ();
    }

  if (!ok)
    {
      if (g_fail == 0)
	g_fail = 1;
      warn (0, "%s: %s: line %d: not properly indented",
	    program_name, in_file, lineno);
    }
}

%}

w [a-zA-Z_]
b [^a-zA-Z_\n]

%%

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

"'\\\"'" |
"'\"'" {
  /* We need this rule so that the double quote in the character literal,
     '"', is not interpreted as the string opener.  */
  MY_ECHO;
}

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

^[ \t]*#[ \t]*if/{b}      { EMIT_DIR (EIC_IF); }
^[ \t]*#[ \t]*ifdef/{b}   { EMIT_DIR (EIC_IFDEF); }
^[ \t]*#[ \t]*ifndef/{b}  { EMIT_DIR (EIC_IFNDEF); }

^[ \t]*#[ \t]*elif/{b}    { EMIT_DIR (EIC_ELIF); }
^[ \t]*#[ \t]*else{w}     { MY_ECHO; }
^[ \t]*#[ \t]*else/{b}    { EMIT_DIR (EIC_ELSE); }
^[ \t]*#[ \t]*else$       { EMIT_DIR (EIC_ELSE); }

^[ \t]*#[ \t]*endif{w}    { MY_ECHO; }
^[ \t]*#[ \t]*endif/{b}   { EMIT_DIR (EIC_ENDIF); }
^[ \t]*#[ \t]*endif$      { EMIT_DIR (EIC_ENDIF); }
^[ \t]*#[ \t]*endif       { EMIT_DIR (EIC_ENDIF); }

^[ \t]*#[ \t]*            { EMIT_DIR (EIC_OTHER); }

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
	  enum eic_type t;
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

  if (!inhibit_output && argc > 2)
    {
      warn (0, "too many arguments");
      usage (1);
    }

  file_list = (argc == 1 ? default_file_list : argv + 1);

  fail = 0;
  for (i = 0; file_list[i]; i++)
    {
      int err = cpp_indent (file_list[i]);
      if (err > fail)
	fail = err;
    }

  if (fclose (stdout) == EOF)
    {
      fatal (3, errno, "%s: write error", program_name);
    }

  exit (fail);
}
