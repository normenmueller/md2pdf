-- links-normalize-internal.lua
-- Keep only external http(s) links; turn all others into plain text.
-- Additionally, drop or convert leftover Images pointing to *.md
-- (safety net if an embed was not expanded).

if FORMAT ~= "latex" then
  return {}
end

local List = require "pandoc.List"

-- Remove Obsidian-style wiki links ([[target]] / [[target|alias]])
-- but leave embeds ![[...]] untouched.
local function strip_wikilinks_from_inlines(inlines)
  local result = List()
  local inside = false
  local alias_mode = false
  local target_inlines = List()
  local alias_inlines = List()

  local function reset()
    inside = false
    alias_mode = false
    target_inlines = List()
    alias_inlines = List()
  end

  local function insert_inlines(dst, src)
    for _, inline in ipairs(src) do
      dst:insert(inline)
    end
  end

  local function append_to_current(inline)
    local dst = alias_mode and alias_inlines or target_inlines
    dst:insert(inline)
  end

  local function append_text_chunk(text)
    if text and text ~= "" then
      append_to_current(pandoc.Str(text))
    end
  end

  local function append_space(kind)
    if kind == "Space" then
      append_to_current(pandoc.Space())
    elseif kind == "SoftBreak" then
      append_to_current(pandoc.SoftBreak())
    end
  end

  local function flush_current()
    local source
    if alias_mode and #alias_inlines > 0 then
      source = alias_inlines
    else
      source = target_inlines
    end
    insert_inlines(result, source)
    reset()
  end

  local function handle_inside_str(text)
    local rest = text
    while rest ~= "" do
      local close_pos = rest:find("%]%]")
      local pipe_pos = (not alias_mode) and rest:find("|") or nil

      if close_pos and (not pipe_pos or close_pos < pipe_pos) then
        local before = rest:sub(1, close_pos - 1)
        append_text_chunk(before)
        rest = rest:sub(close_pos + 2)
        flush_current()
        return rest
      elseif pipe_pos then
        local before = rest:sub(1, pipe_pos - 1)
        append_text_chunk(before)
        alias_mode = true
        rest = rest:sub(pipe_pos + 1)
      else
        append_text_chunk(rest)
        return ""
      end
    end
    return ""
  end

  local function handle_outside_str(text)
    local rest = text
    while rest ~= "" do
      local start_pos = rest:find("%[%[")
      if start_pos then
        local preceding_char = start_pos > 1 and rest:sub(start_pos - 1, start_pos - 1) or nil
        local before
        if preceding_char == "!" then
          before = rest:sub(1, start_pos - 2)
        else
          before = rest:sub(1, start_pos - 1)
        end
        if before ~= "" then
          result:insert(pandoc.Str(before))
        end
        inside = true
        alias_mode = false
        target_inlines = List()
        alias_inlines = List()
        rest = handle_inside_str(rest:sub(start_pos + 2))
      else
        if rest ~= "" then
          result:insert(pandoc.Str(rest))
        end
        return
      end
    end
  end

  for _, inline in ipairs(inlines) do
    if inside then
      if inline.t == "Str" then
        local leftover = handle_inside_str(inline.text)
        if leftover ~= "" then
          handle_outside_str(leftover)
        end
      elseif inline.t == "Space" then
        append_space("Space")
      elseif inline.t == "SoftBreak" then
        append_space("SoftBreak")
      else
        append_text_chunk(pandoc.utils.stringify(inline))
      end
    else
      if inline.t == "Str" then
        handle_outside_str(inline.text)
      else
        result:insert(inline)
      end
    end
  end

  if inside then
    local fallback = (alias_mode and #alias_inlines > 0) and alias_inlines or target_inlines
    insert_inlines(result, fallback)
  end

  return result
end

function Inlines(inlines)
  return strip_wikilinks_from_inlines(inlines)
end

-- Handle normal links
function Link(el)
  local target = el.target or ""

  -- keep external http(s) links
  if target:match("^https?://") then
    return el
  end

  -- everything else (anchors, relative paths, file links, etc.)
  -- -> drop link, keep visible text/content
  return el.content
end

-- Safety: handle images that still point to *.md
function Image(el)
  local target = el.src or el.target or ""

  if target:match("%.md$") then
    -- If there is a caption, keep it as plain text,
    -- otherwise remove the image completely.
    if el.caption and #el.caption > 0 then
      return el.caption
    else
      return {}
    end
  end

  -- all other images unchanged
  return el
end
