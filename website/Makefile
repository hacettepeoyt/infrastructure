M4 ?= m4
DESTDIR ?= $(out)

SRCS := $(wildcard *.html.m4)
HTMLS := $(subst .m4,,$(SRCS))
HTMLS += $(addprefix mobile/,$(HTMLS))
DEPS := common.html.m4 $(wildcard aux/*) Makefile

.PHONY: all
all: $(HTMLS)

.PHONY: preview
preview: all
	xdg-open index.html

.PHONY: preview-mobile
preview-mobile: all
	xdg-open mobile/index.html

.PHONY: clean
clean:
	rm -rf $(HTMLS)

.PHONY: install
install: all
	cp style.css *.html $(DESTDIR)
	@mkdir -p $(DESTDIR)/mobile
	cp mobile/*.html $(DESTDIR)/mobile

%.html: %.html.m4 common.html.m4
	$(M4) -P -DWEB_ROOT="$$(realpath $(<D) --relative-to="$(@D)")" $< > $@

mobile/%.html: %.html.m4 common.html.m4
	@mkdir -p mobile
	$(M4) -P -DMOBILE=1 -DWEB_ROOT="$$(realpath $(<D) --relative-to="$(@D)")" $< > $@
