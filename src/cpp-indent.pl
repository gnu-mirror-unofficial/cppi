#!@PERL@ -w
# Filter C code so that CPP #-directives are indented to reflect nesting.
# written by Jim Meyering
use strict;

unshift (@ARGV, '-') if @ARGV == 0;
die "usage: $0 [FILE]\n" if @ARGV > 1;

my $file = shift @ARGV;
my $exit_status = cpp_indent ($file, 0);

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

  # Bugs:
  # May get confused by comments or string literals containing
  # what would otherwise be valid cpp directives.

  # TODO: allow this to be overridden by a command-line option.
  my $indent_incr = ' ';

  my @opener_stack;
  my $depth = 0;

  open (FILE, $file) || die "$0: couldn't open $file: $!\n";

  my $fail = 0;
  my $line;
  while (defined ($line = <FILE>))
    {
      my $saved_line = $line;
      if ($line =~ s/^\s*\#\s*//)
	{
	  my $keyword;
	  my $indent;
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
		  warn "$0: $file: line $.: found #$& without matching #if\n";
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
		  warn "$0: $file: line $.: found #$& without matching #if\n";
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
	      warn "foo: $saved_line ne #$indent$keyword$'\n";
	      close FILE;
	      return 1;
	    }
	  $line = "#$indent$keyword$'";
	}
      print $line if !$checking;
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
