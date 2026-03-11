-- tikz-trf.lua
-- Transform TikZ code fences into raw LaTeX TikZ blocks.

if FORMAT ~= "latex" then
  return {}
end

local state = {
  packages = {},
  libraries = {},
  package_order = {},
  library_order = {}
}

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

local function add_unique(set, order, value)
  if value == "" then
    return
  end
  if not set[value] then
    set[value] = true
    table.insert(order, value)
  end
end

local function split_lines(text)
  local lines = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    table.insert(lines, line)
  end
  return lines
end

local function class_value(classes, key)
  if not classes then
    return nil
  end
  if type(classes) == "string" then
    classes = { classes }
  end
  for _, cls in ipairs(classes) do
    local value = cls:match("^" .. key .. "=(.+)$")
    if value and value ~= "" then
      return value
    end
  end
  return nil
end

local function attr_value(attr, key)
  if not attr or not attr.attributes then
    return nil
  end
  local value = attr.attributes[key]
  if value and value ~= "" then
    return value
  end
  return nil
end

local function extract_dimensions(attr)
  local scale = attr_value(attr, "scale")
  local width = attr_value(attr, "width")
  local height = attr_value(attr, "height")

  local classes = nil
  if attr and attr.classes then
    classes = attr.classes
  elseif attr and attr.class then
    classes = attr.class
  end

  if classes then
    scale = scale or class_value(classes, "scale")
    width = width or class_value(classes, "width")
    height = height or class_value(classes, "height")
  end

  return scale, width, height
end

local function extract_figure_attrs(attr)
  local caption = attr_value(attr, "caption")
  local label = attr_value(attr, "label")
  local placement = attr_value(attr, "placement")
  return caption, label, placement
end

local function apply_scale(lines, scale)
  if not scale then
    return lines, true
  end

  for i, line in ipairs(lines) do
    if line:match("\\begin%s*{tikzpicture}") then
      if line:match("\\begin%s*{tikzpicture}%s*%[") then
        line = line:gsub("^(%s*\\begin%s*{tikzpicture}%s*)%[(.-)%](%s*)$", function(prefix, inner, suffix)
          if inner:match("scale%s*=") then
            return prefix .. "[" .. inner .. "]" .. suffix
          end
          if inner == "" then
            return prefix .. "[scale=" .. scale .. "]" .. suffix
          end
          return prefix .. "[" .. inner .. ",scale=" .. scale .. "]" .. suffix
        end, 1)
      else
        line = line:gsub("^(%s*\\begin%s*{tikzpicture}%s*)", "%1[scale=" .. scale .. "]")
      end
      lines[i] = line
      return lines, true
    end
  end

  return lines, false
end

local function wrap_resizebox(body, width, height)
  if not width and not height then
    return body
  end
  local w = width or "!"
  local h = height or "!"
  return "\\resizebox{" .. w .. "}{" .. h .. "}{\n" .. body .. "\n}"
end

local function collect_preamble(line)
  local trimmed = trim(line)
  if trimmed:match("^\\usepackage%s*") then
    add_unique(state.packages, state.package_order, trimmed)
    return true
  end
  if trimmed:match("^\\usetikzlibrary%s*") then
    add_unique(state.libraries, state.library_order, trimmed)
    return true
  end
  if trimmed:match("^\\begin%s*{document}") then
    return true
  end
  if trimmed:match("^\\end%s*{document}") then
    return true
  end
  return false
end

local function has_tikzpicture(lines)
  for _, line in ipairs(lines) do
    if line:match("\\begin%s*{tikzpicture}") then
      return true
    end
  end
  return false
end

local function transform_block(el)
  local lines = split_lines(element_text(el))
  local body_lines = {}

  for _, line in ipairs(lines) do
    if not collect_preamble(line) then
      table.insert(body_lines, line)
    end
  end

  if not has_tikzpicture(body_lines) then
    io.stderr:write("[md2pdf|tikz] No \\begin{tikzpicture} found; leaving block unchanged.\n")
    return nil
  end

  local scale, width, height = extract_dimensions(el.attr or {})
  local caption, label, placement = extract_figure_attrs(el.attr or {})

  body_lines = apply_scale(body_lines, scale)
  local tikz_body = table.concat(body_lines, "\n")
  tikz_body = wrap_resizebox(tikz_body, width, height)

  local rendered = tikz_body
  if caption and caption ~= "" then
    local placement_opt = ""
    if placement and placement ~= "" then
      placement_opt = "[" .. placement .. "]"
    end
    local fig_lines = {
      "\\begin{figure}" .. placement_opt,
      "\\centering",
      rendered,
      "\\caption{" .. caption .. "}"
    }
    if label and label ~= "" then
      table.insert(fig_lines, "\\label{" .. label .. "}")
    end
    table.insert(fig_lines, "\\end{figure}")
    rendered = table.concat(fig_lines, "\n")
  end

  local blocks = pandoc.List({})
  blocks:insert(pandoc.RawBlock("latex", "\\par\\medskip"))
  blocks:insert(pandoc.RawBlock("latex", rendered))
  blocks:insert(pandoc.RawBlock("latex", "\\par\\medskip"))
  return blocks
end

function CodeBlock(el)
  local classes = nil
  if el.attr and el.attr.classes then
    classes = el.attr.classes
  elseif el.classes then
    classes = el.classes
  end

  if not classes then
    return nil
  end

  local is_tikz = false
  for _, cls in ipairs(classes) do
    if cls == "tikz" then
      is_tikz = true
      break
    end
  end
  if not is_tikz then
    return nil
  end

  return transform_block(el)
end

local function ensure_meta_list(meta, key)
  local existing = meta[key]
  if not existing then
    local list = pandoc.MetaList({})
    meta[key] = list
    return list
  end
  if existing.t == "MetaList" then
    return existing
  end
  local list = pandoc.MetaList({})
  list:insert(existing)
  meta[key] = list
  return list
end

local function collect_existing_header_includes(meta_list)
  local existing = {}
  for _, entry in ipairs(meta_list) do
    if entry.t == "MetaBlocks" then
      for _, block in ipairs(entry) do
        if block.t == "RawBlock" and block.format == "latex" then
          existing[element_text(block)] = true
        end
      end
    end
  end
  return existing
end

local function append_header_includes(meta, lines)
  if #lines == 0 then
    return
  end
  local meta_list = ensure_meta_list(meta, "header-includes")
  local existing = collect_existing_header_includes(meta_list)

  for _, line in ipairs(lines) do
    if not existing[line] then
      local raw = pandoc.RawBlock("latex", line)
      meta_list:insert(pandoc.MetaBlocks({ raw }))
      existing[line] = true
    end
  end
end

function Pandoc(doc)
  append_header_includes(doc.meta, state.package_order)
  append_header_includes(doc.meta, state.library_order)
  return doc
end
