# Purpose

This file contains stable project understanding for future agents working on `md2pdf`.

# Project Summary

`md2pdf` converts Markdown into structured PDF files using Pandoc, LaTeX templates, and a curated Lua filter pipeline.
The practical goal is a deterministic, ergonomic CLI that supports repeatable PDF generation, reusable templates, filter-based Markdown transformations, installable runtime assets, and shell completions.
Evidence: `README.md`; `src/app/md2pdf.sh`; `src/lib/filters/manifest.sh`; `Makefile`.

# Current Objective

The active workstream is migration of old agent-operation artifacts into canonical `.ai4X/` bootstrap memory:

- `.ai4X/BEHAVIOR.md`
- `.ai4X/CONTEXT.md`
- `.ai4X/STATE.md`

The user instructed that existing `doc/ops/AGENTS.md` and `doc/ops/_workflow.md` be considered, adapted into `.ai4X/`, and deleted once their relevant content is safely transferred.
Evidence: active user instruction.

# Background

- The project previously stored agent instructions in `doc/ops/AGENTS.md` and strict workflow guidance in `doc/ops/_workflow.md`.
- A root-level `AGENTS.md` symlink pointed to `doc/ops/AGENTS.md`.
- The user wants long-running project memory that works across future sessions without chat history or assistant resume state.
- The new canonical memory system is `.ai4X/`, with separate files for behavior, context, and volatile state.
- Agent chat remains German by default; generated repository artifacts remain English by default.
Evidence: active user instruction; former `doc/ops/AGENTS.md`; former `doc/ops/_workflow.md`.

# Domain Model

- CLI entrypoint: `src/app/md2pdf.sh` parses options, resolves runtime asset directories, validates dependencies, resolves templates, builds filter arguments, creates optional asset symlinks, and runs Pandoc twice for TOC and cross-reference convergence.
- Runtime data directory: contains `templates/` and `filters/`. It can be discovered from `MD2PDF_DATADIR` or relative installed/source paths. Evidence: `src/app/md2pdf.sh`.
- Template selector: `--template <name|path>` accepts a named template from the templates directory or an explicit `.tex` path. A matching `.icl` include file is used when available; otherwise `default.icl` is fallback. Evidence: `src/app/md2pdf.sh`.
- Filter pipeline: `src/lib/filters/manifest.sh` defines ordered Lua filter files shared by runtime and tests.
- Golden outputs: `src/tst/expected/*.json` and `src/tst/expected/*.tex` define expected Pandoc JSON AST and LaTeX output for examples.
- Examples: `doc/exp` contains runnable and regression Markdown inputs, including filter-specific cases under `doc/exp/filters`.
- Install flow: `Makefile` installs executable, templates, filters, filter manifest, and Bash/Zsh/Fish completions under configurable `PREFIX`, `DESTDIR`, and directory variables.
- Asset links: `--asset-link <dir>` creates temporary symlinks in the input directory and cleans them on exit. Evidence: `src/app/md2pdf.sh`.
- Character policy: tracked repository text is checked for disallowed non-ASCII characters by `utl/check-charset.sh`.

# Repository Map

- `.ai4X/`: canonical operational memory for future agents.
- `src/app/md2pdf.sh`: executable Bash CLI entrypoint.
- `src/lib/filters/`: Lua filters plus `manifest.sh` for pipeline order.
- `src/lib/templates/`: LaTeX templates and paired header include files.
- `src/tst/run.sh`: golden regression test runner.
- `src/tst/expected/`: expected JSON AST and LaTeX outputs.
- `doc/exp/`: runnable and regression examples.
- `utl/completions/`: Bash, Zsh, and Fish completion definitions.
- `utl/check-templates.sh`: template pair validation.
- `utl/check-charset.sh`: repository character policy validation.
- `Makefile`: install, uninstall, and verification targets.
- `README.md`: user-facing install, usage, template catalog, completion, quality, and project structure documentation.
- `CHANGELOG.md`: release history.
- `.gitignore`: ignores generated PDFs and LaTeX auxiliary outputs.

# Architecture And Design

- The CLI is implemented as a Bash script with strict mode and array-based command construction. Evidence: `src/app/md2pdf.sh`.
- Runtime assets are separated from the executable. The CLI resolves a data directory containing templates and filters, validating required files before execution. Evidence: `src/app/md2pdf.sh`.
- The Pandoc command uses Markdown extensions, PDF output, a selected LaTeX template, a selected header include file, `pdflatex`, table of contents, numbered sections, syntax highlighting, required `pandoc-include`, ordered Lua filters, required `pandoc-crossref`, optional input-local YAML metadata, and user-provided Pandoc arguments after `--`. Evidence: `src/app/md2pdf.sh`.
- Tests apply the same ordered filter manifest to examples and compare both normalized JSON AST and LaTeX output against golden files. Evidence: `src/tst/run.sh`; `src/lib/filters/manifest.sh`.
- Template integrity is checked structurally by ensuring each `.tex` has a paired `.icl` and that `default.tex` and `default.icl` exist. Evidence: `utl/check-templates.sh`.
- Install and uninstall are Makefile-driven and support configurable install roots. Evidence: `Makefile`.
- INFERRED: The project favors deterministic outputs over convenience because PDF rendering, golden tests, and explicit validation gates are central to the workflow.

# User Preferences

- Chat responses must be in German unless the user requests another language.
- Repository artifacts and source code must be in English unless the user explicitly requests another artifact language.
- The user expects a senior expert peer, not a passive assistant.
- The user values durable cross-session agent memory and wants fresh agents to become useful without chat history.
- The user wants old operational artifacts removed after migration into `.ai4X/`.
- The user expects concrete execution on disk, not only explanations.
Evidence: active user instruction; former `doc/ops/AGENTS.md`.

# Constraints

- Keep output behavior deterministic.
- Keep user-facing CLI stable unless explicitly changed.
- Keep documentation aligned with implementation.
- Keep shell completions aligned with CLI options.
- Keep template `.tex` and `.icl` pairs consistent.
- Keep filter order synchronized through `src/lib/filters/manifest.sh`.
- Validate risky changes; do not silently skip checks.
- Public release commands require explicit user approval. Evidence: former `_workflow.md`.
- Source code and repository documentation must obey the repository character policy. Evidence: `utl/check-charset.sh`.
- External dependencies for normal operation include Pandoc, a LaTeX distribution with `pdflatex`, `pandoc-include`, `pandoc-crossref`, and Python 3 for `--asset-link`. Evidence: `README.md`; `src/app/md2pdf.sh`.

# Non-Goals

- Do not redesign the CLI, filter pipeline, template architecture, install layout, or documentation structure unless explicitly requested.
- Do not change PDF output or golden fixtures unless the behavior change is intentional and verified.
- Do not restore old host-specific adapter files unless the user explicitly asks.
- Do not turn `.ai4X/` files into user-facing product documentation; they are operational memory for agents.
- Do not persist secrets, credentials, or unnecessary personal data in `.ai4X/`.

# External Context

- No web or external research was consulted for this bootstrap update.
- Project-relevant external tools are Pandoc, `pdflatex`, `pandoc-include`, `pandoc-crossref`, Python 3, Bash, Make, Git, and shell completion systems. Evidence: repository files.
