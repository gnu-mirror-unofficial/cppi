PERL = /p/bin/perl
editpl = sed -e 's,@''PERL''@,$(PERL),g'

all: a.O
	diff -u a.E a.O

a.O: a.I cpp-indent
	./cpp-indent < $< > $@-tmp
	mv $@-tmp $@

.SUFFIXES:
.SUFFIXES: .pl

.pl:
	rm -f $@ $@.tmp
	$(editpl) $< > $@.tmp && chmod +x-w $@.tmp && mv $@.tmp $@

perl_in = $(wildcard *.pl)
perl = $(patsubst %.pl,%,$(perl_in))

clean:
	rm -f cpp-indent *.O
