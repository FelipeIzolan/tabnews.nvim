local components = require("tabnews.component")

local function parser (body)
  local result = {}
  local text = body
  local text_max_width = 76
  local s, e = text:find("\n")

  -- table
  while s do
    s, e = text:find("\n")
    if not s then break end
    table.insert(result, text:sub(0, s - 1))
    text = text:sub(e + 1)
  end

  table.insert(result, text)

  -- format
  for i, value in ipairs(result) do
    local pos = value:find(" ", text_max_width)

    if #value > text_max_width then
      local x = pos and pos or #value
      result[i] = value:sub(0, x)
      table.insert(result, i + 1, value:sub(x + 1))
    end

    local c1, c2 = value:sub(1,1), value:sub(1, 2)

    if c1 == "#" then
      result[i] = components.title(value)
    end

    if c2 == "--" then
      result[i] = components.hr()
    end

    if c1 == "!" or c1 == "[" then
      local x = components.link(value)
      result[i] = x[1]
      table.insert(result, i + 1, x[2])
    end

  end

  return table.unpack(result)
end

return parser
