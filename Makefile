CC = gcc
optimize = -pipe -g -O2
CFLAGS = -I. -g $(optimize) -Wall -D__USE_FIXED_PROTOTYPES__
LINK.c = $(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS)

PERL = /p/bin/perl

t = a b c
td = $(addsuffix .d,$t)
tO = $(addsuffix .O,$t)

qd = $(addsuffix .qd,$t)
qO = $(addsuffix .qO,$t)

LEX = flex
lex_debug = #-d
lex_optimize = -Cfr -p -b
LFLAGS = $(lex_debug) $(lex_optimize)

# all: $(td) $(qd) cppi
all: check

check: $(qd) cppi
	for i in d1 e1 e2 e3 e4 e5 e6 e7 e8 e9 f1 f2 f3 f4 f5 f6; do \
	  echo $$i...; \
	  ./$$i; \
	done

cppi: cppi.o fatal.o strerror.o
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -o $@

cppi.o: cpp-cond-lookup.c

cpp-cond-lookup.c: cpp.gp
	gperf -a -C -E -N cpp_cond_lookup -n -p -t -s 6 -k '*' $< > $@-tmp
	mv $@-tmp $@

$(td): %.d: %.E %.O
	-diff -u $^ > $@-tmp
	@mv $@-tmp $@
	@test -s $@ && cat $@ || :

$(tO): %.O: %.I cpp-indent
	./cpp-indent $< > $@-tmp
	mv $@-tmp $@

$(qd): %.qd: %.E %.qO
	-diff -u $^ > $@-tmp
	@mv $@-tmp $@
	@test -s $@ && cat $@ || :

$(qO): %.qO: %.I cppi
	./cppi $< > $@-tmp
	mv $@-tmp $@

.SUFFIXES:
.SUFFIXES: .c .o .l .pl

editpl = sed -e 's,@''PERL''@,$(PERL),g'
perl_in = $(wildcard *.pl)
perl = $(patsubst %.pl,%,$(perl_in))

.pl:
	rm -f $@ $@.tmp
	$(editpl) $< > $@.tmp && chmod +x-w $@.tmp && mv $@.tmp $@

%.c: %.l
	rm -f $@-tmp $@
	$(LEX) $(LFLAGS) -t $< > $@-tmp
	chmod u-w $@-tmp
	mv $@-tmp $@

clean:
	rm -f cpp-indent cppi *.o *.O *.d *.qO *.qd
