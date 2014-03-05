include Makefile.deps

all: report.pdf

Makefile.deps: report.tex
	sed -nE 's_\\include{build/(.*)}_report.pdf: build/\1.tex_gp' <report.tex >$@

build:
	mkdir -p build

build/%.tex: sections/%.md build
	pandoc -f markdown_github+raw_tex -t latex --listings --chapters $< -o $@

report.pdf: report.tex report.bib
	pdflatex report.tex
	bibtex report
	pdflatex report.tex
	pdflatex report.tex

count: report.pdf
	@texcount -merge -total report.tex 2>/dev/null | grep "Words in text" | sed 's/[^0-9]//g'

clean:
	cat .gitignore | xargs rm -rf

.PHONY: all clean count
