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

#define input_and_echo()			\
 ({						\
   int _c_ = input ();				\
   if (_c_ != EOF)				\
     fputc (_c_, yyout);			\
   _c_;						\
 })

static int lineno = 1;
static int i_depth = 0;
static int inhibit_output = 0;

char *program_name;

int
yywrap (void)
{
  return 1;
}

static void
emit_indented_cpp (char const *directive, FILE *out)
{
#define MAX_DEPTH
  static char blanks[] = { [0 ... MAX_DEPTH] = ' ' };

  if (inhibit_output)
    return;

  fputc ('#', out);
  assert (i_depth <= MAX_DEPTH);
  blanks[i_depth] = '\0';
  fputs (blanks, out);
  blanks[i_depth] = ' ';
  fputs (directive, out);
}

%}

%%

"/*"        {
  register int c;

  if (!inhibit_output)
    ECHO;
  for ( ; ; )
    {
      while ((c = input_and_echo ()) != '*' && c != EOF)
	{
	  if (c == '\n')
	    ++lineno;
	}

      if (c == '*')
	{
	  while ((c = input_and_echo ()) == '*')
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
  if (!inhibit_output)
    ECHO;
}

"\"" {
  register int c;

  /* Count consecutive backslashes.  We'll need this number when
     a string of them immediately precedes a double quote.  */
  int n_backslashes = 0;

  if (!inhibit_output)
    ECHO;

  while (1)
    {
      c = input_and_echo ();

      if (c == EOF)
	fatal (0, "%s: %s: ERROR: EOF in string", program_name, in_file);

      /* If the number of preceding backslashes is even, then this is
	 an unescaped double quote, and it marks the end of the string.  */
      if (c == '"' && n_backslashes % 2 == 0))
	break;

      n_backslashes = (c == '\\' ? n_backslashes + 1 : 0);
      if (c == '\n')
	++lineno;
    }
}

^[ \t]*#[ \t]*if/[ \t]		{ emit_indented_cpp ("if", yyout); }
^[ \t]*#[ \t]*ifdef/[ \t]	{ emit_indented_cpp ("ifdef", yyout); }
^[ \t]*#[ \t]*ifndef/[ \t]	{ emit_indented_cpp ("ifndef", yyout); }

^[ \t]*#[ \t]*elif[ \t]		{ emit_indented_cpp ("elif", yyout); }
^[ \t]*#[ \t]*else([ \t]|$)	{ emit_indented_cpp ("else", yyout); }

^[ \t]*#[ \t]*endif([ \t]|$)	{ emit_indented_cpp ("else", yyout); }

^[ \t]*#			{ emit_indented_cpp ("", yyout); }

.				{ if (!inhibit_output) ECHO; }
\n				{ if (!inhibit_output) ECHO; ++lineno; }

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
