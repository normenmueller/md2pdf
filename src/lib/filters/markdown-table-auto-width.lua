-- markdown-table-auto-width.lua
-- Heuristic column width assignment for all LaTeX tables.
-- Idea:
--   - start from equal-width columns
--   - blend in a score-based width (based on cell text length)
--   - clamp per-column widths to [minw, maxw]
--
-- Note:
--   - lower `blend_factor` (for example 0.3) keeps columns closer to equal width

if FORMAT ~= "latex" then
  return {}
end

-- approximate text length of a cell
local function cell_length(cell)
  local s = pandoc.utils.stringify(cell) or ""
  return #s
end

local function adjust_colspecs(tbl)
  local ncols = #tbl.colspecs
  if ncols == 0 then
    return tbl
  end

  -- 1) collect scores per column (max cell length)
  local scores = {}
  for j = 1, ncols do
    scores[j] = 1 -- baseline, so nothing is 0
  end

  local function scan_row(row)
    for j, cell in ipairs(row.cells) do
      local len = cell_length(cell)
      if len > scores[j] then
        scores[j] = len
      end
    end
  end

  -- header rows
  if tbl.head and tbl.head.rows then
    for _, row in ipairs(tbl.head.rows) do
      scan_row(row)
    end
  end

  -- body rows
  if tbl.bodies then
    for _, body in ipairs(tbl.bodies) do
      if body.body then
        for _, row in ipairs(body.body) do
          scan_row(row)
        end
      end
    end
  end

  -- 2) sum scores
  local total_score = 0
  for j = 1, ncols do
    total_score = total_score + scores[j]
  end

  -- fallback: equal widths
  if total_score == 0 then
    local w = 1.0 / ncols
    for j = 1, ncols do
      local align = tbl.colspecs[j][1]
      tbl.colspecs[j] = { align, w }
    end
    return tbl
  end

  -- 3) blend equal width with score-based width
  --    blend_factor=0 means all equal, 1 means fully score-based
  local blend_factor = 0.5
  local equal_width  = 1.0 / ncols

  local widths = {}
  for j = 1, ncols do
    local score_frac = scores[j] / total_score
    widths[j] = (1.0 - blend_factor) * equal_width
               + blend_factor * score_frac
  end

  -- 4) clamp and renormalize
  local minw      = 0.12
  local maxw      = 0.60

  local sum = 0
  for j = 1, ncols do
    local w = widths[j]
    if w < minw then w = minw end
    if w > maxw then w = maxw end
    widths[j] = w
    sum = sum + w
  end

  -- renormalize to sum=1 and force fixed-point strings
  for j = 1, ncols do
    local align = tbl.colspecs[j][1]
    local normalized = widths[j] / sum
    local formatted = string.format("%.6f", normalized)
    tbl.colspecs[j] = { align, formatted }
  end

  return tbl
end

function Table(tbl)
  return adjust_colspecs(tbl)
end
