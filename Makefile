RUBBER_INFO = rubber-info
RUBBER = rubber --unsafe -m graphics -m xelatex --warn=refs --warn=misc
.SECONDARY:
SHELL = /bin/bash -eu

-include Makefile.local

all: annotated-presentation-skim.pdf presentation-skim.pdf

skim: annotated-presentation-skim.pdf
	open -a /Applications/Skim.app $<

annotated-presentation.pdf: presentation.tex

.PHONY: .FORCE

annotated-presentation.pdf: labels.aux

labels.aux: presentation-skim.pdf
	grep '^\\newlabel' presentation.aux > $@ ||:

%.pdf: %.tex .FORCE
	#iconv -f UTF-8 -t US-ASCII $< > /dev/null
	${RUBBER} $<
	if grep -q 'fourupslides Warning: $*-skim.pdf not found' $*.log; then \
	    cat $@ > $*-skim.pdf; \
	    ${RUBBER} --force $<; \
	fi
	$(EXTRA_CMDS)

%-skim.pdf: %.pdf
	cat $< > $@

clean::
	rm -f *.aux *.log *.snm *.toc *.nav *.out *.toc *.vrb \
	    {annotated-,}presentation*.pdf \
	    transcript.tex transcript*.pdf

realclean:: clean
	rm -f {annotated-,}presentation-skim.pdf

PYTHON_FILES = $(wildcard *.py)

presentation.pdf: $(PYTHON_FILES:%.py=%.py.include)

%.py.include: %.py ./python-interpret
	echo -n > $@
	echo '\begin{verbatim}' >> $@
	./python-interpret < $*.py >> $@
	echo '\end{verbatim}' >> $@

%.py.out: %.py
	(echo 'import datetime'; cat $<) | python > $@

clean::
	rm -f *.out *.include
