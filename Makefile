
DOTS = $(wildcard *.dot)
SVGS = $(DOTS:.dot=.svg)
PNGS = $(DOTS:.dot=.png)

all: $(SVGS)

%.svg: %.dot
	dot -Tsvg $^ > $@

%.png: %.dot
	dot -Tpng $^ > $@

clean:
	rm -f $(PNGS)
