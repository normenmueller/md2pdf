-- obsidian-callout.lua
-- Convert Obsidian-style callouts in Markdown to LaTeX tcolorbox environments.
-- - works with nested callouts
-- - tags case-insensitive: [!note], [!NOTE], [!Note], ...
-- - supports Obsidian fold markers [!note]- / [!note]+
-- - optional title (on first line) and optional body (subsequent lines)
-- - normal blockquotes no change

if FORMAT ~= "latex" then
  return {}
end

-- global theme switch: "color" (default) or "gray"
local callout_theme = "color"

-- mono style for all callouts in gray mode
--local MONO_STYLE = "colback=gray!5!white,colframe=gray!60!black"
local MONO_STYLE = "colback=gray!5!white,colframe=gray!60!black,left=3mm,boxed title style={left=1mm}"


-- Styles for callout tags (all lowercase)
local callout_styles = {
  tldr       = "colback=ocGryBack,colframe=ocGryFrame,coltitle=ocGryTitle,left=3mm,boxed title style={left=1mm}",
  summary    = "colback=ocGryBack,colframe=ocGryFrame,coltitle=ocGryTitle,left=3mm,boxed title style={left=1mm}",
  abstract   = "colback=ocGryBack,colframe=ocGryFrame,coltitle=ocGryTitle,left=3mm,boxed title style={left=1mm}",

  note       = "colback=ocGryBack,colframe=ocGryFrame,coltitle=ocGryTitle,left=3mm,boxed title style={left=1mm}",

  info       = "colback=ocGryBack,colframe=ocGryFrame,coltitle=ocGryTitle,left=3mm,boxed title style={left=1mm}",

  tip        = "colback=ocYelBack,colframe=ocYelFrame,coltitle=ocYelTitle,left=3mm,boxed title style={left=1mm}",
  hint       = "colback=ocYelBack,colframe=ocYelFrame,coltitle=ocYelTitle,left=3mm,boxed title style={left=1mm}",
  important  = "colback=ocYelBack,colframe=ocYelFrame,coltitle=ocYelTitle,left=3mm,boxed title style={left=1mm}",

  faq        = "colback=gray!10!white,colframe=gray!40!black,colbacktitle=gray!15!white,coltitle=gray!20!black,left=3mm,boxed title style={left=1mm}",
  help       = "colback=gray!10!white,colframe=gray!40!black,colbacktitle=gray!15!white,coltitle=gray!20!black,left=3mm,boxed title style={left=1mm}",

  question   = "colback=gray!10!white,colframe=gray!40!black,colbacktitle=gray!15!white,coltitle=gray!20!black,left=3mm,boxed title style={left=1mm}",

  quote      = "colback=gray!5!white,colframe=gray!60!black,left=3mm,boxed title style={left=1mm}",
  cite       = "colback=gray!5!white,colframe=gray!60!black,left=3mm,boxed title style={left=1mm}",

  todo       = "colback=yellow!5!white,colframe=yellow!50!black,left=3mm,boxed title style={left=1mm}",

  success    = "colback=ocGreBack,colframe=ocGreFrame,coltitle=ocGreTitle,left=3mm,boxed title style={left=1mm}",
  check      = "colback=ocGreBack,colframe=ocGreFrame,coltitle=ocGreTitle,left=3mm,boxed title style={left=1mm}",
  done       = "colback=ocGreBack,colframe=ocGreFrame,coltitle=ocGreTitle,left=3mm,boxed title style={left=1mm}",

  fail       = "colback=ocRedBack,colframe=ocRedFrame,coltitle=ocRedTitle,left=3mm,boxed title style={left=1mm}",
  failure    = "colback=ocRedBack,colframe=ocRedFrame,coltitle=ocRedTitle,left=3mm,boxed title style={left=1mm}",
  missing    = "colback=ocRedBack,colframe=ocRedFrame,coltitle=ocRedTitle,left=3mm,boxed title style={left=1mm}",

  warning    = "colback=ocOrgBack,colframe=ocOrgFrame,coltitle=ocOrgTitle,left=3mm,boxed title style={left=1mm}",
  caution    = "colback=ocOrgBack,colframe=ocOrgFrame,coltitle=ocOrgTitle,left=3mm,boxed title style={left=1mm}",
  attention  = "colback=ocOrgBack,colframe=ocOrgFrame,coltitle=ocOrgTitle,left=3mm,boxed title style={left=1mm}",

  bug        = "colback=ocRed2Back,colframe=ocRed2Frame,coltitle=ocRed2Title,left=3mm,boxed title style={left=1mm}",
  error      = "colback=ocRed2Back,colframe=ocRed2Frame,coltitle=ocRed2Title,left=3mm,boxed title style={left=1mm}",
  danger     = "colback=ocRed2Back,colframe=ocRed2Frame,coltitle=ocRed2Title,left=3mm,boxed title style={left=1mm}",

  definition = "colback=ocPinBack,colframe=ocPinFrame,coltitle=ocPinTitle,left=3mm,boxed title style={left=1mm}",

  terminus   = "colback=ocLavBack,colframe=ocLavFrame,coltitle=ocLavTitle,left=3mm,boxed title style={left=1mm}",

  addendum   = "colback=ocBluBack,colframe=ocBluFrame,coltitle=ocBluTitle,left=3mm,boxed title style={left=1mm}",

  example    = "colback=ocCynBack,colframe=ocCynFrame,coltitle=ocCynTitle,left=3mm,boxed title style={left=1mm}",
}

