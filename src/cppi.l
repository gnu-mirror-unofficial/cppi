%{ /* -*- C -*- */

#ifndef FLEX_SCANNER
This scanner must be made using flex, not lex.
#endif

#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <ctype.h>

#include <errno.h>
#ifndef errno
extern int errno;
#endif

#undef YY_DECL
#define YY_DECL static int cpp_i (const char *in_file)

#define INPUT_AND_ECHO()			\
 ({						\
   int _c_ = input ();				\
   if (_c_ != EOF && !inhibit_output)		\
     fputc (_c_, yyout);			\
   _c_;						\
 })

#define MY_ECHO do { if (!inhibit_output) ECHO; } while (0)

enum eic_type
{
  EIC_IF,
  EIC_ELSE,
  EIC_ENDIF,
  EIC_OTHER
};

static int lineno = 1;
static int i_depth = 0;
static int inhibit_output = 0;

char *program_name;

int
yywrap (void)
{
  return 1;
}

#define EMIT					\
  do						\
    {						\
      if (!inhibit_output)			\
	{					\
	  fputc ('#', out);			\
	  assert (i_depth <= MAX_DEPTH);	\
	  blanks[i_depth] = '\0';		\
	  fputs (blanks, out);			\
	  blanks[i_depth] = ' ';		\
	  fputs (directive, out);		\
	}					\
    }						\
  while (0)

static void
emit_indented_cpp (enum eic_type t, char const *directive, FILE *out)
{
#define MAX_DEPTH 40
  static char blanks[] = { [0 ... MAX_DEPTH] = ' ' };

  switch (t)
    {
    case EIC_IF:
      EMIT;
      ++i_depth;
      break;

    case EIC_ELSE:
      --i_depth;
      EMIT;
      ++i_depth;
      break;

    case EIC_ENDIF:
      --i_depth;
      EMIT;
      break;

    case EIC_OTHER:
      EMIT;
      break;

    default:
      abort ();
    }
}

%}

%%

"/*"        {
  register int c;

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
	}

      if (c == EOF)
	{
	  fatal (0, "%s: %s: ERROR: EOF in comment", program_name, in_file);
	  break;
	}
    }
}

/* We need this so that the double quote in the character literal, '"',
   is not interpreted as the string opener.  */
"'\"'" {
  MY_ECHO;
}

"\"" {
  register int c;

  /* Count consecutive backslashes.  We'll need this number when
     a string of them immediately precedes a double quote.  */
  int n_backslashes = 0;

  MY_ECHO;

  while (1)
    {
      c = INPUT_AND_ECHO ();

      if (c == EOF)
	fatal (0, "%s: %s: ERROR: EOF in string", program_name, in_file);

      /* If the number of preceding backslashes is even, then this is
	 an unescaped double quote, and it marks the end of the string.  */
      if (c == '"' && n_backslashes % 2 == 0)
	break;

      n_backslashes = (c == '\\' ? n_backslashes + 1 : 0);
      if (c == '\n')
	++lineno;
    }
}

^[ \t]*#[ \t]*if/[ \t]		{ emit_indented_cpp (EIC_IF, "if", yyout); }
^[ \t]*#[ \t]*ifdef/[ \t]	{ emit_indented_cpp (EIC_IF, "ifdef", yyout); }
^[ \t]*#[ \t]*ifndef/[ \t]	{ emit_indented_cpp (EIC_IF, "ifndef", yyout); }

^[ \t]*#[ \t]*elif[ \t]		{ emit_indented_cpp (EIC_ELSE, "elif", yyout); }
^[ \t]*#[ \t]*else([ \t]|$)	{ emit_indented_cpp (EIC_ELSE, "else", yyout); }

^[ \t]*#[ \t]*endif([ \t]|$)	{ emit_indented_cpp (EIC_ENDIF "endif", yyout);}

^[ \t]*#			{ emit_indented_cpp (EIC_OTHER, "", yyout); }

\n				{ MY_ECHO; ++lineno; }
.				{ MY_ECHO; }

%%

void
cpp_indent (const char *in_file, const char *out_file)
{
  FILE *out_stream;
  FILE *in = NULL;

  if (STREQ (in_file, "-"))
    {
      yyin = stdin;
      in_file = "standard input";
    }
  else
    {
      if ((in = fopen (in_file, "r")) == NULL)
	fatal (errno, "%s: %s", program_name, in_file);
      yyin = in;
    }

  if ((out_stream = fopen (out_file, "w")) == NULL)
    fatal (errno, "%s: %s", program_name, out_file);

  yyout = out_stream;
  cpp_i (in_file);

  if (in && fclose (in) == EOF)
    fatal (errno, "%s: %s", program_name, in_file);
  if (fclose (out_stream) == EOF)
    fatal (errno, "%s: %s", program_name, out_file);
}

#ifdef TESTING_ERR_TO_HDL

int
main (int argc, char** argv)
{
  char *in, *out;

  program_name = argv[0];

  assert (argc == 3);
  in = argv[1];
  out = argv[2];
  err_to_hdl (in, out);

  if (fclose (stdout) == EOF)
    fatal (errno, "%s: write error", program_name);

  exit (0);
}

#endif
