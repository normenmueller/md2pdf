-- embed-md.lua
-- Inline Markdown embeds (Obsidian style) that replace image-style links to
-- *.md files with the parsed blocks of that file. External links remain
-- untouched; plain links keep behaving like normal hyperlinks.

local List = require "pandoc.List"

------------------------------------------------------------
-- Configuration and state
------------------------------------------------------------

local CALLOUT_EMBED_ATTR = "data-md2pdf-callout-embed"

local base_dir = "."
if PANDOC_STATE
   and PANDOC_STATE.input_files
   and #PANDOC_STATE.input_files > 0 then
  base_dir = pandoc.path.directory(PANDOC_STATE.input_files[1])
end

local current_heading_level = 0
local embed_usage_counts = {}
local active_embed_stack = {}
local active_embed_lookup = {}
local embed_max_depth = 16

local marker_filter = {}
local embed_filter = {}

------------------------------------------------------------
-- Utility helpers
------------------------------------------------------------

local function url_decode(str)
  return (str:gsub("%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end))
end

local function resolve_path(target)
  if not target or target == "" then
    return nil
  end

  local path = url_decode(target)

  if path:match("^[a-zA-Z]+://") then
    return nil
  end

  if pandoc.path.is_absolute(path) then
    return pandoc.path.normalize(path)
  end

  return pandoc.path.normalize(pandoc.path.join({ base_dir, path }))
end

local function sanitize_identifier(text)
  local sanitized = text:lower()
  sanitized = sanitized:gsub("[^%w]+", "-")
  sanitized = sanitized:gsub("^-+", ""):gsub("-+$", "")
  if sanitized == "" then
    sanitized = "embed"
  end
  return sanitized
end

local function build_id_prefix(fs_path, instance)
  local filename = pandoc.path.filename(fs_path)
  local stem = pandoc.path.split_extension(filename)
  local prefix = sanitize_identifier(stem)
  if instance and instance > 0 then
    prefix = prefix .. "-" .. tostring(instance)
  end
  return prefix
end

local function ensure_class(attr, class_name)
  local classes = attr.classes or List()
  if type(classes.insert) ~= "function" then
    classes = List(classes)
  end
  for _, existing in ipairs(classes) do
    if existing == class_name then
      attr.classes = classes
      return
    end
  end
  classes:insert(class_name)
  attr.classes = classes
end

local function adjust_embedded_blocks(blocks, shift, id_prefix, inside_callout)
  if (not shift or shift == 0) and (not id_prefix or id_prefix == "") and not inside_callout then
    return blocks
  end

  local walker = {
    Header = function(el)
      if shift and shift > 0 then
        local new_level = el.level + shift
        if new_level > 6 then
          new_level = 6
        end
        el.level = new_level
      end

      if id_prefix and id_prefix ~= "" then
        local current_id = el.attr and el.attr.identifier or ""
        if current_id ~= "" then
          current_id = id_prefix .. "-" .. current_id
        else
          local generated = sanitize_identifier(pandoc.utils.stringify(el.content))
          current_id = id_prefix .. "-" .. generated
        end
        if el.attr then
          el.attr.identifier = current_id
        else
          el.attr = pandoc.Attr(current_id)
        end
      end

      if inside_callout then
        local attr = el.attr or pandoc.Attr()
        ensure_class(attr, "unnumbered")
        ensure_class(attr, "unlisted")
        el.attr = attr
      end

      return el
    end
  }

  local div = pandoc.Div(blocks)
  local adjusted_div = pandoc.walk_block(div, walker)
  return adjusted_div.content
end

local function is_whitespace_only(inlines)
  if not inlines or #inlines == 0 then
    return true
  end
  for _, inline in ipairs(inlines) do
    if inline.t ~= "Space" and inline.t ~= "SoftBreak" then
      return false
    end
  end
  return true
end

local function find_md_index_and_target(inlines)
  if not inlines then
    return nil, nil, nil
  end

  for i, inline in ipairs(inlines) do
    if inline.t == "Image" then
      local target = inline.src
      if target and target:match("%.md$") then
        return i, target, inline
      end
    end
  end

  return nil, nil, nil
end

local function inline_requested_shift(inline)
  if inline and inline.attr and inline.attr.attributes then
    local attrs = inline.attr.attributes
    local value = attrs["shift-headings"] or attrs["shift-level-by"] or attrs["embed-shift"]
    if value then
      local num = tonumber(value)
      if num then
        return num
      end
    end
  end
  return nil
end

local function inline_marked_as_callout(inline)
  return inline
    and inline.attr
    and inline.attr.attributes
    and inline.attr.attributes[CALLOUT_EMBED_ATTR] == "true"
end

local function with_embed_scope(fs_path, callback)
  if active_embed_lookup[fs_path] then
    io.stderr:write("embed-md: cycle detected for " .. fs_path .. "\n")
    return nil
  end

  if #active_embed_stack >= embed_max_depth then
    io.stderr:write("embed-md: maximum embed depth reached at " .. fs_path .. "\n")
    return nil
  end

  active_embed_lookup[fs_path] = true
  table.insert(active_embed_stack, fs_path)

  local ok, result = pcall(callback)

  active_embed_lookup[fs_path] = nil
  table.remove(active_embed_stack)

  if not ok then
    io.stderr:write("embed-md: expansion failed for " .. fs_path .. "\n")
    return nil
  end

  return result
end

------------------------------------------------------------
-- Embed expansion
------------------------------------------------------------

local function expand_embed_in_inlines(inlines, context_shift, inside_callout)
  local idx, target, inline = find_md_index_and_target(inlines)
  if not target then
    return nil
  end

  local inline_inside_callout = inline_marked_as_callout(inline)
  if not inside_callout and inline_inside_callout then
    inside_callout = true
  end

  local fs_path = resolve_path(target)
  if not fs_path then
    io.stderr:write("embed-md: could not resolve path for target " .. tostring(target) .. "\n")
    return nil
  end

  return with_embed_scope(fs_path, function()
    local fh = io.open(fs_path, "r")
    if not fh then
      io.stderr:write("embed-md: could not open " .. fs_path .. "\n")
      return nil
    end

    local content = fh:read("*a")
    fh:close()

    local ok, embedded_doc = pcall(pandoc.read, content, "markdown")
    if not ok or not embedded_doc then
      io.stderr:write("embed-md: pandoc.read failed for " .. fs_path .. "\n")
      return nil
    end

    local shift = inline_requested_shift(inline)
    if shift == nil then
      if inside_callout then
        shift = 0
      else
        shift = context_shift or 0
      end
    end

    local usage = (embed_usage_counts[fs_path] or 0) + 1
    embed_usage_counts[fs_path] = usage
    local id_prefix = build_id_prefix(fs_path, usage)

    local embedded_blocks = adjust_embedded_blocks(
      embedded_doc.blocks,
      shift,
      id_prefix,
      inside_callout
    )

    local prefix = {}
    for i = 1, idx - 1 do
      prefix[#prefix + 1] = inlines[i]
    end

    local suffix = {}
    for i = idx + 1, #inlines do
      suffix[#suffix + 1] = inlines[i]
    end

    local blocks = {}

    if not is_whitespace_only(prefix) then
      blocks[#blocks + 1] = pandoc.Para(prefix)
    end

    for _, b in ipairs(embedded_blocks) do
      blocks[#blocks + 1] = b
    end

    if not is_whitespace_only(suffix) then
      blocks[#blocks + 1] = pandoc.Para(suffix)
    end

    return blocks
  end)
end

------------------------------------------------------------
-- Embed filter: Para / Plain / Figure / Header
------------------------------------------------------------

function embed_filter.Para(el)
  local blocks = expand_embed_in_inlines(el.content, current_heading_level, false)
  if blocks then
    return blocks
  end
  return nil
end

function embed_filter.Plain(el)
  local blocks = expand_embed_in_inlines(el.content, current_heading_level, false)
  if blocks then
    return blocks
  end
  return nil
end

function embed_filter.Figure(el)
  if not el.content then
    return nil
  end

  local new_blocks = {}
  local changed = false

  for _, block in ipairs(el.content) do
    if block.t == "Para" or block.t == "Plain" then
      local expanded = expand_embed_in_inlines(block.content, current_heading_level, false)
      if expanded then
        changed = true
        for _, b in ipairs(expanded) do
          new_blocks[#new_blocks + 1] = b
        end
      else
        new_blocks[#new_blocks + 1] = block
      end
    else
      changed = true
      new_blocks[#new_blocks + 1] = block
    end
  end

  if changed then
    return new_blocks
  end

  return nil
end

function embed_filter.Header(el)
  current_heading_level = el.level or 0
  return nil
end

function embed_filter.Meta(meta)
  local max_depth = meta["embed-max-depth"]
  if max_depth then
    local parsed = tonumber(pandoc.utils.stringify(max_depth))
    if parsed and parsed >= 1 then
      embed_max_depth = math.floor(parsed)
    end
  end
  return nil
end

------------------------------------------------------------
-- Marker filter: mark embeds located inside callouts
------------------------------------------------------------

local function is_obsidian_callout(el)
  if not el.content or #el.content == 0 then
    return false
  end

  local first = el.content[1]
  if first.t ~= "Para" then
    return false
  end

  local inlines = first.content
  if not inlines or #inlines == 0 then
    return false
  end

  local i = 1
  while i <= #inlines and inlines[i].t == "Space" do
    i = i + 1
  end
  if i > #inlines or inlines[i].t ~= "Str" then
    return false
  end

  local marker_text = inlines[i].text
  if not marker_text then
    return false
  end

  local tag = marker_text:match("^%[!(.-)%]")
  if not tag then
    return false
  end

  return true
end

local function mark_callout_image(inline)
  if inline and inline.t == "Image" then
    local target = inline.src
    if target and target:match("%.md$") then
      local attr = inline.attr or pandoc.Attr()
      attr.attributes = attr.attributes or {}
      attr.attributes[CALLOUT_EMBED_ATTR] = "true"
      inline.attr = attr
    end
  end
end

local function mark_callout_embeds(el)
  local walker = {
    Para = function(par)
      if par.content then
        for _, inline in ipairs(par.content) do
          mark_callout_image(inline)
        end
      end
      return par
    end,
    Plain = function(pl)
      if pl.content then
        for _, inline in ipairs(pl.content) do
          mark_callout_image(inline)
        end
      end
      return pl
    end
  }

  return pandoc.walk_block(el, walker)
end

function marker_filter.BlockQuote(el)
  if is_obsidian_callout(el) then
    return mark_callout_embeds(el)
  end
  return nil
end

return { marker_filter, embed_filter }
