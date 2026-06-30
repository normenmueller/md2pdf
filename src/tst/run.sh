#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
JSON_ACTUAL_TMP="$(mktemp)"
JSON_EXPECTED_TMP="$(mktemp)"
LATEX_TMP="$(mktemp)"
cleanup() { rm -f "$JSON_ACTUAL_TMP" "$JSON_EXPECTED_TMP" "$LATEX_TMP"; }
trap cleanup EXIT

FILTER_MANIFEST="$ROOT/src/lib/filters/manifest.sh"
if [[ ! -f "$FILTER_MANIFEST" ]]; then
  echo "Missing filter manifest: $FILTER_MANIFEST" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$FILTER_MANIFEST"

if [[ -z "${MD2PDF_FILTER_FILES+x}" || "${#MD2PDF_FILTER_FILES[@]}" -eq 0 ]]; then
  echo "Filter manifest does not define MD2PDF_FILTER_FILES." >&2
  exit 1
fi

BASE_ARGS=(--from=markdown-smart+fenced_code_attributes --filter=pandoc-include)

for filter_file in "${MD2PDF_FILTER_FILES[@]}"; do
  filter_path="$ROOT/src/lib/filters/$filter_file"
  if [[ ! -f "$filter_path" ]]; then
    echo "Missing filter from manifest: $filter_path" >&2
    exit 1
  fi
  BASE_ARGS+=(--lua-filter="$filter_path")
done

normalize_json() {
  local input="$1"
  local output="$2"

  python3 - "$input" "$output" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    data = json.load(fh)

data.pop("pandoc-api-version", None)

with open(sys.argv[2], "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=4, ensure_ascii=False)
    fh.write("\n")
PY
}

run_case() {
  local name="$1"
  local input="$2"

  pandoc "${BASE_ARGS[@]}" "$input" -t json | python3 -m json.tool > "$JSON_ACTUAL_TMP"
  normalize_json "$ROOT/src/tst/expected/${name}.json" "$JSON_EXPECTED_TMP"
  normalize_json "$JSON_ACTUAL_TMP" "$JSON_ACTUAL_TMP"
  diff -u "$JSON_EXPECTED_TMP" "$JSON_ACTUAL_TMP"
  echo "JSON AST matches golden file (${name})."

  pandoc "${BASE_ARGS[@]}" "$input" -t latex > "$LATEX_TMP"
  diff -u "$ROOT/src/tst/expected/${name}.tex" "$LATEX_TMP"
  echo "LaTeX output matches golden file (${name})."
}

run_crossref_latex_case() {
  local name="$1"
  local input="$2"
  local caption_count

  pandoc "${BASE_ARGS[@]}" \
    --filter=pandoc-crossref \
    --syntax-highlighting=idiomatic \
    --metadata listings=true \
    "$input" -t latex > "$LATEX_TMP"
  diff -u "$ROOT/src/tst/expected/${name}.tex" "$LATEX_TMP"
  if grep -q '\\begin{codelisting}' "$LATEX_TMP"; then
    echo "Unexpected codelisting wrapper in ${name}." >&2
    exit 1
  fi
  caption_count="$(grep -o 'caption=' "$LATEX_TMP" | wc -l | tr -d ' ')"
  if [[ "$caption_count" -ne 1 ]]; then
    echo "Expected exactly one lstlisting caption in ${name}, found ${caption_count}." >&2
    exit 1
  fi
  echo "Crossref LaTeX output matches golden file (${name})."
}

run_case "main" "$ROOT/doc/exp/main.md"
run_case "tikz" "$ROOT/doc/exp/tikz.md"
run_case "mark" "$ROOT/doc/exp/mark.md"
run_case "table-blank-row" "$ROOT/doc/exp/table-blank-row.md"

for file in "$ROOT/doc/exp/filters/"*.md; do
  [ -f "$file" ] || continue
  base="$(basename "$file")"
  name="filters-${base%.md}"
  run_case "$name" "$file"
done

run_crossref_latex_case "filters-include-code-crossref" "$ROOT/doc/exp/filters/include-code.md"
