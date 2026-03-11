-- html-mark.lua
-- Convert HTML <mark style="background: #RRGGBB;">...</mark> to LaTeX color boxes.

if FORMAT ~= "latex" then
  return {}
end

local DEFAULT_MARK_COLOR = "FFFF00"

local function element_text(el)
  if el.text then
    return el.text
  end
  if el.c and el.c[2] then
    return el.c[2]
  end
  return ""
end

local function trim(text)
  return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function parse_style_color(style)
  if not style then
    return nil
  end
  local hex = style:match("background%-color%s*:%s*#([0-9a-fA-F]+)")
    or style:match("background%s*:%s*#([0-9a-fA-F]+)")
  if not hex then
    return nil
  end
  if #hex == 8 then
    hex = hex:sub(1, 6)
  elseif #hex ~= 6 then
    return nil
  end
  return hex:upper()
end

local function parse_mark_color(raw)
  local style = raw:match('style%s*=%s*"(.-)"')
    or raw:match("style%s*=%s*'(.-)'")
  return parse_style_color(style)
end

local function is_mark_open(raw)
  local lower = raw:lower()
  return lower:match("^<mark") and not lower:match("^</mark")
end

local function is_mark_close(raw)
  return raw:lower():match("^</mark") ~= nil
end

local function render_inlines(inlines)
  local doc = pandoc.Pandoc({ pandoc.Plain(inlines) })
  local latex = pandoc.write(doc, "latex")
  return trim(latex)
end

local function wrap_mark(color, inlines)
  local content = render_inlines(inlines)
  if content == "" then
    return nil
  end
  local hex = color
  if not hex or hex == "" then
    hex = DEFAULT_MARK_COLOR
  end
  return pandoc.RawInline("latex", "\\mdPdfMark{" .. hex .. "}{" .. content .. "}")
end

local function append_all(target, items)
  for _, item in ipairs(items) do
    target:insert(item)
  end
end

local function process_inlines(inlines)
  local result = pandoc.List({})
  local stack = {}

  for _, inline in ipairs(inlines) do
    if inline.t == "RawInline" then
      local format = inline.format or (inline.c and inline.c[1])
      local raw = element_text(inline)
      if format == "html" and raw ~= "" then
        if is_mark_open(raw) then
          local hex = parse_mark_color(raw)
          table.insert(stack, { color = hex, content = pandoc.List({}) })
          goto continue
        end
        if is_mark_close(raw) then
          if #stack == 0 then
            goto continue
          end
          local current = table.remove(stack)
          local wrapped = wrap_mark(current.color, current.content)
          if wrapped then
            if #stack > 0 then
              stack[#stack].content:insert(wrapped)
            else
              result:insert(wrapped)
            end
          end
          goto continue
        end
      end
    end

    if #stack > 0 then
      stack[#stack].content:insert(inline)
    else
      result:insert(inline)
    end

    ::continue::
  end

  if #stack > 0 then
    io.stderr:write("[md2pdf|mark] Unclosed <mark> tag; emitting content without highlight.\n")
    for _, entry in ipairs(stack) do
      append_all(result, entry.content)
    end
  end

  return result
end


function Inlines(inlines)
  return process_inlines(inlines)
end

function Pandoc(doc)
  return doc
end
