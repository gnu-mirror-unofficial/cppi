#!@PERL@ -w
# Filter C code so that CPP #-directives are indented to reflect nesting.
# written by Jim Meyering
use strict;

my $checking = 0;
if (@ARGV && $ARGV[0] eq '-c')
  {
    shift @ARGV;
    $checking = 1;
  }
unshift (@ARGV, '-') if @ARGV == 0;

die "usage: $0 [FILE]\n" if @ARGV > 1;

my $file = shift @ARGV;
my $exit_status = cpp_indent ($file, $checking);

exit ($exit_status);

# ===============================

# Return 2 for syntax problems.
# Return 1 for invalid indentation of CPP #-directives (only if $checking).
# if checking
#   return 0 if syntax and indentation are valid
# else
#   if (syntax is valid)
#     {
#       print properly indented code to stdout
#       return 0
#     }
sub cpp_indent ($$)
{
  my ($file, $checking) = @_;

  sub IN_CODE {1}
  sub IN_COMMENT {2}
  sub IN_STRING {3}
  sub update_state ($$)
  {
    my ($state, $line) = @_;

    while ($line)
      {
	my $remainder = '';
	if ($state == IN_CODE)
	  {
	    if ($line =~ m!.*?(/\*|\")!g)
	      {
		if ($1 eq '"')
		  {
		    $state = IN_STRING
		      if ($& eq '"' || $&[length ($&) - 2] ne '\\');
		  }
		else
		  {
		    $state = IN_COMMENT;
		  }
		$remainder = $';
	      }
	  }
	elsif ($state == IN_COMMENT)
	  {
	    if ($line =~ m!.*?\*/!g)
	      {
		$state = IN_CODE;
		$remainder = $';
	      }
	  }
	else # $state == IN_STRING
	  {
	    if ($line =~ m!^\"|.*?[^\\]\"!g)
	      {
		$state = IN_CODE;
		$remainder = $';
	      }
	  }
	$line = $remainder;
      }

    return $state;
  }
  # ===============================================================

  # TODO: allow this to be overridden by a command-line option.
  my $indent_incr = ' ';

  my @opener_stack;
  my $depth = 0;

  open (FILE, $file) || die "$0: couldn't open $file: $!\n";

  my $fail = 0;
  my $state = IN_CODE;
  my $line;
  while (defined ($line = <FILE>))
    {
      my $rest;

      if ($state == IN_CODE)
	{
	  my $saved_line = $line;
	  if ($line =~ s/^\s*\#\s*//)
	    {
	      my $keyword;
	      my $indent;
	      my $pfx = "$0: $file: line $.";
	      if ($line =~ /^if(n?def)?\b/)
		{
		  # Maintain stack of (line number, keyword) pairs to better
		  # report any `unterminated #if...' errors.
		  push @opener_stack, {LINE_NUMBER => $., KEYWORD => $&};
		  $keyword = $&;
		  $indent = $indent_incr x $depth;
		  ++$depth;
		}
	      elsif ($line =~ /^(else|elif)\b/)
		{
		  if ($depth < 1)
		    {
		      warn "$pfx: found #$& without matching #if\n";
		      $depth = 1;
		      $fail = 2;
		    }
		  $keyword = $&;
		  $indent = $indent_incr x ($depth - 1);
		}
	      elsif ($line =~ /^endif\b/)
		{
		  if ($depth < 1)
		    {
		      warn "$pfx: found #$& without matching #if\n";
		      $depth = 1;
		      $fail = 2;
		    }
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

	      if ($checking && $saved_line ne "#$indent$keyword$'")
		{
		  warn "$pfx: not properly indented\n";
		  close FILE;
		  return 1;
		}

	      $line = "#$indent$keyword$'";
	      $rest = $';
	      $state = update_state ($state, $rest);
	    }
	  else
	    {
	      $rest = $line;
	    }
	}
      else
	{
	  $rest = $line;
	}
      print $line if !$checking;

      $state = update_state ($state, $rest);
    }
  close FILE;

  if ($depth != 0)
    {
      my $x;
      foreach $x (@opener_stack)
	{
	  warn "$0: $file: line $x->{LINE_NUMBER}: "
	    . "unterminated #$x->{KEYWORD}\n";
	}
      $fail = 2;
    }

  return $fail;
}
