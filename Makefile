all: report.pdf

build:
	mkdir -p build

build/%.tex: sections/%.md build
	pandoc -f markdown_github+raw_tex -t latex --listings --chapters $< -o $@

report.pdf: build/introduction.tex report.tex report.bib
	pdflatex report.tex
	bibtex report
	pdflatex report.tex
	pdflatex report.tex

clean:
	cat .gitignore | xargs rm -rf

.PHONY: all clean
