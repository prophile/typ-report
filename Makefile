MARKDOWN_FORMAT=markdown+pipe_tables+tex_math_single_backslash+fenced_code_blocks+fenced_code_attributes+auto_identifiers+backtick_code_blocks+autolink_bare_uris+intraword_underscores+strikeout+footnotes+all_symbols_escapable

include Makefile.deps

all: report.pdf

Makefile.deps: report.tex
	sed -nE 's_\\include{build/(.*)}_report.pdf: build/\1.tex_gp' <report.tex >$@

build:
	mkdir -p build

build/%.tex: sections/%.md build
	pandoc -f $(MARKDOWN_FORMAT) -t latex --listings --chapters $< -o $@

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
