#!@PERL@ -w
# Filter C code so that CPP #-directives are indented to reflect nesting.
# written by Jim Meyering
use strict;

# Bugs:
# May get confused by comments or string literals containing
# what would otherwise be valid cpp directives.

# TODO: allow these to be overridden by command-line options
my $indent_incr = ' ';

my @opener_stack;
my $depth = 0;

unshift (@ARGV, '-') if @ARGV == 0;
die "usage: $0 [FILE]\n" if @ARGV > 1;

my $file = shift @ARGV;

open (FILE, $file) || die "$0: couldn't open $file: $!\n";

my $exit_status = 0;
my $line;
while (defined ($line = <FILE>))
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
	    if ($depth < 1)
	      {
		warn "$0: $file: line $.: found #$& without matching #if\n";
		$depth = 1;
		$exit_status = 1;
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
		$exit_status = 1;
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

	$line = "#$indent$keyword$'";
      }
    print $line;
  }
close FILE;

if ($depth != 0)
  {
    my $x;
    foreach $x (@opener_stack)
      {
	warn "$0: $file: line $x->{LINE_NUMBER}: unterminated #$x->{KEYWORD}\n"
      }
    $exit_status = 1;
  }

exit ($exit_status);
