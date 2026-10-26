#!/usr/bin/env bash
# Compile and extract real PDFs for the Listings UTF-8 regression (issue #8).
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKDIR="$(mktemp -d)"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

for tool in pandoc pandoc-include pandoc-crossref pdflatex pdftotext python3; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing PDF regression dependency: $tool" >&2
    exit 1
  fi
done

cp "$ROOT/doc/exp/inline-code.md" "$WORKDIR/probe.md"

for template_path in "$ROOT/src/lib/templates/"*.tex; do
  template="$(basename "$template_path" .tex)"
  pdf="$WORKDIR/$template.pdf"
  if ! MD2PDF_DATADIR="$ROOT/src/lib" "$ROOT/src/app/md2pdf.sh" \
    --template "$template" -o "$pdf" -- "$WORKDIR/probe.md" \
    >"$WORKDIR/render.log" 2>&1; then
    cat "$WORKDIR/render.log" >&2
    echo "PDF compilation failed ($template)." >&2
    exit 1
  fi

  # Keep content order: layout mode can join separate cases across two columns.
  pdftotext -raw "$pdf" "$WORKDIR/actual.txt"
  python3 - "$ROOT/src/tst/expected/inline-code.txt" "$WORKDIR/actual.txt" <<'PY'
from collections import Counter
from pathlib import Path
import sys
import unicodedata

def lines(path):
    text = unicodedata.normalize("NFC", Path(path).read_text(encoding="utf-8"))
    return Counter(" ".join(line.split()) for line in text.splitlines() if line.strip())

missing = lines(sys.argv[1]) - lines(sys.argv[2])
if missing:
    raise SystemExit(f"Missing or changed PDF text: {dict(missing)!r}")
PY
  echo "PASS: inline code compiles and preserves extracted text ($template)."
done
