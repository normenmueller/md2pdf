#!/usr/bin/env bash
# Regression tests for `md2pdf --closure-manifest` (issue #5).
#
# Each case runs against an isolated, disposable datadir (a copy of
# src/lib/templates + src/lib/filters) selected via MD2PDF_DATADIR, so
# tests never mutate the real repository tree.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/src/app/md2pdf.sh"

WORKDIR="$(mktemp -d)"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

fresh_datadir() {
    local dir="$1"
    rm -rf "$dir"
    mkdir -p "$dir"
    cp -R "$ROOT/src/lib/templates" "$dir/templates"
    cp -R "$ROOT/src/lib/filters" "$dir/filters"
}

manifest_of() {
    local datadir="$1"; shift
    MD2PDF_DATADIR="$datadir" "$SCRIPT" --closure-manifest "$@"
}

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

# ------------------------------------------------------------------
# Case 1: unchanged inputs produce byte-identical stdout.
# ------------------------------------------------------------------
DATADIR_A="$WORKDIR/datadir-a"
fresh_datadir "$DATADIR_A"

OUT1="$(manifest_of "$DATADIR_A")"
OUT2="$(manifest_of "$DATADIR_A")"
[[ "$OUT1" == "$OUT2" ]] || fail "identical effective inputs produced different manifests"
echo "$OUT1" | python3 -m json.tool >/dev/null || fail "manifest is not valid JSON"
echo "PASS: unchanged inputs -> byte-identical, valid JSON."

# ------------------------------------------------------------------
# Case 2: drifted filter content changes the declared identity.
# ------------------------------------------------------------------
DATADIR_B="$WORKDIR/datadir-b"
fresh_datadir "$DATADIR_B"

BEFORE="$(manifest_of "$DATADIR_B")"
printf '\n-- drift marker\n' >> "$DATADIR_B/filters/hide-block.lua"
AFTER="$(manifest_of "$DATADIR_B")"
[[ "$BEFORE" != "$AFTER" ]] || fail "editing an active filter did not change the manifest"
echo "PASS: drifted active filter -> changed identity."

# ------------------------------------------------------------------
# Case 3: reordering active filters changes the declared identity.
# ------------------------------------------------------------------
DATADIR_C="$WORKDIR/datadir-c"
fresh_datadir "$DATADIR_C"

BEFORE="$(manifest_of "$DATADIR_C")"
python3 - "$DATADIR_C/filters/manifest.sh" <<'PY'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
content = content.replace(
    "hide-block.lua\n  center-block.lua",
    "center-block.lua\n  hide-block.lua",
    1,
)
with open(path, "w") as f:
    f.write(content)
PY
AFTER="$(manifest_of "$DATADIR_C")"
[[ "$BEFORE" != "$AFTER" ]] || fail "reordering active filters did not change the manifest"
echo "PASS: reordered active filters -> changed identity."

# ------------------------------------------------------------------
# Case 4: a missing active filter fails closed (non-zero exit, empty
# stdout, actionable stderr diagnostic).
# ------------------------------------------------------------------
DATADIR_D="$WORKDIR/datadir-d"
fresh_datadir "$DATADIR_D"
rm -f "$DATADIR_D/filters/hide-block.lua"

set +e
STDOUT_D="$(manifest_of "$DATADIR_D" 2>"$WORKDIR/stderr-d.txt")"
STATUS_D=$?
set -e
[[ "$STATUS_D" -ne 0 ]] || fail "missing active filter did not produce a non-zero exit code"
[[ -z "$STDOUT_D" ]] || fail "missing active filter still produced stdout output"
grep -q "hide-block.lua" "$WORKDIR/stderr-d.txt" || fail "stderr diagnostic does not name the missing filter"
echo "PASS: missing active filter -> fail closed with actionable stderr diagnostic."

# ------------------------------------------------------------------
# Case 5: selecting a different bundled template changes template and
# header-include identity, independent of the filter pipeline.
# ------------------------------------------------------------------
DATADIR_E="$WORKDIR/datadir-e"
fresh_datadir "$DATADIR_E"

DEFAULT_OUT="$(manifest_of "$DATADIR_E")"
CUSTOM_OUT="$(manifest_of "$DATADIR_E" --template article-modern)"
[[ "$DEFAULT_OUT" != "$CUSTOM_OUT" ]] || fail "custom --template did not change the manifest"
echo "$CUSTOM_OUT" | grep -q '"path": "templates/article-modern.tex"' \
    || fail "custom template path not reflected in manifest"
echo "PASS: custom --template -> changed template/header-include identity."

echo "All closure-manifest cases passed."
