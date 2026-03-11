-- center-block.lua
-- Convert raw HTML <center>...</center> blocks into LaTeX center environments
-- so that Markdown inside the tags survives and renders centered in the PDF.

if FORMAT ~= "latex" then
  return {}
end

local function trim_lower(text)
  return text:gsub("^%s+", ""):gsub("%s+$", ""):lower()
end

local function is_center_start(block)
  if block.t ~= "RawBlock" then
    return false
  end
  if (block.format or block.c and block.c[1]) ~= "html" then
    return false
  end
  local text = block.text or block.c and block.c[2]
  if not text then
    return false
  end
  return trim_lower(text) == "<center>"
end

local function is_center_end(block)
  if block.t ~= "RawBlock" then
    return false
  end
  if (block.format or block.c and block.c[1]) ~= "html" then
    return false
  end
  local text = block.text or block.c and block.c[2]
  if not text then
    return false
  end
  return trim_lower(text) == "</center>"
end

local function wrap_center(blocks)
  local wrapped = pandoc.List({})
  wrapped:insert(pandoc.RawBlock("latex", "\\begin{center}"))
  for _, b in ipairs(blocks) do
    wrapped:insert(b)
  end
  wrapped:insert(pandoc.RawBlock("latex", "\\end{center}"))
  return wrapped
end

local function append_all(target, items)
  for _, item in ipairs(items) do
    target:insert(item)
  end
end

local function process_blocks(blocks)
  local result = pandoc.List({})
  local stack = {}

  for _, block in ipairs(blocks) do
    if is_center_start(block) then
      table.insert(stack, { marker = block, content = pandoc.List({}) })
    elseif is_center_end(block) then
      if #stack == 0 then
        io.stderr:write("[md2pdf|center] Found '</center>' without matching '<center>'.\n")
        result:insert(block)
      else
        local current = table.remove(stack)
        local centered = wrap_center(current.content)
        if #stack > 0 then
          append_all(stack[#stack].content, centered)
        else
          append_all(result, centered)
        end
      end
    else
      if #stack > 0 then
        stack[#stack].content:insert(block)
      else
        result:insert(block)
      end
    end
  end

  if #stack > 0 then
    io.stderr:write("[md2pdf|center] Missing closing '</center>' tag; emitting content literally.\n")
    for _, entry in ipairs(stack) do
      result:insert(entry.marker)
      append_all(result, entry.content)
    end
  end

  return result
end

function Pandoc(doc)
  doc.blocks = process_blocks(doc.blocks)
  return doc
end
