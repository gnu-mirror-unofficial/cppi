#! @PERL@ -w
# Filter C code so that CPP #-directives are indented to reflect nesting.
use strict;

# TODO: allow these to be overridden by command-line options
my $indent_incr = ' ';
my $do_comments = 0;

my $depth = 0;

while (<>)
  {
    if (s/^\s*\#\s*//)
      {
	my $keyword;
	my $indent;
	if (/^if(n?def)?\b/)
	  {
	    $keyword = $&;
	    $indent = $indent_incr x $depth;
	    ++$depth;
	  }
	elsif (/^(else|elif)\b/)
	  {
	    $keyword = $&;
	    $indent = $indent_incr x ($depth - 1);
	  }
	elsif (/^endif\b/)
	  {
	    $keyword = $&;
	    --$depth;
	    $indent = $indent_incr x $depth;
	  }
	else
	  {
	    $keyword = '';
	    $indent = $indent_incr x $depth;
	  }
	print "#$indent$keyword$'";
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
