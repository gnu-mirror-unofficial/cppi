#!@PERL@ -w
# Filter C code so that CPP #-directives are indented to reflect nesting.
# written by Jim Meyering
use strict;

# Bugs:
# May get confused by comments or string literals containing
# what would otherwise be valid cpp directives.

# TODO: allow these to be overridden by command-line options
my $indent_incr = ' ';

sub cpp_indent ($$)
{
  my ($file, $check_only) = @_;
  if (!open (IN, "<$file"))
    {
      warn "$0: $file: $!\n";
      return 0;
    }
}

my @opener_stack;
my $depth = 0;
my $check_only = 0;

my $line;
while (defined ($line = <>))
  {
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
	    die "$0: line $.: found #$& without matching #if\n" if $depth < 1;
	    $keyword = $&;
	    $indent = $indent_incr x ($depth - 1);
	  }
	elsif ($line =~ /^endif\b/)
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

	my $new_line = "#$indent$keyword$'";
	if ($check_only)
	  {
	    return 1 if $new_line ne $line;
	  }
	else
	  {
	    $line = $new_line;
	  }
      }
    print $line if !$check_only;
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
