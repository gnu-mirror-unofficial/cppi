CC = gcc
optimize = -O -pipe
CFLAGS = -I. -g $(optimize) -Wall -D__USE_FIXED_PROTOTYPES__
LINK.c = $(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS)

PERL = /p/bin/perl

t = empty a b c
td = $(addsuffix .d,$t)
tO = $(addsuffix .O,$t)

qd = $(addsuffix .qd,$t)
qO = $(addsuffix .qO,$t)

LEX = flex
lex_debug = #-d
LFLAGS = -I $(lex_debug)

# all: $(td) $(qd) cppi
all: check

check: $(qd) cppi
	for i in e1 e2 e3 e3; do echo $$i...; ./$$i; done

cppi: cppi.o fatal.o strerror.o
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -o $@

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
