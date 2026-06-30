-- listing-caption-wrap.lua
-- Convert captioned lst: code blocks into pandoc-crossref listing Divs when
-- LaTeX listings mode is enabled. This preserves the idiomatic/listings backend
-- while avoiding duplicate caption options in generated lstlisting blocks.

if FORMAT ~= "latex" then
  return {}
end

local List = require "pandoc.List"

local function meta_bool(value)
  if value == true then
    return true
  end
  return value and value.t == "MetaBool" and value.c == true
end

local function starts_with(value, prefix)
  return value:sub(1, #prefix) == prefix
end

local function has_class(classes, name)
  for _, class in ipairs(classes) do
    if class == name then
      return true
    end
  end
  return false
end

local function append_unique_class(classes, class)
  if class == "" or has_class(classes, class) then
    return
  end
  classes:insert(class)
end

local function caption_to_para(caption)
  local parsed = pandoc.read(caption, "markdown")
  local first = parsed.blocks[1]
  if first and (first.t == "Para" or first.t == "Plain") then
    return pandoc.Para(first.content)
  end
  return pandoc.Para({ pandoc.Str(caption) })
end

local function wrap_code_block(el)
  local attr = el.attr or pandoc.Attr()
  local caption = attr.attributes.caption
  if not caption or caption == "" or not starts_with(attr.identifier, "lst:") then
    return nil
  end

  local code_classes = List()
  for _, class in ipairs(attr.classes) do
    append_unique_class(code_classes, class)
  end

  local code_attributes = {}
  for key, value in pairs(attr.attributes) do
    if key ~= "caption" then
      code_attributes[key] = value
    end
  end

  local div_classes = List({ "listing" })
  for _, class in ipairs(code_classes) do
    append_unique_class(div_classes, class)
  end

  local code = pandoc.CodeBlock(el.text, pandoc.Attr("", code_classes, code_attributes))
  return pandoc.Div(
    { caption_to_para(caption), code },
    pandoc.Attr(attr.identifier, div_classes, {})
  )
end

function Pandoc(doc)
  if not meta_bool(doc.meta.listings) then
    return nil
  end

  return doc:walk({
    CodeBlock = wrap_code_block
  })
end
