#! @PERL@

$depth = 0;
$indent_incr = '  ';
$do_comments = 0;

while (<>)
  {
    if (/^#/)
      {
	if (/^#\s*(if(n?def)?)\b(.*)/)
	  {
	    $indent = $indent_incr x $depth;
	    print "#$indent$1$3\n";
	    ++$depth;
	  }
	elsif (/^#\s*else\b(.*)/)
	  {
	    $indent = $indent_incr x ($depth - 1);
	    print "#${indent}else$1\n";
	  }
	elsif (/^#\s*endif\b(.*)/)
	  {
	    --$depth;
	    $indent = $indent_incr x $depth;
	    print "#${indent}endif$1\n";
	  }
	elsif (/^#\s*(.*)/)
	  {
	    $indent = $indent_incr x $depth;
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
		$indent = $indent_incr x $depth;
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
