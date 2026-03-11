PREFIX ?= /usr/local
DESTDIR ?=
SHELL ?= /bin/bash

BIN_NAME ?= md2pdf
SCRIPT ?= src/app/md2pdf.sh

BINDIR ?= $(PREFIX)/bin
DATADIR ?= $(PREFIX)/share/md2pdf
BASH_COMPLETION_DIR ?= $(PREFIX)/share/bash-completion/completions
ZSH_COMPLETION_DIR ?= $(PREFIX)/share/zsh/site-functions
FISH_COMPLETION_DIR ?= $(PREFIX)/share/fish/vendor_completions.d

.PHONY: install uninstall verify

install:
	install -d "$(DESTDIR)$(BINDIR)"
	install -m 0755 "$(SCRIPT)" "$(DESTDIR)$(BINDIR)/$(BIN_NAME)"
	install -d "$(DESTDIR)$(DATADIR)"
	install -d "$(DESTDIR)$(DATADIR)/templates"
	install -m 0644 src/lib/templates/*.tex "$(DESTDIR)$(DATADIR)/templates/"
	install -m 0644 src/lib/templates/*.icl "$(DESTDIR)$(DATADIR)/templates/"
	install -d "$(DESTDIR)$(DATADIR)/filters"
	install -m 0644 src/lib/filters/*.lua "$(DESTDIR)$(DATADIR)/filters/"
	install -m 0644 src/lib/filters/manifest.sh "$(DESTDIR)$(DATADIR)/filters/"
	install -d "$(DESTDIR)$(BASH_COMPLETION_DIR)"
	install -m 0644 "utl/completions/md2pdf.bash" "$(DESTDIR)$(BASH_COMPLETION_DIR)/$(BIN_NAME)"
	install -d "$(DESTDIR)$(ZSH_COMPLETION_DIR)"
	install -m 0644 "utl/completions/_md2pdf" "$(DESTDIR)$(ZSH_COMPLETION_DIR)/_$(BIN_NAME)"
	install -d "$(DESTDIR)$(FISH_COMPLETION_DIR)"
	install -m 0644 "utl/completions/md2pdf.fish" "$(DESTDIR)$(FISH_COMPLETION_DIR)/$(BIN_NAME).fish"
	@echo "Completion notes:"
	@echo "  Zsh: add 'fpath=(\"$(ZSH_COMPLETION_DIR)\" $$fpath)' and run 'compinit'."
	@echo "  Bash: ensure bash-completion is enabled; file is in $(BASH_COMPLETION_DIR)/$(BIN_NAME)."
	@echo "  Fish: completion is in $(FISH_COMPLETION_DIR)/$(BIN_NAME).fish."

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)/$(BIN_NAME)"
	rm -f "$(DESTDIR)$(BASH_COMPLETION_DIR)/$(BIN_NAME)"
	rm -f "$(DESTDIR)$(ZSH_COMPLETION_DIR)/_$(BIN_NAME)"
	rm -f "$(DESTDIR)$(FISH_COMPLETION_DIR)/$(BIN_NAME).fish"
	rm -f "$(DESTDIR)$(DATADIR)/templates/"*.tex
	rm -f "$(DESTDIR)$(DATADIR)/templates/"*.icl
	rm -f "$(DESTDIR)$(DATADIR)/filters/"*.lua
	rm -f "$(DESTDIR)$(DATADIR)/filters/manifest.sh"
	@rmdir "$(DESTDIR)$(DATADIR)/filters" 2>/dev/null || true
	@rmdir "$(DESTDIR)$(DATADIR)/templates" 2>/dev/null || true
	@rmdir "$(DESTDIR)$(DATADIR)" 2>/dev/null || true

verify:
	bash -n src/app/md2pdf.sh
	bash -n src/tst/run.sh
	./src/app/md2pdf.sh --list-templates >/dev/null
	./utl/check-templates.sh
	./utl/check-charset.sh
	src/tst/run.sh
