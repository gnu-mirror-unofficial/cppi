#! @PERL@ -w
# Filter C code so that CPP #-directives are indented to reflect nesting.
# written by Jim Meyering
use strict;

# TODO: allow these to be overridden by command-line options
my $indent_incr = ' ';
my $do_comments = 0;

my @opener_stack;
my $depth = 0;

while (<>)
  {
    if (s/^\s*\#\s*//)
      {
	my $keyword;
	my $indent;
	if (/^if(n?def)?\b/)
	  {
	    # Maintain stack of (line number, keyword) pairs to better
	    # report any `unterminated #if...' errors.
	    push @opener_stack, {LINE_NUMBER => $., KEYWORD => $&};
	    $keyword = $&;
	    $indent = $indent_incr x $depth;
	    ++$depth;
	  }
	elsif (/^(else|elif)\b/)
	  {
	    die "$0: line $.: found #$& without matching #if\n" if $depth < 1;
	    $keyword = $&;
	    $indent = $indent_incr x ($depth - 1);
	  }
	elsif (/^endif\b/)
	  {
	    die "$0: line $.: found #$& without matching #if\n" if $depth < 1;
	    $keyword = $&;
	    --$depth;
	    $indent = $indent_incr x $depth;
	    pop @opener_stack;
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

my $exit_status = 0;

if ($depth != 0)
  {
    my $x;
    foreach $x (@opener_stack)
      {
	warn "$0: line $x->{LINE_NUMBER}: unterminated #$x->{KEYWORD}\n"
      }
    $exit_status = 1;
  }

exit ($exit_status);
