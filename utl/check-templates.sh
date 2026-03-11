#!/usr/bin/env bash
set -euo pipefail

templates_dir="${1:-src/lib/templates}"

if [[ ! -d "$templates_dir" ]]; then
  echo "Missing templates directory: $templates_dir" >&2
  exit 1
fi

status=0

for tex in "$templates_dir"/*.tex; do
  [[ -f "$tex" ]] || continue
  base="${tex%.tex}"
  icl="${base}.icl"
  if [[ ! -f "$icl" ]]; then
    echo "Missing paired include file for template: $tex" >&2
    status=1
  fi
done

if [[ ! -f "$templates_dir/default.tex" || ! -f "$templates_dir/default.icl" ]]; then
  echo "Missing default template pair in $templates_dir" >&2
  status=1
fi

exit "$status"
