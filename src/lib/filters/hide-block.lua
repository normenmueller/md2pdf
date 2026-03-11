-- hide-block.lua
-- Remove content enclosed by the markers
--   %% md2pdf-hide-start %%
--   %% md2pdf-hide-end %%
-- The markers are recognized even when they appear inline; they will be
-- isolated automatically before the hide logic runs.

local HIDE_START = "%% md2pdf-hide-start %%"
local HIDE_END = "%% md2pdf-hide-end %%"

local function normalize_text(text)
  text = text:gsub("^%s+", ""):gsub("%s+$", "")
  text = text:gsub("%s+", " ")
  return text
end

local function stringify_block(block)
  if block.t == "Para" or block.t == "Plain" then
    return normalize_text(pandoc.utils.stringify(block))
  end
  return nil
end

local function is_hide_start(block)
  local txt = stringify_block(block)
  return txt and txt == HIDE_START
end

local function is_hide_end(block)
  local txt = stringify_block(block)
  return txt and txt == HIDE_END
end

local function log_warning(msg)
  io.stderr:write("[md2pdf|hide] " .. msg .. "\n")
end

local function whitespace_token(t)
  return t == "Space" or t == "SoftBreak" or t == "LineBreak"
end

local function skip_whitespace(inlines, idx)
  while idx <= #inlines do
    local token = inlines[idx]
    if whitespace_token(token.t) then
      idx = idx + 1
    else
      break
    end
  end
  return idx
end

local function match_marker(inlines, idx)
  local first = inlines[idx]
  if not (first and first.t == "Str" and first.text == "%%") then
    return nil
  end

  local i = skip_whitespace(inlines, idx + 1)
  local marker = inlines[i]
  if not (marker and marker.t == "Str" and (marker.text == "md2pdf-hide-start" or marker.text == "md2pdf-hide-end")) then
    return nil
  end
  local marker_text = marker.text

  i = skip_whitespace(inlines, i + 1)
  local final_token = inlines[i]
  if not (final_token and final_token.t == "Str" and final_token.text == "%%") then
    return nil
  end

  i = skip_whitespace(inlines, i + 1)
  local consumed = i - idx
  return marker_text, consumed
end

local function make_marker_block(marker_text)
  return pandoc.Para({
    pandoc.Str("%%"),
    pandoc.Space(),
    pandoc.Str(marker_text),
    pandoc.Space(),
    pandoc.Str("%%")
  })
end

local function clone_para_like(block_type, inlines)
  if block_type == "Plain" then
    return pandoc.Plain(inlines)
  end
  return pandoc.Para(inlines)
end

local function explode_block(block)
  if block.t ~= "Para" and block.t ~= "Plain" then
    return pandoc.List({ block })
  end

  local parts = pandoc.List({})
  local buffer = pandoc.List({})
  local i = 1
  local inlines = block.content

  while i <= #inlines do
    local marker_text, consumed = match_marker(inlines, i)
    if marker_text then
      if #buffer > 0 then
        parts:insert(clone_para_like(block.t, buffer))
        buffer = pandoc.List({})
      end
      parts:insert(make_marker_block(marker_text))
      i = i + consumed
    else
      buffer:insert(inlines[i])
      i = i + 1
    end
  end

  if #buffer > 0 then
    parts:insert(clone_para_like(block.t, buffer))
  end

  if #parts == 0 then
    parts:insert(clone_para_like(block.t, buffer))
  end

  return parts
end

local function process_blocks(blocks)
  local result = pandoc.List({})
  local hide_depth = 0

  for _, block in ipairs(blocks) do
    local expanded = explode_block(block)
    for _, expanded_block in ipairs(expanded) do
      if is_hide_start(expanded_block) then
        hide_depth = hide_depth + 1
      elseif is_hide_end(expanded_block) then
        if hide_depth > 0 then
          hide_depth = hide_depth - 1
        else
          log_warning("Encountered 'md2pdf-hide-end' without matching start; ignoring.")
        end
      else
        if hide_depth == 0 then
          result:insert(process_block(expanded_block))
        end
      end
    end
  end

  if hide_depth > 0 then
    log_warning("Missing 'md2pdf-hide-end' marker; remaining hidden content discarded.")
  end

  return result
end

local function process_block_list(list)
  local processed = pandoc.List({})
  for _, blocks in ipairs(list) do
    processed:insert(process_blocks(blocks))
  end
  return processed
end

function process_block(block)
  if block.t == "BlockQuote" then
    block.content = process_blocks(block.content)
  elseif block.t == "Div" then
    block.content = process_blocks(block.content)
  elseif block.t == "BulletList" then
    block.content = process_block_list(block.content)
  elseif block.t == "OrderedList" then
    block.content = process_block_list(block.content)
  elseif block.t == "DefinitionList" then
    for _, item in ipairs(block.content) do
      local definitions = item[2]
      for i, def_blocks in ipairs(definitions) do
        definitions[i] = process_blocks(def_blocks)
      end
    end
  end
  return block
end

function Pandoc(doc)
  doc.blocks = process_blocks(doc.blocks)
  return doc
end
