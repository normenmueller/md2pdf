# Changelog

## 0.2.0 - 2026-06-23

- Require `pandoc-include` and `pandoc-crossref` as standard runtime dependencies.
- Run `pandoc-include` before the md2pdf Lua filter pipeline so included Markdown and code snippets participate in normal processing.
- Remove `--no-crossref`; cross-reference handling is now part of the fixed md2pdf document contract.

## 0.1.2 - 2026-06-06

- Render Markdown level-4 and level-5 headings as block headings with explicit spacing in all templates.

## 0.1.1 - 2026-03-11

- Fix install flow by pruning stale templates and filters before copying new release files.
- Document dedicated branch and pull-request discipline for changes and merges.

## 0.1.0 - 2026-03-11

- Initial Commit.
