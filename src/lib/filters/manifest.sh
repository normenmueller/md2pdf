#!/usr/bin/env bash

# Shared filter order for runtime and test execution.
MD2PDF_FILTER_FILES=(
  hide-block.lua
  center-block.lua
  strip-obsidian-anchors.lua
  html-mark.lua
  tikz-trf.lua
  embed-md.lua
  obsidian-callout.lua
  links-normalize-internal.lua
  markdown-table-auto-width.lua
)
