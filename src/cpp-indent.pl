#! @PERL@ -w
# Filter C code so that CPP #-directives are indented to reflect nesting.
use strict;

# TODO: allow these to be overridden by command-line options
my $indent_incr = ' ';
my $do_comments = 0;

my $depth = 0;

while (<>)
  {
    if (/^#/)
      {
	if (/^#\s*(if(n?def)?)\b(.*)/)
	  {
	    my $indent = $indent_incr x $depth;
	    print "#$indent$1$3\n";
	    ++$depth;
	  }
	elsif (/^#\s*(else|elif)\b(.*)/)
	  {
	    my $indent = $indent_incr x ($depth - 1);
	    print "#${indent}$1$2\n";
	  }
	elsif (/^#\s*endif\b(.*)/)
	  {
	    --$depth;
	    my $indent = $indent_incr x $depth;
	    print "#${indent}endif$1\n";
	  }
	elsif (/^#\s*(.*)/)
	  {
	    my $indent = $indent_incr x $depth;
	    print '#', $indent, $1, "\n";
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
