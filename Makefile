
DOTS = $(wildcard *.dot)
SVGS = $(DOTS:.dot=.svg)
PNGS = $(DOTS:.dot=.png)
JPGS = $(DOTS:.dot=.jpg)

all: $(PNGS)

%.svg: %.dot
	dot -Tsvg $^ -o $@

%.png: %.dot
	dot -Tpng -Gsize=3,15\! -Gdpi=100 $^ -o $@

%.jpg: %.dot
	dot -Tjpg -Gsize=3,15\! -Gdpi=100 $^ -o $@

clean:
	rm -f $(SVGS) $(PNGS) $(JPGS)
