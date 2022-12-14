local function hr ()
  return string.rep("-", vim.g.__tabnews_width)
end

local function title (value)
  return "--[" .. value:gsub("#", "") .. " ]--"
end

local function link (value)
  local t = {}
  local double = value:sub(1, 2) == "[[" or value:sub(1, 3) == " [["
  local qs = value:find("%[") + 1
  local qe = double and value:find("]", value:find("]") + 1) or value:find("]")

  t[1] = value:sub(qs, qe - 1)
  t[2] = value:sub(qe + 1, #value)

  return t
end

return {
  hr = hr,
  title = title,
  link = link
}
