DOT = datapath.dot

main: ${DOT:.dot=.png} ${DOT:.dot=.pdf} ${DOT:.dot=.svg}

.dot.pdf:
	dot -Tpdf $< >$@

.dot.png:
	dot -Tpng $< >$@

.dot.svg:
	dot -Tsvg $< >$@

.SUFFIXES: .dot .pdf .png .svg