-- Optional default titles (otherwise capitalised automatically)
local callout_titles = {
  tldr       = "tl;dr",
  summary    = "tl;dr",
  abstract   = "tl;dr",
  note       = "Note",
  info       = "Information",
  tip        = "Tip",
  hint       = "Hint",
  important  = "Important",
  faq        = "FAQ",
  help       = "Help",
  question   = "Question",
  quote      = "Quote",
  cite       = "Quote",
  todo       = "TODO",
  success    = "Success",
  check      = "Success",
  done       = "Success",
  fail       = "Failure",
  failure    = "Failure",
  missing    = "Failure",
  warning    = "Warning",
  caution    = "Warning",
  attention  = "Critical Warning",

  danger     = "Danger",

  bug        = "Bug",
  error      = "Error",

  definition = "Definition",

  terminus   = "Terminus",

  addendum   = "Addendum",

  example    = "Example",
}

local default_style = "colback=gray!5!white,colframe=gray!40!black"

-- Icons per callout tag (LaTeX macros, defined in the .tex/.icl preamble)
local callout_icons = {
  tldr      = "\\iconTldr";
  summary   = "\\iconTldr";
  abstract  = "\\iconTldr";

  note      = "\\iconNote";

  info      = "\\iconInfo",

  tip       = "\\iconHint",
  hint      = "\\iconHint",
  important = "\\iconIHint",

  faq       = "\\iconHelp",
  help      = "\\iconHelp",

  question  = "\\iconQuestion",

  quote     = "\\iconQuote",
  cite      = "\\iconQuote",

  todo      = "\\iconTodo",

  success   = "\\iconCheck",
  check     = "\\iconCheck",
  done      = "\\iconCheck",

  fail      = "\\iconCross",
  failure   = "\\iconCross",
  missing   = "\\iconCross",

  warning   = "\\iconWarning",
  caution   = "\\iconWarning",
  attention = "\\iconCWarning",

  bug       = "\\iconBug",
  error     = "\\iconBug",
  danger    = "\\iconDanger",

  definition = "\\iconDefinition",

  terminus  = "\\iconTerminus",

  addendum  = "\\iconAddendum",

  example   = "\\iconExample"
}

local function capitalize(tag)
  return (tag:gsub("^%l", string.upper))
end

local function get_style(tag)
  -- if global theme is gray/mono, force all callouts to MONO_STYLE
  if callout_theme == "gray" then
    return MONO_STYLE
  end
  return callout_styles[tag] or default_style
end

local function get_default_title(tag)
  return callout_titles[tag] or capitalize(tag)
end

local function get_icon(tag)
  return callout_icons[tag]
end

local function trim_trailing_ws(text)
  return (text:gsub("%s*$", ""))
end

local function render_blocks_as_latex(blocks)
  if not blocks or #blocks == 0 then
    return ""
  end
  local doc = pandoc.Pandoc(blocks)
  local latex = pandoc.write(doc, "latex")
  return trim_trailing_ws(latex)
end

