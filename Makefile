CC = gcc
optimize = -pipe -O2
CFLAGS = -I. -g $(optimize) -Wall -Wshadow -D__USE_FIXED_PROTOTYPES__
LINK.c = $(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS)

PERL = /p/bin/perl

LEX = flex
lex_debug = #-d
lex_optimize = -Cfr -p -b
LFLAGS = $(lex_debug) $(lex_optimize)

all: check

tests = d1 d2 d3 d4 e1 e2 e3 e4 e5 e6 e7 e8 e9 f1 f2 f3 f4 f5 f6 f7 f8 f9
check: cppi
	cd tests && \
	for i in $(tests); do \
	  echo $$i...; \
	  ./$$i; \
	done

cppi: cppi.o fatal.o warn.o strerror.o getopt.o getopt1.o obstack.o
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -o $@

cppi.o: cpp-cond-lookup.c

cpp-cond-lookup.c: cpp.gp
	gperf -a -C -E -N cpp_cond_lookup -n -p -t -s 6 -k '*' $< \
	  | sed 's/str\[/(unsigned char) str[/' > $@-tmp
	mv $@-tmp $@

.SUFFIXES:
.SUFFIXES: .c .o .l .pl

editpl = sed -e 's,@''PERL''@,$(PERL),g'
perl_in = $(wildcard *.pl)
perl = $(patsubst %.pl,%,$(perl_in))

.pl:
	rm -f $@ $@.tmp
	$(editpl) $< > $@.tmp && chmod +x-w $@.tmp && mv $@.tmp $@

#.PRECIOUS: cppi.c

%.c: %.l
	rm -f $@-tmp $@
	$(LEX) $(LFLAGS) -t $< > $@-tmp
	chmod u-w $@-tmp
	mv $@-tmp $@

clean:
	rm -f cpp-indent cppi *.o

realclean: clean
	rm -f cpp-cond-lookup.c cppi.c
