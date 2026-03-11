# md2pdf

`md2pdf` converts Markdown into structured PDF files using Pandoc, LaTeX templates, and a curated Lua filter pipeline.

## Install

Requirements:

- Pandoc with Lua support
- A LaTeX distribution with `pdflatex`
- `pandoc-crossref` (optional, enabled by default)
- Python 3 (required for `--asset-link`)

Install from this repository:

```bash
make install
```

User-local install:

```bash
make PREFIX=$HOME/.local install
```

## Quick Start

Convert a Markdown file:

```bash
md2pdf -- note.md
```

Select a template:

```bash
md2pdf --template article-modern -- note.md
```

Disable cross-references for a run:

```bash
md2pdf --no-crossref -- note.md
```

Run directly from source tree:

```bash
./src/app/md2pdf.sh -- doc/exp/main.md
```

## Usage

```bash
md2pdf [options] -- <input.md> [pandoc args...]
```

Options:

- `-o, --output <file>`: output PDF path (default: `<input>.pdf`)
- `--template <name|path>`: template name or explicit `.tex` path
- `--no-crossref`: disable `pandoc-crossref` for the current run
- `--list-templates`: list available template names and exit
- `--asset-link <dir>`: create temporary asset symlink(s) in input directory
- `--debug`: print resolved paths and full Pandoc command
- `--version`: print version information

Use external assets without moving files:

```bash
md2pdf --asset-link ../shared-assets -- note.md
```

## Template Catalog

Available templates:

- `default`: balanced default style
- `article-modern`: modern single-column article style
- `article-stylish`: editorial article style
- `article-stylish-2col`: lean two-column article style
- `note-modern`: compact note-oriented style
- `report-stylish`: report-oriented style

List templates from CLI:

```bash
md2pdf --list-templates
```

## Language Handling

Set `lang` in front matter to control localized labels such as the table-of-contents title.

```yaml
---
lang: de-DE
---
```

## Completion

Installed completion targets:

- Bash: `/usr/local/share/bash-completion/completions/md2pdf`
- Zsh: `/usr/local/share/zsh/site-functions/_md2pdf`
- Fish: `/usr/local/share/fish/vendor_completions.d/md2pdf.fish`

## Quality Checks

Run full local verification:

```bash
make verify
```

Run test suite only:

```bash
src/tst/run.sh
```

## Project Structure

```text
.
|-- doc
|   |-- exp
|   `-- ops
|-- src
|   |-- app
|   |-- lib
|   |   |-- filters
|   |   `-- templates
|   `-- tst
`-- utl
    `-- completions
```

## License

See [LICENSE](./LICENSE).
© 2026 [nemron](https://github.com/normenmueller)
