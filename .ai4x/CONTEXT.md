# Purpose

Stable project understanding for md2pdf. Read [BEHAVIOR.md](BEHAVIOR.md) for
operating rules and [STATE.md](STATE.md) for the current handoff, task scope,
verification results, and unknowns. Current objectives belong only in STATE.md.

# Project And Entry Points

md2pdf converts Markdown into PDF through a Bash CLI, Pandoc, a fixed filter
pipeline, and LaTeX templates. Deterministic rendering and CLI ergonomics are
central constraints. Repository facts take precedence over this summary.

- `src/app/md2pdf.sh`: CLI parsing, runtime discovery, dependency checks,
  template selection, asset links, renderer identity, and Pandoc invocation.
- `src/lib/filters/manifest.sh`: ordered Lua filter list shared by runtime
  and golden tests. Inspect it rather than maintaining a second filter list.
- `src/lib/filters/`: Markdown/AST transformations.
- `src/lib/templates/`: paired `.tex` templates and `.icl` header includes.
- `doc/exp/`: example inputs and assets; filter cases are in `doc/exp/filters/`.
- `src/tst/run.sh` and `src/tst/expected/`: golden JSON AST and LaTeX tests.
- `src/tst/closure-manifest.sh`: renderer identity regression tests.
- `src/tst/inline-code-pdf.sh`: real PDF/text regression across bundled templates.
- `Makefile`: installation, uninstallation, and the `verify` target.
- `utl/completions/`: Bash, Zsh, and Fish completions.
- `utl/check-templates.sh`, `utl/check-charset.sh`: structural/character checks.
- `README.md`: installation and CLI documentation.
- `CHANGELOG.md`: release history; Git and GitHub hold commit/issue history.

# CLI And Rendering Contract

Usage: `md2pdf [options] -- <input.md> [pandoc args...]`.

- Runtime assets contain `templates/` and `filters/`. Discovery uses
  `MD2PDF_DATADIR`, then paths relative to the resolved entry script.
- `--template <name|path>` selects a bundled name or an explicit path.
  A matching `.icl` is preferred; `default.icl` is the fallback.
- The default PDF is beside the input. An explicit relative output path is
  relative to the caller's working directory.
- Rendering runs inside the input directory. A sibling `<input-base>.yaml`
  is loaded as metadata when present.
- One Pandoc invocation uses `pdflatex`, a table of contents, numbered
  sections, `idiomatic` syntax highlighting, and `listings=true`.
  Pandoc manages required LaTeX reruns for cross-references.
- Pipeline order is `pandoc-include`, the ordered Lua filters, then
  `pandoc-crossref`. Caller-supplied Pandoc arguments are appended.
- Bundled includes scope Listings' argument scanner to Pandoc's `\passthrough`
  wrapper. Its pre-tokenized inline code must not select the direct-input
  scanner based on an active UTF-8 leading byte; standalone Listings calls
  retain their normal scanner selection.
- `listing-caption-wrap.lua` wraps captioned `lst:` code blocks for
  pandoc-crossref in LaTeX listings mode to avoid duplicate captions.
- Repeatable `--asset-link <dir>` resolves relative directories from the
  input directory and creates basename symlinks there, cleaned on exit.
  Existing symlinks can be replaced; existing files/directories are rejected.
- `--list-templates` lists bundled names and exits without rendering.
- `--closure-manifest` emits deterministic JSON and exits without rendering.
  It is mutually exclusive with `--list-templates`.

Evidence: `src/app/md2pdf.sh`; `src/lib/filters/manifest.sh`;
`src/lib/filters/listing-caption-wrap.lua`.

# Renderer Identity Limits

The schema `md2pdf.closure-manifest/v1` reports the entry-script SHA-256,
filter-manifest path/digest, ordered active filter paths/digests, selected
template/header paths/digests, and Pandoc/pandoc-crossref/pdflatex versions.
Bundled paths are data-directory-relative.

It does not capture the entire rendering environment: for example,
pandoc-include has no reported version, and TeX packages, fonts, document
inputs, and arbitrary Pandoc arguments are not identified by this schema.
Do not treat equal manifests alone as proof of byte-identical PDFs.

Evidence: `print_closure_manifest` in `src/app/md2pdf.sh`.

# Dependencies And Installation

- Rendering requires `pandoc`, `pdflatex`, `pandoc-include`, and
  `pandoc-crossref`. Asset links additionally require `python3`.
- Golden tests require Python 3. Charset checking uses Perl.
- A working pdflatex executable alone does not establish template readiness.
  Shipped includes use packages such as fontawesome5, tcolorbox, awesomebox,
  and pdflscape.
- `make install` installs the executable, templates, filters, manifest, and
  completions. `PREFIX`, `DESTDIR`, and component directory variables are
  configurable. Install/uninstall prune matching runtime files in the chosen
  data directories; use a disposable prefix for installation tests.

Evidence: `README.md`; `Makefile`; `src/lib/templates/*.icl`.

# Verification Boundaries

`make verify` checks shell syntax, template listing and pairs, tracked-file
charset, golden JSON AST/LaTeX output, and closure-manifest regressions.
It does not compile a PDF or perform installation acceptance.

`make verify-pdf` compiles `doc/exp/inline-code.md` with every bundled template
and checks extracted text against `src/tst/expected/inline-code.txt`. It requires
the rendering dependencies, Python 3, and Poppler's `pdftotext`, plus the actual
LaTeX packages/fonts used by the templates. Extraction uses content order to
avoid joining independent cases across columns. It does not check visual
styling automatically or establish downstream/CI acceptance.

Golden JSON comparisons normalize away `pandoc-api-version`; LaTeX comparisons
are strict. Pandoc writer changes can therefore affect goldens even when ASTs
are unchanged. Investigate the renderer version and exact diff before changing
expected fixtures.

The charset checker currently permits ASCII plus German umlauts, sharp s, and
the copyright symbol. The broader text policy in BEHAVIOR.md mentions required
LaTeX math symbols; such an exception is not implemented in the checker. Use
ASCII LaTeX commands when possible and surface any required exception.

Evidence: `Makefile`; `src/tst/run.sh`; `src/tst/closure-manifest.sh`;
`utl/check-charset.sh`.

# Memory And Adapters

`.ai4x/` is the canonical operational memory. `AGENTS.md` is an adapter
symlink to `.ai4x/BEHAVIOR.md`; `.github/agents/md2pdf.agent.md` also points
agents there. Do not modify adapters unless explicitly requested.

Memory must remain useful without chat history, session storage, temporary
scripts, or an absolute checkout path. Discover the current root through Git.
