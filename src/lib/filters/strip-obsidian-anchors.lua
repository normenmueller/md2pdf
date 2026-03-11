-- strip-obsidian-anchors.lua
-- Remove Obsidian-style block anchors such as ^26c877 that otherwise show up
-- as plain text in the rendered PDF.

local function is_anchor_block(block)
  if block.t ~= "Para" and block.t ~= "Plain" then
    return false
  end

  local text = pandoc.utils.stringify(block)
  text = text:gsub("^%s+", ""):gsub("%s+$", "")

  if text:match("^%^[%w%-%_]+$") then
    return true
  end

  return false
end

function Para(block)
  if is_anchor_block(block) then
    return {}
  end
end

function Plain(block)
  if is_anchor_block(block) then
    return {}
  end
end
