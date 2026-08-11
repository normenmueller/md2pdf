# md2pdf

`md2pdf` converts Markdown into structured PDF files using Pandoc, LaTeX templates, and a curated Lua filter pipeline.

## Install

Runtime requirements:

- Pandoc with Lua support
- A LaTeX distribution with `pdflatex`
- `pandoc-include`
- `pandoc-crossref`
- Python 3 (required for `--asset-link`)

Installation from this repository also requires `make` and the standard `install` utility.

Install the Python-based Pandoc include filter with pipx:

```bash
pipx install pandoc-include
```

Check that the required Pandoc filters are visible on `PATH`:

```bash
command -v pandoc-include pandoc-crossref
```

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

Run directly from source tree:

```bash
./src/app/md2pdf.sh -- doc/exp/main.md
```

See `doc/exp` for runnable examples, including filters, assets, tables, and source includes.

## Usage

```bash
md2pdf [options] -- <input.md> [pandoc args...]
```

Options:

- `-o, --output <file>`: output PDF path (default: `<input>.pdf`)
- `--template <name|path>`: template name or explicit `.tex` path
- `--list-templates`: list available template names and exit
- `--asset-link <dir>`: create temporary asset symlink(s) in input directory
- `--debug`: print resolved paths and full Pandoc command
- `--version`: print version information

Use external assets without moving files:

```bash
md2pdf --asset-link ../shared-assets -- note.md
```

## Project Structure

```text
.
|-- .ai4x
|-- acc
|   `-- obsidian
|-- doc
|   `-- exp
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