local function figure_to_nonfloat(el)
  local content_tex = render_blocks_as_latex(el.content)
  if content_tex == "" then
    return {}
  end

  local caption_tex = ""
  if el.caption and el.caption.long and #el.caption.long > 0 then
    caption_tex = render_blocks_as_latex(el.caption.long)
  end

  local label_tex = ""
  if el.identifier and el.identifier ~= "" then
    label_tex = "\\label{" .. el.identifier .. "}"
  end

  local caption_line = ""
  if caption_tex ~= "" then
    caption_line = "\\captionof{figure}{" .. caption_tex .. "}" .. label_tex
  elseif label_tex ~= "" then
    caption_line = "\\refstepcounter{figure}" .. label_tex
  end

  local raw = "{\\centering\n" .. content_tex .. "\n"
  if caption_line ~= "" then
    raw = raw .. caption_line .. "\n"
  end
  raw = raw .. "\\par}\n"

  return { pandoc.RawBlock("latex", raw) }
end

local function rewrite_figures_in_callout(blocks)
  if not blocks or #blocks == 0 then
    return blocks
  end
  local container = pandoc.Div(blocks)
  local walker = {
    Figure = function(el)
      return figure_to_nonfloat(el)
    end,
  }
  local adjusted = pandoc.walk_block(container, walker)
  return adjusted.content
end

-- read theme from metadata: callout-theme: gray | color
function Meta(meta)
  local theme = meta["callout-theme"]
  if theme then
    local val = pandoc.utils.stringify(theme)
    if val == "gray" or val == "mono" then
      callout_theme = "gray"
    else
      callout_theme = "color"
    end
  end
end

-- Try to parse a BlockQuote as Obsidian callout.
-- Returns nil if this is a normal blockquote.
local mark_callout_headings

