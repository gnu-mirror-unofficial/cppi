#! @PERL@ -w
# Filter C code so that CPP #-directives are indented to reflect nesting.
use strict;

# TODO: allow these to be overridden by command-line options
my $indent_incr = ' ';
my $do_comments = 0;

my $depth = 0;

while (<>)
  {
    if (/^\s*#/)
      {
	if (/^\s*#\s*(if(n?def)?)\b/)
	  {
	    my $indent = $indent_incr x $depth;
	    print "#$indent$1$'";
	    ++$depth;
	  }
	elsif (/^\s*#\s*(else|elif)\b/)
	  {
	    my $indent = $indent_incr x ($depth - 1);
	    print "#${indent}$1$'";
	  }
	elsif (/^\s*#\s*endif\b/)
	  {
	    --$depth;
	    my $indent = $indent_incr x $depth;
	    print "#${indent}endif$'";
	  }
	elsif (/^\s*#\s*/)
	  {
	    my $indent = $indent_incr x $depth;
	    print "#$indent$1$'";
	  }
	else
	  {
	    die;
	  }
      }
    else
      {
        if ($do_comments)
	  {
	    if (/^(\/\*.*)/)
	      {
		my $indent = $indent_incr x $depth;
		print " ${indent}$_";
	      }
	    else
	      {
		print;
	      }
	  }
	else
	  {
	    print;
	  }
      }
  }

exit (0);
