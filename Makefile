PERL = /p/bin/perl
editpl = sed -e 's,@''PERL''@,$(PERL),g'

t = empty a b c
td = $(addsuffix .d,$t)
tO = $(addsuffix .O,$t)

all: $(td)

$(td): %.d: %.E %.O
	-diff -u $^ > $@-tmp
	@mv $@-tmp $@
	@test -s $@ && cat $@ || :

$(tO): %.O: %.I cpp-indent
	./cpp-indent $< > $@-tmp
	mv $@-tmp $@

.SUFFIXES:
.SUFFIXES: .pl

.pl:
	rm -f $@ $@.tmp
	$(editpl) $< > $@.tmp && chmod +x-w $@.tmp && mv $@.tmp $@

perl_in = $(wildcard *.pl)
perl = $(patsubst %.pl,%,$(perl_in))

clean:
	rm -f cpp-indent *.O *.d