local function parse_callout(el)
  local blocks = el.content
  if #blocks == 0 then
    return nil
  end

  local first = blocks[1]
  if first.t ~= "Para" then
    return nil
  end

  local inlines = first.content
  if #inlines == 0 then
    return nil
  end

  -- find first non-space inline
  local i = 1
  while i <= #inlines and inlines[i].t == "Space" do
    i = i + 1
  end
  if i > #inlines or inlines[i].t ~= "Str" then
    return nil
  end

  local marker_text = inlines[i].text

  -- support [!tag], [!tag]- and [!tag]+ in a single token
  local raw_tag, fold = marker_text:match("^%[!(.-)%]([%+%-]?)$")
  if not raw_tag then
    -- fallback: only [!tag], fold marker as separate token
    raw_tag = marker_text:match("^%[!(.-)%]$")
    if not raw_tag then
      return nil
    end
  end

  local tag = raw_tag:lower()
  i = i + 1

  -- optional space
  if i <= #inlines and inlines[i].t == "Space" then
    i = i + 1
  end

  -- optional separate fold marker (+ / -)
  if i <= #inlines and inlines[i].t == "Str" and (inlines[i].text == "+" or inlines[i].text == "-") then
    i = i + 1
    if i <= #inlines and inlines[i].t == "Space" then
      i = i + 1
    end
  end

  -- split remaining inlines of first Para at first SoftBreak:
  --   - before SoftBreak = optional title
  --   - after SoftBreak  = first body paragraph
  local title_inlines = {}
  local body_first_para_inlines = nil

  while i <= #inlines do
    local inline = inlines[i]
    if inline.t == "SoftBreak" then
      -- everything after the first SoftBreak belongs to the body
      i = i + 1
      if i <= #inlines then
        body_first_para_inlines = {}
        while i <= #inlines do
          body_first_para_inlines[#body_first_para_inlines + 1] = inlines[i]
          i = i + 1
        end
      end
      break
    else
      title_inlines[#title_inlines + 1] = inline
      i = i + 1
    end
  end

  if #title_inlines == 0 then
    title_inlines = nil
  end

  -- build body blocks
  local body_blocks = {}

  -- if there was inline content after the SoftBreak, treat it as first body Para
  if body_first_para_inlines and #body_first_para_inlines > 0 then
    body_blocks[#body_blocks + 1] = pandoc.Para(body_first_para_inlines)
  end

  -- all blocks after the first Para are body as well
  for bi = 2, #blocks do
    body_blocks[#body_blocks + 1] = blocks[bi]
  end

  body_blocks = mark_callout_headings(body_blocks)

  return {
    tag   = tag,
    title = title_inlines,
    body  = body_blocks,
  }
end

-- Render title inlines to LaTeX
local function render_title_inlines(inlines)
  if not inlines or #inlines == 0 then
    return nil
  end
  local doc = pandoc.Pandoc({ pandoc.Para(inlines) })
  local latex = pandoc.write(doc, "latex")
  latex = latex:gsub("%s*$", "")
  return latex
end

local function ensure_class(attr, class_name)
  local classes = attr.classes or {}
  for _, existing in ipairs(classes) do
    if existing == class_name then
      return
    end
  end
  classes[#classes + 1] = class_name
  attr.classes = classes
end

mark_callout_headings = function(blocks)
  if not blocks or #blocks == 0 then
    return blocks
  end
  local container = pandoc.Div(blocks)
  local walker = {
    Header = function(el)
      el.attr = el.attr or pandoc.Attr()
      ensure_class(el.attr, "unnumbered")
      ensure_class(el.attr, "unlisted")
      return el
    end
  }
  local adjusted = pandoc.walk_block(container, walker)
  return adjusted.content
end

local function get_label_style(tag)
  -- start from the effective style (including gray mode)
  local s = get_style(tag)

  -- "boxed title style={...}" clashes with \tcolorbox boxes without a title
  s = s:gsub(",boxed title style=%b{}", "")

  -- for the label variant:
  --  - use the full text width
  --  - disable additional borders (reuse the existing colframe)
  s = s .. ",width=\\linewidth,boxrule=0pt"

  return s
end

-- Convert parsed callout to LaTeX tcolorbox / title-only box
local function callout_to_latex(co)
  local style = get_style(co.tag)
  local icon  = get_icon(co.tag)

  --------------------------------------------------
  -- 1) Title-only: no body, use a full-width tcolorbox
  --------------------------------------------------
  if #co.body == 0 then
    local title_tex
    if co.title and #co.title > 0 then
      title_tex = render_title_inlines(co.title) or ""
    else
      title_tex = get_default_title(co.tag) or ""
    end

    if icon and icon ~= "" then
      title_tex = "\\hspace*{-2.5mm}" .. icon .. "\\; " .. title_tex
    end

    local label_style = get_label_style(co.tag)

    local begin_box = pandoc.RawBlock(
      "latex",
      "\\noindent\\begin{tcolorbox}[" .. label_style .. "]"
    )
    local end_box = pandoc.RawBlock("latex", "\\end{tcolorbox}")

    local blocks = {}
    blocks[#blocks + 1] = pandoc.RawBlock("latex", "\\vspace{2mm}")
    --blocks[#blocks + 1] = pandoc.RawBlock("latex", "\\medskip")
    blocks[#blocks + 1] = begin_box
    blocks[#blocks + 1] = pandoc.Para({ pandoc.RawInline("latex", title_tex) })
    blocks[#blocks + 1] = end_box
    --blocks[#blocks + 1] = pandoc.RawBlock("latex", "\\vspace{2mm}")
    --blocks[#blocks + 1] = pandoc.RawBlock("latex", "\\medskip")

    return blocks
  end

  --------------------------------------------------
  -- 2) Regular case: title and body rendered in one tcolorbox
  --------------------------------------------------
  local title_opt = ""

  if co.title and #co.title > 0 then
    local title_tex = render_title_inlines(co.title) or ""
    if icon and icon ~= "" then
      title_tex = "\\hspace*{-2.5mm}" .. icon .. "\\; " .. title_tex
    end
    title_opt = ",title={" .. title_tex .. "}"
  else
    local default_title = get_default_title(co.tag)
    if default_title and default_title ~= "" then
      local title_tex = default_title
      if icon and icon ~= "" then
        title_tex = "\\hspace*{-2.5mm}" .. icon .. "\\; " .. title_tex
      end
      title_opt = ",title={" .. title_tex .. "}"
    end
  end

  local begin_box = pandoc.RawBlock(
    "latex",
    "\\begin{tcolorbox}[breakable," .. style .. title_opt .. "]"
  )
  local end_box = pandoc.RawBlock("latex", "\\end{tcolorbox}")

  local body_blocks = rewrite_figures_in_callout(co.body)

  local blocks = {}
  --blocks[#blocks + 1] = pandoc.RawBlock("latex", "\\medskip")
  blocks[#blocks + 1] = begin_box
  for _, b in ipairs(body_blocks) do
    blocks[#blocks + 1] = b
  end
  blocks[#blocks + 1] = end_box
  --blocks[#blocks + 1] = pandoc.RawBlock("latex", "\\medskip")

  return blocks
end

function BlockQuote(el)
  local co = parse_callout(el)
  if not co then
    return nil -- normal blockquote
  end
  return callout_to_latex(co)
end

return {
  { Meta = Meta },
  { BlockQuote = BlockQuote },
}
